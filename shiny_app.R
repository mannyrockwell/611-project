#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyr)
library(highcharter)
library(dplyr)
library(shinythemes)
library(stringr)
library(lubridate)

pitchfork = read.csv("pitchfork.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)  
pitchfork <- pitchfork %>% 
    mutate(simplified_genre = word(genre,1,sep = ",")) %>%
    mutate(date = mdy(date)) %>% 
    mutate(after_aquisition = ifelse(date > "2015-10-13", 1, 0))

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    theme = shinytheme("slate"),

    # Application title
    titlePanel("Pitchfork Reviews 1995 - 2019 "),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("release_year",
                        "Release Year:",
                        min = 1995,
                        max = 2019,
                        value = c(1995,2019),
                        sep="")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           highchartOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    pitchfork_year = function(inputyear){
        pitchfork %>% filter(release_year %in% inputyear[1]:inputyear[2])
    }
    
    output$distPlot <- renderHighchart({
        #hchart(pitchfork_year(input$release_year))
        hchart(pitchfork[pitchfork$release_year %in% input$release_year[1]:input$release_year[2],]$score, 
               color = "#B71C1C") %>% 
        hc_yAxis(title = list(text = "Frequency")) %>% 
        hc_xAxis(title = list(text = "Scores")) %>%
            hc_tooltip(borderWidth = 1, sort = TRUE, crosshairs = TRUE,
                       headerFormat = "",
                       pointFormatter = JS("function() {
return 'Score:'  + Math.round(this.x*10)/10 + '<br> Number of Reviews:' +  this.y;    
             }")) %>%
            hc_legend(enabled = FALSE)

    })
}

# Run the application 
shinyApp(ui = ui, server = server)
