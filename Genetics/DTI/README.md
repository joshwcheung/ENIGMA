# ENIGMA Consortium GWAS Protocols for ENIGMA DTI

*Version 1.02 – April 15, 2015*

**Written by Neda Jahanshad and Derrek Hibar**

Before starting, you need to download and install some required programs (which 
you may already have). Please address any praises/ questions/ comments and 
potential complaints to: neda.jahanshad@ini.usc.edu, 
support.enigmaDTI@ini.usc.edu

---

*   R can be downloaded [here](http://cran.r-project.org/)
*   An ssh client can be downloaded 
    [here](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) 
    (though there are many to choose from).
*   Download the association scripts:

```bash
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/Genetics/DTI
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/Genetics/enigma_backend
```

---

*   Change from previous version: example input for merlin_DL variable in run1 
    step is 0

---

You will need four files to run the association analysis (described below).
*   `combinedROItable.csv`- This file contains the mean FA values for all the 
    extracted ROIs. Please make sure to remove all subjects that had poor 
    quality FA images.
*	We will be removing *all ROIs for a subject if it did not pass QC*. This is 
    because registration, incorrect gradient files and severe artifacts affect 
    the entire FA image and generally not a particular structure. Please also 
    make sure that the subject IDs in **the first column (subjectID)** match the
    ID format in the other files used in the analysis. Also, be sure to save 
    this file as a comma separated (CSV) file after making any edits.
    *   This file should already contain all the covariates you plan to use for 
        GWAS in separate columns.
    *	Most covariates will only be Age, Sex, and if you have both patients and
        controls -- a column marking patients as 1 and controls as 0.
    *	Other common covariates will be a dummy covariate for each imaging site 
        used (if multiple), or protocol (again if multiple)
        *   Do not hesitate to contact the support team if you have any 
            questions as to what covariates you should include in the GWAS!!
    *	Please note, we will center and compute covariates for age-x-sex, 
        age<sup>2</sup>, and age<sup>2</sup>-sex, so make sure to leave these 
        out.
    *	If you do not have all your covariates in your combinedROItable.csv 
        file, fear not! We make it easy for you to add them in using the 
        addInfo.R script in the enigma_backend directory.
*   `HM3mds2R.mds.csv` – In the genetic imputation protocol, you previously 
    performed an MDS analysis to estimate the ancestry of each subject in your 
    cohort (and to remove subjects with non-homogenous ancestry). Please make 
    sure that the final version of the HM3mds2R.mds.csv file that you end up 
    using in the association analysis contains only the subjects you want to 
    keep in the analysis (i.e. that have a homogenous ancestry). You can plot 
    the MDS values using the code provided in the [imputation protocols]
    (../ENIGMA2/Imputation). You can uncomment the line in the plotting 
    code to plot the MDS values with the subject IDs overlaid and then remove 
    those subjects from your HM3mds2R.mds.csv file in Excel (or any text 
    editor).
    *	`local.fam` - If you have related individuals, we will also need this 
        file from the imputation process to extract the relatedness between 
        subjects.

---

Create a working directory and copy all of the required files inside. 

Make a directory called SCRIPTS

```bash
enigma@-> mkdir SCRIPTS
```

Move the association scripts into the SCRIPTS directory.

Your working directory should look something like this:

```bash
enigma@-> ls

combinedROItable.csv 
HM3mds2R.mds.csv
SCRIPTS/
```

Change directories to move into the SCRIPTS/ directory. 
We will run three scripts in order (run0, run1, run2) to setup and then perform 
the GWAS.

For each step, user inputs that need modification are *italicized*. 
**Bolded sections** may or may not need to be addressed depending on the dataset

---

Step 1) `run0_eDTI_GWAS_format.sh`

After *setting user inputs* (see below), make sure you have executable 
permissions to the script and run as with any other bash script on linux:

```bash
chmod 755 run0_eDTI_GWAS_format.sh
./run0_eDTI_GWAS_format.sh
```

---

Open `run0_eDTI _GWAS_format.sh` and set the following parameters (see 
descriptions):

<pre>
#Directory where all the enigma association scripts are stored
<i>run_directory</i>=/ENIGMA/eGWAS/SCRIPTS/enigma_backend

#Full path to R binary
<i>Rbin</i>=/usr/local/R/bin/R

#Path to the FA and covariate csv file
<i>csvFILE</i>=/ENIGMA/eGWAS/eDTI/combinedROItable.csv

#Directory to write out the updated and filtered csv file (this folder will be 
#created for you)
<i>csvFOLDER</i>=/ENIGMA/eGWAS/eDTI/
</pre>

Step 2) `run1_GWAS_flexible_step1.sh`  -- You will need to have imputed your 
data to 1000Genomes by this step. This tells the program how to set things up: 
what your covariates are, if you have patients and controls, how sex is coded, 
and what columns correspond to key covariates.

You will also indicate if you have family data and depending on what you choose 
there are specific inputs that are important to set -- see **bold**. Also let 
the program know if you have already downloaded the needed GWAS programs 
(mach2qtl or merlin) and if so where they are located so there is no need to 
re-download and install them.

After *setting user inputs* (see below), make sure you have executable 
permissions to the script and run as with any other bash script on linux:

```bash
chmod 755 run1_GWAS_flexible_step1.sh
./run1_GWAS_flexible_step1.sh
```

---

Open `run1_GWAS_flexible_step1.sh` and set the following parameters (see below):

<pre>
#Directory where all the enigma association scripts are stored
<i>run_directory</i>=/ENIGMA/eGWAS/SCRIPTS/enigma_backend/

#Full path to R binary
<i>Rbin</i>=/usr/local/R/bin/R

#Path to your HM3mds2Rmds.csv file -- has 4 MDS components to use as covariates 
#(output from the MDS Analysis Protocol)
<i>csvFILE</i>=/ENIGMA/eGWAS/HM3mds2R.mds.csv

#Path to the csv file where your phenotypes and covariates are stored after 
#running ./run0_eDTI_GWAS_format.sh
#Note this file was created for you in run0
<i>combinedROItableFILE</i>=/ENIGMA/eGWAS/eDTI/combinedROItable_eDTI4GWAS.csv

#
#Please give some information about the covariate coding you used:
#
<i>ageColumnHeader</i>='Age'   #The column header for your age covariate
<i>sexColumnHeader</i>='Sex'   #The column header for your sex covariate
<i>maleIndicator</i>=1         #Males in the sex column coded as (M? 1? 2? ... )
<i>patients</i>=1              #Does your dataset contain patients? (mark 0 for 
                        #no, # 1 or 'AffectionStatus' or another column 
                        #header for yes).
                        #If your sample has patients and controls make sure you 
                        #have a column, (for example called 'AffectionStatus')
                        #In 'AffectionStatus' patients are marked with 1 and 
                        #healthy controls with a 0.
                        #If you have patients but the column name is NOT 
                        #'AffectionStatus', instead of 1, specify the column name.

#
#Output diriectory for the ped and dat file outputs (folder will be created for 
#you)
#
<i>peddatdir</i>=/ENIGMA/eGWAS/PedDat/

#
#Does you sample have related or unrelated subjects?
#

<i>related</i>=0  # Mark 0 for unrelated sample, 1 for related

if [ $related -eq 0 ]
then
<b>mach2qtl_DL</b>=0   # UNRELATED ONLY: Have you downloaded mach2qtl yet? Mark 0 for 
                # no, 1 for yes
<b>run_machdir</b>=${run_directory}/mach2qtl/  # UNRELATED ONLY: Directory where you 
                                        # will download and compile mach2qtl 
                                        # installed (probably can leave as is)
<b>localfamFILE</b>="None" # UNRELATED ONLY: Keep as is.

else

<b>localfamFILE</b>=/ENIGMA/eGWAS/local.fam    # RELATED ONLY: Path to your local.fam 
                                        # file outputted during the Genetic 
                                        # Imputation step
<b>merlin_DL</b>=0 # RELATED ONLY: Have you downloaded and compiled merlin-offline? 
            # Mark 0 for no, 1 for yes
<b>merlin_directory</b>=${run_directory}/merlin/   # RELATED ONLY: Create a directory 
                                            # to download and compile the merlin
                                            # code (probably can leave as is)

fi
</pre>

Step 3) `run2_GWAS_flexible_step2.sh` -- this setup files for performing GWAS.

You will also indicate if you have related (family) data and where the GWAS 
programs (mach2qtl or merlin) are located on your system.

```bash
chmod 755 run2_GWAS_flexible_step2.sh
```

1.	This script can be run in batch-mode if you have a Sun Grid Engine (qsub):
    *   Example: qsub -q "qname.q" -t 1:"Nnodes" run2_GWAS_flexible_step2.sh
2.	If you do not have access to an SGE/qsub compute server, you can run each 
    GWAS in a series locally (will take between 24-36 hours to run):
    *   Set Nnodes=1, and then run by calling ./run2_GWAS_flexible_step2.sh
3.	If you want a text file list of commands so that you can batch submit using 
    another system:
    *   Set Nnodes=1, Set mode="manual", and then run by calling 
        ./run2_GWAS_flexible_step2.sh
    *   This will create text files that can be found in your current working 
        directory

---

<pre>
#Directory where all the enigma association scripts are stored
<i>run_directory</i>=/ENIGMA/eGWAS/SCRIPTS/enigma_backend/

#You can split up the processing into this many nodes, if running in series or 
#manually, Nnodes=1
<i>Nnodes</i>=1

#Give the directory to the imputed output from Mach (after imputation scripts)
<i>machFILEdir</i>=/ENIGMA/Study_Genotypes/1KGPref/Mach/

#Give the dir to the ped and dat files created in run1_GWAS_flexible_step1.sh
<i>peddatdir</i>=/ENIGMA/eGWAS/PedDat/

#Give abbreviated name of your sample, no spaces in the name (i.e. ADNI)
<i>samplename</i>=ADNI

#Directory for the output from mach2qtl or merlin (folder will be created for 
#you)
<i>GWASout</i>=/ENIGMA/eGWAS/GWAS_out/

#Can change to "manual" if you want to output a list of commands that you can 
#batch process yourself, otherwise set to "run"
<i>mode</i>="run"

#H for healthy, HD for healthy and disease, (or D for disease-only datasets)
<i>status</i>=H

#
#Does you sample have related or unrelated subjects?
#

#0 for unrelated sample, 1 (or anything else for related)
<i>related</i>=0

if [ $related -eq 0 ]
then

#give the directory to where you installed and compiled mach2qtl (the parent 
#folder of the executables/ folder)`
<i>run_machdir</i>=/ENIGMA/eGWAS/enigma_backend/mach2qtl/

else

#RELATED ONLY: give the directory to where you installed and compiled Merlin in 
#step 1
<i>merlin_directory</i>=/ENIGMA/eGWAS/enigma_backend/merlin/

#RELATED ONLY: give the directory to the imputed output for merlin (will be 
#created if files don't exist), see 
#http://genepi.qimr.edu.au/staff/sarahMe/mach2merlin.html
<i>merlinFILEdir</i>=/ENIGMA/eGWAS/merlin/

fi
</pre>

Each group has a secure space on the ENIGMA upload server to upload the .info.gz
(from imputation) and gzipped association result files. Please contact 
support.enigmaDTI@ini.usc.edu to obtain upload information for your group’s 
data.
