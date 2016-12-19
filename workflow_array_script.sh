#! /bin/bash
#SBATCH --nodes=1 #request one node
#SBATCH -p medium
#SBATCH --error=msg/array%a.err
#SBATCH --output=msg/array%a.out
module load R

R --no-save < workflow_array_job.R #run an R script using R
