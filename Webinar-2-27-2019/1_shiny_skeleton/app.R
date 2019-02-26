
library(shiny)

ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("Here's a shiny app!"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(),
  
  # Main panel for displaying outputs ----
  mainPanel()
)

server <- function(input, output) {
  
}

shinyApp(ui, server)
