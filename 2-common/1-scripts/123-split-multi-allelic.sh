#!/usr/bin/env bash
#SBATCH -A snic2022-5-408
#SBATCH -p node
#SBATCH -n 1
#SBATCH -t 15:00
#SBATCH -J 123-split-multiallelic
#SBATCH -o 123-split-multiallelic.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se
#SBATCH --qos=short

# -V /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/124-hard-filtering-multiallelic/mtdna-hard-filtered.vcf
# -O /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/127-hard-filtering-split-multiallelic/hard-filtered-split.vcf


ml bioinfo-tools GATK/4.3.0.0 &&

gatk LeftAlignAndTrimVariants \
  -R /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa \
  -V /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/203-merge-vcf/merged-variant-calling.vcf \
  -O /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/203-merge-vcf/merged-split.vcf \
  --split-multi-allelics \
  --dont-trim-alleles