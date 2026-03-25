#!/bin/bash --login
#-----------------------------Mail address-----------------------------
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=/sbatch_scripts/Output_file/Output_%j.txt
#SBATCH --error=/sbatch_scripts/Error_output/Error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment=12
#SBATCH --job-name=Mapping
#-----------------------------Required resources-----------------------
#SBATCH --time=5-20:00:00
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=8
#SBATCH --mem=100000
#-----------------------------Environment, Operations and Job steps----

InputDir=/40Latvia_unmapped_secondbatch/Sequences/SecondBatch/
OutputDir=/Mapped_69Latvia/Mapped_samples_secondBatch/
inds=Sequenced_samples.txt #list of fastq files without extensions. E.g. 'Individual1_name_file_1.fq' and 'Individual1_name_file_2.fq' would be condensed to one line with name 'Individual1_name_file'
#Comment, make sure that a copy of the 'inds' file.txt is in the InputDir as well as the OutputDir
refGenome=/ncbi_dataset/data/GCF_000003025.6/GCF_000003025.6_Sscrofa11.1_genomic.fna
TMPDIRs_dir=/tmpdirs/SecondBatchthirdSet #directory for temporary files produced by samtools during the mapping step

conda activate Mapping_5 #this environment should include samtools, picard, bwa-mem2,qualimap

cd $InputDir 

#Map reads to the reference genome, Sort the output, 
cat "${inds}" | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_mapping.log \
    "TMPDIR=\$(mktemp -d -p ${TMPDIRs_dir}) && \
    trap 'rm -rf \$TMPDIR' EXIT && \
    bwa-mem2 mem -t ${SLURM_CPUS_PER_TASK} -M ${refGenome} {}_1.trimmed.fq.gz {}_2.trimmed.fq.gz | \
    samtools sort -T \$TMPDIR/samtools_tmp -o ${OutputDir}{}.sort.bam"
		
wait

cd $OutputDir

cat "${inds}" | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_qualimapbatch4.log \
	"samtools index -@ ${SLURM_CPUS_PER_TASK} {}.sort.bam"

wait

#Remove PCR duplicates
cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_removeduplicates.log \
	"picard MarkDuplicates --INPUT {}.sort.bam \
    		--REMOVE_DUPLICATES true \
	--METRICS_FILE {}_witoutDups.sort.metrics.txt \
    		--OUTPUT {}.sort.noDups.bam"

wait

cat "${inds}" | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_qualimapbatch4.log \
	"samtools index -@ ${SLURM_CPUS_PER_TASK} {}.sort.noDups.bam"

wait

cat $inds | parallel --verbose -j ${SLURM_NTASKS} --joblog runtask_qualimapbatch4.log \
	"qualimap bamqc -bam {}.sort.noDups.bam -nt ${SLURM_CPUS_PER_TASK} --java-mem-size=12G"

