#ticket #19545: https://arcticdata.io/catalog/view/urn:uuid:8be0fed5-5b37-4c73-9214-e06889b9a313
library(EML)
library(arcticdatautils)
pkg <- get_package(adc, 'resource_map_urn:uuid:977d6b72-330e-425b-936b-9f4ce4b43988', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))

#I can view .nc files with this
#get_ncdf4_attributes('/home/anchen/ticket #19545/S1_firn_aquifers_2014_2019.nc')

#define acronymns in title and abstract
doc$dataset$title <- "Greenland firn aquifer map 1 kilometer (km) based on Sentinel-1 data from 2014-2019"
doc$dataset$abstract$para[[1]] <- "Firn aquifers in Greenland store liquid water within the upper ice sheet and impact the hydrological system and the ice sheets contribution to sea level rise. This Sentinel-1 based product provides a first estimate of firn aquifer presence covering the full Greenland ice sheet at 1 kilometer (km) resolution. The detection of aquifers relies on a delay in the freezing of meltwater within the ﬁrn above the water table, causing a distinctive pattern in the radar backscatter. The total aquifer area is estimated at 54,800 square kilometers (km2). This data set can help improve our understanding of the role of firn aquifers in the complex ice sheet system. With continuity of Sentinel-1 ensured until 2030, our study lays a foundation for monitoring the future response of ﬁrn aquifers to climate change."
doc$dataset$project$title <- "Greenland firn aquifer map 1 kilometer (km) based on Sentinel-1 data from 2014-2019"

doc$dataset$otherEntity[[2]] <- NULL #this otherEntity doesn't have a matching data file

#add attribute list to .nc file (saved as an otherEntity). attributes are listed in the README
out <- shiny_attributes(NULL, NULL)
new_attributes <- read.csv("/home/anchen/ticket #19545/my_attributes_table.csv")
new_factors <- read.csv("/home/anchen/ticket #19545/my_factors.csv")
new_custom_units <- read.csv("/home/anchen/ticket #19545/my_custom_units.csv")

#nevermind, I don't need custom units, so I need to go back in to edit the attributes
out <- shiny_attributes(NULL, new_attributes)
new_attributes2 <- read.csv("/home/anchen/ticket #19545/my_attributes_table2.csv")
new_factors2 <- read.csv("/home/anchen/ticket #19545/my_factors2.csv")

#Convert data.frames to EML using set_attributes - look at the documentation for that
new_attributeList <- set_attributes(attributes=new_attributes2, factors=new_factors2)
doc$dataset$otherEntity[[1]]$attributeList <- new_attributeList

#add physical sections and entityDescriptions to both files
physical1 <- pid_to_eml_physical(adc, pkg$data[[2]])
physical2 <- pid_to_eml_physical(adc, pkg$data[[1]])

doc$dataset$otherEntity[[1]]$physical <- physical1
doc$dataset$otherEntity[[2]]$physical <- physical2

doc$dataset$otherEntity[[1]]$entityDescription <- "Sentinel-1 firn aquifer map over Greenland"
doc$dataset$otherEntity[[2]]$entityDescription <- "README file for Sentinel-1 firn aquifer map over Greenland"

#add email address to creator and contact
old_creator <- doc$dataset$creator #save old creator section just in case
new_creator <- eml_creator(given_names="Isis", sur_name="Brangers", email="isis.brangers@kuleuven.be", userId = "https://orcid.org/0000-0002-5916-753X")
doc$dataset$creator <- new_creator

old_contact <- doc$dataset$contact #save old contact section just in case
new_contact <- eml_contact(given_names="Isis", sur_name="Brangers", email="isis.brangers@kuleuven.be", userId = "https://orcid.org/0000-0002-5916-753X")
doc$dataset$contact <- new_contact

#Validate and write EML
eml_validate(doc)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc, doc_path)

# Publish on test node to check
cn_staging <- CNode('STAGING')
adc_test <- getMNode(cn_staging,'urn:node:mnTestARCTIC')
publish_object(adc_test, doc_path, format_eml('2.1.1'))

#publish on the actual node
update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#now we get https://arcticdata.io/catalog/view/urn:uuid:b9969d36-1052-4d25-ba46-bc1df7268dd2

#after peer review, we need to fix some things 
#change title, superscript the km2 in the abstract, hyperlink at the end

pkg2 <- get_package(adc, 'resource_map_urn:uuid:b9969d36-1052-4d25-ba46-bc1df7268dd2', file_names = TRUE)
doc2 <- read_eml(getObject(adc, pkg2$metadata))

doc2$dataset$title <- "Firn aquifer map 1 kilometer (km) based on Sentinel-1 data, Greenland, 2014-2019"
doc2$dataset$abstract <- eml$abstract(para="Firn aquifers in Greenland store liquid water within the upper ice sheet and impact the hydrological system and the ice sheets contribution to sea level rise. This Sentinel-1 based product provides a first estimate of firn aquifer presence covering the full Greenland ice sheet at 1 kilometer (km) resolution. The detection of aquifers relies on a delay in the freezing of meltwater within the ﬁrn above the water table, causing a distinctive pattern in the radar backscatter. The total aquifer area is estimated at 54,800 square kilometers (km<superscript>2</superscript>). This data set can help improve our understanding of the role of firn aquifers in the complex ice sheet system. With continuity of Sentinel-1 ensured until 2030, our study lays a foundation for monitoring the future response of ﬁrn aquifers to climate change.

More information can be found in Brangers, I., Lievens, H., Miège, C., Demuzere, M., Brucker, L., and De Lannoy, G.J.M., Sentinel-1 detects firn aquifers in the Greenland Ice Sheet, Geophysical Research Letters, 2019. <ulink url='https://doi.org/10.1029/2019GL085192'> <citetitle>https://doi.org/10.1029/2019GL085192</citetitle> </ulink>")

doc2$dataset$methods$methodStep[[3]]$description$para <-"More information can be found in Brangers, I., Lievens, H., Miège, C., Demuzere, M., Brucker, L., and De Lannoy, G.J.M., Sentinel-1 detects firn aquifers in the Greenland Ice Sheet, Geophysical Research Letters, 2019. <ulink url='https://doi.org/10.1029/2019GL085192'> <citetitle>https://doi.org/10.1029/2019GL085192</citetitle> </ulink>"

#Validate and write EML
eml_validate(doc2)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc2, doc_path)

# Publish on test node to check
cn_staging <- CNode('STAGING')
adc_test <- getMNode(cn_staging,'urn:node:mnTestARCTIC')
publish_object(adc_test, doc_path, format_eml('2.1.1'))

#looks alright now
#publish on the actual node
update <- publish_update(adc, 
                         metadata_pid = pkg2$metadata,
                         resource_map_pid = pkg2$resource_map,
                         data_pids = pkg2$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#now we get https://arcticdata.io/catalog/view/urn:uuid:f43ed957-521c-4792-af4c-63199d8c0ee8

#set rights and access to the PI to ensure she can see the updated package
pkg3 <- get_package(adc, 'resource_map_urn:uuid:f43ed957-521c-4792-af4c-63199d8c0ee8', file_names = TRUE)
doc3 <- read_eml(getObject(adc, pkg3$metadata))
set_rights_and_access(adc, pids = pkg3$resource_map, subject = 'http://orcid.org/0000-0002-5916-753X')

#we got her approval, so let's publish with a DOI
update <- publish_update(adc, 
                         metadata_pid = pkg3$metadata,
                         resource_map_pid = pkg3$resource_map,
                         data_pids = pkg3$data,
                         use_doi=TRUE,
                         public = TRUE)
