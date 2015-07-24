# Protocol for applying TBSS skeletonizations from FA analysis to diffusivity and obtaining ROI measures using the ENIGMA-DTI template

*May 27, 2015*

**support.enigmaDTI@ini.usc.edu**

The following steps will allow you to skeletonize diffusivity measures including
mean, axial and radial diffusivity (denoted by MD, L1, and RD respectively) and 
extract relevant ROI information from them according to the ENIGMA-DTI template,
and keep track of them in a spreadsheet.

\*\*\*Before you get started, you must perform all the ENIGMA- FA analyses!! 
This protocol will follow the same naming conventions\*\*\*

Make sure you have already performed the FA analyses [here](DTI/TBSS) and [here]
(DTI/ROIExtraction).

**INSTRUCTIONS**

1.  Setup
    *   From the previous TBSS protocol (linked above), we will assume the 
        parent directory is: `/enigmaDTI/TBSS/run_tbss/`, which we will define 
        this through the variable parentDirectory but you should modify this 
        according to where your images are stored.
    *   Also as before, we will assume your ENIGMA template files are
    
        ```
        /enigmaDTI/TBSS/ENIGMA_targets/ENIGMA_DTI_FA.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets/ENIGMA_DTI_FA_mask.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets/ENIGMA_DTI_FA_skeleton.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets/ENIGMA_DTI_FA_skeleton_mask.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets/ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz
        ```
        \*\*Note: if you had to re-mask the template your paths will be to the 
        edited versions, so remember to use these instead!\*\*
        ```
        /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_mask.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_skeleton.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_skeleton_mask.nii.gz
        /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_skeleton_mask_dst.nii.gz
        ```
2.  Copy all necessary diffusivity images (from TBSS’s DTIFIT, for example) into
    designated directories in your run_tbss/ folder.
    *   We will assume your diffusivity files are located in dtifit_folder but 
        make sure to correct this to reflect your naming convention
        *   We will assume your diffusivity files are located in dtifit_folder 
            but make sure to correct this to reflect your naming convention
        *   Mean and axial diffusivities are output as part of DTIFIT, but here 
            we will compute the radial diffusivity as a mean of the second and 
            third eigenvalue images.
        *   The following is written in a loop so all subjects run in series, 
            however this can be parallelized
        *   Use the latest FSL version 5.0.7 if you have it, but the same code 
            will work for older versions as well.
        
    ```bash
    FSLDIR=/usr/local/fsl-5.0.7/
     
    ENIGMAtemplateDirectory=/enigmaDTI/TBSS/ENIGMA_targets/
    parentDirectory=/enigmaDTI/TBSS/run_tbss/
    dtifit_folder=/enigmaDTI/DTIFIT/
     
    mkdir ${parentDirectory}/MD/
    mkdir ${parentDirectory}/AD/
    mkdir ${parentDirectory}/RD/
     
    cd $parentDirectory
     
    for subj in subj_1 subj_2 … subj_N
    do
        cp ${dtifit_folder}/${subj}*_MD.nii.gz \
        ${parentDirectory}/MD/${subj}_MD.nii.gz
        cp ${dtifit_folder}/${subj}*_L1.nii.gz \
        ${parentDirectory}/AD/${subj}_AD.nii.gz
        $FSLDIR/bin/fslmaths ${dtifit_folder}/${subj}*_L2.nii.gz –add \
        ${dtifit_folder}/${subj}*_L3.nii.gz \
        -div 2 ${parentDirectory}/RD/${subj}_RD.nii.gz
     
        for DIFF in MD AD RD
        do
        mkdir -p ${parentDirectory}/${DIFF}/origdata/
        mkdir -p ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/
        mkdir -p ${parentDirectory}/${DIFF}_individ/${subj}/stats/
     
        $FSLDIR/bin/fslmaths ${parentDirectory}/${DIFF}/${subj}_${DIFF}.nii.gz \
        -mas ${parentDirectory}/FA/${subj}_FA_FA_mask.nii.gz \
        ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/${subj}_${DIFF}
     
        $FSLDIR/bin/immv ${parentDirectory}/${DIFF}/${subj} \
        ${parentDirectory}/${DIFF}/origdata/
     
        $FSLDIR/bin/applywarp -i \
        ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/${subj}_${DIFF} \
        -o ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/${subj}_\
        ${DIFF}_to_target -r \
        $FSLDIR/data/standard/FMRIB58_FA_1mm -w \
        ${parentDirectory}/FA/${subj}_FA_FA_to_target_warp.nii.gz
     
        ##remember to change ENIGMAtemplateDirectory if you re-masked the 
        ##template
     
        $FSLDIR/bin/fslmaths ${parentDirectory}/${DIFF}_individ/${subj}/\
        ${DIFF}/${subj}_${DIFF}_to_target -mas \
        ${ENIGMAtemplateDirectory}/ENIGMA_DTI_FA_mask.nii.gz \
        ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/\
        ${subj}_masked_${DIFF}.nii.gz	
     
        $FSLDIR/bin/tbss_skeleton -i \
        ${ENIGMAtemplateDirectory}/ENIGMA_DTI_FA.nii.gz -p 0.049 \
        ${ENIGMAtemplateDirectory}/ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz \
        $FSLDIR/data/standard/LowerCingulum_1mm.nii.gz \
        ${parentDirectory}/FA_individ/${subj}/FA/${subj}_masked_FA.nii.gz \
        ${parentDirectory}/${DIFF}_individ/${subj}/stats/\
        ${subj}_masked_${DIFF}skel -a \
        ${parentDirectory}/${DIFF}_individ/${subj}/${DIFF}/${subj}_masked_$\
        {DIFF}.nii.gz -s \
        ${ENIGMAtemplateDirectory}/ENIGMA_DTI_FA_skeleton_mask.nii.gz
     
        done
    done
    ```

Now you should have your diffusivity skeletons!

\*\*Check to make sure all skeletons cover the identical set of voxels, for 
example:

```bash
FSLDIR=/usr/local/fsl-5.0.7/
 
${FSLDIR}/bin/fslview \
${parentDirectory}/MD_individ/${subj}/stats/subj_1_masked_MDskel.nii.gz \
${parentDirectory}/FA_individ/subj_1/stats/subj_1_masked_FAskel.nii.gz \
${ENIGMAtemplateDirectory}/ENIGMA_DTI_FA_skeleton.nii.gz
```

Now we can extract ROI measures from these skeletons!

Remember you have already done this with FA

**[SCRIPT HERE](/DTI/ROIExtraction)**

Here the runDirectory represents the directory where all your downloaded scripts
and codes are located.

The descriptions of the commands (from the protocol) are below the code

```
parentDirectory=/enigmaDTI/TBSS/run_tbss/
runDirectory=/enigmaDTI/TBSS/run_tbss/
 
for DIFF in MD AD RD
do
    mkdir ${parentDirectory}/${DIFF}_individ/${DIFF}_ENIGMA_ROI_part1
    dirO1=${parentDirectory}/${DIFF}_individ/${DIFF}_ENIGMA_ROI_part1/

    mkdir ${parentDirectory}/${DIFF}_individ/${DIFF}_ENIGMA_ROI_part2
    dirO2=${parentDirectory}/${DIFF}_individ/${DIFF}_ENIGMA_ROI_part2/
 
    for subject in subj_1 subj_2 … subj_N
    do
 
        ${runDirectory}/singleSubjROI_exe ${runDirectory}/\
        ENIGMA_look_up_table.txt ${runDirectory}/mean_FA_skeleton.nii.gz \
        ${runDirectory}/JHU-WhiteMatter-labels-1mm.nii.gz \
        ${dirO1}/${subject}_${DIFF}_ROIout ${parentDirectory}/${DIFF}_\
        individ/${subject}/stats/${subject}_masked_${DIFF}skel.nii.gz
 
        ${runDirectory}/averageSubjectTracts_exe \
        ${dirO1}/${subject}_${DIFF}_ROIout.csv \
        ${dirO2}/${subject}_${DIFF}_ROIout_avg.csv
 
        # can create subject list here for part 3!
        echo ${subject},${dirO2}/${subject}_${DIFF}_ROIout_avg.csv >> \
        ${parentDirectory}/${DIFF}_individ/subjectList_${DIFF}.csv
    done
 
    Table=${parentDirectory}/ROIextraction_info/ALL_Subject_Info.txt 
    subjectIDcol=subjectID
    subjectList=${parentDirectory}/${DIFF}_individ/subjectList_${DIFF}.csv
    outTable=${parentDirectory}/${DIFF}_individ/combinedROItable_${DIFF}.csv
    Ncov=3  #2 if no disease
    covariates="Age;Sex;Diagnosis" # Just "Age;Sex" if no disease
    Nroi="all" 
    rois="all"
 
    #location of R binary 
    Rbin=/usr/local/R-2.9.2_64bit/bin/R
 
    #Run the R code
    ${Rbin} --no-save --slave --args ${Table} \
    ${subjectIDcol} ${subjectList} ${outTable} \
    ${Ncov} ${covariates} ${Nroi} ${rois} < \
    ${runDirectory}/combine_subject_tables.R
done
```

1.  The first command – **singleSubjROI_exe** uses the atlas and skeleton to 
    extract ROI values from the JHU-atlas ROIs as well as an average diffusivity
    value across the entire skeleton
    *   It is run with the following inputs
        *   ./singleSubjROI_exe look_up_table.txt skeleton.nii.gz 
            JHU-WhiteMatter-labels-1mm.nii.gz OutputfileName 
            Subject_FA_skel.nii.gz
    *   The output will be a .csv file called Subject1_ROIout.csv with all mean 
        FA values of ROIs listed in the first column and the number of voxels 
        each ROI contains in the second column (see 
        **ENIGMA_ROI_part1/Subject1_ROIout.csv** for example output)
2.  The second command – **averageSubjectTracts_exe** uses the information from 
    the first output to average relevant (example average of L and R external 
    capsule) regions to get an average value weighted by volumes of the regions.
    *   It is run with the following inputs
        *   ./averageSubjectTracts_exe inSubjectROIfile.csv 
            outSubjectROIfile_avg.csv
        *   where the first input is the ROI file obtained from Step 4 and the 
            second input is the name of the desired output file.
    *   The output will be a .csv file called outSubjectROIfile_avg.csv with all
        mean FA values of the new ROIs listed in the first column and the number
        of voxels each ROI contains in the second column (see 
        **ENIGMA_ROI_part2/Subject1_ROIout_avg.csv** for example output)
3.  The final portion of this analysis is an ‘R’ script **R** that takes into 
    account all ROI files and creates a spreadsheet which can be used for GWAS 
    or other association tests. It matches desired subjects to a meta-data 
    spreadsheet, adds in desired covariates, and combines any or all desired 
    ROIs from the individual subject files into individual columns.
    *   Input arguments as shown in the bash script are as follows:
        *   Table=./ALL_Subject_Info.txt
            *   A meta-data spreadsheet file with all subject information and 
                any and all covariates
        *   subjectIDcol=subjectID
            *   the header of the column in the meta-data spreadsheet referring 
                to the subject IDs so that they can be matched up accordingly 
                with the ROI files
        *   subjectList=./subjectList.csv
            *   a two column list of subjects and ROI file paths.
            *   this can be created automatically when creating the average ROI 
                .csv files – see sh on how that can be done
        *   outTable=./combinedROItable.csv
            *   the filename of the desired output file containing all 
                covariates and ROIs of interest
        *   Ncov=2
            *   The number of covariates to be included from the meta-data 
                spreadsheet
            *   At least age and sex are recommended
        *   covariates=”Age;Sex”
            *   the column headers of the covariates of interest
            *   these should be separated by a semi-colon ‘;’ and no spaces
        *   Nroi=”all”
            *   The number of ROIs to include
            *   Can specify “all” in which case all ROIs in the file will be 
                added to the spreadsheet
            *   Or can specify only a certain number, for example 2 and write 
                out the 2 ROIs of interest in the next input
        *   rois= “all” #”IC;EC”
            *   the ROIs to be included from the individual subject files
            *   this can be “all” if the above input is “all”
            *   or if only a select number (ex, 2) ROIs are desired, then the 
                names of the specific ROIs as listed in the first column of the 
                ROI file
                *   these ROI names should be separated by a semi-colon ‘;’ and 
                    no spaces for example if Nroi=2, rois=”IC;EC” to get only 
                    information for the internal and external capsules into the 
                    output .csv file
            *   (see csv for example output)

Congrats! Now you should have all of your subjects ROIs in one spreadsheet per 
diffusivity measure with only relevant covariates ready for association testing!
