################
#Issue #114: Commercial Crew Member Data
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


# publish file
# formatted <- publish_object(mn, '/home/stao/my-sasap/114_commercial_crew/Commercial_Crew_data_2012-2017_formatted.csv', format_id = 'text/csv')
formatted <- "urn:uuid:f8a813e8-4937-40ed-9312-ddb177a6469b"



# edit EMl
eml_path <- '/home/stao/my-sasap/114_commercial_crew/CommercialCrewEML.xml'
eml <- read_eml(eml_path)

# add SASAP project info
source('~/sasap-data/data-submission/Helpers/SasapProjectCreator.R')
eml@dataset@project <- sasap_project() 

# add intellectual rights
eml@dataset@intellectualRights <- new('intellectualRights',
                                      .Data = "CFEC retains intellectual property rights to data collected by or for CFEC. Any dissemination of the data must credit CFEC as the source, with a disclaimer that exonerates the department for errors or deficiencies in reproduction, subsequent analysis, or interpretation. Please see http://www.adfg.alaska.gov/index.cfm?adfg=home.copyright for further information.")

# change abstract
eml@dataset@abstract <- new('abstract',
                            .Data = "The Commercial Fisheries Entry Commission (CFEC) is an independent, autonomous agency of the State of Alaska which regulates entry into Alaska's commercial fisheries. The CFEC is committed to promoting conservation and sustained-yield management of Alaska's unique fishery resources and boosting economic stability among fishermen and their dependents. The CFEC is responsible for leasing all commercial fishing permits including permits for limited-entry fisheries. Limited-entry fisheries include all state salmon fisheries, most herring fisheries, and various other fisheries. A person engaged in commercial fishing is considered a commercial fisherman and must hold a commercial fishing license. Commercial fisherman means an individual who fishes commercially for, takes, or attempts to take fish, shellfish, or other fishery resources of the state by any means, and includes every individual aboard a boat operated for fishing purposes, or in a fishing operation, who participates directly or indirectly in the taking of these raw fishery products, whether participation is on shares or as an employee or otherwise; however, this definition does not apply to anyone aboard a licensed vessel as a visitor or guest who does not directly or indirectly participate in the taking; and the term 'commercial fisherman' includes the crews of tenders, processors, catcher processors or other floating craft used in transporting fish. Persons who need to obtain a crew member license include persons handling fishing gear, the cook, the engineer and any crewmembers who assist at all in maintenance, navigation, docking and operation of the vessel (including taking aboard fish from tenders or catcher vessels).
This dataset includes information about commercial crew members including license type, number, year, crew member name, and residence. The data included in this package has been modified slightly from what was provided by CFEC: typos with names were corrected and special characters were removed.")

# create attributes table
attributes1 <- data.frame(
    attributeName = c('License.Year','Full.Name','First.Name','Middle.Initial','Last.Name','Gender','Residency','Mailing.City','Mailing.Country','Mailing.State','Mailing.Street1','Mailing.Street2','Mailing.Zip','Vendor','Type.Description','License.Number'),
    domain = c('dateTimeDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain','textDomain'),
    attributeDefinition = c('year of crew member license','full name of crew member','first name of crew member','middle initial of crew member','last name of crew member','gender of crew member','residency status of crew member','city of mailing address','country of mailing address','state of mailing address','street 1 of mailing address','street 2 of mailing address','zip code of mailing address','vendor','crew member license type description','crew member license number'),
    definition = c(NA,'full name of crew member','first name of crew member','middle initial of crew member','last name of crew member','gender of crew member','residency status of crew member','city of mailing address','country of mailing address','state of mailing address','street 1 of mailing address','street 2 of mailing address','zip code of mailing address','vendor','crew member license type description; For a period, they allowed 7 day crewmember licenses in the hopes of spurring a “dude fishing” industry. While optimistic, the industry never appeared, but savvy fishermen realized that for fisheries that are prosecuted over only a few weeks (i.e., Bristol Bay Salmon) it was cheaper to buy a few 7 day licenses than an annual license. This loophole was closed last year.','crew member license number'),
    measurementScale = c('dateTime','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal','nominal'),
    formatString = c('YYYY',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
    numberType = c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
    unit = c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
    missingValueCode = c(NA,'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA',NA,NA),
    missingValueCodeExplanation = c(NA,'The majority of licenses come in from vendors on paper forms. These forms are data entered by data entry crew. If they can’t read a name they either type a question mark or leave it blank. As a consequence, these data are rife with errors.','information not provided/recorded','crew member does not have a middle name, or information not provided/recorded','information not provided/recorded','gender is not required','information not provided/recorded','information not provided/recorded','information not provided/recorded','information not provided/recorded','information not provided/recorded','information not provided/recorded','information not provided/recorded','information not provided/recorded',NA,NA),
    stringsAsFactors = FALSE)
attributeList1 <- set_attributes(attributes1)

# generate physical
phys <- pid_to_eml_physical(mn, formatted)

# generate dataTables
dataTable1 <- new('dataTable',
                  entityName = 'Commercial_Crew_data_2012-2017_formatted.csv',
                  physical = phys,
                  attributeList = attributeList1)

# add dataTable into EML
eml@dataset@dataTable <- c(dataTable1)


# write and validate EML
write_eml(eml, eml_path)
eml_validate(eml_path)



# create resource map
# rm <- create_resource_map(mn, 'knb.92220.2', data_pids = formatted)
rm <- "resource_map_urn:uuid:cefd2b8e-096b-437a-926d-451a1dae7f2d"

# get package
pkg <- get_package(mn, NEWEST, file_names = T)
    
# update package
publish_update(mn,
               metadata_pid = pkg$metadata, 
               resource_map_pid = pkg$resource_map,
               metadata_path = eml_path, 
               data_pid = pkg$data, 
               check_first = T,
               use_doi = F,
               public = F)

# set rights and access
set_rights_and_access(mn, c(pkg$metadata, pkg$data, pkg$resource_map), 'CN=SASAP,DC=dataone,DC=org', permissions = c('read', 'write', 'changePermission'))

NEWEST <- "urn:uuid:107e0084-8d30-4601-8869-19211b34f967"


# change file name through sysmeta
sysmeta1 <- getSystemMetadata(mn, pkg$data)
sysmeta1@fileName <- 'Commercial_Crew_data_2012-2017_formatted.csv'
updateSystemMetadata(mn, pkg$data, sysmeta1)


# qa data and attributes tables
qa_package(mn, NEWEST, readData = F)
