#----TESTING FOR SINEAD----
# enigma@ini.usc.edu 
# http://enigma.ini.usc.edu
#-----------------------------------------------


library(ppcor)
library(matrixStats)

#--0.
require(RCurl)

read_web_csv<-function(url_address){
  gdoc3=paste(url_address,'/export?format=csv&id=KEY',sep='')
  myCsv <- getURL(gdoc3,.opts=list(ssl.verifypeer=FALSE))
  csv_res<-read.csv(textConnection(myCsv),header = TRUE,stringsAsFactors = FALSE)
  return (csv_res)
}


#--0.
#--1. READING THE COMMAND LINE---

cmdargs = commandArgs(trailingOnly=T)
ID=cmdargs[1]
#RUN_ID=cmdargs[1]

SITE=cmdargs[2]
SitePostfix<-SITE

DATADIR=cmdargs[3]

CURRENT_ROI=cmdargs[7]
RUN_ID=paste(ID,'_',CURRENT_ROI,sep='')

ROI<-eval(parse(text=paste('c("SubjID","',CURRENT_ROI,'")',sep='')))

logDir=cmdargs[4]
LOG_FILE<-paste(logDir, '/',RUN_ID,'_',SITE,'.log',sep='')

resDir=cmdargs[5]
Results_CSV_Path<-paste(resDir,'/',RUN_ID,'_',sep='')

subjects_cov=cmdargs[6]
Subjects_Path<-subjects_cov

Config_Path=cmdargs[8]   #docs.google 



config_csv<-read_web_csv(Config_Path)
config_csv


