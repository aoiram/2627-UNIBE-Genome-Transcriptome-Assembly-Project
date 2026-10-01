#!/usr/bin/env bash

WORKDIR="/data/users/mamos/2627-UNIBE-Genome-Transcriptome-Assembly-Project/2627-UNIBE-Genome-Transcriptome-Assembly-Project"

cd $WORKDIR

sbatch ./src/3_1_busco/3_1_1_busco_flye.sbatch
sbatch ./src/3_1_busco/3_1_2_busco_hifiasm.sbatch
sbatch ./src/3_1_busco/3_1_3_busco_lja.sbatch
sbatch ./src/3_1_busco/3_1_4_busco_trinity.sbatch