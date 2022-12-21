#!/usr/bin/env/python3

import os
import subprocess

path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/003-mtdna"

files = os.listdir(path)

filter = [".bai"]

bamfiles = [s for s in files if all(a not in s for a in filter)]

for f in bamfiles:
    subprocess.Popen(f"samtools index {path}/{f}", shell = True)
