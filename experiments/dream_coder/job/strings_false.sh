#!/bin/bash
#SBATCH --job-name=strings-compression=false
#SBATCH --partition=compute
#SBATCH --time=20:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3968MB
#SBATCH --output=job_out/job_%j.out
#SBATCH --error=job_out/job_%j.err

module load julia

set -euo pipefail
srun --unbuffered run_script.sh "strings" "false" 0
