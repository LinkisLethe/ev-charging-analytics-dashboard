# 电动汽车充电设施分析仪表板

[![R](https://img.shields.io/badge/R-project-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org/)
[![Validation](https://img.shields.io/github/actions/workflow/status/LinkisLethe/ev-charging-analytics-dashboard/validate.yml?branch=main&style=flat-square&label=validation)](https://github.com/LinkisLethe/ev-charging-analytics-dashboard/actions/workflows/validate.yml)
[![License](https://img.shields.io/badge/code%20license-MIT-2ea44f?style=flat-square)](LICENSE)

[English](README.md)

这是一个基于 R Markdown 和 Flexdashboard 的电动汽车充电设施分析项目，范围为欧洲与美洲。项目通过交互式地图和图表展示设施分布，并包含城市不平等分析、PCA 与九类 K-means 聚类、国家级比较及车型趋势。

## 仓库内容

- `01_data_inspection.Rmd` 只读取并审查五份原始 CSV，不修改数据。
- `02_data_preprocessing.Rmd` 检查坐标、去重、统一字段、填补缺失端口数，并生成清洗数据。
- `03_dashboard.Rmd` 用于渲染交互式仪表板，`R/` 包含四个分析模块。
- `dataset/` 保存原始数据与清洗结果。原始数据包含 242,417 个充电站点、121 个国家和 128 款电动汽车。

自包含的 HTML 仪表板约为 54 MiB，因此不纳入仓库，可从源码在本地重新生成。

## 本地运行

安装 R；如需图形界面，可另外安装 RStudio。在仓库根目录先安装依赖：

```r
install.packages(c(
  "rmarkdown", "flexdashboard", "knitr", "DT", "rpivotTable",
  "ggplot2", "plotly", "dplyr", "openintro", "highcharter", "ggvis",
  "leaflet", "leafgl", "sf", "readr", "ineq", "tidyverse",
  "viridis", "shiny"
))
```

然后按顺序生成清洗数据和仪表板：

```powershell
Rscript -e "rmarkdown::render('02_data_preprocessing.Rmd')"
Rscript -e "rmarkdown::render('03_dashboard.Rmd')"
```

生成结果为 `03_dashboard.html`。如需检查原始数据质量，可单独渲染可选的 `01_data_inspection.Rmd`。

## 数据与许可证

原始文件来自 Tarek Masry 的
[EV Infra Dataset](https://www.kaggle.com/datasets/tarekmasryo/global-ev-charging-stations)。
`dataset/` 与 `output/` 中的源数据和衍生数据使用 `CC BY 4.0`，详见
[DATA_LICENSE.md](DATA_LICENSE.md)；源代码和文档使用 [MIT License](LICENSE)。

两份课程期间调整过的汇总 CSV 没有保留完整的中间修改记录。仓库保留已审查的清洗结果，因此仍可从当前快照生成仪表板。
