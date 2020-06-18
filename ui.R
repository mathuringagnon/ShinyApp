library(ggvis)
library(shiny)
library(leaflet)
library(htmltools)
library(shinythemes)

# For dropdown menu
#actionLink <- function(inputId, ...) {
 #   tags$a(href='javascript:void',
  #         id=inputId,
   #        class='action-button',
    #       ...)
#}


navbarPage("Exploration of US Land",
    
   theme = shinytheme("darkly"),
   tabPanel("Home",
            titlePanel("     testing")
   ),
   tabPanel("Graph", 
        titlePanel("Ecosystem Explorer"),
        fluidRow(
            column(3,
                   wellPanel(
                       h4("Filter"),
                       sliderInput("diff", "Minimum number of disturbed acres (millions)",
                                   0, 51, 0, step = .01),
                       sliderInput("curAcres", "Current Acres (millions)",
                                   0, 65, c(0, 70), step = .01),
                       sliderInput("perChange", "Percent change",
                                   0, 100, c(0, 100), step = .01),
                   ),
            ),
            column(9,
                   wellPanel(ggvisOutput("plot1")
                   ),
                   wellPanel(
                       span("Number of ecosystems selected:",
                            textOutput("n_ecosystems")
                       )
                   )
            )
        )
    ),
    tabPanel("US Map",
        tags$style(type = "text/css", "#shinyMap {height: calc(100vh - 50px) !important;}"),
        leafletOutput("shinyMap"
                       ),
        absolutePanel( id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = "auto", left = 10, right = "auto", bottom = 10,
                      width = 160, height = 140,
                      
                      h2("  Color By: "),
                      radioButtons("colorBy", label = NULL,
                                    choices = list("    Percent Natural" = 1, "    Percent Agriculture" = 2, "    Percent Urban" = 3),
                                    selected = 1
                                    )
        
            #sliderInput("percentSelect", "Percent",
            #            0, 100, c(0, 100), step = 0.01),
            #span("Number of Counties Shown: ", textOutput("n_counties"))
        )
    ),
    tabPanel("About",
    )
)
