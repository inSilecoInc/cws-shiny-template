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
  
  # Import density data and simplify
  path <- "data/DensityData-DonneesDeDensite.xlsx"
  densities <- readxl::read_excel(path, "Densities") |>
               dplyr::select(Group, Month, Stratum, Density) |>
               dplyr::mutate(
                 Month = replace(Month, Month == "04050607", "April-July"),
                 Month = replace(Month, Month == "08091011", "August-November"),
                 Month = replace(Month, Month == "12010203", "December-March")
               )

  # Import species dictionnary and simplify
  path <- "data/DataDictionary-DictionnaireDeDonnees.xlsx"
  species <- readxl::read_excel(path, "Species-Espèces") |>
             dplyr::select(Species_ID, English_Name, Scientific_Name, Family_Sci)
  
  # Export as csv
  write.csv(densities, "data/densities.csv", row.names = FALSE)
  write.csv(species, "data/species.csv", row.names = FALSE)
}
