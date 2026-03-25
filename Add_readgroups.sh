#!/bin/bash --login
#-----------------------------Mail address-----------------------------
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=/sbatch_scripts/Output_file/output_%j.txt
#SBATCH --error=/sbatch_scripts/Error_output/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment=12
#SBATCH --job-name=Read_groups
#-----------------------------Required resources-----------------------
#SBATCH --time=200:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100000
#SBATCH --nodes=1
#-----------------------------Environment, Operations and Job steps----

conda activate Mapping_5 #See the .yml at the end of this file

InputDir=/Mapped_69Latvia/Mapped_samples_secondBatch/
SAMPLES=Bamlist_samplesRG.txt #this file has a listing for each bam with the extension ".sort.noDups.RG.bam". The 'RG' part of the extension is added when running 'Add_readgroup.sh'
TMPDIR=/tmpdirs/readgroup/
#The script Add_readgroups.sh is a long script with a code line to modify each individual bam
#a line might would look like this:
#picard AddOrReplaceReadGroups -I WB10_MKDN240010405-1A_22F2GWLT4_L2.sort.noDups.rgOLD.bam -O WB10_MKDN240010405-1A_22F2GWLT4_L2.sort.noDups.RG.bam --RGID WB10_22F2GWLT4 --RGLB MKDN240010405-1A --RGPL ILLUMINA --RGSM WB10 --RGPU WB10_unit --TMP_DIR "$TMPDIR"
#picard AddOrReplaceReadGroups -I <bamname.sort.noDups.bam> -O <bamname.sort.noDups.RG.bam> --RGID <sample_ID> --RGLB <libary_name> --RGPL <sequencing_platform> --RGSM <Sample_name> --RGPU <unique_arbitrary_barcode> --TMP_DIR "$TMPDIR"

cd $InputDir

parallel -j ${SLURM_NTASKS} < Add_readgroups.sh

wait 

cat $SAMPLES | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_qualimapbatch4.log \
	"samtools index {}"



#channels:
#  - conda-forge
#  - bioconda
#  - default
#dependencies:
#  - bcftools=1.15.1
#  - gatk4=4.4.0.0
#  - picard=3.1.0
#  - samtools=1.15.1
#  - bwa-mem2=2.2.1

