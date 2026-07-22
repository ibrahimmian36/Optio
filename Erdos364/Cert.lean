/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Spike

/-!
# Certificate chunk specifications (proof plan step 7 support)

A chunk certificate is a boundary pair, the generator's base-count `kb`, the
expected entry count, and the expected gap-2 pair members, all literals. The
generated table (`Erdos364/C12/Table.lean`) lists one `ChunkSpec` per chunk;
each chunk module proves its `checkChunk` Bool; the assembly composes them
with the soundness stack.
-/

namespace Erdos364

/-- One chunk certificate's literal data. -/
structure ChunkSpec where
  lo : Nat
  hi : Nat
  kb : Nat
  cnt : Nat
  exp : List Nat

/-- The Bool the chunk module proves. -/
def ChunkSpec.check (e : ChunkSpec) : Bool :=
  Spike.checkChunk e.lo e.hi e.kb e.cnt e.exp

/-- The literal side conditions `checkChunk_sound` needs, as one Bool. -/
def ChunkSpec.side (e : ChunkSpec) : Bool :=
  decide (1 ≤ e.lo) && decide (e.hi + 2 < 2 ^ 64) &&
    decide (e.hi + 2 < (2 * e.kb + 1) * (2 * e.kb + 1) * (2 * e.kb + 1)) &&
    decide (e.kb ≤ 2 ^ 40)

end Erdos364
