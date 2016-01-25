#!/bin/bash
#$ -S /bin/bash

node=${SGE_TASK_ID}
MaxNode=50

table=/ifs/enigma/Neda/TWINS_GWAS/DATA/ALLsubj_SS_all_info_NJ_Nov2010wKids.txt  

imgpaths=DTI_105_FApath_smooth9
maskFile=/ifs/enigma/Neda/TARGETS/MDT_32subFA_Xall_thr250.img
##maskFile=/ifs/enigma/Neda/TARGETS/MDT_32subT1_TWINS_fixBorders.img
outputD=/ifs/enigma/Neda/TWINS_GWAS/IRON_Tf_Fer/TF/DTI_105_FAsmooth9_ADULTS_covSexAgeFE_wDups_noOutnoAnc_thr250/

group=familyID
phenotype=TRANSFIN


Ncov=3
covariates='Sex;Age;FE'
Nfilters=3
filters='DT105uncropped;ANCESTRY;ADULT'

#DT30singlesubjects


Nx=110
Ny=110
Nz=110

maskType=1
imgType=2

#R binary
Rbin=/usr/local/R-2.9.2_64bit/bin/R

#Run the OrganizeFiles.R
${Rbin} --no-save --slave --args ${node} ${MaxNode} ${table} ${imgpaths} ${maskFile} ${outputD} ${group} ${phenotype} ${Ncov} ${covariates} ${Nfilters} ${filters} ${Nx} ${Ny} ${Nz} ${maskType} ${imgType} <  /ifshome/njahansh/4Pipeline/vREGRESSION/run_RFX_nlme_voxelwise_addResiduals.R  

###/usr/local/R-2.9.2_64bit/bin/R --no-save --slave --args ${MaxNode} ${maskFile} ${outputD} ${phenotype} ${Ncov} ${covariates} ${Nx} ${Ny} ${Nz} <  /ifshome/njahansh/4Pipeline/vREGRESSION/combine_node_data_RFX.R 

###/usr/local/R-2.9.2_64bit/bin/R --no-save --slave --args 50 /ifs/enigma/Neda/TARGETS/MDT_32subFA_Xall_thr250.img /ifs/enigma/Neda/TWINS_GWAS/IRON_Tf_Fer/TF/DTI_105_FAsmooth9_ADULTS_covSexAgeFE_wDups_noOutnoAnc_thr250/ TRANSFIN 3 'Sex;Age;FE' 110 110 110 <  /ifshome/njahansh/4Pipeline/vREGRESSION/combine_node_data_RFX.R 
