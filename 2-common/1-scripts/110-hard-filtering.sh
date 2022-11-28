#!/bin/bash -l

#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 15:00
#SBATCH -J 110-hard-filtering
#SBATCH -o 110-hard-filtering.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

# Load modules
module load bioinfo-tools
module load vcftools
module load bcftools

# The input is the path to the soft-filtered .vcf.gz file 
input=${1}
# The first output file is a path to a .vcf file displaying the frequencies
freq=${2}
# The second outputfile is the path to a trimmed soft-filtered (hard-filtered) .vcf.gz file 
hard_filt=${3} 
# The third output is the path to a statistics .stats.txt file 
stats=${4}

bcftools view -m2 -M2 --trim-alt-alleles -O u --regions MtDNA -o temporary.vcf.gz $input

bcftools filter -O u --set-GTs . --exclude 'FORMAT/FT ~ "DP_min_depth"' -o temporary.vcf.gz temporary.vcf.gz 

bcftools filter -O u --exclude 'FILTER != "PASS"' -o temporary.vcf.gz temporary.vcf.gz
 
bcftools view -O v --min-af 0.000001 --max-af 0.999999 -o temporary.vcf.gz temporary.vcf.gz

bcftools view -O v -t ^MtDNA:13329-13794 -o temporary.vcf.gz temporary.vcf.gz 
 
vcftools --freq --gzvcf temporary.vcf.gz --out $freq
 
bcftools view -O z --trim-alt-alleles temporary.vcf.gz > $hard_filt

bcftools index $hard_filt
bcftools index --tbi $hard_filt
bcftools stats -s- --verbose $hard_filt > $stats

rm temporary.vcf.gz*
