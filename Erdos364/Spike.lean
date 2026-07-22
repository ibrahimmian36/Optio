/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/

/-!
# Phase 1 kernel-throughput spike (measurement only, no soundness claims yet)

Enumerates the odd powerful numbers `<= X` as `a^2 * b^3` (a, b odd, b
squarefree), merges the per-`b` ascending streams into one sorted list, and
scans adjacent entries for gaps of exactly `2`. The Bool checker compares the
resulting list length and gap-2 members against values computed independently
by the Python engine, so every spike run is also a cross-validation of the
two implementations.

Kernel discipline (centurion `Erdos7/Enumeration.lean` technique): no
`Nat.sqrt` or any well-founded recursion (they do not reduce in the kernel);
every loop is structural recursion on an explicit fuel argument in
accumulator style; the per-run cost is one closed Bool equality checked by
`decide`. `native_decide` is forbidden by the axiom gate.

Soundness lemmas (completeness of the enumeration, scanner correctness) are
Phase 2; this file only has to be honest about cost, and the checker's
agreement with the Python engine is enforced by the baked expected values.
-/

namespace Erdos364.Spike

/-- Fueled integer square root by binary search: with `lo^2 <= n < hi^2` the
result `r` satisfies `r^2 <= n < (r+1)^2` once the interval closes. Fuel `64`
suffices for every `n < 2^64`. Structural recursion on fuel; `Nat.sqrt` is
well-founded recursion and does not reduce in the kernel. -/
def isqrtAux (n : Nat) : Nat → Nat → Nat → Nat
  | 0, lo, _ => lo
  | fuel + 1, lo, hi =>
    let mid := (lo + hi) / 2
    if mid = lo then lo
    else if mid * mid ≤ n then isqrtAux n fuel mid hi
    else isqrtAux n fuel lo mid

/-- Integer square root with constant fuel `64`. -/
def isqrt (n : Nat) : Nat := isqrtAux n 64 0 (n + 1)

/-- Fueled squarefreeness test: no `d` with `2 <= d <= fuel` has `d^2 | b`.
Run with `fuel = isqrt b`. -/
def sqfreeAux (b : Nat) : Nat → Bool
  | 0 => true
  | d + 1 =>
    if d + 1 ≥ 2 && b % ((d + 1) * (d + 1)) == 0 then false
    else sqfreeAux b d

/-- The ascending stream `(2k-1)^2 * b3` for `k = 1, ..., fuel`, built by
prepending from the largest `k` down (accumulator style, constant pending
depth). -/
def genOddAux (b3 : Nat) : Nat → List Nat → List Nat
  | 0, acc => acc
  | k + 1, acc =>
    let a := 2 * k + 1
    genOddAux b3 k (a * a * b3 :: acc)

/-- One ascending stream per odd squarefree `b = 2k-1` with `b^3 <= X`,
`k = 1, ..., fuel`. Each stream holds every odd `a` with `a^2 b^3 <= X`. -/
def outerAux (X : Nat) : Nat → List (List Nat) → List (List Nat)
  | 0, acc => acc
  | k + 1, acc =>
    let b := 2 * k + 1
    let b3 := b * b * b
    outerAux X k
      (if b3 ≤ X && sqfreeAux b (isqrt b) then
        genOddAux b3 ((isqrt (X / b3) + 1) / 2) [] :: acc
      else acc)

/-- Fueled merge of two ascending lists, accumulator style. Run with
`fuel >= |xs| + |ys|`; the fuel-exhausted arm keeps the function total but is
never reached at the call sites below. -/
def mergeAux : Nat → List Nat → List Nat → List Nat → List Nat
  | 0, xs, ys, acc => List.reverseAux acc (xs ++ ys)
  | fuel + 1, xs, ys, acc =>
    match xs, ys with
    | [], _ => List.reverseAux acc ys
    | _, [] => List.reverseAux acc xs
    | x :: xs', y :: ys' =>
      if x ≤ y then mergeAux fuel xs' (y :: ys') (x :: acc)
      else mergeAux fuel (x :: xs') ys' (y :: acc)

/-- One round of pairwise merging: halves the number of streams. -/
def mergeRound : List (List Nat) → List (List Nat)
  | l1 :: l2 :: rest => mergeAux (l1.length + l2.length) l1 l2 [] :: mergeRound rest
  | ls => ls

/-- Balanced merging to a single ascending list. Fuel `40` covers `2^40`
streams. -/
def mergeAll : Nat → List (List Nat) → List Nat
  | 0, ls => ls.flatten
  | _ + 1, [] => []
  | _ + 1, [l] => l
  | fuel + 1, ls => mergeAll fuel (mergeRound ls)

/-- Collect every `m` whose successor entry in the ascending list is `m + 2`.
On the odd powerful list these are exactly the A076445 members `<= X`. -/
def scanGap2Aux : List Nat → List Nat → List Nat
  | x :: y :: rest, acc =>
    scanGap2Aux (y :: rest) (if x + 2 == y then x :: acc else acc)
  | _, acc => acc

/-- The sorted list of odd powerful numbers `<= X`; `kb` is the number of odd
candidate `b` values, `(cbrt X + 1) / 2`, baked by the run generator. -/
def oddPowerfulList (X kb : Nat) : List Nat :=
  mergeAll 40 (outerAux X kb [])

/-- The spike checker: the enumeration has the expected length and its gap-2
scan recovers exactly the expected pair members. Expected values come from
the Python engine, so a `true` result is a cross-implementation agreement. -/
def check (X kb count : Nat) (expected : List Nat) : Bool :=
  let l := oddPowerfulList X kb
  l.length == count && (scanGap2Aux l []).reverse == expected

end Erdos364.Spike
