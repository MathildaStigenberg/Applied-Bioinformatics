#!/usr/bin/env bash
module load bioinfo-tools SeqKit

reference="/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/c_elegans.PRJNA13758.WS283.genomic.fa"

seqkit seq -w 0 $reference | grep -A 1 \>MtDNA > ${reference%/*}/ref-mt.fa
