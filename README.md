# VirEst
VirEst is based on the eHive framework, which is a robust, scalable and resilient workflow management system devel- oped at EBI. VirEst is designed for determining the viral diversity from raw 454 pyrosequencing data of Hepatitis C virus sequences. Viral genetic diversity is one of the factors contributing to a viral population’s response to environmental challenges, such as antiviral drug therapy.

The eHive system was primarily developed for the Ensembl (Flicek et al. 2014) database resource creation pipelines. It is de- signed as a highly scalable and fault-tolerant distributed processing system. It is compatible with a wide range of infrastructure, run- ning on local PC’s, HPCs and cloud based computing services like Amazon EC2.

VirEst is a standard eHive pipeline consisting of seven main stages. These are composed of open source bioinformatics tools as well as custom scripts for the statistical calculations.

1. Initialization
All the data for a particular run is stored in a folder created in this step, with a timestamp of the pipeline initialization. The input files are also fetched from either local or cloud storage.
2. File handling
This step is used for manipulating input files necessary for downstream analysis. For instance, we use 454 data which is in form of .sff files. These have to be converted to the standard .fasta format using sff_extract (http://bioinf.comav.upv.es/seq_crumbs/). This stage can be modified to account for different sources of input data.
3. Quality Control
The processed input data is filtered for quality control and general adapter trimming. CutAdapt (https://code.google.com/p/cutadapt/) is used for trimming the 454 adapters and filtering reads by quality scores. FastQC (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) is used for generating a html report for each input file.
4. Sequence alignment
We perform alignment by reference for our amplicon data. The reference sequence in fasta format has to be specified in the pipeline configuration. We use BWA (Li et al., 2009) but this step can be altered as required by the experiment, e.g. a de novo assembler can be used instead of alignment by reference.
5. Variant Calling
The statistical calculations for diversity depend on frequencies of variants found in the samples. We obtain those by parsing the bam files from BWA using Samtools (Li et al., 2009).
6. Statistical calculations
The main analysis of viral diversity is performed via a Perl script which takes a list of variants and their frequencies as the input. Diversity is calculated using expected heterozygosity (Li et al., 1979)
7. Final output
The earlier steps are run for each sample, once each sample has been ana- lyzed the final values of the viral diversity are presented as a single csv file. Additionally, results from each step are stored in separate folders for easy rechecking of any step in the analysis 

##Usage
VirEst has been designed to work on eHive 2.7. Additional prerequisites for the pipeline are the reference sequences and scripts for the nucleotide diversity calculations. The pipeline is invoked from the command line, and it can be monitored using guiHive (https://github.com/Ensembl/guiHive) on a web browser.
