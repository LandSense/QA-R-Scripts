# data downloaded as Validation.zip

LacoFormat <- function(df, pt, af, nl, se){
  
  # get files
  setwd(df) # location of downloads
  dl <- list.files(pattern = glob2rx(pt)) # select relevant files
  file.copy(dl, af) # copy files to workspace
  
  # extract/rename files
  setwd(af)
  dl <- list.files(pattern = glob2rx(pt)) # select relevant files
  
  for (i in 1:length(dl)){
    unzip(dl[i])  # unzip your file 
    sf <- list.files(pattern = 'Sample Polygons*') # list shape file elements
    for (j in 1:length(sf)){ file.rename(sf[j], paste0(nl[i], se[j])) } # rename files 
  }
  
}