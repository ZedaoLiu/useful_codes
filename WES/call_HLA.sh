#!/bin/bash
source /lustre2/zeminz_pkuhpc/zhangwenjie/bashrc_zwj
R1_fastq=$1
R2_fastq=$2
outname=$3
HLA_ref=../00.resources/hla_reference_dna.fasta
conda activate HLA

razers3 -i 95 -m 1 -dr 0 -o $outname.1.bam $HLA_ref $1

samtools bam2fq $outname.1.bam > 02.HLA_reads/$outname.1.fastq

rm $outname.1.bam

razers3 -i 95 -m 1 -dr 0 -o $outname.2.bam $HLA_ref $2

samtools bam2fq $outname.2.bam > 02.HLA_reads/$outname.2.fastq

rm $outname.2.bam

python /lustre2/zeminz_pkuhpc/zhangwenjie/miniconda3/envs/HLA/bin/OptiTypePipeline.py --dna -v -c ./config.ini  -i 02.HLA_reads/$outname.1.fastq 02.HLA_reads/$outname.2.fastq --outdir 03.output
