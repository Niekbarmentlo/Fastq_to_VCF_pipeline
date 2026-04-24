#!/bin/bash --login
#-----------------------------Mail address-----------------------------
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=/sbatch_scripts/Output_file/output_%j.txt
#SBATCH --error=/sbatch_scripts/Error_output/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment=12
#SBATCH --job-name=VCF_processing
#-----------------------------Required resources-----------------------
#SBATCH --time=4-200:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100000
#-----------------------------Environment, Operations and Job steps----

VCFin=VCF_GWAS_40Latvia.vcf.gz
VCFout=VCF_GWAS_40Latvia_SNPs.vcf.gz
VCFauto=VCF_GWAS_40Latvia_SNPs_autosomal.vcf.gz
VCFdp=VCF_GWAS_40Latvia_SNPs_autosomal.DP.vcf.gz

conda activate VCF_processing #.yml not included in this GitHub repository

outdir=/Latvia_GWAS

cd ${outdir}

rtg vcfstats ${VCFin} > rtg_results_fullVCF.out

bcftools view -m2 -M2 -v snps --no-version -Oz -o ${VCFout} ${VCFin} 
tabix -p vcf ${VCFout}

bcftools convert -R Keep_chromosome_contigs.bed --no-version -Oz -o ${VCFauto} ${VCFout}
tabix -p vcf ${VCFauto}

vcftools --gzvcf ${VCFauto} --minDP 5 --minGQ 30 --recode --recode-INFO-all --stdout | bgzip -c > ${VCFdp}
tabix -p vcf ${VCFdp}
