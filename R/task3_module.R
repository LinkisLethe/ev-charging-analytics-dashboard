# ============================================
# Task 3 data preparation script
# This script is sourced by EV_dashboard.Rmd
# ============================================

world_summary <- readr::read_csv(
  "dataset/data_clean/cleaned_world_summary.csv",
  locale = readr::locale(encoding = "UTF-8")
)

country_summary <- readr::read_csv(
  "dataset/data_clean/cleaned_country_summary.csv",
  locale = readr::locale(encoding = "UTF-8")
)