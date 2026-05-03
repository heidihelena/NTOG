# NTOG LungRisk Educational and Research Hub

Browser-based educational research software for comparing published lung cancer screening criteria, person-level lung cancer risk models, pulmonary nodule malignancy models, growth calculations, guideline-readiness lanes, and experimental NTOG research scores.

## Status

This tool is an educational and research prototype.

It is not:

- a medical device
- a diagnostic tool
- autonomous clinical decision support
- a screening recommendation engine
- a substitute for national guidelines, local policy, multidisciplinary review, clinical judgment, or patient preference

No clinical action threshold is defined for the experimental NTOG scores.

## Current implementation

The current static HTML implementation is:

`ntog.org/lungrisk.html`

The page runs entirely in the browser. It does not use a backend, cookies, localStorage, or persistent browser storage.

## Included model groups

### Screening and eligibility comparison

- USPSTF-style eligibility display
- NELSON-style eligibility display

These are displayed for comparison only. They are not NTOG recommendations.

### Person-level lung cancer risk models

- PLCOm2012 original
- HUNT Lung Cancer Model, corrected 6-year equation

These estimate person-level future lung cancer risk in ever-smokers.

### Nodule-level malignancy models

- Brock / PanCan full model
- Mayo / Swensen pretest probability
- Herder PET-refined probability
- Volume doubling time, VDT

These estimate or contextualize nodule-level malignancy probability or growth.

### Management framework readiness lanes

The tool checks whether required context and data are present for educational comparison with:

- Fleischner 2017
- BTS 2015
- Lung-RADS v2022
- NELSON volumetric protocol
- ESTI screening management

The tool does not output management recommendations.

## Experimental NTOG research scores

### `ntog_experimental_screening_score`

A non-validated, pre-CT, literature-weighted screening research index.

It uses:

- age component
- tobacco architecture component
- respiratory and fibrosis phenotype component
- environmental and occupational exposure component
- host, family, prior thoracic radiotherapy, and immunosuppression component

It does not use:

- nodule variables
- PET variables
- Brock
- Mayo
- Herder
- VDT

### `ntog_not_validated_risk_score`

A non-validated, post-CT, literature-weighted research index.

It uses available components from:

- person-level model output
- nodule-level model output
- growth or VDT
- smoking architecture
- NTOG emerging-risk modifiers

This score is not a probability. Its weights are draft NTOG v0.3 literature-informed points, not coefficients estimated from a Nordic outcome cohort.

## Data and privacy boundary

The current static page:

- calculates in the browser
- does not send entered data to a server
- does not store entered data
- does not use cookies
- does not use localStorage
- exports JSON only when the user explicitly copies or downloads it

No patient identifiers should be entered.

## Governance-gated fields

The original PLCOm2012 calculation requires race/ethnicity and education variables. In this prototype these fields are governance-gated.

If the governance switch is not enabled, PLCOm2012 is blocked rather than silently imputing values.

## JSON export

The JSON export includes:

- schema version
- calculation session ID
- timestamp
- patient-level input fields
- questionnaire fields
- imaging and nodule fields
- normalized smoking and BMI variables
- model outputs
- warnings
- formula registry
- audit metadata

Exported JSON is intended for review, testing, and research planning. It is not a clinical record.

## Development notes

Recommended next steps before production deployment:

1. Keep validated model outputs separate from experimental NTOG scores.
2. Preserve missing-variable lists. Do not silently impute missing model inputs.
3. Add regression tests for fictional examples.
4. Add schema-versioned JSON import/export tests.
5. Add backward-compatible read support for legacy misspelled keys if older exports exist.
6. Split the monolithic HTML into maintainable files when moving beyond the prototype stage:
   - `tools.html`
   - `css/lungrisk.css`
   - `js/lungrisk/models.js`
   - `js/lungrisk/normalization.js`
   - `js/lungrisk/render.js`
   - `js/lungrisk/export.js`
   - `js/lungrisk/examples.js`

## Suggested repository structure

```text
/
├── tools.html
├── css/
│   └── lungrisk.css
├── js/
│   └── lungrisk/
│       ├── constants.js
│       ├── collect-input.js
│       ├── normalization.js
│       ├── models-person.js
│       ├── models-nodule.js
│       ├── ntog-scores.js
│       ├── readiness.js
│       ├── render.js
│       ├── export.js
│       └── examples.js
├── tests/
│   ├── fictional-example.test.js
│   ├── spelling-regression.test.js
│   └── schema-export.test.js
├── README.md
├── LICENSE
└── NOTICE
```

## Source notes

- PLCOm2012: Tammemagi MC et al. *N Engl J Med*. 2013;368:728-736.
- HUNT Lung Cancer Model: Markaki M et al. *EBioMedicine*. 2018;31:36-46. Corrigendum *EBioMedicine*. 2022;82:104187.
- Brock / PanCan: McWilliams A et al. *N Engl J Med*. 2013;369:910-919.
- Mayo / Swensen: Swensen SJ et al. *Arch Intern Med*. 1997;157:849-855.
- Herder: Herder GJ et al. *Chest*. 2005;128:2490-2496.

## License

Source code: Apache License 2.0.

Educational text: CC BY 4.0.

The NTOG name, logo, visual identity, and event branding are not licensed for reuse except as required for attribution.

