################
#Issue #114: Commercial Crew Member Data
#Data Processing
#February 2018
#Sophia Tao
################



a <- read.csv('/home/stao/my-sasap/114_commercial_crew/Commercial Crew data 2012-2016.csv', 
              header = T, 
              stringsAsFactors = F, 
              na.strings = c("", "Not Available"))

# correct typos
typo <- which(a$Full.Name == ",ARL A. HIXSON")
a$Full.Name[typo] <- "CARL A. HIXSON"
typo2 <- which(a$First.Name == ",ARL")
a$First.Name[typo2] <- "CARL"
typo3 <- which(a$Full.Name == "2021682 R. J")
a$Full.Name[typo3] <- "R. J"
a$First.Name[a$First.Name == "2021682"] <- NA
typo4 <- which(a$Full.Name == "A;BERT R. ZAQREB")
a$Full.Name[typo4] <- "ALBERT R. ZAQREB"
typo5 <- which(a$First.Name == "A;BERT")
a$First.Name[typo5] <- "ALBERT"

# remove "?"
a$Full.Name <- gsub("[?]", "", a$Full.Name)
a$First.Name <- gsub("[?]", "", a$First.Name)
a$Last.Name <- gsub("[?]", "", a$Last.Name)

write.csv(a, '/home/stao/my-sasap/114_commercial_crew/Commercial_Crew_data_2012-2016_formatted.csv', row.names = F)


