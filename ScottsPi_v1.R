# according to: https://en.wikipedia.org/wiki/Fleiss%27_kappa

ScottsPi <- function(data, n){
  
    data <- as.matrix(na.omit(data))
  nr <- nrow(data)
  nc <- ncol(data)
  data <- matrix(as.numeric(as.factor(data)), nr, nc)
  mval <- max(data, na.rm = T)
  
  mat <- matrix(unlist(lapply(X = 1:mval, function(x) rowSums(data == x))), nr)
  
  x <- c()
  
  for (i in 1:length(mat[,1])){
    x <- rbind(x, print((1/(n*(n - 1)))*(sum(mat[i,]^2) - n))) }
  
  return(x)
  
}