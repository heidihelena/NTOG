"""Independent validation of EpiNet's headline outputs on the three-axis cohort,
using a different stack (sklearn + DeLong + dcurves + DiCE / closed-form margin).

EpiNet reference (from /tmp/epinet_axes): AUROC 0.855 (iter mean 0.849+/-0.008);
calibration Brier 0.131, slope 1.154, intercept ~0; contestability flip-distance
mean ~1.42 SD; feature value-of-information sybil 0.41 > protein 0.31 > clinical 0.28.
"""
import warnings; warnings.filterwarnings("ignore")
from pathlib import Path
import numpy as np, pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_predict, StratifiedKFold, permutation_test_score
from sklearn.metrics import roc_auc_score, brier_score_loss
from scipy import stats

DATA = Path(__file__).resolve().parent.parent / "data"      # self-contained, relative
df = pd.read_csv(DATA / "three_axis_cohort.csv")
y = df["Outcome"].to_numpy().astype(int)
feats = ["clinical", "protein", "sybil"]
X = df[feats].to_numpy()
n, prev = len(y), y.mean()
print(f"cohort n={n}, malignant prevalence={prev:.3f}\n")

EPI = {"auroc": 0.855, "brier": 0.131, "cal_slope": 1.154, "cal_intercept": -0.004,
       "flip_mean": 1.42, "leverage": {"sybil": 0.412, "protein": 0.306, "clinical": 0.282}}

# ---------- 1. DeLong AUC + variance (fast DeLong, Sun & Xu) ----------
def _midrank(x):
    J = np.argsort(x); Z = x[J]; N = len(x); T = np.zeros(N, float); i = 0
    while i < N:
        j = i
        while j < N and Z[j] == Z[i]: j += 1
        T[i:j] = 0.5 * (i + j - 1) + 1; i = j
    T2 = np.empty(N, float); T2[J] = T; return T2

def delong(y_true, *scores):
    order = np.argsort(-y_true, kind="mergesort")  # positives first
    yt = y_true[order]; m = int(yt.sum())
    preds = np.vstack([s[order] for s in scores])
    k = preds.shape[0]; nn = preds.shape[1] - m
    pos, neg = preds[:, :m], preds[:, m:]
    tx = np.vstack([_midrank(pos[r]) for r in range(k)])
    ty = np.vstack([_midrank(neg[r]) for r in range(k)])
    tz = np.vstack([_midrank(preds[r]) for r in range(k)])
    aucs = tz[:, :m].sum(1) / m / nn - (m + 1) / 2.0 / nn
    v01 = (tz[:, :m] - tx) / nn; v10 = 1 - (tz[:, m:] - ty) / m
    cov = np.cov(v01) / m + np.cov(v10) / nn
    cov = np.atleast_2d(cov)
    return aucs, cov

def auc_ci(y_true, score):
    a, cov = delong(y_true, score)
    se = float(np.sqrt(cov[0, 0])); z = stats.norm.ppf(0.975)
    return a[0], max(0, a[0] - z * se), min(1, a[0] + z * se)

def auc_diff_p(y_true, s1, s2):
    a, cov = delong(y_true, s1, s2)
    d = a[0] - a[1]; var = cov[0, 0] + cov[1, 1] - 2 * cov[0, 1]
    z = d / np.sqrt(var) if var > 0 else 0.0
    return d, 2 * (1 - stats.norm.cdf(abs(z)))

print("=== 1. Single-axis discrimination (DeLong CIs) — sanity vs sklearn ===")
for f in feats:
    pt, lo, hi = auc_ci(y, df[f].to_numpy())
    print(f"  {f:9s} AUROC {pt:.3f} (95% CI {lo:.3f}-{hi:.3f})  [sklearn {roc_auc_score(y, df[f]):.3f}]")
d, p = auc_diff_p(y, df["sybil"].to_numpy(), df["clinical"].to_numpy())
print(f"  paired DeLong  sybil - clinical: dAUC={d:+.3f}  p={p:.2e}")

# ---------- 2. Honest combined model (sklearn RF + logistic), 5-fold CV ----------
print("\n=== 2. Combined 3-axis model — independent 5-fold CV (compare EpiNet 0.855) ===")
skf = StratifiedKFold(5, shuffle=True, random_state=1)
oof = {}
for name, mdl in [("RandomForest", RandomForestClassifier(n_estimators=300, max_depth=10, random_state=0)),
                  ("Logistic", LogisticRegression(max_iter=1000))]:
    p = cross_val_predict(mdl, X, y, cv=skf, method="predict_proba")[:, 1]
    oof[name] = p
    pt, lo, hi = auc_ci(y, p)
    print(f"  {name:13s} AUROC {pt:.3f} (95% CI {lo:.3f}-{hi:.3f})")
print(f"  EpiNet honest RF: 0.855 (iter mean 0.849)")

# ---------- 3. Calibration of the honest model (compare Brier 0.131, slope 1.15) ----------
print("\n=== 3. Calibration — independent (EpiNet: Brier 0.131, slope 1.154, intercept ~0) ===")
p = np.clip(oof["RandomForest"], 1e-6, 1 - 1e-6)
lp = np.log(p / (1 - p))
slope = LogisticRegression(max_iter=1000).fit(lp.reshape(-1, 1), y).coef_[0, 0]
# calibration-in-the-large intercept: 1-D Newton on intercept with offset=lp
a = 0.0
for _ in range(50):
    pi = 1 / (1 + np.exp(-(a + lp))); g = np.sum(y - pi); hh = -np.sum(pi * (1 - pi))
    if hh == 0: break
    a -= g / hh
print(f"  out-of-fold (CV) calibration: Brier {brier_score_loss(y, oof['RandomForest']):.3f} | slope {slope:.3f} | intercept {a:+.3f}")
print(f"  EpiNet apparent/iteration slope 1.154 vs CV (out-of-fold) slope {slope:.3f} — same direction check below")

# ---------- 3b. Apparent vs optimism-corrected calibration slope (Harrell bootstrap) ----------
# Resolves the 1.15-vs-0.94 question with the same logic rms::validate() uses.
def cal_slope(model, Xtr, ytr, Xte, yte):
    model.fit(Xtr, ytr)
    pte = np.clip(model.predict_proba(Xte)[:, 1], 1e-6, 1 - 1e-6)
    return LogisticRegression(max_iter=1000).fit(np.log(pte / (1 - pte)).reshape(-1, 1), yte).coef_[0, 0]
base = RandomForestClassifier(n_estimators=300, max_depth=10, random_state=0)
apparent = cal_slope(base, X, y, X, y)
rng_b = np.random.default_rng(0); opt = []
for _ in range(200):
    idx = rng_b.integers(0, n, n)
    s_boot = cal_slope(RandomForestClassifier(n_estimators=300, max_depth=10, random_state=0), X[idx], y[idx], X[idx], y[idx])
    s_orig = cal_slope(RandomForestClassifier(n_estimators=300, max_depth=10, random_state=0), X[idx], y[idx], X, y)
    opt.append(s_boot - s_orig)
corrected = apparent - np.mean(opt)
print(f"  RF calibration slope: apparent {apparent:.3f} | optimism-corrected (B=200) {corrected:.3f}")
print(f"  -> headline honest slope is the optimism-corrected value; EpiNet 1.15 is apparent/iteration-based.")

# ---------- 4. Decision curve / net benefit (dcurves) ----------
print("\n=== 4. Decision curve — net benefit (dcurves), three thresholds ===")
try:
    from dcurves import dca
    dcdf = pd.DataFrame({"y": y, "model": oof["RandomForest"]})
    res = dca(data=dcdf, outcome="y", modelnames=["model"],
              thresholds=np.arange(0.05, 0.51, 0.01))
    for t in (0.10, 0.20, 0.30):
        sub = res[(res["model"] == "model") & (np.isclose(res["threshold"], t))]
        nb = float(sub["net_benefit"].iloc[0])
        all_ = res[(res["model"] == "all") & (np.isclose(res["threshold"], t))]["net_benefit"].iloc[0]
        print(f"  threshold {t:.2f}: model NB {nb:+.4f}  vs treat-all {all_:+.4f}  (delta {nb-all_:+.4f})")
except Exception as e:
    print("  dcurves failed:", repr(e)[:200])

# ---------- 5. Counterfactual flip-distance vs EpiNet contestability ----------
print("\n=== 5. Counterfactual flip-distance (compare EpiNet mean ~1.42 SD; leverage sybil>protein>clinical) ===")
Z = (X - X.mean(0)) / X.std(0)
clf = LogisticRegression(max_iter=1000).fit(Z, y)
w = clf.coef_[0]; b = clf.intercept_[0]
margin = (Z @ w + b) / np.linalg.norm(w)          # signed distance to boundary, SD units
print(f"  [closed-form linear margin]  mean |flip-distance| = {np.abs(margin).mean():.3f} SD  (EpiNet ~1.42)")
lev = np.abs(w) / np.abs(w).sum()
order = np.argsort(-lev)
print("  [feature value-of-information] " + ", ".join(f"{feats[i]} {lev[i]:.3f}" for i in order))
print("  EpiNet leverage:               " + ", ".join(f"{k} {v:.3f}" for k, v in sorted(EPI['leverage'].items(), key=lambda x:-x[1])))

# DiCE counterfactuals (independent), small sample
try:
    import dice_ml
    from dice_ml import Dice
    rf = RandomForestClassifier(n_estimators=200, max_depth=10, random_state=0).fit(X, y)
    dd = dice_ml.Data(dataframe=df[feats + ["Outcome"]], continuous_features=feats, outcome_name="Outcome")
    mm = dice_ml.Model(model=rf, backend="sklearn")
    exp = Dice(dd, mm, method="random")
    samp = df[feats].sample(50, random_state=3).reset_index(drop=True)
    cf = exp.generate_counterfactuals(samp, total_CFs=1, desired_class="opposite", verbose=False)
    dists = []
    sd = X.std(0)
    for i, e in enumerate(cf.cf_examples_list):
        if e.final_cfs_df is None or len(e.final_cfs_df) == 0: continue
        orig = samp.iloc[i][feats].to_numpy(float)
        cfv = e.final_cfs_df[feats].iloc[0].to_numpy(float)
        dists.append(np.linalg.norm((cfv - orig) / sd))
    if dists:
        print(f"  [DiCE counterfactuals, n={len(dists)}]  mean flip-distance = {np.mean(dists):.3f} SD")
    else:
        print("  [DiCE] no counterfactuals returned")
except Exception as e:
    print("  DiCE failed (closed-form result stands):", repr(e)[:160])

# ---------- 6. Permutation null (signal vs chance) — note what it does and does NOT test ----------
print("\n=== 6. Label-permutation null (does the model beat chance?) ===")
score, perm_scores, pval = permutation_test_score(
    LogisticRegression(max_iter=1000), X, y, scoring="roc_auc",
    cv=StratifiedKFold(5, shuffle=True, random_state=1), n_permutations=200, random_state=0)
print(f"  observed AUROC {score:.3f} | permuted-null mean {perm_scores.mean():.3f} | p = {pval:.4f}")
print("  NOTE: the null is rejected because real signal IS present — but it tests signal-vs-chance,")
print("  NOT whether the three axes are genuinely orthogonal. Orthogonality is a design assumption here.")

print("\nDone.")
