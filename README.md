# Fastq_to_VCF_pipeline
This bioinformatics pipeline is able to trim and map short reads, and variant call the output. The code is designed to be run on a high-performance cluster running on a Debian system, which one can interact with using SLURM. The scripts make use of parallelization and multi-threading while operating in Conda environments to avoid installing software directly on the HPC itself.


## Installation
#### Standalone:
- Miniconda: https://docs.anaconda.com/miniconda/install/#quick-command-line-install

All other necessary softwares are described in the .yml files (software versions are outdated). Install software using:

```conda create -n Mapping```  
```conda activate Mapping```  
```conda config --add channels conda-forge```  
```conda config --add channels bioconda```  
```conda config --set channel_priority strict```  
```conda env update --file Mapping_environment.yml``` 


## Order pipeline:

1. Trimm_reads.sh
2. bwamem.sh
3. Add_readgroups.sh
4. Freebayes_parallel.sh
5. VCF_processing.sh (optional, based on goal project)

Note, the pipeline expects all sbatch script to be in a separate scripts directory, away from any sequencing files. The pipeline will break if this is not the case. 

## Main Softwares
- fastp
- bwa-mem2
- Picard (for removing PCR duplicates and adding read groups)
- freebayes 

## General comments
All these scripts use parallelization. This implies that the cluster is processing multiple files at the same time in different 'jobs'. The amount of files that are being processed is specificied by specifying ```#SBATCH --ntasks=``` . After which, the amount of CPUs working on one particular file is specified in ```#SBATCH --cpus-per-task=``` . So as an example, if I specify the following:

```#SBATCH --ntasks=2```  
```#SBATCH --cpus-per-task=3```

Two files are assessed (or in the case of fastq files, 4 files, as fastq always comes in pairs) and in total 6 cpu's are used (3 x 2).

To run the pipeline, you only have the assess the skeleton of the script (i.e. the ```#sbatch``` lines) and specify the input directory (inputDir), outputDir and make some files including the name of your samples to be assessed. These sometimes are with file extensions (e.g. bamfile.bam) and sometimes without (e.g. bamfile), but it is specified in individual scripts. The Python_generate_add_RG.py script generates code to be run using Add_readgroups.sh, for convenience.  

## Adviced manual checks
With any pipeline, there are certainly potential risks caused by either human or computational errors. Here I highlight what I found to be important (sanitity) checks during the entire pipeline:

1. Sequencing companies often do not deliver the amount of sequenced base pairs they promised. The fastqc command in this pipeline checks the trimmed fastq files. If any discrepancies arise between what the sequencing company promised and you observed, I advice running fastqc also on the untrimmed fastq files.
2. The bwamem.sh script makes use of temporary directories which are created during the parallelization command. The goal is here to separate the streams of temporary files to avoid mismatching BAMs. I advice checking whether temporary files are actually being produced in all temporary directories.
3. Compare the size of the .sort.bam and the .sort.nodups.bam files. They should be more or less the same size. If they are not, it might be worth checking whether you observe a lot of PCR duplicates in the .sort.bam files. You can do this by running ```qualimap bamqc``` on the .sort.bam files.
4. The ```qualimap bamqc``` genome_results.txt files include a lot of information. In my opinion, it is most important to check the "mean coverageData", "number of mapped reads", "number of sequenced bases", the "mean mapping quality" and the coverage of the last chromosome (to assess whether the BAM contains all data). A helpful command for this is: ```find . -name "genome_results.txt" -exec grep -H "mean coverageData =" {} >> Genome_results_allBAMs.txt \;```
5. When an High Performance Computing cluster crashes, it typically corrupts the outputted BAM. To check for this, you can assess whether you can index the BAM. Additionally running ```samtools quickcheck -v *.bam``` is useful. Note, this only works on "truncated BAMs". When adding read groups using Picard, BAMs DO NOT GET TRUNCATED (I learned this the hard way). When you expect potential HPC failure during the addition of read groups, run ```qualimap bamqc``` and check for coverage in ALL CONTIGS (not just whether mean coverage seems okay). 
6. Run ```bcftools query -l <name>.vcf.gz``` to check the amount of samples in your VCF. If there is a mismatch, this is likely through either a corrupted BAM or a problem with the read groups.
