#!/usr/bin/env bash
# Submits one job per element of names x use_refactoring x k from parameters.json.
# Usage: ./submit_all_jobs.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARAMS="$SCRIPT_DIR/parameters.json"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Slurm resolves --output relative to the submission dir, so run from here.
cd "$SCRIPT_DIR"
mkdir -p job_out

mapfile -t NAMES < <(jq -r '.names[]' "$PARAMS")
mapfile -t FLAGS < <(jq -r '.use_refactoring[]' "$PARAMS")
mapfile -t KS < <(jq -r '.k[]' "$PARAMS")

for name in "${NAMES[@]}"; do
    for flag in "${FLAGS[@]}"; do
        for k in "${KS[@]}"; do
            job_name="${name}-compression=${flag}-k=${k}"
            echo "Submitting $job_name"
            $DRY_RUN && continue
            sbatch \
                --job-name="$job_name" \
                --partition=compute \
                --time=20:00:00 \
                --ntasks=1 \
                --cpus-per-task=8 \
                --mem-per-cpu=3968MB \
                --output=job_out/job_%j.out \
                --error=job_out/job_%j.err \
                --wrap="module load julia && srun --unbuffered '$SCRIPT_DIR/run_script.sh' '$name' '$flag' '$k'"
        done
    done
done
