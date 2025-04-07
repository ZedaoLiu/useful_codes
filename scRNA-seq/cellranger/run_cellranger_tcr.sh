# how to use
# bash run_cellranger-tcr.sh


#!/bin/bash  

# Set directories for the input FASTQs and output expression matrices  
FASTQ_DIRS=(raw_TCR_fastqs/*_fastqs)  # Input directories containing FASTQ files  
OUTPUT_DIR="TCR_results"   # Output directory for cellranger count results  
REFERENCE="/lustre2/zeminz_pkuhpc/liuzd/scRNA/test_data/refs/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0" # Path to your cellranger reference directory  

echo "Found FASTQ directories: ${FASTQ_DIRS[@]}"  

# Loop through each FASTQ directory  
for FASTQ_DIR in "${FASTQ_DIRS[@]}"; do  
    # Extract sample name from directory name (e.g., sc5p_v2_hs_PBMC_1k_5gex)  
    SAMPLE_NAME=$(basename "$FASTQ_DIR" | sed 's/_fastqs$//')  

    # Create output directory for this sample  
    #? create outout dir may introduce error since the cellranger itself wants to create it.
    SAMPLE_OUTPUT_DIR="$OUTPUT_DIR/${SAMPLE_NAME}_out"  
    mkdir -p "$SAMPLE_OUTPUT_DIR"  
    echo "Output directory created: $SAMPLE_OUTPUT_DIR"
    
    # Run cellranger count on the detected FASTQ files using sbatch  
    echo "Submitting cellranger count for sample: $SAMPLE_NAME"  

    sbatch << EOF
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

/lustre2/zeminz_pkuhpc/liuzd/scRNA/cellranger-9.0.1/bin/cellranger vdj \
    --id="${SAMPLE_NAME}_out" \
    --reference="$REFERENCE" \
    --fastqs="$FASTQ_DIR" \
    --sample="$SAMPLE_NAME" \
    --localcores=4 \
    --localmem=16 \

EOF

    # Optional: Wait for the job to complete and check for success  
    # job_id=$!  
    # wait $job_id  

done
