"""Generate a rung's squarefree-b table module and smoke runners.

Emits Erdos364/BTableData{tag}.lean holding the literal table plus the
one-time kernel equality against mkBTable, and (with --smoke) chunkT
runner files whose expected values mirror the table-driven checker
exactly. The mirror must match mkBTable's semantics: odd b <= 2*kbT - 1,
squarefree, ascending.

Usage: gen_btable.py X TAG [--smoke N]
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "engine"))

from scan import powerful_upto, squarefree_sieve  # noqa: E402

HEADER = """/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
"""


def kbt_for(x: int) -> int:
    bmax = 1
    while (bmax + 1) ** 3 <= x + 2:
        bmax += 1
    return (bmax + 1) // 2


def btable(x: int) -> tuple[int, list[int]]:
    kbt = kbt_for(x)
    limit = 2 * kbt - 1
    sf = squarefree_sieve(limit)
    return kbt, [b for b in range(1, limit + 1, 2) if sf[b]]


def main() -> int:
    x = int(sys.argv[1])
    tag = sys.argv[2]
    root = Path(__file__).resolve().parent.parent
    kbt, bs = btable(x)

    data = (
        HEADER
        + "import Erdos364.BTable\n\nnamespace Erdos364.Spike\n\n"
        + f"-- The odd squarefree cube bases for X = {x} "
        + f"(kbT = {kbt}, {len(bs)} entries).\n"
        + "set_option maxRecDepth 1000000 in\n"
        + f"def bTable{tag} : List Nat := [\n"
        + ",\n".join(
            "  " + ", ".join(str(b) for b in bs[i : i + 12])
            for i in range(0, len(bs), 12)
        )
        + "]\n\nend Erdos364.Spike\n"
    )
    (root / "Erdos364" / f"BTableData{tag}.lean").write_text(
        data, encoding="utf-8"
    )
    out = root / "spike_runs"
    out.mkdir(exist_ok=True)
    (out / f"BTableEq{tag}.lean").write_text(
        f"import Erdos364.BTableData{tag}\n\n"
        + "set_option maxRecDepth 1000000 in\n"
        + f"theorem bTable{tag}_eq :\n"
        + f"    Erdos364.Spike.bTable{tag} = "
        + f"Erdos364.Spike.mkBTable {kbt} := by\n"
        + "  decide +kernel\n",
        encoding="utf-8",
    )
    print(f"BTableData{tag}.lean: {len(bs)} entries, kbT={kbt}")

    if "--smoke" in sys.argv:
        n = int(sys.argv[sys.argv.index("--smoke") + 1])
        odd = powerful_upto(x + 2, odd_only=True)
        gap2_all = set(int(v) for v in odd[:-1][np.diff(odd) == 2].tolist())
        inner = odd[odd <= x]
        width = x // n
        for idx in range(n):
            lo = idx * width + 1
            hi = (idx + 1) * width if idx < n - 1 else x
            window = odd[(odd >= lo) & (odd <= hi + 2)]
            wset = set(int(v) for v in window.tolist())
            gap2 = [m for m in sorted(wset) if m + 2 in wset and m in gap2_all]
            exp = ", ".join(str(m) for m in gap2)
            (out / f"ChunkT_{tag}_{idx}.lean").write_text(
                f"import Erdos364.BTableData{tag}\n"
                + "import Erdos364.TableGen\n\n"
                + "set_option maxRecDepth 100000 in\n"
                + f"theorem chunkT_{tag}_{idx} :\n"
                + f"    Erdos364.Spike.checkChunkT {lo} {hi} "
                + f"{len(wset)} Erdos364.Spike.bTable{tag} [{exp}] = "
                + "true := by\n  decide +kernel\n",
                encoding="utf-8",
            )
            print(f"ChunkT_{tag}_{idx}.lean: [{lo}, {hi}] cnt={len(wset)}")
        _ = inner, math
    return 0


if __name__ == "__main__":
    sys.exit(main())
