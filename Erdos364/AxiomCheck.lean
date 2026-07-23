/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Mod4
import Erdos364.Witness
import Erdos364.Tiling
import Erdos364.Representation
import Erdos364.Generator
import Erdos364.Sorted
import Erdos364.BTable
import Erdos364.TableGen
import Erdos364.Assembly
import Erdos364.Assembly14
import Erdos364.Bridge

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

-- Step 3: generator soundness
#print axioms Erdos364.Spike.isqrtAux_correct
#print axioms Erdos364.Spike.isqrt_correct
#print axioms Erdos364.Spike.le_isqrt_iff
#print axioms Erdos364.Spike.sqfreeAux_eq_false_iff
#print axioms Erdos364.Spike.sqfreeAux_isqrt_iff
#print axioms Erdos364.Spike.mem_genOddRangeAux
#print axioms Erdos364.Spike.outerRangeAux_acc_mono
#print axioms Erdos364.Spike.stream_mem_outerRangeAux
#print axioms Erdos364.Spike.mem_of_odd_powerful

-- Step 4: merge and scan soundness
#print axioms Erdos364.Spike.stream_sorted
#print axioms Erdos364.Spike.stream_all_odd
#print axioms Erdos364.Spike.outerRangeAux_lists
#print axioms Erdos364.Spike.mem_mergeAux
#print axioms Erdos364.Spike.sorted_mergeAux
#print axioms Erdos364.Spike.mem_mergeRound
#print axioms Erdos364.Spike.sorted_mergeRound
#print axioms Erdos364.Spike.length_mergeRound
#print axioms Erdos364.Spike.mem_mergeAll
#print axioms Erdos364.Spike.sorted_mergeAll
#print axioms Erdos364.Spike.scanGap2Aux_acc_mono
#print axioms Erdos364.Spike.scanGap2Aux_catches
#print axioms Erdos364.Spike.length_outerRangeAux
#print axioms Erdos364.Spike.checkChunk_sound

-- Phase 5: the squarefree cube-base table and the table-driven checker
#print axioms Erdos364.Spike.mkBTableAux_acc_mono
#print axioms Erdos364.Spike.mem_mkBTableAux
#print axioms Erdos364.Spike.mem_mkBTable
#print axioms Erdos364.Spike.mkBTable_all_odd
#print axioms Erdos364.Spike.outerFromTable_acc_mono
#print axioms Erdos364.Spike.stream_mem_outerFromTable
#print axioms Erdos364.Spike.outerFromTable_lists
#print axioms Erdos364.Spike.length_outerFromTable
#print axioms Erdos364.Spike.mem_of_odd_powerful_T
#print axioms Erdos364.Spike.checkChunkT_sound

-- Steps 6 (10^14 extension) and 7: assembly layers and the bridge
#print axioms Erdos364.not_powerful_13837575261124
#print axioms Erdos364.not_powerful_99612037019890
#print axioms Erdos364.tiles_1e12
#print axioms Erdos364.side_1e12
#print axioms Erdos364.exp_known_1e12
#print axioms Erdos364.known_kills
#print axioms Erdos364.no_powerful_triple_up_to_1e12_of
#print axioms Erdos364.tiles_1e14
#print axioms Erdos364.side_1e14
#print axioms Erdos364.reach_1e14
#print axioms Erdos364.blen_1e14
#print axioms Erdos364.exp_known_1e14
#print axioms Erdos364.known_kills_14
#print axioms Erdos364.no_powerful_triple_up_to_1e14_of
#print axioms Erdos364.bounded_of_erdos364
#print axioms Erdos364.erdos364_false_of_witness
