# Phase 1 measurements

Machine: local Apple Silicon laptop, single core per run, Lean 4.30.0.
Method: standalone runner files (scripts/gen_spike.py, scripts/
gen_spike_chunks.py) asserting the Spike Bool checkers via `decide +kernel`;
wall time and peak RSS from `/usr/bin/time -l`. Expected counts and pair
members are baked from the Python engine, so every green run is a
cross-implementation agreement between the kernel enumeration and the numpy
enumeration.

## Python exhaustive scans (data/scan_ledger.jsonl)

    X       powerful    odd powerful  gap-1 pairs  odd gap-2 pairs  triples  time
    10^8    21,044      7,857         10           2                none     0.003s
    10^12   2,158,391   799,138       18           5                none     0.14s
    10^14   21,663,503  8,010,922     24           7                none     1.2s

Pair values match the OEIS b-files (A060355 terms 1..24, A076445 a(1)..a(7))
term by term; every pair member re-verified by trial factorization.

## Kernel spike, monolithic checker (one decide for all of [1, X])

    X       odd entries  wall time  outcome
    10^6    767          1.7s       pass
    10^7    2,458        3.6s       pass
    10^8    7,857        12.6s      pass
    10^9    25,019       killed     memory wall: 1.7 GB resident and paging
                                    (uninterruptible wait) after 13 min wall,
                                    ~2 min CPU; did not complete

The monolithic reduction term graph does not fit. This kills the monolith
above 10^8 and forces the chunked design; it does not affect feasibility,
only shape.

## Kernel spike, chunked checker (one decide per range, fresh process each)

Ranges overlap by 2 so no gap-2 pair straddles a boundary unseen; Phase 2
proves the stitching lemma.

10^9 in 10 equal-width chunks (all pass, total wall 50s):

    chunk 0 [1, 10^8]:   11.5s  2.8 GB     chunks 1-9: 3.7-5.6s, 1.0-1.5 GB

Equal-width chunking makes the first chunk dense (7,857 of the 25k entries).
Entry-balanced chunking (boundaries at equal entry counts) fixes this and is
the production shape.

10^12 in 320 entry-balanced chunks of ~2,500 entries, three samples (all
pass):

    chunk 0   (values near 1):        3.8s   1.1 GB
    chunk 160 (values near 2.5e11):   25.1s  4.6 GB
    chunk 319 (values near 10^12):    241.6s 5.3 GB

Per-chunk cost rises steeply with value magnitude at fixed entry count. The
b-loop size is constant across chunks (4,056 odd squarefree b at 10^12), so
the growth tracks the size of the numbers fed to the fueled isqrt binary
searches and the skip-range computation, not the entry count. Root-causing
and shrinking this (precomputed squarefree-b literal shared across chunks,
profiling the top-end blowup) is Phase 2 work with clear headroom.

## Ladder projection from the curve

Fitting the three 10^12 samples (quadratic through exponential fits bracket
the integral): full 10^12 is roughly 4-7 hours sequential, 1.5-3 hours at
2-3 parallel jobs (memory-capped at ~5 GB per top-end chunk). 10^10 chunked
is minutes. 10^13 extrapolates to days without the optimization pass; 10^14
is out of reach until the top-end cost is understood and reduced.

## Smoke rung result (approved ladder, run 2026-07-22)

10^10 in 32 entry-balanced chunks, parallelism 3: ALL PASS. Summed wall 218s,
slowest chunk 9s, peak RSS 2.0 GB (data/chunk_runs/1e10.log). The 10^12 set
(320 chunks) is generated and the resumable batch driver
(scripts/run_chunks.sh) is ready for the overnight run at parallelism 2.

## Overnight 10^12 attempt (2026-07-22 night): stopped, lesson recorded

141/320 chunks passed, 0 failed, 52,354 kernel-seconds banked
(data/chunk_runs/1e12.log) before Ibby stopped the run. Mid-range chunks
degraded to 42-49 minutes each against 242s for a top-end chunk run alone:
two 3-5 GB chunks in parallel plus the OS exceeded 16 GB and the machine
swapped all night. The three-sample projection missed the parallel-memory
interaction; per-chunk cost figures stand, the parallelism-2 local plan does
not. Certificate-scale batches move to a large-RAM pod (64 GB+, ~8-way,
whole set in roughly 1-2 hours); the driver's resumability means nothing is
lost either way.

## Recommendation

Approve the ladder as: 10^10 smoke rung now, 10^12 as the first published
rung (overnight run, current code), 10^13 and 10^14 deferred until the
Phase 2 optimization pass reprices them. All spike theorems check with
axioms {propext} only (decide produces no Classical dependencies here);
the gate criteria are met by construction, formal gate lands in Phase 2.
