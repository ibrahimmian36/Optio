"""Generate the 10^14 table-checker certificate runners.

Entry-balanced boundaries over the odd powerful numbers <= 10^14 (same
construction as the certified 10^12 rung), one checkChunkT runner per
chunk against bTable1e14, expected values mirrored from the Python
enumeration, and a JSON spec manifest for the assembly generator to
consume byte-exactly. Python scan cross-checks (trial factorization of
every reported pair) run before anything is emitted.

Usage: gen_certs14.py [per_chunk]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "engine"))

from scan import is_powerful_naive, powerful_upto  # noqa: E402

X = 10**14

RUNNER = """import Erdos364.BTableData1e14
import Erdos364.TableGen

set_option maxRecDepth 100000 in
theorem chunkT14_{idx:04d} :
    Erdos364.Spike.checkChunkT {lo} {hi} {cnt}
      Erdos364.Spike.bTable1e14 [{exp}] = true := by
  decide +kernel
"""


def main() -> int:
    per_chunk = int(sys.argv[1]) if len(sys.argv) > 1 else 2500
    root = Path(__file__).resolve().parent.parent
    out = root / "spike_runs"
    out.mkdir(exist_ok=True)

    odd = powerful_upto(X + 2, odd_only=True)
    gap2_all = [
        int(v) for v in odd[:-1][np.diff(odd) == 2].tolist()
    ]
    for m in gap2_all:
        if not (is_powerful_naive(m) and is_powerful_naive(m + 2)):
            raise AssertionError(f"pair {m} fails the naive cross-check")
    gap2_set = set(gap2_all)

    inner = odd[odd <= X]
    nchunks = max(1, round(len(inner) / per_chunk))
    specs: list[dict[str, object]] = []
    lo = 1
    for idx in range(nchunks):
        if idx == nchunks - 1:
            hi = X
        else:
            hi = int(inner[(idx + 1) * len(inner) // nchunks - 1])
            hi += 1 if hi % 2 == 1 else 0
        window = odd[(odd >= lo) & (odd <= hi + 2)]
        wset = set(int(v) for v in window.tolist())
        gap2 = [m for m in sorted(wset) if m + 2 in wset and m in gap2_set]
        exp = ", ".join(str(m) for m in gap2)
        (out / f"Chunk_T14_{idx}.lean").write_text(
            RUNNER.format(idx=idx, lo=lo, hi=hi, cnt=len(wset), exp=exp),
            encoding="utf-8",
        )
        specs.append(
            {"idx": idx, "lo": lo, "hi": hi, "cnt": len(wset), "exp": gap2}
        )
        lo = hi + 1

    (root / "data" / "c14_specs.json").write_text(
        json.dumps(
            {"x": X, "per_chunk": per_chunk, "pairs": gap2_all,
             "chunks": specs},
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"emitted {nchunks} runners; pairs <= 10^14: {gap2_all}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
