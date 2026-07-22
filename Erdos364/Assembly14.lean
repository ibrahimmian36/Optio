/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Mod4
import Erdos364.Witness
import Erdos364.Tiling
import Erdos364.TableGen
import Erdos364.BTableData1e14
import Erdos364.C14.Table

/-!
# Assembly for the 10^14 rung

The table-driven analogue of `Assembly.lean`: mod-4 opener, tiling
placement, `checkChunkT_sound`, confinement to the seven known A076445
members below `10^14`, witness kills. Conditional on exactly two kernel
facts discharged in `Erdos364/Main14.lean`: the rung table equals
`mkBTable 23208`, and every chunk certificate checks.
-/

namespace Erdos364

open Spike

/-- The chunk table tiles `[1, 10^14]` exactly. -/
theorem tiles_1e14 :
    tiles 100000000000000 (C14.table.map fun e => (e.lo, e.hi)) = true := by
  decide +kernel

/-- Window bounds for every chunk: `1 ≤ lo` and `hi + 2 < 2^64`. -/
theorem side_1e14 :
    C14.table.all
      (fun e => decide (1 ≤ e.lo) && decide (e.hi + 2 < 2 ^ 64)) = true := by
  decide +kernel

/-- Every window stays below the table's cube reach:
`hi + 2 < (2*23208+1)^3`. -/
theorem reach_1e14 :
    C14.table.all
      (fun e => decide (e.hi + 2 <
        (2 * 23208 + 1) * (2 * 23208 + 1) * (2 * 23208 + 1))) = true := by
  decide +kernel

/-- The rung table is within the length bound the sort needs. -/
theorem blen_1e14 : bTable1e14.length ≤ 2 ^ 40 := by
  decide +kernel

/-- The seven known pair openers below `10^14` (A076445 a(1)..a(7)). -/
def knownPairs14 : List Nat :=
  [25, 70225, 130576327, 189750625, 512706121225, 13837575261123,
    99612037019889]

/-- Every expected pair in the table is one of the seven known. -/
theorem exp_known_1e14 :
    C14.table.all (fun e => e.exp.all (fun m => knownPairs14.contains m)) =
      true := by
  decide +kernel

/-- Each known pair's middle is not powerful. -/
theorem known_kills_14 : ∀ m ∈ knownPairs14, ¬ Nat.Powerful (m + 1) := by
  intro m hm
  simp only [knownPairs14, List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact not_powerful_26
  · exact not_powerful_70226
  · exact not_powerful_130576328
  · exact not_powerful_189750626
  · exact not_powerful_512706121226
  · exact not_powerful_13837575261124
  · exact not_powerful_99612037019890

/-- The headline for `X = 10^14`, conditional on the two pod-discharged
kernel facts. -/
theorem no_powerful_triple_up_to_1e14_of
    (htable : bTable1e14 = mkBTable 23208)
    (hall : ∀ e ∈ C14.table,
      Spike.checkChunkT e.lo e.hi e.cnt bTable1e14 e.exp = true) :
    ∀ n : ℕ, n + 2 ≤ 100000000000000 →
      ¬ (Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧ Nat.Powerful (n + 2)) := by
  rintro n hn ⟨h0, h1, h2⟩
  have hodd2 : n % 2 = 1 := odd_of_powerful_triple h0 h1 h2
  have hodd : Odd n := Nat.odd_iff.mpr hodd2
  have h1n : 1 ≤ n := by omega
  obtain ⟨p, hp, hp1, hp2⟩ :=
    mem_of_tiles tiles_1e14 h1n (show n ≤ 100000000000000 by omega)
  rw [List.mem_map] at hp
  obtain ⟨e, he, rfl⟩ := hp
  have hside := List.all_eq_true.mp side_1e14 e he
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hside
  obtain ⟨hlo, hhi⟩ := hside
  have hreach := List.all_eq_true.mp reach_1e14 e he
  simp only [decide_eq_true_eq] at hreach
  have hballodd : ∀ b ∈ bTable1e14, Odd b := by
    rw [htable]
    exact mkBTable_all_odd 23208
  have hcover : ∀ b, Odd b → Squarefree b → b * b * b ≤ e.hi + 2 →
      b ∈ bTable1e14 := by
    intro b hbo hbsf hb3
    obtain ⟨k, hk⟩ := id hbo
    have hb1 : 1 ≤ b := by omega
    have hble : b ≤ 2 * 23208 - 1 := by
      by_contra hcon
      push_neg at hcon
      have hge : 2 * 23208 + 1 ≤ b := by omega
      have hcube := Nat.mul_le_mul (Nat.mul_le_mul hge hge) hge
      norm_num at hcube hreach
      omega
    have hb64 : b < 2 ^ 64 := by
      have hbb : b ≤ b * b * b := by
        calc b = 1 * 1 * b := by ring
        _ ≤ b * b * b := Nat.mul_le_mul (Nat.mul_le_mul hb1 hb1) (le_refl b)
      omega
    rw [htable]
    exact mem_mkBTable hbo hbsf hble hb64
  have hcheck := hall e he
  have hmexp : n ∈ e.exp :=
    checkChunkT_sound hlo hhi hballodd hcover blen_1e14 hcheck n hodd h0 h2
      hp1 (by omega)
  have hexp := List.all_eq_true.mp exp_known_1e14 e he
  have hknown : n ∈ knownPairs14 := by
    have := List.all_eq_true.mp hexp n (by simpa using hmexp)
    simpa [List.contains_iff_mem] using this
  exact known_kills_14 n hknown h1

end Erdos364
