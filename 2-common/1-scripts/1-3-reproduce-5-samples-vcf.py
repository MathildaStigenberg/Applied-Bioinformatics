#!/usr/bin/env/python3

import os
import subprocess
path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/5-mtdna-vcf-cendr/1-2-mtdna-vcf.vcf.gz"
output = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/6-mtdna-vcf-subset-cendr/1-3-mtdna-subset.vcf.gz"

subprocess.Popen(f"bcftools view -s MY23,ECA1283,GXW1,NIC1,JU2800 {path} -o {output} -O z", shell = True)
