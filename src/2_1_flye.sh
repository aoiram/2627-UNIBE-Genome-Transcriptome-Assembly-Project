#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=flye_asm
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/2_1_flye_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/2_1_flye_%j.e
#SBATCH --partition=pibu_el8

# Assigned assession = Ms-0
accession='Ms-0_clean' # Please change according to your assession
raw_data='/data/courses/assembly-annotation-course/raw_data/'
genome=$assession
transcriptome='RNAseq_Sha_clean'

genome=./$genome                # PacBio HiFi
transcriptome=./$transcriptome  # Illumina RNA-seq for accession Sha

WORKDIR=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project
OUT_DIR=${WORKDIR}/output/2_1_flye

mkdir -p ${OUT_DIR}

apptainer exec --bind ${WORKDIR} \
/containers/apptainer/flye_2.9.5.sif \
flye --pacbio-hifi "${WORKDIR}/${accession}"/*.fastq.gz \
     --out-dir "${OUT_DIR}" \
     --threads ${SLURM_CPUS_PER_TASK}