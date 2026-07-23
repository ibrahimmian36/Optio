# Erdős 364 — the complete proof plan

Millennium Research, 2026-07-22. This is the step-by-step path from the
current state (Phase 1 complete, overnight 10^12 chunk run launched) to the
published result. Honesty note kept in view throughout: the deliverable is
the first kernel-certified bounded verification of the Erdős-Mollin-Walsh
conjecture, not a proof of the conjecture, which no finite computation can
give. Each step below states what is proved, why it is needed, and its
acceptance test.

## The target theorem, per ladder rung X

    theorem no_powerful_triple_up_to :
      ∀ n : ℕ, n + 2 ≤ X → ¬ (Powerful n ∧ Powerful (n+1) ∧ Powerful (n+2))

with Powerful carried verbatim from formal-conjectures (pinned commit
e923379e6), axioms ⊆ {propext, Classical.choice, Quot.sound}, no
native_decide, no sorry. Rungs: X = 10^10 (smoke), 10^12 (first published),
10^13/10^14 (after the optimization pass).

## Proof architecture in one paragraph

A triple forces its ends odd (step 1). Odd powerful numbers are exactly the
odd a^2 b^3 with b squarefree (step 2), so the fueled generator enumerates
them completely per chunk (step 3); merging keeps the list sorted with only
odd members, so two members differing by 2 must sit adjacent, and the
kernel-checked scan therefore finds every such pair in every chunk (step 4).
The chunks tile [1, X] with overlap 2, so no pair escapes at a boundary
(step 5). That reduces the triple hunt to the finitely many scanned pairs,
and each pair's middle is killed by an explicit non-powerfulness witness
(step 6). Steps 7-9 assemble, gate, and bridge the result.

## Step 1 — mod-4 lemma (pure Lean, short)

    lemma: n % 4 = 2 → ¬ Powerful n
    lemma: Powerful n → Powerful (n+1) → Powerful (n+2) → n % 2 = 1

If n were even, one of n, n+2 is 2 mod 4, and a 2 mod 4 number has 2 in its
prime factors without 4 dividing it. Upstream's proved quadruple variant
uses exactly this tool (not_full_of_prime_mod_prime_sq); we reprove locally
to stay self-contained. Acceptance: compiles, gate-clean. Effort: hours.

## Step 2 — representation lemma (the substantive mathematics)

    lemma: Powerful m → Odd m →
           ∃ a b, Odd a ∧ Odd b ∧ Squarefree b ∧ m = a^2 * b^3

Construction via Nat.factorization: put p^(e/2) into a when e is even,
p^((e-3)/2) into a and p into b when e is odd (e ≥ 3 holds because m is
powerful and e is odd, e ≥ 2). b is squarefree because each prime enters
once; oddness is inherited. Also the uniqueness direction is not needed:
duplicates in the enumeration are harmless because merge keeps them adjacent
and the scan logic tolerates them. This is the one lemma with real
mathematical content; mathlib's Finsupp/factorization API carries it.
Acceptance: compiles against mathlib v4.30.0, gate-clean. Effort: 1-2 days,
the long pole of Phase 2.

## Step 3 — generator completeness (checker soundness, part 1)

    lemma (isqrt): isqrt n * isqrt n ≤ n < (isqrt n + 1)^2
    lemma (stream): v ∈ genOddRange b3 skip cnt ↔
                    v = a^2 * b3 for an odd a in the skipped range
    lemma (cover):  Odd m → Powerful m → lo ≤ m → m ≤ hi →
                    m ∈ some per-b stream of outerRange lo hi kb

The isqrt invariant is a fuel induction on the binary search. The cover
lemma composes step 2 with the a-range arithmetic: m = a^2 b^3 ≤ hi gives
b ≤ cbrt hi (so b is visited) and a in the generated window. Kb sufficiency
(every candidate b is visited) is part of the same arithmetic. Acceptance:
`m ∈ oddPowerfulRange lo hi kb` derived abstractly for every odd powerful m
in [lo, hi]. Effort: 1-2 days.

## Step 4 — sortedness and the adjacency argument (checker soundness, part 2)

    lemma: every stream is sorted; mergeAux/mergeAll preserve sortedness
           and membership; every list member is odd
    lemma: in a sorted all-odd list, if m and m+2 are both members then
           some adjacent pair (l[i], l[i+1]) = (m, m+2)
    lemma: scanGap2 catches exactly the adjacent pairs at distance 2
    theorem (checker sound): checkChunk lo hi kb cnt expected = true →
           ∀ m, lo ≤ m → m ≤ hi → Odd m → Powerful m → Powerful (m+2) →
           m ∈ expected

The adjacency argument needs the all-odd fact: the only value that could
separate m from m+2 in a sorted list is m+1, which is even and hence absent.
Proved once, parametrically; the 320 chunk theorems instantiate it for free.
Acceptance: the implication compiles with no per-chunk work beyond the
already-running decide. Effort: 1-2 days.

## Step 5 — tiling and stitching

    lemma: the chunk boundary list tiles [1, X]: lo_1 = 1, hi_last = X,
           lo_{i+1} = hi_i + 1 (checked by one Bool fold over literals)
    theorem: any odd powerful pair (m, m+2) with m+2 ≤ X lands in the
           chunk owning m, whose window extends to hi_i + 2 ≥ m + 2

With the 2-overlap, a pair near a boundary is caught by the left chunk.
Composing over the tiling: the union of the 320 expected lists contains
every odd powerful pair in [1, X]. Acceptance: one assembly lemma quantifying
over the literal boundary table. Effort: half a day.

## Step 6 — middle kills

    lemma: p.Prime → p ∣ n → ¬ p^2 ∣ n → ¬ Powerful n

At 10^12 the union of expected lists is 5 pairs (25, 70225, 130576327,
189750625, 512706121225); witnesses for the middles: p = 2, 2, 29, 2, 2.
Five two-line instances; divisibility and primality by decide/norm_num.
Acceptance: ¬ Powerful (m+1) for all five. Effort: hours.

## Step 7 — assembly of the headline theorem

Compose: triple with n + 2 ≤ X → n odd (step 1) → (n, n+2) odd powerful
pair (definition) → n in some chunk's expected list (steps 3-5) → n among
the 5 known pairs → Powerful (n+1) contradicted (step 6). The certificate
files (the 320 decide theorems) move from spike_runs into the library as
Erdos364/C12/Chunk_*.lean (~1.4 MB source total, far under budget) and the
assembly imports them. The overnight run validates content and timing; the
library build re-checks everything once more as a natural consequence of
compilation, after which oleans cache it. Acceptance: the headline theorem
compiles sorry-free. Effort: 1 day plus one more overnight-scale compile.

## Step 8 — axiom gate and CI

AxiomCheck.lean (curated manifest: headline theorem + every lemma above,
#print axioms each) and AxiomAudit.lean (mechanical sweep of the whole
library), gated by scripts/axiom_gate.sh adapted from centurion, run in
GitHub Actions. Gate: axioms ⊆ {propext, Classical.choice, Quot.sound},
zero sorryAx, zero _native. The spike theorems already measure at [propext]
alone. Acceptance: gate PASS locally and in CI. Effort: half a day.

## Step 9 — bridge and README

Bridge file states the headline in the upstream namespace and vocabulary,
byte-identical Powerful, upstream commit hash in the header, and derives the
bounded statement in exactly the shape of erdos_364 restricted to n + 2 ≤ X.
README finalizes the two-tier claim with the full citation ledger from the
Phase 0 memo (Johnson 10^22, conditional A076445 7.38e28, Alekseyev ~8.1e66,
Chan, She, Beckon, Sentance, Mollin-Walsh). Acceptance: a reader can check
the claim, its scope, and every provenance line without leaving the README.
Effort: half a day.

## Step 10 — publication (Ibby's decisions, nothing moves without her)

Repo public. Optional: erdosproblems.com comment and formal-conjectures
upstream contribution of the bounded result, both drafted for her review,
sent only by her. Effort: drafting hours.

## Step 11 — optimization arc for 10^13 / 10^14 (optional stretch)

Profile the top-end chunk blowup (cost tracks value magnitude, not entry
count; prime suspects are the per-b isqrt binary searches on big literals
and whnf cache pressure). Levers, in order: shared squarefree-b literal
table (removes 4,056 sqfree recomputations per chunk), baked per-b skip
hints with a tolerant checker (removes the (lo-1)/b^3 isqrt), narrower
chunks at the top end (bounds memory), parallel CI fan-out. Re-price
10^13/10^14 after measuring; certify only what the curve honestly supports.
Effort: ~1 week, separate go/no-go with Ibby.

## Schedule estimate (working days from overnight-run success)

Steps 1+6 in parallel with 2: days 1-2. Steps 3-4: days 2-4. Steps 5+7:
day 5, second certificate compile that night. Steps 8-9: day 6. Buffer and
her review: day 7. Published 10^12 rung inside ~a week; step 11 afterwards
if she wants the stretch rungs.

## Risk register

Representation lemma fights mathlib's factorization API (mitigation: it is
classical bookkeeping, no novel math; worst case costs 1-2 extra days).
Checker soundness reveals a latent generator edge case (mitigation: the
overnight cross-validation against Python bounds the blast radius to proof
shape, not results). Second full compile hits memory during CI (mitigation:
compile locally, CI checks oleans or re-runs gated subsets). Upstream
formal-conjectures edits its statement (mitigation: commit pinned; bridge
re-verified at publication).
