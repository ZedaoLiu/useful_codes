#!/bin/bash
#==================== parameters ================
number_of_threads=35

#==================== locate resources =============
agilent_v6_exome=../00.resources/004.agilent_v6_references/Exome_Agilent_V6.bed
reference_genome=../00.resources/001.hg38/hg38.fa
reference_genome_list=hg38.list
msisensor_pro=msisensor-pro-master/binary/msisensor-pro
#=================== make directories ==================

normal_bam=$1
tumor_bam=$2
tumor_bam_RG="$3-$4"

#=================== calculate MSI ===================


$msisensor_pro msi -b 20 -d $reference_genome_list -n $normal_bam  -t $tumor_bam -o "02.output/$tumor_bam_RG" -e $agilent_v6_exome 

cd 02.output
awk 'FNR==1{printf "%s\t%s\n",$0,"Patient"} FNR==2{printf "%s\t%s\n",$0,FILENAME}' $tumor_bam_RG >> MSI.txt
