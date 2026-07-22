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

## Results

(filled after the runs)
