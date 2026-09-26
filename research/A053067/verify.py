#!/usr/bin/env python3
"""Independent sanity checks for the A053067 research search.

This intentionally does not prove any GMP compositeness result.  It verifies the
sequence definition, the mod-60 prefilter, the affine modular evaluator, and all
explicit small-factor witnesses in the checked-in pilot CSV.
"""

from __future__ import annotations

import csv
from math import gcd
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PILOT = ROOT / "results" / "pilot-3-1000.csv"


def bounds(n: int) -> tuple[int, int]:
    return n * (n - 1) // 2 + 1, n * (n + 1) // 2


def decimal(n: int) -> str:
    lo, hi = bounds(n)
    return "".join(str(x) for x in range(lo, hi + 1))


def streaming_mod(n: int, modulus: int) -> int:
    lo, hi = bounds(n)
    value = 0
    for x in range(lo, hi + 1):
        for ch in str(x):
            value = (10 * value + ord(ch) - ord("0")) % modulus
    return value


def compose(
    after: tuple[int, int, int, int],
    before: tuple[int, int, int, int],
    modulus: int,
) -> tuple[int, int, int, int]:
    a2, b2, c2, k2 = after
    a1, b1, c1, k1 = before
    return (
        a2 * a1 % modulus,
        (a2 * b1 + b2) % modulus,
        (a2 * c1 + b2 * k1 + c2) % modulus,
        k1 + k2,
    )


def transition_pow(q: int, count: int, modulus: int) -> tuple[int, int, int, int]:
    result = (1, 0, 0, 0)
    base = (q % modulus, 1 % modulus, 0, 1)
    while count:
        if count & 1:
            result = compose(base, result, modulus)
        count >>= 1
        if count:
            base = compose(base, base, modulus)
    return result


def fast_mod(n: int, modulus: int) -> int:
    lo, hi = bounds(n)
    value = 0
    cur = lo
    while cur <= hi:
        digits = len(str(cur))
        p10 = 10**digits
        end = min(hi, p10 - 1)
        count = end - cur + 1
        a, b, c, _ = transition_pow(p10, count, modulus)
        value = (a * value + b * cur + c) % modulus
        cur = end + 1
    return value


def elementary_candidate(n: int) -> bool:
    if n <= 2:
        return True
    if n % 3 == 0:
        return False
    _, hi = bounds(n)
    return hi % 10 in {1, 3, 7, 9}


def main() -> None:
    known = {
        1: "1",
        2: "23",
        3: "456",
        4: "78910",
        5: "1112131415",
        6: "161718192021",
    }
    for n, expected in known.items():
        assert decimal(n) == expected

    # Test the periodic n>2 condition using representatives in the next period,
    # so the deliberate n=1,2 exceptions do not contaminate the residue set.
    residues = {r for r in range(60) if elementary_candidate(r + 60)}
    assert residues == {1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58}

    for n in range(1, 60):
        for modulus in (7, 11, 13, 37, 97, 1001, 99991):
            assert fast_mod(n, modulus) == streaming_mod(n, modulus)

    if PILOT.exists():
        rows = list(csv.DictReader(PILOT.open(newline="")))
        assert len(rows) == 198
        assert sum(row["status"] == "small_factor" for row in rows) == 161
        assert sum(row["status"] == "composite_prp" for row in rows) == 37
        assert sum(row["status"] == "probable_prime" for row in rows) == 0

        seen = {int(row["n"]) for row in rows}
        expected = {n for n in range(3, 1001) if elementary_candidate(n)}
        assert seen == expected

        for row in rows:
            if row["status"] != "small_factor":
                continue
            n = int(row["n"])
            p = int(row["witness"])
            assert p > 1
            assert streaming_mod(n, p) == 0
            # All recorded factors are strictly smaller than their A053067 term.
            assert len(decimal(n)) > len(str(p))

    print("A053067 verification: OK")


if __name__ == "__main__":
    main()
