#!/bin/bash
# Batch driver for chunked kernel certificates.
#
# Usage: scripts/run_chunks.sh <tag> [parallel]
#
# Runs every spike_runs/Chunk_<tag>_*.lean with bounded parallelism (default
# 2, sized for 16 GB RAM against the measured 5.3 GB top-end chunk peak).
# Resumable: rerunning skips chunks already logged as PASS. Exit 0 only when
# every chunk in the set has passed.
set -u
cd "$(dirname "$0")/.."
tag=$1
par=${2:-2}
log="data/chunk_runs/${tag}.log"
mkdir -p data/chunk_runs
total=$(ls spike_runs/Chunk_"${tag}"_*.lean 2>/dev/null | wc -l | tr -d ' ')
if [ "$total" -eq 0 ]; then
  echo "no chunk files for tag ${tag}; generate them with scripts/gen_spike_chunks.py"
  exit 1
fi
echo "run start $(date -u +%FT%TZ) tag=${tag} parallel=${par} total=${total}" >> "$log"
ls spike_runs/Chunk_"${tag}"_*.lean | xargs -P "$par" -I{} scripts/run_one_chunk.sh {} "$log"
# Count each chunk by its LAST status line, so a chunk that failed once
# and passed on a rerun counts as a pass (the log is append-only).
pass=$(awk '$1=="PASS"||$1=="FAIL"{s[$2]=$1} END{n=0; for(k in s) if(s[k]=="PASS") n++; print n}' "$log")
fail=$(awk '$1=="PASS"||$1=="FAIL"{s[$2]=$1} END{n=0; for(k in s) if(s[k]=="FAIL") n++; print n}' "$log")
echo "run end $(date -u +%FT%TZ) pass=${pass} fail=${fail} total=${total}" >> "$log"
if [ "$fail" -eq 0 ] && [ "$pass" -ge "$total" ]; then
  echo "ALL CHUNKS PASS (${pass}/${total})"
  exit 0
fi
echo "INCOMPLETE: pass=${pass} fail=${fail} total=${total} (log: ${log})"
exit 1
