#/*
# * Derrek Hibar  - derrek.hibar@ini.usc.edu
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA 2014.
# */
####################################################################
cmdargs = commandArgs(trailingOnly=T);
csvFILE_SA=cmdargs[1]
csvFILE_TH=cmdargs[2]
outFolder=cmdargs[3]
#################

ROIS=c("bankssts","caudalanteriorcingulate","caudalmiddlefrontal","cuneus","entorhinal","fusiform","inferiorparietal","inferiortemporal","isthmuscingulate","lateraloccipital","lateralorbitofrontal","lingual","medialorbitofrontal","middletemporal","parahippocampal","paracentral","parsopercularis","parsorbitalis","parstriangularis","pericalcarine","postcentral","posteriorcingulate","precentral","precuneus","rostralanteriorcingulate","rostralmiddlefrontal","superiorfrontal","superiorparietal","superiortemporal","supramarginal","frontalpole","temporalpole","transversetemporal","insula")

ROIS2=c("SurfArea","Thickness")

#SA <- data.frame(read.csv(csvFILE_SA))
#TH <- data.frame(read.csv(csvFILE_TH))

SA <- data.frame(read.csv(csvFILE_SA,colClasses = "character")) # if you have column names with unstandard symbols ("-") use this
TH <- data.frame(read.csv(csvFILE_TH,colClasses = "character"))

VarNamesSA=names(SA)
VarNamesTH=names(TH)

NsubjSA=dim(SA)[1]
NsubjTH=dim(TH)[1]

subjectNames=SA[,1]

if (NsubjSA != NsubjTH) {
	stop("Number of Subjects with cortical thickness measures do not match those with surface area. Please make sure your files are correct.")
}

Avg_ALL=cbind(subjectNames)
colnames(Avg_ALL)=c("SubjID")

for (i in 1:length(ROIS)) {
	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste("L_",ROIS[i],"_surfavg",sep="")
	R_roi=paste("R_",ROIS[i],"_surfavg",sep="")
	AVG_roi=paste("Mean_",ROIS[i],"_surfavg",sep="")
	#tmp = 0.5*(SA[,which(VarNamesSA==L_roi)]+SA[,which(VarNamesSA==R_roi)])
	     tmp = 0.5*(as.numeric(SA[,which(VarNamesSA==L_roi)])+ as.numeric(SA[,which(VarNamesSA==R_roi)])) # if you have column names with unstandard symbols ("-") use this
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)

	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste("L_",ROIS[i],"_thickavg",sep="")
	R_roi=paste("R_",ROIS[i],"_thickavg",sep="")
	AVG_roi=paste("Mean_",ROIS[i],"_thickavg",sep="")
	#tmp = 0.5*(TH[,which(VarNamesTH==L_roi)]+TH[,which(VarNamesTH==R_roi)])
	     tmp = 0.5*(as.numeric(TH[,which(VarNamesTH==L_roi)])+ as.numeric(TH[,which(VarNamesTH==R_roi)])) # if you have column names with unstandard symbols ("-") use this
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)
}

for (i in 1:length(ROIS2)) {
	if(i == 1){
	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste("L",ROIS2[i],sep="")
	R_roi=paste("R",ROIS2[i],sep="")
	AVG_roi=paste("Mean_Full_",ROIS2[i],sep="")
	#tmp = SA[,which(VarNamesSA==L_roi)]+SA[,which(VarNamesSA==R_roi)]
	      tmp = as.numeric(SA[,which(VarNamesSA==L_roi)]) + as.numeric(SA[,which(VarNamesSA==R_roi)])
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)
	} else {
	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste("L",ROIS2[i],sep="")
	R_roi=paste("R",ROIS2[i],sep="")
	AVG_roi=paste("Mean_Full_",ROIS2[i],sep="")
	#tmp = 0.5 * (SA[,which(VarNamesSA==L_roi)]+SA[,which(VarNamesSA==R_roi)])
	      tmp = 0.5 * (as.numeric(SA[,which(VarNamesSA==L_roi)]) + as.numeric(SA[,which(VarNamesSA==R_roi)]))
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)
	}
}

SummaryAvg_ALL = Avg_ALL[,-1]
SummaryAvg_ALL_dat = colMeans(matrix(as.numeric(unlist(SummaryAvg_ALL)),nrow=nrow(SummaryAvg_ALL)), na.rm=T)

write.csv(SummaryAvg_ALL_dat,file=paste0(outFolder,"/SummaryMeasures.csv"),quote=F,row.names=F)

write.csv(Avg_ALL,paste(outFolder,"/CorticalMeasures_ENIGMA_ALL_Avg.csv",sep=""),quote=F,row.names=F);
