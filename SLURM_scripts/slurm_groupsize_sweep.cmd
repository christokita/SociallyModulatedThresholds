#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH -t 47:59:00
#SBATCH --mem-per-cpu=6G
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=christohper.tokita@gmail.com

Rscript scripts/2_Cluster_GroupSizeSweep.R