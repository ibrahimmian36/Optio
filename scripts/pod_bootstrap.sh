#!/bin/bash
# One-shot setup + certificate batch for a fresh CPU pod (Ubuntu image).
# Installs elan/Lean 4.30.0, clones Optio, fetches the mathlib olean cache,
# regenerates the 10^12 chunk set, and runs the batch driver at the given
# parallelism. Resumable: rerunning skips chunks already logged as PASS.
#
# Usage on the pod: bash pod_bootstrap.sh [parallel]
set -euo pipefail
par=${1:-8}

apt-get update -qq && apt-get install -y -qq git curl time python3 python3-numpy > /dev/null
curl -sSf https://elan.lean-lang.org/elan-init.sh | sh -s -- -y \
  --default-toolchain leanprover/lean4:v4.30.0
export PATH="$HOME/.elan/bin:$PATH"

if [ ! -d Optio ]; then
  git clone https://github.com/ibrahimmian36/Optio.git
fi
cd Optio
lake exe cache get
lake build

python3 scripts/gen_spike_chunks.py 1000000000000 per:2500 1e12 | tail -1
nohup scripts/run_chunks.sh 1e12 "$par" >> data/chunk_runs/1e12_console.log 2>&1 &
echo "batch launched, parallel=$par"
echo "watch:   tail -f Optio/data/chunk_runs/1e12.log"
echo "summary: grep -c '^PASS' Optio/data/chunk_runs/1e12.log"
