#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 30:00
#SBATCH -J 004-extract-mtdna
#SBATCH -o 004-extract-mtdna.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

mtdna=$(find /proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/201-heteroplasmy/MitochondriaPipeline -wholename /*/call-SubsetBamToChrM/execution/*)

for file in ${mtdna};
do
	ln -s $file /proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/007-mtdna/$(basename $file)
done
