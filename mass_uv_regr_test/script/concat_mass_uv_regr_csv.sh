#!/bin/bash
#$ -S /bin/bash
 

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
scriptDir=/ENIGMA_Regressions/mass_uv_regr_test/scripts/ # directory where you have downloaded the ENIGMA R scripts
resDir=/ENIGMA_Regressions/mass_uv_regr_test/results/  # directory where your results will be
logDir=/ENIGMA_Regressions/mass_uv_regr_test/log/  # directory where your log files will be written

#---Section 2. Configuration variables-----

RUN_ID="Ask your Working Group Leader!"
CONFIG_PATH="https://docs.google.com/spreadsheets/d/142eQItt4C_EJQff56-cpwlUPK7QmPICOgSHfnhGWx-w"
SITE="YourSiteID_here"
ROI_LIST_TXT="$scriptDir/roi_list.txt"

#---Section 5. R binary -- CHANGE this to reflect the full path or your R binary
Rbin=/usr/local/R-3.1.3/bin/R

#---Section 6. DO NOT EDIT. Running the R script
#go into the folder where the script should be run
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


OUT=$scriptDir/log.txt
touch $OUT
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
