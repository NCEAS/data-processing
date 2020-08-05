#ticket #20492 Norman
#Human dataset:
#https://arcticdata.io/catalog/#view/urn:uuid:c715fe12-6c05-4c27-8d00-b9c0c536c54b

pkg <- get_package(adc, 'resource_map_urn:uuid:2a957ad3-1c0f-44e9-b79d-5ea2a2ed76bf', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")

id_new <- publish_object(
  adc,
  path = "~/ticket #20492 Norman/CEBP_HumanGeneticData_Summary.csv",
  format_id = "text/csv",
  public = FALSE
)

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = id_new,
                         public = FALSE)
#https://arcticdata.io/catalog/view/urn%3Auuid%3Ab7b1a184-4f25-4c7f-b66d-240e2dfcd348

pkg <- get_package(adc, 'resource_map_urn:uuid:b7b1a184-4f25-4c7f-b66d-240e2dfcd348', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")

doc <- eml_add_publisher(doc)
doc <- eml_add_entity_system(doc)

CEBP_HumanGeneticData_Summary <- read_csv("~/ticket #20492 Norman/CEBP_HumanGeneticData_Summary.csv")
out <- shiny_attributes(CEBP_HumanGeneticData_Summary, NULL)

doc$dataset$otherEntity <- NULL

physical <- pid_to_eml_physical(adc, "urn:uuid:c17ef00e-7202-49b5-aa8e-a51afc999f41")

Attributes_Table <- read_csv("~/ticket #20492 Norman/Attributes_Table.csv")
attributeList <- set_attributes(attributes=Attributes_Table)

dataTable <- eml$dataTable(entityName = "CEBP_HumanGeneticData_Summary.csv",
                           entityDescription = "Summary of the genetic data collected from individuals",
                           physical = physical,
                           attributeList = attributeList
)
doc$dataset$dataTable[[1]] <- dataTable


doc$dataset$contact[[3]] <- NULL

doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$westBoundingCoordinate <- "156.51550"
doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$eastBoundingCoordinate <- "156.64143"

doc$dataset$project <- eml_nsf_to_project("1523059")

eml_validate(doc)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc, doc_path)

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#https://arcticdata.io/catalog/view/urn%3Auuid%3Afff9acca-9e4c-481a-8186-678892ca5a6e

pkg <- get_package(adc, 'resource_map_urn:uuid:fff9acca-9e4c-481a-8186-678892ca5a6e', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")


doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$westBoundingCoordinate <- "-156.51550"
doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$eastBoundingCoordinate <- "-156.64143"

eml_validate(doc)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc, doc_path)

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#https://arcticdata.io/catalog/view/urn%3Auuid%3A8b86d811-2b0e-48ae-9f48-7a57d67eccfe

pkg <- get_package(adc, 'resource_map_urn:uuid:8b86d811-2b0e-48ae-9f48-7a57d67eccfe', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")

doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$northBoundingCoordinate <- "69.057876"
doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$southBoundingCoordinate <- "69.057876"
doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$westBoundingCoordinate <- "-152.862827"
doc$dataset$coverage$geographicCoverage[[2]]$boundingCoordinates$eastBoundingCoordinate <- "-152.862827"

eml_validate(doc)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc, doc_path)

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#https://arcticdata.io/catalog/view/urn:uuid:5b6546c3-b8a6-420f-b1ba-1422c4479f6b

#https://arcticdata.io/catalog/view/urn%3Auuid%3Adda6d1ed-b817-42ad-9c23-a33b01c59a88

pkg <- get_package(adc, 'resource_map_urn:uuid:160fbcbf-92af-4d3b-8ebf-6092a4435a27', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")

set_rights_and_access(adc, pids = unlist(pkg), subject = 'http://orcid.org/0000-0002-5718-6032')

doc$dataset$title <- "Cape Espenberg Birnirk Project (CEBP) human mitogenome summary analysis (2016-2019)"

eml_validate(doc)
doc_path <- file.path(tempdir(), 'science_metadata.xml')
write_eml(doc, doc_path)

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         metadata_path = doc_path, 
                         public = FALSE)
#https://arcticdata.io/catalog/view/urn:uuid:ec4f2c29-bdb2-4927-b364-20f2d6ead811

pkg <- get_package(adc, 'resource_map_urn:uuid:ec4f2c29-bdb2-4927-b364-20f2d6ead811', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))
emld::eml_version("eml-2.1.1")

update <- publish_update(adc, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = pkg$data,
                         use_doi=TRUE,
                         public = TRUE)
#https://arcticdata.io/catalog/view/doi%3A10.18739%2FA2NC5SD2M

datamgmt::categorize_dataset("doi:10.18739/A2CZ32589", c("archaeology","anthropology"), "Angel")
datamgmt::categorize_dataset("doi:10.18739/A2NC5SD2M", c("archaeology","anthropology"), "Angel")

