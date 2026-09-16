#!/usr/bin/env bash
# Build a Lake project's modules in bounded batches so Lake cannot fan out to
# one lean process per core (each ~1.3 GB on a large development) and exceed a
# container memory limit. Lake 5.0 (Lean 4.30) has no jobs flag.
# Usage: lake_build_batched.sh <project-dir> <root-module> [batch=6] [shard=0] [shards=1]
# With shards>1 only every shards-th leaf (starting at shard) is built, so
# independent jobs can split a large certificate set.
set -u
DIR="$1"; ROOT="$2"; N="${3:-6}"; SHARD="${4:-0}"; SHARDS="${5:-1}"
export PATH="$HOME/.elan/bin:$PATH"; cd "$DIR" || exit 2
# leaves only: a module that also has a directory of the same name is an
# aggregator whose import closure would defeat the batching
mods=$(find "$ROOT" -name '*.lean' | while read -r f; do d="${f%.lean}"; [ -d "$d" ] || echo "$f"; done | sed 's#/#.#g; s#\.lean$##' | sort)
mods=$(echo "$mods" | awk -v s="$SHARD" -v n="$SHARDS" 'NR % n == s')
total=$(echo "$mods" | wc -l | tr -d ' '); i=0; batch=""; rc_all=0
for m in $mods; do
  batch="$batch $m"; i=$((i+1))
  if [ $((i % N)) -eq 0 ] || [ "$i" -eq "$total" ]; then
    echo "[$(date -u +%FT%TZ)] batch ending at $i/$total"
    lake build $batch > /dev/null 2>&1 || { rc=$?; echo "batch rc=$rc: $batch"; rc_all=1; }
    batch=""
  fi
done
if [ "$SHARDS" = 1 ]; then echo "[$(date -u +%FT%TZ)] final lake build $ROOT"; lake build "$ROOT" > /dev/null 2>&1; rc=$?; echo "final rc=$rc"; else rc=0; fi
exit $(( rc_all || rc ))
