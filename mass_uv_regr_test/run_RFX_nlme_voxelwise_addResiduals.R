

#Run
#/usr/local/R-2.9.2_64bit/bin/R --no-save --slave --args MaxNode node <  /ifs/hardi/Neda/SCRIPTS/MULTI_GenoPheno/run_emmaX_ROI.R

cmdargs = commandArgs(trailingOnly=T);

node=cmdargs[1];
nodeN=as.numeric(cmdargs[1]);
MaxNode=as.numeric(cmdargs[2]);

table=cmdargs[3];  #req columns: familyID, subjectID, zygosity;  put zygosity info here code as 0,1,2
imgpaths=cmdargs[4]
maskFile=cmdargs[5];
Outputdirectory=cmdargs[6];

grp=cmdargs[7]

phenotype=cmdargs[8]

Ncov=as.numeric(cmdargs[9]);
covariates=cmdargs[10] #semicolon separated list of table headers cov1; cov2; cov3
Nfilters=as.numeric(cmdargs[11]);
filters=cmdargs[12];

Nx=as.numeric(cmdargs[13]);
Ny=as.numeric(cmdargs[14]);
Nz=as.numeric(cmdargs[15]);

maskType=as.numeric(cmdargs[16]);
imgType=as.numeric(cmdargs[17]);



system(paste('mkdir -p', Outputdirectory))

OutputdirectoryEX = paste(Outputdirectory,'/vRFX/',sep='');
dir.create(OutputdirectoryEX);
OutputdirectoryEX = paste(Outputdirectory,'/Residuals/',sep='');
dir.create(OutputdirectoryEX);

## the table with all the info
Table<-read.table(table,sep="\t",header=T,blank.lines.skip = TRUE)
columnnames = colnames(Table);


if (grp=="none") {
DesignMatrix<-data.frame(cbind(familyID=Table$familyID, subjectID=Table$subjectID), imgpaths=Table[,which(columnnames==imgpaths)])
} else {
DesignMatrix<-data.frame(cbind(familyID=Table$familyID, subjectID=Table$subjectID), imgpaths=Table[,which(columnnames==imgpaths)],group=Table[,which(columnnames==grp)])
}

nsub=length(as.vector(Table$subjectID))
print(nsub)



## read and parse covariates if they exist
## add to design Matrix
if (Ncov > 0) {
cov<-as.matrix(0,nrow=nsub,ncol=Ncov)
parsedCov=parse(text=covariates)

for (nc in 1:Ncov) {
covName<-as.character(parsedCov[nc])
print(covName)
origcolnames = colnames(DesignMatrix);
DesignMatrix[,length(DesignMatrix)+1] = Table[,which(columnnames==covName)]
colnames(DesignMatrix) = c(origcolnames,covName);
}
print(paste("done adding covariates",parsedCov))
}


if (Nfilters > 0) {
parsedFilt=parse(text=filters)

for (nf in 1:Nfilters) {
filtName<-as.character(parsedFilt[nf])
print(filtName)
origcolnames = colnames(DesignMatrix);
DesignMatrix[,length(DesignMatrix)+1] = Table[,which(columnnames==filtName)]
colnames(DesignMatrix) = c(origcolnames,filtName);
}
print(paste("done adding filter",parsedFilt))
}




origcolnames = colnames(DesignMatrix);
DesignMatrix[,length(DesignMatrix)+1] = Table[,which(columnnames==phenotype)]
colnames(DesignMatrix) = c(origcolnames,phenotype);
print(colnames(DesignMatrix))
##get rid of all rows with NAs in them

##get rid of all rows with NAs in them
i=which(apply(DesignMatrix,1,function(x)any(is.na(x))));
##get rid of all rows with NAs in them
if (length(i) >0 ){
DesignMatrix<-DesignMatrix[-which(apply(DesignMatrix,1,function(x)any(is.na(x)))),]
}

origcolnames = colnames(DesignMatrix);
pheno=as.vector(DesignMatrix[,which(origcolnames==phenotype)])


## get some variables
nsub=length(as.vector(DesignMatrix$subjectID)) 

print(nsub)

write.table(DesignMatrix[,1:2],paste(Outputdirectory,'/subjectlist.txt',sep=''),sep="\t",row.names=F,col.names=F);
subjectlist= paste(Outputdirectory,'/subjectlist.txt',sep='');

if (grp=="none") {
imgpaths=DesignMatrix$imgpaths
group=NULL
print(imgpaths)
} else {
imgpaths=DesignMatrix$imgpaths
group=DesignMatrix$group
print(imgpaths)
}
#######################################################################

nsub=length(as.vector(DesignMatrix$subjectID)) 

print(nsub)

if (Ncov >0){
covariatesforRFX = matrix(1,nrow=nsub,ncol=Ncov);

}

pheno_covariatesforRFX = matrix(1,nrow=nsub,ncol=Ncov+1);
pheno_covariatesforRFX[,1]=pheno;


origcolnames = colnames(DesignMatrix);
print(origcolnames)
if (Ncov > 0) {
parsedCov=parse(text=covariates)
    cat('    There are',Ncov,'covariates\n');
    for (covariate in 1:Ncov) {
covName=as.character(parsedCov[covariate])
print(covName)
covariatesforRFX[,covariate] = DesignMatrix[,which(origcolnames==covName)];
pheno_covariatesforRFX[,covariate+1] = DesignMatrix[,which(origcolnames==covName)];
    }
        write.table(covariatesforRFX,paste(Outputdirectory,'covars.txt',sep=''),sep="\t",row.names=F,col.names=F);
} else {
    cat('    There are no covariates\n');
}

##read mask
con=file(as.character(maskFile),'rb')

if (maskType==2) { # for float32
   mask=readBin(con,"double",n=Nx*Ny*Nz,size=4,endian='little')
} else if (maskType==1) { # for short
   mask=readBin(con,"integer",n=Nx*Ny*Nz,size=2,signed=0,endian='little')
}  else {
    stop('mask needs to be little endian and short or float, pls specify correctly');
}

close(con)
indx=which(mask!=0)
mask<-as.matrix(mask);

L=length(indx);
cat("size of mask, nodes distributed over, node number\n",sep="");
print(L)
print(MaxNode)
print(nodeN)
numV<-ceiling(L/MaxNode);
minV<-numV*(nodeN-1)+1
maxV<-min(numV*nodeN,L)
print(minV)
print(maxV)
#Lset<-maxV-minV +1
#print(length(Lset))
LsetIndx=indx[minV:maxV];
print(length(LsetIndx))

numsubjects = length(DesignMatrix$subjectID);

outslice = matrix(1,nrow=length(LsetIndx),ncol=1);
outsliceB = matrix(0,nrow=length(LsetIndx),ncol=1);
corr = matrix(0,nrow=length(LsetIndx),ncol=1);
SE = matrix(0,nrow=length(LsetIndx),ncol=1);
tVal = matrix(0,nrow=length(LsetIndx),ncol=1);
C_outslice = matrix(1,nrow=length(LsetIndx),ncol=Ncov);
C_outsliceB = matrix(0,nrow=length(LsetIndx),ncol=Ncov);
res = matrix(0,nrow=numsubjects,ncol=length(LsetIndx));

columnnames = colnames(DesignMatrix);
#Find out how many subjects are in the file

cat('    There are',numsubjects,'subjects in the Design Matrix\n');

write.table(DesignMatrix,paste(Outputdirectory,'DesignMatrix.txt',sep=''),sep="\t",row.names=F,col.names=F);

#######
if (node==1){
system(paste('rm',paste(Outputdirectory,phenotype,"_information_file.txt",sep="")));
	zz <- file(paste(Outputdirectory,phenotype,"_information_file.txt",sep=""),"w")
	writeLines(paste("   Table file is:",table),con=zz,sep="\n")
	writeLines(paste("   grouping factor is:",grp),con=zz,sep="\n")
	writeLines(paste("   phenotype is:",phenotype),con=zz,sep="\n")
	writeLines(paste("   phenotype min:",min(pheno_covariatesforRFX[,1])),con=zz,sep="\n")
	writeLines(paste("   phenotype max:",max(pheno_covariatesforRFX[,1])),con=zz,sep="\n")
	writeLines(paste("   phenotype mean:",mean(pheno_covariatesforRFX[,1])),con=zz,sep="\n")
	writeLines(paste("   phenotype median:",median(pheno_covariatesforRFX[,1])),con=zz,sep="\n")
	writeLines(paste('   There are',numsubjects,'subjects in the analysis'),con=zz,sep="\n")
	writeLines(paste("   the image paths are: "),con=zz,sep="\n")
        writeLines(paste("              ",imgpaths),con=zz,sep="\n")
if (Ncov > 0){
for (n in 1: Ncov){
	writeLines(paste("   Covariate:",parsedCov[n]),con=zz,sep="\n")
}}
if (Nfilters > 0){
for (n in 1: Nfilters){
	writeLines(paste("   Filter:",parsedFilt[n]),con=zz,sep="\n")
}}
	writeLines(paste("   Subject-wise residuals printed out after regressing for covariates only. The trait of interest was NOT used in the model. "),con=zz,sep="\n")
	close(zz)
}
#######


library(nlme)

ROIval<-matrix(0,nrow=numsubjects,ncol=length(LsetIndx))
for (sub in 1: numsubjects) {	
print(as.character(imgpaths[sub]))

con=file(as.character(imgpaths[sub]),'rb')
	
if (imgType==2) { # for float32
   img=readBin(con,"double",n=Nx*Ny*Nz,size=4,endian='little');
} else if (imgType==1) { # for short
   img=readBin(con,"integer",n=Nx*Ny*Nz,size=2,signed=0,endian='little')
}  else {
    stop('images needs to be little endian and short or float, pls specify correctly');
}

img<-as.matrix(img);
	ROIval[sub,]<-img[LsetIndx]
	close(con)	
	}

for (vox in 1: length(LsetIndx)) {

#print(vox)
Ys=ROIval[,vox]
if (grp=="none") {

nophenomodel<-lm(Ys ~ covariatesforRFX);
res[,vox]=transpose(as.vector(nophenomodel$residuals))

model<-lm(Ys ~ pheno_covariatesforRFX)

summarymodel <- summary(model,'correlation'=TRUE)

outslice[vox] = summarymodel$coefficients[2,4]
outsliceB[vox] = summarymodel$coefficients[2,1]
SE[vox] = summarymodel$coefficients[2,2]
tVal[vox] = summarymodel$coefficients[2,3]
corr[vox] = summarymodel$correlation[2,1]


if (Ncov > 0 ) {
for (nc in 1:Ncov){
C_outslice[vox,nc] = summarymodel$coefficients[2+nc,4]
C_outsliceB[vox,nc] = summarymodel$coefficients[2+nc,1]
}}

} else {
nophenomodel<-lme(Ys ~ covariatesforRFX, random= ~ 1 | group, control=lmeControl(msMaxIter=50, returnObject=TRUE));
res[,vox]=transpose(as.vector(residuals(nophenomodel, type="response")))

model<-lme(Ys ~ pheno_covariatesforRFX, random= ~ 1 | group, control=lmeControl(msMaxIter=50, returnObject=TRUE));

summarymodel <- summary(model)

outslice[vox] = summarymodel$tTable[2,5]
outsliceB[vox] = summarymodel$tTable[2,1]
corr[vox]<- summarymodel$corFixed[2,1]
SE[vox]<- summarymodel$tTable[2,2]
tVal[vox]<- summarymodel$tTable[2,4]

if (Ncov > 0 ) {
for (nc in 1:Ncov){
C_outslice[vox,nc] = summarymodel$tTable[2+nc,5]
C_outsliceB[vox,nc] = summarymodel$tTable[2+nc,1]
}}

}


}

write.table(outslice,paste(OutputdirectoryEX,phenotype,'_Pvals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
write.table(outsliceB,paste(OutputdirectoryEX,phenotype,'_Bvals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
write.table(corr,paste(OutputdirectoryEX,phenotype,'_Corr_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
write.table(SE,paste(OutputdirectoryEX,phenotype,'_SE_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
write.table(tVal,paste(OutputdirectoryEX,phenotype,'_Tvals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);

if (Ncov > 0 ) {
for (nc in 1:Ncov){
write.table(C_outslice[,nc],paste(OutputdirectoryEX,parsedCov[nc],'_Pvals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
write.table(C_outsliceB[,nc],paste(OutputdirectoryEX,parsedCov[nc],'_Bvals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
}
}

res1<- matrix(0,nrow=length(LsetIndx),ncol=1);
for (sub in 1:nsub) {
subjectName=as.character(DesignMatrix$subjectID[sub])
res1<-res[sub,]
write.table(res1,paste(Outputdirectory,'/Residuals/',subjectName,'_RawResiduals_node',node,'.txt',sep=''),sep="\t",row.names=F,col.names=F);
}

