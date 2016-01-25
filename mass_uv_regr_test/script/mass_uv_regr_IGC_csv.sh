#!/bin/bash
#$ -S /bin/bash
#$ -o /ifshome/disaev/log -j y  ###### Path to your own log file directory 

#----Wrapper for csv version of mass_uv_regr.R script.
#----See readme to change the parameters for your data
#-Dmitry Isaev
#-Boris Gutman
#-Neda Jahanshad
# Beta version for testing on sites.
#-Imaging Genetics Center, Keck School of Medicine, University of Southern California
#-ENIGMA Project, 2015
# enigma@ini.usc.edu 
# http://enigma.ini.usc.edu
#-----------------------------------------------

#---Section 1. Script directories
scriptDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr_test/script
resDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr_test/res
logDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr_test/log

if [ ! -d $scriptDir ]
then
   mkdir -p $scriptDir
fi

if [ ! -d $resDir ]
then
   mkdir -p $resDir
fi

if [ ! -d $logDir ]
then
   mkdir -p $logDir
fi


#---Section 2. Configuration variables-----

RUN_ID="SZDTI"
CONFIG_PATH="https://docs.google.com/spreadsheets/d/142eQItt4C_EJQff56-cpwlUPK7QmPICOgSHfnhGWx-w"

SITE="dublin"
DATADIR="/ifs/loni/faculty/thompson/four_d/disaev/4Neda_Sinead/ENIGMA_SZ_DTI_beta_test_Dublin_092915"
#DATA_PATH="/ifs/loni/faculty/thompson/four_d/disaev/4Neda_Sinead/ENIGMA_SZ_DTI_beta_test_Dublin_092915"

ROI_LIST=("ACR" "ACR_L" "ACR_R" "ALIC" "ALIC_L" "ALIC_R") # "AverageFA" "BCC" "CC" "CGC" "CGC_L" "CGC_R" "CGH" "CGH_L" "CGH_R" "CR" "CR_L" "CR_R" "CST" "CST_L" "CST_R" "EC" "EC_L" "EC_R" "FX" "FX_ST_L" "FX_ST_R" "FXST" "GCC" "IC" "IC_L" "IC_R" "IFO" "IFO_L" "IFO_R" "PCR" "PCR_L" "PCR_R" "PLIC" "PLIC_L" "PLIC_R" "PTR" "PTR_L" "PTR_R" "RLIC" "RLIC_L" "RLIC_R" "SCC" "SCR" "SCR_L" "SCR_R" "SFO" "SFO_L" "SFO_R" "SLF" "SLF_L" "SLF_R" "SS" "SS_L" "SS_R" "UNC" "UNC_L" "UNC_R")



Nnodes=${#ROI_LIST[@]} 	#Set number of nodes to the length of ROI list
#Nnodes=1		#Set number of nodes to 1 if running without grid

SUBJECTS_COV="/ifs/loni/faculty/thompson/four_d/disaev/4Neda_Sinead/ENIGMA_SZ_DTI_beta_test_Dublin_092915/cov.csv"
EXCLUDE_FILE=""
SHAPE_METR_PREFIX="metr_"

#---Section 3. DO NOT EDIT. some additional processing of arbitrary variables
if [ "$EXCLUDE_FILE" != "" ]; then
	EXCLUDE_STR="-exclude_path $EXCLUDE_FILE"
else
	EXCLUDE_STR=""
fi

if [ "$SHAPE_METR_PREFIX" != "" ]; then
	SHAPE_METR_PREFIX_STR="-shape_prefix $SHAPE_METR_PREFIX"
else
	SHAPE_METR_PREFIX_STR=""
fi


#---Section 4. DO NOT EDIT. qsub variable ---
#cur_roi=${ROI_LIST[${SGE_TASK_ID}-1]}  
Nroi=${#ROI_LIST[@]}	

if [ $Nnodes == 1 ]
then
	SGE_TASK_ID=1
fi

if [ ${SGE_TASK_ID} == 1 ]
then
	touch $scriptDir/roi_list.txt	
	rm $scriptDir/roi_list.txt
	touch $scriptDir/roi_list.txt
	roi_text=$(printf "\",\"%s" ${ROI_LIST[@]})
	roi_text=${roi_text:2}"\""

	echo $roi_text >> $scriptDir/roi_list.txt
fi
NchunksPerTask=$((Nroi/Nnodes))
start_pt=$(($((${SGE_TASK_ID}-1))*${NchunksPerTask}+1))
end_pt=$((${SGE_TASK_ID}*${NchunksPerTask}))

if [ "$SGE_TASK_ID" == "$Nnodes" ]
then
end_pt=$((${Nroi}))
fi

#---Section 5. R binary
#Rbin=/usr/local/R-2.9.2_64bit/bin/R
Rbin=/usr/local/R-3.1.3/bin/R

#---Section 6. DO NOT EDIT. Running the R script
#go into the folder where the script should be run
cd $scriptDir
echo "CHANGING DIRECTORY into $scriptDir"

OUT=log.txt
touch $OUT
for ((i=${start_pt}; i<=${end_pt};i++));
do
	cur_roi=${ROI_LIST[$i-1]}  
	cmd="${Rbin} --no-save --slave --args\
			${RUN_ID}\
			${SITE} \
			${DATADIR} \
			${logDir} \
			${resDir}
			${SUBJECTS_COV} \
			${cur_roi} \
			${CONFIG_PATH} \
			${EXCLUDE_STR} \
			${SHAPE_METR_PREFIX_STR} \
			<  ${scriptDir}/mass_uv_regr.R
		"
	echo $cmd
	echo $cmd >> $OUT
	eval $cmd
done
