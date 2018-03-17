################
#Issue #199: CFEC Basic Information Table (BIT)
#Data Submission
#February 2018
#Sophia Tao
################



# load libraries
library(arcticdatautils)
library(dataone)
library(EML)
library(XML)
library(digest)
library(shiny)
library(rhandsontable)

# set environment 
cn <- CNode('PROD')
mn <- getMNode(cn,'urn:node:KNB')
# set authentication token



# publish data object
bit_path <- '/home/stao/my-sasap/199_CFEC/BIT.csv'
# bitID <- publish_object(mn, bit_path, format_id = 'text/csv')
bitID <- "urn:uuid:aa308395-54f6-412c-9ca3-0112a1d67938" 



# edit EML
eml_path <- '/home/stao/my-sasap/199_CFEC/CFEC_BIT.xml'
eml <- read_eml(eml_path)

# add SASAP project info
source('~/sasap-data/data-submission/Helpers/SasapProjectCreator.R')
eml@dataset@project <- sasap_project() 

# generate attribute table
attributes1 <- data.frame(
    attributeName = c('Fishery','Fishery.Description','Year','Resident.Permanent.Permits.Renewed','Nonresident.Permanent.Permits.Renewed','Total.Permanent.Permits.Renewed','Resident.Interim.Permits.Issued','Nonresident.Interim.Permits.Issued','Total.Interim.Permits.Issued','Resident.Permits.Issued.Renewed','Nonresident.Permits.Issued.Renewed','Total.Permits.Issued.Renewed','Resident.Total.Permits.Fished','Nonresident.Total.Permits.Fished','Total.Permits.Fished','Resident.Total.Pounds','Nonresident.Total.Pounds','Total.Pounds','Resident.Average.Pounds','Nonresident.Average.Pounds','Average.Pounds','Resident.Total.Earnings','Nonresident.Total.Earnings','Total.Earnings','Resident.Average.Earnings','Nonresident.Average.Earnings','Average.Earnings','Average.Permit.Price'),
    domain = c('textDomain','textDomain','dateTimeDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain','numericDomain'),
    attributeDefinition = c('fishery code comprises of a species code, a gear code, and an area code','description for fishery code','year pertaining to the correlating information','number of permanent permits renewed by residents','number of permanent permits renewed by nonresidents','total number of permanent permits renewed','number of interim permits issued to residents','number of interim permits issued to nonresidents','total number of interim permits issued','number of permits issued to or renewed by residents','number of permits issued to or renewed by nonresidents','total number of permits issued or renewed','number of permits used to fish by residents','number of permits used to fish by nonresidents','total number of permits used to fish overall','total pounds of fish landed by residents','total pounds of fish landed by nonresidents','total pounds of fish landed overall','average pounds of fish landed by residents','average pounds of fish landed by nonresidents','average pounds of fish landed overall','total earnings of residents','total earnings of nonresidents','total earnings overall','average earnings of residents','average earnings of nonresidents','average earnings overall','average permit price'),
    definition = c('fishery code comprises of a species code, a gear code, and an area code','description for fishery code',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
    measurementScale = c('nominal','nominal','dateTime','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio','ratio'),
    formatString = c(NA,NA,'YYYY',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
    numberType = c(NA,NA,NA,'whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole','whole'),
    unit = c(NA,NA,NA,'number','number','number','number','number','number','number','number','number','number','number','number','pound','pound','pound','pound','pound','pound','dimensionless','dimensionless','dimensionless','dimensionless','dimensionless','dimensionless','dimensionless'),
    missingValueCode = c('NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA'),
    missingValueCodeExplanation = c('information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported','information not provided/reported'),
    stringsAsFactors = FALSE)
attributeList1 <- set_attributes(attributes1)

# generate physical
physical1 <- pid_to_eml_physical(mn, pkg$data)

# generate dataTable
dataTable1 <- new('dataTable',
                  entityName = 'BIT.csv',
                  entityDescription = 'Slightly modified csv file of CFEC Basic Information Table (BIT) including number of permits, total pounds landed, total estimated gross earnings, and average estimated gross earnings per permit for each permit fishery by year, from 1975 to 2016',
                  physical = c(physical1[[1]]),
                  attributeList = attributeList1)

# add dataTable to EML
eml@dataset@dataTable <- c(dataTable1)

# change geographic coverage
geocov1 <- new("geographicCoverage", geographicDescription = "The geographic region includes all commercial fishery management areas in Alaska as well as all areas of residence of permit holders.",
               boundingCoordinates = new("boundingCoordinates", 
                                         northBoundingCoordinate = new("northBoundingCoordinate", 72),
                                         eastBoundingCoordinate = new("eastBoundingCoordinate", -129),
                                         southBoundingCoordinate = new("southBoundingCoordinate", 51),
                                         westBoundingCoordinate =  new("westBoundingCoordinate", -179)))
eml@dataset@coverage@geographicCoverage <- c(geocov1)

# change abstract
eml@dataset@abstract <- new("abstract", .Data = "The Commercial Fisheries Entry Commission (CFEC) is an independent, autonomous agency of the State of Alaska which regulates entry into Alaska's commercial fisheries. The CFEC is committed to promoting conservation and sustained-yield management of Alaska's unique fishery resources and boosting economic stability among fishermen and their dependents. The CFEC is responsible for leasing all commercial fishing permits including permits for limited-entry fisheries. Limited-entry fisheries include all state salmon fisheries, most herring fisheries, and various other fisheries. The number of permits, total pounds landed, total estimated gross earnings, and average estimated gross earnings per permit are provided for each permit fishery by year, from 1975-2016. Information is subtotaled by resident type. Estimated permit values at year-end are shown for limited fisheries with a sufficient number of permit sales. The data included in this package has been modified slightly from what was provided by CFEC: currency columns were reformatted as numeric, and an empty column was removed.")

# write and validate EML
write_eml(eml, eml_path)
eml_validate(eml_path)



# create resource map
# rm <- create_resource_map(mn, "knb.92196.1", bitID)
rm <- update_resource_map(mn, "resource_map_urn:uuid:ac8a0a24-79f1-47d3-92be-113132808913", "knb.92196.4", pkg$data, public = T, check_first = T)

# get package
pkg <- get_package(mn, NEWEST, file_names = T)

# set rights & access
set_rights_and_access(mn, 
                      c(pkg$metadata, pkg$data, pkg$resource_map), 
                      subject = 'CN=SASAP,DC=dataone,DC=org',
                      permissions = c('read', 'write', 'changePermission'))

# update package
publish_update(mn,
               metadata_pid = pkg$metadata, 
               resource_map_pid = pkg$resource_map,
               metadata_path = eml_path, 
               data_pid = pkg$data, 
               check_first = T,
               use_doi = F,
               public = T)

NEWEST <- "urn:uuid:a6a4b230-799c-42ea-b331-62a2b1013ee4"





# accidentally published another data package with the same metadata.....
# publish metadata
# metadata <- publish_object(mn, eml_path, format_id = format_eml())
metadata <- "urn:uuid:d4c2f2df-24db-4863-8f7c-734dfb087059"
remove_public_read(mn, metadata)

# use sysmeta to 'obselete' duplicated data package
get_all_versions(mn, pkg$metadata)
old <- "knb.92196.1"
sysmeta <- getSystemMetadata(mn, old)
sysmeta@obsoletes = metadata
updateSystemMetadata(mn, old, sysmeta)

sysmetaOB <- getSystemMetadata(mn, metadata)
sysmetaOB@obsoletedBy = old
updateSystemMetadata(mn, metadata, sysmetaOB)

# set public read
set_public_read(mn, c(pkg$data, pkg$metadata, pkg$resource_map))


