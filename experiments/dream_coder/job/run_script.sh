#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <experiment_name> <use_compression> <k>"
    echo "  experiment_name: e.g., 'karel', 'strings', 'pixels', etc."
    echo "  use_compression: true or false"
    echo "  k: integer value"
    exit 1
fi

EXPERIMENT_NAME="$1"
USE_COMPRESSION="$2"
K="$3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$REPO_ROOT"

# Activate this Julia project and run the uncommented DreamCoder test call.
julia --project=. -e "using Pkg; Pkg.activate(\".\"); using RefactoringExperiments; println(\"experiment_name=$EXPERIMENT_NAME use_compression=$USE_COMPRESSION k=$K\"); run_dream_coder_experiment(\"$EXPERIMENT_NAME\", 1000000, aux_tag=\"aulile_default\", max_number_of_attempts=10, use_compression=$USE_COMPRESSION, compression_timeout=120, k=$K)"
