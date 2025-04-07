#tree raw_fastqs/
#raw_fastqs/
#├── sc5p_v2_hs_PBMC_1k_5gex_fastqs
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L001_I1_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L001_I2_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L001_R1_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L001_R2_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L002_I1_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L002_I2_001.fastq.gz
#│   ├── sc5p_v2_hs_PBMC_1k_5gex_S1_L002_R1_001.fastq.gz
#│   └── sc5p_v2_hs_PBMC_1k_5gex_S1_L002_R2_001.fastq.gz
#└── sc5p_v2_hs_PBMC_2k_5gex_fastqs
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L001_I1_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L001_I2_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L001_R1_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L001_R2_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L002_I1_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L002_I2_001.fastq.gz
#    ├── sc5p_v2_hs_PBMC_2k_5gex_S1_L002_R1_001.fastq.gz
#    └── sc5p_v2_hs_PBMC_2k_5gex_S1_L002_R2_001.fastq.gz

# automatically detects sample data in raw_fastqs (see above) and generate GEX outputs
# how to run:
# bash batch_process_10x_GEX.sh

#/bin/bash  

# Set directories for the input FASTQs and output expression matrices  
FASTQ_DIRS=(raw_fastqs/*_fastqs)  # Input directories containing FASTQ files  
OUTPUT_DIR="expression_matrices"   # Output directory for cellranger count results  
REFERENCE="/lustre2/zeminz_pkuhpc/liuzd/scRNA/test_data/refs/refdata-gex-GRCh38-2024-A" # Path to your cellranger reference directory  


# Loop through each FASTQ directory  
for FASTQ_DIR in "${FASTQ_DIRS[@]}"; do  
    # Extract sample name from directory name (e.g., sc5p_v2_hs_PBMC_1k_5gex)  
    SAMPLE_NAME=$(basename "$FASTQ_DIR" | sed 's/_fastqs$//')  

    # Create output directory for this sample  
    SAMPLE_OUTPUT_DIR="$OUTPUT_DIR/$SAMPLE_NAME"  
    mkdir -p "$SAMPLE_OUTPUT_DIR"  

    # Run cellranger count on the detected FASTQ files using sbatch  
    echo "Submitting cellranger count for sample: $SAMPLE_NAME"  

    sbatch <<EOF
#!/bin/bash  
#SBATCH --job-name=cellranger_$SAMPLE_NAME     # Job name  
#SBATCH --output=$SAMPLE_OUTPUT_DIR/log.txt     # Output file  
#SBATCH --error=$SAMPLE_OUTPUT_DIR/error.txt    # Error file  
#SBATCH -A zeminz_g1
#SBATCH --qos=zeminzcns
#SBATCH -p cn-short
#SBATCH -J Liuzd_cellranger_test
#SBATCH --nodes=1                              # Number of nodes  
#SBATCH --cpus-per-task=20                      # Number of CPU cores per task  

/lustre2/zeminz_pkuhpc/liuzd/scRNA/cellranger-9.0.1/bin/cellranger count \
    --id="$SAMPLE_NAME" \
    --transcriptome="$REFERENCE" \
    --fastqs="$FASTQ_DIR" \
    --sample="$SAMPLE_NAME" \
    --localcores=4 \
    --localmem=16 \
    --create-bam false
    --output-dir="$SAMPLE_OUTPUT_DIR"   
EOF

    # Optional: Wait for the job to complete and check for success  
    # job_id=$!  
    # wait $job_id  

done
