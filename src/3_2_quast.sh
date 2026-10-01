#!/usr/bin/env bash
#SBATCH --time=2:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=eval_quast
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/quast_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/quast_%j.e

WORKDIR="/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project"
accession="Ms-0_clean"
asm_dir=${WORKDIR}/output/2_*
OUT_DIR="${WORKDIR}/output/03_evaluation/quast"

flye_file=`ls ${asm_dir}1_*/assembly.fasta`
hifiasm_file=`ls ${asm_dir}2_*/*.asm.bp.p_ctg.fa`
lja_file=`ls ${asm_dir}3_*/assembly.fasta`

REF_GENOME="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
REF_ANNOTATION="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.57.gff3"

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

CONTAINER="/containers/apptainer/quast_5.2.0.sif"

# Use the Array ID to decide which task this specific parallel job should run
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then

    echo "Running QUAST without reference (Array ID 0)..."
    apptainer exec --bind "${WORKDIR}" --bind /data/courses ${CONTAINER} \
        quast.py "${flye_file}" "${hifiasm_file}" "${lja_file}" \
                 -o "quast_no_ref" \
                 --labels "Flye,Hifiasm,LJA" \
                 --eukaryote \
                 --large \
                 --est-ref-size 135000000 \
                 --threads ${SLURM_CPUS_PER_TASK}

elif [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then

    echo "Running QUAST with reference (Array ID 1)..."
    apptainer exec --bind "${WORKDIR}" --bind /data/courses ${CONTAINER} \
        quast.py "${flye_file}" "${hifiasm_file}" "${lja_file}" \
                 -R ${REF_GENOME} \
                 --features ${REF_ANNOTATION} \
                 -o "quast_with_ref" \
                 --labels "Flye,Hifiasm,LJA" \
                 --eukaryote \
                 --large \
                 --threads ${SLURM_CPUS_PER_TASK}

fi