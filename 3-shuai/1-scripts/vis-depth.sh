#!/usr/bin/env bash

project="/proj/snic2022-6-224/private/Applied-Bioinformatics"
module load bioinfo-tools samtools
for x in ${project}/1-data/3-mtdna/*.bam
do
samtools depth $x > ${project}/3-shuai/3-results/${x##*/}.depth &
done
wait
