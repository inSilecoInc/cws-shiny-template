# Get data used for the shiny application
# Atlas of Seabirds at Sea in Eastern Canada 2006-2016
# https://open.canada.ca/data/en/dataset/f612e2b4-5c67-46dc-9a84-1154c649ab4e
if (!file.exists("data/AtlasGrid-GrilleAtlas.gdb")) {
  library(rgovcan)
  uid <- "f612e2b4-5c67-46dc-9a84-1154c649ab4e"
  output <- "data/"
  if (!file.exists(output)) dir.create(output)
  suppressWarnings(
    govcan_dl_resources(resources = uid, path = output)
  )
  utils::unzip("data/AtlasGrid-GrilleAtlas.gdb.zip", exdir = output)  
}
