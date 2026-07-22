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

end Erdos364.Spike
