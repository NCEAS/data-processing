library(arcticdatautils)
library(dataone)
library(EML)
library(tidyverse)

#get auth token

cn <- CNode("PROD")
adc <- getMNode(cn, "urn:node:ARCTIC")

original_rm <- "resource_map_urn:uuid:1d762afa-8ee9-4afa-af60-f38bcee8d543"

#get the most recent resource map
all_versions <- get_all_versions(adc, original_rm)
rm <- all_versions[length(all_versions)]

#read in the metadata
pkg <- get_package(adc, rm)
doc <- read_eml(getObject(adc, pkg$metadata))

#FAIR
doc <- eml_add_publisher(doc)
doc <- eml_add_entity_system(doc)

#going through and uploading all the files in the zip
gpr_file <- list.files("EAGER_GPR_Dataset", recursive = TRUE, full.names = TRUE)

#update
eml_validate(doc)

eml_path <- "/home/egg/Tickets/Ticket 6 - Correa Rangel/cr_updated_eml.xml"
write_eml(doc, eml_path)
update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = c(pkg$data, unlist(data_pids)),
                         metadata_path = eml_path,
                         public = FALSE)

##including metadata_path in last update overrode creating otherentities for the data objects, so loop to fix it
gpr_entity <- list()
for(i in 1:length(data_pids)){
  en <- pid_to_eml_entity(adc, data_pids[[i]], entity_type = "otherEntity")
  gpr_entity[[i]] <- en
}
doc$dataset$otherEntity[[i]] <- gpr_entity

##another update
eml_validate(doc)

eml_path <- "/home/egg/Tickets/Ticket 6 - Correa Rangel/cr_updated_eml2.xml"
write_eml(doc, eml_path)
update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data[-198],
                         metadata_path = eml_path,
                         public = FALSE)

##remove the zip
#did this in the above publish update

##remove the zip's other entity
doc$dataset$otherEntity[[1]] <- NULL

##run project
doc$dataset$project <- eml_nsf_to_project("1823717")

##update sysmeta to say format of csv on the csv
sysmeta <- getSystemMetadata(adc, "urn:uuid:ee35812b-4e81-4069-a244-a9ebce238e96")
sysmeta@formatId <- "text/csv"
updateSystemMetadata(adc, "urn:uuid:ee35812b-4e81-4069-a244-a9ebce238e96", sysmeta)

##csv - add attributes
data<-read.csv("EAGER_GPR.csv")
atts <- EML::shiny_attributes(data = data)
att_list <- EML::set_attributes(attributes = atts$attributes)
phys <- arcticdatautils::pid_to_eml_physical(adc, pkg$data[[197]])

dataTable_new <- eml$dataTable(entityName = "EAGER_GPR.csv",
                               physical = phys,
                               attributeList = att_list)

doc$dataset$dataTable <- dataTable_new
doc$dataset$otherEntity[[1]] <- NULL

##another update - kept rerunning this one for subsequent updates, editing the eml path each time
eml_validate(doc)

eml_path <- "/home/egg/Tickets/Ticket 6 - Correa Rangel/cr_updated_eml9.xml"
write_eml(doc, eml_path)
update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = eml_path,
                         public = FALSE)

## fix meters (m) in abstract
#did this in web editor

##spatial
#working with spatial files

#checking out layers
sf::st_layers("EAGER_GPR.kml")

#reading the spatial file to find geometry and crs
layer_38 <- sf::read_sf("EAGER_GPR.kml", layer = "38")
View(layer_38)

#if you want to find the entire list of accepted crs and how they should be formatted
coord_list <- arcticdatautils::get_coord_list()

## spatial atts
"urn:uuid:a34c2206-1baf-4f3d-902d-4322f9892809"
library(sf)
data2 <- sf::read_sf("EAGER_GPR.kml")
atts2 <- EML::shiny_attributes(data = data2)
att_list2 <- EML::set_attributes(attributes = atts2$attributes)
phys2 <- arcticdatautils::pid_to_eml_physical(adc, pkg$data[[119]])
spatialVector <- pid_to_eml_entity(adc,
                                   pkg$data[122],
                                   entity_type = "spatialVector",
                                   entityName = "EAGER_GPR.kml",
                                   entityDescription = "Spatial vector containing GPR data",
                                   attributeList = att_list2,
                                   geometry = "Point",
                                   spatialReference = list(horizCoordSysName = "GCS_WGS_1984"))
doc$dataset$spatialVector <- spatialVector
doc$dataset$otherEntity[[1]] <- NULL

doc$dataset$spatialVector[[1]]$attributeList <- att_list2

##adding 195 entity descriptions
#make sure to change spatial vector from otherentity to spatialvector before running the below
library(stringr)
for(i in 1:length(doc$dataset$otherEntity)){
  if (str_detect(doc$dataset$otherEntity[[i]]$entityName, ".cor")) {
    doc$dataset$otherEntity[[i]]$entityDescription <- paste("GPS coordinates file for", str_remove(doc$dataset$otherEntity[[i]]$entityName, "\\.cor"))
  } else if (str_detect(doc$dataset$otherEntity[[i]]$entityName, ".rad")) {
    doc$dataset$otherEntity[[i]]$entityDescription <- paste("Acquisition parameter file for", str_remove(doc$dataset$otherEntity[[i]]$entityName, "\\.rad"))
  } else {
    doc$dataset$otherEntity[[i]]$entityDescription <- paste("Raw GPR data file for", str_remove(doc$dataset$otherEntity[[i]]$entityName, "\\.rd3"))
  }
}
##define mhz, gps, kml in abstract
#done on web editor

##delete otherEntity of EAGER_GPR.kml and extra spatial vector
doc$dataset$spatialVector[[4]] <- NULL
doc$dataset$spatialVector[[3]] <- NULL
doc$dataset$spatialVector[[2]] <- NULL
doc$dataset$otherEntity[[195]] <- NULL

##make sure it is SHA-1
#loop
for(i in 1:length(pkg$data)){
  sysmeta <- getSystemMetadata(adc, pkg$data[i])
  sysmeta@checksumAlgorithm <- "SHA-1"
  updateSystemMetadata(adc, pkg$data[i], sysmeta)
}

##update physicals
#csv
"urn-uuid-ee35812b-4e81-4069-a244-a9ebce238e96"
phys3 <- arcticdatautils::pid_to_eml_physical(adc, pkg$data[[196]])
doc$dataset$dataTable$physical <- phys3

#kml
"urn:uuid:48f737a5-7b48-4465-83a0-8e7643b6ab16"
phys4 <- arcticdatautils::pid_to_eml_physical(adc, pkg$data[[156]])
doc$dataset$spatialVector$physical <- phys4

#loop for otherEntities
for (i in seq_along(doc$dataset$otherEntity)) {
  otherEntity <- doc$dataset$otherEntity[[i]]
  id <- otherEntity$id
  
  if (!grepl("urn-uuid-", id)) {
    warning("otherEntity ", i, " is not a pid")
    
  } else {
    id <- gsub("urn-uuid-", "urn:uuid:", id)
    physical <- arcticdatautils::pid_to_eml_physical(adc, id)
    doc$dataset$otherEntity[[i]]$physical <- physical
  }
}

##fix typo in abstract - doing it this way because web editor causes duplicates of entities to be made
doc$dataset$abstract$para[[1]] <- str_replace(doc$dataset$abstract$para[[1]], "estimated", "estimate")

##set rights and access
# Set ORCiD
subject <- 'https://orcid.org/0000-0003-4934-7016'

# As a convention we use `http:` instead of `https:` in our system metadata
subject <- sub("^https://", "http://", subject)

set_rights_and_access(adc,
                      pids = c(pkg$metadata, pkg$data, pkg$resource_map),
                      subject = subject,
                      permissions = c('read','write','changePermission'))

##final publish
update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         data_pids = pkg$data,
                         resource_map_pid = pkg$resource_map,
                         metadata_path = eml_path,
                         public = T,
                         use_doi = T)
