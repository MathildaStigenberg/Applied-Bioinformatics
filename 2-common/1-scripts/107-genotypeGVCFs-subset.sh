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

ref="/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa"

database="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/106-vc-genomicsDB-subset"

output="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/107-genotypeGVCFs-subset/jointly-genotyped-vcf-subset.vcf"

gatk  --java-options "-Xmx4g" \
            GenotypeGVCFs \
            -R $ref \
            -V gendb://${database} \
            -G StandardAnnotation \
            -G AS_StandardAnnotation \
            -G StandardHCAnnotation \
            -L MtDNA \
            -O $output

