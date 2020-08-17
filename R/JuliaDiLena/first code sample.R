library(dataone)
library(arcticdatautils)
library(tidyverse)
library(reprex)
library(EML)
library(stringr)
library(dataone)
library(datamgmt)

cn <- CNode("PROD")
adc <- getMNode(cn, "urn:node:ARCTIC")

#get resource map
rm <- "resource_map_urn:uuid:eb8a029b-4f1c-4244-9ef3-1c181c6c2094"
pkg <- get_package(adc, rm)

#load in the metadata
doc <- read_eml(getObject(adc, pkg$metadata))

id_new <- arcticdatautils::update_object(adc, 
                                         pid = "urn:uuid:d5cf2773-6081-4395-af51-a7c532b30fcf",
                                         path = "Arctic_Data_Center_2017_2018_Biogeochemistry 3.csv",
                                         format_id = "text/csv")

physical <- arcticdatautils::pid_to_eml_physical(adc, id_new)

doc <- read_eml(getObject(adc, pkg$metadata))
doc$dataset$dataTable[[4]]$physical <- physical
eml_validate(doc)


eml_path <- "Pain_2019_Hydrogeochemistry.xml"
write_eml(doc, eml_path)

# Manually set ORCiD
subject <- 'http://orcid.org/0000-0002-2873-3180'

# Set ORCiD from EML creator

# if more than 1 creator exists and you want the first one
subject <- doc$dataset$creator[[1]]$userId$userId

# As a convention we use `http:` instead of `https:` in our system metadata
subject <- sub("^https://", "http://", subject)

set_rights_and_access(adc, 
                      pids = c(pkg$metadata, pkg$data, pkg$resource_map),
                      subject = subject,
                      permissions = c('read','write','changePermission'))

update <- publish_update(adc, 
                         metadata_pid = "urn:uuid:394bace0-ee04-4f4a-b21a-6ab99726ecaa",
                         resource_map_pid = "resource_map_urn:uuid:3ddbe853-a40d-414d-b16b-51d3b6e50779",
                         data_pids = c(pkg$data, id_new), # add new pid
                         metadata_path = eml_path, 
                         public = TRUE)

all_ver <- get_all_versions(adc, 'urn:uuid:394bace0-ee04-4f4a-b21a-6ab99726ecaa')
most_recent <- all_ver[length(all_ver)]
most_recent

update$resource_map

all_ver_rm <- get_all_versions(adc, update$resource_map)
most_recent_rm <- all_ver_rm[length(all_ver_rm)]
most_recent_rm


getSystemMetadata(adc, "urn:uuid:ef271d62-22f9-4866-9b76-1b042cf4bd8b")


#keywords
kw_list_1 <- eml$keywordSet(keyword = list("Greenland", "glacial meltwater", "stream water chemistry", "watersheds", "hydrology", "biogeochemistry", "hydrogeochemistry", "trace metals"))
doc$dataset$keywordSet <- list(kw_list_1)

rm <- "resource_map_urn:uuid:3ddbe853-a40d-414d-b16b-51d3b6e50779"
pkg <- get_package(adc, rm)
update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         data_pids = pkg$data,
                         resource_map_pid = pkg$resource_map,
                         metadata_path ="Pain_2019_Hydrogeochemistry.xml",
                         public = T)

update <- publish_update(adc,
                         metadata_pid = pkg$metadata,
                         data_pids = pkg$data,
                         resource_map_pid = pkg$resource_map,
                         metadata_path = eml_path,
                         public = T,
                         use_doi = T)

datamgmt::categorize_dataset("doi:10.18739/A2PC2T94T", c("glaciology", "atmosphere"), "Julia DiLena", overwrite = TRUE)
