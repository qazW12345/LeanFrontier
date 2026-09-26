#!/usr/bin/env python3
"""Compute A053067 local correction factors across decimal widths.

Unlike local_product.py this tool never enumerates the genuine n interval.
It only uses exact periodic zero families, so widths may be arbitrarily large.

For each d and each prime 5<p<=B it computes the exact zero density conditioned
on the elementary mod-60 admissible classes, then reports

    C_d(B) = prod_p (1-rho_{p,d}) / (1-1/p).

This is a finite-cutoff local singular correction, not a prime-count theorem.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path

from congruence_families import primes_up_to, zero_family

ADMISSIBLE_MOD_60 = (1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58)


def conditioned_zero_density(period: int, roots: list[int]) -> float:
    g = math.gcd(period, 60)
    counts = [0] * g
    for s in ADMISSIBLE_MOD_60:
        counts[s % g] += 1
    killed = sum(counts[root % g] for root in roots)
    admissible = len(ADMISSIBLE_MOD_60) * (period // g)
    return killed / admissible


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--min-d", type=int, default=1)
    p.add_argument("--max-d", type=int, required=True)
    p.add_argument("--prime-bound", type=int, default=1000)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if args.min_d < 1 or args.max_d < args.min_d:
        raise SystemExit("invalid width range")
    if args.prime_bound < 7:
        raise SystemExit("prime bound must be >= 7")

    primes = [p for p in primes_up_to(args.prime_bound) if p not in (2, 3, 5)]
    naive_log = sum(math.log1p(-1.0 / p) for p in primes)
    naive = math.exp(naive_log)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    rows: list[tuple[int, float]] = []

    with args.output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["digits", "prime_bound", "correction", "local_survival", "naive_survival"])
        for d in range(args.min_d, args.max_d + 1):
            local_log = 0.0
            for p in primes:
                period, roots = zero_family(d, p)
                rho = conditioned_zero_density(period, roots)
                if not (0.0 <= rho < 1.0):
                    raise RuntimeError(f"invalid density d={d} p={p}: {rho}")
                local_log += math.log1p(-rho)

            local = math.exp(local_log)
            correction = local / naive
            rows.append((d, correction))
            writer.writerow([
                d,
                args.prime_bound,
                f"{correction:.17g}",
                f"{local:.17g}",
                f"{naive:.17g}",
            ])

    corrections = [c for _, c in rows]
    harmonic_num = sum(c / d for d, c in rows)
    harmonic_den = sum(1.0 / d for d, _ in rows)
    geom = math.exp(sum(math.log(c) for c in corrections) / len(corrections))

    min_d, min_c = min(rows, key=lambda x: x[1])
    max_d, max_c = max(rows, key=lambda x: x[1])

    print(
        f"width-corrections d={args.min_d}..{args.max_d} B={args.prime_bound} "
        f"min={min_c:.9f}@d={min_d} max={max_c:.9f}@d={max_d} "
        f"mean={sum(corrections)/len(corrections):.9f} "
        f"geom={geom:.9f} harmonic-weighted={harmonic_num/harmonic_den:.9f}"
    )
    print(
        f"harmonic_mass=sum(C_d/d)={harmonic_num:.9f} "
        f"baseline=sum(1/d)={harmonic_den:.9f}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
