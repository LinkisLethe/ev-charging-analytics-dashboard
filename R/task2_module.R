# ==============================================================================
# task2_data_prep.R
# Visualization functions and theme configuration for Task 2
# Contains: Plot functions + Theme configuration
# This file is PURELY for visualization
# ==============================================================================

# 1. Load Required Packages ----------------------------------------------------
library(tidyverse)
library(plotly)
library(ineq)
library(viridis)

# 2. Visualization Theme Configuration -----------------------------------------
# Core design tokens for global visual consistency
stations_city <- readr::read_csv(
  "dataset/data_clean/charging_stations_ml_clean.csv",
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)
# 2.1 Color System
DASHBOARD_COLORS <- list(
  # Background & Surfaces
  bg_dark      = "#0d1117",  # body background
  bg_card      = "#161b22",  # card, inactive tab
  bg_active    = "#2980b9",  # active element
  # Primary UI Colors
  primary      = "#33ccff",  # main hue, links, highlights
  secondary    = "#ffb347",  # secondary color, second data series
  tertiary     = "#f78166",  # accent color, threshold lines
  # Text & Borders
  text_title   = "#f5f5f5",  # title text
  text_body    = "#cccccc",  # body font
  text_muted   = "#8b949e",  # muted text, labels
  border       = "#2c3e50",  # borders, dividers
  # Chart-specific Palettes
  viridis_pal  = plasma(4, direction = -1),  # development stages
  cluster_pal  = viridis(7)                  # clusters
)

# 2.2 Plotly Global Layout Configuration
PLOTLY_THEME <- list(
  layout = list(
    paper_bgcolor = DASHBOARD_COLORS$bg_dark,
    plot_bgcolor  = DASHBOARD_COLORS$bg_dark,
    font = list(
      color = DASHBOARD_COLORS$text_body,
      family = "Calibri, Segoe UI, Helvetica Neue, Arial, sans-serif",
      size = 14
    ),
    margin = list(l = 70, r = 40, t = 80, b = 70),
    hoverlabel = list(
      bgcolor = DASHBOARD_COLORS$bg_card,
      bordercolor = DASHBOARD_COLORS$border,
      font = list(color = DASHBOARD_COLORS$text_body)
    )
  ),
  axis = list(
    gridcolor = DASHBOARD_COLORS$border,
    zerolinecolor = DASHBOARD_COLORS$border,
    linecolor = DASHBOARD_COLORS$text_muted,
    tickfont = list(size = 12),
    titlefont = list(size = 13)
  ),
  thresholds = list(
    fast_share = 70,    # converted to percentage
    median_power = 50,
    line_style = list(color = DASHBOARD_COLORS$tertiary, width = 2, dash = "dash")
  )
)

# 2.3 Theme Application Function (Core Utility)
apply_dashboard_theme <- function(plotly_obj, title = NULL, 
                                  xaxis_title = NULL, yaxis_title = NULL,
                                  legend_title = NULL) {
  
  p <- plotly_obj %>%
    layout(
      paper_bgcolor = PLOTLY_THEME$layout$paper_bgcolor,
      plot_bgcolor  = PLOTLY_THEME$layout$plot_bgcolor,
      font = PLOTLY_THEME$layout$font,
      margin = PLOTLY_THEME$layout$margin,
      hoverlabel = PLOTLY_THEME$layout$hoverlabel,
      title = if (!is.null(title)) list(
        text = title,
        x = 0.05,  # left-aligned to match CSS style
        font = list(size = 18, color = DASHBOARD_COLORS$text_title)
      )
    ) %>%
    layout(
      xaxis = c(
        list(title = xaxis_title),
        PLOTLY_THEME$axis
      ),
      yaxis = c(
        list(title = yaxis_title),
        PLOTLY_THEME$axis
      )
    )
  
  # Configure legend if title is provided
  if (!is.null(legend_title)) {
    p <- p %>% layout(
      legend = list(
        title = list(text = paste0("<b>", legend_title, "</b>"), 
                     font = list(color = DASHBOARD_COLORS$text_title)),
        bgcolor = paste0(substr(DASHBOARD_COLORS$bg_card, 1, 7), "CC"),
        bordercolor = DASHBOARD_COLORS$border,
        font = list(color = DASHBOARD_COLORS$text_body)
      )
    )
  }
  
  return(p)
}

# 3. Plot Functions ------------------------------------------------------------

# 3.1 Lorenz Curve Plot
create_lorenz_plot <- function(data, gini_value = NULL) {
  
  lc <- Lc(data$station_count)
  lorenz_df <- data.frame(p = lc$p, L = lc$L)
  gini <- if (is.null(gini_value)) Gini(data$station_count) else gini_value
  
  plot_ly(lorenz_df) %>%
    add_trace(x = c(0,1), y = c(0,1), type = 'scatter', mode = 'lines',
              line = list(color = DASHBOARD_COLORS$text_muted, dash = 'dash', width = 2),
              name = 'Perfect Equality', showlegend = FALSE) %>%
    add_trace(x = ~p, y = ~L, type = 'scatter', mode = 'lines',
              fill = 'tozeroy', fillcolor = paste0(substr(DASHBOARD_COLORS$primary, 1, 7), "4D"),
              line = list(color = DASHBOARD_COLORS$primary, width = 3),
              name = 'Actual Distribution',
              hovertemplate = 'Cities (cumulative): %{x:.1%}<br>Stations (cumulative): %{y:.1%}<extra></extra>') %>%
    apply_dashboard_theme(
      title = paste("Lorenz Curve of Charging Station Distribution<br><span style='font-size:14px; color:", 
                    DASHBOARD_COLORS$text_muted, "'>Gini Coefficient = ", round(gini, 3), "</span>"),
      xaxis_title = "Cumulative Share of Cities (ascending by station count)",
      yaxis_title = "Cumulative Share of Stations"
    )
}

# 3.2 Inequality Pie Chart (Top 10% Cities Share)
create_inequality_pie <- function(data, top_pct = 0.1) {
  
  top_cities <- data %>% 
    arrange(desc(station_count)) %>% 
    slice_head(prop = top_pct)
  
  top_share <- sum(top_cities$station_count) / sum(data$station_count)
  
  plot_ly() %>%
    add_pie(labels = c(paste0('Top ', top_pct*100, '% Cities'), 'Remaining Cities'),
            values = c(top_share, 1 - top_share),
            marker = list(colors = c(DASHBOARD_COLORS$secondary, DASHBOARD_COLORS$bg_card)),
            hole = 0.65,
            textinfo = 'label+percent',
            hovertemplate = "%{label}<br>Share: %{percent}<br>Stations: %{value:.0f}<extra></extra>") %>%
    layout(annotations = list(
      text = paste0(round(top_share*100, 1), "%"),
      font = list(size = 28, color = DASHBOARD_COLORS$text_title),
      showarrow = FALSE
    )) %>%
    apply_dashboard_theme(
      title = paste("Charging Station Concentration<br><span style='font-size:14px; color:", 
                    DASHBOARD_COLORS$text_muted, "'>Top ", top_pct*100, "% cities own ", 
                    round(top_share*100, 1), "% of all stations</span>")
    )
}

# 3.3 Fast-Charging Infrastructure Scatter Plot
create_fast_scatter <- function(data, size_by_log = TRUE) {
  
  # Dynamic size calculation
  size_var <- if (size_by_log) ~log10(station_count + 1) else ~station_count
  
  plot_ly(data, x = ~fast_station_share * 100, y = ~median_power_kw) %>%
    add_markers(color = ~dev_stage, colors = DASHBOARD_COLORS$viridis_pal,
                size = size_var, sizes = c(5, 25),
                marker = list(opacity = 0.8, sizemode = 'diameter',
                              line = list(width = 0.5, color = 'white')),
                hoverinfo = 'text',
                text = ~paste('<b>', city, '</b> (', country_code, ')<br>',
                              'Stations: ', station_count, '<br>',
                              'Fast Share: ', round(fast_station_share*100, 1), '%<br>',
                              'Median Power: ', round(median_power_kw, 1), ' kW<br>',
                              'Stage: ', dev_stage)) %>%
    # Threshold lines
    add_segments(x = PLOTLY_THEME$thresholds$fast_share, xend = PLOTLY_THEME$thresholds$fast_share,
                 y = 0, yend = 400, line = PLOTLY_THEME$thresholds$line_style,
                 showlegend = FALSE) %>%
    add_segments(x = 0, xend = 100,
                 y = PLOTLY_THEME$thresholds$median_power, 
                 yend = PLOTLY_THEME$thresholds$median_power,
                 line = PLOTLY_THEME$thresholds$line_style, showlegend = FALSE) %>%
    apply_dashboard_theme(
      title = "Fast-Charging Infrastructure Analysis<br><span style='font-size:14px; color:#8b949e'>Fast-Charging Share vs. Median Power</span>",
      xaxis_title = "Fast-Charging Station Share (%)", 
      yaxis_title = "Median Charging Power (kW)",
      legend_title = "Development Stage"
    ) %>%
    layout(xaxis = list(range = c(-5, 105)),
           yaxis = list(range = c(0, 400)))
}

# 3.4 Cluster PCA Visualization
create_cluster_pca <- function(data, n_clusters = 9) {
  
  # 1. Extract and preprocess features
  features <- data %>%
    select(station_count, fast_station_share, median_power_kw) %>%
    mutate(log_stations = log10(station_count + 1)) %>%
    select(-station_count)
  
  # 2. Check and handle missing values
  if(any(is.na(features))) {
    warning("Found NA values in features. Removing rows with NA.")
    complete_cases <- complete.cases(features)
    features <- features[complete_cases, ]
    data <- data[complete_cases, ]
  }
  
  # 3. Standardize features (required for clustering)
  scaled_features <- scale(features, center = TRUE, scale = TRUE)
  
  # 4. Perform K-means clustering
  set.seed(42)  # Ensure reproducible results
  kmeans_result <- kmeans(scaled_features, centers = n_clusters, nstart = 25)
  
  # 5. PCA visualization (using same standardized data as clustering)
  pca <- prcomp(scaled_features)
  var_exp <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)
  
  # 6. Create result data frame
  scores <- as.data.frame(pca$x[, 1:2])
  colnames(scores) <- c("PC1", "PC2")
  scores$Cluster <- as.factor(kmeans_result$cluster)
  scores$City <- data$city
  scores$Country <- data$country_code
  
  # 7. Create cluster plot
  plot_ly(scores, x = ~PC1, y = ~PC2) %>%
    add_markers(color = ~Cluster, colors = DASHBOARD_COLORS$cluster_pal,
                marker = list(size = 10, opacity = 0.7,
                              line = list(width = 1, color = 'white')),
                hoverinfo = 'text',
                text = ~paste('<b>', City, '</b><br>',
                              'Country: ', Country, '<br>',
                              'Cluster: ', Cluster, '<br>',
                              'PC1: ', round(PC1, 2), '<br>',
                              'PC2: ', round(PC2, 2))) %>%
    apply_dashboard_theme(
      title = "City Charging Infrastructure Clusters",
      xaxis_title = paste("Principal Component 1 (", var_exp[1], "% variance)"),
      yaxis_title = paste("Principal Component 2 (", var_exp[2], "% variance)"),
      legend_title = "Cluster"
    )
}

# 4. Dashboard Data Preparation Function ---------------------------------------
# This function creates dashboard data from already cleaned data
prepare_dashboard_data <- function(
    clean_data_path = "dataset/data_clean/charging_stations_ml_clean.csv",
    dashboard_file_path = "output/dashboard_city_data.csv",
    metrics_file_path = "output/dashboard_metrics.rds",
    sample_target = 2000
) {
  
  # Read cleaned data
  clean_data <- read_csv(clean_data_path, show_col_types = FALSE)
  
  # Create sampled dataset for dashboard
  # Separate fast-dominant cities
  fast_dominant <- clean_data %>% filter(is_fast_dominant)
  non_fast <- clean_data %>% filter(!is_fast_dominant)
  
  # Stratified sampling
  set.seed(42)
  remaining_slots <- max(0, sample_target - nrow(fast_dominant))
  
  if (remaining_slots > 0 && nrow(non_fast) > 0) {
    stage_counts <- non_fast %>% 
      count(dev_stage, name = "total")
    
    stage_samples <- stage_counts %>%
      mutate(
        proportion = total / sum(total),
        target = pmax(10, round(proportion * remaining_slots))
      )
    
    sampled_list <- list()
    
    for (i in 1:nrow(stage_samples)) {
      stage <- stage_samples$dev_stage[i]
      target_n <- stage_samples$target[i]
      
      stage_data <- non_fast %>% filter(dev_stage == stage)
      sample_n <- min(target_n, nrow(stage_data))
      
      if (sample_n > 0) {
        sampled_list[[stage]] <- stage_data %>% sample_n(sample_n)
      }
    }
    
    sampled_non_fast <- bind_rows(sampled_list)
  } else {
    sampled_non_fast <- tibble()
  }
  
  # Combine final dataset
  dashboard_data <- bind_rows(fast_dominant, sampled_non_fast)
  
  # Calculate metrics
  metrics <- list(
    gini_coefficient = Gini(dashboard_data$station_count),
    total_original = nrow(clean_data),
    total_sampled = nrow(dashboard_data),
    fast_dominant_count = nrow(fast_dominant),
    sampling_rate = round(nrow(dashboard_data) / nrow(clean_data) * 100, 1),
    avg_stations_per_city = round(mean(dashboard_data$station_count, na.rm = TRUE), 1),
    created_at = Sys.time()
  )
  
  # Save dashboard data and metrics
  if (!dir.exists("output")) dir.create("output", recursive = TRUE)
  write_csv(dashboard_data, dashboard_file_path)
  saveRDS(metrics, metrics_file_path)
  
  cat("SUCCESS: Dashboard data prepared\n")
  cat(sprintf("  Processed cities: %d\n", nrow(clean_data)))
  cat(sprintf("  Sampled cities: %d\n", nrow(dashboard_data)))
  cat(sprintf("  Gini coefficient: %.3f\n", metrics$gini_coefficient))
  
  # Return both the processed clean data and dashboard data
  return(list(
    clean_data = clean_data,
    dashboard_data = dashboard_data,
    metrics = metrics
  ))
}

# 5. Dashboard Data Initialization Function (Simple) ---------------------------------------
# This function loads or creates dashboard data when sourced
init_dashboard <- function() {
  # Default file paths
  dashboard_file <- "output/dashboard_city_data.csv"
  metrics_file <- "output/dashboard_metrics.rds"
  clean_file <- "dataset/data_clean/charging_stations_ml_clean.csv"
  
  # Check if dashboard files exist
  if (file.exists(dashboard_file) && file.exists(metrics_file)) {
    cat("Loading existing dashboard data...\n")
    dashboard_data <<- read_csv(dashboard_file, show_col_types = FALSE)
    dashboard_metrics <<- readRDS(metrics_file)
    cat(sprintf("  Loaded %d cities\n", nrow(dashboard_data)))
  } else {
    cat("Dashboard files not found. Creating new data...\n")
    
    # Ensure output directory exists
    if (!dir.exists("output")) {
      dir.create("output", recursive = TRUE)
    }
    
    # Create dashboard data
    result <- prepare_dashboard_data(
      clean_data_path = clean_file,
      dashboard_file_path = dashboard_file,
      metrics_file_path = metrics_file,
      sample_target = 2000
    )
    
    # Assign to global environment for dashboard access
    dashboard_data <<- result$dashboard_data
    dashboard_metrics <<- result$metrics
    cat(sprintf("  Created dashboard data with %d cities\n", nrow(dashboard_data)))
  }
}

# 6. Auto-initialize when sourced in dashboard context ------------------------------------
# This runs when the script is sourced (not when run via command line)
if (sys.nframe() > 0) {
  # Check if we're likely in a dashboard context
  # by looking for common dashboard environments
  is_dashboard_context <- exists("shinymode", mode = "function") || 
    exists("renderPlotly", mode = "function") ||
    interactive()
  
  if (is_dashboard_context) {
    # Initialize dashboard data automatically
    init_dashboard()
  }
}
# ==============================================================================
# END OF FILE
# ==============================================================================