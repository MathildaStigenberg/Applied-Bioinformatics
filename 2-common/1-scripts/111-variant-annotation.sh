#!/bin/bash -l

#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 10:00:00
#SBATCH -J annotation
#SBATCH -o annotation.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user hanna.hyllander.8450@student.uu.se

#module load
ml bioinfo-tools snpEff/4.3t

#input file is the mtdna-hard-filtered vcf-file
input=${1}

#the output files will have the suffix .ann.vcf and be stored in our result folder
output=${2}

#-ud 0 meaning that the upstream and downstream size is 0, -c because we are not running the script in snpEff
java -Xmx8g -jar $SNPEFF_ROOT/snpEff.jar eff -no-upstream -no-downstream -ud 0 -c $SNPEFF_ROOT/snpEff.config -v c_elegans.PRJNA13758.WS283 $input > $output  

