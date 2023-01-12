#!/usr/bin/env/python3
import subprocess
import csv

path_file = "/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/129-compare-cendr-our/544-cendr.tsv"
content = list()
seen = set()
with open(path_file, "r") as mtdna_subset:
    with open("544-cendr-extract-sites.tsv","w") as mtdna_sites:
        columns = csv.reader(mtdna_subset, delimiter ="\t")
        for line in columns:
            if line[0] == "MtDNA":
                for col in line[9:553]:
                    if col[0:3] == "0/0":
                        continue
                    else:
                        if (line[1],line[4]) not in seen:
                            seen.add((line[1],line[4]))
                            content.append("\t".join(line))
        file_cont = "\n".join(content)
        mtdna_sites.write(file_cont)

output = "/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/129-compare-cendr-our/544-cendr-extract-sites.tsv"

subprocess.Popen(f"mv 544-cendr-extract-sites.tsv {output}", shell = True)





