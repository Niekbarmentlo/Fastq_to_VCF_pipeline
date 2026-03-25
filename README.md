# Fastq_to_VCF_pipeline
This bioinformatics pipeline is designed to trim and map reads, and variant call the output. The code is designed to be run on a high-performance cluster running on a Debian system, which one can interact with using SLURM. The scripts makes use of parallelization and multi-threading while working in Conda environments to avoid installing software directly on the HPC itself.


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


# General comments
All these scripts use parallelization. This implies that the cluster is processing multiple files at the same time in different 'jobs'. The amount of files that are being processed is specificied by specifying ```#SBATCH --ntasks=``` . After which, the amount of CPUs working on one particular file is specified in ```#SBATCH --cpus-per-task=``` . So as an example, if I specify the following:

```#SBATCH --ntasks=2```  
```#SBATCH --cpus-per-task=3```

Two files are assessed (or in the case of fastq files, 4 files, as fastq always comes in pairs) and in total 6 cpu's are used (3 x 2).

To run the pipeline, you only have the assess the skeleton of the script (i.e. the ```#sbatch lines```) and specify the input directory (inputDir), outputDir and make some files including the name of your samples to be assessed. These sometimes are with file extensions (e.g. bamfile.bam) and sometimes without (e.g. bamfile), but it is specified in individual scripts. The Python_generate_add_RG.py script generates code to be run using Add_readgroups.sh, for convenience.
