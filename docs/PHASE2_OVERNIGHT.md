# Phase 2 overnight work order: proof steps 1 through 6

Millennium Research, 2026-07-22. Historical: the execution plan for an
8-hour uninterrupted overnight block on Optio, to begin after the 10^12
chunk run posted its final tally. The trigger never fired (the run was
stopped and moved to a pod); see docs/PHASE2_LOG.md for what actually
ran. Steps refer to docs/ERDOS364_PROOF_PLAN.md.

## Trigger and machine discipline

Do not start heavy compiles while the 10^12 batch is running. Begin when
data/chunk_runs/1e12.log contains its "run end" line. First action on
trigger: record the tally (pass/fail counts, total wall, slowest chunk,
peak RSS from the log) in docs/PHASE1_MEASUREMENTS.md, commit. If the run
ended INCOMPLETE, do not debug it overnight; note it for Ibby and proceed
with the proof work, which does not depend on the run's artifacts.
Throughout the block: at most two lean processes at once, none if a
certificate-scale compile is ever needed (it is not, tonight).

## The contract

The lemma statements in ERDOS364_PROOF_PLAN.md steps 1-6 are fixed. Never
weaken, narrow, or restate a lemma to make it provable; if a statement
proves wrong as written, that is a finding to report, not to paper over.
No native_decide, no new axioms, nothing that fails the gate. Every
finished lemma compiles sorry-free before it is committed; work in
progress may carry sorry only in the working tree, never in a commit.
Commit per completed step (or completed coherent lemma group) with
centurion-style messages; push after each commit. All Lean work in
Erdos364/ modules: Mod4.lean (step 1), Representation.lean (step 2),
Generator.lean (step 3), Sorted.lean (step 4), Tiling.lean (step 5),
Witness.lean (step 6), imported from Erdos364.lean root.

## Order of attack and time boxes

1. Step 1, mod-4 (target 45 min): the two lemmas, plus the helper
   "2 mod 4 is not powerful". Small, unblocks the assembly shape.
2. Step 6, witnesses (target 45 min): the generic kill lemma and five
   instances at 10^12 values. Independent of everything else.
3. Step 5, tiling (target 1 h): boundary-table Bool fold and the covering
   lemma, stated against a generic boundary list so the 10^12 table drops
   in later.
4. Step 2, representation (target 3 h, the long pole): odd powerful
   m = a^2 b^3 with a, b odd, b squarefree, via Nat.factorization. If
   stuck at the 3-hour box, leave the cleanest sorry'd skeleton with a
   note on the blocking API and move on.
5. Steps 3-4, checker soundness (remaining time): isqrt invariant first
   (self-contained fuel induction), then stream membership, then
   sortedness and the adjacency argument. These are long but mechanical;
   partial progress in committed sorry-free pieces (e.g. isqrt lemmas
   alone) is worth more than an uncommitted sweep.

If any box finishes early, roll time forward. If all six complete, begin
step 7 assembly scaffolding (file moves and imports only; no certificate
compile).

## Verification and honesty

After each commit: lake build must succeed from clean state of the touched
modules; #print axioms on each new theorem must show a subset of {propext,
Classical.choice, Quot.sound}. Keep a running log in
the phase log: timestamp, lemma, status (proved / sorry'd at
box / statement-issue found), one line each.
Python gates (ruff, mypy, pytest) rerun only if engine/ is touched (it
should not be).

## Morning report to Ibby

Lead with: steps fully done, steps partial (what compiles, what is
sorry'd), any statement found wrong as written, tally of the 10^12 run,
and the exact remaining work with revised estimates for steps 1-6 and the
step-7 compile decision (local night vs pod). Nothing public, no
outreach, no wiki edits. Stop after the report; step 7+ waits for her go.
