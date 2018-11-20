accuracy<-function(cm, area_prop, alpha=0.05) {
  #convert both data frames and vectors to matrices
  cmx<-as.matrix(cm)
  #try to convert a vector to a square matrix
  if (ncol(cmx) == 1)
    cmx<-matrix(cmx, byrow=TRUE, nrow=sqrt(nrow(cmx)))
  nr<-nrow(cmx); nc<-ncol(cmx)
  if (nr != nc)
  { print("Error: matrix is not square"); break }
  
  #descriptive statistics
  n<-sum(cmx)
  d<-diag(cmx); dsum<-sum(d); oa<-dsum/n
  oav<-((oa*(1-oa))/n)
  oul<-oa+(2*(sqrt(oav)))
  oll<-oa-(2*(sqrt(oav)))
  csum<-apply(cmx,2,sum); rsum<-apply(cmx,1,sum)
  ua<-d/rsum; pa<-d/csum
  
  #area  weighted matrix
  cmx_area<-matrix(0, nrow(cmx),ncol(cmx))
  for (i in 1:nrow(cmx)) {
    for (j in 1: ncol(cmx)){
      cmx_area[i,j]<-cmx[i,j]/rsum[i]*area_prop[i]
    }
  }
  
  d_area<-diag(cmx_area)
  
  #accuracy metrics
  oaw<-sum(d_area) # overall area weighted accuracy
  oawv<-sum(d_area*(area_prop-d_area)/rsum)# variance
  tp<-apply(cmx_area,2,sum) # true proportion
  tpv <- numeric(ncol(cmx_area)) #true map proportion variance
  for (j in 1:ncol(cmx_area)) {
    tpv[j]<-sum(cmx_area[,j]*(area_prop-cmx_area[,j]))/rsum[j]
  }
  paw<-d_area/tp #producers accuracy area weighted
  #for variance of paw
  fake_m<-cmx_area
  diag(fake_m)=0
  er<-numeric(ncol(cmx_area))
  for (j in 1:ncol(cmx_area)) {
    er[j]<-sum(fake_m[,j]*(area_prop-fake_m[,j])/rsum[j])
  }
  pawv<-(d_area*(tp^(-4))*((d_area*er)+(area_prop-d_area)*((tp-d_area)^2)/rsum))
  
  # user accuracy area weighted eq18, card 1982
  uaw<-d/rsum
  uawv<-(d_area*(area_prop-d_area))/((area_prop^2)*rsum)
  
  #confidence interval
  oac<-qnorm(1-(alpha/2))*sqrt(oawv) 
  oawul<-oaw+oac
  oawll<-oaw-oac
  tpc<-qnorm(1-(alpha/2))*sqrt(tpv)
  uac<-qnorm(1-(alpha/2))*sqrt(uawv)
  pac<-qnorm(1-(alpha/2))*(sqrt(pawv))
    
  #true proportion statistics
  tps<-data.frame(tp)
  row.names(tps)<-row.names(cmx)
  tps$tpc<-tpc
  
  #class specific accuracy statistics
  uas<-data.frame(uaw)
  row.names(uas)<-row.names(cmx)
  uas$uac<-uac

  pas<-data.frame(paw)
  row.names(pas)<-row.names(cmx)
  pas$pac<-pac
    
  #writing class specific results
  class<-(tps);class[3:4]<-uas; class[5:6]<-pas
# write.csv(class, "class_specific_result.csv",row.names=TRUE)
  #writing area weighted matrix
 # write.csv(cmx_area, "area_weighted_cm.csv")
  
  #printing statistics
  #print("Overall /area weighted accuracy, & CV%, class specific accuracies ", quote=F)
  output <- list(sum.n=n, overall.accuracy=oa, overall.var=oav, user.ac=ua, prod.ac=pa, 
       overall.area.weighted=oaw, overall.a.w.var=oawv, overall.area.w.upper=oawul, overall.area.w.lower=oawll,
       true.proportion=tps, user.accuracy=uas, producer.accuracy=pas)
 return(output)
 
}
