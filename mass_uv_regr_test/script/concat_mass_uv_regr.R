#----Postprocessing script for mass_uv_regr package. Don't change
#-Dmitry Isaev
#-Boris Gutman
#-Neda Jahanshad
# Beta version for testing on sites.
#-Imaging Genetics Center, Keck School of Medicine, University of Southern California
#-ENIGMA Project, 2015
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


logDir=cmdargs[3]
#LOG_FILE<-paste(logDir, '/',RUN_ID,'_',SITE,'.log',sep='')

resDir=cmdargs[4]
Results_CSV_Path<-paste(resDir,'/',ID,'_',sep='')

ROI_LIST_TXT=cmdargs[5]
ROI_LIST<-readChar(ROI_LIST_TXT, file.info(ROI_LIST_TXT)$size)
ROI_LIST
ROI<-eval(parse(text=paste('c(',ROI_LIST,')',sep='')))


Config_Path=cmdargs[6]   #docs.google 


#ID='SZDTI'
#CURRENT_ROI='"ACR","ACR_L","ACR_R","ALIC"' #,"ALIC_L","ALIC_R","AverageFA","BCC"'#,"CC","CGC","CGC_L","CGC_R","CGH","CGH_L","CGH_R","CR","CR_L","CR_R","CST","CST_L","CST_R","EC","EC_L","EC_R","FX","FX_ST_L","FX_ST_R","FXST","GCC","IC","IC_L","IC_R","IFO","IFO_L","IFO_R","PCR","PCR_L","PCR_R","PLIC","PLIC_L","PLIC_R","PTR","PTR_L","PTR_R","RLIC","RLIC_L","RLIC_R","SCC","SCR","SCR_L","SCR_R","SFO","SFO_L","SFO_R","SLF","SLF_L","SLF_R","SS","SS_L","SS_R","UNC","UNC_L","UNC_R"'
#CURRENT_ROI2='"10","11","12","13","17","18","26","49","50","51","52","53","54","58"'
#ROI<-eval(parse(text=paste('c(',CURRENT_ROI,')',sep='')))
#SitePostfix<-"dublin"
#Config_Path="https://docs.google.com/spreadsheets/d/142eQItt4C_EJQff56-cpwlUPK7QmPICOgSHfnhGWx-w"
config_csv<-read_web_csv(Config_Path)

config_currentRun<-config_csv[grep(ID, config_csv$ID, ignore.case=T),]
if(nrow(config_currentRun)>1) {
  cat (paste("Error: number of rows with ID ",ID," is more than 1. Row must be unique.",sep=''))
  stop()
}


AnalysisList_Path<-config_currentRun$AnalysisList_Path
DemographicsList_Path<-config_currentRun$DemographicsList_Path

dsAnalysisConf<-read_web_csv(AnalysisList_Path)
#read demographic configuration file
dsDemographicsConf<-read_web_csv(DemographicsList_Path)

cat(paste("Analysis list path: ",AnalysisList_Path,sep=''))
TYPE<-config_currentRun$Type
TRAIT_LIST<-config_currentRun$Trait
TRAIT_LIST<-gsub("[[:space:]]", "", TRAIT_LIST)
TRAIT_LIST<-gsub(";","\",\"",TRAIT_LIST)
SHAPE_METRICS<-eval(parse(text=paste('c("',TRAIT_LIST,'")',sep='')))

trait="FA"
cur_rowAnalysis=1
for(trait in SHAPE_METRICS){
  for (cur_rowAnalysis in 1:nrow(dsAnalysisConf)){
    i=1
    setwd(resDir)
    if (dsAnalysisConf$Active[cur_rowAnalysis]==1) 
    {
      
      for (cur_roi in ROI) {
        f_name=paste(ID,'_',cur_roi,'_',trait,'_',dsAnalysisConf$ID[cur_rowAnalysis],'_',SitePostfix,'.csv',sep='')
        cur_csv<-read.csv(f_name, header = TRUE,sep=',',dec='.')
        if(i==1) {
          data_csv<-cur_csv
        }
        else{
          data_csv<-rbind(data_csv,cur_csv,deparse.level = 0)
        }
        i=i+1
      }
      write.csv(data_csv,file=paste(ID,'_ALL_',trait,'_',dsAnalysisConf$ID[cur_rowAnalysis],'_',SitePostfix,'.csv',sep=''))
    }
  }
}
