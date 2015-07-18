# Meta-Analysis Data Preparation Guidelines for the Childhood Intelligence Consortium (CHIC)

*Prepared by the Statistical Genetics Analysis Group*

The aim of the study is to perform a meta-analysis of GWAS results on childhood 
intelligence from participating laboratories in the Childhood Intelligence 
Consortium (CHIC).  The phenotype should be the best available measure of 
general cognitive ability (g) or IQ, derived from diverse tests that assess both
verbal and non-verbal ability.  In some studies this will be derived from an IQ 
test; in other studies, it will be derived from the first unrotated factor of a 
principal factor analysis.  Much research has shown that g is robust to the 
composition of the test battery.  The choice and exact definition of phenotype 
for each participating group can be discussed at part of the StatGen group 
deliberations.

The following guidelines are proposed to assist participating groups in 
preparing a summary of GWAS results that can be used for a meta-analysis. This 
guide assumes the analyses are of a quantitative trait in unrelated individuals.
It is also assumed that the meta-analysis will be performed on samples with 
European ancestry.

Each participating laboratory is requested to perform the following steps:

**A. Individual sample QC:** individuals removed based on missingness, 
heterozygosity, relatedness, population and ethnic outliers, and other 
cohort-specific QC steps. Please document all QC steps. We propose not to be 
more specific because some of the groups have already performed QC and the exact
choice of QC thresholds may depend on genotyping platform and study.

**B. SNP QC:** SNPs removed based on missingness, minor allele frequency (MAF < 
1%), Hardy–Weinberg (HWE p-value < 10<sup>-6</sup>), Mendelian errors (if family
data is available) and other QC, such as the mean of GeneCall score for Illumina
arrays. Please document all QC steps.

**C. Imputation:** We suggest to perform imputation using the MACH software 
(http://www.sph.umich.edu/csg/abecasis/MACH/download/) on QC-ed data using 
HAPMAP II CEU Panel (Release 22, NCBI Build36, dbSNP b126) and +ve strand as the
reference. No QC in terms of imputation quality is needed for imputed SNPs, but 
it is worth to double-check the directly genotyped SNPs as MACH replaces them. 
Please include all SNPs in the association analysis so that the list of 
association results is identical across all participating groups. In the 
meta-analysis we can remove badly imputed SNPs if necessary. If participating 
groups have already performed imputation using different software then we will 
accommodate this. We propose imputation to HapMap2 because (i) some groups have 
already performed imputation based upon HapMap2, (ii) all relevant data from 
HapMap3 for imputation purposes are not yet available (by July 23rd 2009) and 
(iii) there is little gain to be expected in going from HapMap2 to HapMap3.

**D. Association analysis:** Perform an association analysis on the dosage score
(the estimated counts of the reference allele in each individual; these 
estimates may be fractional and range from 0.0 to 2.0). MACH2QTL software 
(http://www.sph.umich.edu/csg/abecasis/MACH/download/) can be used to perform 
association analyses for quantitative traits on dosage score, but if preferred 
other software can also be used. Use an additive model on the standardised 
residuals (Z score, transformed to normality if the phenotype is highly skewed) 
of the trait after adjusting for known covariates (age, sex, cohort, etc., 
including subtle population stratification effects, e.g. the first 5 MDS or 
principal component scores for each individual from a stratification analysis) 
on both genotyped and imputed SNPs.  Both the directly genotyped and imputed 
SNPs should be aligned to the HapMap reference strand.

**E. Results:** Summarise the results (on +ve strand) into the following 
columns:

1.  **MARKER:** SNP rs-number
2.	**CHR:** Chromosome number
3.	**BP:** Genomic physical position in base pair according to NCBI Build36
4.	**EFALLELE:** Effect Allele (in A/C/G/T)
5.	**NONEFALLELE:** Non-reference Allele (in A/C/G/T)
6.	**FREQ:** Frequency of Effect Allele (column 4) 
7.	**N:** Number of individuals tested for that SNP
8.	**BETA:** The effect size in SD
9.	**SE:** Standard Error of Beta (column 8)
10.	**P:** Uncorrected P Value
11.	**PADJ:** Adjusted P Value for genomic control
12.	**LAMBDA:** The estimated inflation factor
13.	**PHWE:** Exact P Value of HWE test
14.	**CALL:** Call rate for genotyped SNP or write “1” for imputed SNP
15.	**IMPUTE:** Write “0” if the SNP is genotyped and “1” if the SNP is imputed.
16.	**RSQUARE:** MACH Rsq (the squared correlation between imputed and true 
    genotypes ranging from 0 to 1)
    
For groups using other software for imputation, columns 16 should be replaced by
Confidence score for the SNP/Maximum posterior probabilities (IMPUTE), allelic 
R<sup>2</sup> (BEAGLE) and Information metric/Info (PLINK).

Beben Benyamin & Peter Visscher