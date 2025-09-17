# Download GBIF occurrences for Medfly (Ceratitis capitata) and filter for CONUS
library(rgbif)
library(dplyr)
library(sf)

species_name <- 'Ceratitis capitata'

# Use rgbif to search occurrences; this may take time and might need paging
occ <- occ_search(scientificName = species_name,
                  hasCoordinate = TRUE,
                  limit = 200000)

occ_df <- occ$data %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  filter(!is.na(decimal_latitude), !is.na(decimal_longitude)) %>%
  select(key, scientific_name, decimal_latitude, decimal_longitude, country, state_province, locality, year)

# Convert to sf points
occ_sf <- st_as_sf(occ_df, coords = c('decimal_longitude','decimal_latitude'), crs = 4326, remove = FALSE)

# Keep only occurrences within the continental US (CONUS). We'll use a simple bounding box for CONUS
conus_bbox <- st_as_sfc(st_bbox(c(xmin = -125, xmax = -66.5, ymin = 24.5, ymax = 49.5), crs = 4326))
occ_conus <- occ_sf[st_intersects(occ_sf, conus_bbox, sparse = FALSE), ]

message('Total occurrences downloaded: ', nrow(occ_df))
message('Occurrences in CONUS: ', nrow(occ_conus))

# Save results
dir.create('data', showWarnings = FALSE)
readr::write_rds(occ_conus, 'data/medfly_gbif_conus.rds')

message('Saved to data/medfly_gbif_conus.rds')
