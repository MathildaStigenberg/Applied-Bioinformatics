#!/usr/bin/env/python3

import os
import subprocess
path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/2-isotypes"
files = os.listdir(path)

for file in files:
    bamfile = path + "/" + file
    subprocess.Popen(f"samtools view {bamfile} MtDNA -b -o /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/3-mtdna/{file}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    





#samtools view -r MtDNA /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/1-raw/strain_bams/ECA1793.bam -b -o testmtbam.bam
