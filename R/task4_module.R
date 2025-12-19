# ============================================
# Task 4 data preparation script
# This script is sourced by 04_dashboard.Rmd
# ============================================

# 1. Load cleaned ev_models dataset ----------------------
clean_data_path <- "dataset/data_clean/ev_models_clean.csv"

if(file.exists(clean_data_path)){
  ev_models <- readr::read_csv(
    clean_data_path,
    locale = readr::locale(encoding = "UTF-8"),
    show_col_types = FALSE
  )
} else {
  warning("Task 4 Data Not Found! Please run 02_task4_preprocessing.Rmd.")
  ev_models <- NULL 
}

# 2. Define Visualization Theme (Dark Mode) -------------------
task4_theme <- list(
  paper_bgcolor = "#0d1117",
  plot_bgcolor  = "#0d1117",
  font = list(color = "white", family = "Calibri"),
  xaxis = list(
    gridcolor = "#30363d", 
    linecolor = "white", 
    tickfont = list(color = "white"), 
    titlefont = list(color = "white")
  ),
  yaxis = list(
    gridcolor = "#30363d", 
    linecolor = "white", 
    tickfont = list(color = "white"), 
    titlefont = list(color = "white")
  ),
  legend = list(font = list(color = "white"))
)
