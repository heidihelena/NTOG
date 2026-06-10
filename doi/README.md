# DOI & citation metadata for NTOG tools

This folder is the **citation-provenance** record for NTOG's tools. It is kept under version
control on purpose: the metadata here is the canonical source from which each tool's DOI is
minted, so anyone can see exactly how a tool is described, versioned, licensed and attributed —
and re-mint a new version later without starting from scratch.

## What's here
- **`<tool>.zenodo.json`** — ready-to-use Zenodo deposition metadata for each tool (title,
  version, description, creator + ORCID, license, keywords, related identifiers, disclosure note).
- **`MINTING.md`** — step-by-step checklist for minting the per-tool DOIs on Zenodo.
- (repo root) **`CITATION.cff`** — collection-level citation file (GitHub "Cite this repository").

## Policy
- **Route:** per-tool DOIs (each single-file tool = its own Zenodo record).
- **License:** Creative Commons Attribution–NonCommercial 4.0 (CC-BY-NC-4.0).
- **Author:** Heidi Andersén (ORCID 0000-0001-5923-5865), Tampere University; University of Turku.
- **Disclosure:** the author is clinical lead of the Finnish lung cancer registry and founder of
  Vahtian (the independent engine behind the tools). Tools are educational decision-support, not
  medical devices. Affiliations are for identification only and imply no endorsement.

## Updating a tool version
1. Edit the tool, bump its version.
2. Update `version` (and description if needed) in the matching `<tool>.zenodo.json`.
3. On Zenodo, use **New version** of the existing record → publish → a new version DOI is minted
   under the same concept DOI.
4. Add the new version DOI to the tool page's JSON-LD `identifier`/`sameAs`.
