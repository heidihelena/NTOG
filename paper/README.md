# Nordic Nodule Pathway — manuscript, data, code

Working manuscript and reproducible materials for the Nordic Nodule Pathway Sandbox v3
and its EpiNet evaluation. **Draft. Educational / research-planning only — not clinical
decision support. All data are synthetic and calibrated to published discrimination
figures; absolute AUROCs are not real performance.**

## Contents
- `manuscript.md` — working manuscript draft (model–threshold coupling, the grey zone,
  time as a factor, orthogonal information axes; methods, results, discussion, references).
- `SCORECARD.md` — independent validation of EpiNet against established tools.
- `figures/` — Fig 1 discrimination ladder · Fig 2 complementarity Venn · Fig 3 EpiNet
  calibration · Fig 4 EpiNet contestability · Fig 5 decision-curve validation.
- `data/` — `three_axis_cohort.csv` (6,000 nodules × clinical/protein/sybil + outcome),
  `nodule_cohort_scores.csv` (Brock/Mayo/VDT + latent truth), `three_axis_summary.json`.
- `code/` — `three_axis_simulation.py` (seed 42, regenerates the cohort + Figs 1–2),
  `validate_epinet.py` (Python cross-check), `validate_epinet.R` (rms + pROC + dcurves).

## Reproduce
```bash
pip install numpy pandas scikit-learn matplotlib matplotlib-venn dcurves dice-ml
python code/three_axis_simulation.py        # cohort + figures
python code/validate_epinet.py              # independent validation
Rscript code/validate_epinet.R data/three_axis_cohort.csv   # gold-standard cross-check
```
EpiNet itself: https://github.com/heidihelena/epinet · Sandbox: https://ntog.org/nordic-nodule-pathway-sandbox-v3.html
