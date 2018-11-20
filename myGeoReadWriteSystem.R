myReadWriteJSON=function(fileName){
  print('running R function')
  library(jsonlite)
  document <- fromJSON(txt=fileName)
  return(document)
}
#Reading arguments
args <- commandArgs(TRUE)
fileName <- as.character(args[1])

#fileName <- 'C:/Users/ezzjfr/Downloads/cobweb_pts.geojson'

#Call function
result = myReadWriteJSON(fileName)

# Output
#cat("result=")
print(toJSON(result))
