#!/usr/bin/env bash
# Submits one job that runs every names x use_refactoring x k combination.
# Usage: ./submit_all_jobs.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARAMS="$SCRIPT_DIR/parameters.json"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Slurm resolves --output relative to the submission dir, so run from here.
cd "$SCRIPT_DIR"
mkdir -p job_out

NAMES_COUNT=$(jq '.names | length' "$PARAMS")
FLAGS_COUNT=$(jq '.use_refactoring | length' "$PARAMS")
KS_COUNT=$(jq '.k | length' "$PARAMS")
RUN_COUNT=$((NAMES_COUNT * FLAGS_COUNT * KS_COUNT))
JOB_NAME="dream-coder-all"

echo "Submitting $JOB_NAME ($RUN_COUNT experiment runs)"
$DRY_RUN && exit 0

WRAP_SCRIPT="set -e
module load julia
for name in \$(jq -r '.names[]' '$PARAMS'); do
    for flag in \$(jq -r '.use_refactoring[]' '$PARAMS'); do
        for k in \$(jq -r '.k[]' '$PARAMS'); do
            srun --unbuffered '$SCRIPT_DIR/run_script.sh' \"\$name\" \"\$flag\" \"\$k\"
        done
    done
done"

sbatch \
    --job-name="$JOB_NAME" \
    --partition=compute \
    --time=23:00:00 \
    --ntasks=24 \
    --cpus-per-task=1 \
    --mem-per-cpu=3968MB \
    --output=job_out/job_%j.out \
    --error=job_out/job_%j.err \
    --wrap="$WRAP_SCRIPT"
