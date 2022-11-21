# cws-shiny-template

Template for the shiny built as part of cws-shiny-workshop

## The application 

This shiny application allows a user to: 

1. filter a dataset and visualize as a table 
  2. Group 
  3. Month
2. filter a spatial object and visualize as a map 
3. summarize data based on filters selected in 1 and 2

## The data 

The data used for this application is the *Atlas of Seabirds at Sea in Eastern Canada 2006 - 2016* (Bolduc *et al.* 2016) available on the Open Government Portal [here](https://open.canada.ca/data/en/dataset/f612e2b4-5c67-46dc-9a84-1154c649ab4e).

```r
resources <- list(
  gdb = list(
    file = "AtlasGrid-GrilleAtlas.gdb.zip",
    location = "http://data.ec.gc.ca/data/species/assess/atlas-of-seabirds-at-sea-in-eastern-canada-2006-2016/AtlasGrid-GrilleAtlas.gdb.zip",
    outputdir = "data"
  ),
  density = list(
    file = "DensityData-DonneesDeDensite.xlsx",
    location = "http://data.ec.gc.ca/data/species/assess/atlas-of-seabirds-at-sea-in-eastern-canada-2006-2016/DensityData-DonneesDeDensite.xlsx",
    outputdir = "data"
  ),
  dictionnary = list(
    file = "DataDictionary-DictionnaireDeDonnees.xlsx",
    location = "http://data.ec.gc.ca/data/species/assess/atlas-of-seabirds-at-sea-in-eastern-canada-2006-2016/DataDictionary-DictionnaireDeDonnees.xlsx",
    outputdir = "data"
  )
)
```

## Getting started  

1. Install packages

```r
pkgs <- c(
  "DT",
  "leaflet",
  "readxl",
  "sf",
  "shiny",
  "tidyverse"
)

# Tell us which one is not already installed
install_pkgs <- pkgs[!pkgs %in% installed.packages()]

# Install the missing dependancies
for(lib in install_libs) install.packages(lib, dependencies=TRUE)

# Load all packages dependancies
sapply(pkgs, require, character=TRUE)

# Download the data required
source(setup.R)
```
