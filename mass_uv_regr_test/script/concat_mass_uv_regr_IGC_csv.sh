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
ROI_LIST_TXT="$scriptDir/roi_list.txt"

#---Section 5. R binary
#Rbin=/usr/local/R-2.9.2_64bit/bin/R
Rbin=/usr/local/R-3.1.3/bin/R

#---Section 6. DO NOT EDIT. Running the R script
#go into the folder where the script should be run
cd $scriptDir
echo "CHANGING DIRECTORY into $scriptDir"

OUT=log.txt
touch $OUT
#for ((i=${start_pt}; i<=${end_pt};i++));
#do
	cur_roi=${ROI_LIST[$i-1]}  
	cmd="${Rbin} --no-save --slave --args\
			${RUN_ID}\
			${SITE} \
			${logDir} \
			${resDir} \
			${ROI_LIST_TXT} \
			${CONFIG_PATH} \
			<  ${scriptDir}/concat_mass_uv_regr.R"
	echo $cmd
	echo $cmd >> $OUT
	eval $cmd
#done
