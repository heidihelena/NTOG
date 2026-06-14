"""Three-axis nodule-malignancy simulation: clinical (CRS-like) + protein (4MP-like)
+ Sybil (deep-learning CT). Synthetic illustration calibrated to published AUCs
(Brock/CRS ~0.72; 4MP/proteomics ~0.74, Guida 2018 / Feng 2023; Sybil ~0.88,
Mikhael 2023). NOT real performance. Shows (a) the discrimination ceiling and how
each orthogonal axis lifts it, (b) the contested-tail strategy (protein only on
the grey zone), and (c) a Venn of which malignancies each axis uniquely catches.
"""
import json
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_predict, StratifiedKFold
from sklearn.metrics import roc_auc_score
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib_venn import venn3

rng = np.random.default_rng(42)
N = 6000

# --- Orthogonal latent components (each an independent axis of information) ---
C  = rng.normal(size=N)   # common cancer signal (all three modalities see it)
Uc = rng.normal(size=N)   # clinical/imaging-semantic unique (size, morphology, growth)
Up = rng.normal(size=N)   # protein-unique biology (not visible on CT)
Us = rng.normal(size=N)   # Sybil sub-visual texture (not semantic, not protein)

# True malignancy depends on ALL axes -> each carries real orthogonal signal.
logit = -1.8 + 1.0*C + 1.2*Uc + 1.4*Up + 1.3*Us
Y = (rng.uniform(size=N) < 1/(1+np.exp(-logit))).astype(int)

# Each modality sees common + its own unique signal; calibrate added noise so the
# single-axis AUROC matches the published anchors (CRS 0.72; 4MP 0.74; Sybil 0.88).
ec, ep, es = rng.normal(size=N), rng.normal(size=N), rng.normal(size=N)
def calibrate(clean, e, target):
    lo, hi = 0.02, 6.0
    for _ in range(45):
        mid = (lo + hi) / 2
        if roc_auc_score(Y, clean + mid * e) > target:
            lo = mid          # signal too strong -> add more noise
        else:
            hi = mid
    return clean + (lo + hi) / 2 * e

clinical = calibrate(C + Uc, ec, 0.72)        # Brock/CRS-like: semantic imaging axis
protein  = calibrate(C + Up, ep, 0.74)        # 4MP-like: orthogonal blood-biology axis
sybil    = calibrate(C + Uc + Us, es, 0.86)   # Sybil: reads whole CT (semantic + sub-visual)

def cv_prob(cols):
    X = np.asarray(cols)
    if X.ndim == 1:
        X = X[:, None]
    skf = StratifiedKFold(5, shuffle=True, random_state=1)
    return cross_val_predict(LogisticRegression(max_iter=1000), X, Y, cv=skf,
                             method="predict_proba")[:, 1]

prevalence = Y.mean()
pc  = cv_prob(clinical)
pp  = cv_prob(protein)
ps  = cv_prob(sybil)
pcp = cv_prob(np.c_[clinical, protein])
pcs = cv_prob(np.c_[clinical, sybil])
pall = cv_prob(np.c_[clinical, protein, sybil])

auc = lambda p: roc_auc_score(Y, p)

# --- Contested-tail strategy: protein measured only on the clinical grey zone ---
lo, hi = np.quantile(pc, [0.30, 0.70])            # indeterminate clinical band
contested = (pc >= lo) & (pc <= hi)
frac_tested = contested.mean()
hybrid = pc.copy()
hybrid[contested] = pcp[contested]                 # add protein only where contested

ladder = {
    "Clinical only (CRS-like)":        auc(pc),
    "Protein only (4MP-like)":         auc(pp),
    "Sybil only (DL CT)":              auc(ps),
    f"Clinical + Protein (contested {frac_tested*100:.0f}% only)": auc(hybrid),
    "Clinical + Protein (all)":        auc(pcp),
    "Clinical + Sybil (all)":          auc(pcs),
    "All three axes":                  auc(pall),
}

# --- Venn: which MALIGNANT nodules each axis catches at fixed 85% specificity ---
def caught_set(score):
    thr = np.quantile(score[Y == 0], 0.85)        # 85% specificity
    return set(np.where((Y == 1) & (score >= thr))[0]), thr, (score[Y == 0] >= thr).mean()

setC, _, fprC = caught_set(clinical)
setP, _, fprP = caught_set(protein)
setS, _, fprS = caught_set(sybil)
nmal = int(Y.sum())
union = setC | setP | setS
sens = {"Clinical": len(setC)/nmal, "Protein": len(setP)/nmal,
        "Sybil": len(setS)/nmal, "Any of three (union)": len(union)/nmal}

# ===================== Figure A: the discrimination ladder =====================
fig, ax = plt.subplots(figsize=(9.4, 4.8))
labels = list(ladder.keys())[::-1]
vals = [ladder[k] for k in labels]
colors = []
for k in labels:
    if k.startswith("All three"): colors.append("#0072B2")
    elif "contested" in k: colors.append("#D55E00")
    elif "Sybil" in k: colors.append("#009E73")
    elif "Protein" in k: colors.append("#CC79A7")
    else: colors.append("#7a8aa0")
bars = ax.barh(labels, vals, color=colors)
ax.axvline(ladder["Clinical only (CRS-like)"], color="#7a8aa0", ls="--", lw=1)
ax.text(ladder["Clinical only (CRS-like)"]+0.002, -0.4, "imaging+clinical ceiling", color="#5a6a80", fontsize=8)
for b, v in zip(bars, vals):
    ax.text(v+0.003, b.get_y()+b.get_height()/2, f"{v:.3f}", va="center", fontsize=9, fontweight="bold")
ax.set_xlim(0.5, 1.0)
ax.set_xlabel("Cross-validated AUROC vs latent malignancy")
ax.set_title("Breaking the 0.72 ceiling: orthogonal axes for nodule malignancy\n"
             "Synthetic illustration calibrated to literature (CRS~0.72; 4MP~0.74; Sybil~0.88) — not real performance",
             fontsize=10)
plt.tight_layout()
plt.savefig("/tmp/axes_run/axis_ladder.png", dpi=140)
plt.close()

# ===================== Figure B: Venn of malignancies caught =====================
fig, ax = plt.subplots(figsize=(7.6, 6.4))
v = venn3([setC, setP, setS],
          set_labels=(f"Clinical\n(sens {sens['Clinical']*100:.0f}%)",
                      f"Protein 4MP\n(sens {sens['Protein']*100:.0f}%)",
                      f"Sybil DL CT\n(sens {sens['Sybil']*100:.0f}%)"),
          set_colors=("#7a8aa0", "#CC79A7", "#009E73"), alpha=0.55, ax=ax)
ax.set_title(f"Malignant nodules caught by each axis at fixed 85% specificity\n"
             f"(n={nmal} true malignancies; union sensitivity {sens['Any of three (union)']*100:.0f}%)\n"
             f"Synthetic illustration — each axis uniquely catches cancers the others miss",
             fontsize=10)
plt.tight_layout()
plt.savefig("/tmp/axes_run/axis_venn.png", dpi=140)
plt.close()

# ===================== console summary =====================
print(f"n={N}  malignant prevalence={prevalence*100:.1f}%  ({nmal} cancers)\n")
print("AUROC ladder (5-fold cross-validated):")
for k, vv in ladder.items():
    print(f"  {k:42s} {vv:.3f}")
print(f"\nContested-tail strategy: protein measured on {frac_tested*100:.0f}% of nodules "
      f"(clinical grey zone)\n  recovers {(ladder['Clinical + Protein (contested %d%% only)'%round(frac_tested*100)]-ladder['Clinical only (CRS-like)']):.3f} "
      f"of the {(ladder['Clinical + Protein (all)']-ladder['Clinical only (CRS-like)']):.3f} AUC gain from testing everyone.")
print("\nSensitivity at 85% specificity (single axis):")
for k, vv in sens.items():
    print(f"  {k:24s} {vv*100:.0f}%")
print("\nVenn regions among malignancies (caught at 85% spec):")
print(f"  caught by all three:          {len(setC&setP&setS)}")
print(f"  Sybil only (others miss):     {len(setS-setC-setP)}")
print(f"  Protein only (others miss):   {len(setP-setC-setS)}")
print(f"  Clinical only (others miss):  {len(setC-setP-setS)}")
print(f"  missed by all three:          {nmal-len(union)}")

json.dump({"ladder": ladder, "sensitivity_at_85spec": sens, "frac_tested_contested": frac_tested,
           "prevalence": prevalence, "n": N, "n_malignant": nmal},
          open("/tmp/axes_run/summary.json", "w"), indent=2)

# Export the three-axis cohort for epinet's honest harness.
import csv as _csv
with open("/tmp/axes_run/nodes_axes.csv", "w", newline="") as f:
    w = _csv.writer(f); w.writerow(["ID", "Outcome", "clinical", "protein", "sybil"])
    for i in range(N):
        w.writerow([f"nod_{i}", int(Y[i]), f"{clinical[i]:.4f}", f"{protein[i]:.4f}", f"{sybil[i]:.4f}"])
with open("/tmp/axes_run/edges_axes.csv", "w", newline="") as f:
    f.write("SourceID,TargetID,Relationship,Weight\n")
print("\nwrote nodes_axes.csv for epinet")
