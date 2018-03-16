generate_attributes_table <- function(csv_file_path,
                                      attributes_file_path) {
  # Check that files exist 
  stopifnot(file.exists(csv_file_path))
  stopifnot(file.exists(attributes_file_path))
  
  # Read in files 
  data <- read.csv(csv_file_path, stringsAsFactors = FALSE, skip = 2)
  n <- dim(data)[2]
  attributes <- try(read.csv(attributes_file_path, stringsAsFactors = FALSE))

  
  # Initialize data frame
  table <- data.frame(attributeName = rep("NA", n),
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
  
  for (i in seq_len(n)) {
    # add attribute name
    table$attributeName[i] = colnames(data)[i]
    
      ## check if the name has a qualifier at the end
      if (any(endsWith(colnames(data)[i], suffix = qualifiers))) {
        # identify the qualifier
        current_qual <- which(endsWith(colnames(data)[i], suffix = qualifiers))
        qualifier<- qualifiers[current_qual]
        len<- nchar(qualifier)
        main_label<- substr(colnames(data)[i], 1, nchar(colnames(data)[i])-len)
        
        # get definition for main label
        main_def <- attributes$uniqueAttributeDefinition[attributes$uniqueAttributeLabel == main_label]
        
        # get definition for qualifier label, special case if it is a number
        if (qualifier %in% num_qualifiers){
          qual_def <- attributes$uniqueAttributeDefinition[attributes$uniqueAttributeLabel == "_#"]
        } else{
          qual_def <- attributes$uniqueAttributeDefinition[attributes$uniqueAttributeLabel == qualifier]
        }
        
        # concatenate the definitions
        table$attributeDefinition[i] = paste(main_def, ". ", qual_def)
        
        # check if it is a time variable
        if (grepl("TIME", main_label)){
          table$measurementScale[i] = "dateTime"
          table$domain[i] = "dateTimeDomain"
          table$formatString[i] = "YYYYMMDDHHMM"
          table$unit[i] = "NA"
        } else {
          table$measurementScale[i] = "ratio"
          table$domain[i] = "numericDomain"
          table$numberType[i] <- "real"
          table$unit[i] = attributes$SI_unit[attributes$uniqueAttributeLabel == main_label]
          table$missingValueCode[i] = "-9999"
          table$missingValueCodeExplanation[i] = "Missing values are represented as -9999"
        } 
        
        # case if there is no qualifier
      } else {
        table$attributeDefinition[i] = attributes$uniqueAttributeDefinition[attributes$uniqueAttributeLabel ==            colnames(data)[i]]
        # check if it is a time variable
        if (grepl("TIME", colnames(data)[i])){
          table$measurementScale[i] = "dateTime"
          table$domain[i] = "dateTimeDomain"
          table$formatString[i] = "YYYYMMDDHHMM"
          table$unit[i] = "NA"
        } else {
          table$measurementScale[i] = "ratio"
          table$domain[i] = "numericDomain"
          table$numberType[i] <- "real"
          table$unit[i] = attributes$SI_unit[attributes$uniqueAttributeLabel == colnames(data)[i]]
          table$missingValueCode[i] = "-9999"
          table$missingValueCodeExplanation[i] = "Missing values are represented as -9999"
        } 
     }
    
  }
  
  return(table)
  
}
