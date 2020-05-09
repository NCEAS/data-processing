################
#Issue #199: CFEC Basic Information Table (BIT)
#Data Processing
#February 2018
#Sophia Tao
################



# read in
bit <- read.csv("/home/stao/my-sasap/199_CFEC/BIT.csv", header = T)

# delete unnecessary column
bit$X....Preliminary <- NULL

# replace "." with "NA"
bit$Average.Permit.Price[bit$Average.Permit.Price=="."] <- NA
bit$Total.Permits.Fished[bit$Total.Permits.Fished=="."] <- NA
bit$Resident.Total.Pounds[bit$Resident.Total.Pounds=="."] <- NA
bit$Nonresident.Total.Pounds[bit$Nonresident.Total.Pounds=="."] <- NA
bit$Total.Pounds[bit$Total.Pounds=="."] <- NA
bit$Resident.Average.Pounds[bit$Resident.Average.Pounds=="."] <- NA
bit$Nonresident.Average.Pounds[bit$Nonresident.Average.Pounds=="."] <- NA
bit$Average.Pounds[bit$Average.Pounds=="."] <- NA
bit$Resident.Total.Earnings[bit$Resident.Total.Earnings=="."] <- NA
bit$Nonresident.Total.Earnings[bit$Nonresident.Total.Earnings=="."] <- NA
bit$Total.Earnings[bit$Total.Earnings=="."] <- NA
bit$Resident.Average.Earnings[bit$Resident.Average.Earnings=="."] <- NA
bit$Nonresident.Average.Earnings[bit$Nonresident.Average.Earnings=="."] <- NA
bit$Average.Earnings[bit$Average.Earnings=="."] <- NA
bit$Average.Permit.Price[bit$Average.Permit.Price=="."] <- NA

# remove commas
bit$Resident.Interim.Permits.Issued <- gsub(",", "", bit$Resident.Interim.Permits.Issued)
bit$Resident.Interim.Permits.Issued <- gsub(",", "", bit$Resident.Interim.Permits.Issued)
bit$Nonresident.Interim.Permits.Issued <- gsub(",", "", bit$Nonresident.Interim.Permits.Issued)
bit$Total.Interim.Permits.Issued <- gsub(",", "", bit$Total.Interim.Permits.Issued)
bit$Resident.Permits.Issued.Renewed <- gsub(",", "", bit$Resident.Permits.Issued.Renewed)
bit$Nonresident.Permits.Issued.Renewed <- gsub(",", "", bit$Nonresident.Permits.Issued.Renewed)
bit$Total.Permits.Issued.Renewed <- gsub(",", "", bit$Total.Permits.Issued.Renewed)
bit$Resident.Total.Permits.Fished <- gsub(",", "", bit$Resident.Total.Permits.Fished)
bit$Total.Permits.Fished <- gsub(",", "", bit$Total.Permits.Fished)
bit$Resident.Total.Pounds <- gsub(",", "", bit$Resident.Total.Pounds)
bit$Nonresident.Total.Pounds <- gsub(",", "", bit$Nonresident.Total.Pounds)
bit$Total.Pounds <- gsub(",", "", bit$Total.Pounds)
bit$Resident.Average.Pounds <- gsub(",", "", bit$Resident.Average.Pounds)
bit$Nonresident.Average.Pounds <- gsub(",", "", bit$Nonresident.Average.Pounds)
bit$Average.Pounds <- gsub(",", "", bit$Average.Pounds)
bit$Resident.Total.Earnings <- gsub(",", "", bit$Resident.Total.Earnings)
bit$Nonresident.Total.Earnings <- gsub(",", "", bit$Nonresident.Total.Earnings)
bit$Total.Earnings <- gsub(",", "", bit$Total.Earnings)
bit$Resident.Average.Earnings <- gsub(",", "", bit$Resident.Average.Earnings)
bit$Nonresident.Average.Earnings <- gsub(",", "", bit$Nonresident.Average.Earnings)
bit$Average.Earnings <- gsub(",", "", bit$Average.Earnings)

# remove "$"
bit$Resident.Total.Earnings <- gsub("[$]", "", bit$Resident.Total.Earnings)
bit$Nonresident.Total.Earnings <- gsub("[$]", "", bit$Nonresident.Total.Earnings)
bit$Total.Earnings <- gsub("[$]", "", bit$Total.Earnings)
bit$Resident.Average.Earnings <- gsub("[$]", "", bit$Resident.Average.Earnings)
bit$Nonresident.Average.Earnings <- gsub("[$]", "", bit$Nonresident.Average.Earnings)
bit$Average.Earnings <- gsub("[$]", "", bit$Average.Earnings)

# export
write.csv(bit, "/home/stao/my-sasap/199_CFEC/BIT.csv", row.names = F)


