#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=hifiasm
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/2_2_hifiasm_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/2_2_hifiasm_%j.e
#SBATCH --partition=pibu_el8

# Assigned assession = Ms-0
accession='Ms-0_clean' # Please change according to your assession
raw_data='/data/courses/assembly-annotation-course/raw_data/'
genome=$assession
transcriptome='RNAseq_Sha_clean'

genome=./$genome                # PacBio HiFi
transcriptome=./$transcriptome  # Illumina RNA-seq for accession Sha

WORKDIR=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project
OUT_DIR=${WORKDIR}/output/2_2_hifiasm

mkdir -p "${OUT_DIR}"

apptainer exec --bind "${WORKDIR}" \
  /containers/apptainer/hifiasm_0.25.0.sif \
  hifiasm -o "${OUT_DIR}/${accession}.asm" -t ${SLURM_CPUS_PER_TASK} "${WORKDIR}/${accession}"/*.fastq.gz

awk '/^S/{print ">"$2;print $3}' "${OUT_DIR}/${accession}.asm.bp.p_ctg.gfa" > "${OUT_DIR}/${accession}.asm.bp.p_ctg.fa"