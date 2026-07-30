# NTOG Nordic Lung Cancer Trends

An interactive R Shiny application for exploring lung-cancer incidence and
mortality trends in Denmark, Finland, Iceland, Norway and Sweden.

The app is designed for researchers who need to:

- compare annual national trajectories by sex;
- distinguish crude and age-standardised rate definitions;
- retain source, version, cancer definition and retrieval metadata;
- export 16:9 PNG or vector PDF figures for presentations;
- download the exact selected observations and a matching methods citation.

Mortality is the default cross-country view. NORDCAN reports that Swedish
lung-cancer incidence is not directly comparable with incidence in the other
Nordic countries and recommends mortality for comparisons.

## Data

The frozen snapshot contains 1,298 annual observations for lung cancer
(ICD-10 C33-C34) from 1960 through 2024, where available:

- NORDCAN version 9.6 (30 June 2026)
- accessed 30 July 2026
- five national populations
- male and female series
- incidence and mortality
- crude, World, European 1976, European 2013 and Nordic 2000 rates

The snapshot keeps the app reproducible and available if the upstream service
is temporarily unavailable. Refresh it deliberately after reviewing upstream
version and schema changes:

```bash
Rscript scripts/refresh_nordcan_data.R
Rscript tests/testthat.R
```

## Run locally

From this directory:

```bash
R -e 'shiny::runApp(".", port = 3838, host = "127.0.0.1")'
```

Then open <http://127.0.0.1:3838>.

Required R packages are `shiny`, `bslib`, `dplyr`, `ggplot2`, `readr`,
`scales`, `jsonlite`, and `testthat` for tests.

## Deploy on Render

Create a new **Web Service** from `heidihelena/NTOG`:

| Setting | Value |
|---|---|
| Runtime | Docker |
| Root Directory | `trends` |
| Dockerfile Path | `./Dockerfile` |
| Health Check Path | `/` |

No build or start command is required because the Dockerfile supplies both. The
container reads Render's `PORT` environment variable and binds to `0.0.0.0`.
Once the service is live, add `trends.ntog.org` as its custom domain. Render
will display the exact canonical hostname to use at the DNS provider.

At Cloudflare, create this record only after Render shows the service target:

| Type | Name | Target | Proxy |
|---|---|---|---|
| CNAME | `trends` | exact Render hostname, e.g. `ntog-trends.onrender.com` | DNS only |

Do not enter the example target until the Render service with that hostname
actually exists. Add the custom domain in Render, wait for verification and
certificate issuance, and then test `https://trends.ntog.org/`.

The repository's `render.yaml` provides the same settings as a Render
Blueprint, including the `trends` monorepo root and Frankfurt region.

## Licensing and attribution

Application code is licensed under Apache-2.0 under the NTOG repository
licence. NORDCAN data retain their source terms and attribution. Generated
figures and methods files include the recommended NORDCAN reference and access
date.
