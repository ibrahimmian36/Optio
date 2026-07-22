/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Generator

/-!
# Merge and scan soundness (proof plan step 4)

The streams are sorted (`List.Pairwise (· ≤ ·)`) and all-odd; the fueled
balanced merge preserves both along with membership; and on a sorted
all-odd list the gap-2 scan catches every pair of members at distance `2`
(the only value that could separate them is even, hence absent). Composed
with generator completeness this yields the chunk checker's soundness.
-/

namespace Erdos364.Spike

/-- The stream closed form: prepending from the top down is `map` over
`range`. -/
theorem genOddRangeAux_eq (b3 kLo : Nat) : ∀ (cnt : Nat) (acc : List Nat),
    genOddRangeAux b3 kLo cnt acc =
      ((List.range cnt).map
        (fun i => (2 * (kLo + i) + 1) * (2 * (kLo + i) + 1) * b3)) ++ acc := by
  intro cnt
  induction cnt with
  | zero =>
    intro acc
    simp [genOddRangeAux]
  | succ c ih =>
    intro acc
    rw [genOddRangeAux, ih, List.range_succ]
    simp

/-- Streams are sorted. -/
theorem stream_sorted (b3 kLo cnt : Nat) :
    (genOddRangeAux b3 kLo cnt []).Pairwise (· ≤ ·) := by
  rw [genOddRangeAux_eq, List.append_nil, List.pairwise_map]
  rw [List.range_eq_range']
  refine List.Pairwise.imp ?_ List.pairwise_lt_range'
  intro i j hij
  have h : 2 * (kLo + i) + 1 ≤ 2 * (kLo + j) + 1 := by omega
  exact Nat.mul_le_mul (Nat.mul_le_mul h h) (le_refl b3)

/-- Streams over an odd cube base contain only odd values. -/
theorem stream_all_odd {b3 : Nat} (hb3 : Odd b3) (kLo cnt : Nat) :
    ∀ v ∈ genOddRangeAux b3 kLo cnt [], Odd v := by
  intro v hv
  rw [genOddRangeAux_eq, List.append_nil, List.mem_map] at hv
  obtain ⟨i, -, rfl⟩ := hv
  exact (Odd.mul (⟨kLo + i, by ring⟩ : Odd (2 * (kLo + i) + 1))
    (⟨kLo + i, by ring⟩ : Odd (2 * (kLo + i) + 1))).mul hb3

/-- Every list the outer loop emits over an empty accumulator is a stream
with an odd cube base. -/
theorem outerRangeAux_lists {lo hi : Nat} : ∀ (kb : Nat)
    (acc : List (List Nat)) (l : List Nat),
    l ∈ outerRangeAux lo hi kb acc →
    l ∈ acc ∨ ∃ b3 kLo cnt, Odd b3 ∧ l = genOddRangeAux b3 kLo cnt [] := by
  intro kb
  induction kb with
  | zero =>
    intro acc l h
    exact Or.inl h
  | succ k ih =>
    intro acc l h
    rw [outerRangeAux] at h
    rcases ih _ _ h with hacc | hstream
    · split at hacc
      · split at hacc
        · rcases List.mem_cons.mp hacc with heq | htail
          · refine Or.inr ⟨(2 * k + 1) * (2 * k + 1) * (2 * k + 1), _, _,
              ?_, heq⟩
            exact (Odd.mul (⟨k, by ring⟩ : Odd (2 * k + 1))
              (⟨k, by ring⟩ : Odd (2 * k + 1))).mul ⟨k, by ring⟩
          · exact Or.inl htail
        · exact Or.inl hacc
      · exact Or.inl hacc
    · exact Or.inr hstream

/-- Merge membership, any fuel. -/
theorem mem_mergeAux : ∀ (fuel : Nat) (xs ys acc : List Nat) (v : Nat),
    v ∈ mergeAux fuel xs ys acc ↔ v ∈ xs ∨ v ∈ ys ∨ v ∈ acc := by
  intro fuel
  induction fuel with
  | zero =>
    intro xs ys acc v
    simp only [mergeAux, List.reverseAux_eq, List.mem_append,
      List.mem_reverse]
    tauto
  | succ f ih =>
    intro xs ys acc v
    cases xs with
    | nil =>
      simp only [mergeAux, List.reverseAux_eq, List.mem_append,
        List.mem_reverse, List.not_mem_nil]
      tauto
    | cons x xs' =>
      cases ys with
      | nil =>
        simp only [mergeAux, List.reverseAux_eq, List.mem_append,
          List.mem_reverse, List.not_mem_nil]
        tauto
      | cons y ys' =>
        simp only [mergeAux]
        by_cases hle : x ≤ y
        · rw [if_pos hle, ih]
          simp only [List.mem_cons]
          tauto
        · rw [if_neg hle, ih]
          simp only [List.mem_cons]
          tauto

/-- Merge sortedness, with sufficient fuel: the accumulator is
reverse-sorted and bounds both inputs from below. -/
theorem sorted_mergeAux : ∀ (fuel : Nat) (xs ys acc : List Nat),
    xs.length + ys.length ≤ fuel →
    xs.Pairwise (· ≤ ·) → ys.Pairwise (· ≤ ·) →
    acc.Pairwise (· ≥ ·) →
    (∀ p ∈ acc, ∀ x ∈ xs, p ≤ x) →
    (∀ p ∈ acc, ∀ y ∈ ys, p ≤ y) →
    (mergeAux fuel xs ys acc).Pairwise (· ≤ ·) := by
  intro fuel
  induction fuel with
  | zero =>
    intro xs ys acc hlen hxs hys hacc hax hay
    have hx0 : xs = [] := by
      cases xs with
      | nil => rfl
      | cons a l => simp at hlen
    have hy0 : ys = [] := by
      cases ys with
      | nil => rfl
      | cons a l => rw [hx0] at hlen; simp at hlen
    subst hx0
    subst hy0
    simp only [mergeAux, List.append_nil, List.reverseAux_eq]
    rw [List.pairwise_reverse]
    exact hacc
  | succ f ih =>
    intro xs ys acc hlen hxs hys hacc hax hay
    cases xs with
    | nil =>
      simp only [mergeAux, List.reverseAux_eq]
      rw [List.pairwise_append, List.pairwise_reverse]
      refine ⟨hacc, hys, ?_⟩
      intro p hp y hy
      exact hay p (List.mem_reverse.mp hp) y hy
    | cons x xs' =>
      cases ys with
      | nil =>
        simp only [mergeAux, List.reverseAux_eq]
        rw [List.pairwise_append, List.pairwise_reverse]
        refine ⟨hacc, hxs, ?_⟩
        intro p hp z hz
        exact hax p (List.mem_reverse.mp hp) z hz
      | cons y ys' =>
        rw [List.pairwise_cons] at hxs hys
        simp only [mergeAux]
        by_cases hle : x ≤ y
        · rw [if_pos hle]
          refine ih xs' (y :: ys') (x :: acc) (by simp at hlen ⊢; omega)
            hxs.2 (List.pairwise_cons.mpr hys) ?_ ?_ ?_
          · rw [List.pairwise_cons]
            exact ⟨fun p hp => hax p hp x List.mem_cons_self, hacc⟩
          · intro p hp z hz
            rcases List.mem_cons.mp hp with rfl | hp'
            · exact hxs.1 z hz
            · exact hax p hp' z (List.mem_cons_of_mem _ hz)
          · intro p hp z hz
            rcases List.mem_cons.mp hp with rfl | hp'
            · rcases List.mem_cons.mp hz with rfl | hz'
              · exact hle
              · exact hle.trans (hys.1 z hz')
            · exact hay p hp' z hz
        · rw [if_neg hle]
          have hyx : y ≤ x := by omega
          refine ih (x :: xs') ys' (y :: acc) (by simp at hlen ⊢; omega)
            (List.pairwise_cons.mpr hxs) hys.2 ?_ ?_ ?_
          · rw [List.pairwise_cons]
            exact ⟨fun p hp => hay p hp y List.mem_cons_self, hacc⟩
          · intro p hp z hz
            rcases List.mem_cons.mp hp with rfl | hp'
            · rcases List.mem_cons.mp hz with rfl | hz'
              · exact hyx
              · exact hyx.trans (hxs.1 z hz')
            · exact hax p hp' z hz
          · intro p hp z hz
            rcases List.mem_cons.mp hp with rfl | hp'
            · exact hys.1 z hz
            · exact hay p hp' z (List.mem_cons_of_mem _ hz)

/-- One merge round preserves the members. -/
theorem mem_mergeRound : ∀ (ls : List (List Nat)) (v : Nat),
    (∃ l ∈ mergeRound ls, v ∈ l) ↔ ∃ l ∈ ls, v ∈ l := by
  intro ls
  induction ls using mergeRound.induct with
  | case1 l1 l2 rest ih =>
    intro v
    rw [mergeRound]
    simp only [List.mem_cons]
    constructor
    · rintro ⟨l, hl | hl, hv⟩
      · rw [hl, mem_mergeAux] at hv
        rcases hv with h | h | h
        · exact ⟨l1, Or.inl rfl, h⟩
        · exact ⟨l2, Or.inr (Or.inl rfl), h⟩
        · cases h
      · obtain ⟨l', hl', hv'⟩ := (ih v).mp ⟨l, hl, hv⟩
        exact ⟨l', Or.inr (Or.inr hl'), hv'⟩
    · rintro ⟨l, hl | hl | hl, hv⟩
      · refine ⟨mergeAux (l1.length + l2.length) l1 l2 [], Or.inl rfl, ?_⟩
        rw [mem_mergeAux]
        exact Or.inl (hl ▸ hv)
      · refine ⟨mergeAux (l1.length + l2.length) l1 l2 [], Or.inl rfl, ?_⟩
        rw [mem_mergeAux]
        exact Or.inr (Or.inl (hl ▸ hv))
      · obtain ⟨l', hl', hv'⟩ := (ih v).mpr ⟨l, hl, hv⟩
        exact ⟨l', Or.inr hl', hv'⟩
  | case2 ls h =>
    intro v
    rw [mergeRound.eq_def]
    split
    · exact absurd rfl (h _ _ _)
    · exact Iff.rfl

/-- One merge round preserves sortedness of every member list. -/
theorem sorted_mergeRound : ∀ (ls : List (List Nat)),
    (∀ l ∈ ls, l.Pairwise (· ≤ ·)) →
    ∀ l ∈ mergeRound ls, l.Pairwise (· ≤ ·) := by
  intro ls
  induction ls using mergeRound.induct with
  | case1 l1 l2 rest ih =>
    intro hall l hl
    rw [mergeRound] at hl
    rcases List.mem_cons.mp hl with rfl | htail
    · refine sorted_mergeAux _ l1 l2 [] (le_refl _)
        (hall l1 List.mem_cons_self)
        (hall l2 (List.mem_cons_of_mem _ List.mem_cons_self))
        List.Pairwise.nil (by simp) (by simp)
    · exact ih (fun l' hl' => hall l'
        (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hl'))) l htail
  | case2 ls h =>
    intro hall l hl
    rw [mergeRound.eq_def] at hl
    split at hl
    · exact absurd rfl (h _ _ _)
    · exact hall l hl

/-- A merge round at most halves the number of lists (rounding up). -/
theorem length_mergeRound : ∀ (ls : List (List Nat)),
    (mergeRound ls).length ≤ (ls.length + 1) / 2 := by
  intro ls
  induction ls using mergeRound.induct with
  | case1 l1 l2 rest ih =>
    rw [mergeRound]
    simp only [List.length_cons]
    omega
  | case2 ls h =>
    rw [mergeRound.eq_def]
    split
    · exact absurd rfl (h _ _ _)
    · match ls with
      | [] => simp
      | [l] => simp
      | l1 :: l2 :: rest => exact absurd rfl (h _ _ _)

/-- Balanced merging preserves the members, any fuel. -/
theorem mem_mergeAll : ∀ (fuel : Nat) (ls : List (List Nat)) (v : Nat),
    v ∈ mergeAll fuel ls ↔ ∃ l ∈ ls, v ∈ l := by
  intro fuel
  induction fuel with
  | zero =>
    intro ls v
    rw [mergeAll]
    simp [List.mem_flatten]
  | succ f ih =>
    intro ls v
    match ls with
    | [] =>
      rw [mergeAll]
      simp
    | [l] =>
      rw [mergeAll]
      simp
    | l1 :: l2 :: rest =>
      have hu : mergeAll (f + 1) (l1 :: l2 :: rest) =
          mergeAll f (mergeRound (l1 :: l2 :: rest)) := rfl
      rw [hu, ih, mem_mergeRound]

/-- Balanced merging sorts, with fuel logarithmic in the list count. -/
theorem sorted_mergeAll : ∀ (fuel : Nat) (ls : List (List Nat)),
    ls.length ≤ 2 ^ fuel →
    (∀ l ∈ ls, l.Pairwise (· ≤ ·)) →
    (mergeAll fuel ls).Pairwise (· ≤ ·) := by
  intro fuel
  induction fuel with
  | zero =>
    intro ls hlen hall
    rw [mergeAll]
    match ls with
    | [] => simp
    | [l] =>
      simp only [List.flatten_cons, List.flatten_nil, List.append_nil]
      exact hall l List.mem_cons_self
    | l1 :: l2 :: rest => simp at hlen
  | succ f ih =>
    intro ls hlen hall
    match ls with
    | [] =>
      rw [mergeAll]
      simp
    | [l] =>
      rw [mergeAll]
      exact hall l List.mem_cons_self
    | l1 :: l2 :: rest =>
      have hu : mergeAll (f + 1) (l1 :: l2 :: rest) =
          mergeAll f (mergeRound (l1 :: l2 :: rest)) := rfl
      rw [hu]
      refine ih _ ?_ (sorted_mergeRound _ hall)
      have hround := length_mergeRound (l1 :: l2 :: rest)
      have hpow : 2 ^ (f + 1) = 2 * 2 ^ f := by ring
      omega

/-- The scan keeps everything already accumulated. -/
theorem scanGap2Aux_acc_mono : ∀ (l acc : List Nat) (v : Nat),
    v ∈ acc → v ∈ scanGap2Aux l acc := by
  intro l
  induction l with
  | nil =>
    intro acc v hv
    exact hv
  | cons x tail ih =>
    intro acc v hv
    cases tail with
    | nil => exact hv
    | cons y rest =>
      rw [scanGap2Aux]
      refine ih _ v ?_
      split
      · exact List.mem_cons_of_mem _ hv
      · exact hv

/-- On a sorted all-odd list the scan catches every member pair at
distance `2`. -/
theorem scanGap2Aux_catches : ∀ (l : List Nat), l.Pairwise (· ≤ ·) →
    (∀ v ∈ l, Odd v) → ∀ (m : Nat) (acc : List Nat),
    m ∈ l → m + 2 ∈ l → m ∈ scanGap2Aux l acc := by
  intro l
  induction l with
  | nil =>
    intro _ _ m acc hm _
    cases hm
  | cons x tail ih =>
    intro hsorted hodd m acc hm hm2
    rw [List.pairwise_cons] at hsorted
    cases tail with
    | nil =>
      rcases List.mem_cons.mp hm with rfl | hm'
      · rcases List.mem_cons.mp hm2 with heq | hm2'
        · omega
        · cases hm2'
      · cases hm'
    | cons y rest =>
      rw [scanGap2Aux]
      rcases List.mem_cons.mp hm with rfl | hmtail
      · have hm2tail : m + 2 ∈ y :: rest := by
          rcases List.mem_cons.mp hm2 with heq | h
          · omega
          · exact h
        have hym : m ≤ y := hsorted.1 y List.mem_cons_self
        have hym2 : y ≤ m + 2 := by
          rcases List.mem_cons.mp hm2tail with heq | h
          · omega
          · exact (List.pairwise_cons.mp hsorted.2).1 _ h
        have hyodd := hodd y (List.mem_cons_of_mem _ List.mem_cons_self)
        have hmodd := hodd m List.mem_cons_self
        rw [Nat.odd_iff] at hyodd hmodd
        have hcase : y = m ∨ y = m + 2 := by omega
        rcases hcase with hy | hy
        · refine ih hsorted.2
            (fun v hv => hodd v (List.mem_cons_of_mem _ hv)) m _ ?_ hm2tail
          rw [hy]
          exact List.mem_cons_self
        · have hguard : (m + 2 == y) = true := by simp [hy]
          rw [if_pos hguard]
          exact scanGap2Aux_acc_mono _ _ m List.mem_cons_self
      · have hm2tail : m + 2 ∈ y :: rest := by
          rcases List.mem_cons.mp hm2 with heq | h
          · have := hsorted.1 m hmtail
            omega
          · exact h
        exact ih hsorted.2
          (fun v hv => hodd v (List.mem_cons_of_mem _ hv)) m _ hmtail hm2tail

/-- The outer loop emits at most one stream per base index. -/
theorem length_outerRangeAux (lo hi : Nat) : ∀ (kb : Nat)
    (acc : List (List Nat)),
    (outerRangeAux lo hi kb acc).length ≤ kb + acc.length := by
  intro kb
  induction kb with
  | zero =>
    intro acc
    simp [outerRangeAux]
  | succ k ih =>
    intro acc
    rw [outerRangeAux]
    split
    · split
      · refine (ih _).trans ?_
        simp only [List.length_cons]
        omega
      · exact (ih _).trans (by omega)
    · exact (ih _).trans (by omega)

/-- Soundness of the chunk checker: a `true` run means the `expected` list
contains every odd powerful pair opening in `[lo, hi]`. The side conditions
are literal facts each certificate discharges by `decide`. -/
theorem checkChunk_sound {lo hi kb cnt : Nat} {exp : List Nat}
    (hlo : 1 ≤ lo) (hhi : hi + 2 < 2 ^ 64)
    (hkb : hi + 2 < (2 * kb + 1) * (2 * kb + 1) * (2 * kb + 1))
    (hkb40 : kb ≤ 2 ^ 40)
    (hcheck : checkChunk lo hi kb cnt exp = true) :
    ∀ m : Nat, Odd m → m.Powerful → (m + 2).Powerful →
      lo ≤ m → m + 2 ≤ hi + 2 → m ∈ exp := by
  intro m hodd hpow hpow2 h1 h2
  simp only [checkChunk, Bool.and_eq_true, beq_iff_eq] at hcheck
  obtain ⟨-, hscan⟩ := hcheck
  set L := oddPowerfulRange lo (hi + 2) kb with hL
  have houter : ∀ l ∈ outerRangeAux lo (hi + 2) kb [],
      ∃ b3 kLo c, Odd b3 ∧ l = genOddRangeAux b3 kLo c [] := by
    intro l hl
    rcases outerRangeAux_lists kb [] l hl with habs | hstream
    · cases habs
    · exact hstream
  have hsorted : L.Pairwise (· ≤ ·) := by
    refine sorted_mergeAll 40 _ ?_ ?_
    · have := length_outerRangeAux lo (hi + 2) kb []
      simp only [List.length_nil] at this
      calc (outerRangeAux lo (hi + 2) kb []).length ≤ kb + 0 := this
      _ ≤ 2 ^ 40 := by omega
    · intro l hl
      obtain ⟨b3, kLo, c, -, rfl⟩ := houter l hl
      exact stream_sorted b3 kLo c
  have hallodd : ∀ v ∈ L, Odd v := by
    intro v hv
    rw [hL, oddPowerfulRange, mem_mergeAll] at hv
    obtain ⟨l, hl, hvl⟩ := hv
    obtain ⟨b3, kLo, c, hb3, rfl⟩ := houter l hl
    exact stream_all_odd hb3 kLo c v hvl
  have hmem : ∀ v : Nat, Odd v → v.Powerful → lo ≤ v → v ≤ hi + 2 →
      v ∈ L := by
    intro v hv hvp hv1 hv2
    rw [hL, oddPowerfulRange, mem_mergeAll]
    exact mem_of_odd_powerful hlo hhi hkb hv hvp hv1 hv2
  have hmL : m ∈ L := hmem m hodd hpow h1 (by omega)
  have hm2L : m + 2 ∈ L := by
    refine hmem (m + 2) ?_ hpow2 (by omega) h2
    obtain ⟨j, hj⟩ := hodd
    exact ⟨j + 1, by omega⟩
  have hcaught : m ∈ scanGap2Aux L [] :=
    scanGap2Aux_catches L hsorted hallodd m [] hmL hm2L
  rw [← hscan]
  exact List.mem_reverse.mpr hcaught

end Erdos364.Spike
