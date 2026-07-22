/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Mod4
import Erdos364.Witness
import Erdos364.Tiling
import Erdos364.Sorted
import Erdos364.C12.Table

/-!
# Assembly for the 10^12 rung (proof plan step 7)

Composes the proof stack over the generated chunk table: the mod-4 lemma
forces a triple to open odd, the tiling places the opener in a chunk, the
chunk checker's soundness turns the verified Bool into membership in the
expected pair list, the table-level Bool checks confine those pairs to the
five known A076445 members below 10^12, and the witness kills finish. The
single hypothesis `hall` is discharged by `C12.all_chunks_pass` in
`Erdos364/Main.lean`, which imports the 320 chunk certificates; everything
in THIS file compiles without them.
-/

namespace Erdos364

open Spike

/-- The chunk table tiles `[1, 10^12]` exactly. -/
theorem tiles_1e12 :
    tiles 1000000000000 (C12.table.map fun e => (e.lo, e.hi)) = true := by
  decide +kernel

/-- Every table entry satisfies the literal side conditions. -/
theorem side_1e12 : C12.table.all ChunkSpec.side = true := by
  decide +kernel

/-- The five known pair openers below `10^12` (A076445 a(1)..a(5)). -/
def knownPairs : List Nat :=
  [25, 70225, 130576327, 189750625, 512706121225]

/-- Every expected pair in the table is one of the five known. -/
theorem exp_known_1e12 :
    C12.table.all (fun e => e.exp.all (fun m => knownPairs.contains m)) =
      true := by
  decide +kernel

/-- Each known pair's middle is not powerful. -/
theorem known_kills : ∀ m ∈ knownPairs, ¬ Nat.Powerful (m + 1) := by
  intro m hm
  simp only [knownPairs, List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl | rfl
  · exact not_powerful_26
  · exact not_powerful_70226
  · exact not_powerful_130576328
  · exact not_powerful_189750626
  · exact not_powerful_512706121226

/-- The headline for `X = 10^12`, conditional only on the chunk
certificates. -/
theorem no_powerful_triple_up_to_1e12_of
    (hall : ∀ e ∈ C12.table, ChunkSpec.check e = true) :
    ∀ n : ℕ, n + 2 ≤ 1000000000000 →
      ¬ (Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧ Nat.Powerful (n + 2)) := by
  rintro n hn ⟨h0, h1, h2⟩
  have hodd2 : n % 2 = 1 := odd_of_powerful_triple h0 h1 h2
  have hodd : Odd n := Nat.odd_iff.mpr hodd2
  have h1n : 1 ≤ n := by omega
  obtain ⟨p, hp, hp1, hp2⟩ :=
    mem_of_tiles tiles_1e12 h1n (show n ≤ 1000000000000 by omega)
  rw [List.mem_map] at hp
  obtain ⟨e, he, rfl⟩ := hp
  have hside := List.all_eq_true.mp side_1e12 e he
  simp only [ChunkSpec.side, Bool.and_eq_true, decide_eq_true_eq] at hside
  obtain ⟨⟨⟨hlo, hhi⟩, hkb⟩, hkb40⟩ := hside
  have hcheck : Spike.checkChunk e.lo e.hi e.kb e.cnt e.exp = true :=
    hall e he
  have hmexp : n ∈ e.exp :=
    checkChunk_sound hlo hhi hkb hkb40 hcheck n hodd h0 h2 hp1 (by omega)
  have hexp := List.all_eq_true.mp exp_known_1e12 e he
  have hknown : n ∈ knownPairs := by
    have := List.all_eq_true.mp hexp n (by simpa using hmexp)
    simpa [List.contains_iff_mem] using this
  exact known_kills n hknown h1

end Erdos364
