#!/usr/bin/env bash

# will rename the header in the fasta files from MtDNA to the corresponding name of the file
sed -i "s/>MtDNA/>$(basename ${1%%.*})/" ${1}
