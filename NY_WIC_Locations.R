################################################################################
### Environment setup
################################################################################

# Install latest ggmap from GitHub to use API key 
#  install.packages("devtools")
#  devtools::install_github("dkahle/ggmap")

library(ggmap)         # Mapping and geocoding tools
library(tidyverse)     # Lots of data tools, https://www.tidyverse.org/packages/
library(rvest)         # Scrape web pages

source("./secrets.R")  # Loads my Google API Key

################################################################################
### Scrape table from HTML
################################################################################

# New York State WIC Page URL
nypage <- "https://www.health.ny.gov/prevention/nutrition/wic/local_agencies.htm"

# Get page, isolate table
# NOTE: Found table bin with SelectorGadget tool 
ny <- read_html(nypage) %>%
    html_node(".widetable") %>%
    html_table(fill=TRUE)

# Create full address with street, city, and zip
ny$address <- paste0(ny$`Street Address`, ", ", ny$City, ", ", ny$Zip)

################################################################################
### Geocode addresses
################################################################################

# Comment out API calls after the first download
# nylatlon <- geocode(ny$address)
# write_csv(nylatlon, "./out/NY WIC LatLon.csv")
nylatlon <- read_csv("./out/NY WIC LatLon.csv")

ny <- bind_cols(ny, nylatlon)

################################################################################
### Create map
################################################################################

# Get map data
mdata <- get_map(location = "Syracuse, New York",
                 color = "color",
                 source = "google",
                 maptype = "roadmap",
                 zoom = 7)

# Create a map using sample members' addresses
ggmap(mdata,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude") +
    geom_point(data=nylatlon, aes(x = lon, y = lat), color="blue", size=3, show.legend = FALSE)
