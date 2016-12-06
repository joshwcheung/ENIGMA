# ENIGMA Effect size and GLM script
*Dmitry Isaev, Boris Gutman, Neda Jahanshad, Sinead Kelly*

The script is intended at batch processing of multiple linear models, and the results can be carried on to meta-analysis stage. 
Each working group may configure its own set of linear models, depending on imaging metrics and covariates data it has.
Imaging metrics could be: **average ROI values (FA, MD, etc.)** or **shape vertexwise values**.
Configuring script for average ROI values and shape vertexwise data is in a big way different, so below it is explained in 2 different paragraphs.

### Contents of the package
In order to run the package, the following data should be present:
- Linear Models and Demographics statistics configuration file (*Google Docs*)
- Average ROI imaging measures/vertexwise shape measures (*shape output .raw or average ROI .csv files on end user machine*)
- Covariates files (*.csv files on end user machine*)
The following scripts should be downloaded from GitHub:
- Script shell-wrapper (*mass_uv_regr\[_csv\].sh file on end user machine*)
- The R executable code (*mass_uv_regr.R file on end user machine*)
- Shell-wrapper for script for concatenating results from all ROIs (*concat_mass_uv_regr\[_csv\].sh file on end user machine*)
- The R executable code for concatenating results from all ROIs (*concat_mass_uv_regr\[_csv\].R file on end user machine*)

# Step by step tutorial on setting up your analysis with Average ROI metrics
This section is a step-by-step tutorial on setting up analysis with Average ROI metrics.
### Step 1. Prepare directory structure
Create a folder on your machine/server where you will be performing your analysis. For example:    

    mkdir /<path-to-your-folder>/ENIGMA

In that folder create 4 subfolders where you will put your data, logs, results and scripts. For example:

    mkdir /<path-to-your-folder>/ENIGMA/data
    mkdir /<path-to-your-folder>/ENIGMA/logs
    mkdir /<path-to-your-folder>/ENIGMA/results
    mkdir /<path-to-your-folder>/ENIGMA/scripts

### Step 2. Prepare metrics CSV files
Create or copy your existing metrics files to `data` folder. Metrics file should have name `prefix_TRAIT.csv`, where `prefix` is any string, and `TRAIT` - the name of metric, contained in that file. For example:
```
    /<path-to-your-folder>/ENIGMA/data/metr_FA.csv
    /<path-to-your-folder>/ENIGMA/data/metr_MD.csv
    /<path-to-your-folder>/ENIGMA/data/metr_AD.csv
    /<path-to-your-folder>/ENIGMA/data/metr_RD.csv
``` 
\- are traditional Diffusion Tensor FA, MD, AD, RD metrics.

Please mind, that *Each metrics should have its separate file*.

Required structure of metrics file:

SubjID | ROI_Name1 | ROI_Name2 | ... | ROI_Name#N
-------|-----------|-----------|-----|-----------
\<ID_1\>|0.42|0.81| ... | 0.64
\<ID_2\>|0.61|0.58| ... | 0.55
...|...|...|...|...

**SubjID** column name should not be changed. You will later need list of ROI names (ROI_name1, ROI_name2, etc.) for configuring shell script, so keep them meaningful. Please take a look at the [Example of metr_FA.csv](http://metr_FA.csv).

### Step 3. Prepare your covariates CSV file.
Create or copy your covariates file to `data` folder. For example:
```
    /<path-to-your-folder>/ENIGMA/data/covariates.csv    
```
Example structure of covariates file:

SubjID | Site | Age | Sex |... 
-------|------|-----|-----|---
\<ID_1\>|USC|34| 1 | ... 
\<ID_2\>|USC|37| 0 | ...
...|...|...|...|...

**SubjID** column name should not be changed. If you do multi-site study, then **Site** column is obligatory.  Please check that Subject IDs and number of rows in covariates and metrics CSV match. It's necessary for correct script performance. Please take a look at the [Example of covariates.csv](http://covariates.csv)


### Step 4. Prepare QA analysis file (if you have one).
If you did automatic QA, please copy your QA analysis output .csv file to `data` folder. For example:
```
	/<path-to-your-folder>/ENIGMA/data/QA.csv
```
Required structure of QA file:


SubjID | **ROI**\<ROI_Name1\> | **ROI**\<ROI_Name2\> | ... | **ROI**\<ROI_Name#N\>
-------|-----------|-----------|-----|-----------
\<ID_1\>|3|2| ... | 1
\<ID_2\>|1|2| ... | 3
...|...|...|...|...

**SubjID** column name should not be changed. Columns corresponding to ROIs have to have prefix **ROI** and then real ROI name(same as in metrics and covariates CSV files) without any space.

### Step 5. Register your study in ENIGMA-Analysis Google Sheet (Should be done by Group Leader).
Main configuration file is [ENIGMA Analysis Google Sheet](http://www.link/), that is shared by all group leaders, each of them owning one or several lines in the sheet.
#### ENIGMA Analysis Google Sheet structure
[ENIGMA Analysis Google Sheet](http://www.link/) consists of the following columns:

1. **ID**. Unique ID of your study
2. **AnalysisList_Path**. Link to Google Sheet with configuration of your Linear Models.
3. **DemographicsList_Path**. Link to Google Sheet with configuration for descriptive statistics you want to gather from your sample (mean Age, amount of Men/Women, mean Age of Men/Women, etc.).
4. **Type**. Can take either of two values: **raw**/**csv**. Use **raw** if your study is dealing with shape data. Use **csv** if you read average ROI metrics from .csv files.
5. **Trait**. List metric names that correspond to names of your csv file name. If your metrics files are named `metr_FA.csv`, `metr_MD.csv`, `metr_AD.csv`, `metr_RD.csv` then your **Trait** field should be `FA; MD; AD; RD`. **Names should be separated with semicolon and a space**. 
See [Example for ENIGMA Analysis Google Sheet](http://www.example-enigma-analysis/).

### Step 6. Create Linear Model Google Sheet (AnalysisList_Path).
Configuring the linear models Google Sheet. For example see [Example of Enigma Linear models Google sheet](https://docs.google.com/spreadsheets/d/1N98u4C_Tl2jaW_bFDtkdatOdfHNoR2NBAs60UWqL9YM)
Overall you may do three different types of analysis with the package:

- effect size analysis (Cohen's D). In that case you should have two-level diagnosis variable, for which the system will compute the size of effect.
- Partial correlations. In that case you compute partial correlations between imaging metric and first variable in your analysis, controlling for all other variables included in your linear model.
- Linear model computing betas for all covariates, and outputting p-value for particular covariate of interest.

These three different behaviours are defined by 3 fields: **LM**,**MainFactor** and **FactorOfInterest**. 

- For Effect size analysis - see section 6.3
- For Partial correlations - see section 6.4
- For Beta and p-value - see section 6.5

#### 6.1. ID
- ID of each distinct linear model, results are written to the file with the name {GROUP_ID}_{METRICS}_{ROI}_{ID}_{SitePostfix}.csv, where METRICS={LogJacs|thick|FA|MD|etc...} 

#### 6.2 Name
- for your own purposes, not used in the script.

#### 6.3 Effect size analysis (Cohen's D).

##### 6.3.1 LM
The actual linear model, expressed in R syntax. Covariate, which effect size you want to find, **should go first in Linear Model formula**.
The names of the variables MUST EXACTLY MATCH those in the covariates file (see **Step 3**) 
Categorical variables should be embedded as 'factor(variable)'.

##### 6.3.2 MainFactor and FactorOfInterest
Variable, which effect size is of interest, should be listed as MainFactor. For example, if your LM=*'factor(Dx)+Age+Sex+Age:Sex'*, then your MainFactor should be *'factor(Dx)'*. FactorOfInterest should be left empty.

#### 6.4 Partial correlations analysis.

##### 6.4.1 LM
The actual linear model, expressed in R syntax. Covariate, which you want to correlate with imaging metrics , **should go first in Linear Model formula**.
The names of the variables MUST EXACTLY MATCH those in the covariates file (see **Step 3**) 
LM should not contain variables embedded as 'factor(variable)'. For partial correlations to work properly, all variables have to be continious.

##### 6.4.2 MainFactor and FactorOfInterest
Covariate, for which we want to get partial correlations, should be listed in the field MainFactor. For example, if your LM=*'Age+Sex+Age:Sex'*, and you're looking for correlations between imaging metrics and Age, then your MainFactor should be *'Age'*. FactorOfInterest should be left empty. Mind, that Age should go in first place in Linear Model.

#### 6.5 Beta and p-value for particular variable.
If we just want to output beta and p-value for particular covariate, we should put it in first place in Linear Model, and put it's name into "FactorOfInterest" field.
##### 6.5.1 LM
Except putting factor of interest in first place, no special restrictions are set on linear model.
##### 6.5.2 MainFactor and FactorOfInterest
MainFactor should be left empty. FactorOfInterest should represent the name of the covariate for which we need beta and p-value.

#### 6.6 Adding filters (Filters_1, Filters_2)

In the Filters columns, various filters for the data can be applied.  Variables should be separated from other syntax with DOUBLE UNDERSCORE ON BOTH SIDES: \_\_Variable\_\_.
For example, if you want to investigate the effects of age at onset in patients only, include: 
	
	(__Dx__==1) & (!is.na(__AO__))

Here, we assume that patients are coded as “1” and age at onset is coded as “AO”

If you have a variable that has multiple levels, e.g antipsychotic medication (unmediated, typical, atypical, both), you may want to include more than one filter for individual t-tests between these groups. 
In this example, we may want to compare patients on atypical medication with patients on typical medication (excluding the other two medication groups, as well as healthy controls).
In this case, we would add the first filter to look at patients only and then patients on typical medication (assuming patients on typical medication are coded as “2” in your antipsychotic (“AP”) variable):

	(__Dx__==1) & (__AP__==2)

Then, in the second filter column, you will filter for patients only, as well as patients on atypical medication (assuming atypical patients are coded as “3” in your “AP” variable):

	(__Dx__==1) & (__AP__==3)

Finally, in the ‘ContValue’ and ‘PatValue’ columns, enter “2” and “3” respectively, to indicate that you are comparing groups 2 and 3 for your antipsychotic medication (“AP”) variable. 

*Filters_3 column should not be used.*

#### 6.7 SiteRegressors 
- used if multiple Site variables present in covariates file (e.g. Site1,Site3.1., etc). If 'all' is put into the field, all variables named like 'SiteN' are added to the model as regressors. if there's no such variables, no regressors will be added.

#### 6.8 NewRegressors 

In the “NewRegressers” column, you can introduce new regressors that may not be included in your covariate spreadsheets. For example, if you want to also covary for age demeaned (“AgeC”), enter a formula to calculate “AgeC”:

	__AgeC__=__Age__-mean(__Age__)

If you want to covary for Age demeaned squared (“AgeC2”), enter the following (all in the same cell):

	__AgeC__=__Age__-mean(__Age__); __AgeC2__=__AgeC__*__AgeC__

In the example config file you will see formulas for age demeaned by sex (“AgeCSex”), age squared demeaned (“Age2C”), and Age squared demeaned by sex (“Age2CSex”)
These new variables can then be included as covariates in linear model (‘LM’ column):
	
	factor(Dx) + Age + factor(Sex) + AgeCSex +Age2C + Age2CSex

New regressors are created  before filtering, so they in turn can be used for filtering.

#### 6.9 ContValue,PatValue 
- value of variables used for t-test for 'factor' variable. By default, 0 and 1. If your variable like 'factor(ATBN)' is instead taking values '2' and '3' you should put these values in the ContValue and PatValue fields.

#### 6.10 Active.
In the ‘Active’ column, you can activate the individual tests by entering “1” or deactivate individual tests by entering “0”.

#### 6.11 Comments. 
Anything you like.

#### 6.12 ContMin,PatMin 
- minimum amount of elements in controls/patient groups needed to run the test

#### 6.13 SaveLM 
- should either be 1 or 0. If set to 1, then the linear models in R format are saved to the .RData variable (with the  name {GROUP_ID}_{METRICS}_LM_{ROI}_{ID}_{SitePostfix}.Rdata) in the results folder

### Step 7. Create Demographics Google Sheet (DemographicsList_Path).
This file specifies the descriptive statistics you want to obtain. 
Three types of descriptive statistics can be specified in this file:

- METRICS
- COV
- NUM
#### 7.1. Metrics
**METRICS** will output summary information (mean, sd, min, max) for each imaging measure (e.g. FA, volume, thickness) for each ROI or structure.  You can also split this up based on the groups in your analysis (patients, controls, medicated patients, unmedicated patients etc). See the ‘Filter’ column.  ‘Stats’ and ‘StatsNames’ columns indicate the statistics you want to obtain (sd, mean etc). 
#### 7.2. COV (Covariates)
**COV** obtains descriptive statistics (mean, sd, range) for each of your continuous variables in the analysis (e.g. age, duration of illness, age at onset etc.).  If you want to split this up in terms of your groups (patients, controls, medicated, unmedicated) use the ‘Filter’ column to specify your groups (see example). The ‘Covariate’ column will remain the same as the ‘Varname’ column and the ‘Postfix’ column will contain the postfix you want to give each output file. 
#### 7.3. NUM (amount of subjects in different subsets
**NUM** obtains the number (n) of participants for each categorical variable in your analysis (e.g. Diagnosis, Sex, medication type, smokers, non-smokers), but you also can filter subjects with continious variables (e.g. Age>30)
Using the ‘Filter’ column, indicate if you want n for:
Females only (assuming females are coded as “2”):

	(__Sex__==2)

Males only (assuming males are coded as “1”):

	(__Sex__==1)

Female healthy controls (assuming healthy controls are coded as “0’):

	(__Sex__==2) & (__Dx__==0)

Unmedicated females (assuming unmedicated patients are coded as “1”):

	(__Sex__==2) & (__AP__==1)

See example [Example DempographicsList Google Sheet](http://dem_config.csv) file for more filters.
The working group leader in this case can intuitively name the ‘StatsNames’ column.

‘Active’ columns can be left as “1” for active or “0” for inactive.

*'Sepfile' column is deprecated. Set it to 0*.

### Step 8. Download scripts and adjust mass_uv_regr_csv.sh
Download all files from `script` folder on GitHub into `/<path-to-your-folder>/ENIGMA/scripts`.
Give yourself permissions to everything in the folders

    chmod -R 755 /<path-to-your-folder>/ENIGMA/scripts  

Open `mass_uv_regr_csv.sh` in any text editor and configure as follows for your own analysis.
##### 8.1  Section 1:

- `scriptDir="/<path-to-your-folder>/ENIGMA/scripts"`
- `resDir="/<path-to-your-folder>/ENIGMA/results"`
- `logDir="/<path-to-your-folder>/ENIGMA/logs"`
    
    
##### 8.2 Section 2. Main configuration section

- `RUN_ID="<STUDY_ID>"` - Unique ID of your study from ENIGMA Analysis Google Docs file (see **Step 5**)
- `CONFIG_PATH="https://docs.google.com/spreadsheets/d/1AxtW4xN8ETZUHvztqqkF0jD68Mm_5SNPWV2Y6HPFrh8"` - path to ENIGMA Analysis Google Docs file. The script will take the AnalysisList_Path and DemographicsList_Path links from the line of config file with RUN_ID and will run the models from these files.
- `SITE="<SITE_NAME>"` - the name of particular site for which the script is being configured. It will become the postfix for the resulting files.
- `DATADIR="/<path-to-your-folder>/ENIGMA/data"` - folder where the covariates,metrics and QC reside.
- `ROI_LIST` - list of ROIs (have pre-set value for shapes and csv, maybe no need to change it)
- `SUBJECTS_COV="/<path-to-your-folder>/ENIGMA/data/covariates.csv"`
- `EXCLUDE_FILE="/<path-to-your-folder>/ENIGMA/data/QA.csv"` path to QA file. (!!!) ADD QA_LEVEL
- `METR_PREFIX="metr_"` - prefix for files with metrics (for instance if you have all files named as metr_FA.csv, metr_MD.csv, metr_AD.csv, etc)
-  Nnodes - number of nodes used for computation. This number should match with that you set in qsub command: qsub -q .... -t 1-"Nnodes" mass_uv_regr_...sh. if you do not use grid and use just shell execution - use Nnodes=1. Otherwise set the number of nodes up to the number of ROIs.

##### 8.3 Section 5. Path to R binary 
- `Rbin="<path_to_R_binary>` - put here the path to R binary ( for which you installed the packages)

### Step 9. Make sure you have R packages installed.
Before running the script you have to make sure you have all necessary libraries for R.
The following packages should be installed for R:
	`matrixStats`,
	`RCurl`,
	`ppcor`,
	`moments`.
### Step 10. Running the script.
You can split this up for parallelized regressions if you Q-SUB it!

`qsub -t 1-#N# mass_uv_regr_csv.sh`, where `#N#` is the Number of Nodes (Nnodes variable in your script)

Another option is to set the number of nodes (**Nnodes** variable) to 1 and run it from command-line:

`sh mass_uv_regr_csv.sh`

### Step 11. Analyzing results.

### Step 12. Concatenating results for subsequent meta-analysis.
 After running the script you may want to concatenate .CSV files from each ROI.
For this you should use the script `concat_mass_uv_regr_csv.sh` which calls `concat_mass_uv_regr.R`
Configuring `concat_mass_uv_regr_csv.sh` script:
##### 12.2 Section 1:

	scriptDir,
	resDir,
	logDir,
	
\-same as in mass_uv_regr.sh, see **Step 8.1**
##### 12.2 Section 2:
	RUN_ID,
	CONFIG_PATH,
	SITE,
\-same as in mass_uv_regr.sh, see **Step 8.2**
\-ROI_LIST - DO NOT CHANGE
##### 12.3 Running the script:
	sh  concat_mass_uv_regr_csv.sh
Results: files {GROUP_ID}_{METRICS}_ALL_{MODEL_ID}_{SitePostfix}.csv - all ROI for the same model and same trait concatenated in one file.


...























## Confuguration and input data preparation for usage with Average ROI imaging metrics
Main configuration file is [ENIGMA Analysis Google Sheet](http://www.link/), that is shared by all group leaders, each of them owning one or several lines in the sheet.
### ENIGMA Analysis Google Sheet structure
[ENIGMA Analysis Google Sheet](http://www.link/) consists of the following columns:

1. **ID**. Unique ID of your study
2. **AnalysisList_Path**. Link to Google Sheet with configuration of your Linear Models.
3. **DemographicsList_Path**. Link to Google Sheet with configuration for descriptive statistics you want to gather from your sample (mean Age, amount of Men/Women, mean Age of Men/Women, etc.).
4. **Type**. Can take either of two values: **raw**/**csv**. Use **raw** if your study is dealing with shape data. Use **csv** if you read average ROI metrics from .csv files.
5. **Trait**. List metric names that correspond to names of your csv/raw file (see below in **Script shell-wrapper** section).  **Names should be separated with semicolon and a space**. *Need to be more clear - tell about column names in metr_FA.csv, or names of .raw files*.
See [Example for ENIGMA Analysis Google Sheet](http://www.example-enigma-analysis/).

### Average ROI imaging metrics file
ROI imaging metrics file should have structure

### Configuration of the models and input data preparation

### Configuration of the script on end-user machine

### Running the script

### Appendix A. Installation and prerequisites.


---README for mass_uv_regr package of scripts---

Dmitry Isaev
Boris Gutman
Neda Jahanshad

Beta version for testing on sites.
ENIGMA Project, 3.1.015
-----------------------------------------------
0. THIS IS THE BETA VERSION. Please check your analyses and results!! More complex models which use filters and new regressors may not have been tested using the combinations you have entered, so please let us know if you encounter any problems or have concerns. 
The script will create log files in the **log** directory. If you note an "Error" in a log file, please double check the analysis and send questions to us (Dmitry, Boris or Neda) at enigma@ini.usc.edu. 

1. The scripts folder consists of 3 files:
	Customized bash scripts for running on your local machine or server:
	* mass_uv_regr_shapes.sh - wrapper that can be used with/or without qsub for running vertexwise stats over the shape data
	* mass_uv_regr_csv.sh - wrapper that can be used with/or without qsub for running over the csv data
	Universal regression models for ENIGMA groups
	* mass_uv_regr.R - R-based regression code for processing the data
	
.sh scripts should be modified to specify your local paths and files

2. Installation. 
2.1 Prerequisites. R libraries:
The following packages should be installed for R:
	matrixStats
	RCurl
	ppcor
	moments
2.2 Configuring the shell script.
2.2.1 Give yourself permissions to everything in the folders
	chmod -R 755 ENIGMA_Regressions/*  
2.2.2  Section 1:
	scriptDir - directory of the script itself (the folder containing .sh and .R scripts
	resDir - directory for results
	logDir - directory for logs
2.2.3 Section 2. Main configuration section
	RUN_ID="IJSHAPES"
	CONFIG_PATH="https://docs.google.com/spreadsheets/d/1AxtW4xN8ETZUHvztqqkF0jD68Mm_5SNPWV2Y6HPFrh8"
	
	CONFIG_PATH is the path to Google Sheets documents which contains the links to 2 other documents as well as Study ID, type (csv/raw) and Traits to be examined. 
	Working group leaders should contact us about making an entry in the shared docs so all sites can perform the same tests.
	All other users must create their own GOOGLE DOCS FILES FOR AnalysisList_Path and DemographicsList_Path fields in that document.
	
	RUN_ID - should be the same as the STUDY ID of interest in the Google Sheet.
	
	The script will take the links from the line of config file with RUN_ID and will run the models from these files.

	SITE="ENIGMA" - the name of site - the postfix for the resulting files
	DATADIR="/ENIGMA_Regression/testMe/data/" - folder where the data resides.
	ROI_LIST - list of ROIs (have pre-set value for shapes and csv, maybe no need to change it)
	SUBJECTS_COV=path to your local subjects and covariates file
	EXCLUDE_FILE=path to file with excluded subjects for each ROI (if you have one)
	METR_PREFIX - prefix for files with metrics (for instance if you have all files named as metr_FA.csv, metr_MD.csv, metr_AD.csv, etc)
(!!!)	Nnodes - number of nodes used for computation. This number should match with that you set in qsub command: qsub -q .... -t 1-"Nnodes" mass_uv_regr_...sh
	if you do not use grid and use just shell execution - use Nnodes=1. Otherwise set the number of nodes up to the number of ROIs.
2.2.4 Section 5. 
	Rbin - put here the path to R binary ( for which you installed the packages)
3. Configuring the linear models and descriptive statistics. Link to those are in the Google Docs file specified by CONFIG_PATH

3.1 Configuring the linear models Google Sheet. For example see https://docs.google.com/spreadsheets/d/1N98u4C_Tl2jaW_bFDtkdatOdfHNoR2NBAs60UWqL9YM
3.1.1 ID
- ID of each distinct linear model, results are written to the file with the name {GROUP_ID}_{METRICS}_{ROI}_{ID}_{SitePostfix}.csv, where METRICS={LogJacs|thick|FA|MD|etc...} 
3.1.2 Name
- for your own purposes, not used in the script.
3.1.3 LM
- the actual linear model, expressed in R syntax.
The names of the variables MUST EXACTLY MATCH those in the covariates file (see Subject_Path, p.6) 
Categorical variables should be embedded as 'factor(variable)'.

3.1.4 MainFactor
the factor for which hypothesis is tested.
if factor appears as 'factor(variable)' - then the Cohen's D statistic is obtained.
if factor appears as 'variable' - runs the general linear model as well as the partial correlation between the metric and the main factor of interest, taking into consideration all other variables in model.
Currently, the MainFactor HAS TO BE either CONTINUOUS, or have only TWO LEVELS in the covariates table. 

3.1.5 Filters_1, Filters_3.1.
- filters which should be applied to the data before fitting the linear model. Variables should be separated from other syntax with DOUBLE UNDERSCORE ON BOTH SIDES: __Variable__
3.1.6 Filters_3 - not used.
3.1.7 SiteRegressors - used if multiple Site variables present in covariates file (e.g. Site1,Site3.1., etc).
if 'all' is put into the field, all variables named like 'SiteN' are added to the model as regressors. if there's no such variables, no regressors will be added.
3.1.8 NewRegressors 
ONLY FOR VERY EXPERIENCED USERS :))) -- let us know if you want to learn to work with these!
New variables that can be created from existing. Applied before filtering, so new regressors can be used for filtering
3.1.9 ContValue,PatValue - value of variables used for t-test for 'factor' variable. By default, 0 and 1. If your variable like 'factor(ATBN)' is istead taking values '3.1.' and '3' you should put these values in the ContValue and PatValue fields.
3.1.10 Active.
SETS IF THE LINE WILL BE EXECUTED BY THE SCRIPT.
If you want some lines to be omitted in the run, for debugging purposes, set ACTIVE to 0.
3.1.11 Comments. 
Anything you like.
3.1.12 ContMin,PatMin - minimum amount of elements in controls/patient groups needed to run the test
3.1.13 SaveLM - should either be 1 or 0. If set to 1, then the linear models in R format are saved to the .RData variable (with the  name {GROUP_ID}_{METRICS}_LM_{ROI}_{ID}_{SitePostfix}.Rdata) in the results folder

4. Configuring descriptive statistics configuration. For Example see https://docs.google.com/spreadsheets/d/11sVXxrtfUf-YzppDpW96IODaVbi5itXtfzGHy9tIVmE
4.1 Type
One of three: METRICS,COV,NUM.
METRICS - statistics gathered from shape metrics (LogJacs, thick)
COV - statistics gathered from covariates
NUM - number of elements in the group.
4.2 varname - name of the variable.
for SHAPE_metrics section the resulting varname looks like: varname.statsName (e.g. patients.mu.raw, patients.sd.raw, etc).
for COV metrics section the resulting varname looks like: varname.statsName.Postfix(e.g. age.mu.all,age.sd.all,age.mu.dx0,age.sd.dx0, etc)
for NUM metrics the resulting varname looks like: varname.StatsName (e.g. n.fem,n.mal,n.fem.dx0, etc)
4.4. Filter - same principle as in (p. 2.5) - will be applied before the statistics is computed).
4.4 Stats, StatsNames - DON't CHANGE IT, let it work as it is. it basically makes R to gather the statistics (mean, sd, range) and put it into variable names (varname.mu, varname.sd, varname.range).
4.5 SepFile - DEPRECATED IN CURRENT VERSION. sets if the statistics should be gathered in separate .Rdata file.
4.6 Active - same as (p. 2.10) - the statistics is active only if this field is set to 1.
4.7 Covariate - for COV section tells the name of the Covariate from which to extract the data. Should EXACTLY match the covariate field name (see p. 6)
4.8 Postfix -  explained in (p. 4.2)

5. Running the script.
You can split this up for parallelized regressions if you Q-SUB it!
	qsub -t 1-#N# mass_uv_regr_csv.sh, where #N# is the Number of Nodes (Nnodes variable in your script)
-- or-- set the number of nodes (Nnodes variable) to 1 and run it command-line:
sh mass_uv_regr_csv.sh

6. After running the script you may want to concatenate .CSV files from each ROI.
For this you could use the script: concat_mass_uv_regr_csv.sh which calls concat_mass_uv_regr.R
Things you need to configure:

6.2 Section 1:
	scriptDir,
	resDir,
	logDir,
	- same as in mass_uv_regr.sh, see p. 2.2.2
6.3 Section 2:
	RUN_ID,
	CONFIG_PATH,
	SITE,
	- same as in mass_uv_regr.sh, see p. 2.2.3
	
	ROI_LIST - DO NOT CHANGE
6.4 Running the script:
sh  same as in mass_uv_regr.sh, see p. 2.2.2
6.5 Results: files {GROUP_ID}_{METRICS}_ALL_{MODEL_ID}_{SitePostfix}.csv - all ROI for the same model and same trait concatenated in one file.

