# Protocol for FA and Skeleton Visual QC analysis for ENIGMA-DTI

*Last update September 2014*

**Neda Jahanshad, Hervé LeMaitre, Sean Hatton, Annchen Knodt**

**neda.jahanshad@ini.usc.edu; herve.lemaitre@cea.fr; sean.hatton@sydney.edu.au; 
annchen.knodt@duke.edu**

The following steps will allow you to visualize your FA images after 
registration to the ENIGMA-DTI template, and to see if your extracted skeletons 
are all projected onto the ENIGMA Skeleton.

**These protocols are offered with an unlimited license and without warranty. 
However, if you find these protocols useful in your research, please provide a 
link to the ENIGMA website in your work: 
[enigma.ini.usc.edu](http://enigma.ini.usc.edu)**

*Italicized portions of the instructions may require you to make changes so that
the commands work on your system and data.*

**INSTRUCTIONS**

**Prerequisites**
*   [Matlab](http://www.mathworks.com/products/matlab/) installed
*   Diffusion-weighted images preprocessed using FSL’s 
    [DTIFIT](http://fsl.fmrib.ox.ac.uk/fsl/fsl4.0/fdt/fdt_dtifit.html) or 
    equivalent.
*   Run the [ENIGMA DTI processing protocol to project individual skeletons onto
    the common template](/DTI#enigma-dti-skeletonization)

**Step 1 – Download the utility packages**

Download the Matlab scripts package for Step 3:
```bash
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/DTI/QC/enigmaDTI_QC
```

Download the script to build the QC webpage for Step 4:
*   [Linux](make_enigmaDTI_FA_Skel_QC_webpage.sh)
*   [Mac](make_enigmaDTI_FA_Skel_QC_webpage_mac.sh)

**Step 2 – Build a text file defining the location of subject files**

Create a three column tab-delimited text file (e.g. *Subject_Path_Info.txt*):
*   **subjectID**: subject ID
*   **FAimage**: full path to registered FA image.
*   **Skeleton**: full path to skeletonized FA image.

```
subjectID   FAimage                         Skeleton
USC_01      /path/USC_01_masked_FA.nii.gz   /path/USC_01_masked_FAskel.nii.gz
USC_02      /path/USC_02_masked_FA.nii.gz   /path/USC_02_masked_FAskel.nii.gz
USC_03      /path/USC_03_masked_FA.nii.gz   /path/USC_03_masked_FAskel.nii.gz
```

**Step 3 – Run Matlab script to make QC images**

Unzip the Matlab scripts from Step 1 and change directories to that folder with 
the required Matlab \*.m scripts. For simplicity, we assume you are working on a
Linux machine with the base directory */enigmaDTI/QC_ENIGMA/*.

Make a directory to store all of the QC output:

<pre>
mkdir <i>/enigmaDTI/QC_ENIGMA/QC_FA_SKEL/</i>
</pre>

Start Matlab:

<pre>
<i>/usr/local/matlab/bin/</i>matlab
</pre>

Next we will run the **func_QC_enigmaDTI_FA_skel.m** script that reads the
***Subject_Path_Info.txt*** file to create subdirectories in a specified 
**output_directory** for each individual **subjectID**, then create an axial, 
coronal and sagittal image of the **FA_image** with overlays from the 
**Skeleton**.

In the Matlab command window paste and run:

<pre>
TXTfile='<i>/enigmaDTI/QC_ENIGMA/Subject_Path_Info.txt</i>';
output_directory='<i>/enigmaDTI/QC_ENIGMA/QC_FA_SKEL/</i>';
</pre>

```matlab
[subjs,FAs,SKELs]=textread(TXTfile,'%s %s %s','headerlines',1)

for s = 1:length(subjs)
subj=subjs(s);
Fa=FAs(s);
skel=SKELs(s);
try

% reslice FA
[pathstrfa,nameniifa,gzfa] = fileparts(Fa{1,1});
[nafa,namefa,niifa] = fileparts(nameniifa);
newnamegzfa=[pathstrfa,'/',namefa,'_reslice.nii.gz'];
newnamefa=[pathstrfa,'/',namefa,'_reslice.nii'];
copyfile(Fa{1,1},newnamegzfa);
gunzip(newnamegzfa);
delete(newnamegzfa);
reslice_nii(newnamefa,newnamefa);

% reslice skel
[pathstrskel,nameniiskel,gzskel] = fileparts(skel{1,1});
[naskel,nameskel,niiskel] = fileparts(nameniiskel);
newnamegzskel =[pathstrskel,'/',nameskel,'_reslice.nii.gz'];
newnameskel =[pathstrskel,'/',nameskel,'_reslice.nii'];
copyfile(skel{1,1},newnamegzskel);
gunzip(newnamegzskel);
delete(newnamegzskel);
reslice_nii(newnameskel,newnameskel);

% qc
func_QC_enigmaDTI_FA_skel(subj,newnamefa,newnameskel,
output_directory);
close(1)
close(2)
close(3)

% delete
delete(newnamefa)
delete(newnameskel)
end

display(['Done with subject: ', num2str(s), ' of ',
num2str(length(subjs))]);

end
```

For troubleshooting individual subjects **func_QC_enigmaDTI_FA_skel.m script** 
can be run in the command console with the following parameters:

```bash
func_QC_enigmaDTI_FA_skel('subjectID', 'FA_image_path', 'Skel_image_path','output_directory')
```

**Step 4 - Make the QC webpage**

Within a terminal session go to the */enigmaDTI/QC_ENIGMA/* directory where you 
stored the script **make_enigmaDTI_FA_Skel_QC_webpage.sh** and ensure it is 
executable:

```bash
chmod 777 make_enigmaDTI_FA_Skel_QC_webpage.sh
```

or for Mac,

```bash
chmod 777 make_enigmaDTI_FA_Skel_QC_webpage_mac.sh
```

Run the script, specifying the full path to the directory where you stored the 
Matlab QC output files:

<pre>
./make_enigmaDTI_FA_Skel_QC_webpage.sh <i>/enigmaDTI/QC_ENIGMA/QC_FA_SKEL/</i>
</pre>

or for Mac,

<pre>
sh make_enigmaDTI_FA_Skel_QC_webpage_mac.sh <i>/enigmaDTI/QC_ENIGMA/QC_FA_SKEL/</i>
</pre>

This script will create a webpage called *enigmaDTI_FA_Skel_QC.html* in the same
folder as your QC output. To open the webpage in a browser in a Linux 
environment type:

<pre>
firefox <i>/enigmaDTI/QC_ENIGMA/QC_FA_SKEL/</i>enigmaDTI_FA_Skel_QC.html
</pre>

Scroll through each set of images to check that the images are all aligned and 
well registered and all skeletons are composed of the same voxels. For closer 
inspection, clicking on a subject’s preview image will provide a larger image. 
If you want to check the segmentation on another computer, you can just copy 
over the whole */enigmaDTI/QC_ENIGMA/QC_FA_SKEL/* output folder to your computer
and open the webpage from there.

Congrats! Now you should have all you need to make sure your FA images turned 
out OK and their skeletons line up!
