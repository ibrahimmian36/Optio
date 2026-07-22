/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Mathlib.Data.Nat.PrimeFin

/-!
# The `Powerful` predicate, carried verbatim from formal-conjectures

Erdős problem 364 asks whether three consecutive powerful numbers exist. The
formal statement we bridge to lives in google-deepmind/formal-conjectures,
`FormalConjectures/ErdosProblems/364.lean`, and its `Powerful` predicate is
defined in `FormalConjecturesForMathlib/Data/Nat/Full.lean` (not in mathlib).

Pinned upstream commit: e923379e609b9d5987011a1d1f06ec22ea25cd20 (2026-07-21).
The two definitions below are byte-identical to upstream up to the removal of
the new module-system markers (`public`, `@[expose]`) that upstream's file
carries and our classic file layout does not need. Conventions inherited with
the definition: `0` and `1` are both `Powerful` (their `primeFactors` is
empty). This is harmless for the triple statement because `2` is not powerful.
-/

namespace Nat

/-- `n` is `k`-full: every prime that divides `n` does so at least `k` times. -/
def Full (k : ℕ) (n : ℕ) : Prop := ∀ p ∈ n.primeFactors, p^k ∣ n

/-- A powerful number: every prime in `n` appears squared. This is `2`-full. -/
abbrev Powerful : ℕ → Prop := (2).Full

instance (k n : ℕ) : Decidable (Nat.Full k n) := by
  unfold Nat.Full
  infer_instance

end Nat
