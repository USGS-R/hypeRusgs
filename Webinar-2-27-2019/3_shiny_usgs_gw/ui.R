
library(shinythemes)

ui <- fluidPage(
  
  theme = shinytheme("yeti"),
  
  # # Code for just adding tabs
  # navbarPage(
  #   title = "USGS GW Example App",
  #   tabPanel("Select Data and Plot"),
  #   tabPanel("About")
  # )
  
  # Code for populating tabs with wdigets and info
  navbarPage(
    title = "USGS GW Example App",
    tabPanel(
      "Select Data and Plot",
      sidebarLayout(
        sidebarPanel(
          textInput("site_no", label = "", placeholder = "Enter USGS site number"),
          selectInput("pcode", label = "Select a parameter",
                      choices = list(
                        "Discharge, cfs" = "00060",
                        "Gage height, ft" = "00065",
                        "Water temperature, deg C" = "00010"
                      )),
          dateRangeInput("dates", h3("Date range")),
          actionButton("submit", "Submit")
        ),
        mainPanel(
          plotOutput("plot")
        )
      )
    ),
    tabPanel(
      "About",
      p("This is an example app built by Lindsay Platt on 2/27/19 for use in a webinar demonstrating Shiny. The code is available in the hypeRusgs repository on GitHub. The app pulls data from the publicly available webservices of the National Water Information System (NWIS)."),
      hr(),
      img(src = "usgs-logo.png", width = 400)
    )
  )
  
)

