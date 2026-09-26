#!/usr/bin/env python3
"""Sieve the unique mixed-width A053067 block at each decimal boundary.

For q=10^d let n be the unique index with T_{n-1} < q <= T_n.
That A053067 block crosses from d-digit to (d+1)-digit integers.

The script evaluates the two fixed-base pieces modulo small primes using the
closed form, so it never constructs the concatenated A053067 integer.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path


def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    p = 2
    while p * p <= limit:
        if sieve[p]:
            sieve[p * p : limit + 1 : p] = b"\x00" * (
                (limit - p * p) // p + 1
            )
        p += 1
    return [i for i in range(2, limit + 1) if sieve[i]]


def boundary_state(d: int) -> tuple[int, int, int]:
    q = 10**d
    s = math.isqrt(1 + 8 * q)
    n = max(1, (s - 1) // 2)
    while n * (n + 1) // 2 < q:
        n += 1
    while (n - 1) * n // 2 >= q:
        n -= 1
    delta = n * (n + 1) // 2 - q
    return q, n, delta


def fixed_mod(q: int, L: int, k: int, p: int) -> int:
    """F(q,L,k) modulo odd prime p using the division-free closed form."""
    qm = q % p
    Lm = L % p
    km = k % p

    if qm == 1:
        return km * ((2 * Lm + (k - 1) % p) % p) * pow(2, -1, p) % p

    qk = pow(qm, k, p)
    numerator = (
        qk * (((qm - 1) * Lm + 1) % p)
        - (((qm - 1) * ((L + k - 1) % p) + qm) % p)
    ) % p
    denominator = (qm - 1) * (qm - 1) % p
    return numerator * pow(denominator, -1, p) % p


def mixed_mod(q: int, n: int, delta: int, p: int) -> int:
    # b high-width terms q..U; a low-width terms L..q-1.
    b = delta + 1
    a = n - b
    L = n * (n - 1) // 2 + 1
    Q = 10 * q

    low = fixed_mod(q, L, a, p)
    high = fixed_mod(Q, q, b, p)
    return (pow(Q % p, b, p) * low + high) % p


def elementary_candidate(n: int) -> bool:
    if n <= 2:
        return True
    U = n * (n + 1) // 2
    return n % 3 != 0 and U % 10 in {1, 3, 7, 9}


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--min-d", type=int, default=1)
    p.add_argument("--max-d", type=int, required=True)
    p.add_argument("--prime-bound", type=int, default=100000)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if args.min_d < 1 or args.max_d < args.min_d:
        raise SystemExit("invalid decimal-width range")

    primes = [p for p in primes_up_to(args.prime_bound) if p not in (2, 3, 5)]
    args.output.parent.mkdir(parents=True, exist_ok=True)

    admissible = factored = survivors = 0
    factor_counts: dict[int, int] = {}

    with args.output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "d", "status", "witness", "n_digits", "delta_digits",
            "n_mod_60", "delta_mod_60",
        ])

        for d in range(args.min_d, args.max_d + 1):
            q, n, delta = boundary_state(d)
            if not elementary_candidate(n):
                continue

            admissible += 1
            witness = None
            for p in primes:
                if mixed_mod(q, n, delta, p) == 0:
                    witness = p
                    break

            if witness is None:
                survivors += 1
                status = "sieve_survivor"
                w = ""
            else:
                factored += 1
                factor_counts[witness] = factor_counts.get(witness, 0) + 1
                status = "small_factor"
                w = str(witness)

            writer.writerow([
                d, status, w, len(str(n)), len(str(delta)),
                n % 60, delta % 60,
            ])

    top = sorted(factor_counts.items(), key=lambda kv: (-kv[1], kv[0]))[:20]
    print(
        f"mixed-boundary d={args.min_d}..{args.max_d} "
        f"admissible={admissible} small_factor={factored} "
        f"sieve_survivor={survivors} prime_bound={args.prime_bound}"
    )
    if top:
        print("top factors:", " ".join(f"{p}:{c}" for p, c in top))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
