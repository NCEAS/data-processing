#ticket 20632

library(arcticdatautils)
library(dataone)
library(EML)
library(dplyr)
library(datapack)
library(ncdf4)

rm <- "resource_map_urn:uuid:610b0253-5fa1-492b-a6af-abdd012ed325"
pkg <- get_package(adc, rm)
doc <- read_eml(getObject(adc, pkg$metadata))

# abstract: a number of the borehole
doc$dataset$abstract <- gsub("\\(C43-MS1\\)", "borehole with number C43-MS1", doc$dataset$abstract)
doc$dataset$abstract <- gsub("45 km", "45 kilometers (km)", doc$dataset$abstract)
doc$dataset$abstract <- gsub("5.2 m", "5.2 meters (m)", doc$dataset$abstract)

# add decription of images
for (i in 2:length(doc$dataset$otherEntity)) {
  doc$dataset$otherEntity[[i]]$entityDescription <- paste("Photographs of frozen cores for", substr(doc$dataset$otherEntity[[i]]$entityName, start = 30, stop = 40))
}

# remove attribute for otherEntity
for (i in 1:length(doc$dataset$otherEntity)) {
  doc$dataset$otherEntity[[i]]$attributeList <- NULL
}

# add physical
for (i in 1:length(doc$dataset$otherEntity)) {
  id <- gsub("urn-uuid-", "urn:uuid:", doc$dataset$otherEntity[[i]]$id)
  doc$dataset$otherEntity[[i]]$physical <- pid_to_eml_physical(adc, id)
}

# add creator info
doc$dataset$creator[[2]]$electronicMailAddress <- "ecoscience@alaska.net"
doc$dataset$creator[[2]]$userId$directory <- "https://orcid.org"
doc$dataset$creator[[2]]$userId$userId <- "https://orcid.org/0000-0002-9834-8851"

doc$dataset$creator[[3]]$electronicMailAddress <- "akliljedahl@alaska.edu"
doc$dataset$creator[[3]]$userId$directory <- "https://orcid.org"
doc$dataset$creator[[3]]$userId$userId <- "https://orcid.org/0000-0001-7114-6443"

doc$dataset$creator[[4]]$electronicMailAddress <- "ronald.daanen@alaska.gov"
doc$dataset$creator[[4]]$userId$directory <- "https://orcid.org"
doc$dataset$creator[[4]]$userId$userId <- "https://orcid.org/0000-0001-7511-1491"
doc$dataset$creator[[4]]$individualName$givenName <- "Ronald P."

# set contact = creator for MK
doc$dataset$contact <- doc$dataset$creator[[1]]
doc$dataset$contact$id <- NULL

# set nsf
awards <- c("1722572", "1820883") %>% unlist()
doc$dataset$project <- eml_nsf_to_project(awards)

# add FAIR
doc <- eml_add_publisher(doc)
doc <- eml_add_entity_system(doc)

# methods: expand acronym
doc$dataset$methods$methodStep$description$para <- gsub("cu. in.", "cubic inches", doc$dataset$methods$methodStep$description$para)
doc$dataset$methods$methodStep$description$para <- gsub("h.p.", "horsepower", doc$dataset$methods$methodStep$description$para)
doc$dataset$methods$methodStep$description$para <- gsub("72 h", "72 hours", doc$dataset$methods$methodStep$description$para)

# valid EML
eml_validate(doc)

# write EML
eml_path <- "/home/kwang/MikhailK_JagoRiver/metadata.xml"
write_eml(doc, eml_path)

# update EML
#update <- publish_update(adc,
#                         metadata_pid = pkg$metadata,
#                         resource_map_pid = pkg$resource_map,
#                         data_pids = pkg$data,
#                         metadata_path = eml_path,
#                         public = FALSE)
