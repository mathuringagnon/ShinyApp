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
            fluidRow(
              column(10, align="left", offset = 1,
                     tags$h1(
                       tags$b("Land use and ecosystem loss in the lower 48 states"
                       )
                     ),
                     tags$h3(
                        tags$p("In recent centuries technology has vastly improved, aiding in the explosion of the human population which,
                               now in 2020, has surpassed 7.6 billion globally. This explosion of population has undoubtedly affected many ecosystems,
                               and as humans continue to expand agricultural and urban land use, examining which ecosystems have been impacted is becoming 
                               increasingly urgent. ", "text-indent: 1.5em"
                              ),
                        tags$br(),
                        tags$p("   The United States is the fourth largest country in the world and has 2.3 billion acres of land, with the lower 48 states comprising
                                1.9 billion of those acres. In our web app we explore how the ~1,000 ecosystems of the US have changed, where the changes have been 
                                the greatest, as well as how the land of the US has is used between urban settings, agriculture, and natural.")
                     )
              )
            )
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
             #this page has about what code we used how we created this page
    )
)
