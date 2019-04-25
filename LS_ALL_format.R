# purpose: formats data downloaded from laco-wiki and other LandSense pilot data sources
# in: geojson output from laco-wiki (requiers currently reformating downloaded zip shp to geojson)
# in: ADD other formats
# out: data formated pilto specific QA 
# 25.04.2019, michael.schultz@uni-heidelberg.de

# add fomat identification

LacoFormat <- function(In, Out, pt, nl, se){ # arguments: In = Input folder, Out = Output folder, pt = pattern (eg. *.zip) of downloaded data, nl = redundancy depth if 0 or 1 than no redundancy (needs implementation), s = sampling population 
  
  # get files
  setwd(In) # location of downloads
  dl <- list.files(pattern = glob2rx(pt)) # select relevant files
  file.copy(dl, Out) # copy files to workspace
  
  # extract/rename files
  setwd(Out)
  dl <- list.files(pattern = glob2rx(pt)) # select relevant files
  
  for (i in 1:length(dl)){
    unzip(dl[i])  # unzip your file 
    sf <- list.files(pattern = 'Sample Polygons*') # list shape file elements
    for (j in 1:length(sf)){ file.rename(sf[j], paste0(nl[i], se[j])) } # rename files 
  }
  
}
