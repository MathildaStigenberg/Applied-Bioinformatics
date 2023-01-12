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

# The chosen sample one wants to investigate the variants for 
sample <- args[4]

# output table, a .html file 
output_table <- args[5]

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

relevant_data <- all_data[ , c("POS", "gt_GT", "REF", "ALT", "Indiv", "frequency")] 

relevant_data <- merge(relevant_data, data_vcf_fix[, c("POS", "ALT", "ANN")], by.x = c("POS", "ALT"), by.y = c("POS", "ALT"))

relevant_data <- relevant_data[order(relevant_data$POS),]

relevant_data[c("base","effect")] <- str_split_fixed(relevant_data$ANN,"[|]",3)

relevant_data <- relevant_data[!duplicated(relevant_data[c("POS", "REF", "ALT", "Indiv")]),]

relevant_data <- subset(relevant_data, gt_GT == 1)

relevant_data <- cbind(ID = 1:nrow(relevant_data),relevant_data)

len <- length(relevant_data$ID)
for (i in 1:len){
  if (is.na(relevant_data$gt_GT[i])){
    next
  }
  if (relevant_data$Indiv[i] == sample){
    for (j in relevant_data$POS[i]){
      if (nchar(relevant_data$REF[relevant_data$ID == i]) > 1){
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
          if ((length(fasta)-j) > nchar(relevant_data$REF[relevant_data$ID == i])){
            left <- 8-(length(fasta)-j)
            seq_ending <- gsub(", ", "", toString(fasta[(j+nchar(relevant_data$REF[relevant_data$ID == i])):length(fasta)]))
            seq_beginning <- gsub(", ", "", toString(fasta[1:(left+(nchar(relevant_data$REF[relevant_data$ID == i])-2))]))
            seq_right <- sprintf("%s%s", seq_ending, seq_beginning)
          }
          else {
            left <- nchar(relevant_data$REF[relevant_data$ID == i])-(length(fasta)-j)
            seq_right <- gsub(", ", "", toString(fasta[left:(left+6)]))
          }
        }
        else {
          if ((length(fasta)-j) > nchar(relevant_data$REF[relevant_data$ID == i])){
            seq_right <- gsub(", ", "", toString(fasta[(j+nchar(relevant_data$REF[relevant_data$ID == i])):(j+nchar(relevant_data$REF[relevant_data$ID == i])+6)]))
          }
          else {
            left <- nchar(relevant_data$REF[relevant_data$ID == i])-(length(fasta)-j)
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
      Isotype <- append(Isotype, relevant_data$Indiv[i])
      Position <- append(Position, j)
      variant <- sprintf("%s->%s", relevant_data$REF[relevant_data$ID == i], relevant_data$ALT[relevant_data$ID == i])
      Mutation <- append(Mutation, variant)
      annotation_effect <- gsub("_", " ", relevant_data$effect[relevant_data$ID == i])
      annotation_effect <- gsub("&", " & ", annotation_effect)
      annotation_effect <- gsub("variant", "", annotation_effect)
      Effect <- append(Effect, annotation_effect)
      Frequency <- append(Frequency, relevant_data$frequency[relevant_data$ID == i])
      if (!is.null(genes[[j]])){
        Gene <- append(Gene, genes[[j]])
      }
      else {
        Gene <- append(Gene, " ")
      }
      if (nchar(relevant_data$REF[relevant_data$ID == i]) == 1 & nchar(relevant_data$ALT[relevant_data$ID == i]) == 1){
        if ((relevant_data$REF[relevant_data$ID == i] == "A" & relevant_data$ALT[relevant_data$ID == i] == "G") | (relevant_data$REF[relevant_data$ID == i] == "C" & relevant_data$ALT[relevant_data$ID == i] == "T") | (relevant_data$REF[relevant_data$ID == i] == "G" & relevant_data$ALT[relevant_data$ID == i] == "A") | (relevant_data$REF[relevant_data$ID == i] == "T" & relevant_data$ALT[relevant_data$ID == i] == "C")){
          Type <- append(Type, "transition")
        }
        else {
          Type <- append(Type, "transversion")
        }
      }
      else if (nchar(relevant_data$REF[relevant_data$ID == i]) > nchar(relevant_data$ALT[relevant_data$ID == i])) {
        Type <- append(Type, "deletion")
      }
      else if (nchar(relevant_data$REF[relevant_data$ID == i]) < nchar(relevant_data$ALT[relevant_data$ID == i])) {
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


