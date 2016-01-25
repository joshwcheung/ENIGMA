require(RCurl)

read_web_csv<-function(url_address){
  gdoc3=paste(url_address,'/export?format=csv&id=KEY',sep='')
  myCsv <- getURL(gdoc3,.opts=list(ssl.verifypeer=FALSE))
  csv_res<-read.csv(textConnection(myCsv))
  return (csv_res)
}

addr="https://docs.google.com/spreadsheets/d/1S57PbfDtXHOIiMUvShjQCrt0Cg8kK87giyYLQclUjVI"
csvTest<-read_web_csv(addr)

setwd('/Volumes/four_d/disaev/4Neda_Sinead/ENIGMA_SZ_DTI_beta_test_Dublin_092915/')
DemographicsList_Path<-"dem_config.csv"   #docs.google

dsDemographicsConf<-read.csv(DemographicsList_Path, header = TRUE,stringsAsFactors = FALSE)

