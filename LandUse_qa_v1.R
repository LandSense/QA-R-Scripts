# purpose: calculates standard accuracy measures (Congalton 1991) considering true marginal map proportions (Card 1982) and user agreement (Scotts Pi) 
# in: geojson output from laco-wiki (requiers currently reformating downloaded zip shp to geojson)
# out: statistics and graphs of accuracys and agreement 
# 05.11.2018, michael.schultz@uni-heidelberg.de


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
  res = gsub("^(?:--file=(.*)|.*)$", "\\1", cmd.args)
  
  # If multiple --file arguments are given, R uses the last one
  res = tail(res[res != ""], 1)
  if (0 < length(res)) return(dirname(res))
  
  # Both are not the case. Maybe we are in an R GUI?
  return(NULL)
}




LandUse_qa_v1=function(In, Out, a, n, s){ # arguments: In = Input data, Out = Output data, a = campaign prefix, n = redundancy depth if 0 or 1 than no redundancy (needs implementation), s = sampling population 
  
  # dependencies
  x <- c('jsonlite', 'rgdal', 'reshape2', 'ggplot2', 'raster') # list of libraries
  lapply(x, library, character.only = T); rm(x) # load libraries and clean
  fd <- LocationOfThisScript()
  
  
  print(paste0('working dir ', fd))
  source(paste(fd, 'ScottsPi_v1.R', sep="/")) # Scotts Pi, https://en.wikipedia.org/wiki/Fleiss%27_kappa # worked example
  source(paste(fd, 'fun_accuracy_stratified.R', sep="/")) # accuracy Card 1982

  # /home/michi/Dropbox/LandSense_QA/LandUse_qa/in/ /home/michi/Dropbox/LandSense_QA/LandUse_qa/out/ GENEVA 5 150
  
  #In <- '/home/michi/Dropbox/LandSense_QA/LandUse_qa/in/'
  #Out <- '/home/michi/Dropbox/LandSense_QA/LandUse_qa/out/'
  #a <- 'GENEVA'
  #n <- 5
  #s <- 150
  
  # C:/Users/ezzjfr/Documents/lucas_git/landsenseR/LandSense_QA/LandUse_qa/In/ C:/Users/ezzjfr/Documents/lucas_git/landsenseR/LandSense_QA/LandUse_qa/Out/ GENEVAJ 5 150
  
  # In <-'C:/Users/ezzjfr/Documents/lucas_git/landsenseR/LandSense_QA/LandUse_qa/In/'
  # Out <- 'C:/Users/ezzjfr/Documents/lucas_git/landsenseR/LandSense_QA/LandUse_qa/Out/'
  # a <- 'GENEVAJules'
  # n <- 5
  # s <- 150
  
  # program start
  setwd(In) # Input data 
  
  fl <- list.files(pattern = paste0('*', '.geojson')) # geojson list
  r <- raster(list.files(pattern = paste0('*', '.tif'))) # tif raster file
  
  # agreement calculation
  co <- matrix(0, ncol = 0, nrow = s) # initiate matrix
  co <- data.frame(co) # as data frame
  for (i in 1:length(fl)){ 
    
    x <- fromJSON(txt=fl[i]) # call json
    x <- as.data.frame(cbind(as.numeric(as.character(x$features$properties$ValValue)), x$features$properties$SampleID)) # extract relevant data
    colnames(x) <- c('r' , 'id') # column names r = reference , id = of samples needed for comparison
    x <- x[order(x$id),] # sort data
    co <- cbind(co, x$r) # populate data frame
    
  }; rm(i, x) # combine data sets and clean
  mv <- as.numeric(apply(co,1,function(x) names(which.max(table(x))))) # majority response (will be compared with the map)
  si <- ScottsPi(co, n) # agreement calculation
  
  # fetch map response
  x <- fromJSON(txt=fl[1]) # call geojson
  x <- as.data.frame(cbind(as.numeric(as.character(x$features$properties$DataValue)), x$features$properties$SampleID)) # extract relevant data
  colnames(x) <- c('m' , 'id') # column names m = map , id = of samples needed for comparison
  x <- x[order(as.numeric(as.character(x$id))),] # sort data
  
  # format data
  x <- as.data.frame(cbind(si, as.numeric(as.character(x$m)), mv, as.numeric(as.character(x$id)))) # combine ScottsPi, map response and majority vote
  colnames(x) <- c('s', 'm', 'r', 'id') # colnames: ScottsPi, map response, and majority vote as reference
  
  # ouput raw QA
  write.csv(x, file = paste0(Out, a, '_raw', '.csv')) # output raw results
  jpeg(paste0(Out, a, '_agreementDist', '.jpg')) # figure name
  plot(table(x$s)/sum(table(x$s)), main="data user agreement", xlab="Scotts PI", ylab="percentage") # agreement distribution
  dev.off() # save plot
  
  # calculate accuracy
  # class proportions
  f <- as.data.frame(freq(r)) # class frequencies
  f <- f[-nrow(f),] # remove NA
  p <- f$count/sum(f$count) # area proportions
  
  # calculate accuracy
  x <- x[ which(x$r!=99),]
  con <- table(x$m, x$r) # map, reference
  acc <- accuracy(con, p) # accuracy
  
  # format data for plotting
  oa <- c(acc$overall.area.weighted[1], acc$overall.area.w.upper[1]) # overall acccuracy and confidence
  d <- cbind(acc$user.accuracy, acc$producer.accuracy) # add accuracy measures
  lc <- rownames(d); d <- cbind(d, lc) # land cover classes
  dc <- as.data.frame(cbind(d$uac, d$pac, as.numeric(as.character(d$lc)))); colnames(dc) <- c('uc', 'pc', 'lc'); dc <- melt(dc, id = 'lc') # accuracy
  da <- as.data.frame(cbind(d$uaw, d$paw, as.numeric(as.character(d$lc)))); colnames(da) <- c('ua', 'pa', 'lc'); da <- melt(da, id = 'lc') # accuracy
  d <- data.frame((da$value)*100, (dc$value)*100 , dc$variable, da$lc); colnames(d) <- c('acc', 'con', 'type', 'lc') # area bias, area bias confidence, land cover, site, method
  d$con[abs(d$acc - d$con) > 100] <- abs(abs(d$acc[d$acc - d$con < -100]) -100) # fix exceding confidence
  
  # graph data regulations
  d$acc <- round(d$acc, digits = 1); d$con <- round(d$con, digits = 2) # round 
  d$con[(100 - d$acc) < d$con] <- abs(d$acc[(100 - d$acc) < d$con] - 100) # 1st fix exceding confidence
  d$con[d$acc < d$con] <- d$acc[d$acc < d$con] # 2nd fix exceding confidence
  d$con <- round(d$con, digits = 2) # additional round
  
  # create accuracy comparison figure
  ggplot(d, aes(x = lc, y = acc, fill = type)) + # call plot
    geom_bar(position=position_dodge(), stat="identity")+ # basic bar plot
    geom_errorbar(aes(ymin=acc-con, ymax=acc+con), position=position_dodge()) + # errorbars
    geom_hline(yintercept = 85, color="green", linetype="dashed", size = 1)+ 
    labs(list(title = '', x = "", y = "Accuracy [%]", color = ""))+ # captions
    geom_text(label = '',fontface = "bold", colour = "red", position = position_dodge(width = 0.9), angle = 90, hjust = 1.2)+
    # theme
    theme(axis.text = element_text(size=15, colour = 'black'),
          axis.text.x = element_text(size=15, colour = 'black', angle = 90),# font axis text
          axis.title = element_text(size=15, colour = 'black'), # font axis caption
          legend.text = element_text(size=15), # font legend caption
          legend.title = element_text(size=15), # font legend title
          axis.ticks = element_line(colour = 'black', size = 1), legend.position="bottom", 
          strip.background = element_blank(),
          strip.text = element_text(size = 15)) # axis ticks
  ggsave(paste0(Out, a, '_Accuracy', '.jpg'), width = 4, height = 4)
  
}

args <- commandArgs(T) # parse arguments
In <- as.character(args[1])
Out <- as.character(args[2])
a <- as.character(args[3])
n <- as.numeric(args[4])
s <- as.numeric(args[5])

result = LandUse_qa_v1(In, Out, a, n, s) # execute