# Optio

Kernel-certified verification for Erdős problem 364: are there three
consecutive powerful numbers? (`n` is powerful when `p | n` implies
`p^2 | n`.) Erdős [Er76d] and, independently, Mollin and Walsh [MoWa86]
conjectured there are none; the abc conjecture implies at most finitely
many. The conjecture is open. This repository does not solve it. What it
contains is the first verification of the conjecture at any finite bound
that is checked end to end by a proof kernel.

## The certified results

    theorem Erdos364.no_powerful_triple_up_to_1e12 :
        ∀ n : ℕ, n + 2 ≤ 10^12 →
          ¬ (Powerful n ∧ Powerful (n+1) ∧ Powerful (n+2))

    theorem Erdos364.no_powerful_triple_up_to_1e14 :
        ∀ n : ℕ, n + 2 ≤ 10^14 →
          ¬ (Powerful n ∧ Powerful (n+1) ∧ Powerful (n+2))

Both compile in Lean 4.30.0 / mathlib v4.30.0 with axioms exactly
`{propext, Classical.choice, Quot.sound}`: no `sorry`, no `native_decide`,
no extra axioms. `Powerful` is carried byte-identically from
google-deepmind/formal-conjectures (commit `e923379e6`, pinned in
`Erdos364/Bridge.lean`), so the theorems speak the upstream statement's
exact vocabulary; `Bridge.lean` also proves abstractly that the upstream
conjecture implies each bounded form.

## Two tiers, stated plainly

This is a certification result, not a computational record. Larger
uncertified computations exist and are cited deliberately:

- Exhaustive to 10^22: Donovan Johnson's 2011 enumeration of consecutive
  powerful pairs (OEIS A060355 b-file). Uncertified, method undocumented.
- Conditionally to about 7.38 x 10^28: the 13 terms of OEIS A076445
  (McCranie 2002, Reynolds 2005, Noe 2006). Exhaustive only if that list
  is complete, which is not established; the OEIS entry was renamed in
  2013 specifically to avoid implying completeness.
- Known pairs to about 8.1 x 10^66: Alekseyev's conjectured extension of
  A076445 (2012), explicitly not known to be consecutive. None of the 33
  known pairs has a powerful middle.

What this repository adds is that every step below 10^14 — the
enumeration of powerful numbers, the mod-4 reduction, the location of
every pair at distance 2, and the non-powerfulness of each candidate
middle — is checked by the Lean kernel rather than trusted contributor
code.

## Proof architecture

A triple of consecutive powerful numbers must open odd (one of any four
consecutive integers is 2 mod 4). Every odd powerful number is a^2 b^3
with a, b odd and b squarefree, so a fueled kernel generator enumerates
the odd powerful numbers of an interval completely; merging keeps the
list sorted and all-odd, so two members at distance 2 must sit adjacent
and a linear scan provably catches every such pair; the intervals tile
[1, X] with overlap 2, so no pair escapes at a boundary; and each of the
seven pairs found (the A076445 members: 25, 70225, 130576327, 189750625,
512706121225, 13837575261123, 99612037019889) has its middle killed by an
explicit witness prime. The per-interval computations are 320 chunk
certificates at 10^12 (`Erdos364/C12/`) and 3,204 table-driven
certificates at 10^14 (`Erdos364/C14/`), each one a single Bool equality
the kernel evaluates; expected values are computed independently by the
Python engine (`engine/`), so every green certificate doubles as a
cross-implementation agreement. `docs/ERDOS364_PROOF_PLAN.md` has the
full lemma-level map.

## Verifying it yourself

The soundness library (every lemma through the conditional headline
theorems) builds on an ordinary machine:

    lake exe cache get && lake build && scripts/axiom_gate.sh

The gate checks a 61-theorem curated manifest, a mechanical 260-theorem
whole-library audit, and the committed certificate records, and CI runs
it on every push. The certificate modules themselves (`C12`, `C14`,
`Main`, `Main14`) need roughly 46 CPU-hours (16 at 10^12, 30 at 10^14);
per-chunk memory peaks in the committed logs reach 7.9 GB, and the
one-time 10^14 table verification wants tens of GB free, so
`scripts/pod_final14.sh` reproduces the 10^14 build on a 64 GB machine.
Their `#print axioms` outputs are committed at
`data/chunk_runs/cert_1e12_axioms.txt` and `cert_1e14_axioms.txt`, with
build and batch logs alongside. Note that the committed build logs end at
the failed attempts the run ledger describes (a detached `set_option` and
a heartbeat abort, both diagnosed there); the axiom records are the
outputs of the subsequent clean builds. The Lean sources of the certified closure
are frozen as attested (cosmetic lint cleanups deliberately not applied);
the run ledger in `docs/PHASE2_LOG.md` records every failure hit on the
way, including two reporting bugs found and fixed in our own harness.
Two known docstring slips are preserved by that freeze rather than
edited: `Main.lean` suggests a `-j6` flag that this Lake version spells
`--jobs 6`, and `Tiling.lean` carries a stale remark about its imports.
Neither affects any statement or proof. A few modules (`BTableData1e8`,
`BTableData1e12`, `CostAttrib`) are measurement and revalidation
instrumentation retained for the record; they are not part of the
certified closure.

## Layout

    Erdos364/   Lean 4: definitions, soundness lemmas, certificates,
                assembly, bridge, gate manifest and audit
    engine/     Python enumeration and cross-validation (ruff, mypy
                --strict, pytest)
    scripts/    generators, batch drivers, axiom gate, pod scripts
    docs/       program documents, measurements, run ledger
    data/       scan ledger, chunk-run logs, certificate axiom records

## Citations

Erdős, Problems and results on number theoretic properties of consecutive
integers and related questions, Proc. Fifth Manitoba Conf. (1976)
[Er76d]. Mollin and Walsh, On powerful numbers, Internat. J. Math. Math.
Sci. 9 (1986) 801-806. Golomb, Powerful numbers, Amer. Math. Monthly 77
(1970). Sentance, Occurrences of consecutive odd powerful numbers, Amer.
Math. Monthly 88 (1981) 272-274. Guy, Unsolved Problems in Number Theory,
B16. OEIS A001694 (powerful numbers), A060355 (n, n+1 both powerful;
b-file Donovan Johnson 2011, exhaustive below 10^22), A076445 (pairs of
powerful numbers differing by 2: McCranie 2002, Reynolds 2005, Noe 2006;
Alekseyev's conjectured 33-term extension 2012), A062739, A118894.
Beckon, Rose-Hulman Undergrad. Math. J. 20(2) (2019) (mod-36 constraint).
Chan, A note on three consecutive powerful numbers, Integers 25 (2025)
A7, arXiv:2503.21485. She, Nonexistence of consecutive powerful triplets
around cubes with prime-square factors, Integers 25 (2025) A103,
arXiv:2507.16828. Erdős problem catalogue: erdosproblems.com/364 (T. F.
Bloom). Formal statement: google-deepmind/formal-conjectures,
FormalConjectures/ErdosProblems/364.lean, commit e923379e6.

## License

Apache 2.0.
