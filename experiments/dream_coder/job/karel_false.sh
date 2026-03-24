#!/bin/bash
#SBATCH --account=research-eemcs-st
#SBATCH --partition=memory
#SBATCH --job-name=karel-compression=false
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000MB
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=job_out/job_%j.out
#SBATCH --error=job_out/job_%j.err

module load julia

set -euo pipefail
srun run_script.sh "karel" "false"
