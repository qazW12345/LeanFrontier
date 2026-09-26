#!/usr/bin/env python3
"""Average A053067 local prime factors over the full decimal-width period.

For each prime p>5, d -> rho_{p,d} is periodic with period ord_p(10).
This tool measures the signed first-order bias

    p * ord_p(10) * (mean_d rho_{p,d} - 1/p)

and the geometric mean of the normalized local factor

    (1-rho_{p,d}) / (1-1/p).

The goal is to test whether averaging over widths gains a full square-root
cancellation beyond the pointwise character-sum bound.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path

from congruence_families import multiplicative_order, primes_up_to, zero_family
from local_product import conditioned_zero_density

S60 = (1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58)


def legendre(a: int, p: int) -> int:
    a %= p
    if a == 0:
        return 0
    x = pow(a, (p - 1) // 2, p)
    return 1 if x == 1 else -1


def fast_local_densities(d: int, p: int) -> tuple[float, float]:
    """Exact conditioned and unconditioned zero densities without root solving."""
    q = pow(10, d, p)

    if q == 1:
        roots = 3 if p % 4 == 1 else 1
        rho = roots / p
        return rho, rho

    r = multiplicative_order(q, p)
    g = math.gcd(r, 60)
    weights = [0] * g
    for s in S60:
        weights[s % g] += 1

    weighted_roots = 0
    total_roots = 0
    t = 1

    for b in range(r):
        if b == 0:
            root_count = 1
        else:
            disc = (
                (q - 1)
                * (
                    -(7 * q + 1) * t * t
                    + (18 * q - 2) * t
                    - (7 * q + 1)
                )
            ) % p
            root_count = 1 + legendre(disc, p)

        total_roots += root_count
        weighted_roots += weights[b % g] * root_count
        t = t * q % p

    conditioned = weighted_roots / (len(S60) * p * (r // g))
    unconditioned = total_roots / (p * r)
    return conditioned, unconditioned


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--prime-bound", type=int, default=1000)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    primes = [p for p in primes_up_to(args.prime_bound) if p not in (2, 3, 5)]
    args.output.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    sum_mean_log = 0.0
    sum_generator_mean_log = 0.0

    with args.output.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow([
            "prime", "ord10",
            "mean_rho", "signed_bias", "scaled_bias_p_ord",
            "mean_rho_unconditioned", "signed_bias_unconditioned",
            "scaled_bias_unconditioned_p_ord",
            "mean_factor", "geom_factor", "mean_log_factor",
            "generator_mean_rho", "generator_scaled_bias_p_ord",
            "generator_geom_factor", "generator_mean_log_factor",
        ])

        for p in primes:
            ell = multiplicative_order(10, p)
            rhos = []
            rhos_unconditioned = []
            logs = []
            factors = []
            generator_rhos = []
            generator_logs = []

            for d in range(1, ell + 1):
                rho, rho_unconditioned = fast_local_densities(d, p)
                factor = (1.0 - rho) / (1.0 - 1.0 / p)
                rhos.append(rho)
                rhos_unconditioned.append(rho_unconditioned)
                factors.append(factor)
                log_factor = math.log(factor)
                logs.append(log_factor)
                if math.gcd(d, ell) == 1:
                    generator_rhos.append(rho)
                    generator_logs.append(log_factor)

            mean_rho = sum(rhos) / ell
            bias = mean_rho - 1.0 / p
            scaled = bias * p * ell
            mean_rho_unconditioned = sum(rhos_unconditioned) / ell
            bias_unconditioned = mean_rho_unconditioned - 1.0 / p
            scaled_unconditioned = bias_unconditioned * p * ell
            mean_factor = sum(factors) / ell
            mean_log = sum(logs) / ell
            geom = math.exp(mean_log)
            generator_mean_rho = sum(generator_rhos) / len(generator_rhos)
            generator_bias = generator_mean_rho - 1.0 / p
            generator_scaled = generator_bias * p * ell
            generator_mean_log = sum(generator_logs) / len(generator_logs)
            generator_geom = math.exp(generator_mean_log)

            sum_mean_log += mean_log
            sum_generator_mean_log += generator_mean_log

            rows.append((p, ell, scaled, mean_log))
            w.writerow([
                p, ell,
                f"{mean_rho:.17g}",
                f"{bias:.17g}",
                f"{scaled:.17g}",
                f"{mean_rho_unconditioned:.17g}",
                f"{bias_unconditioned:.17g}",
                f"{scaled_unconditioned:.17g}",
                f"{mean_factor:.17g}",
                f"{geom:.17g}",
                f"{mean_log:.17g}",
                f"{generator_mean_rho:.17g}",
                f"{generator_scaled:.17g}",
                f"{generator_geom:.17g}",
                f"{generator_mean_log:.17g}",
            ])

    maxrow = max(rows, key=lambda x: abs(x[2]))
    minlog = min(rows, key=lambda x: x[3])
    maxlog = max(rows, key=lambda x: x[3])

    print(
        f"prime-width-average B={args.prime_bound} primes={len(rows)} "
        f"max_abs_scaled_bias={abs(maxrow[2]):.9f}@p={maxrow[0]} "
        f"sum_mean_log={sum_mean_log:.9f} "
        f"aggregate_geom={math.exp(sum_mean_log):.9f} "
        f"generator_aggregate_geom={math.exp(sum_generator_mean_log):.9f}"
    )
    print(
        f"mean-log range: min={minlog[3]:+.9g}@p={minlog[0]} "
        f"max={maxlog[3]:+.9g}@p={maxlog[0]}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
