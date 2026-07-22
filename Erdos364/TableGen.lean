/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.BTable
import Erdos364.Sorted

/-!
# The table-driven generator and its soundness (phase 5)

`outerFromTable` walks a literal list of cube bases instead of testing
every odd candidate, deleting the per-chunk squarefree sweep the
attribution measured at ~95% of generation. The soundness stack mirrors
`Generator.lean`/`Sorted.lean` with list induction in place of fuel
induction; the merge and scan lemmas are reused unchanged. The certified
`checkChunk` path is untouched.
-/

namespace Erdos364.Spike

/-- The generator over an explicit base list: one ascending stream per
`b ∈ bs` whose cube reaches the window. No squarefree test here — the
table is trusted for cost and verified for completeness/oddness where the
soundness lemmas need it. -/
def outerFromTable (lo hi : Nat) : List Nat → List (List Nat) →
    List (List Nat)
  | [], acc => acc
  | b :: bs, acc =>
    outerFromTable lo hi bs
      (if b * b * b ≤ hi then
        (if (isqrt ((lo - 1) / (b * b * b)) + 1) / 2 <
            (isqrt (hi / (b * b * b)) + 1) / 2 then
          genOddRangeAux (b * b * b)
            ((isqrt ((lo - 1) / (b * b * b)) + 1) / 2)
            ((isqrt (hi / (b * b * b)) + 1) / 2 -
              (isqrt ((lo - 1) / (b * b * b)) + 1) / 2)
            [] :: acc
        else acc)
      else acc)

/-- Sorted odd powerful candidates in `[lo, hi]` from the base list. -/
def oddPowerfulRangeT (lo hi : Nat) (bs : List Nat) : List Nat :=
  mergeAll 40 (outerFromTable lo hi bs [])

/-- The table-driven chunk checker: same window and `+2` overlap semantics
as `checkChunk`. -/
def checkChunkT (lo hi cnt : Nat) (bs exp : List Nat) : Bool :=
  (oddPowerfulRangeT lo (hi + 2) bs).length == cnt &&
    (scanGap2Aux (oddPowerfulRangeT lo (hi + 2) bs) []).reverse == exp

/-- Accumulated lists survive the walk. -/
theorem outerFromTable_acc_mono (lo hi : Nat) : ∀ (bs : List Nat)
    (acc : List (List Nat)) (l : List Nat), l ∈ acc →
    l ∈ outerFromTable lo hi bs acc := by
  intro bs
  induction bs with
  | nil =>
    intro acc l h
    exact h
  | cons b rest ih =>
    intro acc l h
    rw [outerFromTable]
    split
    · split
      · exact ih _ _ (List.mem_cons_of_mem _ h)
      · exact ih _ _ h
    · exact ih _ _ h

/-- The stream for a listed base is among the walk's lists when its guards
pass. -/
theorem stream_mem_outerFromTable (lo hi : Nat) : ∀ (bs : List Nat)
    (b : Nat), b ∈ bs →
    b * b * b ≤ hi →
    (isqrt ((lo - 1) / (b * b * b)) + 1) / 2 <
      (isqrt (hi / (b * b * b)) + 1) / 2 →
    ∀ acc, genOddRangeAux (b * b * b)
        ((isqrt ((lo - 1) / (b * b * b)) + 1) / 2)
        ((isqrt (hi / (b * b * b)) + 1) / 2 -
          (isqrt ((lo - 1) / (b * b * b)) + 1) / 2)
        [] ∈ outerFromTable lo hi bs acc := by
  intro bs
  induction bs with
  | nil =>
    intro b hb
    cases hb
  | cons c rest ih =>
    intro b hb hb3 hst acc
    rw [outerFromTable]
    rcases List.mem_cons.mp hb with rfl | hb'
    · rw [if_pos (by simpa using hb3), if_pos (by simpa using hst)]
      exact outerFromTable_acc_mono lo hi _ _ _ List.mem_cons_self
    · split
      · split
        · exact ih b hb' hb3 hst _
        · exact ih b hb' hb3 hst _
      · exact ih b hb' hb3 hst _

/-- Every list the walk emits over an empty accumulator is a stream with
an odd cube base, provided the table is all-odd. -/
theorem outerFromTable_lists {lo hi : Nat} : ∀ (bs : List Nat),
    (∀ b ∈ bs, Odd b) → ∀ (acc : List (List Nat)) (l : List Nat),
    l ∈ outerFromTable lo hi bs acc →
    l ∈ acc ∨ ∃ b3 kLo cnt, Odd b3 ∧ l = genOddRangeAux b3 kLo cnt [] := by
  intro bs
  induction bs with
  | nil =>
    intro _ acc l h
    exact Or.inl h
  | cons b rest ih =>
    intro hbs acc l h
    rw [outerFromTable] at h
    rcases ih (fun c hc => hbs c (List.mem_cons_of_mem _ hc)) _ _ h with
      hacc | hstream
    · split at hacc
      · split at hacc
        · rcases List.mem_cons.mp hacc with heq | htail
          · have hb : Odd b := hbs b List.mem_cons_self
            exact Or.inr ⟨b * b * b, _, _, (hb.mul hb).mul hb, heq⟩
          · exact Or.inl htail
        · exact Or.inl hacc
      · exact Or.inl hacc
    · exact Or.inr hstream

/-- The walk emits at most one stream per listed base. -/
theorem length_outerFromTable (lo hi : Nat) : ∀ (bs : List Nat)
    (acc : List (List Nat)),
    (outerFromTable lo hi bs acc).length ≤ bs.length + acc.length := by
  intro bs
  induction bs with
  | nil =>
    intro acc
    simp [outerFromTable]
  | cons b rest ih =>
    intro acc
    rw [outerFromTable]
    split
    · split
      · refine (ih _).trans ?_
        simp only [List.length_cons]
        omega
      · exact (ih _).trans (by simp)
    · exact (ih _).trans (by simp)

/-- Cover: every odd powerful number in `[lo, hi]` lands in a stream of
the walk, provided the table contains every odd squarefree base whose cube
reaches the window. -/
theorem mem_of_odd_powerful_T {lo hi m : Nat} {bs : List Nat}
    (hlo : 1 ≤ lo) (hhi : hi < 2 ^ 64)
    (hcover : ∀ b, Odd b → Squarefree b → b * b * b ≤ hi → b ∈ bs)
    (hodd : Odd m) (hpow : m.Powerful) (h1 : lo ≤ m) (h2 : m ≤ hi) :
    ∃ l ∈ outerFromTable lo hi bs [], m ∈ l := by
  obtain ⟨a, b, haodd, hbodd, hbsf, hm⟩ :=
    Erdos364.exists_odd_sq_mul_cube hpow hodd
  obtain ⟨j, hj⟩ := haodd
  have ha1 : 1 ≤ a := by omega
  have hb1 : 1 ≤ b := by
    obtain ⟨k, hk⟩ := hbodd
    omega
  have hb3 : b * b * b ≤ hi := by
    calc b * b * b = b ^ 3 := by ring
    _ ≤ a ^ 2 * b ^ 3 := Nat.le_mul_of_pos_left _ (pow_pos (by omega) 2)
    _ = m := hm.symm
    _ ≤ hi := h2
  have hmem : b ∈ bs := hcover b hbodd hbsf hb3
  set b3 := b * b * b with hb3def
  have hb3pos : 0 < b3 := by positivity
  have hmab : m = a * a * b3 := by
    rw [hm, hb3def]
    ring
  have hq64 : hi / b3 < 2 ^ 64 := lt_of_le_of_lt (Nat.div_le_self _ _) hhi
  have hl64 : (lo - 1) / b3 < 2 ^ 64 :=
    lt_of_le_of_lt (Nat.div_le_self _ _) (by omega)
  have haup : a ≤ isqrt (hi / b3) := by
    rw [le_isqrt_iff hq64]
    rw [Nat.le_div_iff_mul_le hb3pos]
    calc a * a * b3 = m := hmab.symm
    _ ≤ hi := h2
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
  have hskip : (isqrt ((lo - 1) / b3) + 1) / 2 ≤ j := by omega
  have htot : j < (isqrt (hi / b3) + 1) / 2 := by omega
  refine ⟨_, stream_mem_outerFromTable lo hi bs b hmem
    (by rw [← hb3def]; exact hb3) (by rw [← hb3def]; omega) [], ?_⟩
  rw [mem_genOddRangeAux]
  refine Or.inl ⟨j - (isqrt ((lo - 1) / (b * b * b)) + 1) / 2, ?_, ?_⟩
  · rw [← hb3def]
    omega
  · rw [← hb3def]
    have hja : 2 * ((isqrt ((lo - 1) / b3) + 1) / 2 +
        (j - (isqrt ((lo - 1) / b3) + 1) / 2)) + 1 = a := by omega
    rw [hja]
    exact hmab

/-- Soundness of the table-driven chunk checker. -/
theorem checkChunkT_sound {lo hi cnt : Nat} {bs exp : List Nat}
    (hlo : 1 ≤ lo) (hhi : hi + 2 < 2 ^ 64)
    (hballodd : ∀ b ∈ bs, Odd b)
    (hcover : ∀ b, Odd b → Squarefree b → b * b * b ≤ hi + 2 → b ∈ bs)
    (hblen : bs.length ≤ 2 ^ 40)
    (hcheck : checkChunkT lo hi cnt bs exp = true) :
    ∀ m : Nat, Odd m → m.Powerful → (m + 2).Powerful →
      lo ≤ m → m + 2 ≤ hi + 2 → m ∈ exp := by
  intro m hodd hpow hpow2 h1 h2
  simp only [checkChunkT, Bool.and_eq_true, beq_iff_eq] at hcheck
  obtain ⟨-, hscan⟩ := hcheck
  set L := oddPowerfulRangeT lo (hi + 2) bs with hL
  have houter : ∀ l ∈ outerFromTable lo (hi + 2) bs [],
      ∃ b3 kLo c, Odd b3 ∧ l = genOddRangeAux b3 kLo c [] := by
    intro l hl
    rcases outerFromTable_lists bs hballodd [] l hl with habs | hstream
    · cases habs
    · exact hstream
  have hsorted : L.Pairwise (· ≤ ·) := by
    refine sorted_mergeAll 40 _ ?_ ?_
    · have := length_outerFromTable lo (hi + 2) bs []
      simp only [List.length_nil] at this
      calc (outerFromTable lo (hi + 2) bs []).length ≤ bs.length + 0 :=
            this
      _ ≤ 2 ^ 40 := by omega
    · intro l hl
      obtain ⟨b3, kLo, c, -, rfl⟩ := houter l hl
      exact stream_sorted b3 kLo c
  have hallodd : ∀ v ∈ L, Odd v := by
    intro v hv
    rw [hL, oddPowerfulRangeT, mem_mergeAll] at hv
    obtain ⟨l, hl, hvl⟩ := hv
    obtain ⟨b3, kLo, c, hb3, rfl⟩ := houter l hl
    exact stream_all_odd hb3 kLo c v hvl
  have hmem : ∀ v : Nat, Odd v → v.Powerful → lo ≤ v → v ≤ hi + 2 →
      v ∈ L := by
    intro v hv hvp hv1 hv2
    rw [hL, oddPowerfulRangeT, mem_mergeAll]
    exact mem_of_odd_powerful_T hlo hhi hcover hv hvp hv1 hv2
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
