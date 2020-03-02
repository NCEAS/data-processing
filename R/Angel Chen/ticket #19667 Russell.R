#ticket #19667: https://arcticdata.io/catalog/view/urn:uuid:6a64c7ad-aa08-424a-9cf9-8a5747436813
#formatted like this https://www-air.larc.nasa.gov/missions/etc/IcarttDataFormat.htm
#spending time to do https://learning.nceas.ucsb.edu/2020-02-RRCourse/data-cleaning-and-manipulation.html

#making attributes for Barrow_Spectra_Barrow_20080302_R1_thru20100305.ict
#grab the names of the columns using names() and make that a data frame (using data.frame()
#split the names into wavelength and frame number columns using separate()
#create descriptions of the attributes using a combination of mutate() and paste(), descriptions can match a format like "absorbance at x nm, frame y"
#add units, etc using mutate (unit can be dimensionless

#1878 total variables


pkg <- get_package(adc, 'resource_map_urn:uuid:6b36ffd1-98f3-415d-a1b7-822a67745a1b', file_names = TRUE)
doc <- read_eml(getObject(adc, pkg$metadata))

dat <- read.csv("~/ticket #19667 Russell/Barrow_Spectra_Barrow_20080302_R1_thru20100305.ict", skip = 1906)

names_df <- data.frame(names(dat))
names_vector <- as.vector(names_df[[1]])

descriptions1 <- c("number of seconds elapsed since 03/02/2008 in Coordinated Universal Time (UTC), recorded when a day began", "number of seconds elapsed since 03/02/2008 in Coordinated Universal Time (UTC), recorded when a day ended")

wavenumbers <- seq(400, 4000, by=1.92)
descriptions2 <- paste("absorbance at wavenumber", wavenumbers)

scales1 <- c("ratio", "ratio")
scales2 <- rep("ratio", 1876)

domains <- rep("numericDomain", 1878)

format_strings <- rep(NA, 1878)

definitions <- rep(NA, 1878)

units1 <- c("second", "second")
units2 <- rep("dimensionless" ,1876)

number_types <- rep("real", 1878)

missing_codes <- rep(NA, 1878)
missing_explanations <- rep(NA, 1878)

attributes <- data.frame(
  attributeName = names_vector,
  attributeDefinition = c(descriptions1, descriptions2),
  measurementScale = c(scales1, scales2),
  domain = domains,
  formatString = format_strings,
  definition = definitions,
  unit = c(units1, units2),
  numberType = number_types,
  missingValueCode = missing_codes,
  missingValueCodeExplanation = missing_explanations,
  
  stringsAsFactors = FALSE)
