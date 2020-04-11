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
rm_pid_original <- "resource_map_urn:uuid:fefa7f4a-5b9b-4b63-acb3-f42ee0fc07a3"
all_rm_versions <- get_all_versions(adc, rm_pid_original)
rm_pid <- all_rm_versions[length(all_rm_versions)]

pkg <- get_package(adc,
                   rm_pid,
                   file_names = T
)

doc <- read_eml(getObject(adc, pkg$metadata))

f <- read_eml(getObject(adc, pkg$data))

# updating the physical for all items in otherEntity
for (i in seq_along(doc$dataset$otherEntity)) { # goes through all of the items in otherEntity
  otherEntity <- doc$dataset$otherEntity[[i]] #grab the item in  that index
  id <- otherEntity$id #get the  id
  
  if (!grepl("urn-uuid-", id)) {
    warning("otherEntity ", i, " is not a pid")
    
  } else {
    id <- gsub("urn-uuid-", "urn:uuid:", id)
    physical <- arcticdatautils::pid_to_eml_physical(adc, id)
    doc$dataset$otherEntity[[i]]$physical <- physical
  }
}
