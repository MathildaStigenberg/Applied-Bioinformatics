#!/usr/bin/env bash

module load bioinfo-tools GATK/4.3.0.0
cd ../../1-data/005-mtdna-subset/
for sample in *
do
  gatk Mutect2 \
  -R ../c_elegans.PRJNA13758.WS283.genomic.fa \
  -L MtDNA \
  --mitochondria-mode \
  -I $sample \
  -O ../201-mtdna-vcf-dgmsk/${sample}.vcf.gz &
done
wait