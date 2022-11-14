library(shiny)
library(DT)
library(leaflet)
library(plotly)

densities <- read.csv("../data/densities.csv")
species <- read.csv("../data/species.csv")
effort <- read.csv("../data/effort.csv")

geo <- sf::st_read("../data/AtlasGrid-GrilleAtlas.gdb", layer = "AtlasGrid_GrilleAtlas") |>
       sf::st_transform(crs = 4326) 

palDensity <- leaflet::colorBin("Greens", domain = geo$density)

maxValue <- max(densities$Density)
minValue <- min(densities$Density)

vecSpecies <- sort(unique(densities$Group))
vecMonths <- sort(unique(densities$Month))

effortVariable <- sort(unique(effort$name))

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "yeti", version = 5),
  titlePanel("Atlas of seabirds (2006-2016)"),
  # Sidebar with a slider input
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Data filtering"),
      selectInput("species", label = "Species", choices = vecSpecies, selected = "TBMU"),
      selectInput("period", label = "Period", choices = vecMonths, selected = "April-July"),
      br(),
      h4("Spatial filtering"),
      sliderInput("lon", label = "Longitude", value = c(-93, -18), min = -93, max = -18),
      sliderInput("lat", label = "Latitude", value = c(36, 76), min = 36, max = 76),
      h4("Effort filtering"),
      selectInput("effortVar", label = "Selected variable", choices = effortVariable, selected = effortVariable[1]),
  ),

  # Main panel of application 
  mainPanel(
    width = 9,
    fluidRow(
      h2(htmlOutput("speciesName")),
      column(8,
        tabsetPanel(type="tabs",
          # Panel 1 
          tabPanel("Density Map",
            leafletOutput("densityMap", width = "100%", height = "80vh")
          ),
          # Panel 2
          tabPanel("Species table",
            dataTableOutput("table")
          )
        )
      ),
      column(4,
        h4("Density observation frequency (log10)"),
        plotlyOutput("graphDistrib"),
        h4("Sampling effort"),
        leafletOutput("effortMap", width = "100%", height = "40vh")
      )
    )
  ))
)

server <- function(input, output, session) {
  
  density_geo_filter <- reactive({
    # Create bounding box
    bbox <- c(
      xmin = input$lon[1], ymin = input$lat[1], 
      xmax = input$lon[2], ymax = input$lat[2]
    ) |>
    sf::st_bbox(crs = sf::st_crs(4326)) |>
    sf::st_as_sfc()
    
    # Add densities for the selected period and group of species
    geo <- dplyr::right_join(
        x = geo, 
        y = dplyr::filter(
          densities, 
          Group == input$species,
          Month == input$period
        ), 
        by = c("id" = "Stratum")
    )

    # Intersect with atlas grid
    geo[bbox, ]
  })

  effort_data_filter <- reactive({
    dplyr::filter(
          effort, 
          name == input$effortVar,
          Month == input$period
        )
  })

  effort_geo_filter <- reactive({
    # Create bounding box
    bbox <- c(
      xmin = input$lon[1], ymin = input$lat[1], 
      xmax = input$lon[2], ymax = input$lat[2]
    ) |>
    sf::st_bbox(crs = sf::st_crs(4326)) |>
    sf::st_as_sfc()
    
    # Add densities for the selected period and group of species
    geo <- dplyr::right_join(
        x = geo, 
        y = effort_data_filter(), 
        by = c("id" = "Stratum")
    )
    # Intersect with atlas grid
    geo[bbox, ]
  })

  palEffort <- reactive({
    leaflet::colorBin("Blues", domain = effort_data_filter()$value)
  })

  output$speciesName <- renderText({
      HTML(paste0(
        "<b>",dplyr::filter(species, Species_ID == input$species)$English_Name,
        "</b><br><i>",dplyr::filter(species, Species_ID == input$species)$Scientific_Name,
        "</i>"
      ))
  })

  output$table <- renderDataTable(
    as.data.frame(density_geo_filter() |> sf::st_drop_geometry()),  
    rownames= FALSE, 
    options = list(pageLength = 20)
  )

  output$graphDistrib <- renderPlotly({
    plot_ly(as.data.frame(density_geo_filter()), type='histogram', x=~log10(Density), bingroup=1) %>%
      layout(
        bargap = 0.2,
        xaxis = list(range = c(log10(minValue), log10(maxValue))), 
        yaxis = list(title = 'Frequency'))
  })

  output$densityMap <- renderLeaflet({
    leaflet(density_geo_filter()) |> 
    setView(lng = -55.5, lat = 60, zoom = 4) |>
    addProviderTiles("CartoDB.Positron") |>
    addPolygons(fillColor = ~palDensity(Density),
      weight = 1,
      color = "grey",
      fillOpacity = 0.8)
  })

  output$effortMap <- renderLeaflet({
    leaflet(effort_geo_filter()) |> 
    setView(lng = -55.5, lat = 60, zoom = 3) |>
    addProviderTiles("CartoDB.Positron") |>
    addPolygons(fillColor = palEffort()(effort_data_filter()$value),
      weight = 1,
      color = "grey",
      fillOpacity = 0.8)
  })
}

shinyApp(ui, server)


# Ex1 : RenderText <- Ajouter le nom Latin + Famille de l'espèce à l'étude dans l'app
# Ex2 : Ajouter un historgramme de fréquence (pour l'espèce et la period select dans le input)
# Ex3 : Ajouter une map sur l'effort d'échatillonage bindé sur l'espèce cible