# NLCS 2027 — Abstract submission & digital abstract book

This folder contains the abstract workflow for the 16th Nordic Lung Cancer Symposium.

## The pipeline

```
Author → online submission form → CSV / JSON export → Abstract Book Builder → digital abstract book
         (Google / MS Forms, etc.)                     (abstract-book-builder.html)   (HTML + print/PDF)
```

The NTOG site is static (GitHub Pages, no backend), so submission itself is handled by an
external form provider. The **Abstract Book Builder** (`abstract-book-builder.html`) then
turns the form's export into a browsable, searchable, printable abstract book — entirely in
the browser, with no upload of submitted data.

## Setting up the submission form

Create the form in any provider that can export a spreadsheet (Google Forms, Microsoft Forms,
Fillout, etc.). Use **one column per field** below. The builder auto-matches these column names
(and common variants), so matching them keeps the workflow zero-config.

| Column              | Required | Notes |
|---------------------|----------|-------|
| `number`            | no       | Leave blank — the builder can renumber sequentially. |
| `category`          | yes*     | Scientific theme / track. Used to group the book. |
| `type`              | yes*     | `oral` or `poster` (presentation preference). |
| `title`             | **yes**  | Abstract title. |
| `authors`           | yes*     | Semicolon-separated, e.g. `Andersén H; Saghir Z`. |
| `affiliations`      | yes*     | Semicolon-separated, e.g. `1. Dept, Hospital, City, Country; 2. …`. |
| `presenting_author` | yes*     | Name as it appears in `authors`; rendered bold + underlined. |
| `keywords`          | no       | Semicolon-separated. |
| `background`        | yes*     | Structured abstract section. |
| `methods`           | yes*     | Structured abstract section. |
| `results`           | yes*     | Structured abstract section. |
| `conclusions`       | yes*     | Structured abstract section. |
| `body`              | no       | Use instead of the four structured sections if you prefer free text. |
| `coi`               | no       | Conflicts of interest. |
| `funding`           | no       | Funding statement. |
| `poster_file`       | no       | Path or URL to the poster PDF/image, e.g. `files/p12.pdf`. E-poster gallery only. |
| `poster_thumb`      | no       | Path or URL to a thumbnail image for the gallery card. |
| `publish_consent`   | no       | `yes` if the presenting author agreed to the poster being public. Gates the gallery export. |

\* Not technically required by the tool (only `title` is), but recommended for a complete book.

Get a ready-made header row by opening the builder and clicking **Download CSV template**.

## Building the book

1. Open `abstract-book-builder.html` (locally or at `ntog.org/ntog2027/abstract-book-builder.html`).
2. Export submissions from the form as CSV (or JSON) and drop the file onto the tool — or paste it.
3. Check the **column mapping** (auto-matched) and the **book details** (pre-filled for NLCS 2027).
4. Click **Build abstract book**.
5. Use search / category / type filters and sorting to review.
6. Output:
   - **Print / Save as PDF** — the print-ready abstract book.
   - **Export standalone book (.html)** — a single self-contained file you can host at
     e.g. `ntog.org/ntog2027/abstract-book/` for attendees.
   - **Save project (.json)** — reload later to continue editing.

## Building the e-poster gallery

The same data also exports a small public **e-poster gallery**: a searchable index plus one
landing page per abstract, the page a QR code on a printed poster can point at.

1. Build the book as above, then use the toolbar filters to pick what should be public
   (e.g. type = poster).
2. Set **Gallery base URL** in *Book details*. It fills the `canonical` and `og:url` tags.
3. Click **Export e-poster gallery (.zip)**.
4. Unzip into a served folder, e.g. `ntog2027/posters/`, so the gallery is at
   `ntog.org/ntog2027/posters/`.
5. Upload the poster PDFs and thumbnails yourself, to the paths given in `poster_file` /
   `poster_thumb`. They are **not** in the ZIP.

The ZIP contains `index.html` (search + category/type filters), `p-<number>-<slug>.html` per
abstract (abstract, poster viewer, download link, citation line, prev/next), `gallery.css` and
a `README.txt`.

**Consent gate.** If a `publish_consent` column is mapped, only rows whose value reads as yes
(`yes`, `y`, `true`, `1`, `x`, `ok`, `ja`, `kyllä`) are exported, and the export reports how many
were left out. With no such column mapped, everything in the current view is exported, so map
the column, or filter by hand, before publishing anyone's poster.

## Test data

`.testdata/abstract-testdata.csv` is a synthetic 18-row export shaped like a real form download:
form-style column headers, quoted fields, Nordic diacritics, long author lists, two rows
without publish consent, three without a poster file, two groups submitting the same title,
and one title long enough to be truncated in the filename. Every author, institution and
funder in it is an invented placeholder, and every number is made up. Nothing in the file
is a real submission.

Use it to check the builder after a change: drop it on the dropzone, build, then export both
the book and the gallery. The expected result is 18 abstracts in, 16 landing pages out, 2 held
back for missing consent.

It sits in a dot-prefixed folder on purpose. GitHub Pages skips dotfiles and dot-folders at any
depth, so the fixture stays out of the published site: `ntog.org/ntog2027/.testdata/…` returns
404, the same way `/.github/…` does. Keep it there, and keep any future fixture there too.

## Notes

- The builder is an **organiser tool** (`noindex`). It is not a clinical or medical device.
- No submitted abstract data is uploaded anywhere — everything stays in the browser.
- The abstract book inherits the NTOG 2027 red brand.
- The exported gallery pages are **public and indexable** (unlike the builder itself). Deploy them
  only once the abstracts are final and consent is recorded.
- The gallery links the site fonts at `/fonts/…`; hosted anywhere other than ntog.org it falls back
  to system fonts.
