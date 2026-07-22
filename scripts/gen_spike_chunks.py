"""Generate chunked spike runner files.

Splits [1, X] into equal-width chunks, each extended by 2 for boundary
overlap, and emits one runner file per chunk asserting the chunk checker with
expected values from the Python engine. Mirrors the Lean-side semantics
exactly: entries counted in [lo, hi+2], gap-2 members among those entries.

Usage: gen_spike_chunks.py X NCHUNKS TAG
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "engine"))

from scan import powerful_upto  # noqa: E402

TEMPLATE = """import Erdos364.Spike

set_option maxRecDepth 100000 in
theorem chunk_{tag}_{idx} :
    Erdos364.Spike.checkChunk {lo} {hi} {kb} {count} [{expected}] = true := by
  decide +kernel
"""


def emit_chunks(x: int, nchunks: int, tag: str, out_dir: Path) -> list[Path]:
    odd = powerful_upto(x + 2, odd_only=True)
    gap2_all = set(int(v) for v in odd[:-1][np.diff(odd) == 2].tolist())
    width = x // nchunks
    out_dir.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for idx in range(nchunks):
        lo = idx * width + 1
        hi = (idx + 1) * width if idx < nchunks - 1 else x
        window = odd[(odd >= lo) & (odd <= hi + 2)]
        in_window = [int(v) for v in window.tolist()]
        wset = set(in_window)
        gap2 = [m for m in in_window if m + 2 in wset and m in gap2_all]
        bmax = 1
        while (bmax + 1) ** 3 <= hi + 2:
            bmax += 1
        kb = (bmax + 1) // 2
        body = TEMPLATE.format(
            tag=tag,
            idx=idx,
            lo=lo,
            hi=hi,
            kb=kb,
            count=len(in_window),
            expected=", ".join(str(m) for m in gap2),
        )
        path = out_dir / f"Chunk_{tag}_{idx}.lean"
        path.write_text(body, encoding="utf-8")
        paths.append(path)
    return paths


def emit_balanced(
    x: int,
    per_chunk: int,
    tag: str,
    out_dir: Path,
    only: list[int] | None = None,
) -> list[Path]:
    """Entry-balanced chunking: boundaries chosen so every chunk holds about
    per_chunk entries. Optionally emit only the chunks at the given indices
    (for sampling large X without writing hundreds of files)."""
    odd = powerful_upto(x + 2, odd_only=True)
    inner = odd[odd <= x]
    nchunks = max(1, round(len(inner) / per_chunk))
    boundaries: list[tuple[int, int]] = []
    lo = 1
    for idx in range(nchunks):
        if idx == nchunks - 1:
            hi = x
        else:
            hi = int(inner[(idx + 1) * len(inner) // nchunks - 1])
            hi += 1 if hi % 2 == 1 else 0
        boundaries.append((lo, hi))
        lo = hi + 1
    out_dir.mkdir(parents=True, exist_ok=True)
    gap2_all = set(int(v) for v in odd[:-1][np.diff(odd) == 2].tolist())
    paths: list[Path] = []
    for idx, (clo, chi) in enumerate(boundaries):
        if only is not None and idx not in only:
            continue
        window = odd[(odd >= clo) & (odd <= chi + 2)]
        in_window = [int(v) for v in window.tolist()]
        wset = set(in_window)
        gap2 = [m for m in in_window if m + 2 in wset and m in gap2_all]
        bmax = 1
        while (bmax + 1) ** 3 <= chi + 2:
            bmax += 1
        kb = (bmax + 1) // 2
        body = TEMPLATE.format(
            tag=tag,
            idx=idx,
            lo=clo,
            hi=chi,
            kb=kb,
            count=len(in_window),
            expected=", ".join(str(m) for m in gap2),
        )
        path = out_dir / f"Chunk_{tag}_{idx}.lean"
        path.write_text(body, encoding="utf-8")
        paths.append(path)
    print(f"nchunks={nchunks}")
    return paths


def main() -> int:
    x, tag = int(sys.argv[1]), sys.argv[3]
    out_dir = Path(__file__).resolve().parent.parent / "spike_runs"
    if sys.argv[2].startswith("per:"):
        per_chunk = int(sys.argv[2].removeprefix("per:"))
        only = [int(v) for v in sys.argv[4].split(",")] if len(sys.argv) > 4 else None
        for path in emit_balanced(x, per_chunk, tag, out_dir, only):
            print(path)
    else:
        for path in emit_chunks(x, int(sys.argv[2]), tag, out_dir):
            print(path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
