"""Tests for the Phase 1 scan: small closed-form cases and OEIS anchors."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from scan import (  # noqa: E402
    is_powerful_naive,
    powerful_upto,
    scan,
    smallest_unit_witness,
    squarefree_sieve,
)

# A001694 up to 1000, from the OEIS entry.
A001694_TO_1000 = [
    1, 4, 8, 9, 16, 25, 27, 32, 36, 49, 64, 72, 81, 100, 108, 121, 125, 128,
    144, 169, 196, 200, 216, 225, 243, 256, 288, 289, 324, 343, 361, 392, 400,
    432, 441, 484, 500, 512, 529, 576, 625, 648, 675, 676, 729, 784, 800, 841,
    864, 900, 961, 968, 972, 1000,
]

# A060355 terms below 10^8 (n and n+1 both powerful).
A060355_TO_1E8 = [8, 288, 675, 9800, 12167, 235224, 332928, 465124, 1825200, 11309768]

# A076445 terms below 10^8 (odd powerful pairs differing by 2).
A076445_TO_1E8 = [25, 70225]


def test_squarefree_sieve() -> None:
    sf = squarefree_sieve(30)
    squarefree = [i for i in range(1, 31) if sf[i]]
    assert squarefree == [
        1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 15, 17, 19, 21, 22, 23, 26, 29, 30,
    ]


def test_powerful_upto_matches_oeis() -> None:
    assert powerful_upto(1000).tolist() == A001694_TO_1000


def test_powerful_upto_agrees_with_naive() -> None:
    generated = set(powerful_upto(5000).tolist())
    for n in range(1, 5001):
        assert (n in generated) == is_powerful_naive(n), n


def test_odd_only_enumeration() -> None:
    full = powerful_upto(100000)
    odd_direct = [int(v) for v in full.tolist() if v % 2 == 1]
    assert powerful_upto(100000, odd_only=True).tolist() == odd_direct


def test_scan_anchors() -> None:
    result = scan(10**8)
    assert result.count_all == 21044  # A118896 count at 10^8
    assert result.pairs == A060355_TO_1E8
    assert result.odd_gap2 == A076445_TO_1E8
    assert result.triples == []


def test_witnesses() -> None:
    assert smallest_unit_witness(26) == 2
    assert smallest_unit_witness(130576328) == 29
    assert smallest_unit_witness(13837575261124) == 19
    assert smallest_unit_witness(36) is None
    assert is_powerful_naive(1)
    assert not is_powerful_naive(2)
    assert is_powerful_naive(27)
