#!/usr/bin/env bash
#SBATCH --time=2:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=eval_merqury
#SBATCH --partition=pshort_el8
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --array=0-3   # 4 jobs
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/merqury_%A_%a.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/merqury_%A_%a.e

WORKDIR="/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project"
accession="Ms-0_clean"
asm_dir=${WORKDIR}/output/2_*
OUT_DIR="${WORKDIR}/output/03_evaluation/merqury"

flye_file=`ls ${asm_dir}1_*/assembly.fasta`
hifiasm_file=`ls ${asm_dir}2_*/*.asm.bp.p_ctg.fa`
lja_file=`ls ${asm_dir}3_*/assembly.fasta`

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

export MERQURY="/usr/local/share/merqury"
CONTAINER="/containers/apptainer/merqury_1.3.sif"

# Build Meryl Database
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
    echo "Array ID 0: Building Meryl DB from reads..."

    # Remove old done file just in case you are re-running this script
    rm -f meryl_build.done

    apptainer exec --bind "${WORKDIR}" ${CONTAINER} \
        meryl k=21 count threads=${SLURM_CPUS_PER_TASK} memory=30 \
        output ${accession}_reads.meryl "${WORKDIR}/${accession}"/*.fastq.gz

    # Signal to the other parallel jobs that the DB is ready
    touch meryl_build.done
    echo "Meryl DB build complete!"

# Evaluations
else
    echo "Array ID ${SLURM_ARRAY_TASK_ID}: Waiting for Meryl DB to be generated..."

    # Pause these tasks until DB Creation creates the .done file
    while [ ! -f "meryl_build.done" ]; do
        sleep 30
    done

    echo "Meryl DB is ready. Proceeding with evaluation."

    if [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
        echo "Evaluating Flye..."
        mkdir -p flye_eval && cd flye_eval
        apptainer exec --bind "${WORKDIR}" --env MERQURY="/usr/local/share/merqury" ${CONTAINER} \
            sh -c "\$MERQURY/merqury.sh ../${accession}_reads.meryl ${flye_file} flye_${accession}"

    elif [ "$SLURM_ARRAY_TASK_ID" -eq 2 ]; then
        echo "Evaluating Hifiasm..."
        mkdir -p hifiasm_eval && cd hifiasm_eval
        apptainer exec --bind "${WORKDIR}" --env MERQURY="/usr/local/share/merqury" ${CONTAINER} \
            sh -c "\$MERQURY/merqury.sh ../${accession}_reads.meryl ${hifiasm_file} hifiasm_${accession}"

    elif [ "$SLURM_ARRAY_TASK_ID" -eq 3 ]; then
        echo "Evaluating LJA..."
        mkdir -p lja_eval && cd lja_eval
        apptainer exec --bind "${WORKDIR}" --env MERQURY="/usr/local/share/merqury" ${CONTAINER} \
            sh -c "\$MERQURY/merqury.sh ../${accession}_reads.meryl ${lja_file} lja_${accession}"
    fi
fi