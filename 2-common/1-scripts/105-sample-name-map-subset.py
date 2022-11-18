#!/usr/bin/env/python3
import os
from subprocess import Popen
import csv
import glob

path = "/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/104-vc-haplotypecaller-subset/*.gz"
paths = glob.glob(path)

files = list(map(os.path.basename, paths))

files_with_suffix_and_without = list()

for f , p in zip(files, paths):
    files_with_suffix_and_without.append(f.removesuffix(".g.vcf.gz") + "\t" + p)

with open("list-samples-subset.tsv","w") as my_list_file:
    file_content = "\n".join(files_with_suffix_and_without)
    my_list_file.write(file_content)

Popen(f"mv /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/1-scripts/list-samples-subset.tsv /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/105-list-samples-subset/list-samples-subset.tsv", shell = True)


