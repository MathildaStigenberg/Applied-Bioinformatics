#!/usr/bin/env/python3
import os
from subprocess import Popen
import csv
import glob
import sys

# Path to all the files (*.gz) in the haplotypecaller folder, have citation
# marks around the path " ". 
path = sys.argv[1]

# Path to the output folder
output = sys.argv[2]

paths = glob.glob(path)

files = list(map(os.path.basename, paths))

files_with_suffix_and_without = list()

for f , p in zip(files, paths):
    files_with_suffix_and_without.append(f.removesuffix(".g.vcf.gz") + "\t" + p)

with open("list-samples.tsv","w") as my_list_file:
    file_content = "\n".join(files_with_suffix_and_without)
    my_list_file.write(file_content)

Popen(f"mv list-samples.tsv {output}/list-samples.tsv", shell = True)


