#!/usr/bin/env bash
#SBATCH --time=2:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=eval_busco
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/busco_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/busco_%j.e

WORKDIR="/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project"
accession="Ms-0_clean"
asm_dir=${WORKDIR}/output/2_*
OUT_DIR="${WORKDIR}/output/03_evaluation/busco"

flye_file=`ls ${asm_dir}1_*/assembly.fasta`
hifiasm_file=`ls ${asm_dir}2_*/*.asm.bp.p_ctg.fa`
lja_file=`ls ${asm_dir}3_*/assembly.fasta`
trinity_file=`ls ${asm_dir}4_*/Trinity.fasta`

mkdir -p "${OUT_DIR}"

cd "${OUT_DIR}"

CONTAINER="/containers/apptainer/busco_5.7.1.sif"

apptainer exec --bind "${WORKDIR}" ${CONTAINER} \
    busco -i "${trinity_file}" \
          -o "busco_trinity_${accession}" \
          -m transcriptome \
          --auto-lineage \
          -c ${SLURM_CPUS_PER_TASK}