/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Defs
import Mathlib.Tactic.NormNum

/-!
# The mod-4 reduction (proof plan step 1)

A number that is 2 mod 4 has 2 as a prime factor without 4 dividing it, so
it is not powerful. In a triple of consecutive powerful numbers the first
must therefore be odd: an even start puts either the first or the third at
2 mod 4.
-/

namespace Erdos364

/-- A number that is `2` mod `4` is not powerful. -/
theorem not_powerful_of_two_mod_four {n : ℕ} (h : n % 4 = 2) :
    ¬ n.Powerful := by
  intro hp
  have hmem : 2 ∈ n.primeFactors :=
    Nat.mem_primeFactors.mpr ⟨Nat.prime_two, by omega, by omega⟩
  have h4 := hp 2 hmem
  norm_num at h4
  omega

/-- The first member of a powerful triple is odd. -/
theorem odd_of_powerful_triple {n : ℕ}
    (h0 : n.Powerful) (_h1 : (n + 1).Powerful) (h2 : (n + 2).Powerful) :
    n % 2 = 1 := by
  by_contra h
  have h4 : n % 4 = 0 ∨ n % 4 = 2 := by omega
  rcases h4 with h4 | h4
  · exact not_powerful_of_two_mod_four (show (n + 2) % 4 = 2 by omega) h2
  · exact not_powerful_of_two_mod_four h4 h0

end Erdos364
