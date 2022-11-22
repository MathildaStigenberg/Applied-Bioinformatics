#!/bin/bash -l

input="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/107-genotypeGVCFs-subset/jointly-genotyped-vcf-subset.vcf"

ref="/proj/snic2022-6-224/private/Applied-Bioinformatics/1-data/006-reference/ref-mt.fa"

output="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/109-soft-filtering-subset/soft-filtering-subset.vcf.gz"

bcf_output="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/109-soft-filtering-subset/soft-filtering-subset.soft-filter.vcf.gz" 

stats_output="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/109-soft-filtering-subset/soft-filtering-subset.soft-filter_stats.txt"

filtered_stats="/proj/snic2022-6-224/private/Applied-Bioinformatics/2-common/3-results/109-soft-filtering-subset/soft-filtering-subset.soft-filter.filter_stats.txt"

# Apply filters
gatk --java-options "-Xmx4g" \
            VariantFiltration \
            -R $ref \
            --variant $input \
            --genotype-filter-expression "DP < 100.0"    --genotype-filter-name "DP_min_depth" \
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
