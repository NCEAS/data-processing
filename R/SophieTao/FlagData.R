library(plotly)
library(shiny)
library(ggplot2)
library(dplyr)

##### Function ##### 
flagData <- function (df, x, y, origin = NULL) {
  
  formatSelected <- function(s = NULL) {
    
    if (!is.null(s)) {
      s <- s[, c("x", "y")]
      colnames(s) <- c(x, y)
      if (!is.null(origin)) {
        s[,1] <- as.POSIXct(s[,1], origin = origin)
      }
      s
    }
  }
  
  ui <- fluidPage(
    plotlyOutput("plot"),
    actionButton("finish", "Finished")
  )
  
  server <- function(input, output, session) {
    
    if (!"FLAG" %in% colnames(df)) {
      df$FLAG = FALSE
    }
    df$INDEX = rownames(df)
    
    reactive_s <- reactiveVal("")
    reactive_df <- reactiveVal(df)
    
    observeEvent(event_data("plotly_selected"), {
      s <- event_data("plotly_selected")
      s <- formatSelected(s)
      df <- reactive_df()
      s <- left_join(s, df, by = c(x, y))
      df[df$INDEX %in% s$INDEX, "FLAG"] <- !df[df$INDEX %in% s$INDEX, "FLAG"]
      
      reactive_s(s)
      reactive_df(df)
    })
    
    output$plot <- renderPlotly({
      
      
      plot <- ggplot(reactive_df())+
        geom_point(aes_string(x = x, y = y, color = "FLAG"))
      ggplotly(plot)
    })
    
    observe({
      if(input$finish > 0){
        
        stopApp(reactive_df())
      }
    })
    
  }
  suppressMessages(suppressWarnings(runApp(shinyApp(ui, server))))
  
}

##### Example Script ##### 
# Get data
df <- read.csv("/home/stao/StreamTemp.csv")
# Format data
df$SampleDateTime <- as.POSIXct(df$SampleDateTime)
# Get time scale origin
origin = df$SampleDateTime[1] - as.numeric (df$SampleDateTime[1])
# Run app
df <- flagData(df, "SampleDateTime", "Temperature", origin)
# Change flagging if needed
df$FLAG <- as.numeric(!df$FLAG)

