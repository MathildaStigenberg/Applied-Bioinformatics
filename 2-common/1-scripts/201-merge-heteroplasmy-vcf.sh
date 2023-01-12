#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 2:00:00
#SBATCH -J 201-merge-vcf
#SBATCH -o 201-merge-vcf.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

# Load modules
module load bioinfo-tools
module load bcftools/1.14

# The input .txt file containing the path to all heteroplasmy .vcf files 
input=${1}

# The output, a merged .vcf file 
output=${2}

lines=$(cat $input)

for file in $lines
do
	bcftools index $file
	bcftools index --tbi $file
done

bcftools merge --file-list $input -O z -o temporary.vcf.gz 

bcftools index temporary.vcf.gz
bcftools index --tbi temporary.vcf.gz

bcftools norm -m -both -O z -o $output temporary.vcf.gz

bcftools index $output
bcftools index --tbi $output

rm temporary.vcf.gz*

