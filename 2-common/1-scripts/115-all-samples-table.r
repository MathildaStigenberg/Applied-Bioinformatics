library("vcfR")
library("tidyverse")
library("seqinr")
library("stringr")
library("xtable")
library("dplyr")

args <- commandArgs(trailingOnly=TRUE)

# The r-script which generates a dictionary with all sites as keys and genes as values
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

data_vcf_everything <- vcfR2tidy(vcf, single_frame = TRUE)

data_vcf <- vcfR2tidy(vcf)

all_data <- data.frame(data_vcf_everything$dat)

data_vcf_gt <- data.frame(data_vcf$gt)
data_vcf_fix <- data.frame(data_vcf$fix)
data_vcf_meta <- data.frame(data_vcf$meta)

#extracting reads variant from the second column in AD
data <- as_tibble(all_data)
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

all_data$frequency <- freq_adjusted

line_break_function <- function(x){
  gsub("$<$br$>$","<br>",x)
}

options(xtable.sanitize.text.function = line_break_function)

data_group <- all_data %>% group_by(POS, gt_GT, REF, ALT) %>% dplyr::summarize(frequency = paste(sprintf("%.4f",frequency), collapse = "<br>"), samples = paste(Indiv, collapse = "<br>")) %>% as.data.frame()

data_group <- subset(data_group, gt_GT == 1)

data_group[c("base","effect")] <- str_split_fixed(data_vcf_fix$ANN,"[|]",3)

data_group <- data_group[!duplicated(data_group[c("POS", "REF", "ALT", "samples")]),]

data_group <- cbind(ID = 1:nrow(data_group),data_group)

len <- length(data_group$ID)
for (i in 1:len){
  for (j in data_group$POS[i]){
    if (nchar(data_group$REF[data_group$ID == i]) > 1){
      if (j < 9){
        left <- 8-j
        seq_beginning <- gsub(", ", "", toString(fasta[1:j]))
        seq_ending <- gsub(", ", "", toString(fasta[(length(fasta)-left):length(fasta)]))
        seq_left <- sprintf("%s%s", seq_ending, seq_beginning)
      }
      else {
        seq_left <- gsub(", ", "", toString(fasta[(j-8):j]))
      }
      if (j > (length(fasta)-8)){
        if ((length(fasta)-j) > nchar(data_group$REF[data_group$ID == i])){
          left <- 8-(length(fasta)-j)
          seq_ending <- gsub(", ", "", toString(fasta[(j+nchar(data_group$REF[data_group$ID == i])):length(fasta)]))
          seq_beginning <- gsub(", ", "", toString(fasta[1:(left+(nchar(data_group$REF[data_group$ID == i])-2))]))
          seq_right <- sprintf("%s%s", seq_ending, seq_beginning)
        }
        else {
          left <- nchar(data_group$REF[data_group$ID == i])-(length(fasta)-j)
          seq_right <- gsub(", ", "", toString(fasta[left:(left+6)]))
        }
      }
      else {
        if ((length(fasta)-j) > nchar(data_group$REF[data_group$ID == i])){
          seq_right <- gsub(", ", "", toString(fasta[(j+nchar(data_group$REF[data_group$ID == i])):(j+nchar(data_group$REF[data_group$ID == i])+6)]))
        }
        else {
          left <- nchar(data_group$REF[data_group$ID == i])-(length(fasta)-j)
          seq_right <- gsub(", ", "", toString(fasta[left:(left+6)]))
        }
      }
      sequence <- sprintf("%s[...]%s", toupper(seq_left), toupper(seq_right))
      Context <- append(Context, sequence)
    }
    else {
      if (j < 9){
        left <- 8-j
        seq_beginning <- gsub(", ", "", toString(fasta[1:j]))
        seq_ending <- gsub(", ", "", toString(fasta[(length(fasta)-left):length(fasta)]))
        seq_left <- sprintf("%s%s", seq_ending, seq_beginning)
      }
      else {
        seq_left <- gsub(", ", "", toString(fasta[(j-8):j]))
      }
      if (j > (length(fasta)-8)){
        left <- 8-(length(fasta)-j)
        seq_ending <- gsub(", ", "", toString(fasta[(j+1):length(fasta)]))
        seq_beginning <- gsub(", ", "", toString(fasta[1:left]))
        seq_right <- sprintf("%s%s", seq_ending, seq_beginning)
      }
      else {
        seq_right <- gsub(", ", "", toString(fasta[(j+1):(j+8)]))
      }
      sequence <- sprintf("%s%s", toupper(seq_left), toupper(seq_right))
      Context <- append(Context, sequence)
    }
    Isotype <- append(Isotype, data_group$samples[data_group$ID == i])
    Position <- append(Position, j)
    variant <- sprintf("%s->%s", data_group$REF[data_group$ID == i], data_group$ALT[data_group$ID == i])
    Mutation <- append(Mutation, variant)
    annotation_effect <- gsub("_", " ", data_group$effect[data_group$ID == i])
    annotation_effect <- gsub("&", " & ", annotation_effect)
    annotation_effect <- gsub("variant", "", annotation_effect)
    Effect <- append(Effect, annotation_effect)
    Frequency <- append(Frequency, data_group$frequency[data_group$ID == i])
    if (!is.null(genes[[j]])){
      Gene <- append(Gene, genes[[j]])
    }
    else {
      Gene <- append(Gene, " ")
    }
    if (nchar(data_group$REF[data_group$ID == i]) == 1 & nchar(data_group$ALT[data_group$ID == i]) == 1){
      if ((data_group$REF[data_group$ID == i] == "A" & data_group$ALT[data_group$ID == i] == "G") | (data_group$REF[data_group$ID == i] == "C" & data_group$ALT[data_group$ID == i] == "T") | (data_group$REF[data_group$ID == i] == "G" & data_group$ALT[data_group$ID == i] == "A") | (data_group$REF[data_group$ID == i] == "T" & data_group$ALT[data_group$ID == i] == "C")){
        Type <- append(Type, "transition")
      }
      else {
        Type <- append(Type, "transversion")
      }
    }
    else if (nchar(data_group$REF[data_group$ID == i]) > nchar(data_group$ALT[data_group$ID == i])) {
      Type <- append(Type, "deletion")
    }
    else if (nchar(data_group$REF[data_group$ID == i]) < nchar(data_group$ALT[data_group$ID == i])) {
      Type <- append(Type, "insertion")
    }
    else {
      Type <- append(Type, " ")
    }
  }
}

info_table <- data.frame(Isotype, Position, Gene, Mutation, Effect, Type, Frequency, Context)

html_table <- print(xtable(info_table, digits = 4), type = "HTML", include.rownames = FALSE, quote=FALSE)

file.create(output_table)
write.table(html_table, output_table, row.names = FALSE, col.names = FALSE, quote=FALSE)

