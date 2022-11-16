#!/usr/bin/env bash
module load bioinfo-tools bwa samtools GATK

samtools faidx -o \
/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa.fai \
/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa

bwa index \
/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa

gatk CreateSequenceDictionary \
-R /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa