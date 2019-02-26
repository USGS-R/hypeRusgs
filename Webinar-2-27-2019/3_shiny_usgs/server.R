
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
          endDate = input$dates[2]
        )
        
        validate(
          need(nrow(df) > 0, "No data was returned.")
        )

        # rename the value column to 'value' for plotting
        # remove code column
        df <- df[,-grep("cd", names(df))]
        names(df)[grep(input$pcode, names(df))] <- "value"
        
        ggplot(df, aes(x = dateTime, y = value)) +
          geom_point(color = "cornflowerblue") +
          xlab("Date") + ylab(input$pcode) +
          theme_bw()
      })
    })
  
}
