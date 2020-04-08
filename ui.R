library(ggvis)

# For dropdown menu
actionLink <- function(inputId, ...) {
    tags$a(href='javascript:void',
           id=inputId,
           class='action-button',
           ...)
}

navbarPage("Ecosystem Comparison",
    

   tabPanel("Home", 
        titlePanel("Ecosystem explorer"),
        fluidRow(
            column(3,
                   wellPanel(
                       h4("Filter"),
                       sliderInput("diff", "Minimum number of disturbed acres (millions)",
                                   0, 51, 0, step = .01),
                       #sliderInput("year", "Year released", 1940, 2014, value = c(1970, 2014),
                        #           sep = ""),
                       #sliderInput("oscars", "Minimum number of Oscar wins (all categories)",
                                  # 0, 4, 0, step = 1),
                       sliderInput("curAcres", "Current Acres (millions)",
                                   0, 65, c(0, 70), step = .01),
                       sliderInput("perChange", "Percent change",
                                   0, 100, c(0, 100), step = .01),
                       #selectInput("genre", "Genre (a movie can have multiple genres)",
                        #           c("All", "Action", "Adventure", "Animation", "Biography", "Comedy",
                        #             "Crime", "Documentary", "Drama", "Family", "Fantasy", "History",
                        #             "Horror", "Music", "Musical", "Mystery", "Romance", "Sci-Fi",
                        #             "Short", "Sport", "Thriller", "War", "Western")
                       #),
                       #textInput("director", "Director name contains (e.g., Miyazaki)"),
                       #textInput("cast", "Cast names contains (e.g. Tom Hanks)")
                   ),
                   #wellPanel(
                    #   selectInput("xvar", "X-axis variable", axis_vars, selected = "Meter"),
                    #   selectInput("yvar", "Y-axis variable", axis_vars, selected = "Reviews"),
                    #   tags$small(paste0(
                        #   "Note: The Tomato Meter is the proportion of positive reviews",
                        #   " (as judged by the Rotten Tomatoes staff), and the Numeric rating is",
                        #   " a normalized 1-10 score of those reviews which have star ratings",
                        #   " (for example, 3 out of 4 stars)."
                      # ))
                  # )
            ),
            column(9,
                   ggvisOutput("plot1"),
                   wellPanel(
                       span("Number of ecosystems selected:",
                            textOutput("n_ecosystems")
                       )
                   )
            )
        )
    ),
   
    tabPanel("US Map", 
             titlePanel("This is an example to see if this works"),
             
    )
)
