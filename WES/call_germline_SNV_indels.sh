#!/bin/bash
sample=$3$4
sampleN=$1
sampleT=$2
exome="/lustre2/zeminz_pkuhpc/zhangwenjie/neoadjuvant/WES/00.resources/004.agilent_v6_references/Exome_Agilent_V6.bed.gz"
refData="/lustre2/zeminz_pkuhpc/zhangwenjie/neoadjuvant/WES/00.resources/001.hg38/hg38.fa"
outDir="output_snps_indels"
annovar="/lustre2/zeminz_pkuhpc/zhangwenjie/neoadjuvant/WES/00.resources/007.ANNOVAR/table_annovar.pl"
convert_to_avinput="/lustre2/zeminz_pkuhpc/zhangwenjie/neoadjuvant/WES/00.resources/007.ANNOVAR/convert2annovar.pl"

annovar_path=../00.resources/007.ANNOVAR/
mkdir $outDir
mkdir $outDir/$sample
# call germline mut by strelka
STRELKA_INSTALL_PATH="/lustre2/zeminz_pkuhpc/zhangwenjie/neoadjuvant/WES/somatic_strelka/strelka-2.9.10.centos6_x86_64/bin"

${STRELKA_INSTALL_PATH}/configureStrelkaGermlineWorkflow.py \
        --bam $sampleN
        --referenceFasta $refData \
        --runDir $outDir/$sample/strelka \
        --exome \
        --callRegions $exome

$outDir/$sample/strelka/runWorkflow.py -m local -j 20

VARSCAN_OUT=./output_snps_indels/VarScan2

samtools mpileup -B -f $refData $sampleN | java -jar VarScan.v2.4.2.jar mpileup2cns --output-vcf --min-avg-qual 25 --min-var-freq 0.2 --p-value 0.01 --variants 

python ~/anaconda3/envs/pyclone/share/platypus-variant-0.8.1.2-4/Platypus.py
