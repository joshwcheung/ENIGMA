#!/bin/bash

# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA_DTI 2014.
# */

######## SH INPUTS #############
run_machdir=${1}  #give the directory to the imputed output from Mach/minimac
machdir=${2}
peddatdir=${3}  #give the dir to the ped and dat files just created
samplename=${4}  #give abbreviated name of your sample, no spaces in the name (i.e. ADNI)
mach2qtlout=${5}  #make a folder for the output from mach2qtl
status=${6}  ### this should be H for healthy, D for disease or HD for healthy and disease
Nnodes=${7}  # can split up the processing into N nodes
totalFiles=${8}
eName=${9}
SGE_TASK_ID=${10}
mode=${11}
######## END SH INPUTS #########


#ls -1 ${machdir}/chunk*-ready4mach.*.imputed.dose.gz > ${mach2qtlout}/fileList.txt
#totalFiles=`ls ${machdir}/chunk*-ready4mach.*.imputed.dose.gz |wc -w`

NchunksPerTask=$((totalFiles/Nnodes))
start_pt=$(($((${SGE_TASK_ID}-1))*${NchunksPerTask}+1))
end_pt=$((${SGE_TASK_ID}*${NchunksPerTask}))
date=$(date +'%Y%m%d')

if [ "$end_pt" == "$totalFiles" ]
then
end_pt=$((${totalFiles}))
fi

if [ "$mode" != "run" ]; then
	echo "Running in MANUAL mode"	
	echo "Commands will be stored in the text files called Step1_Manual_GWAS.txt and Step2_Manual_GZIP.txt"
fi

case $status in

    H)

    for ((i=${start_pt}; i<=${end_pt};i++));
        do
        fileDose=$(awk -v "line=$i" 'NR == line' ${mach2qtlout}/fileList_${SGE_TASK_ID}.txt )
        fileInfo=`echo ${fileDose%.dose.gz}.info.gz`
        chr=$(basename  ${fileInfo} | awk -F '.' '{print $2}')
        chunk=$(basename  ${fileInfo} | awk -F '-' '{print $1}')

        wSAOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wSA_${chr}_${chunk}_${date}.out
		wTHICKOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wTHICK_${chr}_${chunk}_${date}.out
		woOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wo_${chr}_${chunk}_${date}.out
        wSADatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wSA.dat
		wTHICKDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wTHICK.dat
		woDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wo.dat
        pedFileName=${peddatdir}/ENIGMA_${eName}_PEDfile_healthy.ped
		
		if [ "$mode" == "run" ]; then
        	echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}
        	gzip -f ${wSAOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}
        	gzip -f ${wTHICKOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}"
			${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}
			gzip -f ${woOutName}
		else
			echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wSAOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wTHICKOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${woOutName}" >> Step2_Manual_GZIP.txt
		fi
	done
    ;;

    D)
    for ((i=${start_pt}; i<=${end_pt};i++));
        do
        fileDose=$(awk -v "line=$i" 'NR == line' ${mach2qtlout}/fileList_${SGE_TASK_ID}.txt )
        fileInfo=`echo ${fileDose%.dose.gz}.info.gz`
        chr=$(basename  ${fileInfo} | awk -F '.' '{print $2}')
        chunk=$(basename  ${fileInfo} | awk -F '-' '{print $1}')

        wSAOutName=${mach2qtlout}/${samplename}_${eName}_disease_wSA_${chr}_${chunk}_${date}.out
		wTHICKOutName=${mach2qtlout}/${samplename}_${eName}_disease_wTHICK_${chr}_${chunk}_${date}.out
		woOutName=${mach2qtlout}/${samplename}_${eName}_disease_wo_${chr}_${chunk}_${date}.out
        wSADatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_patients_wSA.dat
		wTHICKDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_patients_wTHICK.dat
		woDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_patients_wo.dat
        pedFileName=${peddatdir}/ENIGMA_${eName}_PEDfile_patients.ped
		if [ "$mode" == "run" ]; then
       	 	echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}"
       	 	${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}
       	 	gzip -f ${wSAOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}"
       	 	${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}
       	 	gzip -f ${wTHICKOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}"
       	 	${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}
       	 	gzip -f ${woOutName}
		else
			echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wSAOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wTHICKOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${woOutName}" >> Step2_Manual_GZIP.txt
		fi
    done
    ;;

    HD)
# we are actually going to double up here, and run 2x as many runs per node one for healthy only and one for the full group
    for ((i=${start_pt}; i<=${end_pt};i++));
        do
        fileDose=$(awk -v "line=$i" 'NR == line' ${mach2qtlout}/fileList_${SGE_TASK_ID}.txt )
        fileInfo=`echo ${fileDose%.dose.gz}.info.gz`
        chr=$(basename  ${fileInfo} | awk -F '.' '{print $2}')
        chunk=$(basename  ${fileInfo} | awk -F '-' '{print $1}')

        ###### run healthy and disease -- full group
        wSAOutName=${mach2qtlout}/${samplename}_${eName}_mixedHD_wSA_${chr}_${chunk}_${date}.out
		wTHICKOutName=${mach2qtlout}/${samplename}_${eName}_mixedHD_wTHICK_${chr}_${chunk}_${date}.out
		woOutName=${mach2qtlout}/${samplename}_${eName}_mixedHD_wo_${chr}_${chunk}_${date}.out
        wSADatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_fullGroup_wSA.dat
		wTHICKDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_fullGroup_wTHICK.dat
		woDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_fullGroup_wo.dat
        pedFileName=${peddatdir}/ENIGMA_${eName}_PEDfile_fullGroup.ped
		if [ "$mode" == "run" ]; then
        	echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}
        	gzip -f ${wSAOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}
        	gzip -f ${wTHICKOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}
        	gzip -f ${woOutName}
		else
			echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wSAOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wTHICKOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${woOutName}" >> Step2_Manual_GZIP.txt	
		fi

        ###### run healthy only
        wSAOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wSA_${chr}_${chunk}_${date}.out
		wTHICKOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wTHICK_${chr}_${chunk}_${date}.out
		woOutName=${mach2qtlout}/${samplename}_${eName}_healthy_wo_${chr}_${chunk}_${date}.out
        wSADatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wSA.dat
		wTHICKDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wTHICK.dat
		woDatFileName=${peddatdir}/ENIGMA_${eName}_DATfile_healthy_wo.dat
        pedFileName=${peddatdir}/ENIGMA_${eName}_PEDfile_healthy.ped
		if [ "$mode" == "run" ]; then
        	echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}
        	gzip -f ${wSAOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}
        	gzip -f ${wTHICKOutName}
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}"
        	${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}
        	gzip -f ${woOutName}
		else
			echo "${run_machdir}/executables/mach2qtl --datfile ${wSADatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wSAOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wSAOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${wTHICKDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${wTHICKOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${wTHICKOutName}" >> Step2_Manual_GZIP.txt
			echo "${run_machdir}/executables/mach2qtl --datfile ${woDatFileName} --pedfile ${pedFileName} --infofile ${fileInfo} --dosefile ${fileDose} --samplesize > ${woOutName}" >> Step1_Manual_GWAS.txt
			echo "gzip -f ${woOutName}" >> Step2_Manual_GZIP.txt
		fi
	done
    ;;

esac
