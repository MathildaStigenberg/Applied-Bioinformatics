#!/bin/bash -l

#SBATCH -A snic2022-5-408
#SBATCH -p node
#SBATCH -n 1
#SBATCH -t 15:00
#SBATCH -J 110-hard-filtering
#SBATCH -o 110-hard-filtering-multiallelic.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se
#SBATCH --qos=short

# Load modules
ml bioinfo-tools vcftools/0.1.16 bcftools/1.14 &&

# The input is the path to the soft-filtered soft-filter.vcf.gz file 
input=${1}
# The first output file is a path to a .vcf file displaying the frequencies
freq=${2}
# The second outputfile is the path to a trimmed soft-filtered (hard-filtered) .vcf.gz file 
hard_filt=${3} 
# The third output is the path to a statistics .stats.txt file 
stats=${4}

bcftools view --trim-alt-alleles -O z --regions MtDNA -o temporary1.vcf.gz $input
bcftools index temporary1.vcf.gz
bcftools index --tbi temporary1.vcf.gz


bcftools filter -O z --set-GTs . --exclude 'FORMAT/FT ~ "DP_min_depth"' -o temporary2.vcf.gz temporary1.vcf.gz
bcftools index temporary2.vcf.gz
bcftools index --tbi temporary2.vcf.gz

bcftools filter -O z --exclude 'FILTER != "PASS"' -o temporary3.vcf.gz temporary2.vcf.gz
bcftools index temporary3.vcf.gz
bcftools index --tbi temporary3.vcf.gz

bcftools view -O z --min-af 0.000001 --max-af 0.999999 -o temporary4.vcf.gz temporary3.vcf.gz
bcftools index temporary4.vcf.gz
bcftools index --tbi temporary4.vcf.gz

bcftools view -O z -t ^MtDNA:13329-13794 -o temporary5.vcf.gz temporary4.vcf.gz
bcftools index temporary5.vcf.gz
bcftools index --tbi temporary5.vcf.gz
 
vcftools --freq --gzvcf temporary5.vcf.gz --out $freq
 
bcftools view -O z --trim-alt-alleles temporary5.vcf.gz > $hard_filt

bcftools index $hard_filt
bcftools index --tbi $hard_filt
bcftools stats -s- --verbose $hard_filt > $stats

rm temporary*
