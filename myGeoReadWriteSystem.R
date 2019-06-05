# purpose:  demo R script for use in QA-Platform
# in: URL to a geojson file
# out: geojson
# Description: basic example of how to configure an R script for use in the QA-Platform. 
# The script should be callable from a terminal and therefore handles parsing arugments

# this function is the business logic
myReadWriteJSON=function(fileName){
  print('running R function')
  library(jsonlite)
  document <- fromJSON(txt=fileName)
  return(document)
}

#Reading / parsing arguments
args <- commandArgs(TRUE)
fileName <- as.character(args[1])
#fileame <- 'https://www.nottingham.ac.uk/~ezzjfr/4_point_geojson.geojson' # for local testing

#Call function 
result = myReadWriteJSON(fileName)

# Output
print(toJSON(result))
