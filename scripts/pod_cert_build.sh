#!/bin/bash
# Final certificate build for a fresh CPU pod (Ubuntu image): installs the
# toolchain, pulls the mathlib cache, and builds Erdos364.Main, which
# re-checks all 320 chunk certificates in the kernel and prints the
# axioms of the headline theorem. Requires the repo at ./Optio (rsync it
# from the workstation; the repo is private so there is no clone path).
#
# Usage: bash Optio/scripts/pod_cert_build.sh [jobs]   (default 6 for 64 GB)
set -euo pipefail
jobs=${1:-6}

apt-get update -qq && apt-get install -y -qq git curl time > /dev/null
if [ ! -d "$HOME/.elan" ]; then
  curl -sSf https://elan.lean-lang.org/elan-init.sh | sh -s -- -y \
    --default-toolchain leanprover/lean4:v4.30.0
fi
export PATH="$HOME/.elan/bin:$PATH"

cd "$(dirname "$0")/.."
lake exe cache get
# This Lake lacks the `-j` short flag; use the long form. Limiting jobs is
# not optional: the heavy top-end chunks peak near 8 GB each, so unbounded
# parallelism OOM-kills on a 64 GB pod. 6 jobs stays under ~48 GB.
nohup lake build --jobs "$jobs" Erdos364.Main >> data/cert_build.log 2>&1 &
echo "certificate build launched, jobs=$jobs"
echo "watch:  tail -f $(pwd)/data/cert_build.log"
echo "done when the log shows 'Build completed successfully' and the"
echo "axioms line for no_powerful_triple_up_to_1e12"
