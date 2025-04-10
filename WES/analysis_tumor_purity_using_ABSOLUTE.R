# This script is used to estimate tumor purity and ploidy using the ABSOLUTE algorithm
# Author: Dingcheng Yi
# Time : 2022/5/9

library(tidyverse)
library(readxl)
library(ABSOLUTE)
# Generate the ABSOLUTE input file
# Input: Clinical data
# Output: ABSOLUTE input file, in a data.frame with 2 columns: Tumor_Sample_Barcode and pathology
generateClinicalFiles <- function() {
  setwd("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/")
  Clinical_Data <- read_xlsx("./Clinical/收样信息-20220428.xlsx") 
  Clinical_Data <- Clinical_Data%>%mutate(Tumor_Sample_Barcode=样本编号 %>% str_extract("P\\d+\\.[SB]\\.(T|N|LN)(\\.[#]?\\d|\\.Edge|\\.Core)?") %>% str_replace_all(c("\\."="-","#"="","Edge" = "edge", "Core" = "core", "-[BS]"="")), response=ifelse(病理缓解率==1.0,"pCR",ifelse(病理缓解率>0.8,"MPR",ifelse(病理缓解率>=0.5,">=50%","<50%"))), pathology = 病理类型 %>% str_extract(("LU(AD|SC)"))) %>% select(Tumor_Sample_Barcode, pathology) %>% filter(str_detect(Tumor_Sample_Barcode, "-N")==F) %>% distinct()
  return(Clinical_Data)
}

# Pre-process the ABSOLUTE input seg file
# Input: ABSOLUTE input seg file
# Output: seg file ready for DoAbsolute
ColChange <- function(clinical) {
  sample.name <- clinical
  seg.dat.fn <- paste("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/", sample.name, ".seg", sep = "")
  if(!file.exists(seg.dat.fn)) {
    print(paste("File not found: ", seg.dat.fn))
    return(NULL)
  }
  print(seg.dat.fn)
  seg.dat <- read_delim(seg.dat.fn, delim = "\t")
  colnames(seg.dat) <- c("ID", "Chromosome", "Start", "End", "Num_Probes","Segment_Mean")
  seg.dat  <- seg.dat %>% filter(str_detect(Chromosome, "v")==F)
  write_delim(seg.dat, seg.dat.fn, delim ="\t")
}

Echo <- function(clin, pathology) {
  print(clin)
  print(pathology)
}


# do the ABSOLUTE analysis
# Input: vector with 2 columns: Tumor_Sample_Barcode and pathology
DoAbsolute <- function(Tumor_Sample_Barcode, pathology) {
  library(ABSOLUTE)
  plate.name <- "NSCLC_purity_and_ploidy"
  genome <- "hg38"
  platform <- "Illumina_WES"
  primary.disease <- pathology
  sample.name <- Tumor_Sample_Barcode
  sigma.p <- 0.01
  max.sigma.h <- 0.02
  min.ploidy <- 0.95
  max.ploidy <- 10
  max.as.seg.count <- 1500
  max.non.clonal <- 0
  max.neg.genome <- 0
  copy_num_type <- "total"
  setwd("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/")
  seg.dat.fn <- paste("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/", sample.name, ".seg", sep = "")
  if(!file.exists(seg.dat.fn)) {
    print(paste("File not found: ", seg.dat.fn))
    return(NULL)
  }
  absolute_file <- paste("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/output/absolute/", Tumor_Sample_Barcode, ".ABSOLUTE.Rdata", sep = "")
 # if(file.exists(absolute_file)) {
  #  print(paste("File already exists: ", absolute_file))
   # return(NULL)
  #}
  results.dir <- paste(".", "output", "absolute", sep = "/")
  log.dir <- paste(".", "output", "abs_logs", sep = "/")
  if (!file.exists(log.dir)) {
    print(paste("Creating directory: ", log.dir))
    dir.create(log.dir, recursive=TRUE)
  }
  if (!file.exists(results.dir)) {
    dir.create(results.dir, recursive=TRUE)
  }
  print(paste("Running ABSOLUTE on ", sample.name))

  RunAbsolute(seg.dat.fn, sigma.p, max.sigma.h, min.ploidy, max.ploidy, primary.disease, platform, sample.name, results.dir, max.as.seg.count, max.non.clonal, max.neg.genome, copy_num_type,verbose=TRUE)
}


Clinical_Data <- generateClinicalFiles()
walk(Clinical_Data$Tumor_Sample_Barcode, ColChange)
walk2(Clinical_Data$Tumor_Sample_Barcode, Clinical_Data$pathology, DoAbsolute)
Clinical_Data <- Clinical_Data[-29, ]
absolute_files <- paste("C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/output/absolute/", Clinical_Data$Tumor_Sample_Barcode, ".ABSOLUTE.Rdata", sep = "")

CreateReviewObject("NSCLC", absolute_files, verbose = T, copy_num_type = "total", indv.results.dir = "C:/Users/ydc2020/OneDrive/桌面/Zhang Lab/CNV_results/CNV_CNVkit/output/absolute/")
