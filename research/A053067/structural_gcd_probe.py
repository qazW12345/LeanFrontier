#!/usr/bin/env python3
"""Probe fixed-width A053067 sieve survivors with proof-derived structural gcds.

The probe uses three exact divisor mechanisms:

1. q-1:
   every odd divisor of gcd(q-1, n(n^2+1)) is an A053067 divisor;

2. q+1:
   for even n use gcd(q+1,n/2);
   for odd n use gcd(q+1,n^2+1);

3. factors inherited from n:
   every prime divisor of gcd(n,q^n-1) divides A053067(n).

Candidate gcds are independently verified against A modulo the candidate;
the full concatenated integer is never constructed.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path


def compose(after, before, modulus: int):
    a2, b2, c2, k2 = after
    a1, b1, c1, k1 = before
    return (
        a2 * a1 % modulus,
        (a2 * b1 + b2) % modulus,
        (a2 * c1 + b2 * (k1 % modulus) + c2) % modulus,
        k1 + k2,
    )


def transition_pow(q: int, count: int, modulus: int):
    result = (1, 0, 0, 0)
    base = (q % modulus, 1 % modulus, 0, 1)
    while count:
        if count & 1:
            result = compose(base, result, modulus)
        count >>= 1
        if count:
            base = compose(base, base, modulus)
    return result


def concat_mod(n: int, q: int, modulus: int) -> int:
    L = n * (n - 1) // 2 + 1
    _, b, c, _ = transition_pow(q, n, modulus)
    return (b * (L % modulus) + c) % modulus


def fixed_width(n: int) -> int | None:
    L = n * (n - 1) // 2 + 1
    U = n * (n + 1) // 2
    dl = len(str(L))
    return dl if dl == len(str(U)) else None


def verified_part(n: int, q: int, candidate: int) -> int:
    if candidate <= 1:
        return 1
    return math.gcd(candidate, concat_mod(n, q, candidate))


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("csv", type=Path)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    rows = list(csv.DictReader(args.csv.open(newline="")))
    targets = [int(r["n"]) for r in rows if r["status"] == "sieve_survivor"]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    counts = {"q_minus_1": 0, "q_plus_1": 0, "inherited": 0}
    caught: set[int] = set()

    with args.output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["n", "digits", "kind", "divisor"])

        for n in targets:
            d = fixed_width(n)
            if d is None:
                continue
            q = 10**d

            candidates = []

            g = math.gcd(q - 1, n * (n * n + 1))
            h = verified_part(n, q, g)
            if h > 1:
                candidates.append(("q_minus_1", h))

            if n % 2 == 0:
                g = math.gcd(q + 1, n // 2)
            else:
                g = math.gcd(q + 1, n * n + 1)
            h = verified_part(n, q, g)
            if h > 1:
                candidates.append(("q_plus_1", h))

            g = math.gcd(n, (pow(q, n, n) - 1) % n)
            h = verified_part(n, q, g)
            if h > 1:
                candidates.append(("inherited", h))

            for kind, divisor in candidates:
                writer.writerow([n, d, kind, divisor])
                counts[kind] += 1
                caught.add(n)

    print(
        f"structural-gcd targets={len(targets)} caught={len(caught)} "
        f"q_minus_1={counts['q_minus_1']} "
        f"q_plus_1={counts['q_plus_1']} "
        f"inherited={counts['inherited']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
