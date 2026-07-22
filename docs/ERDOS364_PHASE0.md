# Erdős 364 — Phase 0 due diligence memo

Millennium Research, 2026-07-22. Status: uncommitted working draft, no repo yet.
Scope: independent verification of the selection sweep's claims, provenance of the
known bound, formal-statement semantics, scratch measurements, certificate design,
go/no-go. No compute beyond local scratch was used.

## Verdict

GO, with one design correction and one positioning upgrade. The field is clear:
no formal work exists beyond the sorry'd statement file, nobody is registered as
working on or formalising the problem, and the two 2025 papers are narrow
algebraic shape results with no computational content. The widely quoted
7.38e28 bound turns out to be weaker than assumed: it is not just uncertified
but conditional on an unproven completeness claim, and the cleanly attributed
exhaustive (still uncertified) bound is 10^22 (section 2). The certificate is
cheaper than the plan assumed: no witness tables at all, constant-size Lean
source, and exactly 7 middle-element witnesses below 10^14. One premise in the
mission brief is false and the design must change accordingly (section 5).

## 1. Problem and landscape (verified independently)

Problem: do three consecutive powerful numbers exist? (n powerful: p | n implies
p^2 | n.) Erdős [Er76d] and independently Mollin–Walsh [MoWa86] conjecture no.
Erdős conjectured the stronger gap bound n_{k+2} - n_k > n_k^c. The abc
conjecture implies finitely many triples. Quadruples are impossible: one of four
consecutive integers is 2 mod 4, hence not powerful. Mahler: infinitely many
consecutive pairs via Pell, x^2 = 8y^2 + 1.

erdosproblems.com/364 (archived 2026-07-09; live origin was down with 522 during
Phase 0, as it was in the July sweep): status VERIFIABLE, last edited 2026-04-13,
"Formalised statement? Yes", nobody working on it, nobody formalising, no
solutions claimed in comments. All 5 comments recovered from the archived forum
thread (/forum/thread/364):

- marinov (2026-07-07): the classical doubling construction for pairs, if
  (n, n+1) is a pair then so is (4n(n+1), (2n+1)^2). Relevant to 365, not to
  triples.
- Yuchen_Li (2025-12-21): the A076445 bound, no triple with n <= 7.384e28
  (site incorporated this; this is where the page's figure comes from).
- Alfaiz (2025-11-13, 2025-10-16): the She and Chan papers (site incorporated).
- trestyn (2025-10-30): tag housekeeping.

Zero robot-flag counts on every comment. Nothing is hiding in the comments.

Adjacent pages checked for overlap:

- 365 (pairs: must one of n, n+1 be square? count (log x)^O(1)?): OPEN, no
  formalisation, 3 comments, nobody working. Golomb's 12167/12168 and Walker's
  7^3 x^2 = 3^3 y^2 + 1 answer the square question negatively. No overlap with
  our claim.
- 366 (n 2-full with n+1 3-full): open, nobody working or formalising. Page
  notes A060355 has been searched exhaustively to 10^22 (39 terms), which is a
  useful provenance anchor for pair data. The sweep's note that 366 had AI
  activity is not visible on the archived page (all reaction rows empty, no AI
  wiki entry); treat that sweep claim as unconfirmed and recheck when the site
  is back up.
- 938 (three-term arithmetic progressions of consecutive terms n_k, n_{k+1},
  n_{k+2} of the powerful sequence): a DIFFERENT problem, one user (SkyYang)
  currently working, comments claim partial results, and van Doorn
  (arXiv:2605.06697) found 18 such AP triples below 10^14. No conflict with 364,
  but do not confuse the two when writing anything public.
- 137 (products of k >= 3 consecutive integers never powerful): unrelated to a
  finite verification; no overlap.

## 2. Provenance of the 7.38e28 bound (weaker than the brief assumed)

The page's "no such n for n < 7.38 x 10^28" traces to OEIS A076445, exact
current name "The smaller of a pair of powerful numbers (A001694) that differ
by 2" (all terms are automatically odd). The entry has exactly 13 terms; the
last is

    a(13) = 73840550964522899559001927225  (~7.384e28)

Attribution as recorded on the entry: sequence by Jud McCranie (Oct 2002);
a(8)-a(10) Geoffrey Reynolds (Feb 2005); a(11)-a(13) T. D. Noe (May 2006).

The key Phase 0 finding: the exhaustiveness of those 13 terms is NOT
established anywhere. Noe's terms come from the generalized Sentance/Pell
construction (Chebyshev polynomials over the moduli in A118894); his comment
claims the construction generates all consecutive odd powerful numbers, but
completeness up to a(13) would need every relevant Pell modulus covered
(moduli range up to ~X^(2/3) ~ 1.7e19) and nothing on the entry documents that.
The OEIS editors themselves hedge: Adams-Watters renamed the sequence in 2013
precisely to drop the completeness-implying word "consecutive", and Max
Alekseyev's 2012 extension file (33 terms to ~8.12e66) carries the explicit
caveat that its terms are not known to be consecutive. No published source
asserts "no triple below 7.38e28": not MathWorld, not Chan, not Beckon. The
erdosproblems page itself cited 10^22 (via A060355) as late as its July 2025
revision and adopted the 7.38e28 figure only in the 2026-04-13 edit, sourced to
the Yuchen_Li comment of Dec 2025, which simply reads the figure off A076445.

The cleanly attributed uncertified exhaustive bound is therefore 10^22:
Donovan Johnson's 2011 exhaustive enumeration of A060355 (39 terms, b-file
captioned "terms < 10^22"; a triple would put two adjacent integers in
A060355). That too is a single private computation, no method description, no
replication, no certificate. Separately, Wroblewski (Prime Puzzles problem 53,
2008) searched pairs with neither member square, only to 1.56e16; not a
triples bound.

Summary of the known-bound tiers, none certified in any sense:

    10^22      Johnson 2011, exhaustive pair enumeration (A060355), uncertified
    7.38e28    conditional: exhaustive ONLY IF A076445's 13 terms are complete,
               which rests on Noe's undocumented 2006 Pell-construction search
    ~8.1e66    Alekseyev 2012, known pairs only, explicitly non-exhaustive
               (none of the 33 pairs has a powerful middle)

The inference from pair lists to "no triples" (mod-4 reduction plus a
non-powerfulness check on each pair's middle) is itself nowhere written down
formally. Our certificate makes exactly this chain kernel-checked. This is
better for positioning than the brief assumed: the widely quoted 7.38e28 is
not just uncertified, it is conditional, and the site's own figure moved by
six orders of magnitude on the strength of one comment.

## 3. The 2025 papers (confirmed shape results, no verification content)

- Chan [Ch25]: arXiv:2503.21485, "A note on three consecutive powerful
  numbers", Integers 25 (2025), A7. Theorem: no triple of the form
  x^3 - 1 = p^3 y^2, x^3, x^3 + 1 = q^3 z^2 with p, q prime. Pell equations,
  elliptic curves, recurrences.
- She [Sh25]: arXiv:2507.16828, Jialai She, "Nonexistence of Consecutive
  Powerful Triplets Around Cubes with Prime-Square Factors", Integers 25 (2025),
  A103. Theorem: no triple x^3 - 1 = p^2 a^3, x^3, x^3 + 1 = q^2 b^3, p, q
  prime. Builds on Chan.

Both are special cases (middle term a perfect cube, outer terms of a prescribed
shape). Neither contains a computational search or any formal verification.
Neither has been formalized anywhere. Also of note: Beckon (Rose-Hulman Undergrad.
Math. J. 20(2), 2019) proved the smallest member of any triple is 7, 27, or 35
mod 36; optional as a Lean lemma, not needed for the certificate.

Prior formal work search: GitHub code search for Erdos364 / "Mollin Walsh" /
"consecutive powerful" in Lean finds only the formal-conjectures statement file
and sorry'd AI-attempt farms (alphaproof-nexus, lean-genius, aristotle-math-
problems, etc.), none with a nontrivial verified result. The lean-genius repo
proves only trivia (8,9 pair; 2 mod 4 obstruction; no quadruple). The niche
claimed in the mission brief is real and clear.

## 4. Formal statement semantics (formal-conjectures)

File: FormalConjectures/ErdosProblems/364.lean, namespace Erdos364. Pinned
commits (2026-07-22): repo HEAD e923379e609b9d5987011a1d1f06ec22ea25cd20
(2026-07-21); last commit touching 364.lean c252a41054125b5fd9c8356e2137cd9b55337657
(2026-07-16, import-line refactor only); last substantive edit
ab84c073cd67d9936a09719818591b4d9995cbb1 (2026-04-29).

The main statement is exactly

    theorem erdos_364 : ¬ ∃ (n : ℕ), Powerful n ∧ Powerful (n+1) ∧ Powerful (n+2)

with no offsets, no side conditions. Two variants share the file:
erdos_364.variants.strong (the n_k^c gap conjecture, sorry) and
erdos_364.variants.weak (no quadruple), which is already PROVED upstream via the
mod-4 argument, category textbook. So the quadruple lemma is not ours to claim;
our mod-4 lemma for the triple reduction is the same technique and we should
cite their weak variant in the bridge file.

Powerful is NOT mathlib. It is repo-local, in
FormalConjecturesForMathlib/Data/Nat/Full.lean:

    def Full (k n : ℕ) : Prop := ∀ p ∈ n.primeFactors, p^k ∣ n
    abbrev Powerful : ℕ → Prop := (2).Full

Conventions: 0 and 1 are both Powerful (primeFactors is empty; the repo proves
Full.zero_right and Full.one_right explicitly). Harmless for the triple
statement since 2 is not powerful, but the bridge must carry the definition
VERBATIM including these conventions. Decidable instances exist. Mathlib has no
Powerful/Squarefull at any version, so there is no collision risk, only the
obligation to inline the definition. Upstream toolchain is Lean 4.27.0 /
mathlib v4.27.0; we target 4.30.0 as in centurion. The definition uses only
stable API (Nat.primeFactors, dvd); the upstream file's module-system syntax
(public import, @[expose]) gets stripped when inlining. Statement port risk: low.

Boundary convention for the bounded claim, fixed now to avoid off-by-one drift:
we certify

    ∀ n : ℕ, n + 2 ≤ X → ¬ (Powerful n ∧ Powerful (n+1) ∧ Powerful (n+2))

stated with n + 2 ≤ X (no truncated subtraction anywhere). "Exhausted [1, X]"
in the ledger means every triple whose largest element is ≤ X is excluded.

## 5. Design correction (the mission brief's reduction is false as stated)

The brief says: "it suffices to show no pair of ODD powerful numbers m, m+2 with
m+2 ≤ X". No such certificate can exist, because such pairs DO exist: (25, 27)
is one (5^2 and 3^3), and there are exactly 7 below 10^14. That is precisely
what A076445 enumerates; its nonemptiness is the reason the sequence has terms.

The correct reduction: if n, n+1, n+2 are all powerful then n is odd and
n+1 ≡ 0 mod 4 (if n were even, one of n, n+2 would be 2 mod 4). Hence n, n+2
form an odd powerful pair at distance 2 AND n+1 is powerful. The certificate
therefore has three parts:

1. MOD-4 LEMMA (short pure Lean): any triple has n odd; equivalently m ≡ 2 mod 4
   is never powerful (upstream already proves the tool lemma
   not_full_of_prime_mod_prime_sq).
2. COMPLETE ENUMERATION of odd powerful numbers ≤ X: every odd powerful n has a
   representation n = a^2 b^3 with a, b odd, b squarefree (standard, via
   factorization; uniqueness not needed, existence is). The Lean generator
   iterates odd squarefree b ≤ X^(1/3) and odd a ≤ sqrt(X/b^3); completeness is
   an abstract lemma, membership is kernel evaluation.
3. PAIR SCAN AND MIDDLE KILLS: sort the enumerated list, scan adjacent entries
   for gaps of exactly 2, and for each of the resulting pairs (m, m+2) exhibit a
   prime p with p | m+1, p^2 ∤ m+1. Measured below 10^14 there are exactly 7
   pairs and the witnesses are tiny: p = 2 for the five pairs with m ≡ 1 mod 4
   (then m+1 ≡ 2 mod 4), p = 29 for m = 130576327, p = 19 for
   m = 13837575261123 (the two m ≡ 3 mod 4 cases).

Consequences for cost, all favorable versus the brief:

- No witness tables. The brief's step 3 (a non-powerfulness witness for every
  odd powerful m ≤ X-2) is both impossible as stated and unnecessary: only pair
  MIDDLES need witnesses, and there are 7 of them, not 8 million.
- No Pratt certificates. Every needed witness prime is at most 29.
- No large certificate data files at all, in principle. The generator, sorter,
  scanner, and the 7 witnesses are constant-size Lean source; the kernel does
  the enumeration. Published source stays tiny at every X. The 50 MB budget
  becomes irrelevant unless the kernel-sort route fails (fallback below).

The open cost question is kernel throughput of generate + sort + scan (roughly
N log N comparisons on numbers up to X: about 1.6e7 comparisons at 10^12, 2e8 at
10^14). Centurion's Enumeration.lean pattern applies directly: Finset-free,
structurally recursive, constant fuel, accumulator style, one closed Bool
equality by decide, native_decide forbidden. The sort is the new ingredient; a
straightforward structural merge sort should be fine but MUST be spiked at
Phase 1 before committing to a ladder rung. Fallback if kernel sorting is slow:
generate the sorted list outside Lean, embed as a literal, kernel-verify
sortedness + powerfulness per entry (with (a, b) annotations) + completeness by
re-enumeration and binary search. Literal sizes: ~10 MB at 10^12 (fine),
~35 MB at 10^13 (borderline), ~120 MB at 10^14 (over budget). So 10^14 is
realistic only on the kernel-internal route.

## 6. Scratch measurements (numpy a^2 b^3 enumeration, cross-validated)

Enumeration to 10^14 takes 0.8 s single-core (anaconda numpy). Counts:

    X       powerful   odd powerful  A060355 pairs  odd (m,m+2) pairs
    10^8    21,044     7,857         10             2
    10^10   214,122    79,487        14             4
    10^12   2,158,391  799,138       18             5
    10^13   (not run)  2,530,755     (not run)      (6)
    10^14   21,663,503 8,010,922     24             7

    n / sqrt(X) ratio: 2.104 at 10^8 rising to 2.166 at 10^14 (literature
    constant zeta(3/2)/zeta(3) ~ 2.173, consistent).

Generator loop sizes for the odd-only enumeration (grounds the Lean fuel
constants): odd squarefree b count 873 at 10^10, 4,056 at 10^12, 8,733 at
10^13, 18,815 at 10^14; a ranges up to sqrt(X).

Cross-validation, two implementations one truth:

- The 24 recovered A060355 terms below 10^14 match the OEIS b-file (Donovan
  Johnson) EXACTLY, term by term.
- The 7 recovered odd pairs match A076445 a(1)..a(7) EXACTLY: 25, 70225,
  130576327, 189750625, 512706121225, 13837575261123, 99612037019889.
- Independent sympy factorization confirms both members of all 7 pairs powerful
  and gives the middle factorizations (26 = 2·13; 70226 = 2·13·37·73;
  130576328 = 2^3·29·197·2857; 189750626 = 2·13·61·181·661;
  512706121226 = 2·13·757·2521·10333; 13837575261124 = 2^2·19·61·199·1381·10861;
  99612037019890 = 2·5·89·103093·1085657).
- No triples found to 10^14, as expected (consistent with Johnson's 10^22
  enumeration).

## 7. Ladder and positioning

Ladder: 10^10 smoke (80k odd entries), then 10^12 (800k) as the first published
rung, then 10^13 or 10^14 depending on measured kernel throughput from the
Phase 1 spike. Every rung's claim: first kernel-certified verification that no
three consecutive powerful numbers exist with n + 2 ≤ X, axioms ⊆ {propext,
Classical.choice, Quot.sound}, no native_decide, no sorry, bridged verbatim to
formal-conjectures erdos_364 (pinned commit). Always stated against the three
uncertified tiers from section 2: exhaustive to 10^22 (Johnson), conditional to
7.38e28 (A076445, completeness unproven), known pairs to ~8.1e66 (Alekseyev,
non-exhaustive). Our contribution is certification, not range; quote all three
tiers with their caveats rather than the flat 7.38e28 the site uses. A hit is
not a realistic outcome; any apparent triple is treated as a bug until a second
code path and then a compiling Lean certificate confirm it, and even a
confirmed one below 10^22 would mean a Johnson-computation error, which is its
own result but first a bug.

## 8. Risks and unknowns

1. Kernel sort throughput unmeasured. Mitigation: Phase 1 Lean spike at 10^8
   and 10^10 before any public claim; literal-list fallback exists to 10^13.
2. erdosproblems.com origin down throughout Phase 0 (522). Comments were
   recovered from the 2026-07-09 archive; anything posted after that date is
   unseen. Page last edited 2026-04-13; risk low. Recheck live site before any
   announcement.
3. The sweep's "366 has AI activity" note is unconfirmed on the archive;
   irrelevant to 364 but worth a recheck for situational awareness.
4. Problem 938 has an active worker (SkyYang) and recent literature (van Doorn
   2026) on a neighboring question. Keep the distinction sharp in all text.
5. Upstream formal-conjectures moves (it refactored imports six days ago). Pin
   the commit in the bridge header and re-verify the statement verbatim at
   publication time.

## 9. Citation ledger (for the eventual README)

A001694: powerful numbers, includes 1, b-file 10,000 terms (Eldar/Noe/Greubel);
density constant zeta(3/2)/zeta(3) ~ 2.1732 (Bateman-Grosswald 1958), matching
our measured ratios. A060355: 39 terms, exhaustive < 10^22, Donovan Johnson
b-file, computation dated Jul 2011. A076445: 13 terms, McCranie 2002 /
Reynolds 2005 / Noe 2006, completeness unproven, renamed 2013; Alekseyev
conjectured extension to 33 terms (~8.1e66), 2012. A062739: odd powerful
numbers (Labos Elemer 2001). Sentance, Amer. Math. Monthly 88 (1981) 272-274
(the pair construction); A118894 (Noe 2006) for the generalized moduli. Guy
UPINT B16. Mollin-Walsh, IJMMS 9 (1986) 801-806. Chan, Integers 25 (2025) A7 =
arXiv:2503.21485. She, Integers 25 (2025) A103 = arXiv:2507.16828. Beckon,
RHUMJ 20(2) (2019) (mod-36 constraint). Wroblewski, Prime Puzzles problem 53
(2008). van Doorn arXiv:2605.06697 (problem 938, not 364). formal-conjectures
commits pinned in section 4.

## 10. Decision points

1. Go/no-go. Recommendation: GO.
2. Approve the corrected certificate design (enumeration + sorted scan + 7
   middle witnesses) replacing the brief's witness-table design.
3. Approve the ladder (10^10 smoke, 10^12 first published rung, 10^13/10^14
   decided by the Phase 1 spike).
4. Repo scaffold timing (Optio, layout per the brief, gate script adapted
   from centurion).
5. Whether Phase 1 should also include the optional Beckon mod-36 lemma as a
   redundant cross-check on the pair scan (cheap, but adds surface).

STOP. Awaiting go before any repo creation, commits, or Lean work.
