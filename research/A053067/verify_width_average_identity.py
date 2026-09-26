#!/usr/bin/env python3
"""Verify the exact common-period width-average identity for A053067.

For each prime p>5:
  * compute the conditioned mean local density by independently enumerating
    the exact zero families for every width d mod ord_p(10);
  * compute the new two-dimensional common-period character sum;
  * compare the normalized quantities exactly up to floating error.

This is a derivation check for WIDTH_AVERAGE_THEORY.md.
"""

from __future__ import annotations

import argparse
import math
from fractions import Fraction

from congruence_families import multiplicative_order, primes_up_to, zero_family
from local_product import conditioned_zero_density

S60 = (1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58)


def legendre(a: int, p: int) -> int:
    a %= p
    if a == 0:
        return 0
    x = pow(a, (p - 1) // 2, p)
    return 1 if x == 1 else -1


def delta(q: int, t: int, p: int) -> int:
    return (
        (q - 1)
        * (-(7 * q + 1) * t * t + (18 * q - 2) * t - (7 * q + 1))
    ) % p


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--prime-bound", type=int, default=200)
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    checked = 0
    max_abs = 0.0

    for p in primes_up_to(args.prime_bound):
        if p in (2, 3, 5):
            continue

        ell = multiplicative_order(10, p)

        # Left side: exact conditioned density averaged over one width period.
        rhos = []
        for d in range(1, ell + 1):
            period, roots = zero_family(d, p)
            rhos.append(Fraction(
                sum(
                    sum(1 for s in S60 if s % math.gcd(period, 60) == root % math.gcd(period, 60))
                    for root in roots
                ),
                len(S60) * (period // math.gcd(period, 60)),
            ))
        mean_rho = sum(rhos, Fraction(0, 1)) / ell
        lhs = Fraction(p * ell, 1) * (mean_rho - Fraction(1, p))

        # Right side: exact common-period character sum.
        L = math.lcm(ell, 60)
        char_sum = 0

        # d=0 is q=1 and is handled by nu_p - 1.
        for d in range(1, ell):
            q = pow(10, d, p)
            for s in S60:
                for c in range(s % 60, L, 60):
                    # range(0,...) for residue 0 would need care, but S has no 0.
                    t = pow(q, c, p)
                    if t == 1:
                        continue
                    char_sum += legendre(delta(q, t, p), p)

        nu = 3 if p % 4 == 1 else 1
        rhs = Fraction(5 * char_sum, L) + (nu - 1)

        if lhs != rhs:
            print(f"FAIL p={p} ell={ell} lhs={lhs} rhs={rhs}")
            return 1

        checked += 1
        max_abs = max(max_abs, abs(float(lhs)))

    print(
        f"common-period identity verified for {checked} primes through "
        f"{args.prime_bound}; max_abs_scaled_bias={max_abs:.9f}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
