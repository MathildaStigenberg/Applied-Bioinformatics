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

database_path="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/106-vc-genomicsDB-subset"

list="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/105-list-samples-subset/list-samples-subset.tsv"

gatk  --java-options "-Xmx4g" \
            GenomicsDBImport \
            --genomicsdb-workspace-path $database_path \
            --batch-size 16 \
	    -L MtDNA \
            --sample-name-map $list \
            --reader-threads 5
