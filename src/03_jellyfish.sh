#!/usr/bin/env bash

#SBATCH --cpus-per-task=6
#SBATCH --mem=60G
#SBATCH --time=04:00:00
#SBATCH --job-name=jellyfish
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_jellyfish_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_jellyfish_%j.e
#SBATCH --partition=pibu_el8

# Assigned assession = Ms-0
accession='Ms-0' # Please change according to your assession
raw_data='/data/courses/assembly-annotation-course/raw_data/'
genome=$accession
transcriptome='RNAseq_Sha'

genome=./$genome                # PacBio HiFi
transcriptome=./$transcriptome  # Illumina RNA-seq for accession Sha

WORKDIR=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project
OUT_DIR=${WORKDIR}/output/03_jellyfish

mkdir -p OUT_DIR

module load Jellyfish/2.3.0-GCC-10.3.0

jellyfish count -C -m 32 -s 5G -t ${SLURM_CPUS_PER_TASK} \
  -o ${OUT_DIR}/${accession}_reads_k31.jf \
  <(zcat ./${accession}/*.fastq.gz)

jellyfish histo -t ${SLURM_CPUS_PER_TASK} \
  ${OUT_DIR}/${accession}_reads_k31.jf > ${OUT_DIR}/${accession}_reads_k31.histo