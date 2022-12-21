#!/bin/bash -l
#SBATCH -A snic2022-5-408
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 30:00
#SBATCH -J 109-soft-filtering
#SBATCH -o 109-soft-filtering.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user hanna.hyllander.8450@student.uu.se

# Load modules
module load bioinfo-tools
module load GATK/4.1.4.1
module load bcftools/1.14 

# Path to the input file, the jointly-genotyped .vcf file obtained from the genotypeGVCFs script 
input=${1}

# Path to the reference .fa 
ref=${2}

# Path to the output file that will be created from soft-filtering, a .vcf.gz file 
output=${3}

# Path to the output file that will be created when filter high missing and high heterozygosity, a .soft-filter.vcf.gz file
bcf_output=${4} 

# Path to a statistics file, a soft-filter_stats.txt file
stats_output=${5}

# Path to a summarized statistics, a filtered one, a soft-filter.filter_stats.txt file
filtered_stats=${6}

# Apply filters
gatk --java-options "-Xmx4g" \
            VariantFiltration \
            -R $ref \
            --variant $input \
            --genotype-filter-expression "DP < 5.0"    --genotype-filter-name "DP_min_depth" \
            --filter-expression "QUAL < 30.0"                --filter-name "QUAL_quality" \
            --filter-expression "FS > 100.0"          --filter-name "FS_fisherstrand" \
            --filter-expression "QD < 20.0"     --filter-name "QD_quality_by_depth" \
            --filter-expression "SOR > 5.0"    --filter-name "SOR_strand_odds_ratio" \
            --genotype-filter-expression "isHet == 1.0"                  --genotype-filter-name "is_het" \
            -O $output

# Create indexfile
bcftools index --tbi $output

# Apply high missing and high heterozygosity filters
bcftools filter --threads 4 --soft-filter='high_missing' --mode + --include 'F_MISSING  <= 0.95' $output |\
bcftools filter --threads 4 --soft-filter='high_heterozygosity' --mode + --include 'COUNT(GT="het")/N_SAMPLES <= 0.10' -O z > $bcf_output
       
bcftools index $bcf_output
bcftools index --tbi $bcf_output
bcftools stats --threads 4 \
                       -s- --verbose $bcf_output > $stats_output

{
            echo -e 'QUAL\\tQD\\tSOR\\tFS\\tFILTER';
            bcftools query -f '%QUAL\t%INFO/QD\t%INFO/SOR\t%INFO/FS\t%FILTER\n' ${bcf_output};
        }     > $filtered_stats
