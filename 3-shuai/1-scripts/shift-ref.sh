#!/usr/bin/env bash

module load bioinfo-tools GATK/4.3.0.0

gatk ShiftFasta -R /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa \
-O /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/shift-ref-mt.fa \
--shift-back-output /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/shift-back.chain