# Install required R packages for the medfly SDM project
pkgs <- c(
  'remotes',
  'rgbif',
  'sf',
  'raster',
  'terra',
  'sp',
  'dismo',
  'maxnet',
  'flexsdm',
  'geodata',
  'tidyverse',
  'janitor'
)

inst <- rownames(installed.packages())
to_install <- setdiff(pkgs, inst)
if(length(to_install)) {
  message('Installing: ', paste(to_install, collapse=', '))
  install.packages(to_install, repos = 'https://cloud.r-project.org')
} else {
  message('All packages already installed')
}

# flexsdm is on CRAN; if you want the development version uncomment below
# if(!'flexsdm' %in% inst) remotes::install_github('marlonecobos/flexsdm')

message('Done. Restart R session if any namespace conflicts occur.')
