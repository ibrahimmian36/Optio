"""Emit table-checker revalidation runners for the certified 10^12 rung.

Reads every certified chunk spec from Erdos364/C12/Chunk<idx>.lean,
re-emits it as a checkChunkT runner over bTable1e12, and verifies the
specs are byte-identical to the certified ones (same lo, hi, cnt, exp).
Any drift aborts before kernel time is spent.

Usage: gen_certsT.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

RUNNER = """import Erdos364.BTableData1e12
import Erdos364.TableGen

set_option maxRecDepth 100000 in
theorem chunkT12_{idx:03d} :
    Erdos364.Spike.checkChunkT {lo} {hi} {cnt}
      Erdos364.Spike.bTable1e12 [{exp}] = true := by
  decide +kernel
"""

SPEC = re.compile(
    r"checkChunk (\d+) (\d+) (\d+) (\d+) \[([0-9, ]*)\]", re.DOTALL
)


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    cdir = root / "Erdos364" / "C12"
    out = root / "spike_runs"
    out.mkdir(exist_ok=True)
    table_src = (cdir / "Table.lean").read_text(encoding="utf-8")
    table_specs = re.findall(
        r"⟨(\d+), (\d+), (\d+), (\d+), \[([0-9, ]*)\]⟩", table_src
    )
    assert len(table_specs) == 320, len(table_specs)

    emitted = 0
    for idx in range(320):
        src = (cdir / f"Chunk{idx:03d}.lean").read_text(encoding="utf-8")
        m = SPEC.search(src.replace("\n", " "))
        assert m is not None, idx
        lo, hi, kb, cnt, exp = (
            m.group(1), m.group(2), m.group(3), m.group(4),
            re.sub(r"\s+", " ", m.group(5)).strip(),
        )
        t_lo, t_hi, t_kb, t_cnt, t_exp = table_specs[idx]
        t_exp = re.sub(r"\s+", " ", t_exp).strip()
        if (lo, hi, kb, cnt, exp) != (t_lo, t_hi, t_kb, t_cnt, t_exp):
            print(f"SPEC DIFF at {idx}: chunk=({lo},{hi},{kb},{cnt},[{exp}])"
                  f" table=({t_lo},{t_hi},{t_kb},{t_cnt},[{t_exp}])")
            return 1
        (out / f"Chunk_T12_{idx}.lean").write_text(
            RUNNER.format(idx=idx, lo=lo, hi=hi, cnt=cnt, exp=exp),
            encoding="utf-8",
        )
        emitted += 1
    print(f"emitted {emitted} revalidation runners, spec diff empty")
    return 0


if __name__ == "__main__":
    sys.exit(main())
