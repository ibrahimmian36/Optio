#!/bin/bash
# Run a single chunk runner file through the kernel, appending a PASS/FAIL
# line with wall time and peak RSS to the shared log. Skips chunks already
# recorded as PASS, which makes the batch driver resumable.
set -u
f=$1
log=$2
name=$(basename "$f" .lean)
grep -q "^PASS $name " "$log" 2>/dev/null && exit 0
start=$(date +%s)
out=$(/usr/bin/time -l lake env lean "$f" 2>&1)
status=$?
end=$(date +%s)
rss=$(printf '%s' "$out" | awk '/maximum resident/ {printf "%.0f", $1/1048576}')
if [ "$status" -eq 0 ]; then
  echo "PASS $name $((end - start))s ${rss:-?}MB" >> "$log"
else
  { echo "FAIL $name $((end - start))s ${rss:-?}MB"
    printf '%s\n' "$out" | tail -5; } >> "$log"
fi
exit $status
