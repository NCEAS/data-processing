#' Generate Attributes table 
#'
#' @description This function creates a complete attributes table by combining information gathered from 
#' the csv data file itself and a csv of preliminary attribute information. This function was written 
#' specifically to work with Ameriflux data and the information that was provided along with it.
#'  
#'
#' @param csv_file_path (character) Path to the CSV file of data
#' @param attributes_file_path (character) Path to CSV file of preliminary attribute information


generate_attributes_table <- function(csv_file_path,
                                      attributes_file_path) {
  # Check that files exist 
  stopifnot(file.exists(csv_file_path))
  stopifnot(file.exists(attributes_file_path))
  
  # Read in files 
  data <- read.csv(csv_file_path, stringsAsFactors = FALSE, skip = 2)
  n <- dim(data)[2]
  attributes <- try(read.csv(attributes_file_path, stringsAsFactors = FALSE))
  colnames(attributes) <- ("category", "label", "definition", "unit", "SI_unit")
  
  # Initialize data frame
  att_table <- data.frame(attributeName = rep("NA", n),
                      attributeDefinition = rep("NA", n),
                      measurementScale = rep("NA", n),
                      domain = rep("NA", n),
                      formatString = rep("NA", n),
                      definition = rep("NA", n),
                      unit = rep("NA", n),
                      numberType = rep("NA", n),
                      missingValueCode = rep("NA", n),
                      missingValueCodeExplanation = rep("NA", n),
                      stringsAsFactors = F)
  
  qualifiers<- c("_PI", "_QC", "_F", "_IU", "_H_V_R", "_H_V_A", "_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9", "_SD", "_N")
  num_qualifiers<- c("_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9")
  
  # add attribute name
  att_table$attributeName <- colnames(data)
  col_names <- colnames(data)
  
  for (i in seq_len(n)) {
    
      ## check if the name has a qualifier at the end
      if (any(endsWith(col_names[i], suffix = qualifiers))) {
        # identify the qualifier
        current_qual <- which(endsWith(col_names[i], suffix = qualifiers))
        qualifier<- qualifiers[current_qual]
        len<- nchar(qualifier)
        main_label<- substr(col_names[i], 1, nchar(col_names[i])-len)
        
        # get definition for main label
        main_def <- attributes$definition[attributes$label == main_label]
        
        # get definition for qualifier label, special case if it is a number
        if (qualifier %in% num_qualifiers){
          qual_def <- attributes$definition[attributes$label == "_#"]
        } else{
          qual_def <- attributes$definition[attributes$label == qualifier]
        }
        
        # concatenate the definitions
        att_table$attributeDefinition[i] <- paste(main_def, ". ", qual_def)
        
        # check if it is a time variable
        if (grepl("TIME", main_label)){
          att_table$measurementScale[i] <- "dateTime"
          att_table$domain[i] <- "dateTimeDomain"
          att_table$formatString[i] <- "YYYYMMDDHHMM"
          att_table$unit[i] <- "NA"
        } else {
          att_table$measurementScale[i] <- "ratio"
          att_table$domain[i] <- "numericDomain"
          att_table$numberType[i] <- "real"
          att_table$unit[i] <- attributes$SI_unit[attributes$label == main_label]
          att_table$missingValueCode[i] <- "-9999"
          att_table$missingValueCodeExplanation[i] <- "Missing values are represented as -9999"
        } 
        
        # case if there is no qualifier
      } else {
        att_table$attributeDefinition[i] <- attributes$definition[attributes$label == col_names[i]]
        # check if it is a time variable
        if (grepl("TIME", col_names[i])){
          att_table$measurementScale[i] <- "dateTime"
          att_table$domain[i] <- "dateTimeDomain"
          att_table$formatString[i] <- "YYYYMMDDHHMM"
          att_table$unit[i] <- "NA"
        } else {
          att_table$measurementScale[i] <- "ratio"
          att_table$domain[i] <- "numericDomain"
          att_table$numberType[i] <- "real"
          att_table$unit[i] <- attributes$SI_unit[attributes$label == col_names[i]]
          att_table$missingValueCode[i] <- "-9999"
          att_table$missingValueCodeExplanation[i] <- "Missing values are represented as -9999"
        } 
     }
    
  }
  
  return(att_table)
  
}
