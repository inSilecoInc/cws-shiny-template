library(shiny)
ui <- fluidPage(
  # Menu
  selectInput(
    "dataset", 
    label = "Dataset", 
    choices = speices in table
  ),
  
  # Panel 1 
  
  
  # Panel 2
  
  # Panel 3
  tableOutput("summary_table")
)

server <- function(input, output, session) {
  # Data table 
  ouput$data_table <- reactive({
    
  })
  
  # Panel 1 
  
  
  # Panel 2
  
    
  # Panel 3
  output$table <- renderTable({
    dataset <- get(input$dataset, "package:datasets")
    dataset
  })
}

shinyApp(ui, server)