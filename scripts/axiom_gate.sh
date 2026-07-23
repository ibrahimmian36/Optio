#!/bin/bash
# Erdos-364 publication gate, adapted from centurion.
#
# Two independent layers, both required:
#
#   1. Manifest (Erdos364/AxiomCheck.lean): every PUBLISHED theorem,
#      listed by name, `#print axioms`-ed for the record.
#   2. Audit (Erdos364/AxiomAudit.lean): every theorem in every locally
#      buildable Erdos364 module, discovered mechanically from the
#      compiled environment, so a theorem added tomorrow cannot slip past
#      the hand-maintained list.
#
# Every theorem must depend on AT MOST the three standard axioms
#   propext, Classical.choice, Quot.sound
# (subsets are fine), with zero `sorryAx` and zero `_native.*`
# (native_decide is forbidden: it mints a per-theorem trust axiom).
#
# Scope: the certificate modules (C12, C14, Main, Main14) build on a
# large-memory machine; their axiom records are the committed pod outputs
# in data/chunk_runs/cert_1e12_axioms.txt and cert_1e14_axioms.txt. This
# gate re-checks those two records textually as a third, weaker layer.
#
# Usage: scripts/axiom_gate.sh    (exits 0 on PASS, 1 on FAIL)
set -uo pipefail
cd "$(dirname "$0")/.."

# ---------- Layer 1: the curated manifest ----------
out=$(lake env lean Erdos364/AxiomCheck.lean 2>&1)
status=$?
echo "$out"
if [ $status -ne 0 ]; then
  echo "AXIOM GATE: FAIL (AxiomCheck.lean did not compile)"
  exit 1
fi
viol=$(echo "$out" | grep "depends on" \
  | sed 's/.*axioms: \[//; s/\]//' | tr ',' '\n' | tr -d ' ' \
  | grep -vE '^(propext|Classical\.choice|Quot\.sound)$' || true)
count=$(echo "$out" | grep -c "depends on")
nodeps=$(echo "$out" | grep -c "does not depend on any axioms" || true)
count=$((count + nodeps))
if [ -n "$viol" ]; then
  echo "AXIOM GATE: FAIL: disallowed axioms:"
  echo "$viol" | sort -u
  exit 1
fi
if echo "$out" | grep -qE "sorryAx|_native"; then
  echo "AXIOM GATE: FAIL: sorryAx or native axiom present"
  exit 1
fi
if [ "$count" -eq 0 ]; then
  echo "AXIOM GATE: FAIL: no '#print axioms' output found"
  exit 1
fi

# ---------- Layer 2: the automated whole-library audit ----------
aud=$(lake env lean Erdos364/AxiomAudit.lean 2>&1)
astatus=$?
echo "$aud"
if [ $astatus -ne 0 ]; then
  echo "AXIOM GATE: FAIL (automated audit failed, see output above)"
  exit 1
fi
audited=$(echo "$aud" | sed -n 's/.*AXIOM AUDIT: PASS: \([0-9][0-9]*\) theorems.*/\1/p' | head -1)
if [ -z "$audited" ]; then
  echo "AXIOM GATE: FAIL: audit compiled but reported no PASS line"
  exit 1
fi
if [ "$audited" -lt "$count" ]; then
  echo "AXIOM GATE: FAIL: audit saw $audited theorems, fewer than the $count in the manifest"
  exit 1
fi

# ---------- Layer 3: the committed certificate records ----------
for rec in data/chunk_runs/cert_1e12_axioms.txt data/chunk_runs/cert_1e14_axioms.txt; do
  if [ ! -f "$rec" ]; then
    echo "AXIOM GATE: FAIL: missing certificate record $rec"
    exit 1
  fi
  if ! grep -q "depends on axioms: \[propext, Classical.choice, Quot.sound\]" "$rec"; then
    echo "AXIOM GATE: FAIL: $rec does not show the clean axiom set"
    exit 1
  fi
  if grep -qE "sorryAx|_native" "$rec"; then
    echo "AXIOM GATE: FAIL: $rec contains sorryAx or a native axiom"
    exit 1
  fi
done

echo "AXIOM GATE: PASS ($count manifest theorems, $audited audited library-wide, certificate records clean, axioms within {propext, Classical.choice, Quot.sound})"
