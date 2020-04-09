## Get token!!!
# options(dataone_test_token = "...")

# load packages
library(dataone)
library(datapack)
library(EML)
library(remotes)
library(XML)
library(arcticdatautils)
library(datamgmt)

# setting node to arctic node
cn <- CNode("PROD")
adc <- getMNode(cn, "urn:node:ARCTIC") # the mn

# making sure that we have to most recent reasource map
rm_pid_original <- "resource_map_urn:uuid:9e7325b5-a344-499b-99c1-aa3421f2d297"
all_rm_versions <- get_all_versions(adc, rm_pid_original)
rm_pid <- all_rm_versions[length(all_rm_versions)]

pkg <- get_package(adc,
  rm_pid,
  file_names = T
)

# grab the eml
doc <- read_eml(getObject(adc, pkg$metadata))

# Updating the entityDescription in otherEntity, LIDAR

# get the index of the LIDAR otherEntity and save to to be used
# searches the entityDescriptions for one with LIDAR in it
num <- which_in_eml(
  doc$dataset$otherEntity, "entityDescription",
  function(x) {
    grepl("LIDAR", x)
  }
)

# updating the description in the LIDAR other entity
doc$dataset$otherEntity[[num]]$entityDescription <- "LIDAR derived digital elevation model (29 April 2018)"

# where to save the xml file
eml_path <- here::here("R/JasmineLai/eml.xml")

# save the file
write_eml(doc, eml_path)

# sends update
update <- publish_update(adc,
  metadata_pid = pkg$metadata,
  resource_map_pid = pkg$resource_map,
  data_pids = pkg$data,
  metadata_path = eml_path,
  public = FALSE
)
