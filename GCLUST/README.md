# Analysis of mean cortical thickness and surface area

*March 31, 2014*

**Written by Derrek Hibar and Lars T. Westlye**

Use this protocol for the analysis of mean cortical thickness and surface area 
data within FreeSurfer ROI's for the ENIGMA Bipolar, Schizophrenia, Major 
Depressive Disorder, ADHD, and Addiction working groups.

If you have any questions or run into problems, please feel free to contact us: 
(derrek.hibar@ini.usc.edu) and (l.t.westlye@psykologi.uio.no) 

These protocols are offered with an unlimited license and without warranty.  
However, if you find these protocols useful in your research, please provide a 
link to the ENIGMA website in your work: www.enigma.ini.usc.edu

---

### **Step 4: Co-register FreeSurfer Output for Vertexwise Surface Analysis**

*Italicized* portions of the instructions may require you to make changes so 
that the commands work on your system and data.

This section assumes that you have on your system:

*	Download the [driver script](prepoc.csh)
*	Download [design matrix file template](subjects.fsgd)

NOTE: It is recommended that vertexwise analyses be performed on data that have 
been processed with FreeSurfer v5.3. If your data have not been processed with 
this version, please consider re-running –autorecon3 with the v5.3 binaries and 
using those cortical segmentations for this protocol (additional QC should not 
be required). If for some reason re-analyzing your data is not feasible note 
that v5.2 and versions prior to v5.0 ARE NOT COMPATIBLE with this protocol. If 
you have any questions please contact Derrek (Derrek.Hibar@ini.usc.edu) and 
Lars (l.t.westlye@psykologi.uio.no).

---

Move the script `prepoc.csh` to the parent folder of your Freesurfer output. 
For example:

```
Subject1/	Subject2/	Subject3/	Subject4/	preproc.csh
```

Within this parent directory, create another folder for the surface script 
output:

<pre>
mkdir <i>/usr/enigma/FSoutput/</i>SURF
</pre>

Now open the preproc.sh script in any text editor and edit the environment 
parameters:

<pre>
setenv FREESURFER_HOME <i>/usr/local/freesurfer-5.3.0_64bit</i>

# this is where you find the reconstructed freesurfer data for all subjects
setenv SUBJECTS_DIR <i>/usr/enigma/FSoutput</i>

source $FREESURFER_HOME/SetUpFreeSurfer.sh

# this is path to the SURF output folder you just created
set outfolder="<i>/usr/enigma/FSoutput/SURF</i>" 

#save changes
</pre>

---

Move the subjects.fsgd file you downloaded previously to the SURF output folder:

<pre>
mv subjects.fsgd <i>/usr/enigma/FSoutput/</i>SURF
</pre>

Change directories to inside the SURF folder:

<pre>
cd <i>/usr/enigma/FSoutput/</i>SURF
</pre>

Use the following commands to create a “dummy” design matrix. Subjects in this 
list will be included in a group registration. Copy and paste the following 
into the command line:

```
#Assuming your SURF folder in one directory below the FreeSrufer output files (ie ../)
ls -d ../*/ | awk -F/ '{print "Input", $2, "BD", NR, "0"}' >> subjects.fsgd
```

Open up the subjects.fsgd file, it should look something like this:

```
GroupDescriptorFile 1  
Title all  
MeasureMentName thickness  
RegistrationSubject fsaverage
DeMeanFlag 0

Class BD
 
SomeTag 

Variables  age sex 
Input Subject1 BD 1 0
Input Subject2 BD 2 0
Input Subject3 BD 3 0
Input Subject4 BD 4 0
Input Subject5 BD 5 0
Input Subject6 BD 6 0
...
```

**Important:**
*	Look through the subjects.fsgd file for any lines in the input that aren’t 
	actually subject directories. The ls command may have included directories 
	for other things in the parent directory. Remove all lines in the text file 
	that are not subject folders with FreeSurfer output.
*	**Remove all lines in the subjects.fsgd text file for subjects that were 
	marked as poorly segmented in the QC Steps.**

<pre>
#Change directories back the parent folder with the FreeSurfer output and the preproc.csh script.

#Make sure that the fsaverage is available in this directory:
export FREESURFER_HOME=<i>/usr/local/freesurfer-5.3.0_64bit</i>
ln -s ${FREESURFER_HOME}/subjects/fsaverage .

#Run the script

tcsh preproc.csh subjects
</pre>

Feel free to send questions to Derrek (Derrek.Hibar@ini.usc.edu), Lars 
(l.t.westlye@psykologi.uio.no), and Ole (o.a.andreassen@medisin.uio.no)

---

# GCLUST Phenotype Extraction Protocol

*December 3, 2014*

**Written by Chi-Hua Chen and Donald Hagler**

Use this protocol for the analysis of mean cortical thickness and surface area 
data within fuzzy cluster ROIs defined based on genetic correlations for the 
Cortical GWAS Meta-Analysis – ENIGMA3.

If you have any questions or run into problems, please feel free to contact us: 
(chc101@ucsd.edu) and (dhagler@ucsd.edu)

These protocols are offered with an unlimited license and without warranty.  
However, if you find these protocols useful in your research, please provide a 
link to the ENIGMA website in your work: www.enigma.ini.usc.edu

---

### **Step 5: Extract FreeSurfer measures with cortical surface genetic clusters**

*Italicized* portions of the instructions may require you to make changes so 
that the commands work on your system and data.

This section assumes that you have on your system:

*	Download the package of ROIs, scripts, and MATLAB functions in this 
	directory.
	

NOTE: It is recommended that these analyses be performed on data that have been 
processed with FreeSurfer v5.3. If your data have not been processed with this 
version, please consider re-running –autorecon3 with the v5.3 binaries and using 
those cortical segmentations for this protocol (additional QC should not be 
required). If for some reason re-analyzing your data is not feasible note that 
v5.2 and versions prior to v5.0 ARE NOT COMPATIBLE with this protocol. If you 
have any questions please contact Don (dhagler@ucsd.edu) and Chi-Hua 
(chc101@ucsd.edu). 
 
---

*	Move the directory `GCLUST` to the parent folder of your FreeSurfer output. 
	For example:

```
Subject1/	Subject2/	Subject3/	Subject4/	GCLUST
```

*	Within this parent directory, make sure that the fsaverage is available. In 
	the tcsh shell:

<pre>
setenv FREESURFER_HOME <i>/usr/local/freesurfer-5.3.0_64bit</i>
ln -s ${FREESURFER_HOME}/subjects/fsaverage .
</pre>

*	Change directories (cd) into the `GCLUST` directory.

---

Create a list of FreeSurfer subject directories to be included in the result 
spreadsheets using the `set_subjlist.csh` script.

*	Open the `set_subjlist.csh` script in any text editor and edit the 
	environment variable:

<pre>
setenv SUBJECTS_DIR <i>/usr/enigma/FSoutput</i>
</pre>

*note: this is where you find the reconstructed freesurfer data for all 
subjects*

*	Save changes
*	Run the script:

```
./set_subjlist.csh
```

**Important**: This will create a subdirectory called surfdata containing a file 
called subjlist.txt. Verify that the entries included in this file are correct. 
**Quality Checking**: Remove all rows in the resultant subjlist.txt file for 
subjects that were marked as poorly segmented for the whole subject in *Step 2 
for Quality Checking of Outputs*. Make sure to save the subjlist.txt file.

---

Resample FreeSurfer surface measures to the atlas and extract weighted averages 
using fuzzy cluster ROIs based on genetic correlations using the `gclust.csh` 
script.

*	Open the `gclust.csh` script in any text editor and edit environment 
	variables:
	
<pre>
setenv FREESURFER_HOME <i>/usr/local/freesurfer-5.3.0_64bit</i>
</pre>

<pre>
setenv SUBJECTS_DIR <i>/usr/enigma/FSoutput</i>
</pre>

*note: this is where you find the reconstructed freesurfer data for all 
subjects*

```
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

*note: in a typical FreeSurfer setup, you must edit this SetUpFreeSurfer.sh 
file*

*	Save changes
*	Run the script:

```
gclust.csh
```

---

After extracting FreeSurfer measures with cortical surface genetic clusters, 
you should have two files called gclust_thickness.csv and gclust_area.csv. 
There should be 25 columns in each file (the first column is Subject ID, then 
12 ROIs for the left hemisphere and 12 ROIs for the right hemisphere). All the 
subjects marked as poorly segmented in the QC Steps were removed. The values in 
the csv files are already adjusted for global effects. 

If these genetically based parcellations for surface area and cortical 
thickness were used, please cite the following papers.

*	[Hierarchical genetic organization of human cortical surface area.](https://www.ncbi.nlm.nih.gov/pubmed/22461613) 
	Chen CH, Gutierrez ED, Thompson W, Panizzon MS, Jernigan TL, Eyler LT, 
	Fennema-Notestine C, Jak AJ, Neale MC, Franz CE, Lyons MJ, Grant MD, Fischl 
	B, Seidman LJ, Tsuang MT, Kremen WS, Dale AM. Science. 2012
*	[Genetic topography of brain morphology.](https://www.ncbi.nlm.nih.gov/pubmed/24082094) 
	Chen CH, Fiecas M, Gutiérrez ED, Panizzon MS, Eyler LT, Vuoksimaa E, 
	Thompson WK, Fennema-Notestine C, Hagler DJ Jr, Jernigan TL, Neale MC, 
	Franz CE, Lyons MJ, Fischl B, Tsuang MT, Dale AM, Kremen WS. PNAS. 2013
	
Feel free to send questions to Don (dhagler@ucsd.edu) and Chi-Hua 
(chc101@ucsd.edu). 