/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Assembly
import Erdos364.Assembly14

/-!
# The bridge to google-deepmind/formal-conjectures (proof plan step 9)

Erdős problem 364 (also Mollin–Walsh): are there three consecutive
powerful numbers? The upstream formal statement lives in
`FormalConjectures/ErdosProblems/364.lean` at commit
`e923379e609b9d5987011a1d1f06ec22ea25cd20` (2026-07-21):

    theorem erdos_364 :
        ¬ ∃ (n : ℕ), Powerful n ∧ Powerful (n + 1) ∧ Powerful (n + 2)

with `Powerful` defined in
`FormalConjecturesForMathlib/Data/Nat/Full.lean` as

    def Full (k : ℕ) (n : ℕ) : Prop := ∀ p ∈ n.primeFactors, p^k ∣ n
    abbrev Powerful : ℕ → Prop := (2).Full

Our `Erdos364/Defs.lean` carries those two definitions byte-identically
(up to the removal of upstream's module-system markers), so every theorem
in this repository speaks upstream's exact vocabulary; there is no
translation layer to trust.

This library proves the BOUNDED forms:

    Erdos364.no_powerful_triple_up_to_1e12  (Erdos364/Main.lean)
    Erdos364.no_powerful_triple_up_to_1e14  (Erdos364/Main14.lean)

with axioms exactly `{propext, Classical.choice, Quot.sound}` (committed
records in `data/chunk_runs/`). Those modules import thousands of chunk
certificates and build on a large-memory machine; this file deliberately
does not import them. What it adds is the statement-level relationship,
proved abstractly: the upstream conjecture implies every bounded form, so
the bounded theorems are exactly finite fragments of `erdos_364` — the
same claim, restricted, in the same words.
-/

namespace Erdos364

/-- The upstream conjecture restricted to any bound: `erdos_364` (were it
proved) implies each of our bounded theorems. This pins the statement
correspondence with no room for drift. -/
theorem bounded_of_erdos364
    (h : ¬ ∃ n : ℕ, Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧
      Nat.Powerful (n + 2)) (X : ℕ) :
    ∀ n : ℕ, n + 2 ≤ X →
      ¬ (Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧ Nat.Powerful (n + 2)) :=
  fun n _ hn => h ⟨n, hn⟩

/-- The contrapositive shape: a witness below any bound would refute the
conjecture outright. This is the direction a hypothetical HIT would
travel. -/
theorem erdos364_false_of_witness {X n : ℕ} (_ : n + 2 ≤ X)
    (hn : Nat.Powerful n ∧ Nat.Powerful (n + 1) ∧ Nat.Powerful (n + 2)) :
    ∃ m : ℕ, Nat.Powerful m ∧ Nat.Powerful (m + 1) ∧
      Nat.Powerful (m + 2) :=
  ⟨n, hn⟩

end Erdos364
