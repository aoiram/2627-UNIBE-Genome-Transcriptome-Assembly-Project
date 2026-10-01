#!/usr/bin/env bash
#SBATCH --time=2:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=mummer
#SBATCH --partition=pshort_el8
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --array=0-5
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/mummer_%A_%a.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/03_evaluation/mummer_%A_%a.e

WORKDIR="/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project"
accession="Ms-0_clean"
asm_dir=${WORKDIR}/output/2_*
OUT_DIR="${WORKDIR}/output/03_evaluation/mummer"

flye_file=`ls ${asm_dir}1_*/assembly.fasta`
hifiasm_file=`ls ${asm_dir}2_*/*.asm.bp.p_ctg.fa`
lja_file=`ls ${asm_dir}3_*/assembly.fasta`

REF_GENOME="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
REF_ANNOTATION="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.57.gff3"

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
    TARGET=${REF_GENOME}
    QUERY=${flye_file}
    PREFIX="ref_vs_flye"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
    TARGET=${REF_GENOME}
    QUERY=${hifiasm_file}
    PREFIX="ref_vs_hifiasm"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 2 ]; then
    TARGET=${REF_GENOME}
    QUERY=${lja_file}
    PREFIX="ref_vs_lja"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 3 ]; then
    TARGET=${flye_file}
    QUERY=${hifiasm_file}
    PREFIX="flye_vs_hifiasm"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 4 ]; then
    TARGET=${flye_file}
    QUERY=${lja_file}
    PREFIX="flye_vs_lja"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 5 ]; then
    TARGET=${hifiasm_file}
    QUERY=${lja_file}
    PREFIX="hifiasm_vs_lja"
fi

echo "Task ID ${SLURM_ARRAY_TASK_ID}: Aligning ${QUERY} to${TARGET}..."

apptainer exec --bind "${WORKDIR}" --bind /data/courses ${CONTAINER} \
    nucmer -t ${SLURM_CPUS_PER_TASK} \
           --prefix="${PREFIX}" \
           --breaklen=1000 \
           --mincluster=1000 \
           "${TARGET}" "${QUERY}"

apptainer exec --bind "${WORKDIR}" --bind /data/courses ${CONTAINER} \
    mummerplot -R "${TARGET}" -Q "${QUERY}" \
               --filter -t png --large --layout --fat \
               -p "plot_${PREFIX}" "${PREFIX}.delta"

echo "Task ID ${SLURM_ARRAY_TASK_ID}: Finished generating plot_${PREFIX}.png"