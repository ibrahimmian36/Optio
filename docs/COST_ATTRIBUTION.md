# Cost attribution spike (1e14 plan, phase B)

Millennium Research, 2026-07-22. Work order and results for attributing the
per-chunk kernel cost before building any optimization. No optimization is
designed or written until the numbers below are measured. All runs local,
no pod, no spend. Nothing here touches the certified path: the variants
live in a module the library root does not import, they prove nothing, and
their assertions are equalities against Python-mirrored values, not
correctness claims.

## Question

Phase 1 measured per-chunk cost tracking value magnitude, not entry count
(chunk 0 of 320 at 3.8s vs chunk 319 at 242s, same ~2,500 entries). The
1e14 plan bets the dominant cost is the per-chunk squarefree recomputation
over all kb candidate b-values. Confirm or refute, with numbers.

## Method

Four timed kernel runs on the same chunk, same machine, same day. Each is
one `decide +kernel` on a Nat equality whose expected value is computed
independently by scripts/attrib_mirror.py, so a green run is also a
cross-check that the variant computed what the mirror computed.

    run          computes                                    isolates
    full         checkChunk (the real certificate Bool)      baseline
    genOnly      sum of stream lengths of the real           full - genOnly =
                 outerRangeAux (generation, no merge/scan)   merge + scan
    genNoSqfree  same, with the squarefree guard removed     genOnly - genNoSqfree =
                 (accepts every odd b)                       sqfree test cost*
    isqrtOnly    fueled fold of the two per-b isqrt calls    isqrt cost directly

    * genNoSqfree does MORE stream work (non-squarefree b admitted, more
      entries) while doing NO sqfree tests, so the subtraction understates
      the sqfree cost; it is a lower bound, and isqrtOnly plus stream-size
      accounting closes the books.

Protocol: smoke on chunk 0 first (validates the mirrors; wrong mirror =
decide fails immediately), then measure on chunk 319 (the expensive end,
where attribution matters). Wall times via /usr/bin/time, one run at a
time, no other load.

## Decision rule

If sqfree + isqrt account for the bulk of (full - merge - scan) at the top
end, phase C builds the shared squarefree-b table and baked-skip variant as
planned. If merge dominates, phase C targets the merge instead. If nothing
dominates (flat profile), the optimization phase is cancelled and 10^14 is
priced as brute force.

## Results (chunk 319, window [993775715691, 1000000000002], kb = 5000)

    run          wall      peak RSS   green (mirror agrees)
    full         305.5s    4.4 GB     yes (the certified chunk itself)
    lenOnly      396.1s    5.4 GB     yes  (streams + merge + length)
    genOnly      163.6s    5.0 GB     yes  (streams, sqfree included)
    genNoSqfree  8.3s      1.5 GB     yes  (streams, sqfree removed)
    isqrtOnly    6.6s      1.4 GB     yes

Smoke on chunk 0: all three variants green at ~1s (mirror validation).

## Attribution

1. THE SQUAREFREE TEST IS ~95% OF GENERATION: 163.6s with it, 8.3s without
   it, and the without-run builds MORE stream cells (every odd b admitted).
   Root cause of the position-dependent cost curve: per-chunk kb grows like
   cbrt(window), so chunk 0 trial-divides ~70 candidate b values and chunk
   319 trial-divides ~5,000, each at O(sqrt b) kernel steps. Hypothesis
   confirmed.
2. MERGE IS THE SECOND FIRST-CLASS COST, not negligible as assumed:
   lenOnly - genOnly ~ 230s, full - genOnly ~ 140s. The two brackets
   disagree because run-to-run variance on this laptop is large (note full
   at 305s vs lenOnly at 396s, though full does strictly more work); the
   honest statement is merge ~ 140-230s at the top end, i.e. comparable to
   sqfree. Mechanism: ~2,000 mostly-singleton streams, ~11 balanced rounds
   over ~2,500 entries, tens of kernel reductions per element-step; genuine
   kernel overhead, no accidental quadratic found.
3. isqrt and stream construction are noise (~8s together).

## Decision (feeds the 1e14 plan phase C)

Build the shared squarefree-b table: it deletes finding 1 (~155s/top
chunk) for a one-time table cost, exactly as planned. Merge (finding 2)
survives the optimization and becomes the floor: with sqfree gone, a
10^14 top chunk should cost roughly its merge+scan (~140-230s local,
faster on the pod). Revised 10^14 kernel-batch estimate: ~3,200 chunks,
entry-bound not kb-bound after the table, roughly 15-20 pod-hours at
8-way (~$15-20) instead of the ~100x brute-force blowup. A merge redesign
is NOT scheduled: its cost is entry-proportional and chunking-invariant,
the pod absorbs it, and new soundness surface for a second optimization is
not worth it at this rung. Revisit only if 10^14 pricing on the pod comes
in materially worse than projected.

## Postscript (phase 5 measured, same day)

The table-driven checker lands at 12.2s on chunk 319 (vs 305s certified,
25x) with the rung's entire squarefree cost paid once in an 80.4s table
verification. This falsifies the merge attribution above: merge is ~4s,
not 140-230s. The unexplained seconds in `full`/`lenOnly` were the
enumeration being forced more than once through the let-bound checker
shape plus documented run variance. Conclusion stands on the measured
artifact, not the estimate: sqfree table + single-shape checker = ~25x at
the top end.

## Full-rung revalidation (phase 6, same day)

All 320 certified 10^12 windows re-verified through checkChunkT over
bTable1e12: 320/320 PASS, zero FAIL, specs byte-identical to the certified
table. Summed kernel time 2,422s vs 57,652s certified (23.8x); wall 13.5
minutes at laptop parallelism 3; max chunk 11s (was 305s); peak 3.2 GB.
The optimized checker reproduces the certified enumeration exactly and the
rung that needed an overnight pod now fits a coffee break.
