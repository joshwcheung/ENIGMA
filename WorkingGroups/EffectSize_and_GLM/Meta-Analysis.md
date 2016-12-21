# META-analysis for csv data tutorial
This tutorial is intended at describing the process of configuring meta-analysis scripts for analysing the results of first-level site models.
It implies that you have already configured your models and run your script on several first-level sites.

### Step 1. Prepare directory structure.
Create a folder for meta-analysis input data and results.

    mkdir /<path-to-your-folder>/ENIGMA/META
    mkdir /<path-to-your-folder>/ENIGMA/META/results
Create a log folder for meta-analysis log files.

    mkdir /<path-to-your-folder>/ENIGMA/META/logs

### Step 2. Copy first-level results to folder.
copy ```*_ALL_*.csv``` files from each site to ```/<path-to-your-folder>/ENIGMA/META/res``` folder

### Step 3. Configure your meta-analysis shell script.
if you downloaded everything from 'EffectSize_and_GLM/scripts' folder, then you should have files ```meta_mass_uv_regr_parallel.R``` and ```meta_mass_uv_regr_parallel.sh``` in your ```ENIGMA/scripts``` folder.
Open file ```meta_mass_uv_regr_parallel.sh``` in text editor and perform the changes as follows.

#### Section 1. Folders.
- `scriptDir="/<path-to-your-folder>/ENIGMA/scripts"`
- `resDir="/<path-to-your-folder>/ENIGMA/META/results"`
- `logDir="/<path-to-your-folder>/ENIGMA/META/logs"`
#### Section 2. Site list.
Create a file named ```site_list.txt```` in your ```scriptDir```
Enter the site names (as they are named in your first-level shell script in **SITE** variable), in quotes and separated with cmman
