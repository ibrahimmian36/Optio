# Phase 6 work order: revalidate the table checker against the certified rung

Millennium Research, 2026-07-22. The optimized checker earns trust the same
way everything else here has: by reproducing a known result exactly. All
320 chunks of the certified 10^12 rung are regenerated as `checkChunkT`
certificates over `bTable1e12`, with boundaries, counts, and expected pair
lists identical to the certified `C12` table, and every one must pass the
kernel. Two implementations, one truth, applied to the optimization itself.

## Contract

Boundaries are IDENTICAL to the certified rung (same generator code path),
verified mechanically by diffing the emitted specs against
`Erdos364/C12/Table.lean` before any kernel time is spent; a nonempty diff
aborts the phase. The certified path is untouched. Any chunk FAIL is a
stop-and-report: it would mean the table-driven enumeration disagrees with
the certified one somewhere below 10^12, which is a bug in the new path
until proven otherwise (the certified result stands regardless).

## Steps

1. gen_certsT emits spike_runs/Chunk_T12_<idx>.lean for all 320 certified
   windows: `checkChunkT lo hi cnt bTable1e12 [exp] = true` by decide.
2. Spec diff: parse (lo, hi, cnt, exp) from the emitted files and from the
   certified C12 table; require exact equality per index.
3. Batch through the existing resumable driver at local parallelism 3
   (measured ~1-3 GB per table chunk; 16 GB laptop holds 3 with slack).
   Projected total ~10-30 min against 57,652 certified kernel-seconds.
4. Acceptance: 320/320 PASS, zero FAIL, spec diff empty. Record the
   full-rung wall and per-chunk distribution next to the certified
   numbers in docs/COST_ATTRIBUTION.md.
5. Report with the measured speedup; the 10^14 generation (phase 7) is a
   separate go.

No pod, no spend: the whole point of phase 5 is that this now fits the
laptop.
