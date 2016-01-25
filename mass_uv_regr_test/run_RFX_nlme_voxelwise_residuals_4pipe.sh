#!/bin/bash
#$ -S /bin/bash

node=${1}
MaxNode=${2}

table=${3}  #req columns: familyID, subjectID, zygosity;  put zygosity info here code as 0,1,2

imgpaths=${4}
maskFile=${5}
outputD=${6}

group=${7}
phenotype=${8}


Ncov=${9} # comma seperated list of snps 
covariates=${10} #semicolon separated list of table headers cov1; cov2; cov3
Nfilters=${11}
filters=${12}


Nargs=$#
runresid=0
if [[ $Nargs -eq 13 ]]
then 
runresid=${13}
else 
runresid=0
fi


#R binary
Rbin=/usr/local/R-2.9.2_64bit/bin/R
cmd="${Rbin} --no-save --slave --args ${node} ${MaxNode} ${table} ${imgpaths} ${maskFile} ${outputD} ${group} ${phenotype} ${Ncov} ${covariates} ${Nfilters} ${filters} ${runresid}  <  /ifs/loni/faculty/njahansh/tools/4Pipeline/vREGRESSION/run_RFX_nlme_voxelwise_addResiduals.R"

echo $cmd

#Run the OrganizeFiles.R
${Rbin} --no-save --slave --args ${node} ${MaxNode} ${table} ${imgpaths} ${maskFile} ${outputD} ${group} ${phenotype} ${Ncov} ${covariates} ${Nfilters} ${filters} ${runresid}  <  /ifs/loni/faculty/njahansh/tools/4Pipeline/vREGRESSION/run_RFX_nlme_voxelwise_addResiduals.R


