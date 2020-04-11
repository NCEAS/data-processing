library(tidyverse)

fl <- list.files("R/JasmineLai/data", 
                 pattern = "*.csv",
                 full.names = T)

date_col <- c("Year", "Month", "Day", "Hours (UTC)")

attribute_tbl <- map(fl, read_csv) %>% 
  map(.,names) %>% 
  map(., as_data_frame) %>% 
  map(.,~mutate(.,
                attributeName = value,
                # measurementScale = if_else(attributeName %in% date_col,
                #                            "dateTime",
                #                            "ratio"),
                domain = if_else(attributeName %in% date_col,
                                 "dateTime",
                                 "numericDomain"),
                missingValueCode = "NaN"))

#save files
nm <- list.files("R/JasmineLai/data", 
                 pattern = "*.csv")

map2(attribute_tbl,nm,~write_csv(.x, paste0("R/JasmineLai/attribute_tbl/",.y)))

data <- read_csv("R/JasmineLai/attribute_tbl/FA_13_Firn_Temperatures_Depths.csv")

shiny_attributes(data = read_csv("R/JasmineLai/data/FA_13_Firn_Temperatures_Depths.csv"))

test_output <- shiny_attributes(attributes = data)
