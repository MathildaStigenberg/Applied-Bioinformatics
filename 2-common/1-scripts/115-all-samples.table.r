library("vcfR")
library("tidyverse")
library("seqinr")
library("stringr")
library("xtable")
library("dplyr")

args <- commandArgs(trailingOnly=TRUE)

# The r-script (112-genes.r) which generates a dictionary with all sites as keys and genes as values
gene_script <- args[1]

# The mtdna reference of c. elegans, a fa. file 
reference <- args[2]

# An annotated .vcf file 
vcf_file <- args[3]

# output table, a .html file 
output_table <- args[4]

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
Effect <- c()
Frequency <- c()
Context <- c()
Type <- c()

data_vcf_gt$frequency <- freq_adjusted

line_break_function <- function(x){
  gsub("$<$br$>$","<br>",x)
}

options(xtable.sanitize.text.function = line_break_function)

data_group <- data_vcf_gt %>% group_by(POS, gt_GT) %>% dplyr::summarize(frequency = paste(sprintf("%.4f",frequency), collapse = "<br>"), samples = paste(Indiv, collapse = "<br>")) %>% as.data.frame()

data_group <- subset(data_group, gt_GT == 1)

data_vcf_fix[c("base","effect")] <- str_split_fixed(data_vcf_fix$ANN,"[|]",3)


len <- length(data_group$POS)
for (i in 1:len){
  if (data_group$gt_GT[i] == 1){
    for (j in data_group$POS[i]){
      if (nchar(data_vcf$fix$REF[data_vcf$fix$POS == j]) > 1){
        seq_left <- gsub(", ", "", toString(fasta[(j-8):j]))
        seq_right <- gsub(", ", "", toString(fasta[(j+nchar(data_vcf$fix$REF[data_vcf$fix$POS == j])):(j+nchar(data_vcf$fix$REF[data_vcf$fix$POS == j])+6)]))
        sequence <- sprintf("%s[...]%s", toupper(seq_left), toupper(seq_right))
        Context <- append(Context, sequence)
      }
      else {
        seq <- gsub(", ", "", toString(fasta[(j-8):(j+8)]))
        Context <- append(Context, toupper(seq))
      }
      Isotype <- append(Isotype, data_group$samples[data_group$POS == j])
      Position <- append(Position, j)
      variant <- sprintf("%s->%s", data_vcf$fix$REF[data_vcf$fix$POS == j], data_vcf$fix$ALT[data_vcf$fix$POS == j])
      Mutation <- append(Mutation, variant)
      annotation_effect <- gsub("_", " ", data_vcf_fix$effect[data_vcf_fix$POS == j])
      annotation_effect <- gsub("&", " & ", annotation_effect)
      annotation_effect <- gsub("variant", "", annotation_effect)
      Effect <- append(Effect, annotation_effect)
      Frequency <- append(Frequency, data_group$frequency[data_group$POS == j])
      if (!is.null(genes[[j]])){
        Gene <- append(Gene, genes[[j]])
      }
      else {
        Gene <- append(Gene, " ")
      }
      if (nchar(data_vcf$fix$REF[data_vcf$fix$POS == j]) == 1 & nchar(data_vcf$fix$ALT[data_vcf$fix$POS == j]) == 1){
        if ((data_vcf$fix$REF[data_vcf$fix$POS == j] == "A" & data_vcf$fix$ALT[data_vcf$fix$POS == j] == "G") | (data_vcf$fix$REF[data_vcf$fix$POS == j] == "C" & data_vcf$fix$ALT[data_vcf$fix$POS == j] == "T") | (data_vcf$fix$REF[data_vcf$fix$POS == j] == "G" & data_vcf$fix$ALT[data_vcf$fix$POS == j] == "A") | (data_vcf$fix$REF[data_vcf$fix$POS == j] == "T" & data_vcf$fix$ALT[data_vcf$fix$POS == j] == "C")){
          Type <- append(Type, "transition")
        }
        else {
          Type <- append(Type, "transversion")
        }
      }
      else if (nchar(data_vcf$fix$REF[data_vcf$fix$POS == j]) > nchar(data_vcf$fix$ALT[data_vcf$fix$POS == j])) {
        Type <- append(Type, "deletion")
      }
      else if (nchar(data_vcf$fix$REF[data_vcf$fix$POS == j]) < nchar(data_vcf$fix$ALT[data_vcf$fix$POS == j])) {
        Type <- append(Type, "insertion")
      }
      else {
        Type <- append(Type, " ")
      }
    }
  }
}

info_table <- data.frame(Isotype, Position, Gene, Mutation, Effect, Type, Frequency, Context)

html_table <- print(xtable(info_table, digits = 4), type = "HTML", include.rownames = FALSE, quote=FALSE)

file.create(output_table)
write.table(html_table, output_table, row.names = FALSE, col.names = FALSE, quote=FALSE)
