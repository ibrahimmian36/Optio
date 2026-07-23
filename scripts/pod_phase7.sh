#!/bin/bash
# Phase 7 on a fresh CPU pod: install the toolchain, build the library and
# the 10^14 base table, verify the table against mkBTable (the rung's
# one-time squarefree cost), then launch the 3,204-chunk batch in the
# background through the resumable driver. Requires the repo at ./Optio
# (rsync from the workstation, or clone the repo).
#
# Usage: bash Optio/scripts/pod_phase7.sh [parallel]   (default 8)
set -euo pipefail
par=${1:-8}

apt-get update -qq && apt-get install -y -qq git curl time > /dev/null
if [ ! -d "$HOME/.elan" ]; then
  curl -sSf https://elan.lean-lang.org/elan-init.sh | sh -s -- -y \
    --default-toolchain leanprover/lean4:v4.30.0
fi
export PATH="$HOME/.elan/bin:$PATH"

cd "$(dirname "$0")/.."
lake exe cache get
lake build Erdos364.BTableData1e14 Erdos364.TableGen

echo "verifying bTable1e14 against mkBTable (one-time)"
# Do NOT filter this through grep: an earlier version piped the output to
# grep and then echoed "table verified" unconditionally, which hid a real
# heartbeat-limit failure. Fail loudly instead.
if ! lake env lean spike_runs/BTableEq1e14.lean; then
  echo "TABLE VERIFICATION FAILED - stopping"
  exit 1
fi
echo "table verified"

nohup scripts/run_chunks.sh T14 "$par" >> data/chunk_runs/t14_console.log 2>&1 &
echo "batch launched, parallel=$par, 3204 chunks"
echo "watch:   tail -f $(pwd)/data/chunk_runs/T14.log"
echo "count:   grep -c '^PASS' $(pwd)/data/chunk_runs/T14.log"
echo "done at: ALL CHUNKS PASS (3204/3204)"
