##Neilson, 2017
##Megan Nguyen
##2018

#Clean files
IC_WeirQ <- read.csv("/home/mnguyen/Neilson/IC_WeirQ.csv", header = TRUE)
IC_WeirQ <- IC_WeirQ[,-3]
names(IC_WeirQ) <- c("Date_adt", "Discharge_cms")

Kup2AQ <- read.csv("/home/mnguyen/Neilson/Kup2AQ.csv", header = TRUE)
names(Kup2AQ)

ICKUP_Q <- read.csv("/home/mnguyen/Neilson/ICKUP_Q.csv", header = TRUE)
str(ICKUP_Q)
results <- grepl(pattern = "^\\d", ICKUP_Q$Date_adt)
delete <- c()
for(i in 1:length(ICKUP_Q$Date_adt)){
  if(results[i] == FALSE){
    delete <- c(delete, i)
  }
}

ICKUP_Q <- ICKUP_Q[-delete,]
names(ICKUP_Q)

Kup2TQ <- read.csv("/home/mnguyen/Neilson/Kup2TQ.csv", header = TRUE)

Kup3BQ <- read.csv("/home/mnguyen/Neilson/Kup3BQ.csv", header = TRUE)

Kup3TQ <- read.csv("/home/mnguyen/Neilson/Kup3TQ.csv", header = TRUE)

Kup4Q <- read.csv("/home/mnguyen/Neilson/Kup4Q.csv", header = TRUE)

Kup5Q <- read.csv("/home/mnguyen/Neilson/Kup5Q.csv", header = TRUE)
names(Kup5Q) <- c("Date_adt", "Discharge_cms")

Kup8Q <- read.csv("/home/mnguyen/Neilson/Kup8Q.csv", header = TRUE)
names(Kup8Q) <- c("Date_adt", "Discharge_cms")

Kup9Q <- read.csv("/home/mnguyen/Neilson/Kup9Q.csv", header = TRUE)
results <- grepl(pattern = "^\\d", Kup9Q$Date_adt)
delete <- c()
for(i in 1:length(Kup9Q$Date_adt)){
  if(results[i] == FALSE){
    delete <- c(delete, i)
  }
}

Kup9Q <- Kup9Q[-delete,]


files <- list(IC_WeirQ, ICKUP_Q, Kup2AQ, Kup2TQ, Kup3BQ, Kup3TQ, Kup4Q, Kup5Q, Kup8Q, Kup9Q)

#Separate date and time in order to edit

for(i in 1:length(files)){
  files[[i]] <- separate(data = files[[i]], col = Date_adt, into = c("Date", "Time"), sep = " ")
}

##Add ":00" at end of time
for(i in 1:length(files)){
  for(j in 1:length(files[[i]]$Time)){
    files[[i]]$Time[j] <- paste(files[[i]]$Time[j], ":00", sep = "")
  }
}

##Make hour two digits
for(i in 1:length(files)){
  for(j in 1:length(files[[i]]$Time)){
    pattern = "^\\d{2}[[:punct:]]"
    results <- grepl(pattern, files[[i]]$Time)
    if(results[j] == FALSE){
      files[[i]]$Time[j] <- paste("0", files[[i]]$Time[j], sep = "")
    }
  }
}

#Change date format
files[[1]]$Date <- as.Date(files[[1]]$Date, format = "%m/%d/%Y")
for(i in 1:length(files[[1]]$Date)){
if(isTRUE(files[[1]]$Date[i] < as.Date("2000-01-01"))){
  files[[1]]$Date[i] <- format(files[[1]]$Date[i], "20%y-%m-%d")
}else{
  files[[1]]$Date[i] <- format(files[[1]]$Date[i])
}
}

for(i in 2:length(files)){
    files[[i]]$Date <- as.Date(files[[i]]$Date, format = "%m/%d/%Y")
  }

#Combine date and time columns
for(i in 1:length(files)){
  files[[i]] <- unite(files[[i]], Date_adt, c(Date, Time), sep = " ")
}

#Format Date_adt
for(i in 1:length(files)){
  format(as.POSIXct(files[[i]]$Date_adt, tz = ""), format = "%Y-%m-%d %H:%M:%S")
}

#Data file editing complete!

#Reassign edited files to new file names
write.csv(files[[1]], file = "/home/mnguyen/Neilson/Neilson_IC_WeirQ.csv", row.names = FALSE) 
write.csv(files[[2]], file = "/home/mnguyen/Neilson/Neilson_ICKUP_Q.csv", row.names = FALSE) 
write.csv(files[[3]], file = "/home/mnguyen/Neilson/Neilson_Kup2AQ.csv", row.names = FALSE) 
write.csv(files[[4]], file = "/home/mnguyen/Neilson/Neilson_Kup2TQ.csv", row.names = FALSE) 
write.csv(files[[5]], file = "/home/mnguyen/Neilson/Neilson_Kup3BQ.csv", row.names = FALSE) 
write.csv(files[[6]], file = "/home/mnguyen/Neilson/Neilson_Kup3TQ.csv", row.names = FALSE) 
write.csv(files[[7]], file = "/home/mnguyen/Neilson/Neilson_Kup4Q.csv", row.names = FALSE) 
write.csv(files[[8]], file = "/home/mnguyen/Neilson/Neilson_Kup5Q.csv", row.names = FALSE) 
write.csv(files[[9]], file = "/home/mnguyen/Neilson/Neilson_Kup8Q.csv", row.names = FALSE) 
write.csv(files[[10]], file = "/home/mnguyen/Neilson/Neilson_Kup9Q.csv", row.names = FALSE) 


#Check if length and values the same
test <- read.csv("/home/mnguyen/Neilson/Neilson_Kup9Q.csv", header=TRUE)
test$Discharge_cms == Kup9Q$Discharge_cms
length(test$Discharge_cms) == length(Kup9Q$Discharge_cms)
#Good to go

#EML

eml <- read_eml("/home/mnguyen/Neilson/NeilsonMetadata.xml")

#create attributes table

library(RCurl)
script <- getURL("https://raw.githubusercontent.com/NCEAS/datamgmt/master/R/create_attributes_table.R", ssl.verifypeer = FALSE)
eval(parse(text = script))

library(rhandsontable)
library(shiny)

df <- read.csv("/home/mnguyen/Neilson/Neilson_ICKUP_Q.csv")
create_attributes_table(df)

attributes <- data.frame(
  attributeName = c('Date_adt','Discharge_cms'),
  domain = c('dateTimeDomain','numericDomain'),
  attributeDefinition = c('Date and time of sample','Sample discharge'),
  definition = c(NA,NA),
  measurementScale = c('dateTime','ratio'),
  formatString = c('YYYY-MM-DD hh:mm:ss',NA),
  numberType = c(NA,'real'),
  unit = c(NA,'centimeter'),
  missingValueCode = c(NA,NA),
  missingValueCodeExplanation = c(NA,NA),
  stringsAsFactors = FALSE)

attributeList1 <- set_attributes(attributes)

#Create new datapids

data_pathIC_WeirQ <- "/home/mnguyen/Neilson/Neilson_IC_WeirQ.csv"
data_pathICKUP_Q <- "/home/mnguyen/Neilson/Neilson_ICKUP_Q.csv"
data_pathKup2AQ <- "/home/mnguyen/Neilson/Neilson_Kup2AQ.csv"
data_pathKup2TQ <- "/home/mnguyen/Neilson/Neilson_Kup2TQ.csv"
data_pathKup3BQ <- "/home/mnguyen/Neilson/Neilson_Kup3BQ.csv"
data_pathKup3TQ <- "/home/mnguyen/Neilson/Neilson_Kup3TQ.csv"
data_pathKup4Q <- "/home/mnguyen/Neilson/Neilson_Kup4Q.csv"
data_pathKup5Q <- "/home/mnguyen/Neilson/Neilson_Kup5Q.csv"
data_pathKup8Q <- "/home/mnguyen/Neilson/Neilson_Kup8Q.csv"
data_pathKup9Q <- "/home/mnguyen/Neilson/Neilson_Kup9Q.csv"

data_pidIC_WeirQ <- publish_object(mn, data_pathIC_WeirQ, format_id = "text/csv")
data_pidICKUP_Q <- publish_object(mn, data_pathICKUP_Q, format_id = "text/csv")
data_pidKup2AQ <- publish_object(mn, data_pathKup2AQ, format_id = "text/csv")
data_pidKup2TQ <- publish_object(mn, data_pathKup2TQ, format_id = "text/csv")
data_pidKup3BQ <- publish_object(mn, data_pathKup3BQ, format_id = "text/csv")
data_pidKup3TQ <- publish_object(mn, data_pathKup3TQ, format_id = "text/csv")
data_pidKup4Q <- publish_object(mn, data_pathKup4Q, format_id = "text/csv")
data_pidKup5Q <- publish_object(mn, data_pathKup5Q, format_id = "text/csv")
data_pidKup8Q <- publish_object(mn, data_pathKup8Q, format_id = "text/csv")
data_pidKup9Q <- publish_object(mn, data_pathKup9Q, format_id = "text/csv")

#physicals
physicalIC_WeirQ <- pid_to_eml_physical(mn, data_pidIC_WeirQ)
physicalICKUP_Q <- pid_to_eml_physical(mn, data_pidICKUP_Q)
physicalKup2AQ <- pid_to_eml_physical(mn, data_pidKup2AQ)
physicalKup2TQ <- pid_to_eml_physical(mn, data_pidKup2TQ)
physicalKup3BQ <- pid_to_eml_physical(mn, data_pidKup3BQ)
physicalKup3TQ <- pid_to_eml_physical(mn, data_pidKup3TQ)
physicalKup4Q <- pid_to_eml_physical(mn, data_pidKup4Q)
physicalKup5Q <- pid_to_eml_physical(mn, data_pidKup5Q)
physicalKup8Q <- pid_to_eml_physical(mn, data_pidKup8Q)
physicalKup9Q <- pid_to_eml_physical(mn, data_pidKup9Q)

#dataTables
dt_IC_Weir <- new('dataTable',
           entityName = "IC_Weir.csv",
           entityDescription = "Imnavait Creek at long term weir",
           physical = physicalIC_WeirQ,
           attributeList = attributeList1)

dt_IC_Q <- new('dataTable',
                  entityName = "IC_Q.csv",
                  entityDescription = "Imnavait Creek at mouth" ,
                  physical = physicalICKUP_Q,
                  attributeList = attributeList1)
dt_KupATR <- new('dataTable',
               entityName = "KupATR.csv",
               entityDescription = "Kuparuk River above Toolik River confluence" ,
               physical = physicalKup2AQ,
               attributeList = attributeList1)

dt_KupTR <- new('dataTable',
                 entityName = "KupTR.csv",
                 entityDescription = "Toolik River at mouth of Kuparuk River" ,
                 physical = physicalKup2TQ,
                 attributeList = attributeList1)
dt_KupBWH <- new('dataTable',
                entityName = "KupBWH.csv",
                entityDescription = "Kuparuk River below White Hills creek confluence" ,
                physical = physicalKup3BQ,
                attributeList = attributeList1)
dt_KupBOK <- new('dataTable',
                 entityName = "KupBOK.csv",
                 entityDescription = "Kuparuk River below Old Kuparuk" ,
                 physical = physicalKup3TQ,
                 attributeList = attributeList1)
dt_KupBA <- new('dataTable',
                 entityName = "KupBA.csv",
                 entityDescription = "Kuparuk River below aufeis" ,
                 physical = physicalKup4Q,
                 attributeList = attributeList1)

dt_KupAA <- new('dataTable',
                entityName = "KupAA.csv",
                entityDescription = "Kuparuk River above aufeis" ,
                physical = physicalKup5Q,
                attributeList = attributeList1)
dt_KupBIC <- new('dataTable',
                entityName = "KupBIC.csv",
                entityDescription = "Kuparuk River below Imnavait Creek confluence" ,
                physical = physicalKup8Q,
                attributeList = attributeList1)

dt_KupRoadQ <- new('dataTable',
                 entityName = "KupRoadQ.csv",
                 entityDescription = "Kuparuk River above Dalton Highway" ,
                 physical = physicalKup9Q,
                 attributeList = attributeList1)

eml@dataset@dataTable <- c(dt_IC_Q, dt_IC_Weir, dt_KupBWH, dt_KupBOK, dt_KupAA, dt_KupBA, dt_KupATR, dt_KupTR, dt_KupBIC, dt_KupRoadQ)

#Edit names
eml@dataset@dataTable@.Data[[10]]@entityName
eml@dataset@dataTable@.Data[[10]]@physical@.Data[[1]]@objectName <- "KupRoadQ.csv"

#Validate and write eml
eml_validate(eml)
write_eml(eml, "/home/mnguyen/Neilson/Neilson_Metadata.xml")

#Update package
dataPid <- c(data_pidIC_WeirQ, data_pidICKUP_Q , data_pidKup2AQ , data_pidKup2TQ , data_pidKup3BQ, data_pidKup3TQ , data_pidKup4Q , data_pidKup5Q , data_pidKup8Q , data_pidKup9Q) 

ids <- get_package(mn, "urn:uuid:6674785c-f684-4cfc-922e-35630d18ed1a")
publish_update(mn,
               metadata_pid = ids$metadata,
               resource_map_pid = ids$resource_map,
               metadata_path = "/home/mnguyen/Neilson/Neilson_Metadata.xml",
               data_pids = ids$data,
               check_first = TRUE,
               use_doi = TRUE,
               public = TRUE)

#Edit system metadata
system <- getSystemMetadata(mn, "doi:10.18739/A2K87V")
system@fileName <- "KupRoadQ.csv"
updateSystemMetadata(mn, "urn:uuid:955e80f1-f1d9-4bee-8cf9-2393bcb9ece6", system)

set_rights_and_access(mn,
                      pids = c(ids$metadata, ids$data, ids$resource_map),
                      subject = "http://orcid.org/0000-0001-8829-5082",
                      permissions = c('read', 'write', 'changePermission'))
system@accessPolicy
