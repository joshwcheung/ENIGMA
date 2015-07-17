# ENIGMA Consortium GWAS Protocols GWAS of the Cortex (ENIGMA3)

*Version 1.1 – July 14, 2015*

**Written by Derrek Hibar and Neda Jahanshad**

Before we start, you need to download and install some required programs (which 
you may already have). Please address any questions to: 
enigma3helpdesk@gmail.com.

---

*   R can be downloaded [here](http://cran.r-project.org/)
*   An ssh client can be downloaded 
    [here](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) 
    (though there are many to choose from).
*   Download the association scripts and put them in the same folder as your 
    .csv files:

```bash    
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/Genetics/ENIGMA3
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/Genetics/enigma_backend
```

---

You will need four files to run the association analysis (described below).

*   `CorticalMeasuresENIGMA_SurfAvg.csv` - This file contains the mean surface 
    area within each of the FreeSurfer ROI from the Desikan Atlas. In previous 
    steps you marked individual ROIs as “NA” (without the quotes) if that ROI 
    was poorly segmented for a given subject. There are no additional edits 
    required, however, please make sure that the subject IDs in the first column
    (SubjID) match the ID format in the other files used in the analysis. Also, 
    be sure to save this file as a comma separated (CSV) file after making any 
    edits.
*   `CorticalMeasuresENIGMA_ThickAvg.csv` - This file contains the mean cortical
    thickness within each of the FreeSurfer ROI from the Desikan Atlas. In 
    previous steps you marked individual ROIs as “NA” (without the quotes) if 
    that ROI was poorly segmented for a given subject. There are no additional 
    edits required, however, please make sure that the subject IDs in the first 
    column (SubjID) match the ID format in the other files used in the analysis.
    Also, be sure to save this file as a comma separated (CSV) file after making
    any edits.
*   `HM3mds2R.mds.csv` – In the genetic imputation protocol, you previously 
    performed an MDS analysis to estimate the ancestry of each subject in your 
    cohort (and to remove subjects with non-homogenous ancestry). Please make 
    sure that the final version of the HM3mds2R.mds.csv file that you end up 
    using in the association analysis contains only the subjects you want to 
    keep in the analysis (i.e. that have a homogenous ancestry). You can plot 
    the MDS values using the code provided in the [imputation protocols]
    (Genetics/ENIGMA2/Imputation). You can uncomment the line in the plotting 
    code to plot the MDS values with the subject IDs overlaid and then remove 
    those subjects from your HM3mds2R.mds.csv file in Excel (or any text 
    editor).
*	`Covariates.csv` – This file you will have to create, but it should be 
    relatively similar (but not the same!) as the covariates files previously 
    created for ENIGMA. Using Excel or your favorite spreadsheet program, create
    a file that contains the following columns: SubjID, Age, Sex. Additional 
    columns for dummy covariates (i.e. a covariate to control for different MR 
    acquisitions, if applicable) is optional. Save this spreadsheet as a comma 
    delimited (.csv) text file called Covariates.csv.
    *   **Note:** If your cohort has both patients and healthy controls, you 
        should include a covariate called “AffectionStatus”, coded as a binary 
        indicator variable where Controls = 0 and Patients = 1. The final file 
        should have the following columns at a minimum: SubjID, Age, Sex, 
        AffectionStatus. Additional columns for dummy covariates (i.e. a 
        covariate to control for different MR acquisitions, if applicable) is 
        optional.
    *   **Note 2:** Your Covariates.csv file should not contain an missing values
        or NA values. If any covariates are missing the whole subject will be 
        removed from the analysis. Please remove any subject with missing values
        for covariates from the Covariates.csv file before continuing with the scripts
        below.
    
---

Create a working directory and copy all of the required files inside. Unzip the 
association scripts and move the Scripts/ folder into your working directory.

Your working directory should look something like this:

```bash
enigma@-> ls

CorticalMeasuresENIGMA_SurfAvg.csv 
CorticalMeasuresENIGMA_ThickAvg.csv
HM3mds2R.mds.csv
Covariates.csv
SCRIPTS/
```

Change directories to move into the SCRIPTS/ folder. We will run three scripts 
in order (run0, run1, run2) to setup and then perform the GWAS.

For each step, user inputs that need modification are listed below. In some 
cases, we have bolded directions, so please pay close attention to those 
settings. Most of the bolded sections involve separate settings depending on 
whether or not your sample contains related members (a family design) or contain
all unrelated subjects.

---
---
---

### **Step 1) run0_E3_GWAS_format.sh**

After setting user inputs, make sure you have executable permissions to the 
script and run as with any other bash script on linux:

```bash
chmod 755 run0_E3_GWAS_format.sh
./run0_E3_GWAS_format.sh
```

**But first** open `run0_E3_GWAS_format.sh` and set the following parameters 
(see descriptions):

#Set the directory where all the enigma association scripts are stored

```bash
run_directory=/ENIGMA/CortexGWAS/SCRIPTS/enigma_backend                  
```

#Give the **full path** to R binary, can be found by typing `which R` on the 
command line.

```bash
Rbin=/usr/local/R/bin/R                 								 
```

#Give the **full path** to the surf area csv file on your system

```bash
csvFILE_1=/ENIGMA/CortexGWAS/CorticalMeasuresENIGMA_SurfAvg.csv 
```

#Give the **full path** to the thickness csv file on your system

```bash
csvFILE_2=/ENIGMA/CortexGWAS/CorticalMeasuresENIGMA_ThickAvg.csv
```

#Give the **full path** to a directory to write out the updated and filtered csv
file (this folder will be created for you) 

```bash
csvFOLDER=/ENIGMA/CortexGWAS/E3     									 
```

#Please indicate the **full path** to the file where your covariate data is 
stored so that we can merge in relevant covariates to the ENIGMA phenotype files

```bash
TableFile=/ENIGMA/CortexGWAS/Covariates.csv
```

#What is the column name where the subject IDs are listed in your Covariates.csv
file (needed to match subject-by-subject with the ENIGMA files)

```bash
TableSubjectID_column="SubjID"
```

#How many covariates will you be using (note, at a minimum we would require 2 
or 3 -- age and sex and diagnosis (if dataset consists of patients and 
controls), and any additional site-specific variables, please contact us with 
questions!)

```bash
Ncov=3
```

*   **Note:** Remember to update this if you change the number of covariates in 
    the line below. For example, if you have a healthy-only dataset (i.e. no 
    AffectionStatus covariate) you might set this to 2.

#In your covariates file, what are the column headers for the covariates you 
would like to include? Make sure to separate them here with a semi-colon and no 
space!

```bash
covariates="Age;Sex;AffectionStatus"
```

*   **Note:** If you have a healthy-only cohort you do not need to include an 
    AffectionStatus covariate. If you add in additional covariates to control 
    for site for example, you can add them here (the name just has to match the 
    column name for that variable in the Covariates.csv file). Also, make sure 
    that the number of covariates in this step matches the Ncov variable defined
    above.

---
---
---

### **Step 2) run1_GWAS_flexible_step1.sh**

You will need to have imputed your data to 1000Genomes by this step. This tells 
the program how to set things up: what your covariates are, if you have patients
and controls, how sex is coded, and what columns correspond to key covariates.

You will also indicate if you have family data and depending on what you choose 
there are specific inputs that are important to set (see bolded directions 
below). 

Also for the purposes of this analysis we have created modified versions of the 
association programs (mach2qtl and merlin). Please use these new versions of the
code and **NOT** previous versions on your system.

After setting user inputs, make sure you have executable permissions to the 
script and run as with any other bash script on linux:

```bash
chmod 755 run1_GWAS_flexible_step1.sh
./run1_GWAS_flexible_step1.sh
```

**But first** open `run1_GWAS_flexible_step1.sh` and set the following 
parameters (see below):

#Give the **full path** to where all the enigma association scripts are stored

```bash
run_directory=/ENIGMA/CortexGWAS/SCRIPTS/enigma_backend      			
```

#Give the **full path** to R binary	(can be found by typing `which R` on the 
command line)			   

```bash
Rbin=/usr/local/R/bin/R 									 							   
```

#Give the **full path** to your HM3mds2Rmds.csv file -- has 4 MDS components to 
use as covariates 
(output from the MDS Analysis Protocol)

```bash
csvFILE=/ENIGMA/CortexGWAS/HM3mds2R.mds.csv   				 							   
```

#Give the **full path** to the csv file where your phenotypes and covariates are
stored after running ./run0_E3_GWAS_format.sh

```bash
combinedROItableFILE=/ENIGMA/CortexGWAS/E3/combinedROItable_eCORTEX4GWAS.csv
```

#Please give some information about the covariate coding you used:

```bash
ageColumnHeader='Age'   # The column header for your age covariate
sexColumnHeader='Sex'   # The column header for your sex covariate
maleIndicator=1         # Males in the sex column coded as (M? 1? 2? ... )
patients=1              # Does your dataset contain patients? (mark 0 for no,
                        # 1 for yes). If your sample has patients and 
                        # controls make sure you have a column, (called
                        # 'AffectionStatus') where patients are marked with 1 
                        # and healthy controls with a 0.
```

#Give the **full path** of the output diriectory for the ped and dat file 
outputs (folder will be created for you)


```bash
peddatdir=/ENIGMA/CortexGWAS/PedDat/
```

#

**#Does you sample have related or unrelated subjects?**

#

```bash
related=0  # Mark 0 for unrelated sample, 1 for related
```
#

**#Please only fill out the section below that pertains to your sample (i.e. 
unrelated or related)**

#

```bash
if [ $related -eq 0 ]
then

mach2qtl_DL=0   # UNRELATED ONLY: Only change this to 1 if you know what you are 
                # doing.

run_machdir=${run_directory}/mach2qtl/  # UNRELATED ONLY: Only change this if 
                                        # you know what you are doing

localfamFILE="None" # UNRELATED ONLY: Keep as is.

else

localfamFILE=/ENIGMA/CortexGWAS/local.fam   # RELATED ONLY: Path to your 
                                            #local.fam file outputted #during 
                                            # the Genetic #Imputation step

merlin_DL=0 # RELATED ONLY: Only change this to 1 if you know what you are 
            # doing.

merlin_directory=${run_directory}/merlin/   # RELATED ONLY: Only change this if 
                                            # you know what you are doing

fi
```
---
---
---

### **Step 3) run2_GWAS_flexible_step2.sh**

This script will setup files for performing GWAS. You will also indicate if you 
have related (family) data and where the GWAS programs (mach2qtl or merlin) are 
located on your system.

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

#Give the **full path** to where all the enigma association scripts are stored

```bash
run_directory=/ENIGMA/CortexGWAS/SCRIPTS/enigma_backend/
```

#You can split up the processing into this many nodes, if running in series or 
manually, set Nnodes=1                       

```bash
Nnodes=1 
```

#Give the **full path** to the imputed output from Mach (after imputation 
scripts)			

```bash
machFILEdir=/ENIGMA/Study_Genotypes/1KGPref/Mach/              			
```

#Give the **full path** to the ped and dat files created in 
run1_GWAS_flexible_step1.sh		

```bash
peddatdir=/ENIGMA/CortexGWAS/PedDat/                					
```

#Give abbreviated name of your sample, no spaces in the name (i.e. ADNI)	

```bash
samplename=ADNI                         							
```

#Give the **full path** for the output from mach2qtl or merlin (folder will be 
created for you)			

```bash
GWASout=/ENIGMA/CortexGWAS/GWAS_out/     							
```

#Can change to "manual" if you want to output a list of commands that you can 
batch process yourself, otherwise set to "run"			

```bash
mode="run"  
```

#Indicate whether your dataset contains (H for healthy-only subjects), 
(HD for healthy controls and affected patients), 
(or D for datasets with affected/diagnosis patients only)	

```bash
status=HD                                										
```

#

**#Does you sample have related or unrelated subjects?**

#


#Mark 0 for unrelated sample, 1 for related samples

```bash
related=0                                 
```
#

**#Please only fill out the section below that pertains to your sample (i.e. 
unrelated or related)**

#

```bash
if [ $related -eq 0 ]
then

#UNRELATED ONLY: give the directory to where you installed and compiled mach2qtl
(the parent folder of the executables/ folder)

run_machdir=${run_directory}/mach2qtl/  # Only change if you know what you are 
                                        # doing

else

#RELATED ONLY: give the directory to where you installed and compiled Merlin in 
step 1

merlin_directory=${run_directory}/merlin/   # Only change if you know what you 
                                            # are doing            

#RELATED ONLY: give the directory to the imputed output for merlin (will be 
created if files do not exist), see 
http://genepi.qimr.edu.au/staff/sarahMe/mach2merlin.html

merlinFILEdir=/ENIGMA/CortexGWAS/merlin/    

fi
```

Each group has a secure space on the ENIGMA upload server to upload the .info.gz
(from imputation) and gzipped association result files. Please contact 
enigma3helpdesk@gmail.com to obtain upload information for your group’s data.