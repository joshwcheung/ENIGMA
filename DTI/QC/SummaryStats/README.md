# Protocol for Creating Histograms and Summary Stats QC analysis for ENIGMA-DTI

*Last update February 2014*

**Neda Jahanshad, Derrek Hibar**

**neda.jahanshad@ini.usc.edu; derrek.hibar@ini.usc.edu**

The following steps will allow you to visualize your final FA distribution in 
each ROI in the form of a histogram and will output a text file with summary 
statistics on each ROI including the mean, standard deviation, min and max 
value, as well as the subjects corresponding to the min and max values.

**These protocols are offered with an unlimited license and without warranty. 
However, if you find these protocols useful in your research, please provide a 
link to the ENIGMA website in your work: 
[enigma.ini.usc.edu](http://enigma.ini.usc.edu)**

**Generate Summary Statistics and Histogram Plots**

*Italicized portions of the instructions may require you to make changes so that
the commands work on your system and data.*

**This section assumes that you have installed:**
* [R](http://cran.r-project.org/)

Download the [automated script for generating the 
plots](ENIGMA_DTI_plots_ALL.R)

---

After having quality checked eaching of your segmented structures you should 
have a file called combinedROItable.csv, which is a comma separated file with 
the mean FA of each ROI for each subject. **It should look like this (note the 
... there should be 64 + however many covariates of interest columns):**

"subjectID","Age","Sex","ACR","ACR-L","ACR-R","ALIC","ALIC-L","ALIC-R",
AverageFA","BCC",...

subject1, ...

subject2, ...

subject3, ...

**Generating plots and summary statistics:**

Make a new directory to store necessary files:

<pre>
mkdir <i>/enigmaDTI/figures/</i>
</pre>

Copy your combinedROItable.csv file to your new folder:

<pre>
cp <i>/enigmaDTI/</i> combinedROItable.csv <i>/enigmaDTI/figures/</i>
</pre>

Move the ENIGMA_DTI_plots.R script to the same folder:

<pre>
mv <i>/enigmaDTI/downloads/</i>ENIGMA_DTI_plots.R <i>/enigmaDTI/figures/</i>
</pre>

Make sure you are in your new figures folder:

<pre>
cd <i>/enigmaDTI/figures</i>
</pre>

The code will make a new directory to store all of your summary stats and 
histogram plots:

<pre>
<i>/enigmaDTI/figures/</i>QC_ENIGMA
</pre?

Run the R script to generate the plots, make sure to enter your cohort name so 
it shows up on all plots:

<pre>
cohort='<i>MyCohort</i>'
R --no-save --slave --args ${cohort} < ENIGMA_DTI_plots_ALL.R
</pre>

It should only take a few minutes to generate all of the plots. If you get 
errors, the script might tell you what things need to be changed in your data 
file in order to work properly. Just make sure that your input file is in *.csv 
format similar to the file above.

The output will be a pdf file with a series of hisograms. You need to go through
each page to make sure that your histograms look approximately normal. If there 
appear to be any outliers, please verify your original FA image is appropriate. 
If you end up deciding that certain subjects have poor quality scans then you 
should give that subject an "NA" for all ROIs in your combinedROItable.csv file 
and then re-run the ENIGMA_DTI_plots_ALL.R script given above.

**Please upload the ENIGMA_DTI_allROI_histograms.pdf and the 
ENIGMA_DTI_allROI_stats.txt files to the ENIGMA DTI Support or Working Group.**
