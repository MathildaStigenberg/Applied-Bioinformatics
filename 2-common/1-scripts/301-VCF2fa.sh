#!/usr/bin/env bash
#SBATCH -A snic2022-5-408
#SBATCH -p node
#SBATCH -n 1
#SBATCH -t 15:00
#SBATCH -J vcf2fa
#SBATCH -o vcf2fa.output
#SBATCH --mail-type=FAIL
#SBATCH --mail-user hanna.hyllander.8450@student.uu.se

# load modules
ml bioinfo-tools bcftools/1.14


input='/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/120-hard-filtered-all-samples/mtdna-hard-filtered.vcf'
ref='/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa'


bcftools view -s ${1} $input -O z -o /proj/snic2022-6-224/private/Applied-Bioinformatics/5-hanna/tempo_vcf/${1}.vcf.gz
bcftools index /proj/snic2022-6-224/private/Applied-Bioinformatics/5-hanna/tempo_vcf/${1}.vcf.gz
bcftools consensus -f $ref /proj/snic2022-6-224/private/Applied-Bioinformatics/5-hanna/tempo_vcf/${1}.vcf.gz > ${2}/${1}.fa


