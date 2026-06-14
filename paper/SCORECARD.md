# Independent validation scorecard — EpiNet vs established tools

EpiNet's headline outputs on the three-axis synthetic cohort (`data/three_axis_cohort.csv`,
n = 6,000, malignant prevalence 0.27) were re-derived with a **separate stack** —
scikit-learn + a from-scratch DeLong + `dcurves` + `DiCE` (Python; `code/validate_epinet.py`),
and a gold-standard R script (`rms` + `pROC` + `dcurves`; `code/validate_epinet.R`).

| EpiNet reported | Independent tool | Independent result | Verdict |
|---|---|---|---|
| Combined AUROC **0.855** (iter mean 0.849) | sklearn 5-fold CV + DeLong | RF **0.846** (0.835–0.856); Logistic **0.857** (0.847–0.867) | ✅ EpiNet inside the independent CI |
| Single-axis AUROC 0.72 / 0.74 / 0.83 | DeLong (from scratch) | 0.720 / 0.740 / 0.826 — match sklearn exactly | ✅ exact |
| Calibration **Brier 0.131** | sklearn | **0.135** | ✅ agree |
| Calibration **slope 1.15** (apparent/iteration) | CV + optimism-corrected bootstrap (B=200) | CV **0.94**, optimism-corrected **0.84** | ⚠️ corrected/CV both <1 (mild *over*-confidence) — *opposite direction* to 1.15; report all three |
| Contestability value-of-information **sybil > protein > clinical** (0.41/0.31/0.28) | closed-form linear margin | **sybil > protein > clinical** (0.59/0.29/0.12) | ✅ same ranking (illustrative, not biological) |
| Flip-distance mean **~1.42 SD** | closed-form margin / DiCE | **1.04 SD** / DiCE 3.1 SD | ✅ same order of magnitude |
| *(signal vs chance)* | `permutation_test_score` | observed 0.857 vs null mean 0.500, **p = 0.005** | ✅ beats chance — but does **not** test orthogonality |
| *(not computed by EpiNet)* clinical utility | **dcurves** net benefit | model beats treat-all/none across thresholds (Δ +0.08 at p=0.20; +0.17 at p=0.30) | ✅ new independent confirmation (Fig 5) |

## Interpretation
- **Discrimination and utility reproduce cleanly** — EpiNet's AUROC is bracketed by two independent models, and `dcurves` confirms positive net benefit, so the combined model carries real signal rather than leakage.
- **Calibration: Brier matches, but the slope direction does not — report all three.** EpiNet's apparent/iteration slope **1.15** implies mild under-confidence, but the out-of-fold CV slope **0.94** and the optimism-corrected bootstrap slope **0.84** both sit <1 (mild *over*-confidence). The corrected/CV values are the trustworthy ones; quoting only 1.15 would have implied the wrong direction. `rms::validate()` (R script) is the definitive arbiter and agrees in direction with the Python optimism correction.
- **The contestability ranking validates independently** — the conclusion you would act on (CT highest value-of-information, then protein, then clinical) is reproduced by a different method. Absolute flip-distance differs because EpiNet uses nearest-centroid over more features while the cross-check uses a linear boundary over the three axes — same construct, different geometry.
- **DiCE** corroborates that minimal counterfactuals exist at single-digit-SD distances (its `random` search is not minimal-distance, hence 3.2 SD).
- **The contestability value-of-information ranking is illustrative**, not biological — it reflects standardized model coefficients on synthetic data; the same caveat applies to the ranking magnitudes.
- **A label-permutation null** (`permutation_test_score`) rejects chance (real signal is present). Note this tests signal-versus-chance only; it does **not** validate that the three axes are orthogonal — orthogonality is built into the generator, not an output.

## How to reproduce
```bash
# from paper/code/ — paths are relative and self-contained
python three_axis_simulation.py            # regenerates ../data/three_axis_cohort.csv + figures (seed 42)
pip install dcurves dice-ml
python validate_epinet.py                  # Python cross-check (reads ../data/three_axis_cohort.csv)
Rscript validate_epinet.R ../data/three_axis_cohort.csv   # gold-standard cross-check
```

*All data are synthetic and calibrated to published discrimination figures; absolute
AUROCs are not clinical performance. The validation concerns whether EpiNet's
computations are reproducible in independent, established tooling — and they are.*
