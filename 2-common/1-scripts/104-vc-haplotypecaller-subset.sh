#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 30:00
#SBATCH -J 104-haplotyper
#SBATCH -o 104-haplotyper.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user mathilda.stigenberg.5156@student.uu.se

# Load modules
module load bioinfo-tools
module load GATK/4.1.4.1

# Input
input_folder="/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/005-mtdna-subset/*bam"

# Reference 
ref="/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa"

# Output 
output="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/104-vc-haplotypecaller-subset"

for bamfile in ${input_folder};
do
	gatk --java-options '-Xmx4g' HaplotypeCaller \
	    --emit-ref-confidence GVCF \
            --annotation DepthPerAlleleBySample \
            --annotation Coverage \
            --annotation GenotypeSummaries \
            --annotation TandemRepeat \
            --annotation StrandBiasBySample \
            --annotation ChromosomeCounts \
            --annotation ReadPosRankSumTest \
            --annotation AS_ReadPosRankSumTest \
            --annotation AS_QualByDepth \
            --annotation AS_StrandOddsRatio \
            --annotation AS_MappingQualityRankSumTest \
            --annotation DepthPerSampleHC \
            --annotation-group StandardAnnotation \
            --annotation-group AS_StandardAnnotation \
            --annotation-group StandardHCAnnotation \
            --do-not-run-physical-phasing \
	    -R $ref \
	    -I $bamfile \
	    -L MtDNA \
	    -O ${output}/$(basename ${bamfile%.*}).g.vcf.gz
done 
