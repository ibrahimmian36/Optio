/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Defs
import Mathlib.Data.Nat.Squarefree

/-!
# The representation lemma (proof plan step 2)

Every odd powerful number is `a^2 * b^3` with `a`, `b` odd and `b`
squarefree. Route: mathlib's square-times-squarefree decomposition writes
`m = sq^2 * sf` with `sf` squarefree; powerfulness forces every prime of
`sf` into `sq` (the prime has exponent `2*e_sq + 1` in `m`, and powerful
plus squarefree makes that at least `2`), so `sf ∣ sq`; substituting
`sq = sf * c` gives `m = c^2 * sf^3`. This is what makes the odd `a^2 b^3`
generator complete, which is the certificate's enumeration guarantee.
-/

namespace Erdos364

/-- Divisors of odd numbers are odd. -/
theorem odd_of_dvd_odd {d m : ℕ} (hdvd : d ∣ m) (hodd : Odd m) : Odd d := by
  rcases Nat.even_or_odd d with he | ho
  · have h2d : 2 ∣ d := Nat.dvd_of_mod_eq_zero (Nat.even_iff.mp he)
    have h2m : 2 ∣ m := h2d.trans hdvd
    rw [Nat.odd_iff] at hodd
    omega
  · exact ho

/-- Step 2: every odd powerful number is an odd square times an odd
squarefree cube. -/
theorem exists_odd_sq_mul_cube {m : ℕ} (hpow : m.Powerful) (hodd : Odd m) :
    ∃ a b : ℕ, Odd a ∧ Odd b ∧ Squarefree b ∧ m = a ^ 2 * b ^ 3 := by
  have hm0 : m ≠ 0 := by
    rintro rfl
    simp [Nat.odd_iff] at hodd
  obtain ⟨sf, sq, hsf_pos, hsq_pos, hprod, hsf⟩ :=
    Nat.sq_mul_squarefree_of_pos (Nat.pos_of_ne_zero hm0)
  have hsf0 : sf ≠ 0 := hsf_pos.ne'
  have hsq0 : sq ≠ 0 := hsq_pos.ne'
  have hfact : m.factorization = 2 • sq.factorization + sf.factorization := by
    rw [← hprod, Nat.factorization_mul (pow_ne_zero 2 hsq0) hsf0,
      Nat.factorization_pow]
  have key : ∀ p : ℕ, p.Prime → p ∣ sf → p ∣ sq := by
    intro p pp hpsf
    have hpm : p ∣ m := hprod ▸ (hpsf.mul_left (sq ^ 2))
    have hp2 : p ^ 2 ∣ m := hpow p (Nat.mem_primeFactors.mpr ⟨pp, hpm, hm0⟩)
    have h2le : 2 ≤ m.factorization p :=
      (Nat.Prime.pow_dvd_iff_le_factorization pp hm0).mp hp2
    have hsfp : sf.factorization p ≤ 1 :=
      (Nat.squarefree_iff_factorization_le_one hsf0).mp hsf p
    have happ : m.factorization p =
        2 * sq.factorization p + sf.factorization p := by
      rw [hfact]
      simp [Finsupp.add_apply, two_smul, two_mul]
    have h1le : 1 ≤ sq.factorization p := by omega
    exact (Nat.Prime.dvd_iff_one_le_factorization pp hsq0).mpr h1le
  have hdvd : sf ∣ sq := by
    rw [← Nat.factorization_le_iff_dvd hsf0 hsq0]
    rw [Finsupp.le_iff]
    intro p hp
    have pp : p.Prime := Nat.prime_of_mem_primeFactors
      (Nat.support_factorization sf ▸ hp)
    have hpsf : p ∣ sf := Nat.dvd_of_mem_primeFactors
      (Nat.support_factorization sf ▸ hp)
    have h1le : 1 ≤ sq.factorization p :=
      (Nat.Prime.dvd_iff_one_le_factorization pp hsq0).mp (key p pp hpsf)
    have hsfp : sf.factorization p ≤ 1 :=
      (Nat.squarefree_iff_factorization_le_one hsf0).mp hsf p
    omega
  obtain ⟨c, hc⟩ := hdvd
  have hm : m = c ^ 2 * sf ^ 3 := by
    rw [← hprod, hc]
    ring
  have hcm : c ∣ m := by
    rw [hm]
    exact (dvd_pow_self c (by norm_num)).mul_right _
  have hsfm : sf ∣ m := by
    rw [hm]
    exact (dvd_pow_self sf (by norm_num)).mul_left _
  exact ⟨c, sf, odd_of_dvd_odd hcm hodd, odd_of_dvd_odd hsfm hodd, hsf, hm⟩

end Erdos364
