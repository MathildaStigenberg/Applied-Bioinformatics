#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 15:00
#SBATCH -J 106-genomicdDB
#SBATCH -o 106-genomicsDB.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

# Load modules
module load bioinfo-tools
module load GATK/4.1.4.1

# Path to the database folder that will be created in this step   
database_path=${1}

# Path to the file displaying two lists separated by tab, first col is the samples and the second col is the path to samples
# The list is a sample-name-map 
list=${2}

gatk  --java-options "-Xmx4g" \
            GenomicsDBImport \
            --genomicsdb-workspace-path $database_path \
            --batch-size 16 \
	    -L MtDNA \
            --sample-name-map $list \
            --reader-threads 5
