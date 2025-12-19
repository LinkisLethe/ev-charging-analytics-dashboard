# ============================================
# Task 1 data preparation script
# ============================================

# 1. Load cleaned station-level dataset ----------------------
stations_world <- readr::read_csv(
  "dataset/data_clean/charging_station_clean.csv",
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# 2. Filter stations to Europe + Americas & Classify ---------
stations_task1 <- stations_world %>%
  dplyr::filter(
    (longitude >= -170 & longitude <= -25) |                  # Americas
      (longitude >= -15 & longitude <= 60 & latitude >= 30)     # Europe
  ) %>%
  mutate(
    fast_type = ifelse(is_fast_dc %in% c(1, TRUE, "1", "TRUE"), "Fast-DC", "Non-fast"),
    # Pre-assign colors here to ensure consistency across all charts
    color_fast = ifelse(fast_type == "Fast-DC", "#FFB347", "#33CCFF")
  )

# SF object for Map (Leaflet)
stations_task1_sf <- st_as_sf(
  stations_task1,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

# 3. Aggregates: Global Mix & Pareto -------------------------

# 3.1 Global Fast-DC vs Non-fast mix
fast_mix_global <- stations_task1 %>%
  count(fast_type, wt = ports, name = "ports") %>% # count(wt=...) 代替 group_by + sum
  mutate(share = ports / sum(ports))

# 3.2 Country-level Pareto Data
fast_country_pareto <- stations_task1 %>%
  group_by(country_code, fast_type) %>%
  summarise(ports = sum(ports, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(
    names_from = fast_type, 
    values_from = ports, 
    values_fill = 0
  ) %>%
  rename(fast_ports = `Fast-DC`, nonfast_ports = `Non-fast`) %>%
  filter(fast_ports > 0) %>%
  arrange(desc(fast_ports)) %>%
  mutate(
    fast_share     = fast_ports / sum(fast_ports),
    cum_fast_share = cumsum(fast_share),
    country_code   = factor(country_code, levels = country_code) # Lock order
  )

# Top 35 for Pareto Plot
fast_country_top35 <- fast_country_pareto %>%
  slice_head(n = 35) %>%
  mutate(cum_share_scaled = cum_fast_share * 30) # Scaling for dual-axis plot

# 4. Power Class Data (Optimized & Ordered) ------------------

# Define the logical order for the legend (Low -> High Power)
power_levels_order <- c(
  "AC_L1_(<7.5kW)",
  "AC_L2_(7.5-21kW)",
  "AC_HIGH_(22-49kW)",
  "DC_FAST_(50-149kW)",
  "DC_ULTRA_(>=150kW)"
)

pc_df_ready <- stations_task1 %>%
  # 1. Filter valid power classes
  filter(!is.na(power_class), power_class != "POWER_UNKNOWN") %>%
  
  # 2. Aggregation: Count stations by country & class
  count(country_code, power_class, name = "stations") %>%
  
  # 3. Calculate total stations per country (for ranking)
  add_count(country_code, wt = stations, name = "total_stations") %>%
  
  # 4. Filter: Keep only Top 35 countries
  # (Logic: Find top countries by total_stations inside the filter)
  filter(country_code %in% (
    distinct(., country_code, total_stations) %>%
      slice_max(total_stations, n = 35) %>%
      pull(country_code)
  )) %>%
  
  # 5. Formatting: Order Factors & Create Hover Text
  mutate(
    # Order X-axis: Countries by total stations (Descending)
    country_code = reorder(country_code, -total_stations),
    
    # Order Legend/Stacks: Apply the specific power levels defined above
    power_class  = factor(power_class, levels = power_levels_order),
    
    hover_text   = paste0(
      "Country: ", country_code, "<br>",
      "Class: ", power_class, "<br>",
      "Stations: ", stations
    )
  )