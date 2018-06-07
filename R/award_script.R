###Produce a list of award numbers in our metadata and their information

#####First use download_data_objects from datamgmt
download_data_objects <- function(mn, data_pids, out_paths, n_max = 3) {
  stopifnot(methods::is(mn, "MNode"))
  stopifnot(is.character(data_pids))
  
  for (i in seq_along(out_paths)) {
    
    if (file.exists(out_paths[i])) {
      warning(call. = FALSE,
              paste0("The file ", out_paths[i], " already exists. Skipping download."))
    } else {
      n_tries <- 0
      dataObj <- "error"
      
      while (dataObj[1] == "error" & n_tries < n_max) {
        dataObj <- tryCatch({
          dataone::getObject(mn, data_pids[i])
        }, error = function(e) {return("error")})
        
        n_tries <- n_tries + 1
      }
      writeBin(dataObj, out_paths[i])
    }
  }
  
  return(invisible())
}
######

#Function with arguments: mn, metapid
getAwardNumbers <- function(mn, metapid){
  #outputs list of pid, raw_award_string, award_number, title of xml file
  
  stopifnot(methods::is(mn, "MNode"))
  stopifnot(is.character(metapid))
  
  #get outpath name from metapid
  systema <- getSystemMetadata(mn, metapid)
  systema_name <- systema@fileName
  outpath <- paste("/home/mnguyen/", systema_name, sep = "")
  
  #download data from metapid
  download_data_objects(mn, c(metapid), c(outpath))
  eml_file <- outpath
  
  #get xml from metapid
  eml <- read_eml(eml_file) #read in eml_file
  list <- list() #will be output list
  
  #filename 
  filename <- eml_file
  list[["filename"]] <- filename
  
  #pid
  list[["metapid"]] <- metapid
  
  #the raw award string numbers
  raw_award_string <- c()
  funding <- eml@dataset@project@funding@para
  for(i in 1:length(funding)){
    award <- funding@.Data[[i]]@.Data[[1]]
    raw_award_string[i] <- as_list(award)[[1]]
  }
  list[["raw_award_string"]] <- raw_award_string
  
  #award_number
  award_number <- str_extract_all(string = raw_award_string, pattern ="[0-9]+")
  list[["award_number"]] <- unlist(award_number)
  
  #title
  title <- eml@dataset@title@.Data[[1]]@.Data
  list[["title"]] <- title
  
  return(list)
}
