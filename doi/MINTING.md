# Minting per-tool DOIs on Zenodo — checklist

**Decisions locked:** per-tool DOI · license **CC-BY-NC-4.0** · 8 tools.
DOIs are external identifiers — they are created on YOUR Zenodo account. This repo only holds the prepared metadata.

## One-time setup
1. Sign in at https://zenodo.org with ORCID (0000-0001-5923-5865) so records auto-link to your ORCID.

## For EACH tool (repeat 8×)
1. Zenodo → **New upload**.
2. Upload the tool's single HTML file (and any JS/CSS it needs — e.g. /js/mdt-i18n.js for the MDT forms).
3. Open the matching `doi/<slug>.zenodo.json` and copy each field into the Zenodo form (title, description, creators, license = Creative Commons Attribution-NonCommercial 4.0, version, keywords, related identifiers).
4. **Publish** → Zenodo mints a **version DOI** and a **concept DOI** (cite the concept DOI for 'always latest').
5. Paste the concept DOI back into the tool page (see snippet below).

## Tools & versions

- **NTOG Lung Cancer MDT Structured Form v3.1** — `mdt-structured-v3_1.html` — metadata: `doi/mdt-structured-v3_1.zenodo.json` — DOI: ______________
- **NTOG Lung Cancer MDT — Structured (mini) v1.0** — `mdt-structured-mini.html` — metadata: `doi/mdt-structured-mini.zenodo.json` — DOI: ______________
- **Understanding Lung Cancer Screening Risk (NTOG) v1.0** — `screening-risk-explained.html` — metadata: `doi/screening-risk-explained.zenodo.json` — DOI: ______________
- **NTOG Experimental Lung Screening and Nodule Risk Hub v3.0** — `ntog_lungrisk_static_tools_v3.html` — metadata: `doi/ntog_lungrisk_static_tools_v3.zenodo.json` — DOI: ______________
- **NTOG Treatment Value Discussion Compass v2.0** — `decision-tool-v2.html` — metadata: `doi/decision-tool-v2.zenodo.json` — DOI: ______________
- **NTOG Structured Treatment Value Profile v1.0** — `decision-tool-structured.html` — metadata: `doi/decision-tool-structured.zenodo.json` — DOI: ______________
- **NTOG Federated Dataset & Visualisation Builder v1.0** — `federated-dataset-builder.html` — metadata: `doi/federated-dataset-builder.zenodo.json` — DOI: ______________
- **NTOG Study Design & Simulation Builder v0.9** — `study-builder.html` — metadata: `doi/study-builder.zenodo.json` — DOI: ______________

## After minting: add DOI to each page
Replace the placeholder in the tool's JSON-LD (already has `license` + `version`) by adding:
```json
"identifier": "https://doi.org/10.5281/zenodo.XXXXXXX",
"sameAs": "https://doi.org/10.5281/zenodo.XXXXXXX"
```
and add a visible citation line, e.g.:
```html
<p class="text-muted"><strong>Cite:</strong> Andersén H. <em>NTOG Lung Cancer MDT Structured Form</em>. NTOG; 2026. doi:10.5281/zenodo.XXXXXXX. Licensed CC-BY-NC-4.0.</p>
```
Tell me the DOIs and I will insert the `identifier` + visible citation block into all pages in one pass.
