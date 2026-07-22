/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Defs

/-!
# Chunk tiling (proof plan step 5)

The certificate splits `[1, X]` into chunks `[lo_i, hi_i]`. One Bool fold
checks the boundary table is an exact tiling: the first chunk starts at `1`,
each chunk starts where its predecessor ended plus one, and the last ends at
`X`. The covering lemma then places every `m ≤ X` in some chunk, so a pair
`(m, m+2)` with `m + 2 ≤ X` lands in the window `[lo_i, hi_i + 2]` of the
chunk owning `m`. Plain structural inductions; only the rcases tactic module
is imported.
-/

namespace Erdos364

/-- `tilesFrom lo bs X`: the ranges in `bs` tile `[lo, X]` exactly, in
order. -/
def tilesFrom : Nat → List (Nat × Nat) → Nat → Bool
  | lo, [], X => lo == X + 1
  | lo, (l, h) :: rest, X => l == lo && lo ≤ h && tilesFrom (h + 1) rest X

/-- The boundary table tiles `[1, X]`. -/
def tiles (X : Nat) (bs : List (Nat × Nat)) : Bool :=
  tilesFrom 1 bs X

/-- Covering, general form: a verified tiling of `[lo, X]` owns every `m`
with `lo ≤ m ≤ X`. -/
theorem mem_of_tilesFrom {bs : List (Nat × Nat)} {lo X m : Nat}
    (ht : tilesFrom lo bs X = true) (hlo : lo ≤ m) (hX : m ≤ X) :
    ∃ p ∈ bs, p.1 ≤ m ∧ m ≤ p.2 := by
  induction bs generalizing lo with
  | nil =>
    simp only [tilesFrom, beq_iff_eq] at ht
    omega
  | cons head rest ih =>
    obtain ⟨l, h⟩ := head
    simp only [tilesFrom, Bool.and_eq_true, beq_iff_eq,
      decide_eq_true_eq] at ht
    obtain ⟨⟨hl, hlh⟩, hrest⟩ := ht
    by_cases hm : m ≤ h
    · exact ⟨(l, h), List.Mem.head _, by omega, hm⟩
    · obtain ⟨p, hp, hp1, hp2⟩ := ih hrest (by omega)
      exact ⟨p, List.Mem.tail _ hp, hp1, hp2⟩

/-- Covering: a verified tiling of `[1, X]` owns every `1 ≤ m ≤ X`. -/
theorem mem_of_tiles {bs : List (Nat × Nat)} {X m : Nat}
    (ht : tiles X bs = true) (h1 : 1 ≤ m) (hX : m ≤ X) :
    ∃ p ∈ bs, p.1 ≤ m ∧ m ≤ p.2 :=
  mem_of_tilesFrom ht h1 hX

end Erdos364
