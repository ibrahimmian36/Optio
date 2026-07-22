/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Spike

/-!
# Cost-attribution variants (docs/COST_ATTRIBUTION.md; measurement only)

Instrumentation for timing the checker's stages in isolation. Nothing here
is part of the certificate: the library root does not import this module,
no theorem below claims correctness, and the runner assertions are Nat
equalities against values mirrored independently in Python
(scripts/attrib_mirror.py). `sumLens` reuses the real generator verbatim;
`outerNoSqfreeCount` is the generator with the squarefree guard removed
(deliberately wrong as a certificate, useful only as a timing foil);
`isqrtProbe` runs just the per-b integer square roots.
-/

namespace Erdos364.CostAttrib

open Erdos364.Spike

/-- Total entries across the real generator's streams: times generation
(sqfree + isqrt + stream building) without merge or scan. -/
def sumLens (lo hi kb : Nat) : Nat :=
  (outerRangeAux lo hi kb []).foldl (fun acc l => acc + l.length) 0

/-- The generator with the squarefree guard removed: builds streams for
every odd `b` (deliberately wrong as a certificate), so the delta against
the real generator is the sqfree-test cost minus the extra stream cells,
which the mirror accounts for. -/
def outerNoSqfreeAux (lo hi : Nat) : Nat → List (List Nat) →
    List (List Nat)
  | 0, acc => acc
  | k + 1, acc =>
    let b := 2 * k + 1
    let b3 := b * b * b
    outerNoSqfreeAux lo hi k
      (if b3 ≤ hi then
        (if (isqrt ((lo - 1) / b3) + 1) / 2 < (isqrt (hi / b3) + 1) / 2 then
          genOddRangeAux b3 ((isqrt ((lo - 1) / b3) + 1) / 2)
            ((isqrt (hi / b3) + 1) / 2 - (isqrt ((lo - 1) / b3) + 1) / 2)
            [] :: acc
        else acc)
      else acc)

/-- Entry count across the no-sqfree streams. -/
def noSqfreeCount (lo hi kb : Nat) : Nat :=
  (outerNoSqfreeAux lo hi kb []).foldl (fun acc l => acc + l.length) 0

/-- Just the two per-b integer square roots, summed: times `isqrt` alone
(plus the divisions). -/
def isqrtProbe (lo hi : Nat) : Nat → Nat → Nat
  | 0, acc => acc
  | k + 1, acc =>
    let b := 2 * k + 1
    let b3 := b * b * b
    isqrtProbe lo hi k
      (if b3 ≤ hi then acc + isqrt (hi / b3) + isqrt ((lo - 1) / b3)
      else acc)

end Erdos364.CostAttrib
