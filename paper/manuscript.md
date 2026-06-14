# The grey zone is the point: model–threshold coupling, decision geometry, and orthogonal information axes for pulmonary nodule pathways

**A reproducible browser sandbox (Nordic Nodule Pathway Sandbox v3) and an honest-evaluation toolkit (EpiNet)**

*Heidi H. Andersén¹²  ·  Nordic Thoracic Oncology Group (NTOG)*
¹ Tampere University · ² University of Turku · Tools powered by Vahtian

> **Draft manuscript — working version.** Educational and research-planning content. The interactive tools are **not medical devices**. All quantitative results below come from **synthetic data** and are calibrated to published discrimination figures; they illustrate *logic and trade-offs*, not real clinical performance. Replace bracketed placeholders before submission.

---

## Abstract

**Background.** Pulmonary-nodule management is usually framed around a risk *threshold* (e.g. refer above 10% malignancy risk). We argue the threshold is meaningless without the *model* that produces the score: model choice sets the rank order, and the threshold merely cuts that model-specific distribution. The clinically interesting object is therefore the **gap population** — the patients whose eligibility *changes* when the model or threshold changes — and the **grey zone**, where benign and malignant nodules overlap in feature space. Time compounds both: a nodule that is benign-appearing today can declare itself malignant tomorrow, so classification is a moving target, not a label.

**Methods.** We built two transparent, openly inspectable tools. (1) The **Nordic Nodule Pathway Sandbox v3** — a single self-contained HTML file that simulates a class-conditional synthetic nodule cohort, computes continuous risk (Brock 2013/PanCan, Herder PET update, a non-monotonic volume-doubling-time growth term, and a composite CRS), compares candidate pathways, and now quantifies the **gap population**, **harm-weight sensitivity**, **decision-boundary fragility**, and the value of adding an **orthogonal information axis**. (2) **EpiNet**, a Python "honest evaluation" toolkit that scores any cohort for discrimination, calibration, a label-permutation null, and **contestability** (the closed-form distance to flip a call), producing a TRIPOD-style model card. We (a) verified that EpiNet's nodule-model port reproduces the sandbox/published models, (b) compared Brock vs Mayo vs the Nordic composite against a latent malignancy label, and (c) simulated a three-axis cohort — imaging-clinical (CRS), a **protein panel** (4MP-like), and a **deep-learning CT** model (Sybil-like) — to quantify what an orthogonal axis buys, for everyone versus only the grey zone.

**Results.** Port validation passed exactly (Δ = 0 over 5,000 random inputs; every Brock/Mayo coefficient `exp(β)` matched its published odds ratio). On the synthetic cohort the Nordic composite was statistically indistinguishable from Brock and Mayo on static discrimination (AUROC ≈ 0.70–0.72; pairwise Δ ≈ 0, *p* > 0.7) but reranked fast-growing nodules upward as designed (growth-tracking *r* = 0.24). On a 6,000-nodule three-axis cohort the single-axis AUROCs are **calibrated inputs** (CRS 0.72, protein 0.74, deep-learning CT 0.83 cross-validated); with orthogonality built into the data-generating process, the (emergent) three-axis combination reached **0.86** (EpiNet honest model 0.85; calibration slope near 1, reported with its apparent-vs-corrected discrepancy rather than a single flattering value). *By construction* the protein axis added discrimination on top of the CT axis (+0.03), and at fixed 85% specificity uniquely "caught" 183 malignancies the imaging axes missed (single-seed, illustrative). Applying the protein axis to **only the contested 40% grey zone** recovered roughly **half** the full-cohort gain. *These results show that **if** axes are orthogonal then combining them helps; they do not establish that real assays are orthogonal.*

**Conclusion.** Squeezing the existing imaging-clinical features cannot exceed an information ceiling (~0.72 in the hard, indeterminate regime). Breaking it requires an **orthogonal axis** — a blood biomarker or a deep-learning imaging signature — and a **hypothesis worth prospective testing** is to deploy it on the **grey zone**, not the whole cohort. Treating model–threshold coupling, decision geometry, and time as first-class objects gives guideline groups a concrete, quantitative language for pathway design.

**Keywords:** pulmonary nodule; lung cancer screening; Brock model; volume doubling time; clinical pathway; gap population; grey zone; decision support; calibration; contestability; Nordic guideline.

---

## 1. Introduction

Lung-cancer screening and incidental-nodule follow-up translate continuous clinical and radiological information into discrete actions: routine surveillance, shortened-interval CT, PET-CT, biopsy, surgery, or multidisciplinary-team (MDT) review. These actions are usually described *as if* they follow from a threshold alone. In practice a threshold has meaning **only relative to the model that generates the score**. Change the model and you change the score distribution, the rank order of patients, and which patients cross the same nominal cut-point. We call this the **model–threshold coupling problem**.

Two consequences follow. First, two pathways can report similar AUROC or sensitivity while moving **different patients** into and out of eligibility — the **gap population**. Its clinical and demographic profile is policy-relevant even when aggregate discrimination is unchanged. Second, thresholds draw a line through a feature space in which benign and malignant nodules **overlap** — the **grey zone**. Patients near the class centroids are easy; patients near the centre of the distance-ratio distribution are *structurally* ambiguous, and no better cut-point resolves them.

**Time is the third axis, and it is the one clinicians feel most.** A nodule's malignancy is not a fixed label but a latent state revealed over time: *benign today can be malignant tomorrow*. Volume-doubling time (VDT), interval growth, and density change are the temporal read-out, and "imminent" cancers (those that will declare within ~12 months) have a distinct biological signature. Surveillance exists precisely because a single timepoint is insufficient; the gap population and grey zone therefore **move** between scans. Any honest pathway tool must represent uncertainty *and* its evolution in time.

This manuscript describes two open tools built around these ideas and uses them to ask a concrete question raised in NTOG working-group discussion: **the imaging-clinical model plateaus around AUROC 0.72 in the hard regime; what would it take to do better?** The answer, we show, is not more data on the same features (that buys precision, not ceiling) but an **orthogonal information axis** — and the cheapest way to capture its benefit is to spend it on the grey zone.

---

## 2. The two tools

### 2.1 Nordic Nodule Pathway Sandbox v3 (the simulator)
A single self-contained HTML file (no content-delivery network, no server, no data egress; a strict Content-Security-Policy enforces this). It has four modules:

1. **Single nodule** — composite risk (CRS), Brock probability, optional Herder PET update, the non-monotonic growth term `G(VDT)`, Euclidean distance to cohort centroids, and a four-centroid soft-mixture score.
2. **Cohort simulation** — a seed-reproducible class-conditional synthetic cohort (malignancy sampled first, features conditional on it), ROC/AUC, grey-zone geometry, and decision-boundary robustness.
3. **Pathway comparison** — candidate pathways (GrowCAT-style growth rules, Brock-only, CRS, a Hybrid Nordic draft, and a custom rule), with sensitivity/specificity/PPV/NPV, **gap population**, **harm-weight sensitivity**, and **boundary fragility**.
4. **Information axes** *(new)* — add a protein panel and/or a deep-learning CT axis with adjustable standalone AUROC and redundancy with CRS; see the discrimination ladder, the contested-grey-zone-only strategy, and the complementarity of axes.

Live: `https://ntog.org/nordic-nodule-pathway-sandbox-v3.html`.

### 2.2 EpiNet (the evaluator)
A Python toolkit (`pip install -e .`) whose default path is **honest evaluation**: a RandomForest over graph features + node attributes reported with discrimination (AUROC, AUPRC), **calibration** (Brier, slope, intercept), bootstrap CIs, a label-permutation null, community-aware splitting, small-cohort warnings, a reproducibility/provenance block, and a TRIPOD+AI-flavoured `model_card.md`. Its **contestability** lens computes the closed-form smallest feature-space move that flips a node's nearest-centroid class, plus a per-feature value-of-information ranking. The graph layer is optional: **in this paper we supplied no edges, so EpiNet ran in its single-CSV / feature-space mode** — the graph features degenerate (all nodes are isolates) and the model uses only the node attributes (here, the three axis scores). Statements below about "graph features" therefore do not apply to this application; the relevant model is a feature-space RandomForest over the three axes.

---

## 3. Methods — reproducible, step by step

> Everything below runs locally. The sandbox needs only a browser. EpiNet needs Python 3.10–3.12.

### 3.0 The data model (so the synthetic numbers are interpretable)
Malignancy `Y` is sampled first; nodule features are then sampled **conditional** on `Y` (class-conditional design — without it, any valid model would look non-discriminatory). Risk scores are computed from those features; an independent **latent malignancy label** is the ground truth used for evaluation. *Because the label is generated from a model that shares features with the scores, absolute AUROCs are not clinical performance — only relative comparisons and behaviour (e.g. growth reranking, complementarity) are trustworthy.*

### 3.1 Install EpiNet
```bash
git clone https://github.com/heidihelena/epinet && cd epinet
python -m venv .venv && . .venv/bin/activate
pip install -e .            # installs the package + the `epinet` command
```

### 3.2 Generate the nodule cohort (the "simulation")
```bash
cd examples
python build_nodule_cohort.py
# -> nodule_nodes.csv, nodule_edges.csv, nodule_risk_scores.csv
```
This emits patients and nodules, with per-nodule Brock/Mayo scores, VDT, a risk tier, and the latent malignancy label. (A copy is included here as `data/nodule_cohort_scores.csv`.)

### 3.3 Verify the models are implemented correctly
```bash
python validate_nodule_models.py
```
Three independent checks: (1) the port reproduces a verbatim transcription of the NTOG tool's formula (floating-point equality); (2) each coefficient's `exp(β)` equals the published odds ratio; (3) hand-traceable worked cases, monotonicity, and VDT properties.

### 3.4 Run the honest evaluation
```bash
epinet --nodes nodes_malignant.csv --edges nodule_edges.csv \
       --outcome-column Outcome --target-outcome 1 \
       --run-contest --output-dir out
```
(`nodes_malignant.csv` = the nodes file with `Outcome` set to the latent malignancy label.) Outputs: `model_metrics.json`, `model_card.md`, contestability report, and `plots/*.png`.

### 3.5 The three-axis experiment
`three_axis_simulation.py` (included) builds a 6,000-nodule cohort in which malignancy depends on **independent latent components**, so each axis carries real *orthogonal* signal:
- **Clinical (CRS-like)** reads the semantic imaging axis (calibrated to AUROC 0.72).
- **Protein (4MP-like)** reads an orthogonal blood-biology axis the CT cannot see (0.74).
- **Deep-learning CT (Sybil-like)** reads the whole image — semantic *plus* sub-visual texture. Its discrimination is stated once, three consistent ways to avoid confusion: **target 0.86** (apparent AUROC, what the noise-calibration step matches on the full data), **0.826 cross-validated** (the value reported in Table §4.3), and **literature anchor 0.86–0.92**. The target↔achieved gap is simply apparent-vs-out-of-fold AUROC.

Each axis's noise is auto-calibrated (binary search) to hit its target standalone AUROC. We then evaluate, by 5-fold cross-validation, single axes, pairwise and triple combinations, a **contested-grey-zone-only** protein strategy, and the **complementarity** of axes at a fixed operating specificity. The same cohort (`data/three_axis_cohort.csv`) is passed to EpiNet for the honest, calibrated, contestability version.
```bash
python three_axis_simulation.py    # writes figures + nodes_axes.csv
epinet --nodes nodes_axes.csv --edges edges_axes.csv \
       --outcome-column Outcome --target-outcome 1 --run-contest --output-dir epinet_axes
```

---

## 4. Results

### 4.1 The models are faithfully implemented
Port validation **passed** on all three checks: max |Δ| Brock = Mayo = 0.00 over 5,000 random inputs; `exp(β)` matched every published odds ratio (e.g. spiculation 2.17, female 1.82, ever-smoker 2.21); all worked cases, monotonicity, and VDT properties held. *Interpretation: the sandbox's risk engine is the published engine — a prerequisite for any downstream claim.*

### 4.2 The Nordic composite vs Brock vs Mayo
On this **small** cohort (n = 117, ~39 events, 33% malignant): AUROC Brock 0.703 (95% CI 0.602–0.796), Mayo 0.716 (0.621–0.809), **Nordic/NTOG 0.711 (0.611–0.805)**. The pairwise differences were not significant (Δ ≈ 0, *p* > 0.7) — but this is a **failure to reject, not equivalence**: at n = 117 the study is underpowered to detect even moderate differences (the CIs span ~0.20 AUROC), so "indistinguishable" should be read as "we cannot tell them apart here," not "they are the same." (This cohort is the small `build_nodule_cohort` example; the axis experiment in §4.3 uses n = 6,000. A powered head-to-head would re-run this comparison at the larger n.) The Nordic score's *distinct* behaviour was **growth reranking**: its rank shift versus Brock tracked growth rate (*r* = 0.24, 95% CI 0.06–0.40, *p* ≈ 0.01) — faster-growing nodules ranked higher, as the growth domain intends. *Interpretation: the Nordic score's contribution is the temporal/growth axis, not a static-discrimination gain — a more defensible and more interesting claim than "ours is better."*

### 4.3 If axes are orthogonal, combining them helps (Figure 1)
**These numbers are bookkeeping of the chosen generative structure, not an empirical finding.** Orthogonality and additivity are *built into* the data-generating process (malignancy depends on independent latent components `Uc`, `Up`, `Us`; the protein axis sees `Up`, which the CT axes do not). The single-axis AUROCs are **calibrated inputs** — a binary search tunes each axis's noise to hit the published anchor — so only the all-three value is emergent, and it too is determined by the assumed independence. The table therefore shows that **if** the axes are orthogonal **then** combining them lifts discrimination; it is **not** evidence that the real assays *are* orthogonal (that is an empirical question; see §5 and Limitation 4).

On the 6,000-nodule three-axis cohort (5-fold CV AUROC):

| Model | AUROC | Status |
|---|---|---|
| Clinical only (CRS-like) | 0.720 | calibrated *input* |
| Protein only (4MP-like) | 0.740 | calibrated *input* |
| Deep-learning CT only (Sybil-like) | 0.826 | calibrated *input* (target 0.86 apparent) |
| CRS + protein (all) | 0.778 | derived |
| CRS + DL-CT (all) | 0.826 | derived |
| **All three axes** | **0.857** | **derived (emergent)** |

Two consequences follow directly from the construction, and should be read as such. (i) `CRS + DL-CT = DL-CT alone` (both 0.826) because, by construction, the Sybil axis already contains the clinical signal `Uc` — i.e. **clinical is redundant with Sybil**, not informative on top of it. (ii) The protein axis adds **+0.031 on top of the CT axis** (0.826 → 0.857) precisely because `Up` is, by construction, unseen by either imaging axis. *Interpretation: the simulation makes explicit a hypothesis — that an axis is worth adding exactly to the extent it is orthogonal — and quantifies its size under that assumption; it does not establish the assumption.*

### 4.4 You don't need to test everyone (the grey-zone strategy)
Measuring the protein axis on **only the contested 40%** (the clinical grey zone) recovered **0.029 of the 0.058** full-cohort AUROC gain — about **half the benefit at 40% of the blood draws**. *Interpretation: spend the expensive axis where the cheap model is uncertain.*

### 4.5 Axes are complementary (Figure 2)
At fixed 85% specificity, among true malignancies: the protein axis uniquely caught **183** cancers that *both* CT axes missed; the DL-CT axis uniquely caught 266; CRS-only 35 (small — by construction the Sybil axis already reads the image); 353 were missed by all. **Union sensitivity 78% vs 42% for CRS alone.** *These are single-seed point estimates without uncertainty intervals, shown to illustrate the structure of complementarity, not to quantify it. Interpretation: the value of a new axis is the cancers it catches that the others cannot — the non-overlapping slices — which here follows from the assumed orthogonality.*

### 4.6 Honest evaluation confirms it (Figures 3–4)
EpiNet's honest model over the three axes reached AUROC **0.85** (iteration mean 0.849 ± 0.008), independently reproduced by a separate stack (RandomForest 0.846, logistic 0.857; see `SCORECARD.md`). **Calibration is reported as a discrepancy, not a single flattering number — and the directions disagree.** The Brier score agrees across tools (EpiNet 0.131; independent 0.135), but the calibration *slope* depends on method: EpiNet's apparent/iteration-based slope is **1.15** (which would imply mild *under*-confidence), whereas the out-of-fold cross-validated slope is **0.94** and the optimism-corrected bootstrap slope (`rms::validate`-style; `code/validate_epinet.py`/`.R`, B = 200) is **0.84** — both < 1, i.e. the model is, if anything, mildly *over*-confident. The corrected/CV values are the trustworthy ones; **reporting only 1.15 would have implied the wrong direction**, which is exactly the kind of selective-number reporting EpiNet's own honest-evaluation stance is meant to prevent. A **label-permutation null** confirms the discrimination beats chance (observed AUROC 0.857 vs permuted-null mean 0.500, *p* = 0.005) — but this tests signal-versus-chance, **not** whether the three axes are genuinely orthogonal; orthogonality is a design assumption here, not a testable output. Contestability ranked **value-of-information** as deep-learning CT (0.41) > protein (0.31) > clinical (0.28) — an *illustrative* ordering that reflects the standardized model on synthetic data, not a biological hierarchy. *Interpretation: the combined model reproduces across tools and beats chance; its trustworthiness claim rests on cross-validation and the permutation null, while the calibration slope is reported with its honest method-dependence.*

---

## 5. Discussion — the clinical benefit of taking the grey zone (and time) seriously

**The grey zone is not noise; it is the patient population that matters.** Easy nodules are managed correctly by any reasonable rule. Disagreement between pathways, fragility under measurement error, and the gap population all concentrate in the same structurally ambiguous region. Designing a pathway *for the grey zone* — rather than optimising an average metric across everyone — is the higher-leverage goal. The sandbox makes this region explicit (distance-ratio geometry, four-centroid mixture, boundary fragility) and counts who lives in it.

**Time turns a label into a trajectory: benign today can be malignant tomorrow.** A single CT gives a snapshot; malignancy is a latent state that growth reveals. This has three practical implications the tools encode:
1. **Growth must be non-monotonic.** Very rapid growth (VDT < ~30 days) is often inflammatory/infective, not malignant; suspicion should peak in an intermediate VDT window. The sandbox's `G(VDT)` does exactly this, preventing the common shortcut "shorter VDT = higher risk."
2. **The grey zone moves.** A nodule near the boundary today may cross it at the next scan. The gap population is therefore *temporal*: surveillance is the mechanism by which time resolves ambiguity, and the question "who needs a shorter interval?" is a gap-population question.
3. **"Imminent" cancer has a distinct signature.** Biomarker work (below) shows that nodules destined to declare within ~12 months carry a separable protein burden — i.e. *time-to-malignancy* is itself partly readable now. That is the strongest argument for an orthogonal molecular axis in surveillance: it can flag the "benign today, malignant tomorrow" nodule earlier than imaging alone.

**Why an orthogonal axis, and which one.** In the hard regime, imaging-clinical discrimination plateaus (~0.72 here; externally Brock reaches ~0.85–0.90 only on *easier*, screen-detected nodules). The ceiling is set by the mutual information between features and outcome, not by sample size. Two orthogonal axes are mature enough to consider:
- A **circulating-protein panel** (Guida, Johansson *et al.*, 2018; Feng, Johansson *et al.*, 2023; the screen-detected-nodule proteome, 2023): integrating a four-marker panel with smoking lifted AUROC from ~0.73 to ~0.83; a 302-protein model beat PLCOm2012 (0.75 vs 0.64) and a commercial autoantibody test; a circulating-proteome score separated malignant from benign nodules *even within LungRADS 4*, with a distinct **imminent-tumour** (≤1 year) signal. This model is **in process of validation in risk/screening populations**.
- A **deep-learning imaging signature** (Sybil; Mikhael *et al.*, 2023): predicts future lung-cancer risk from a single low-dose CT (1-year AUC ~0.86–0.92), capturing sub-visual texture absent from semantic features.

Our simulation is **consistent with** this empirically reported pattern — each axis adds, the protein axis adds *even on top of* the imaging DL axis, and targeting the grey zone is efficient — and turns it into a tunable figure for guideline discussion (sandbox tab 4). We stress that the simulation *assumes* the orthogonality the literature reports; it does not re-establish it. (The value-of-information ranking from EpiNet, CT > protein > clinical, is likewise a reflection of the standardized model coefficients on synthetic data, i.e. illustrative — not a biological ordering.)

**A pathway hypothesis to test (not a recommendation).** The above motivates a two-stage design *worth evaluating on real, outcome-linked data*: Stage 1, the imaging-clinical model confidently resolves the easy majority; Stage 2, an orthogonal axis (protein panel, deep-learning CT re-read, or a deliberately-timed short-interval re-scan to read growth) is applied **only to the contested grey zone**, where value-of-information should be highest, aiming to optimise *net benefit* rather than AUROC. EpiNet's contestability can pre-specify which nodules qualify. **None of this is a clinical recommendation**; all quantities here are synthetic, and the design must be validated prospectively before any clinical use.

---

## 6. Limitations
1. **Synthetic data.** Distributions are plausible working assumptions, not Nordic registry estimates; absolute AUROCs are generator-dependent and must not be read as clinical performance.
2. **Brock is not Nordic-validated.** It is included as an established continuous reference model.
3. **CRS and harm weights are explicit research constructs**, chosen for transparent comparison, not fitted to outcomes; harm weights are subjective (sandbox provides one-way sensitivity).
4. **The orthogonal-axis AUROCs are calibrated to the literature**, not measured here; the experiment demonstrates *logic and trade-offs*, and assumes a given orthogonality that real assays must demonstrate.
5. **No real patient data.** External validation requires Nordic registry linkage, harmonised nodule annotation, outcome ascertainment, and governance approval.

---

## 7. Reproducibility, data, and code availability
- **Sandbox:** single HTML file, `https://ntog.org/nordic-nodule-pathway-sandbox-v3.html` (version stamped; seed + parameters in its JSON export). Archived release & DOI **to follow** on Zenodo.
- **EpiNet:** `https://github.com/heidihelena/epinet` (MIT).
- **This package:** `three_axis_simulation.py` (seed 42), the two synthetic cohorts (`data/`), the EpiNet model card, and Figures 1–4. No patient-level data are included.

## 8. Ethics
Synthetic data only; no patient information. Evaluation on clinical/registry data would require appropriate approvals and data-governance review.

---

## Figure legends

**Figure 1 — Discrimination ladder.** Cross-validated AUROC for each information axis and their combinations on the 6,000-nodule synthetic cohort. The imaging-clinical ceiling (~0.72) is lifted by orthogonal axes; all three reach 0.86. *Synthetic, calibrated to literature — not real performance.*

**Figure 2 — Complementarity (Venn).** Among true malignancies at fixed 85% specificity, the nodules caught by each axis. Non-overlapping slices are the unique value of each axis; the protein panel uniquely catches 183 cancers both CT axes miss. Union sensitivity 78% vs 42% (CRS alone).

**Figure 3 — EpiNet calibration.** Calibration of the honest three-axis model (Brier 0.13). Predicted risks broadly track observed frequencies; the calibration *slope* is near 1 but its exact value is implementation-dependent and is reported with the apparent-vs-corrected discrepancy in §4.6, not as a single flattering number. *Calibration speaks to whether predicted probabilities are accurate; it does **not** by itself establish absence of leakage — that is the job of the cross-validation and label-permutation null (§4.6).*

**Figure 4 — EpiNet contestability / value-of-information.** Left: how far each call is from flipping (the most-contested tail shaded). Right: the features that most drive boundary flips — the quantitative basis for *which axis to add*.

---

## References (to be completed/formatted)
1. McWilliams A, Tammemagi MC, Mayo JR, *et al.* Probability of cancer in pulmonary nodules detected on first screening CT. *N Engl J Med.* 2013;369:910–919.
2. Swensen SJ, *et al.* (Mayo model). *Arch Intern Med.* 1997.
3. Herder GJ, *et al.* Clinical prediction model … added value of 18F-FDG PET. *Chest.* 2005;128:2490–2496.
4. Guida F, … **Johansson M**, *et al.* Assessment of Lung Cancer Risk on the Basis of a Biomarker Panel of Circulating Proteins. *JAMA Oncol.* 2018. doi:10.1001/jamaoncol.2018.2078.
5. Feng X, … **Johansson M**, *et al.* Lung cancer risk discrimination of prediagnostic proteomics measurements compared with existing prediction tools. *J Natl Cancer Inst.* 2023. doi:10.1093/jnci/djad071.
6. Khodayari Moez E, … Hung RJ, *et al.* Circulating proteome for pulmonary nodule malignancy. *J Natl Cancer Inst.* 2023. doi:10.1093/jnci/djad122.
7. Mikhael PG, *et al.* Sybil: A Validated Deep Learning Model to Predict Future Lung Cancer Risk From a Single Low-Dose Chest CT. *J Clin Oncol.* 2023. doi:10.1200/JCO.22.01345.
8. Vickers AJ, Elkin EB. Decision curve analysis. *Med Decis Making.* 2006. *(for net-benefit framing)*
9. Riley RD, *et al.* Minimum sample size for developing a multivariable prediction model. *(for the ~14k robustness estimate)*
10. EpiNet — the Epistemic Network toolkit. https://github.com/heidihelena/epinet. Zenodo. doi:10.5281/zenodo.20681072.
11. NTOG. Nordic Nodule Pathway Sandbox v3. https://ntog.org/nordic-nodule-pathway-sandbox-v3.html.

*(Sources retrieved via PubMed; please verify each DOI and complete author lists/volume/pages at submission.)*
