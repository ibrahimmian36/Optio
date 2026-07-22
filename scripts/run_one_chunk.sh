#!/bin/bash
# Run a single chunk runner file through the kernel, appending a PASS/FAIL
# line with wall time and peak RSS to the shared log. Skips chunks already
# recorded as PASS, which makes the batch driver resumable. Portable across
# macOS (/usr/bin/time -l, bytes) and Linux (/usr/bin/time -v, kbytes).
set -u
f=$1
log=$2
name=$(basename "$f" .lean)
grep -q "^PASS $name " "$log" 2>/dev/null && exit 0
if [ "$(uname)" = "Darwin" ]; then
  timeflag="-l"
else
  timeflag="-v"
fi
start=$(date +%s)
out=$(/usr/bin/time $timeflag lake env lean "$f" 2>&1)
status=$?
end=$(date +%s)
rss=$(printf '%s' "$out" | awk 'tolower($0) ~ /maximum resident/ {
  if ($1 + 0 > 0) printf "%.0f", $1 / 1048576;
  else printf "%.0f", $NF / 1024 }')
if [ "$status" -eq 0 ]; then
  echo "PASS $name $((end - start))s ${rss:-?}MB" >> "$log"
else
  { echo "FAIL $name $((end - start))s ${rss:-?}MB"
    printf '%s\n' "$out" | tail -5; } >> "$log"
fi
exit $status
