#!/bin/bash

#
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA_DTI 2014.
#

##################################
######## USER INPUTS #############
##################################

run_directory=/ENIGMA/eGWAS/SCRIPTS/enigma_backend/      						# Directory where all the enigma association scripts are stored
Rbin=/usr/local/R/bin/R 									 							   # Full path to R binary

MDScsvFILE=/ENIGMA/eGWAS/HM3mds2R.mds.csv   				 							#  Path to your HM3mds2Rmds.csv file -- has 4 MDS components to use as covariates (output from the MDS Analysis Protocol)
combinedROItableFILE=/ENIGMA/eGWAS/eDTI/combinedROItable_eDTI4GWAS.csv  #  Path to the csv file where your phenotypes and covariates are stored after running ./run0_E3_GWAS_format.sh

#
# Please give some information about the covariate coding you used:
#
ageColumnHeader='Age' #  The column header for your age covariate
sexColumnHeader='Sex' #  The column header for your sex covariate
maleIndicator=1       #  What is the indicator for males in the sex column (M? 1? 2? ... )
related=0                                 # Does you sample have related or unrelated subjects? 0 for unrelated sample, 1 (or anything else for related)
patients=0            #  Does your dataset contain patients? (mark 0 for no, 1 for yes).  
                      #    If your sample has patients and controls make sure you have a column, (called 'AffectionStatus')
                      #     In 'AffectionStatus' patients are marked with 1 and healthy controls with a 0.
                      #     If you have patients but the column name is NOT 'AffectionStatus', instead of 1, specify the column name.
							 							 
peddatdir=/ENIGMA/eGWAS/eDTI/PedDat/				# Output diriectory for the ped and dat file outputs (folder will be created for you)


if [ $related -eq 0 ]
then
mach2qtl_DL=0                       				# UNRELATED ONLY: Have you downloaded mach2qtl yet? Mark 0 for no, 1 for yes
run_machdir=${run_directory}/mach2qtl/              # UNRELATED ONLY: Directory where you will download and compile mach2qtl installed (probably can leave as is)
localfamFILE="None"                 				# UNRELATED ONLY: Keep as is.
else
localfamFILE=/ENIGMA/eGWAS/genotypes/local.fam      		# RELATED ONLY: Path to your local.fam file outputted during the Genetic Imputation step
merlin_DL=0                                        # RELATED ONLY: Have you downloaded and compiled merlin-offline yet? Mark 0 for no, 1 for yes
merlin_directory=${run_directory}/merlin/           # RELATED ONLY: Create a directory to download and compile the merlin code (probably can leave as is)
fi

######################################
######## END USER INPUTS #############
######################################


######## Begin ENIGMA phenotypes / covariate inputs #########
eName="DTI"  ## what type of ENGIMA analysis are you doing here?
## so far your options include "DTI" or "E3_cortex"
## here we can run formating scripts particular to an ENIGMA analysis - at the end we need (1) a set of ROI/column headers and (2) a set of covariates to move forward.

######## we have some scripts ready for analysis-specific phenotype/covariate formatting
if [ "$eName" == "DTI" ]
then
## set ROIS
ALL_ROIS="ACR;ALIC;AverageFA;BCC;CC;CGC;CGH;CR;EC;FXST;GCC;IC;PCR;PLIC;PTR;RLIC;SCC;SCR;SFO;SLF;SS"
else 
	if [ "$eName" == "E3_cortex" ] 
	then
		## set ROIS
		ALL_ROIS="Mean_bankssts_surfavg;Mean_caudalanteriorcingulate_surfavg;Mean_caudalmiddlefrontal_surfavg;Mean_cuneus_surfavg;Mean_entorhinal_surfavg;Mean_fusiform_surfavg;Mean_inferiorparietal_surfavg;Mean_inferiortemporal_surfavg;Mean_isthmuscingulate_surfavg;Mean_lateraloccipital_surfavg;Mean_lateralorbitofrontal_surfavg;Mean_lingual_surfavg;Mean_medialorbitofrontal_surfavg;Mean_middletemporal_surfavg;Mean_parahippocampal_surfavg;Mean_paracentral_surfavg;Mean_parsopercularis_surfavg;Mean_parsorbitalis_surfavg;Mean_parstriangularis_surfavg;Mean_pericalcarine_surfavg;Mean_postcentral_surfavg;Mean_posteriorcingulate_surfavg;Mean_precentral_surfavg;Mean_precuneus_surfavg;Mean_rostralanteriorcingulate_surfavg;Mean_rostralmiddlefrontal_surfavg;Mean_superiorfrontal_surfavg;Mean_superiorparietal_surfavg;Mean_superiortemporal_surfavg;Mean_supramarginal_surfavg;Mean_frontalpole_surfavg;Mean_temporalpole_surfavg;Mean_transversetemporal_surfavg;Mean_insula_surfavg;Mean_bankssts_thickavg;Mean_caudalanteriorcingulate_thickavg;Mean_caudalmiddlefrontal_thickavg;Mean_cuneus_thickavg;Mean_entorhinal_thickavg;Mean_fusiform_thickavg;Mean_inferiorparietal_thickavg;Mean_inferiortemporal_thickavg;Mean_isthmuscingulate_thickavg;Mean_lateraloccipital_thickavg;Mean_lateralorbitofrontal_thickavg;Mean_lingual_thickavg;Mean_medialorbitofrontal_thickavg;Mean_middletemporal_thickavg;Mean_parahippocampal_thickavg;Mean_paracentral_thickavg;Mean_parsopercularis_thickavg;Mean_parsorbitalis_thickavg;Mean_parstriangularis_thickavg;Mean_pericalcarine_thickavg;Mean_postcentral_thickavg;Mean_posteriorcingulate_thickavg;Mean_precentral_thickavg;Mean_precuneus_thickavg;Mean_rostralanteriorcingulate_thickavg;Mean_rostralmiddlefrontal_thickavg;Mean_superiorfrontal_thickavg;Mean_superiorparietal_thickavg;Mean_superiortemporal_thickavg;Mean_supramarginal_thickavg;Mean_frontalpole_thickavg;Mean_temporalpole_thickavg;Mean_transversetemporal_thickavg;Mean_insula_thickavg;Full_SurfArea;Mean_Full_Thickness"
	else 
		echo "this is not yet an ENIGMA analysis compatable with these pipelines"
	fi
fi

##
######## END ENIGMA inputs #########


######## No need to edit below this line #########

# make sure all files are downloaded and installed for GWAS
if [ $related -eq 0 ]
then
    if [ $mach2qtl_DL -eq 0 ]
    then
    mkdir ${run_machdir}
    cd ${run_machdir}
    wget "http://www.sph.umich.edu/csg/abecasis/MACH/download/mach2qtl.source.V112.tgz"
    tar -zxvf mach2qtl.source.V112.tgz #mach2qtl.tar.gz
    wget -O mach2qtl/Main.cpp "http://enigma.ini.usc.edu/wp-content/uploads/GWAS_scripts/Main.cpp"
    make all
    fi
else
    if [ $merlin_DL -eq 0 ]
    then
    ## download merlin and compile the code
    mkdir ${merlin_directory}
    cd ${merlin_directory}
    wget "http://www.sph.umich.edu/csg/abecasis/merlin/download/merlin-1.1.2.tar.gz"
    tar -zxvf merlin-1.1.2.tar.gz
    cd merlin-1.1.2/libsrc
    wget "http://genepi.qimr.edu.au/staff/sarahMe/mach2merlin/PedigreeGlobals.cpp"
    mv PedigreeGlobals.cpp.1 PedigreeGlobals.cpp
    cd ../
    wget -O merlin/FastAssociation.cpp "http://enigma.ini.usc.edu/wp-content/uploads/GWAS_scripts/FastAssociation.cpp"
    make all
    cd ${merlin_directory}/
    wget "http://genepi.qimr.edu.au/staff/sarahMe/mach2merlin/1KGPminimac2merlin.pl"
    chmod -R 755 ./*
    fi
fi

#cd to the run_directory
cd ${run_directory}

# run R script to create ped and dat files for GWAS. eName will name outputs accordingly 
${Rbin} --no-save --slave --args ${MDScsvFILE} ${localfamFILE} ${combinedROItableFILE} ${ageColumnHeader} ${sexColumnHeader} ${maleIndicator} ${patients} ${related} ${peddatdir} ${ALL_ROIS} ${eName} <  createDatPed_flexible_files.R

