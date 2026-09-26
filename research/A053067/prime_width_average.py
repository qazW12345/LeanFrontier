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

    with args.output.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow([
            "prime", "ord10",
            "mean_rho", "signed_bias", "scaled_bias_p_ord",
            "mean_rho_unconditioned", "signed_bias_unconditioned",
            "scaled_bias_unconditioned_p_ord",
            "mean_factor", "geom_factor", "mean_log_factor",
        ])

        for p in primes:
            ell = multiplicative_order(10, p)
            rhos = []
            rhos_unconditioned = []
            logs = []
            factors = []

            for d in range(1, ell + 1):
                period, roots = zero_family(d, p)
                rho = conditioned_zero_density(period, roots)
                rho_unconditioned = len(roots) / period
                factor = (1.0 - rho) / (1.0 - 1.0 / p)
                rhos.append(rho)
                rhos_unconditioned.append(rho_unconditioned)
                factors.append(factor)
                logs.append(math.log(factor))

            mean_rho = sum(rhos) / ell
            bias = mean_rho - 1.0 / p
            scaled = bias * p * ell
            mean_rho_unconditioned = sum(rhos_unconditioned) / ell
            bias_unconditioned = mean_rho_unconditioned - 1.0 / p
            scaled_unconditioned = bias_unconditioned * p * ell
            mean_factor = sum(factors) / ell
            mean_log = sum(logs) / ell
            geom = math.exp(mean_log)
            sum_mean_log += mean_log

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
            ])

    maxrow = max(rows, key=lambda x: abs(x[2]))
    minlog = min(rows, key=lambda x: x[3])
    maxlog = max(rows, key=lambda x: x[3])

    print(
        f"prime-width-average B={args.prime_bound} primes={len(rows)} "
        f"max_abs_scaled_bias={abs(maxrow[2]):.9f}@p={maxrow[0]} "
        f"sum_mean_log={sum_mean_log:.9f} "
        f"aggregate_geom={math.exp(sum_mean_log):.9f}"
    )
    print(
        f"mean-log range: min={minlog[3]:+.9g}@p={minlog[0]} "
        f"max={maxlog[3]:+.9g}@p={maxlog[0]}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
