"""Erdos 364 Phase 1 scan: enumerate powerful numbers and hunt triples.

Two implementations, one truth:

* the fast path enumerates every powerful number <= X as a^2 * b^3 with b
  squarefree (unique representation, so counts are exact);
* the slow path decides powerfulness by trial factorization, and every
  reported pair or triple must survive it before being written to the ledger.

The scan is exhaustive on [1, X]. Coverage language in the ledger is exact:
"exhausted" means every powerful number in range was generated and every
adjacent gap examined.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

import numpy as np
from numpy.typing import NDArray


def squarefree_sieve(limit: int) -> NDArray[np.bool_]:
    """Boolean mask sf where sf[i] says i is squarefree, for 0 <= i <= limit."""
    sf = np.ones(limit + 1, dtype=np.bool_)
    sf[0] = False
    p = 2
    while p * p <= limit:
        sf[p * p :: p * p] = False
        p += 1
    return sf


def powerful_upto(x: int, odd_only: bool = False) -> NDArray[np.uint64]:
    """Sorted array of every powerful number in [1, x], via a^2 * b^3.

    With odd_only, restricts to odd a and odd b, which enumerates exactly the
    odd powerful numbers.
    """
    if x < 1:
        return np.empty(0, dtype=np.uint64)
    bmax = 1
    while (bmax + 1) ** 3 <= x:
        bmax += 1
    sf = squarefree_sieve(bmax)
    step = 2 if odd_only else 1
    chunks: list[NDArray[np.uint64]] = []
    for b in range(1, bmax + 1, step):
        if not sf[b]:
            continue
        b3 = b * b * b
        if b3 > x:
            break
        amax = int((x // b3) ** 0.5)
        while (amax + 1) ** 2 * b3 <= x:
            amax += 1
        while amax >= 1 and amax * amax * b3 > x:
            amax -= 1
        if amax < 1:
            continue
        a = np.arange(1, amax + 1, step, dtype=np.uint64)
        chunks.append(a * a * np.uint64(b3))
    values = np.concatenate(chunks)
    values.sort()
    return values


def is_powerful_naive(n: int) -> bool:
    """Trial-factorization powerfulness check. Independent of the generator."""
    if n < 1:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            e = 0
            while n % d == 0:
                n //= d
                e += 1
            if e < 2:
                return False
        d += 1
    return n == 1


def smallest_unit_witness(n: int) -> int | None:
    """Smallest prime p with p | n and p^2 not dividing n, or None."""
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            e = 0
            while m % d == 0:
                m //= d
                e += 1
            if e == 1:
                return d
        d += 1
    if m > 1:
        return m
    return None


@dataclass
class ScanResult:
    x: int
    count_all: int
    count_odd: int
    pairs: list[int]
    odd_gap2: list[int]
    triples: list[int]
    elapsed_s: float


def scan(x: int) -> ScanResult:
    """Exhaustive scan of [1, x]: counts, gap-1 pairs, odd gap-2 pairs, triples."""
    t0 = time.monotonic()
    values = powerful_upto(x)
    gaps = np.diff(values)
    pairs = values[:-1][gaps == 1]
    tri_idx = np.where((gaps[:-1] == 1) & (gaps[1:] == 1))[0]
    triples = values[tri_idx]
    odd = values[values % 2 == 1]
    odd_gap2 = odd[:-1][np.diff(odd) == 2]
    elapsed = time.monotonic() - t0

    for p in pairs.tolist():
        if not (is_powerful_naive(int(p)) and is_powerful_naive(int(p) + 1)):
            raise AssertionError(f"pair {p} fails the naive cross-check")
    for t in triples.tolist():
        if not all(is_powerful_naive(int(t) + k) for k in (0, 1, 2)):
            raise AssertionError(f"triple {t} fails the naive cross-check")
    for m in odd_gap2.tolist():
        if not (is_powerful_naive(int(m)) and is_powerful_naive(int(m) + 2)):
            raise AssertionError(f"odd pair {m} fails the naive cross-check")

    return ScanResult(
        x=x,
        count_all=len(values),
        count_odd=len(odd),
        pairs=[int(v) for v in pairs.tolist()],
        odd_gap2=[int(v) for v in odd_gap2.tolist()],
        triples=[int(v) for v in triples.tolist()],
        elapsed_s=round(elapsed, 3),
    )


def git_sha() -> str:
    try:
        out = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
            cwd=Path(__file__).resolve().parent,
        )
        return out.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "uncommitted"


def append_ledger(result: ScanResult, ledger_path: Path) -> None:
    """Append one JSONL line. The ledger is append-only by convention."""
    entry = {
        "timestamp": datetime.now(UTC).isoformat(timespec="seconds"),
        "coverage": f"exhausted [1, {result.x}]",
        "x": result.x,
        "count_all": result.count_all,
        "count_odd": result.count_odd,
        "pairs_gap1": result.pairs,
        "odd_pairs_gap2": result.odd_gap2,
        "triples": result.triples,
        "middle_witnesses": {
            str(m): smallest_unit_witness(m + 1) for m in result.odd_gap2
        },
        "elapsed_s": result.elapsed_s,
        "code_sha": git_sha(),
        "cross_check": "every pair member re-verified by trial factorization",
    }
    ledger_path.parent.mkdir(parents=True, exist_ok=True)
    with ledger_path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(entry) + "\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("x", type=int, help="scan bound X, inclusive")
    parser.add_argument(
        "--ledger",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "data" / "scan_ledger.jsonl",
    )
    args = parser.parse_args(argv)

    result = scan(args.x)
    append_ledger(result, args.ledger)
    print(f"exhausted [1, {result.x}]")
    print(f"powerful: {result.count_all}  odd: {result.count_odd}")
    print(f"gap-1 pairs: {len(result.pairs)}  odd gap-2 pairs: {len(result.odd_gap2)}")
    print(f"triples: {result.triples}")
    print(f"elapsed: {result.elapsed_s}s  ledger: {args.ledger}")
    if result.triples:
        print("TRIPLE CANDIDATE FOUND: treat as a bug until independently recounted")
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
