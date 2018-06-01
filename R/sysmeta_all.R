sysmeta_all <- function(mn, pid){
  mn <- mn
  pid <- pid
  
  allPIDS <- get_all_versions(mn, pid)
  
  allSysmeta <- list()
  i=0
  for(i in 1:length(all_vers)){
    allSysmeta[[i]] <- getSystemMetadata(mn, allPIDS[i])
  }
  
  return(allSysmeta)
}


