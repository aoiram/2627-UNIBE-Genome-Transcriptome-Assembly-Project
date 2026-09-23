#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/01_output_fastqc_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/01_error_fastqc_%j.e
#SBATCH --partition=pibu_el8

# Assigned assession = Ms-0
assession='Ms-0' # Please change according to your assession
raw_data='/data/courses/assembly-annotation-course/raw_data/'
genome=$assession
transcriptome='RNAseq_Sha'

# use on first run to create symbolic link
# ln -s $raw_data$genome ./$genome
# ln -s $raw_data$transcriptome ./$transcriptome

genome=./$genome                # PacBio HiFi
transcriptome=./$transcriptome  # Illumina RNA-seq for accession Sha

WORKDIR=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project
output_dir=${WORKDIR}/output/01_reads_and_qc/
mkdir -r $output_dir

apptainer exec \
--bind $WORKDIR \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc -t ${SLURM_CPUS_PER_TASK} ${transcriptome}/ERR754081_1.fastq.gz ${transcriptome}/ERR754081_2.fastq.gz -o ${output_dir}/raw;

apptainer exec \
--bind $WORKDIR \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc -t ${SLURM_CPUS_PER_TASK} ${genome}/ERR11437313.fastq.gz -o ${output_dir}/raw;

# multiqc ${output_dir}/raw/ -o ${output_dir}/raw