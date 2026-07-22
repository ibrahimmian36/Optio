"""Mirror the cost-attribution variants and emit their runner files.

For a given certified chunk index, reads (lo, hi, kb) from the generated
Erdos364/C12/Chunk<idx>.lean, computes the expected values of each variant
independently (math.isqrt is exact), and writes one runner file per variant
to spike_runs/. A green `decide` on a runner is then also a cross-check
that the Lean variant computed what this mirror computed.

Usage: attrib_mirror.py IDX
"""

from __future__ import annotations

import math
import re
import sys
from pathlib import Path

RUNNER = """import Erdos364.CostAttrib

set_option maxRecDepth 100000 in
theorem attrib_{name}_{idx} :
    Erdos364.CostAttrib.{expr} = {value} := by
  decide +kernel
"""


def squarefree(n: int) -> bool:
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


def counts(lo: int, hi: int, kb: int) -> tuple[int, int, int]:
    sum_lens = 0
    no_sqfree = 0
    isqrt_sum = 0
    for k in range(1, kb + 1):
        b = 2 * k - 1
        b3 = b * b * b
        if b3 > hi:
            continue
        total = (math.isqrt(hi // b3) + 1) // 2
        skip = (math.isqrt((lo - 1) // b3) + 1) // 2
        isqrt_sum += math.isqrt(hi // b3) + math.isqrt((lo - 1) // b3)
        cnt = total - skip if skip < total else 0
        no_sqfree += cnt
        if squarefree(b):
            sum_lens += cnt
    return sum_lens, no_sqfree, isqrt_sum


def main() -> int:
    idx = int(sys.argv[1])
    root = Path(__file__).resolve().parent.parent
    src = (root / "Erdos364" / "C12" / f"Chunk{idx:03d}.lean").read_text(
        encoding="utf-8"
    )
    m = re.search(r"checkChunk (\d+) (\d+) (\d+) (\d+)", src)
    assert m is not None
    lo, hi, kb = int(m.group(1)), int(m.group(2)), int(m.group(3))
    win = hi + 2
    sum_lens, no_sqfree, isqrt_sum = counts(lo, win, kb)

    out = root / "spike_runs"
    out.mkdir(exist_ok=True)
    runs = [
        ("genOnly", f"sumLens {lo} {win} {kb}", sum_lens),
        ("genNoSqfree", f"noSqfreeCount {lo} {win} {kb}", no_sqfree),
        ("isqrtOnly", f"isqrtProbe {lo} {win} {kb} 0", isqrt_sum),
    ]
    for name, expr, value in runs:
        path = out / f"Attrib_{name}_{idx}.lean"
        path.write_text(
            RUNNER.format(name=name, idx=idx, expr=expr, value=value),
            encoding="utf-8",
        )
        print(f"{path.name}: expect {value}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
