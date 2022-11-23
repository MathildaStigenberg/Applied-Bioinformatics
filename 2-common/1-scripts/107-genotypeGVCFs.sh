#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 15:00
#SBATCH -J 107-genotypeGVCFs
#SBATCH -o 107-genotypeGVCfs.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

# Load modules
module load bioinfo-tools
module load GATK/4.1.4.1

# Path to the reference .fa 
ref=${1}

# Path to the database folder, created from the genomicsDB script
database=${2}

# The path to the output file .vcf that will be created 
output=${3}

gatk  --java-options "-Xmx4g" \
            GenotypeGVCFs \
            -R $ref \
            -V gendb://${database} \
            -G StandardAnnotation \
            -G AS_StandardAnnotation \
            -G StandardHCAnnotation \
            -L MtDNA \
            -O $output

