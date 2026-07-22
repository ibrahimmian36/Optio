# Erdős 364 — Optio execution spec

Millennium Research, 2026-07-22. Companion to ERDOS364_PHASE0.md (read that
first; it holds the landscape, the bound provenance, and the design
correction). This file is the standing instruction set for all Optio work.
Ibby gave the go on 2026-07-22.

## The claim being built

First kernel-certified verification: no three consecutive powerful numbers
with n + 2 <= X, stated as

    forall n : Nat, n + 2 <= X -> not (Powerful n /\ Powerful (n+1) /\ Powerful (n+2))

checked entirely by the Lean kernel, axioms a subset of {propext,
Classical.choice, Quot.sound}, no native_decide, no sorry, Powerful carried
verbatim from formal-conjectures (commit e923379e609b9d5987011a1d1f06ec22ea25cd20
pinned; definition file FormalConjecturesForMathlib/Data/Nat/Full.lean).
Positioning always states the three uncertified tiers: exhaustive to 10^22
(Johnson 2011, A060355), conditional to 7.38e28 (A076445, completeness
unproven), known pairs to ~8.1e66 (Alekseyev, non-exhaustive). The
contribution is certification, not range. A hit is treated as a bug until a
second code path and a compiling certificate say otherwise.

## Certificate architecture (from Phase 0, corrected design)

1. MOD-4 LEMMA: in any powerful triple, n is odd and n+1 is 0 mod 4. Tool
   fact: m = 2 mod 4 is never powerful.
2. ENUMERATION: every odd powerful n <= X equals a^2 * b^3 with a, b odd and b
   squarefree. Fueled generator over odd squarefree b <= cbrt X, odd
   a <= sqrt(X / b^3); completeness proved abstractly, membership by kernel
   evaluation. Loop sizes measured: 873 b-values at 10^10, 4,056 at 10^12,
   18,815 at 10^14; entries 79,487 / 799,138 / 8,010,922.
3. PAIR SCAN: merge the per-b ascending streams into one sorted list (fueled
   balanced merging, never Nat.sqrt or well-founded recursion in kernel
   terms), scan adjacent entries for gap exactly 2.
4. MIDDLE KILLS: for each recovered pair (m, m+2), a prime p with p | m+1 and
   p^2 does not divide m+1. Known witnesses below 10^14: p = 2 for m = 25,
   70225, 189750625, 512706121225, 99612037019889; p = 29 for m = 130576327;
   p = 19 for m = 13837575261123.
5. BRIDGE: Erdos364 namespace mirrors the upstream statement bounded by X;
   Powerful inlined verbatim (module-system syntax stripped, noted in the
   header); upstream commit hash in the file header.

Kernel technique is centurion Erdos7/Enumeration.lean throughout: Finset-free,
structurally recursive, accumulator style, constant fuel, one closed Bool
equality per certificate checked by decide.

## Phases and gates

PHASE 1 (now, local CPU only, no API spend):
  a. Scaffold Optio (this repo): layout below, toolchain pinned, axiom gate
     adapted from centurion, README with the two-tier claim.
  b. Python engine, two implementations one truth: (i) the a^2 b^3 generator,
     (ii) a naive is-powerful check by trial factorization on samples and on
     every reported pair. Both must agree on counts, on the recovered A060355
     terms, and on the A076445 terms before any number is trusted. Ledger:
     append-only JSONL, timestamps, exact coverage statements
     ("exhausted [1, X]"), code SHA per line. ruff + mypy --strict + pytest
     all green before every commit.
  c. Exhaustive scan to 10^12 with ledger entries; cross-check against the
     OEIS b-files term by term.
  d. LEAN SPIKE (the gating measurement): fueled generator + merge + scan as
     a Bool checker, kernel-evaluated via decide at X = 10^6, 10^8, and if
     tolerable 10^9 or 10^10. Record wall-clock and peak memory per rung.
     Output: measured throughput curve and a ladder recommendation.
  e. Report to Ibby: numbers, spike curve, proposed ladder. STOP for ladder
     approval before Phase 2.

PHASE 2 (after ladder approval): soundness lemmas (representation
completeness, scanner correctness, mod-4), certificate files per rung
(10^10 smoke first), axiom gate green in CI, bridge file, README claim
finalized. Nothing public without Ibby.

## Repo layout

    Erdos364/        Lean library (Defs, Spike now; Enumeration, Scan,
                     Witness, Bridge, AxiomCheck, AxiomAudit in Phase 2)
    engine/          Python: scan.py, ledger.py, tests/
    scripts/         axiom_gate.sh, gen helpers
    docs/            this file, ERDOS364_PHASE0.md, measurements
    data/            ledger JSONL, OEIS reference copies (small, committed)

Toolchain: Lean 4.30.0, mathlib v4.30.0 (same as centurion; mathlib cache
reused from the local centurion checkout, provenance noted). Python 3.13
(/opt/anaconda3/bin/python3) for scratch; the committed engine targets the
same interpreter, stdlib + numpy only.

## Working rules (standing, inherited)

Smoke before scale: every script and every Lean checker runs a tiny validated
case first. Long runs backgrounded, logs end with exit=$?. Two
implementations before trusting any number. Append-only ledger; exhausted vs
sampled is a hard provenance rule. No native_decide, no sorry, gate before
commit. Commit style follows centurion's log: short imperative subject,
what-and-why body when needed, no AI tells anywhere. Secret-scan staged
diffs before any push. Ibby creates the GitHub repo and pushes; local
commits here. Nothing public, no outreach, no wiki edits without her
explicit send.
