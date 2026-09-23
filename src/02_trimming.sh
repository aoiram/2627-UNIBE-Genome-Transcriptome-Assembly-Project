#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastp+fastqc
#SBATCH --mail-user=mario.amos@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/02_trimming_%j.o
#SBATCH --error=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project/output/02_trimming_%j.e
#SBATCH --partition=pibu_el8

# Assigned assession = Ms-0
assession='Ms-0' # Please change according to your assession
raw_data='/data/courses/assembly-annotation-course/raw_data/'
genome=$assession
transcriptome='RNAseq_Sha'

genome=./$genome                # PacBio HiFi
transcriptome=./$transcriptome  # Illumina RNA-seq for accession Sha

WORKDIR=/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project
container=/containers/apptainer/fastp_0.24.1.sif

mkdir -p $WORKDIR/output/02_trimming/

# TRIMMING ILLUMINA

#apptainer exec \
#--bind $WORKDIR \
#$container \
#fastp \
#-i $transcriptome/ERR754081_1.fastq.gz \
#-I $transcriptome/ERR754081_2.fastq.gz \
#-o $WORKDIR/output/02_trimming/ERR754081_1_filtered.fastq.gz \
#-O $WORKDIR/output/02_trimming/ERR754081_2_filtered.fastq.gz \
#-h $WORKDIR/output/02_trimming/illumina_report.html \
#-j $WORKDIR/output/02_trimming/illumina_report.json \
#--thread ${SLURM_CPUS_PER_TASK}

# TRIMMING PACBIO

apptainer exec \
--bind $WORKDIR \
$container \
fastp \
-i ${genome}/ERR11437313.fastq.gz \
-o $WORKDIR/output/02_trimming/ERR11437313_fastp.fastq.gz \
-h $WORKDIR/output/02_trimming/pacbio_report.html \
-j $WORKDIR/output/02_trimming/pacbio_report.json \
--disable_quality_filtering \
--disable_length_filtering \
--disable_adapter_trimming \
--thread ${SLURM_CPUS_PER_TASK}

# FASTQC ON ALL OF IT

#apptainer exec \
#--bind $WORKDIR \
#/containers/apptainer/fastqc-0.12.1.sif \
#fastqc -t ${SLURM_CPUS_PER_TASK} $WORKDIR/output/02_trimming/ERR754081_1_filtered.fastq.gz $WORKDIR/output/02_trimming/ERR754081_2_filtered.fastq.gz -o $WORKDIR/output/02_trimming/;

apptainer exec \
--bind $WORKDIR \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc -t ${SLURM_CPUS_PER_TASK} $WORKDIR/output/02_trimming/ERR11437313_fastp.fastq.gz -o $WORKDIR/output/02_trimming/;

apptainer exec \
--bind $WORKDIR \
/containers/apptainer/multiqc-1.33.sif \
multiqc $WORKDIR/output/02_trimming/* -o $WORKDIR/output/02_trimming/