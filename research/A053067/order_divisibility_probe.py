#!/usr/bin/env python3
"""Probe the order-divisibility series controlling A053067 pair correlations.

The Fourier pair-energy theorem reduces the non-cross, nondegenerate
absolute covariance problem to the arithmetic majorant

    T = sum_{p<r} gcd(l_p,l_r) a_p a_r,
    a_p = 1 / (sqrt(p) l_p),
    l_p = ord_p(10).

Using gcd(u,v) = sum_{m|u,m|v} phi(m), this is evaluated without enumerating
prime pairs:

    T_B = 1/2 sum_m phi(m) (B_m^2 - Q_m),

where
    B_m = sum_{p<=B, m|l_p} a_p,
    Q_m = sum_{p<=B, m|l_p} a_p^2.

This is a diagnostic for the remaining multiplicative-order theorem, not a
proof of convergence.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path

from congruence_families import multiplicative_order, primes_up_to


def divisors(n: int) -> list[int]:
    small: list[int] = []
    large: list[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d * d != n:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def totients_up_to(n: int) -> list[int]:
    phi = list(range(n + 1))
    if n >= 1:
        phi[1] = 1
    for p in range(2, n + 1):
        if phi[p] == p:
            for k in range(p, n + 1, p):
                phi[k] -= phi[k] // p
    return phi


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--prime-bound", type=int, required=True)
    ap.add_argument("--top", type=int, default=30)
    ap.add_argument("--output", type=Path)
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    if args.prime_bound < 7:
        raise SystemExit("--prime-bound must be at least 7")
    if args.top <= 0:
        raise SystemExit("--top must be positive")

    primes = [p for p in primes_up_to(args.prime_bound) if p > 5]
    phi = totients_up_to(args.prime_bound)

    bm = [0.0] * (args.prime_bound + 1)
    qm = [0.0] * (args.prime_bound + 1)
    sum_a = 0.0
    sum_a2 = 0.0
    max_order = 0

    for p in primes:
        ell = multiplicative_order(10, p)
        max_order = max(max_order, ell)
        a = 1.0 / (math.sqrt(p) * ell)
        a2 = a * a
        sum_a += a
        sum_a2 += a2
        for m in divisors(ell):
            bm[m] += a
            qm[m] += a2

    contributions: list[tuple[int, float, float]] = []
    total = 0.0
    for m in range(1, max_order + 1):
        if bm[m] == 0.0:
            continue
        pair_mass = 0.5 * phi[m] * (bm[m] * bm[m] - qm[m])
        if pair_mass < 0.0 and abs(pair_mass) < 1e-18:
            pair_mass = 0.0
        total += pair_mass
        contributions.append((m, pair_mass, bm[m]))

    thresholds = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
    thresholds += [10, 100, 1000, 10000]
    thresholds = sorted(set(h for h in thresholds if h < max_order))

    print(
        f"B={args.prime_bound} primes={len(primes)} max_order={max_order} "
        f"sum_a={sum_a:.12g} sum_a2={sum_a2:.12g} "
        f"order_gcd_majorant={total:.12g}"
    )

    for h in thresholds:
        tail = sum(v for m, v, _ in contributions if m > h)
        print(
            f"m>{h:<5} decomposition_tail={tail:.12g} "
            f"fraction={tail / total:.9g}"
        )

    ranked = sorted(contributions, key=lambda row: row[1], reverse=True)
    print("largest order-divisibility contributions:")
    for m, value, bval in ranked[: args.top]:
        print(
            f"m={m:>6} phi={phi[m]:>6} B_m={bval:.10g} "
            f"pair_mass={value:.10g}"
        )

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("w") as f:
            f.write("m,phi,B_m,Q_m,pair_mass\n")
            for m, value, bval in contributions:
                f.write(f"{m},{phi[m]},{bval:.17g},{qm[m]:.17g},{value:.17g}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
