library(shiny)
library(DT)
library(leaflet)

densities <- read.csv("../data/densities.csv")
species <- read.csv("../data/species.csv")
geo <- sf::st_read("../data/AtlasGrid-GrilleAtlas.gdb", layer = "AtlasGrid_GrilleAtlas") |>
       sf::st_transform(crs = 4326)


  pal <- leaflet::colorBin("YlOrRd", domain = geo$density)

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "flatly", version = 5),
  titlePanel("Shiny application template"),
  sidebarLayout(
    
    # Menu 
    sidebarPanel(
      h4("Table filtering"),
      selectInput("species", label = "Species", choices = sort(unique(densities$Group))),
      selectInput("period", label = "Period", choices = sort(unique(densities$Month))),
      br(),
      h4("Spatial filtering"),
      sliderInput("lon", label = "Longitude", value = c(-93, -18), min = -93, max = -18),
      sliderInput("lat", label = "Latitude", value = c(36, 76), min = 36, max = 76),
      width = 3
    ),
     
    # Main panel of application 
    mainPanel(
      tabsetPanel(
        # Panel 1 
        tabPanel(
          "Species table",
          dataTableOutput("table")
        ),
        
        # Panel 2
        tabPanel("Map",
          leafletOutput("map", width = "100%", height = "85vh")
        )
      ),
      width = 9
    )
  )  
)

server <- function(input, output, session) {
  densities_filter <- reactive({
    dplyr::filter(
      densities, 
      Group == input$species,
      Month == input$period
    )
  })
  
  atlas_filter <- reactive({
    # Create bounding box
    bbox <- c(
      xmin = input$lon[1], ymin = input$lat[1], 
      xmax = input$lon[2], ymax = input$lat[2]
    ) |>
    sf::st_bbox(crs = sf::st_crs(4326)) |>
    sf::st_as_sfc()
    
    # Intersect with atlas grid
    geo[bbox, ]
  })
 
  output$table <- renderDataTable(
    densities_filter(),  
    rownames= FALSE, 
    options = list(pageLength = 10)
  )
  
  output$map <- renderLeaflet({
    leaflet(atlas_filter()) |> 
    setView(lng = -55.5, lat = 60, zoom = 4) |>
    addProviderTiles("CartoDB.Positron") |>
    addPolygons()
  })

}

shinyApp(ui, server)