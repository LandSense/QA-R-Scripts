# purpose:  user agreement (Scotts Pi) 
# in: geojson from IGN france following this form
# out: scottspi evaluated point *.geojson file
# 03.06.2019, michael.schultz@uni-heidelberg.de


LocationOfThisScript = function() # Function LocationOfThisScript returns the location of this .R script (may be needed to source other files in same dir)
{
  this.file = NULL
  # This file may be 'sourced'
  for (i in -(1:sys.nframe())) {
    if (identical(sys.function(i), base::source)) this.file = (normalizePath(sys.frame(i)$ofile))
  }
  
  if (!is.null(this.file)) return(dirname(this.file))
  
  # But it may also be called from the command line
  cmd.args = commandArgs(trailingOnly = FALSE)
  cmd.args.trailing = commandArgs(trailingOnly = TRUE)
  cmd.args = cmd.args[seq.int(from=1, length.out=length(cmd.args) - length(cmd.args.trailing))]
  res = gsub("^(?:--file=(.*)|.*)$", "//1", cmd.args)
  
  # If multiple --file arguments are given, R uses the last one
  res = tail(res[res != ""], 1)
  if (0 < length(res)) return(dirname(res))
  
  # Both are not the case. Maybe we are in an R GUI?
  return(NULL)
}


# Rscript /home/michi/Dropbox/R/LS3a_ContributorAgreement_IGN_v8.R /home/michi/Dropbox/LandSense_QA/IGNMapper_qa/in/AnaMaria_3 /home/michi/Dropbox/LandSense_QA/IGNMapper_qa/out/ 03062019 TLS 2 0.6 validations2019_points_geoville2018_forlandsense.geojson
# c('02062019', 'TLS', 2, 0.6, 'validations2019_points_geoville2018_forlandsense.geojson', 'geoville_AJS2018_EPSG900913.tif')
#In = 'C:/input_landsense' # 'C:/Users/Schul/Dropbox/LandSense_QA/LandUse_qa/In'
#Out = 'C:/output_landsense' # 'C:/Users/Schul/Dropbox/LandSense_QA/LandUse_qa/In'
d = '03062019' # date
s = 'TLS' # caomaign identifer
n = 2 # number of revisits
h = 0.6 # scottspi threshold
f = 'https://www.nottingham.ac.uk/~ezzjfr/validations2019_points_geoville2018_forlandsense_sample_no_crs.geojson' # campaign name
#f = 'C:/Users/wicke/validations2019_points_geoville2018_forlandsense.geojson'


LS3a_ContributorAgreement_IGN_v8=function(d, s, n, h, f){ # arguments: In = dir input data, Out = dir output data, d = date, s = campaign prefix, n = redundancy depth (must be higher than 2), h = scottspi threshold, f = reference file
  
  # Rscript /home/michi/Dropbox/R/LS3a_ContributorAgreement_IGN_v8.R /home/michi/Dropbox/LandSense_QA/IGNMapper_qa/in/AnaMaria_3 /home/michi/Dropbox/LandSense_QA/IGNMapper_qa/out/ 03062019 TLS 2 0.6 validations2019_points_geoville2018_forlandsense.geojson
  # c('02062019', 'TLS', 2, 0.6, 'validations2019_points_geoville2018_forlandsense.geojson', 'geoville_AJS2018_EPSG900913.tif')
  # In = '/home/michi/Dropbox/LandSense_QA/IGNMapper_qa/in/AnaMaria_3' # 'C:/Users/Schul/Dropbox/LandSense_QA/LandUse_qa/In'
  # Out = '/home/michi/Dropbox/LandSense_QA/IGNMapper_qa/out/' # 'C:/Users/Schul/Dropbox/LandSense_QA/LandUse_qa/In'
  # d = '03062019' # date
  # s = 'TLS' # caomaign identifer
  # n = 2 # number of revisits
  # h = 0.6 # scottspi threshold
  # f = 'validations2019_points_geoville2018_forlandsense.geojson' # campaign name
  p = c(d, s, n, h, f)
  rm(d, s, n, h, f)
  
  # dependencies
  #fd = '/home/michi/Dropbox/R/' # functions home, fixed on the server
  fd <- LocationOfThisScript() # this isn't necessary if this and the ScottsPI script were in an R package

  x = c('rgdal', 'reshape2', 'ggplot2', 'raster', 'rgeos', 'maptools', 'foreign','jsonlite') # list of libraries
  lapply(x, library, character.only = T); rm(x) # load libraries and clean
  #source(paste0(fd, 'ScottsPi_v1.R')) # Scotts Pi, https://en.wikipedia.org/wiki/Fleiss%27_kappa # worked example
  
  #this isn't necessary if this and the ScottsPI script were in an R package
  source(paste(fd, 'ScottsPi_v1.R', sep="/")) # Scotts Pi, https://en.wikipedia.org/wiki/Fleiss%27_kappa # worked example
  
  x.r = readOGR(p[5]);
  x = x.r # call; copy reference data
  
  # format factor to numeric 
  x$userval_1 =  as.numeric(levels(x$userval_1))[x$userval_1] # user 1
  x$userval_2 =  as.numeric(levels(x$userval_2))[x$userval_2] # user 2
  x$datavalue =  as.numeric(levels(x$datavalue))[x$datavalue] # map response
  
  # remove 8 (undecided), order and copy
  x = x[x$userval_1 < 8,]; x = x[x$userval_2 < 8,]   # remove 8 undecided by user_1; user_2
  x = x[order(x$sampleid),] # order data
  x.s = x # copy
  
  # calculate Scots Pi and format
  co = as.data.frame(cbind(x$userval_1, x$userval_2)) # format for scots PI
  si = ScottsPi(co, as.numeric(p[3])) # scots PI calculation
  
  x = as.data.frame(cbind(si, x$datavalue, x$userval_1, x$sampleid)) # combine ScottsPi, map response, majority vote reference, id
  colnames(x) = c('s', 'm', 'r', 'sampleid') # colnames: ScottsPi, map response,  majority reference, id
  cc = 0; cv = 0;  # dummy to append category character and category value
  x = cbind(x, cc, cv) # append category character and value
  x$cc[x$s <= 0.1] = 'poor agreement' # agreement category
  x$cc[x$s > 0.2 & x$s <= 0.4] = 'fair agreement'
  x$cc[x$s > 0.4 & x$s <= 0.6] = 'moderate agreement'
  x$cc[x$s > 0.6 & x$s <= 0.8] = 'substantial agreement'
  x$cc[x$s >= 0.8] = 'perfect agreement'
  x$cv[x$s <= 0.1] = 0 # agreement category taking the uper categories
  x$cv[x$s > 0.2 & x$s <= 0.4] = 0.4
  x$cv[x$s > 0.4 & x$s <= 0.6] = 0.6
  x$cv[x$s > 0.6 & x$s <= 0.8] = 0.8
  x$cv[x$s >= 0.8] = 1
  
  # create spatial evaluation data set
  x$mr = x$m == x$r # reference vs map
  x$vm = x$cv >= as.character(p[4]) # above h value, valid ScottsPi match
  x$qa = x$mr == x$vm # match of map and valid ScottsPi
  x.r <- x.r[order(x.r$sampleid),] # order original spatial data
  x.r <-  merge(x.r, x, by = 'sampleid') # merge with data
  
  #setwd(Out) # change to output work directory
  x.e = x.r # copy
  colnames(x.e@data) <- c('sampleid', 'datavalue', 'datalabel', 'userval_1', 'usercar_1',
                          'usercom_1', 'userval_2', 'usercar_2', 'usercom_2', 'scottspi', 'map',
                          'reference', 'agreement_string', 'agreement_category_numeric', 'mapVSref',
                          'scootspi_valid', 'scottspiVSmapVSref') # output labels
  
  
  #create a tempfile to write the data to
  outputTempFile = tempfile()
  #writeOGR(x.e, dsn=paste0(substr(p[5], 0, nchar(p[5])-8),'_', p[1],'_qa.geojson'), layer='ls_qa', driver="GeoJSON") # output
  writeOGR(x.e, dsn=outputTempFile, layer='ls_qa', driver="GeoJSON") # output
  
  #Read the tempfile back in and return the JSON string (uses JSONLite)
  document <- fromJSON(outputTempFile)
  return(document)
}

#parse arguments
args = commandArgs(T) 
d = as.character(args[1])
s = as.character(args[2]); 
n = as.character(args[3]); 
h = as.character(args[4])
f = as.character(args[5])

#run business logic and get JSON string response result
result = LS3a_ContributorAgreement_IGN_v8(d, s, n, h, f) # execute

#print the json string result to stout which will get picked up by QA-Platform 
print(toJSON(result))