#!/usr/bin/env/python3

import os
import subprocess
from glob import glob
path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/002-isotypes"
files = os.listdir(path)

filter = [".bai"]

bamfiles = [s for s in files if all(a not in s for a in filter)]

for file in bamfiles:
    bamfile = path + "/" + file
    subprocess.Popen(f" samtools view {bamfile} MtDNA -b -o /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/003-mtdna/{file}", shell = True)
     




