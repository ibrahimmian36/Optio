# Erdős 364 — pushing the certified rung to 10^14

Millennium Research, 2026-07-22. Plan to extend the kernel-certified
verification from X = 10^12 to X = 10^14, the realistic ceiling of the
brute-enumeration method. Sequenced BEFORE the upstream contribution and
provenance note so the public artifact ships at its strongest.

## Framing (unchanged, honest)

10^14 is not a range record; it is still far below the uncertified bounds
(10^22 Johnson exhaustive, 7.38e28 conditional). Its value is demonstrating
that the certified machinery scales two orders further with no new ideas:
"the same kernel-clean verification runs to 10^14." The two-tier claim
language does not change.

## What changes from 10^12 to 10^14

    quantity                10^12         10^14         factor
    odd powerful entries    799,138       8,010,922     ~10x
    chunks @ 2500 entries    320          ~3,200        ~10x
    b-loop bound kb          4,056         18,815        ~4.6x
    known pair openers        5             7           +2 (A076445 a(6), a(7))
    per-chunk numbers        ~10^12        ~10^14        100x magnitude

The cost driver is NOT entry count. Phase 1 measured per-chunk cost tracking
value magnitude. The suspected reason: every chunk recomputes the
squarefree test for all kb candidate b-values, and that work scales as
sqrt(hi) PER CHUNK, independent of entries. At 10^14 that is ~10^7
operations per chunk times ~3,200 chunks of redundant sqfree work. If that
suspicion is right, brute-forcing 10^14 costs ~100x the 10^12 run (sqfree
scales 10x per chunk AND 10x more chunks), not 10x. Confirming and removing
this is the whole game.

## Phase A — land 10^12 (in progress)

The pod build of Erdos364.Main is running. Done when the log shows
`Build completed successfully` and the axioms line for
no_powerful_triple_up_to_1e12. Commit the build log, terminate the pod.
Nothing below starts until this is banked.

## Phase B — cost attribution spike (local, ~half day, do NOT optimize blind)

Build three variant checkers that each disable one stage (skip the sqfree
test / skip the isqrt calls / skip the merge), run them on a top-end 10^12
chunk, and diff the wall times against the real checker. The deltas
attribute the cost exactly. Deliverable: a measured breakdown that confirms
(or refutes) sqfree as the dominant redundant cost before any optimization
is built. These variants give wrong answers by design and are throwaway;
they never touch the certified path.

## Phase C — the shared squarefree-b table (local, 1-2 days, the risk)

If Phase B confirms sqfree dominates: compute the odd squarefree b-values
<= cbrt(X) ONCE as a verified literal, and have each chunk iterate that
list instead of re-testing squarefreeness.

New code:
- `bTable : List Nat` — the odd squarefree numbers <= B, a literal.
- `bTable_complete` — one kernel check that the list is exactly the odd
  squarefree numbers <= B (sorted, all odd, all squarefree, and complete:
  every odd squarefree m <= B is a member). Paid once, ~10^7 ops, not per
  chunk.
- `outerFromTable` / `checkChunkFromTable` — the generator threaded on the
  precomputed b-list, no per-b sqfree call.
- `checkChunkFromTable_sound` — the analogue of checkChunk_sound. The
  b-cover step now cites bTable_complete instead of the inline sqfree
  characterization; the rest of the soundness stack (isqrt, streams,
  merge, scan, tiling, witnesses) is reused unchanged.

Expected saving: removes the ~100x sqfree blowup, bringing 10^14 back to
~10x the 10^12 cost (entry-driven). This is what makes 10^14 cheap and
clean rather than an expensive brute-force burn.

FALLBACK if the new soundness proof balloons past ~2 days: skip the
optimization and brute-force 10^14 (Phase E) on a 32-vCPU/128GB pod with
cost-balanced narrow chunks. Always reachable, just ~10x more pod time and
dollars. The optimization is a cost lever, not a correctness dependency, so
this fallback carries zero proof risk.

## Phase D — re-validate at 10^12 and measure (local + short pod, ~half day)

Regression gate: the optimized checker must reproduce the exact 320-chunk
10^12 result (same expected pairs, same counts) before it is trusted —
two implementations, one truth, applied to the optimization itself. Then
measure the new per-chunk throughput on sampled positions to price 10^14
honestly before committing the big run.

## Phase E — 10^14 scan, generation, kernel batch

1. Python first (the standing rule): scan to 10^14 exhaustively (already
   done once, ~1s; the 7 odd pairs and no triple are known), regenerate
   the chunk table cost-balanced (fewer entries per chunk toward the top so
   no chunk exceeds ~5 GB), and cross-check every reported pair by trial
   factorization.
2. Generate ~3,200 certificate modules + the table.
3. Kernel batch on a large pod (32 vCPU / 128 GB): run the resumable driver
   at memory-capped parallelism. Estimated 5-15 hours wall depending on
   whether the optimization landed; ~$15-30. Success = ALL CHUNKS PASS.

## Phase F — assembly for 10^14 (local, ~half day)

The Assembly is generic over the chunk table, so most of it regenerates.
Concrete changes:
- knownPairs extends to the 7 A076445 members <= 10^14: add 13837575261123
  and 99612037019889.
- Two new witness kills: middle 13837575261124 = 2^2 * 19 * ... (witness
  p = 19); middle 99612037019890 = 2 * 5 * ... (witness p = 2). Two
  two-line lemmas in Witness.lean.
- Regenerate the table, tiling check, side-condition check, and
  pair-confinement check for the 10^14 boundaries (all decide in seconds).
- The headline theorem no_powerful_triple_up_to_1e14, conditional on the
  10^14 chunk certificates, composed exactly as at 10^12.

## Phase G — final Main build (pod)

Build Erdos364.Main for 10^14 on the pod: re-checks all ~3,200 certificates
in the kernel plus the assembly. This is itself a large, memory-heavy
compile; run at low -j on the 128 GB pod. ~5-10 hours, ~$15. Done when the
axioms line for no_powerful_triple_up_to_1e14 prints clean. Copy the log
back, commit, terminate.

## Estimates

    phase   work                                  my time      pod
    A       land 10^12                            (running)    ~1h left
    B       cost attribution spike                half day     -
    C       squarefree-b table + soundness        1-2 days     -
    D       re-validate + measure                 half day     short
    E       scan/generate/kernel batch            half day     5-15h
    F       assembly (7 pairs, 2 witnesses)       half day     -
    G       final Main build                      -            5-10h
    total                                         ~4-6 days    ~$35-45

Gated on Phase C landing. With the fallback (brute-force), 10^14 is still
reachable without C, at ~$60-80 pod and slower runs but no added proof risk.

## Risks

1. Phase C soundness proof harder than budgeted. Mitigation: hard 2-day
   box, then fall back to brute-force. 10^14 is reachable either way.
2. Memory at the top end. Mitigation: cost-balanced chunking caps every
   chunk at ~5 GB; parallelism sized to fit 128 GB.
3. The final Main build (Phase G) is memory-heavy at 3,200 modules.
   Mitigation: low -j on the big pod; the build is resumable per module.
4. Throughput still too slow even optimized. Mitigation: Phase D prices it
   before the big run commits; if 10^14 is out of reach, 10^13 is the
   honest fallback rung and still one order past the published result.

## Decision points for Ibby

1. Approve the 10^14 target and this sequence (before upstream/provenance).
2. Approve the optimization-first approach with the brute-force fallback,
   or go straight to brute-force to avoid the proof risk.
3. Pod budget ceiling (~$45 optimized, ~$80 brute-force).
4. Whether 10^13 is an acceptable landing if 10^14 proves infeasible.
