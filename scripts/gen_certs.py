"""Generate the certificate library modules for a ladder rung.

Emits Erdos364/C12/Chunk<idx>.lean (one checkChunk decide per chunk, same
boundaries as the verified spike run), Erdos364/C12/Table.lean (the literal
ChunkSpec list), and Erdos364/C12.lean (imports plus the all-chunks-pass
composition). Boundaries reproduce scripts/gen_spike_chunks.py exactly.

Usage: gen_certs.py X PER_CHUNK
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "engine"))

from scan import powerful_upto  # noqa: E402

HEADER = """/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
"""

CHUNK_TEMPLATE = HEADER + """import Erdos364.Spike

namespace Erdos364.C12

set_option maxRecDepth 100000 in
theorem chunk_{idx:03d} :
    Erdos364.Spike.checkChunk {lo} {hi} {kb} {count} [{expected}] = true := by
  decide +kernel

end Erdos364.C12
"""


def boundaries(x: int, per_chunk: int) -> list[tuple[int, int]]:
    odd = powerful_upto(x + 2, odd_only=True)
    inner = odd[odd <= x]
    nchunks = max(1, round(len(inner) / per_chunk))
    out: list[tuple[int, int]] = []
    lo = 1
    for idx in range(nchunks):
        if idx == nchunks - 1:
            hi = x
        else:
            hi = int(inner[(idx + 1) * len(inner) // nchunks - 1])
            hi += 1 if hi % 2 == 1 else 0
        out.append((lo, hi))
        lo = hi + 1
    return out


def main() -> int:
    x, per_chunk = int(sys.argv[1]), int(sys.argv[2])
    root = Path(__file__).resolve().parent.parent
    cdir = root / "Erdos364" / "C12"
    cdir.mkdir(parents=True, exist_ok=True)

    odd = powerful_upto(x + 2, odd_only=True)
    gap2_all = set(int(v) for v in odd[:-1][np.diff(odd) == 2].tolist())
    bounds = boundaries(x, per_chunk)

    table_lines: list[str] = []
    import_lines: list[str] = []
    proof_names: list[str] = []
    for idx, (clo, chi) in enumerate(bounds):
        window = odd[(odd >= clo) & (odd <= chi + 2)]
        in_window = [int(v) for v in window.tolist()]
        wset = set(in_window)
        gap2 = [m for m in in_window if m + 2 in wset and m in gap2_all]
        bmax = 1
        while (bmax + 1) ** 3 <= chi + 2:
            bmax += 1
        kb = (bmax + 1) // 2
        exp = ", ".join(str(m) for m in gap2)
        (cdir / f"Chunk{idx:03d}.lean").write_text(
            CHUNK_TEMPLATE.format(
                idx=idx, lo=clo, hi=chi, kb=kb, count=len(in_window),
                expected=exp,
            ),
            encoding="utf-8",
        )
        table_lines.append(f"  ⟨{clo}, {chi}, {kb}, {len(in_window)}, [{exp}]⟩")
        import_lines.append(f"import Erdos364.C12.Chunk{idx:03d}")
        proof_names.append(f"chunk_{idx:03d}")

    table = (
        HEADER
        + "import Erdos364.Cert\n\nnamespace Erdos364.C12\n\n"
        + "/-- The certified chunk table for X = "
        + str(x)
        + ": boundaries identical to the verified batch run. -/\n"
        + "def table : List Erdos364.ChunkSpec := [\n"
        + ",\n".join(table_lines)
        + "]\n\nend Erdos364.C12\n"
    )
    (cdir / "Table.lean").write_text(table, encoding="utf-8")

    # Combine the per-chunk theorems into `∀ e ∈ table, check e` as a
    # right-nested `forall_mem_cons` term. A `simp only [table, ...]` does
    # not scale to hundreds of entries (recursion-depth blowup); the refine
    # chain is linear and each step consumes one concrete cons. `check e`
    # is definitionally `checkChunk ...`, so each `chunk_NNN` is accepted.
    refine_lines = "\n".join(
        f"  refine List.forall_mem_cons.mpr ⟨{name}, ?_⟩"
        for name in proof_names
    )
    c12 = (
        HEADER
        + "\n".join(import_lines)
        + "\nimport Erdos364.C12.Table\n\nnamespace Erdos364.C12\n\n"
        + "/-- Every chunk certificate in the table checks. -/\n"
        + "set_option maxRecDepth 1000000 in\n"
        + "theorem all_chunks_pass :\n"
        + "    ∀ e ∈ table, Erdos364.ChunkSpec.check e = true := by\n"
        + refine_lines
        + "\n  exact List.forall_mem_nil _\n\nend Erdos364.C12\n"
    )
    (root / "Erdos364" / "C12.lean").write_text(c12, encoding="utf-8")
    print(f"emitted {len(bounds)} chunk modules + Table.lean + C12.lean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
