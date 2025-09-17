# Modeling pipeline using flexsdm for Medfly in CONUS
library(flexsdm)
library(terra)
library(sf)
library(dplyr)

# Load occurrences and env
occ <- readr::read_rds('data/medfly_gbif_conus.rds')
env_stack <- rast('data/wc_bio_conus.tif')

# Convert occurrences to simple data.frame with coordinates
occ_df <- occ %>% st_drop_geometry() %>% rename(lon = decimal_longitude, lat = decimal_latitude)

# Prepare presence points and background
# flexsdm supports different model types; we'll run a simple Maxent (via maxnet) and GLM ensemble

# Create spatial points for presences
presences <- occ_df %>% select(lon, lat) %>% as.data.frame()

# Sample background points across CONUS using terra
set.seed(42)
bg_pts <- spatSample(env_stack[[1]], size = 10000, method = 'random', na.rm = TRUE, values = FALSE)
bg_coords <- as.data.frame(xyFromCell(env_stack[[1]], bg_pts))
colnames(bg_coords) <- c('lon','lat')

# Extract env variables for presences and background
pres_vals <- terra::extract(env_stack, presences)
bg_vals <- terra::extract(env_stack, bg_coords)

# Combine and create response
pres_df <- cbind(presences, pres_vals)
pres_df$presence <- 1
bg_df <- cbind(bg_coords, bg_vals)
bg_df$presence <- 0
train_df <- bind_rows(pres_df, bg_df) %>% drop_na()

# Fit a simple Maxnet model
message('Fitting maxnet model (Maxent-style)')
maxnet_mod <- maxnet::maxnet(p = train_df$presence, data = train_df %>% select(-presence), f = maxnet::maxnet.formula(train_df$presence, train_df %>% select(-presence)))

# Predict across env stack
pred <- predict(env_stack, maxnet_mod, type = 'response')
writeRaster(pred, 'data/medfly_maxnet_conus.tif', overwrite = TRUE)
message('Saved prediction to data/medfly_maxnet_conus.tif')

# Optionally, use flexsdm wrappers to fit ensemble models; skip advanced tuning in this minimal script
