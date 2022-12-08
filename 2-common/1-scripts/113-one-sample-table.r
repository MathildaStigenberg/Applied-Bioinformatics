library("vcfR")
library("tidyverse")
library("seqinr")
library("stringr")
library("xtable")

args <- commandArgs(trailingOnly=TRUE)

# The r-script which generates a dictionary with all sites as keys and genes as values
gene_script <- args[1]

# The mtdna reference of c. elegans, a fa. file 
reference <- args[2]

# A .vcf file 
vcf_file <- args[3]

# The chosen sample one wants to investigate the variants for 
sample <- args[4]

# output table, a .html file 
output_table <- args[5]

source(gene_script)

ref <- read.fasta(reference)

fasta <- ref$MtDNA

vcf <- read.vcfR(vcf_file)

data_vcf <- vcfR2tidy(vcf)

data_vcf_gt <- data.frame(data_vcf$gt)
data_vcf_fix <- data.frame(data_vcf$fix)
data_vcf_meta <- data.frame(data_vcf$meta)

#extracting reads variant from the second column in AD
data <- as_tibble(data_vcf_gt)
ad_data <- data %>% pull(gt_AD)
reads_variant <- word(ad_data,2,sep=",")
#extracting DP from data_vcf_gt
dp_data <- data %>% pull(gt_DP)
#converting ad_data to integer from string
ad_data_int <- strtoi(reads_variant)
#making tabel of frequencies by dividing AD with DP
freq_variants <- ad_data_int / dp_data
freq_adjusted <- signif(freq_variants, 4)

Isotype <- c()
Position <- c()
Gene <- c()
Mutation <- c()
Frequency <- c()
Context <- c()

len <- length(data_vcf$gt$gt_GT)
for (i in 1:len){
  if (is.na(data_vcf$gt$gt_GT[i])){
    next
  }
  if (data_vcf$gt$gt_GT[i] == 1 & data_vcf$gt$Indiv[i] == sample){
    for (j in data_vcf$gt$POS[i]){
      if (!is.null(genes[[j]])){ 
        seq <- gsub(", ", "", toString(fasta[(j-4):(j+4)]))
        Isotype <- append(Isotype, data_vcf$gt$Indiv[i])
        Position <- append(Position, j)
        Gene <- append(Gene, genes[[j]])
        variant <- sprintf("%s->%s", data_vcf$fix$REF[data_vcf$fix$POS == j], data_vcf$fix$ALT[data_vcf$fix$POS == j])
        Mutation <- append(Mutation, variant)
        Frequency <- append(Frequency, freq_adjusted[i])
        Context <- append(Context, seq)
      }
    }
  }
}

info_table <- data.frame(Isotype, Position, Gene, Mutation, Frequency, Context)

html_table <- print(xtable(info_table, digits = 4), type = "HTML", include.rownames = FALSE, quote=FALSE)

file.create(output_table)
write.table(html_table, output_table, row.names = FALSE, col.names = FALSE, quote=FALSE)
