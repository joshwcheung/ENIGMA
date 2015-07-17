#!/bin/bash

#
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA 2014.
#

# this is the first part of the association script 
# it will filter through yout combinedROItable.csv file
# and remove the ROIs we are not going to evaluate this round
# including the lateralized measures
# make sure you have all covariates (including AffectionStatus if you have patients and any dummy variables for site/scanner differences in that CSV file)
# if you want to add more columns easily and automatically, look into the enigma_backend directory and use the "add_Info.R" script

######
# After running this script 
# a new csv file will be output named "combinedROItable_eDTI4GWAS.csv"
# which we will use for GWAS.

##################################
######## USER INPUTS #############
run_directory=/ENIGMA/eGWAS/SCRIPTS/enigma_backend/                        # where all the enigma association scripts are stored
Rbin=/usr/local/R/bin/R                 												# path to R binary

csvFILE=/ENIGMA/eGWAS/eDTI/combinedROItable.csv        #  path to the csv file created from the ROI extractions
csvFOLDER=/ENIGMA/eGWAS/eDTI/      							#  directory to write out the updated and filtered csv file (make sure you have writing permissions!)

######## USER INPUTS #############

cd ${run_directory}

${Rbin} --no-save --slave --args ${csvFILE} ${csvFOLDER} <  ${run_directory}/eDTI_functions.R