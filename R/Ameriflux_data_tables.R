##############################################################################
# Adam Reevesman
# March 19, 2018

# This script defines the function "attribute_table" which
# generates an attribute table for any one of the csvs in the Ameriflux data at
# https://drive.google.com/drive/folders/1g0TuYt1cJEuRxe5tXoUjJ1pSneNFbPXN

# The first step is to read in each of the csvs and my modified version of
# the attribute metadata from
# https://docs.google.com/spreadsheets/d/1K-C7DahQ80KifW1NAbFaU-VusLZe4eAPHqhBl4t_y9s/edit#gid=1340082892

# the attribute metadata is read into a dataframe as definitions
# the csvs are read in as dataframes called data1, data2, ... , data12

# The function "attribute_table" takes in 
# the data dataframe and definitions dataframe to produce an attribute table for the data
# It calls indivual functions that define each column of the attribute table

# The resulting attribute table will not be perfect...
# The measurement scales, number types, and missing value information will need
# to be adjusted manually
# Any custom units that exist in the "unit" column will need to be defined

# An example of the implimentation exists at the very end of this script

##############################################################################

library(stringr)


definitions <- read.csv('/home/reevesman/Ameriflux/attribute_function/definitions.csv',
                        stringsAsFactors = FALSE)

data_path_1 <- '/home/reevesman/Ameriflux/AMF_US-Ivo/AMF_US-Ivo_BASE_HH_2-1.csv'
data_path_2 <- '/home/reevesman/Ameriflux/AMF_US-ICt/AMF_US-ICt_BASE_HH_2-1.csv'
data_path_3 <- '/home/reevesman/Ameriflux/AMF_US-ICs/AMF_US-ICs_BASE_HH_2-1.csv'
data_path_4 <- '/home/reevesman/Ameriflux/AMF_US-ICh/AMF_US-ICh_BASE_HH_2-1.csv'
data_path_5 <- '/home/reevesman/Ameriflux/AMF_US-EML/AMF_US-EML_BASE_HH_1-4.csv'
data_path_6 <- '/home/reevesman/Ameriflux/AMF_US-Brw/AMF_US-Brw_BASE_HH_2-1.csv'
data_path_7 <- '/home/reevesman/Ameriflux/AMF_US-Atq/AMF_US-Atq_BASE_HH_1-1.csv'
data_path_8 <- '/home/reevesman/Ameriflux/AMF_CA-Qfo/AMF_CA-Qfo_BASE_HH_1-1.csv'
data_path_9 <- '/home/reevesman/Ameriflux/AMF_CA-Ojp/AMF_CA-Ojp_BASE_HH_1-1.csv'
data_path_10 <- '/home/reevesman/Ameriflux/AMF_CA-Oas/AMF_CA-Oas_BASE_HH_1-1.csv'
data_path_11 <- '/home/reevesman/Ameriflux/AMF_CA-Man/AMF_CA-Man_BASE_HH_2-1.csv'
data_path_12 <- '/home/reevesman/Ameriflux/AMF_CA-Gro/AMF_CA-Gro_BASE_HH_1-1.csv'


##############################################################################

#function definition for attribute_definitions
  #inputs:
    #data: a dataframe with attributes to define
    #definitions: dataframe in the style of definitions.csv
  #output: a vector of attribute definitions to be used in attribute table

##############################################################################

attribute_definitions <- function(data_path, definitions){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  #potential qualifiers
  int_qualifiers <- c('_1','_2','_3','_4','_5','_6','_7','_8','_9')
  char_qualifiers <- c('_PI','_QC','_IU','_SD','_F','_R','_A')
  qualifiers <- c(int_qualifiers, char_qualifiers)
  
  attributes <- colnames(data)
  
  #will be vector of attribute definitions
  defs <- vector(mode = 'character', length = length(attributes))
  
  #i will be index at which to populate defs
  i <- 1
  #for each attribute
  for (att in attributes){
    
    #if the attribute has one of the attached qualifiers
    #figure out which qualifier it is
    #set att to the regular attribute name (w/out qualifier)
    #if it is an int_qualifier, set it to '_#' so its definition can be found in "definitions"
    #get extra definition of qualifier to paste onto regular definition later
    #set a flag that this attribute includes a qualifier
    
    if (sum(sapply(qualifiers, grepl, x = att)) > 0){
      
      qualifier_indeces <- which(sapply(qualifiers, grepl, x = att) == TRUE)
      att_qualifiers <- qualifiers[qualifier_indeces]
      
      for (j in 1:length(att_qualifiers)){
        att <- gsub(att_qualifiers[j], replacement = '', x = att)
      }
      
      if (att_qualifiers[1] %in% int_qualifiers){
        att_qualifiers <- '_#'
      }
      
      #using paste in case there are multiple qualifiers
      #in reality, only needed for _PI_F
      #same reason for using for loop below (length(att_qualifiers) should be 1 or 2)
      extra <- paste(definitions[which(definitions$uniqueAttributeLabel %in% att_qualifiers), 
                                 'uniqueAttributeDefinition'],
                     collapse = '; ')
      
      QUALIFIERS_EXIST <- TRUE
    }
    
    else {
      QUALIFIERS_EXIST <- FALSE
    }
    
    #if the attribute (with potential qualifiers removed) 
    #is not defined in definitions, there is a problem
    
    if (!(att %in% definitions$uniqueAttributeLabel)){
      print(paste('Error: The attribute: ', 
                  att, 
                  ' is not defined in the definitions dataframe.',
                  sep = ''))
    }
    
    #if there were qualifiers, include the extra part of the definition
    #when populating defs
    else if (QUALIFIERS_EXIST){
      #def is the corresponding definition for i-th attribute
      def <- paste(definitions[which(definitions$uniqueAttributeLabel == att),'uniqueAttributeDefinition'],
                   '; With qualifier \'',
                   paste(att_qualifiers, collapse = ''),
                   '\' ',
                   extra,
                   sep = '')
      
      #assign def to the corresponding position in defs
      defs[i] <- def
      i <- i+1
    }
    
    #if there were no qualifiers, use regular definition
    else {
      def <- definitions[which(definitions$uniqueAttributeLabel == att),'uniqueAttributeDefinition']
      #assign def to the corresponding position in defs
      defs[i] <- def
      i <- i+1
    }
    
  }
  return(defs)
}

##############################################################################










##############################################################################

#function definition for attribute_units
#inputs:
  #data: a dataframe with attributes to define
  #definitions: dataframe in the style of definitions.csv
#output: a vector of attribute definitions to be used in attribute table

##############################################################################

attribute_units <- function(data_path, definitions){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  
  #will be vector of attribute definitions
  units <- vector(mode = 'character', length = length(attributes))
  
  #i will be index at which to populate defs
  i <- 1
  #for each attribute
  for (att in attributes){
    
    #set att to the regular attribute name (w/out qualifier)
    
    #did not do all of the possible combinations of qualifiers
    #because not all possible combinations appeared in data
    
    if (str_sub(att,-5,-1) == '_PI_F'){
      str_sub(att,-5,-1) <- ""
    }
    
    else if (str_sub(att,-3,-1) %in% c('_PI','_QC','_IU','_SD')){
      str_sub(att,-3,-1) <- ""
    }
    
    else if (str_sub(att,-2,-1) == '_F'){
      str_sub(att,-2,-1) <- ""
    }
    
    else if (str_sub(att,-2,-1) %in% c('_1','_2','_3','_4','_5','_6','_7','_8','_9')){
      str_sub(att,-2,-1) <- ""
    }
    
    else if (str_sub(att,-2,-1) %in% c('_R','_A')){
      str_sub(att,-6,-1) <- ""
    }
    
    #if the attribute (with potential qualifiers removed) 
    #is not defined in definitions, there is a problem
    
    if (!(att %in% definitions$uniqueAttributeLabel)){
      print(paste('Error: The attribute: ', 
                  att, 
                  ' is not defined in the definitions dataframe.',
                  sep = ''))
    }
    
    else if (att %in% c('TIMESTAMP_START','TIMESTAMP_END')){
      unit <- NA
      units[i] <- unit
      i <- i+1
    }
    
    else {
      unit <- definitions[which(definitions$uniqueAttributeLabel == att),'unitSpelledOut']
      #assign unit to the corresponding position in units
      units[i] <- unit
      i <- i+1
    }
    
  }
  return(units)
}

##############################################################################





##############################################################################

#function definition for attribute_names
#inputs:
  #data: a dataframe with attribute names
#output: a vector of attribute names to be used in attribute table

##############################################################################

attribute_names <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  return(colnames(data))
}

##############################################################################




##############################################################################

#function definition for attribute_domains
#inputs:
#data: a dataframe with attributes to define
#output: a vector of attribute domains to be used in attribute table

##############################################################################

attribute_domains <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  domains <- vector(mode = 'character', length = length(attributes))
  
  for (i in 1:length(attributes)){
    if (attributes[i] %in% c('TIMESTAMP_START','TIMESTAMP_END')){
      domains[i] <- 'dateTimeDomain'
    }    
    else {
      domains[i] <- 'numericDomain'
    }
  }
  
  return(domains)
}

##############################################################################





##############################################################################

#function definition for textDomain_definitions
#inputs:
#data: a dataframe with attributes to define
#output: a vector of definitions for textDomain attributes to be used in attribute table

##############################################################################

textDomain_definitions <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  #no textDomains in any of the data
  return(rep(NA, times = length(attributes)))
}

##############################################################################






##############################################################################

#function definition for attribute_measurement_scales
#inputs:
#data: a dataframe with attributes to define
#output: a vector of attribute measurement scales to be used in attribute table

##############################################################################

attribute_measurement_scales <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  scales <- vector(mode = 'character', length = length(attributes))
  
  for (i in 1:length(attributes)){
    if (attributes[i] %in% c('TIMESTAMP_START','TIMESTAMP_END')){
      scales[i] <- 'dateTime'
    }
    #will have to manually check measurement scales
    else {
      scales[i] <- 'ratio'
    }
  }
  
  return(scales)
}

##############################################################################






##############################################################################

#function definition for attribute_format_strings
#inputs:
#data: a dataframe with attributes to define
#output: a vector of format strings for dateTime attributes to be used in attribute table

##############################################################################

attribute_format_strings <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  formats <- vector(mode = 'character', length = length(attributes))
  
  for (i in 1:length(attributes)){
    if (attributes[i] %in% c('TIMESTAMP_START','TIMESTAMP_END')){
      formats[i] <- 'YYYYMMDDHHMM'
    }    
    else {
      formats[i] <- NA
    }
  }
  
  return(formats)
}

##############################################################################




##############################################################################

#function definition for attribute_number_type
#inputs:
#data: a dataframe with attributes to define
#output: a vector of attribute numberTypes to be used in attribute table

##############################################################################

attribute_number_type <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  types <- vector(mode = 'character', length = length(attributes))
  
  for (i in 1:length(attributes)){
    if (attributes[i] %in% c('TIMESTAMP_START','TIMESTAMP_END')){
      types[i] <- NA
    }
    #will have to manually check number type
    else {
      types[i] <- 'real'
    }
  }
  
  return(types)
}

##############################################################################







##############################################################################

#function definition for attribute_missing_value_codes
#inputs:
#data: a dataframe with attributes to define
#output: a vector of definitions for textDomain attributes to be used in attribute table

##############################################################################

attribute_missing_value_codes <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  codes <- rep(NA, times = length(attributes))
  
  for (i in 1:length(attributes)){
    x <- attributes[i]
    if (sum(data[, x] == '-9999') > 0){
      codes[i] <- '-9999'
    }
  }
  
  return(codes)
}

##############################################################################







##############################################################################

#function definition for attribute_missing_value_explanations
#inputs:
#data: a dataframe with attributes to define
#output: a vector of definitions for textDomain attributes to be used in attribute table

##############################################################################

attribute_missing_value_explanations <- function(data_path){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  attributes <- colnames(data)
  explanations <- rep(NA, times = length(attributes))
  
  for (i in 1:length(attributes)){
    x <- attributes[i]
    if (sum(data[, x] == '-9999') > 0){
      explanations[i] <- 'Missing data records are indicated by the -9999 value.'
    }
  }
  
  return(explanations)
}

##############################################################################









##############################################################################

#function definition for attribute_table
#inputs:
  #data: a dataframe with attributes to define
  #definitions: dataframe in the style of definitions.csv
#output: a dataTable (dataframe) for the data, to be passed into set_attributes

##############################################################################

attribute_table <- function(data_path, definitions){
  
  data <- read.csv(data_path, skip = 2, stringsAsFactors = FALSE)
  
  print('Manually examine measurement scales')
  print('Manually examine number types')
  print('Manually check for custom units')
  
  attributeTable <- data.frame(
    attributeName = attribute_names(data_path),
    domain = attribute_domains(data_path),
    attributeDefinition = attribute_definitions(data_path, definitions),
    definition = textDomain_definitions(data_path),
    measurementScale = attribute_measurement_scales(data_path),
    formatString = attribute_format_strings(data_path),
    numberType = attribute_number_type(data_path),
    unit = attribute_units(data_path, definitions),
    missingValueCode = attribute_missing_value_codes(data_path),
    missingValueCodeExplanation = attribute_missing_value_explanations(data_path),
    stringsAsFactors = FALSE)
  
  return(attributeTable)
}

##############################################################################


# Example:

# attribute_table(data_path_2,definitions)
# EML::set_attributes(attribute_table(data_path_2,definitions))
