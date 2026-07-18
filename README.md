# EV Charging Analytics Dashboard

[![R](https://img.shields.io/badge/R-project-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org/)
[![Validation](https://img.shields.io/github/actions/workflow/status/LinkisLethe/ev-charging-analytics-dashboard/validate.yml?branch=main&style=flat-square&label=validation)](https://github.com/LinkisLethe/ev-charging-analytics-dashboard/actions/workflows/validate.yml)
[![License](https://img.shields.io/badge/code%20license-MIT-2ea44f?style=flat-square)](LICENSE)

[中文说明](README.zh-CN.md)

An R Markdown and Flexdashboard project for exploring EV charging infrastructure
in Europe and the Americas. It combines interactive maps and charts with city
inequality analysis, PCA and nine-cluster K-means segmentation, country-level
comparisons, and EV model trends.

## What is included

- `01_data_inspection.Rmd` audits five raw CSV files without modifying them.
- `02_data_preprocessing.Rmd` validates coordinates, removes duplicates,
  normalizes fields, imputes missing port counts, and writes the cleaned data.
- `03_dashboard.Rmd` renders the interactive dashboard; `R/` contains the four
  analysis modules used by it.
- `dataset/` contains the raw and cleaned data. The raw source covers 242,417
  charging sites, 121 countries, and 128 EV models.

Generated HTML is not committed because the self-contained dashboard is about
54 MiB. Render it locally from the source.

## Run locally

Install R and, optionally, RStudio. From the repository root, install the
required packages once:

```r
install.packages(c(
  "rmarkdown", "flexdashboard", "knitr", "DT", "rpivotTable",
  "ggplot2", "plotly", "dplyr", "openintro", "highcharter", "ggvis",
  "leaflet", "leafgl", "sf", "readr", "ineq", "tidyverse",
  "viridis", "shiny"
))
```

Then render the preprocessing notebook and dashboard in order:

```powershell
Rscript -e "rmarkdown::render('02_data_preprocessing.Rmd')"
Rscript -e "rmarkdown::render('03_dashboard.Rmd')"
```

The dashboard is written to `03_dashboard.html`. `01_data_inspection.Rmd` is
optional and can be rendered separately when reviewing data quality.

## Data and licensing

The raw files come from Tarek Masry's
[EV Infra Dataset](https://www.kaggle.com/datasets/tarekmasryo/global-ev-charging-stations).
The source and its derivatives in `dataset/` and `output/` use `CC BY 4.0`;
see [DATA_LICENSE.md](DATA_LICENSE.md). Source code and documentation use the
[MIT License](LICENSE).

The repository does not retain the exact intermediate edit history for two
course-period summary CSV files. The committed cleaned files are included so
the dashboard can still be reproduced from the reviewed snapshot.
