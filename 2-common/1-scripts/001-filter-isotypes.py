#!/usr/bin/env python3
import subprocess
import csv
isotypes = set()
with open("../../1-data/CelegansStrainData.tsv", "r") as file:
    strains = csv.reader(file, delimiter = "\t")
    header = True
    for line in strains:
        if (header):
            header = False
        else:
            # print(line)
            isotypes.add(line[3])

for isotype in isotypes:
        subprocess.run(["cp", f"../../1-data/001-raw/strain_bams/{isotype}.bam.bai", f"../../1-data/002-isotypes/"])
	subprocess.run(["cp", f"../../1-data/001-raw/strain_bams/{isotype}.bam", f"../../1-data/002-isotypes/"])

