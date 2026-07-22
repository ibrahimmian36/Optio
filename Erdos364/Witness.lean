/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Defs
import Mathlib.Tactic.NormNum.Prime

/-!
# Non-powerfulness witnesses (proof plan step 6)

A prime dividing `n` exactly once refutes powerfulness. The five instances
kill the middles of the five odd powerful pairs below `10^12` (A076445
a(1)..a(5)); their witnesses were measured in Phase 1: `p = 2` wherever the
pair opens `1` mod `4`, and `p = 29` for the one pair opening `3` mod `4`.
-/

namespace Erdos364

/-- A prime dividing `n` whose square does not is a witness against
powerfulness. -/
theorem not_powerful_of_witness {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n)
    (hnsq : ¬ p ^ 2 ∣ n) : ¬ n.Powerful := by
  intro hpow
  have hn0 : n ≠ 0 := by
    rintro rfl
    exact hnsq (dvd_zero _)
  exact hnsq (hpow p (Nat.mem_primeFactors.mpr ⟨hp, hdvd, hn0⟩))

/-- `26 = 25 + 1`: middle of the pair `(25, 27)`. -/
theorem not_powerful_26 : ¬ Nat.Powerful 26 :=
  not_powerful_of_witness Nat.prime_two (by decide) (by decide)

/-- `70226 = 70225 + 1`: middle of the pair `(70225, 70227)`. -/
theorem not_powerful_70226 : ¬ Nat.Powerful 70226 :=
  not_powerful_of_witness Nat.prime_two (by decide) (by decide)

/-- `130576328 = 130576327 + 1`: middle of the pair
`(130576327, 130576329)`; the pair opens `3` mod `4`, so the witness is
`29`. -/
theorem not_powerful_130576328 : ¬ Nat.Powerful 130576328 :=
  not_powerful_of_witness (by norm_num : Nat.Prime 29) (by decide)
    (by decide)

/-- `189750626 = 189750625 + 1`: middle of the pair
`(189750625, 189750627)`. -/
theorem not_powerful_189750626 : ¬ Nat.Powerful 189750626 :=
  not_powerful_of_witness Nat.prime_two (by decide) (by decide)

/-- `512706121226 = 512706121225 + 1`: middle of the pair
`(512706121225, 512706121227)`. -/
theorem not_powerful_512706121226 : ¬ Nat.Powerful 512706121226 :=
  not_powerful_of_witness Nat.prime_two (by decide) (by decide)

end Erdos364

namespace Erdos364

/-- `13837575261124 = 13837575261123 + 1`: middle of A076445's sixth pair;
the pair opens `3` mod `4`, so the witness is `19`. -/
theorem not_powerful_13837575261124 : ¬ Nat.Powerful 13837575261124 :=
  not_powerful_of_witness (by norm_num : Nat.Prime 19) (by decide)
    (by decide)

/-- `99612037019890 = 99612037019889 + 1`: middle of A076445's seventh
pair. -/
theorem not_powerful_99612037019890 : ¬ Nat.Powerful 99612037019890 :=
  not_powerful_of_witness Nat.prime_two (by decide) (by decide)

end Erdos364
