/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Generator

/-!
# The squarefree cube-base table (phase 5, docs/PHASE5_BTABLE.md)

`mkBTable kbT` is the ascending list of odd `b ≤ 2*kbT - 1` surviving the
fueled squarefree test: exactly the cube bases the certified generator
admits, reified once per rung instead of retested per chunk. Soundness
needs two facts proved here: every odd squarefree `b` in range is a member
(completeness — the catastrophic direction if lost), and every member is
odd (feeds the adjacency argument). Member squarefreeness is a cost
concern, not a soundness need, and is not proved. The guard is written
without a `let` so `if_pos`/`split` see it (kernel-zeta lesson from
`outerRangeAux`).
-/

namespace Erdos364.Spike

/-- The fueled table constructor: `k + 1 ↦ b = 2k+1`, descending fuel,
prepending survivors, so the result is ascending. -/
def mkBTableAux : Nat → List Nat → List Nat
  | 0, acc => acc
  | k + 1, acc =>
    mkBTableAux k
      (if sqfreeAux (2 * k + 1) (isqrt (2 * k + 1)) then
        (2 * k + 1) :: acc
      else acc)

/-- The odd squarefree cube bases `b ≤ 2*kbT - 1`, ascending. -/
def mkBTable (kbT : Nat) : List Nat :=
  mkBTableAux kbT []

/-- Accumulated members survive the constructor. -/
theorem mkBTableAux_acc_mono : ∀ (k : Nat) (acc : List Nat) (v : Nat),
    v ∈ acc → v ∈ mkBTableAux k acc := by
  intro k
  induction k with
  | zero =>
    intro acc v h
    exact h
  | succ j ih =>
    intro acc v h
    rw [mkBTableAux]
    split
    · exact ih _ v (List.mem_cons_of_mem _ h)
    · exact ih _ v h

/-- Index form of completeness: the survivor at slot `j` is a member, for
any accumulator. -/
theorem mem_mkBTableAux {j : Nat} : ∀ (kbT : Nat), j < kbT →
    sqfreeAux (2 * j + 1) (isqrt (2 * j + 1)) = true →
    ∀ acc, (2 * j + 1) ∈ mkBTableAux kbT acc := by
  intro kbT
  induction kbT with
  | zero =>
    intro h
    omega
  | succ k ih =>
    intro hj hguard acc
    rw [mkBTableAux]
    rcases Nat.lt_or_ge j k with hlt | hge
    · split
      · exact ih hlt hguard _
      · exact ih hlt hguard _
    · have hkeq : j = k := by omega
      subst hkeq
      rw [if_pos hguard]
      exact mkBTableAux_acc_mono j _ _ List.mem_cons_self

/-- Completeness: every odd squarefree `b ≤ 2*kbT - 1` is in the table.
The `2^64` bound feeds the exactness of the fueled squarefree test. -/
theorem mem_mkBTable {b kbT : Nat} (hodd : Odd b) (hsf : Squarefree b)
    (hle : b ≤ 2 * kbT - 1) (h64 : b < 2 ^ 64) :
    b ∈ mkBTable kbT := by
  obtain ⟨j, hj⟩ := hodd
  have hb0 : b ≠ 0 := by omega
  have hjk : j < kbT := by omega
  subst hj
  exact mem_mkBTableAux kbT hjk
    ((sqfreeAux_isqrt_iff hb0 h64).mpr hsf) []

/-- Every table member is odd. -/
theorem mkBTableAux_all_odd : ∀ (k : Nat) (acc : List Nat),
    (∀ v ∈ acc, Odd v) → ∀ v ∈ mkBTableAux k acc, Odd v := by
  intro k
  induction k with
  | zero =>
    intro acc hacc v hv
    exact hacc v hv
  | succ j ih =>
    intro acc hacc v hv
    rw [mkBTableAux] at hv
    refine ih _ ?_ v hv
    intro w hw
    split at hw
    · rcases List.mem_cons.mp hw with rfl | hw'
      · exact ⟨j, by ring⟩
      · exact hacc w hw'
    · exact hacc w hw

/-- Every rung-table member is odd. -/
theorem mkBTable_all_odd (kbT : Nat) : ∀ v ∈ mkBTable kbT, Odd v :=
  mkBTableAux_all_odd kbT [] (by simp)

end Erdos364.Spike
