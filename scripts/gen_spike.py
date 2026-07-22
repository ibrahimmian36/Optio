"""Generate spike runner files with expected values from the Python engine.

Each runner is a standalone Lean file asserting the Bool checker at one X,
with the expected odd-powerful count and gap-2 members computed by
engine/scan.py machinery. Run them with:

    time lake env lean spike_runs/SpikeRun_<tag>.lean
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "engine"))

from scan import powerful_upto  # noqa: E402

TEMPLATE = """import Erdos364.Spike

set_option maxRecDepth 100000 in
theorem spike_{tag} :
    Erdos364.Spike.check {x} {kb} {count} [{expected}] = true := by
  decide +kernel
"""


def emit(x: int, tag: str, out_dir: Path) -> Path:
    odd = powerful_upto(x, odd_only=True)
    gap2 = odd[:-1][np.diff(odd) == 2]
    bmax = 1
    while (bmax + 1) ** 3 <= x:
        bmax += 1
    kb = (bmax + 1) // 2
    body = TEMPLATE.format(
        tag=tag,
        x=x,
        kb=kb,
        count=len(odd),
        expected=", ".join(str(int(v)) for v in gap2.tolist()),
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / f"SpikeRun_{tag}.lean"
    path.write_text(body, encoding="utf-8")
    return path


def main() -> int:
    out_dir = Path(__file__).resolve().parent.parent / "spike_runs"
    for exp in [6, 7, 8, 9, 10]:
        path = emit(10**exp, f"1e{exp}", out_dir)
        print(path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
