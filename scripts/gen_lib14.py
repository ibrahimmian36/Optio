"""Emit the C14 certificate library modules from the spec manifest.

Reads data/c14_specs.json (the exact specs the batch runners verify) and
writes Erdos364/C14/Chunk<idx>.lean, Erdos364/C14/Table.lean, and
Erdos364/C14.lean with the forall_mem_cons composition. Content is
byte-equivalent to the runners up to module wrapping, so the pod batch's
green result carries over meaning, and the library build re-checks
everything in the kernel regardless.

Usage: gen_lib14.py
"""

from __future__ import annotations

import json
from pathlib import Path

HEADER = """/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
"""

CHUNK = HEADER + """import Erdos364.BTableData1e14
import Erdos364.TableGen

namespace Erdos364.C14

set_option maxRecDepth 100000 in
theorem chunk_{idx:04d} :
    Erdos364.Spike.checkChunkT {lo} {hi} {cnt}
      Erdos364.Spike.bTable1e14 [{exp}] = true := by
  decide +kernel

end Erdos364.C14
"""


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    spec = json.loads((root / "data" / "c14_specs.json").read_text())
    chunks = spec["chunks"]
    cdir = root / "Erdos364" / "C14"
    cdir.mkdir(parents=True, exist_ok=True)

    table_lines: list[str] = []
    imports: list[str] = []
    names: list[str] = []
    for c in chunks:
        idx, lo, hi, cnt = c["idx"], c["lo"], c["hi"], c["cnt"]
        exp = ", ".join(str(m) for m in c["exp"])
        (cdir / f"Chunk{idx:04d}.lean").write_text(
            CHUNK.format(idx=idx, lo=lo, hi=hi, cnt=cnt, exp=exp),
            encoding="utf-8",
        )
        table_lines.append(f"  ⟨{lo}, {hi}, 0, {cnt}, [{exp}]⟩")
        imports.append(f"import Erdos364.C14.Chunk{idx:04d}")
        names.append(f"chunk_{idx:04d}")

    table = (
        HEADER
        + "import Erdos364.Cert\n\nnamespace Erdos364.C14\n\n"
        + "-- The chunk table for X = 10^14 (kb field unused by the\n"
        + "-- table-driven checker; kept 0).\n"
        + "set_option maxRecDepth 1000000 in\n"
        + "def table : List Erdos364.ChunkSpec := [\n"
        + ",\n".join(table_lines)
        + "]\n\nend Erdos364.C14\n"
    )
    (cdir / "Table.lean").write_text(table, encoding="utf-8")

    c14 = (
        HEADER
        + "\n".join(imports)
        + "\nimport Erdos364.C14.Table\n\nnamespace Erdos364.C14\n\n"
        + "-- Every chunk certificate in the table checks (table-driven).\n"
        + "set_option maxRecDepth 1000000 in\n"
        + "theorem all_chunks_pass : ∀ e ∈ table,\n"
        + "    Erdos364.Spike.checkChunkT e.lo e.hi e.cnt\n"
        + "      Erdos364.Spike.bTable1e14 e.exp = true := by\n"
        + "\n".join(
            f"  refine List.forall_mem_cons.mpr ⟨{n}, ?_⟩" for n in names
        )
        + "\n  exact List.forall_mem_nil _\n\nend Erdos364.C14\n"
    )
    (root / "Erdos364" / "C14.lean").write_text(c14, encoding="utf-8")
    print(f"emitted {len(chunks)} C14 modules + Table + composition")
    return 0


if __name__ == "__main__":
    return_code = main()
    raise SystemExit(return_code)
