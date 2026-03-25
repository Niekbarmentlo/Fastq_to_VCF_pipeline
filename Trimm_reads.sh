#!/bin/bash --login
#-----------------------------Mail address-----------------------------
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=/sbatch_scripts/Output_file/Output_%j.txt
#SBATCH --error=/sbatch_scripts/Error_output/Error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment=12
#SBATCH --job-name=Trimm_reads_secondBatch_2ndSet
#-----------------------------Required resources-----------------------
#SBATCH --time=100:00:00
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=3
#SBATCH --mem=100000
#-----------------------------Environment, Operations and Job steps----

InputDir=/40Latvia_unmapped_secondbatch/Sequences/SecondBatch/
OutputDir=/40Latvia_unmapped_secondbatch/Sequences/SecondBatch/fastQC/
inds=Sequenced_samples.txt #list of fastq files without extensions. E.g. 'Individual1_name_file_1.fq' and 'Individual1_name_file_2.fq' would be condensed to one line with name 'Individual1_name_file'

cd $InputDir
 
conda activate Mapping #this environment should include fastp, samtools, fastqc

#trim reads (i.e. remove adaptors)
cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_fastp.log \
"fastp --in1 {}_1.fq.gz --in2 {}_2.fq.gz --out1 {}_1.trimmed.fq.gz --out2 {}_2.trimmed.fq.gz -l 50"

wait

#Make a directory for the fastQC files
cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog fastqc_runtask1.log \
        "mkdir --parents ${OutputDir}{}"

wait

#Make fastQC (quality control) files for all forward fastq files
cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog fastqc_runtask2.log \
        "fastqc --outdir ${OutputDir}{} {}_1.trimmed.fq.gz"
        
wait

#Make fastQC (quality control) files for all reverse fastq files
cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog fastqc_runtask3.log \
        "fastqc --outdir ${OutputDir}{} {}_2.trimmed.fq.gz"

