/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Mod4
import Erdos364.Witness
import Erdos364.Tiling
import Erdos364.Representation

/-! Publication gate manifest: every published theorem, `#print axioms`-ed
for the record. Every entry must depend on at most
`[propext, Classical.choice, Quot.sound]`: no `sorryAx`, no `_native.*`.
Grows with each proof-plan step; the mechanical whole-library audit is the
second gate layer (Phase 2 step 8). -/

-- Step 1: the mod-4 reduction
#print axioms Erdos364.not_powerful_of_two_mod_four
#print axioms Erdos364.odd_of_powerful_triple

-- Step 6: witnesses
#print axioms Erdos364.not_powerful_of_witness
#print axioms Erdos364.not_powerful_26
#print axioms Erdos364.not_powerful_70226
#print axioms Erdos364.not_powerful_130576328
#print axioms Erdos364.not_powerful_189750626
#print axioms Erdos364.not_powerful_512706121226

-- Step 5: tiling
#print axioms Erdos364.mem_of_tilesFrom
#print axioms Erdos364.mem_of_tiles

-- Step 2: representation
#print axioms Erdos364.odd_of_dvd_odd
#print axioms Erdos364.exists_odd_sq_mul_cube
