#!/usr/bin/env python3
"""Moving-cutoff local correction along prime decimal widths.

For every prime width d <= D, compute

    C_d^{<d} = prod_{5<p<d} (1-rho_{p,d})/(1-1/p),

where rho_{p,d} is the exact mod-60-conditioned local A053067 zero density.

For prime d and p<d, gcd(d, ord_p(10))=1, so every factor is a generator-class
factor.  This is the exact moving product studied in PRIME_WIDTH_THEORY.md.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path

from congruence_families import primes_up_to, zero_family
from local_product import conditioned_zero_density


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--max-width", type=int, required=True)
    ap.add_argument("--output", type=Path, required=True)
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    if args.max_width < 7:
        raise SystemExit("--max-width must be at least 7")

    primes = primes_up_to(args.max_width)
    widths = [d for d in primes if d >= 7]

    args.output.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    for d in widths:
        logcorr = 0.0
        factor_count = 0
        for p in primes:
            if p >= d:
                break
            if p in (2, 3, 5):
                continue
            period, roots = zero_family(d, p)
            rho = conditioned_zero_density(period, roots)
            logcorr += math.log((1.0 - rho) / (1.0 - 1.0 / p))
            factor_count += 1

        corr = math.exp(logcorr)
        rows.append((d, factor_count, corr))

    with args.output.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["prime_width", "local_prime_count", "moving_correction"])
        for row in rows:
            w.writerow([row[0], row[1], f"{row[2]:.17g}"])

    weights = [1.0 / d for d, _, _ in rows]
    harmonic = sum(c / d for d, _, c in rows)
    baseline = sum(weights)
    hmean = harmonic / baseline
    geom = math.exp(
        sum(math.log(c) / d for d, _, c in rows) / baseline
    )

    dmin, _, cmin = min(rows, key=lambda x: x[2])
    dmax, _, cmax = max(rows, key=lambda x: x[2])

    print(
        f"moving-prime-width max_d={args.max_width} widths={len(rows)} "
        f"min={cmin:.9f}@d={dmin} max={cmax:.9f}@d={dmax} "
        f"harmonic_weighted={hmean:.9f} harmonic_geom={geom:.9f}"
    )
    print(
        f"harmonic_mass={harmonic:.9f} baseline={baseline:.9f}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
