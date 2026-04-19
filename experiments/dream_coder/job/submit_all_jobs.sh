#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF_NAME="$(basename "${BASH_SOURCE[0]}")"

cd "$SCRIPT_DIR"

for file in *.sh; do
    [[ "$file" == "run_script.sh" ]] && continue
    [[ "$file" == "$SELF_NAME" ]] && continue

    echo "Submitting $file"
    sbatch "$file"
done
