#!/bin/bash --login
#-----------------------------Mail address-----------------------------
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=/sbatch_scripts/Output_file/output_%j.txt
#SBATCH --error=/sbatch_scripts/Error_output/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment=12
#SBATCH --job-name=Variant_calling
#-----------------------------Required resources-----------------------
#SBATCH --time=4-200:00:00
#SBATCH --ntasks=20
#SBATCH --cpus-per-task=2
#SBATCH --mem=100000
#-----------------------------Environment, Operations and Job steps----


#IMPORTANT, you need a specific python script to run this code called 'fasta_generate_regions.py'. Download from https://github.com/freebayes/freebayes/blob/master/scripts/fasta_generate_regions.py


conda activate Freebayes #should include bcftools, samtools, freebayes, biopet-vcffilter

REF=/ncbi_dataset/data/GCF_000003025.6/GCF_000003025.6_Sscrofa11.1_genomic.fna
BAMlist=Bamlist_40Individuals.txt #file with the name of all BAMs to be used in variant calling, include extensions. E.g. BAM1.sort.noDups.RG.bam
outdir=/VCF

cd ${outdir}

freebayes-parallel <(fasta_generate_regions.py ${REF}.fai 100000) 20 -f ${REF} --use-best-n-alleles 4 --min-base-quality 10 --min-alternate-fraction 0.2 --haplotype-length 0 --ploidy 2 --min-alternate-count 2 -L ${BAMlist} | vcffilter -f 'QUAL > 20' | bgzip -c > ${outdir}/VCF_GWAS_40Latvia.vcf.gz


