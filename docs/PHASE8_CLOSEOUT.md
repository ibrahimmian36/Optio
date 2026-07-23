# Closeout work order: gate, bridge, README (steps 8-9)

Millennium Research, 2026-07-23. Both rungs are certified and all compute
is finished. This order covers the remaining desk work and the freeze
discipline that protects the evidence.

## Freeze discipline (the governing rule)

The Lean modules in the certified closure — Defs, Spike, Mod4, Witness,
Tiling, Representation, Generator, Sorted, Cert, BTable, TableGen,
BTableData*, Assembly, Assembly14, C12*, C14*, Main, Main14 — are FROZEN.
The committed axiom records attest builds of those sources as they stand;
cosmetic edits (the push_neg deprecation, the maxHeartbeats lint comment
placement) would make HEAD diverge from the attested sources for zero
mathematical gain, so they are deliberately not made, and the README says
so. New work lands only in NEW files: AxiomCheck additions (not imported
by any certified module), AxiomAudit, Bridge, CI workflow, docs, README.

## Deliverables

1. GATE. AxiomCheck grows to cover the assembly layers (Assembly and
   Assembly14 lemmas, the two 10^14 witness kills, the -of headline
   theorems). AxiomAudit sweeps every theorem of every locally buildable
   Erdos364 module mechanically, so nothing slips the manifest.
   scripts/axiom_gate.sh runs both, centurion-style: PASS iff every
   theorem's axioms are within {propext, Classical.choice, Quot.sound},
   zero sorryAx, zero _native. Scope note, stated honestly everywhere:
   the gate covers the lemma library that builds on a laptop; the
   certificate modules (C12, C14, Main, Main14) were built on the pod
   with their #print axioms output committed as evidence, because 3,524
   kernel-checked certificates exceed free CI budgets.
2. CI. GitHub Actions: toolchain + mathlib cache, build the root library,
   run the gate. Green badge = the soundness stack is axiom-clean at
   HEAD.
3. BRIDGE. Erdos364/Bridge.lean (new file, imports Assembly/Assembly14
   only): the upstream erdos_364 statement quoted verbatim with the
   pinned commit, the correspondence of our Powerful to upstream's, the
   trivial implication (upstream's conjecture implies each bounded
   theorem) proved abstractly, and pointers to Main/Main14 for the
   unconditional bounded results.
4. README. Final form: both certified theorems with their evidence files,
   the three uncertified tiers with caveats (Johnson 10^22 exhaustive;
   7.38e28 conditional on unproven A076445 completeness; Alekseyev
   ~8.1e66 non-exhaustive), how to re-verify each layer, the freeze note,
   and the citation ledger from the Phase 0 memo.

## Acceptance

Gate PASS locally; CI green on push; Bridge compiles sorry-free and
gate-clean; README readable start to finish by someone who has never seen
this conversation. Publication drafts (repo public, upstream
contribution, provenance note) are step 10 and wait for Ibby.
