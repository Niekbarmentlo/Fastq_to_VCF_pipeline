# Fastq_to_VCF_pipeline
This bioinformatics pipeline is designed to trim and map reads, and variant call the output. The code is designed to be run on a high-performance cluster running on a Debian system, which one can use to interact using SLURM. The scripts makes use of parallelization and multi-threading while working in Conda environments to avoid installing software directly on the HPC itself.


## Installation
#### Standalone:
- Miniconda: https://docs.anaconda.com/miniconda/install/#quick-command-line-install

All other necessary softwares are described in the .yml files. Please use the code in the script CONDA_STUFF_Create.sh to create the environments with all software installed necessary for the other scripts.

## General pipeline
Please see for reference the diagram in FLOWCHART.pdf to see the order in which these scripts should be run. 
