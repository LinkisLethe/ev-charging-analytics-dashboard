required_files <- c(
  "01_data_inspection.Rmd",
  "02_data_preprocessing.Rmd",
  "03_dashboard.Rmd",
  file.path("R", paste0("task", 1:4, "_module.R")),
  file.path("dataset", "data_raw", c(
    "charging_station.csv",
    "charging_station_ml.csv",
    "country_summary.csv",
    "world_summary.csv",
    "ev_models.csv"
  )),
  file.path("dataset", "data_clean", c(
    "charging_station_clean.csv",
    "charging_stations_ml_clean.csv",
    "cleaned_country_summary.csv",
    "cleaned_world_summary.csv",
    "ev_models_clean.csv"
  ))
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing required files: ", paste(missing_files, collapse = ", "))
}

for (path in list.files("R", pattern = "[.]R$", full.names = TRUE)) {
  parse(file = path)
}

expected_columns <- list(
  charging_station.csv = c("id", "latitude", "longitude", "ports", "power_kw"),
  charging_station_ml.csv = c("city", "station_count", "fast_station_share"),
  country_summary.csv = c("country_code"),
  world_summary.csv = c("country_code"),
  ev_models.csv = c("make", "model")
)

for (name in names(expected_columns)) {
  path <- file.path("dataset", "data_raw", name)
  columns <- names(read.csv(path, nrows = 1, check.names = FALSE))
  missing_columns <- setdiff(expected_columns[[name]], columns)
  if (length(missing_columns) > 0) {
    stop(name, " is missing columns: ", paste(missing_columns, collapse = ", "))
  }
}

message("Project structure, R modules, and raw CSV schemas are valid.")
