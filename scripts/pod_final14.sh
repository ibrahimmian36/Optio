#!/bin/bash
# Final 10^14 certificate build: compiles the 3,204 C14 library modules in
# memory-safe batches of 8, then Erdos364.Main14, which discharges the
# table equality and the chunk composition and prints the axioms of
# no_powerful_triple_up_to_1e14. Run detached; expect several hours.
#
# Usage: nohup bash Optio/scripts/pod_final14.sh > Optio/data/final14.log 2>&1 &
set -u
export PATH="$HOME/.elan/bin:$PATH"
cd "$(dirname "$0")/.."
for i in $(seq 0 8 3203); do
  t=""
  for j in $(seq "$i" $((i + 7))); do
    [ "$j" -le 3203 ] && t="$t Erdos364.C14.Chunk$(printf %04d "$j")"
  done
  lake build $t || exit 1
done
lake build Erdos364.Main14
