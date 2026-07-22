# Phase 5 work order: the shared squarefree-b table

Millennium Research, 2026-07-22. Instruction set for the one optimization
the attribution data justifies (docs/COST_ATTRIBUTION.md): replace the
per-chunk squarefree sweep with a rung-level literal table of the odd
squarefree cube bases, verified once. Local only, no pod, no spend.

## Contract

The certified 10^12 path (Spike.lean, Generator.lean, Sorted.lean, C12/,
Assembly.lean, Main.lean) is NOT touched: all new code lands in new
modules, so the banked certificate keeps compiling verbatim. Lemma
statements follow the shapes below; if one proves wrong as stated, that is
a reported finding, not a silent restatement. Every commit sorry-free and
gate-clean. Time box: 2 working days; if the soundness stack is not
compiling by then, stop and fall back to brute-force 10^14 per the 1e14
plan.

## Design

What soundness actually needs from the table (and nothing more):

    completeness  every odd squarefree b <= 2*kbT+1 is a member
                  (else the cover lemma loses a cube base and the
                  certificate silently misses powerful numbers: the one
                  catastrophic direction)
    all-odd       every member is odd (feeds the adjacency argument)

Member squarefreeness is NOT a soundness need (a junk stream only adds odd
powerful values, harmless to the pair scan); it is a cost/mirror concern
enforced by construction.

New modules:

    BTable.lean     mkBTable kbT : List Nat — the reference constructor:
                    the fueled loop over odd b keeping sqfreeAux survivors,
                    ascending. Proofs (abstract, reusing
                    sqfreeAux_isqrt_iff):
                      mem_mkBTable : Odd b -> Squarefree b ->
                        b <= 2*kbT - 1 -> b ∈ mkBTable kbT
                      mkBTable_all_odd : ∀ b ∈ mkBTable kbT, Odd b
    TableGen.lean   outerFromTable lo hi : List Nat -> ... — the generator
                    walking a b-list instead of testing candidates;
                    oddPowerfulRangeT, checkChunkT (same window and +2
                    overlap semantics as checkChunk). Proofs mirroring
                    Generator.lean/Sorted.lean by list induction instead
                    of fuel induction:
                      stream_mem_outerFromTable, outerFromTable_acc_mono,
                      outerFromTable_lists (all-odd streams),
                      mem_of_odd_powerful_T (cover, cites mem_mkBTable),
                      checkChunkT_sound (the capstone; merge and scan
                      lemmas from Sorted.lean reused unchanged)

Per-rung data (generated, not hand-written): the rung table as a literal
`bTableR : List Nat` with ONE kernel check `bTableR = mkBTable kbT` (this
is where the whole rung's sqfree cost is paid, once, ~minutes) — all
soundness lemmas transfer through that equality. Certificates then state
`checkChunkT lo hi cnt exp = true` against `bTableR`; the per-chunk kb
column and per-chunk side conditions shrink to one rung-level condition
`window_max + 2 < (2*kbT+1)^3` plus the per-chunk window bounds.

## Order of work

1. BTable.lean: constructor + the two lemmas. The completeness proof is
   the phase's long pole (induction on the fueled filter, the odd/
   squarefree witness landing in its slot).
2. TableGen.lean: definitions + the soundness stack through
   checkChunkT_sound.
3. scripts/gen_btable.py + smoke rung at 10^8: generate the 10^8 table
   (232 entries), its equality runner, a handful of chunkT certificates
   with Python-mirrored expected values, and run everything green locally.
   Also time one table-equality decide and one chunkT at 10^12 scale
   (table 4,056 entries; expect the per-chunk sqfree cost to be gone,
   merge to remain per the attribution).
4. Report with measured before/after per-chunk numbers. Phase 6
   (full 10^12 re-validation) is a separate go.

## Acceptance

BTable + TableGen compile sorry-free, axioms within the gate set, on the
manifest; smoke rung green end to end with mirrored values; measured
top-chunk time without the sqfree sweep. The 10^12/10^14 regeneration and
any pod work are NOT in this phase.
