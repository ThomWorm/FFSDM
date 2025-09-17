# Prepare environmental rasters for CONUS using geodata::worldclim or raster/terra
library(geodata)
library(terra)

# Create data dir
dir.create('data', showWarnings = FALSE)

# Download bioclim variables at 2.5 minutes (~5km) resolution
message('Downloading WorldClim v2 bioclim variables (resolution 2.5 minutes)')
wc <- worldclim_global(var = 'bio', res = 2.5, path = 'data')

# wc is a SpatRaster stack; crop to CONUS bbox
conus_ext <- ext(-125, -66.5, 24.5, 49.5)
wc_conus <- crop(wc, conus_ext)

# Optionally resample or select specific layers
writeRaster(wc_conus, filename = 'data/wc_bio_conus.tif', overwrite = TRUE)
message('Saved environmental stack to data/wc_bio_conus.tif')
