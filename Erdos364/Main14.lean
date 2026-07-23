/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Assembly14
import Erdos364.C14

/-!
# The certified result for X = 10^14

Discharges the assembly's two kernel facts: the rung table equality (the
one-time squarefree verification, minutes) and the 3,204 chunk
certificates (imported via `Erdos364.C14`). Build on a large-RAM machine
with bounded parallelism.
-/

namespace Erdos364

-- The rung table is exactly the odd squarefree cube bases in range.
-- (A `/-- -/` doc comment cannot precede `set_option ... in` in this
-- Lean; use a line comment.) `maxHeartbeats 0` lifts the elaborator's
-- step budget: the check is minutes of genuine kernel work, and the
-- default 200000-heartbeat ceiling aborts it partway.
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
theorem bTable1e14_eq : Spike.bTable1e14 = Spike.mkBTable 23208 := by
  decide +kernel

/-- No three consecutive powerful numbers with `n + 2 ≤ 10^14`. -/
theorem no_powerful_triple_up_to_1e14 :
    ∀ n : ℕ, n + 2 ≤ 100000000000000 →
      ¬ (Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧ Nat.Powerful (n + 2)) :=
  no_powerful_triple_up_to_1e14_of bTable1e14_eq C14.all_chunks_pass

#print axioms no_powerful_triple_up_to_1e14

end Erdos364
