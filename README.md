# Optio

Kernel-certified verification work on Erdős problem 364: are there three
consecutive powerful numbers? (n is powerful when p | n implies p^2 | n.)
Erdős and, independently, Mollin and Walsh conjectured there are none.

## Status

Both ladder rungs are certified: X = 10^12 and X = 10^14. `Erdos364.no_powerful_triple_up_to_1e12`
(Erdos364/Main.lean) states there is no consecutive powerful triple with
n + 2 <= 10^12, and compiles with axioms exactly
{propext, Classical.choice, Quot.sound}, no sorry, no native_decide. The
proof composes 35 soundness lemmas over 320 kernel-checked chunk
certificates (Erdos364/C12/). See docs/ERDOS364_PROOF_PLAN.md for the
architecture and data/chunk_runs/cert_1e12_axioms.txt for the axiom record.

`Erdos364.no_powerful_triple_up_to_1e14` (Erdos364/Main14.lean) extends the
same claim to n + 2 <= 10^14 over 3,204 table-driven chunk certificates
(Erdos364/C14/), axioms identical, evidence in
data/chunk_runs/cert_1e14_axioms.txt. Next:
the CI gate, the formal-conjectures bridge, and publication.

## The claim under construction

For a bound X on the certificate ladder:

    theorem: for all n, n + 2 <= X, it is not the case that
             n, n + 1, n + 2 are all powerful

checked entirely by the Lean 4 kernel. Axioms are a subset of {propext,
Classical.choice, Quot.sound}; no native_decide, no sorry. The statement is
bridged to the `erdos_364` statement of google-deepmind/formal-conjectures
with the upstream commit pinned and the `Powerful` definition carried
verbatim.

## Two tiers, stated plainly

This is a certification result, not a computational record. Larger
uncertified computations exist and are cited here deliberately:

- Exhaustive to 10^22: Donovan Johnson's 2011 enumeration of consecutive
  powerful pairs (OEIS A060355 b-file). Uncertified, method undocumented.
- Conditionally to about 7.38 x 10^28: the 13 terms of OEIS A076445 (McCranie
  2002, Reynolds 2005, Noe 2006). Exhaustive only if that list is complete,
  which is not established; the OEIS entry itself was renamed in 2013 to
  avoid implying completeness.
- Known pairs to about 8.1 x 10^66: Alekseyev's conjectured extension of
  A076445 (2012), explicitly not known to be consecutive. None of the 33
  known pairs has a powerful middle.

The certified bound published here is far below all three. What it adds is
that every step, from the enumeration of powerful numbers to the mod-4
reduction to the non-powerfulness of each candidate middle, is checked by a
proof kernel rather than trusted contributor code.

## Layout

    Erdos364/   Lean 4 (toolchain 4.30.0, mathlib v4.30.0)
    engine/     Python scan and cross-validation (two implementations, one truth)
    scripts/    axiom gate and helpers
    docs/       program documents and measurements
    data/       append-only scan ledger and small OEIS reference copies

## License

Apache 2.0.
