#!/usr/bin/env/python3

import os
import subprocess

path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/4-vcf-Cendr"

file_vcf = path + "/" + "soft-isotypes.vcf.gz"
output = path + "/" + "1-2-mtdna-vcf"

subprocess.Popen(f"bcftools view {file_vcf} --regions MtDNA -o {output} -O z", shell = True)
