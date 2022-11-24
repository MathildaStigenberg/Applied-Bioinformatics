#!/bin/bash -l

#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 10:00:00
#SBATCH -J phylogenetic_tree
#SBATCH --mail-type=ALL
#SBATCH --mail-user hanna.hyllander.8450@student.uu.se

#module load
ml bioinfo-tools snpEff

#input file is the mtdna-hard-filtered vcf-file
input=${1}

#the output files will have the suffix .ann.vcf and be stored in our result folder
output=${2}

#Variant annotation with snpEff
java -Xmx8g -jar $SNPEFF_ROOT/snpEff.jar -v Caenorhabditis_elegans $input > $output  
