#!/usr/bin/env bash

module load bioinfo-tools samtools

for bam in ../../1-data/005-mtdna-subset/*
do
    samtools index $bam
done