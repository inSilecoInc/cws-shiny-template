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


## The required packages 

```r
deps <- c(
  "DT",
  "leaflet",
  "readxl",
  "rgovcan",
  "sf",
  "shiny",
  "tidyverse"
)
```