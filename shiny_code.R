library(sf)
library(dplyr)
library(leaflet)
library(tidyr)
library(ggplot2)
library(DataCombine)
library(reshape2)
library(plotly)
library(rmapshaper)
library(rgeos)
library(sp)
library(readr)

# Graph Data Prep

UsedData <- read_csv("UsedData.csv", col_types = cols(AG = col_number(), 
                                                      DEV = col_number(), NotAG_DEV = col_number(), 
                                                      ORIGINAL = col_number()))


comp <- UsedData

#renaming columns

colnames(comp)[colnames(comp)=="ORIGINAL"] <- "ACRES_HIST"

colnames(comp)[colnames(comp)=="NotAG_DEV"] <- "ACRES_CURR"

colnames(comp)[colnames(comp)=="BPS_NAME"] <- "CLASSNAME"

#reordering by classname

comp <- arrange(comp, CLASSNAME)

#adding diff column
#comp <- mutate(comp, DIFF = Acres)

comp$DIFF <- abs(as.numeric(comp$ACRES_HIST) - as.numeric(comp$ACRES_CURR))

#adding percent change column

comp$PER_CHANGE <- round((comp$DIFF / comp$ACRES_HIST) * 100, 2)


write.csv(comp, file = "./comp.csv")


# Map Data Prep

MapData <- read_csv('MapData.csv')

#Preparing Map Data for use
allDataMap <- MapData

#removing the value and us_140 columns
allDataMap <- allDataMap[-c(1, 4)]


#taking out all values with urban in the name
urbanMap <- allDataMap %>%
  filter(
    grepl('Urban', DESCRIPTIO)
  )

#changing label and description to urban for simplicity
urbanMap$DESCRIPTIO <- 'Urban'
urbanMap$LABEL <- 'Urban'

#summing the count column by GEOID10 column
urbanCntys <- urbanMap[c(1, 2)]

urbanMap <- urbanMap[-c(1)]

urbanCntys <- urbanCntys %>%
  group_by(CNTYS) %>%
  summarise(COUNT = sum(COUNT))

urbanMap <- merge(urbanMap, urbanCntys, by = 'CNTYS')

urbanMap <- urbanMap[!duplicated(urbanMap),]


#doing the same thing but for AG
agMap <- allDataMap %>%
  filter(
    grepl('Agriculture', DESCRIPTIO)
  )

#changing label and description to urban for simplicity
agMap$DESCRIPTIO <- 'Agriculture'
agMap$LABEL <- 'Agriculture'

#summing the count column by GEOID10 column
urbanCntys <- agMap[c(1, 2)]

agMap <- agMap[-c(1)]

urbanCntys <- urbanCntys %>%
  group_by(CNTYS) %>%
  summarise(COUNT = sum(COUNT))

agMap <- merge(agMap, urbanCntys, by = 'CNTYS')

agMap <- agMap[!duplicated(agMap),]


#doing more or less the same thing but for everything not agriculture or urban
naturalMap <- allDataMap %>% 
  filter(
    !grepl("Agriculture|Urban", DESCRIPTIO)
  )

#changing label and description to urban for simplicity
naturalMap$DESCRIPTIO <- 'Natural'
naturalMap$LABEL <- 'Natural'

#summing the count column by GEOID10 column
naturalCntys <- naturalMap[c(1, 2)]

naturalMap <- naturalMap[-c(1)]

naturalCntys <- naturalCntys %>%
  group_by(CNTYS) %>%
  summarise(COUNT = sum(COUNT))

naturalMap <- merge(naturalMap, naturalCntys, by = 'CNTYS')

naturalMap <- naturalMap[!duplicated(naturalMap),]


#starting to merge all data back into a complete map
completeMap <- naturalMap


completeMap <- rbind(completeMap, urbanMap, agMap)

#taking out DESCRIPTIO column
completeMap$DESCRIPTIO <- NULL


#creating a  total county acres column
countyTotal <- select( completeMap, CNTYS, COUNT)

#summing each count for each label
countyTotal <- countyTotal %>%
  group_by(CNTYS) %>%
  summarise(COUNT = sum(COUNT))

#renaming to TOTALS
colnames(countyTotal)[colnames(countyTotal)=="COUNT"] <- "TOTAL"

#adding column back in so each row has a total for whichever county it has
completeMap <- merge(completeMap, countyTotal, by = 'CNTYS')

#making completeMap data set long to be able to add to shape file
completeMap <- spread(completeMap, key = LABEL, value = COUNT)


#rename columns to make more sense (Says ACRES but for now it's the original pixel count value)
colnames(completeMap)[colnames(completeMap)=="Agriculture"] <- "ACRES_A"

colnames(completeMap)[colnames(completeMap)=="Natural"] <- "ACRES_N"

colnames(completeMap)[colnames(completeMap)=="Urban"] <- "ACRES_U"

# turn NA values in ACRES_AG to zero
completeMap[c("ACRES_A")][is.na(completeMap[c("ACRES_A")])] <- 0

#changing acres columns to acutal acres values using the conversion of 0.222


# round values to integers
completeMap$ACRES_A <- round(completeMap$ACRES_AG, digits = 0)

completeMap$ACRES_N <- round(completeMap$ACRES_NAT, digits = 0)

completeMap$ACRES_U <- round(completeMap$ACRES_URBAN, digits = 0)

completeMap$TOTAL <- round(completeMap$TOTAL, digits = 0)

#math to add percent columns
completeMap$PERCENT_A <- round(completeMap$ACRES_AG/completeMap$TOTAL *100, 2) 

completeMap$PERCENT_U <- round(completeMap$ACRES_URBAN/completeMap$TOTAL *100, 2) 

completeMap$PERCENT_N <- round(completeMap$ACRES_NAT/completeMap$TOTAL *100, 2) 






# prepping shapefile
# read the map shape file as an sf
usMap <- st_read(dsn = "./UScounties.shp", stringsAsFactors = FALSE)

#rename FIPS to GEOID
colnames(usMap)[colnames(usMap)=="FIPS"] <- "GEOID"


# Taking out Hawaii and Alaskan counties
usMap <- usMap %>%
  filter(
    !grepl("Alaska|Hawaii", NAME)
  )


# renaming GEOID10 to GEOID in completeMap data set to prepare for merge
colnames(completeMap)[colnames(completeMap)=="GEOID10"] <- "GEOID"

# add leading zeros to any FIPS code that's less than 5 digits long to get a good match.
completeMap$GEOID <- formatC(completeMap$GEOID, width = 5, format = "d", flag = "0")

# remove unneeded columns
usMap$STATE_FIPS <- NULL


# simplifying the geometry of the sf file

leafMap <- merge(usMap, completeMap, by = "GEOID", all.x = FALSE)

# changing names of shapefile data so no names change automatically after writing it to a .shp file
colnames(leafMap)[colnames(leafMap)=="STATE_NAME"] <- "STATE_N"
colnames(leafMap)[colnames(leafMap)=="CNTY_FIP"] <- "CNTY_FI"

st_write(leafMap, dsn = 'leafMap.shp', driver = 'ESRI Shapefile')



