library(ggvis)
library(dplyr)
library(shiny)
library(leaflet)
library(htmltools)
library(viridis)
if(FALSE) {
    library(RSQLite)
    library(dbplyr)
}

# Set up handles to database tables on app start
#db <- src_sqlite("movies.db")
#omdb <- tbl(db, "omdb")
#tomatoes <- tbl(db, "tomatoes")

# Join tables, filtering out those with <10 reviews, and select specified columns
#all_movies <- inner_join(omdb, tomatoes, by = "ID") %>%
 #   filter(Reviews >= 10) %>%
 #   select(ID, imdbID, Title, Year, Rating_m = Rating.x, Runtime, Genre, Released,
  #         Director, Writer, imdbRating, imdbVotes, Language, Country, Oscars,
  #         Rating = Rating.y, Meter, Reviews, Fresh, Rotten, userMeter, userRating, userReviews,
  #         BoxOffice, Production, Cast)
all_ecosystems <- comp

function(input, output, session) {

  
    # Filter the movies, returning a data frame
    ecosystems <- reactive({
        # Due to dplyr issue #318, we need temp variables for input values
        difference <- input$diff * 1000000
        # oscars <- input$oscars
        #minyear <- input$year[1]
        #maxyear <- input$year[2]
        minCurAcres <- input$curAcres[1] * 1e6
        maxCurAcres <- input$curAcres[2] * 1e6
        minPer <- input$perChange[1]
        maxPer <- input$perChange[2]
        
        # Apply filters
        e <- all_ecosystems %>%
            filter(
                DIFF >= difference,
                #Oscars >= oscars,
                #Year >= minyear,
                #Year <= maxyear,
                ACRES_CURR >= minCurAcres,
                ACRES_CURR <= maxCurAcres,
                PER_CHANGE >= minPer,
                PER_CHANGE <= maxPer
            ) %>%
            arrange(ACRES_CURR)
        
        # Optional: filter by genre
        #if (input$genre != "All") {
        #   genre <- paste0("%", input$genre, "%")
        #   m <- m %>% filter(Genre %like% genre)
        #}
        # Optional: filter by director
        #if (!is.null(input$director) && input$director != "") {
        #   director <- paste0("%", input$director, "%")
        #   m <- m %>% filter(Director %like% director)
        #}
        # Optional: filter by cast member
        #if (!is.null(input$cast) && input$cast != "") {
        #   cast <- paste0("%", input$cast, "%")
        #   m <- m %>% filter(Cast %like% cast)
        #}
        
        
        e <- as.data.frame(e)
        
        # Add column which says whether the movie won any Oscars
        # Be a little careful in case we have a zero-row data frame
        #m$has_oscar <- character(nrow(m))
        #m$has_oscar[m$Oscars == 0] <- "No"
        #m$has_oscar[m$Oscars >= 1] <- "Yes"
        #m
    })
    
    # Function for generating tooltip text
    movie_tooltip <- function(x) {
        if (is.null(x)) return(NULL)
        if (is.null(x$CLASSNAME)) return(NULL)
        
        # Pick out the movie with this ID
        all_ecosystems <- isolate(ecosystems())
        ecosystem <- all_ecosystems[all_ecosystems$CLASSNAME == x$CLASSNAME, ]
        
        paste0("<b>", ecosystem$CLASSNAME, "</b>",
               ecosystem$CURR_ACRES, "<br>",
               format(ecosystem$ACRES_CURR, big.mark = ",", scientific = FALSE), " current acres",
               "<br>", format(ecosystem$ACRES_HIST, big.mark = ",", scientific = FALSE), " historical acres",
               "<br>", format(ecosystem$DIFF, big.mark = ",", scientific = FALSE), " difference in acres"
        )
    }
    
    # A reactive expression with the ggvis plot
    vis <- reactive({
        # Lables for axes
        
        
        # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
        # but since the inputs are strings, we need to do a little more work.
        xvar <- prop("x", as.symbol("ACRES_CURR"))
        yvar <- prop("y", as.symbol("DIFF"))
        
        ecosystems %>%
            ggvis(x = xvar, y = yvar, stroke = ~PER_CHANGE) %>%
            layer_points(size := 50, size.hover := 200,
                         fill = ~PER_CHANGE, fill.hover := 0.5,
                         key := ~CLASSNAME) %>%
            add_tooltip(movie_tooltip, "hover") %>%
            add_axis("x", title = "Current Acres") %>%
            add_axis("y", title = "Difference in Acres between Current and Historical",
                     title_offset = 80, properties = axis_props(labels = )) %>%
            #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
            #scale_nominal("stroke", domain = c("Yes", "No"),
             #             range = c("orange", "#aaa")) %>%
            set_options(width = 500, height = 500)
    })
    
    vis %>% bind_shiny("plot1")
    
    output$n_ecosystems <- renderText({ nrow(ecosystems()) })
    

    
    
    
    #CREATING MAP
    
    bin <- c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
    
    pal <- colorNumeric(palette = "viridis", domain = range(0,100), reverse = TRUE, na.color = "red")
    
    #completeData <- leafMap
    
    
    #filtering map data to what is selected
    
    output$shinyMap <- renderLeaflet({
      
      #temp variables to select data from
      #minPercent <- input$percentSelect[1]
      #maxPercent <- input$percentSelect[2]
      selected <- input$colorBy
      
      filteredData <- leafMap
      
      #filter out ag, urban, and natural based on selected and rename columns
      if(selected == 1){
        #if they selected natural
        filteredData$ACRES_AG <- NULL
        filteredData$ACREs_URBAN <- NULL
        filteredData$PERCENT_AG <- NULL
        filteredData$PERCENT_URBAN <-NULL
        
        colnames(filteredData)[colnames(filteredData)=="ACRES_NAT"] <- "ACRES"
        colnames(filteredData)[colnames(filteredData)=="PERCENT_NAT"] <- "PERCENT"  
        
      } else if(selected == 2){
        #if they selected Agriculture
        filteredData$ACRES_NAT <- NULL
        filteredData$ACREs_URBAN <- NULL
        filteredData$PERCENT_NAT <- NULL
        filteredData$PERCENT_URBAN <-NULL
        
        colnames(filteredData)[colnames(filteredData)=="ACRES_AG"] <- "ACRES"
        colnames(filteredData)[colnames(filteredData)=="PERCENT_AG"] <- "PERCENT" 
      
      } else{
        #if they selected urban
        filteredData$ACRES_AG <- NULL
        filteredData$ACREs_NAT <- NULL
        filteredData$PERCENT_AG <- NULL
        filteredData$PERCENT_NAT <-NULL
        
        colnames(filteredData)[colnames(filteredData)=="ACRES_URBAN"] <- "ACRES"
        colnames(filteredData)[colnames(filteredData)=="PERCENT_URBAN"] <- "PERCENT" 
        
      }
      
      #adjusting label to what button is selected
      if(selected == 1){
        lab = sprintf("<strong>%s County</strong><br/>%g%% Natural <br/>%g Natural Acres", filteredData$CNTYS, filteredData$PERCENT, filteredData$ACRES) %>%
          lapply(HTML)
      } else if(selected == 2){
        lab = sprintf("<strong>%s County</strong><br/>%g%% Agriculture <br/>%g Acres of Agriculture", filteredData$CNTYS, filteredData$PERCENT, filteredData$ACRES) %>%
          lapply(HTML)
      } else{
        lab = sprintf("<strong>%s County</strong><br/>%g%% Urban <br/>%g Urban Acres", filteredData$CNTYS, filteredData$PERCENT, filteredData$ACRES) %>%
          lapply(HTML)
      }
      
      #merging filtered data to map
      #finalData <- merge(usMap, filteredData, by = "GEOID")
      
      
      map <- leaflet(data = finalData) %>%
        addPolygons(weight = 1,
                    smoothFactor = 0.02,
                    fillOpacity = 0.9,
                    color = ~pal(PERCENT),
                    highlight = highlightOptions(
                      weight = 3,
                      color = "#666",
                      fillOpacity = 1,
                      bringToFront = TRUE),
                    label = lab,
                    labelOptions =labelOptions(textsize = "15px")) %>%
        
        addLegend(pal = pal,
                  values = ~PERCENT,
                  bins = bin,
                  opacity = 0.7,
                  title = NULL,
                  position = "bottomright")
      
      #filteredData <- filteredData %>% 
        #filter(
          #PERCENT >= minPercent,
          #PERCENT <= maxPercent
        #)
      
      #filteredData <- as.data.frame(filteredData)
    })
     
     
    #output$testingTable <- finalData
     
     
    
    
    
   
    
    
  
        
}