
library(dataRetrieval)
library(ggplot2)

server <- function(input, output) {
  
  observeEvent(
    input[["submit"]], 
    {    

      output$plot <- renderPlot({
        
        # First, fetch data from NWISWeb
        df <- readNWISdata(
          siteNumber = input$site_no,
          parameterCd = input$pcode,
          startDate = input$dates[1],
          endDate = input$dates[2],
          service = "dv"
        )
        
        validate(
          need(nrow(df) > 0, "No data was returned.")
        )
        
        # rename the value column to 'value' for plotting
        # remove code columns & only use first value instance
        # some have primary, secondary, etc streams (such as 00065 for 07374000)
        df <- df[,-grep("cd", names(df))]
        names(df)[grep(input$pcode, names(df))[1]] <- "value"
        
        ggplot(df, aes(x = dateTime, y = value)) +
          geom_point(color = "cornflowerblue") +
          xlab("Date") + ylab(input$pcode) +
          theme_bw()
      })
    })
  
}
