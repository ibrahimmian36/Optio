/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Defs
import Erdos364.Spike
import Erdos364.Representation
import Mathlib.Tactic.Ring

/-!
# Generator soundness (proof plan step 3)

Correctness of the fueled kernel primitives in `Erdos364.Spike`: the
binary-search integer square root, the trial-square squarefreeness test, and
membership in the ranged streams. Together with the representation lemma
these give chunk-level completeness: every odd powerful number in
`[lo, hi]` appears in `outerRangeAux lo hi kb []` provided `kb` covers every
candidate cube base, which each certificate supplies as a literal side
condition.
-/

namespace Erdos364.Spike

/-- The binary-search invariant: starting from a bracketing interval the
fueled search returns the exact integer square root, given fuel at least the
interval's bit length. -/
theorem isqrtAux_correct (n : ℕ) : ∀ (fuel lo hi : ℕ),
    lo * lo ≤ n → n < hi * hi → lo < hi → hi - lo ≤ 2 ^ fuel →
    (isqrtAux n fuel lo hi) * (isqrtAux n fuel lo hi) ≤ n ∧
      n < (isqrtAux n fuel lo hi + 1) * (isqrtAux n fuel lo hi + 1) := by
  intro fuel
  induction fuel with
  | zero =>
    intro lo hi hlo hhi hlt hgap
    simp only [pow_zero] at hgap
    have : hi = lo + 1 := by omega
    subst this
    exact ⟨hlo, hhi⟩
  | succ f ih =>
    intro lo hi hlo hhi hlt hgap
    rw [isqrtAux]
    by_cases hmid : (lo + hi) / 2 = lo
    · simp only [hmid]
      have : hi = lo + 1 := by omega
      subst this
      exact ⟨hlo, hhi⟩
    · simp only [if_neg hmid]
      have hpow : 2 ^ (f + 1) = 2 * 2 ^ f := by ring
      by_cases hle : (lo + hi) / 2 * ((lo + hi) / 2) ≤ n
      · simp only [if_pos hle]
        exact ih ((lo + hi) / 2) hi hle hhi (by omega) (by omega)
      · simp only [if_neg hle]
        exact ih lo ((lo + hi) / 2) hlo (by omega) (by omega) (by omega)

/-- Correctness of `isqrt` for every argument below `2^64`. -/
theorem isqrt_correct {n : ℕ} (h : n < 2 ^ 64) :
    isqrt n * isqrt n ≤ n ∧ n < (isqrt n + 1) * (isqrt n + 1) := by
  refine isqrtAux_correct n 64 0 (n + 1) (by omega) (by nlinarith) (by omega) ?_
  omega

/-- `isqrt` answers the "largest `r` with `r^2 ≤ n`" question. -/
theorem le_isqrt_iff {n a : ℕ} (h : n < 2 ^ 64) :
    a ≤ isqrt n ↔ a * a ≤ n := by
  obtain ⟨h1, h2⟩ := isqrt_correct h
  constructor
  · intro ha
    calc a * a ≤ isqrt n * isqrt n := Nat.mul_le_mul ha ha
    _ ≤ n := h1
  · intro ha
    by_contra hcon
    have : isqrt n + 1 ≤ a := by omega
    have := Nat.mul_le_mul this this
    omega

/-- The trial-square scan refutes squarefreeness only on true square
divisors. -/
theorem sqfreeAux_eq_false_iff (b : ℕ) : ∀ fuel,
    sqfreeAux b fuel = false ↔
      ∃ d, 2 ≤ d ∧ d ≤ fuel ∧ b % (d * d) = 0 := by
  intro fuel
  induction fuel with
  | zero =>
    simp only [sqfreeAux]
    constructor
    · intro h
      cases h
    · rintro ⟨d, hd2, hd0, -⟩
      omega
  | succ f ih =>
    rw [sqfreeAux]
    by_cases hcase : 2 ≤ f + 1 ∧ b % ((f + 1) * (f + 1)) = 0
    · have hbool : (f + 1 ≥ 2 && b % ((f + 1) * (f + 1)) == 0) = true := by
        simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq, ge_iff_le]
        exact hcase
      rw [if_pos hbool]
      constructor
      · intro _
        exact ⟨f + 1, hcase.1, le_refl _, hcase.2⟩
      · intro _
        rfl
    · have hbool : ¬ (f + 1 ≥ 2 && b % ((f + 1) * (f + 1)) == 0) = true := by
        simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq, ge_iff_le]
        exact hcase
      rw [if_neg hbool]
      rw [ih]
      constructor
      · rintro ⟨d, hd2, hdf, hmod⟩
        exact ⟨d, hd2, by omega, hmod⟩
      · rintro ⟨d, hd2, hdf, hmod⟩
        refine ⟨d, hd2, ?_, hmod⟩
        rcases Nat.lt_or_ge d (f + 1) with hlt | hge
        · omega
        · exfalso
          have : d = f + 1 := by omega
          subst this
          exact hcase ⟨hd2, hmod⟩

/-- The fueled squarefreeness test is exact when run with fuel `isqrt b`. -/
theorem sqfreeAux_isqrt_iff {b : ℕ} (hb : b ≠ 0) (hb64 : b < 2 ^ 64) :
    sqfreeAux b (isqrt b) = true ↔ Squarefree b := by
  rw [Nat.squarefree_iff_prime_squarefree]
  constructor
  · intro htrue p hp hppb
    have hple : p ≤ isqrt b :=
      (le_isqrt_iff hb64).mpr (Nat.le_of_dvd (Nat.pos_of_ne_zero hb) hppb)
    have hfalse : sqfreeAux b (isqrt b) = false :=
      (sqfreeAux_eq_false_iff b (isqrt b)).mpr
        ⟨p, hp.two_le, hple, Nat.mod_eq_zero_of_dvd hppb⟩
    rw [htrue] at hfalse
    cases hfalse
  · intro h
    cases hsf : sqfreeAux b (isqrt b) with
    | true => rfl
    | false =>
      obtain ⟨d, hd2, hdle, hmod⟩ := (sqfreeAux_eq_false_iff b _).mp hsf
      obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd (by omega : d ≠ 1)
      exact absurd ((mul_dvd_mul hpd hpd).trans (Nat.dvd_of_mod_eq_zero hmod))
        (h p hp)

/-- Stream membership: `genOddRangeAux` produces exactly the odd-indexed
squares `(2(kLo+i)+1)^2 * b3` for `i < cnt`, on top of the accumulator. -/
theorem mem_genOddRangeAux (b3 kLo : Nat) : ∀ (cnt : Nat) (acc : List Nat)
    (v : Nat), v ∈ genOddRangeAux b3 kLo cnt acc ↔
      (∃ i, i < cnt ∧ v = (2 * (kLo + i) + 1) * (2 * (kLo + i) + 1) * b3) ∨
        v ∈ acc := by
  intro cnt
  induction cnt with
  | zero =>
    intro acc v
    simp only [genOddRangeAux]
    constructor
    · intro h
      exact Or.inr h
    · rintro (⟨i, hi, -⟩ | h)
      · omega
      · exact h
  | succ c ih =>
    intro acc v
    rw [genOddRangeAux, ih]
    simp only [List.mem_cons]
    constructor
    · rintro (⟨i, hi, hv⟩ | hv | hv)
      · exact Or.inl ⟨i, by omega, hv⟩
      · exact Or.inl ⟨c, by omega, hv⟩
      · exact Or.inr hv
    · rintro (⟨i, hi, hv⟩ | hv)
      · rcases Nat.lt_or_ge i c with hic | hic
        · exact Or.inl ⟨i, hic, hv⟩
        · have : i = c := by omega
          subst this
          exact Or.inr (Or.inl hv)
      · exact Or.inr (Or.inr hv)

/-- Anything already accumulated survives the outer loop. -/
theorem outerRangeAux_acc_mono (lo hi : Nat) : ∀ (kb : Nat)
    (acc : List (List Nat)) (l : List Nat), l ∈ acc →
    l ∈ outerRangeAux lo hi kb acc := by
  intro kb
  induction kb with
  | zero =>
    intro acc l h
    exact h
  | succ k ih =>
    intro acc l h
    rw [outerRangeAux]
    split
    · split
      · exact ih _ _ (List.mem_cons_of_mem _ h)
      · exact ih _ _ h
    · exact ih _ _ h

/-- The stream for base index `k < kb` is among the outer loop's lists when
its guards pass. -/
theorem stream_mem_outerRangeAux (lo hi : Nat) : ∀ (kb : Nat) (k : Nat),
    k < kb →
    (2 * k + 1) * (2 * k + 1) * (2 * k + 1) ≤ hi →
    sqfreeAux (2 * k + 1) (isqrt (2 * k + 1)) = true →
    (isqrt ((lo - 1) / ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))) + 1) / 2 <
      (isqrt (hi / ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))) + 1) / 2 →
    ∀ acc, genOddRangeAux ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))
        ((isqrt ((lo - 1) / ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))) + 1) / 2)
        ((isqrt (hi / ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))) + 1) / 2 -
          (isqrt ((lo - 1) / ((2 * k + 1) * (2 * k + 1) * (2 * k + 1))) + 1) / 2)
        [] ∈ outerRangeAux lo hi kb acc := by
  intro kb
  induction kb with
  | zero =>
    intro k hk
    omega
  | succ kb' ih =>
    intro k hk hb3 hsf hst acc
    rw [outerRangeAux]
    rcases Nat.lt_or_ge k kb' with hlt | hge
    · split
      · split
        · exact ih k hlt hb3 hsf hst _
        · exact ih k hlt hb3 hsf hst _
      · exact ih k hlt hb3 hsf hst _
    · have hkeq : k = kb' := by omega
      subst hkeq
      have hguard : ((2 * k + 1) * (2 * k + 1) * (2 * k + 1) ≤ hi &&
          sqfreeAux (2 * k + 1) (isqrt (2 * k + 1))) = true := by
        simp only [Bool.and_eq_true, decide_eq_true_eq]
        exact ⟨hb3, hsf⟩
      rw [if_pos hguard, if_pos hst]
      exact outerRangeAux_acc_mono lo hi _ _ _ (List.mem_cons_self ..)

/-- Chunk-level completeness (step 3 capstone): every odd powerful number in
`[lo, hi]` appears in some stream of the outer loop, provided `1 ≤ lo`,
`hi` is in `isqrt` range, and `kb` covers every odd cube base up to `hi`. -/
theorem mem_of_odd_powerful {lo hi kb m : Nat} (hlo : 1 ≤ lo)
    (hhi : hi < 2 ^ 64)
    (hkb : hi < (2 * kb + 1) * (2 * kb + 1) * (2 * kb + 1))
    (hodd : Odd m) (hpow : m.Powerful) (h1 : lo ≤ m) (h2 : m ≤ hi) :
    ∃ l ∈ outerRangeAux lo hi kb [], m ∈ l := by
  obtain ⟨a, b, haodd, hbodd, hbsf, hm⟩ :=
    Erdos364.exists_odd_sq_mul_cube hpow hodd
  obtain ⟨j, hj⟩ := haodd
  obtain ⟨k, hk⟩ := hbodd
  have ha1 : 1 ≤ a := by omega
  have hb1 : 1 ≤ b := by omega
  have hb3 : b * b * b ≤ hi := by
    calc b * b * b = b ^ 3 := by ring
    _ ≤ a ^ 2 * b ^ 3 := Nat.le_mul_of_pos_left _ (pow_pos (by omega) 2)
    _ = m := hm.symm
    _ ≤ hi := h2
  have hbk : b * b * b < (2 * kb + 1) * (2 * kb + 1) * (2 * kb + 1) := by
    omega
  have hkkb : k < kb := by
    by_contra hcon
    push_neg at hcon
    have hble : 2 * kb + 1 ≤ 2 * k + 1 := by omega
    have hcube := Nat.mul_le_mul (Nat.mul_le_mul hble hble) hble
    rw [← hk] at hcube
    omega
  have hb0 : b ≠ 0 := by omega
  have hb64 : b < 2 ^ 64 := by
    have hbb : b ≤ b * b * b := by
      simpa using Nat.mul_le_mul (Nat.mul_le_mul hb1 hb1) (le_refl b)
    omega
  have hsf : sqfreeAux b (isqrt b) = true :=
    (sqfreeAux_isqrt_iff hb0 hb64).mpr hbsf
  set b3 := b * b * b with hb3def
  have hb3pos : 0 < b3 := by positivity
  have hmab : m = a * a * b3 := by
    rw [hm, hb3def]
    ring
  have hq64 : hi / b3 < 2 ^ 64 := lt_of_le_of_lt (Nat.div_le_self _ _) hhi
  have hl64 : (lo - 1) / b3 < 2 ^ 64 :=
    lt_of_le_of_lt (Nat.div_le_self _ _) (by omega)
  -- upper bound: a <= isqrt (hi / b3)
  have haup : a ≤ isqrt (hi / b3) := by
    rw [le_isqrt_iff hq64]
    rw [Nat.le_div_iff_mul_le hb3pos]
    calc a * a * b3 = m := hmab.symm
    _ ≤ hi := h2
  -- lower bound: isqrt ((lo-1) / b3) < a
  have halow : isqrt ((lo - 1) / b3) < a := by
    by_contra hcon
    push_neg at hcon
    have h1a : a * a ≤ (lo - 1) / b3 := by
      obtain ⟨hs1, hs2⟩ := isqrt_correct hl64
      calc a * a ≤ isqrt ((lo - 1) / b3) * isqrt ((lo - 1) / b3) :=
            Nat.mul_le_mul hcon hcon
      _ ≤ (lo - 1) / b3 := hs1
    have : a * a * b3 ≤ lo - 1 := by
      rw [← Nat.le_div_iff_mul_le hb3pos]
      exact h1a
    omega
  -- index arithmetic: a = 2j+1 lands at stream index j - skip
  have hskip : (isqrt ((lo - 1) / b3) + 1) / 2 ≤ j := by omega
  have htot : j < (isqrt (hi / b3) + 1) / 2 := by omega
  refine ⟨_, stream_mem_outerRangeAux lo hi kb k hkkb
    (by rw [← hk]; exact hb3) (by rw [← hk]; exact hsf) ?_ [], ?_⟩
  · rw [← hk, ← hb3def]
    omega
  · rw [mem_genOddRangeAux]
    refine Or.inl ⟨j - (isqrt ((lo - 1) / ((2 * k + 1) * (2 * k + 1) *
      (2 * k + 1))) + 1) / 2, ?_, ?_⟩
    · rw [← hk, ← hb3def]
      omega
    · rw [← hk, ← hb3def]
      have hja : 2 * ((isqrt ((lo - 1) / b3) + 1) / 2 +
          (j - (isqrt ((lo - 1) / b3) + 1) / 2)) + 1 = a := by omega
      rw [hja]
      exact hmab

end Erdos364.Spike
