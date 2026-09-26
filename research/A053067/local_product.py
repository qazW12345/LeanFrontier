#!/usr/bin/env python3
"""Period-corrected local Euler product for fixed-width A053067.

For each odd prime p>5 and fixed decimal width d, this computes the exact
fraction rho_{p,d} of indices surviving the exact mod-60 elementary filter
for which p divides the fixed-width A053067 term.

The zero classes come from congruence_families.zero_family().  Conditioning on
n mod 60 is done exactly over lcm(60, period_p), not by assuming independence.

The script compares:
  * exact finite-interval union survival through each checkpoint;
  * the period-corrected independence product prod_p (1-rho_{p,d});
  * the naive random product prod_p (1-1/p);
  * an optional extrapolation from the exact cutoff B to a larger cutoff C
    using the random tail product prod_{B<p<=C} (1-1/p).

This is a research diagnostic, not a primality proof.
"""

from __future__ import annotations

import argparse
import json
import math
from collections import Counter
from pathlib import Path

from congruence_families import (
    elementary_candidate,
    fixed_width_interval,
    primes_up_to,
    zero_family,
)

ADMISSIBLE_MOD_60 = (1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58)


def conditioned_zero_density(period: int, roots: list[int]) -> float:
    """Exact P(p|A(n) | n is elementary-admissible) over one joint period."""
    g = math.gcd(period, 60)
    counts = Counter(r % g for r in ADMISSIBLE_MOD_60)

    # Over L=lcm(period,60), each admissible class s mod 60 has L/60=period/g
    # lifts.  A zero class z mod period is compatible with exactly the
    # admissible s satisfying s == z (mod g).
    killed = sum(counts[root % g] for root in roots)
    admissible = len(ADMISSIBLE_MOD_60) * (period // g)
    return killed / admissible


def interval_hits(
    lo: int,
    hi: int,
    admissible: set[int],
    period: int,
    roots: list[int],
) -> set[int]:
    hits: set[int] = set()
    for root in roots:
        first = lo + ((root - lo) % period)
        for n in range(first, hi + 1, period):
            if n in admissible:
                hits.add(n)
    return hits


def parse_checkpoints(raw: str, exact_bound: int) -> list[int]:
    vals = sorted({int(x) for x in raw.split(",") if x.strip()})
    vals = [x for x in vals if 7 <= x <= exact_bound]
    if exact_bound not in vals:
        vals.append(exact_bound)
    return sorted(set(vals))


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--digits", type=int, required=True)
    p.add_argument("--start", type=int)
    p.add_argument("--end", type=int)
    p.add_argument("--exact-prime-bound", type=int, default=10000)
    p.add_argument("--checkpoints", default="200,1000,5000,10000")
    p.add_argument("--extrapolate-bound", type=int)
    p.add_argument("--observed-survivors", type=int)
    p.add_argument("--json-out", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if args.digits <= 0:
        raise SystemExit("--digits must be positive")
    if args.exact_prime_bound < 7:
        raise SystemExit("--exact-prime-bound must be >= 7")

    width_lo, width_hi = fixed_width_interval(args.digits)
    lo = args.start if args.start is not None else width_lo
    hi = args.end if args.end is not None else width_hi
    if lo < width_lo or hi > width_hi or lo > hi:
        raise SystemExit(
            f"requested interval {lo}..{hi} is not inside fixed-width "
            f"d={args.digits} interval {width_lo}..{width_hi}"
        )

    admissible_list = [n for n in range(lo, hi + 1) if elementary_candidate(n)]
    admissible = set(admissible_list)
    checkpoints = parse_checkpoints(args.checkpoints, args.exact_prime_bound)
    checkpoint_set = set(checkpoints)

    exact_product = 1.0
    naive_product = 1.0
    covered: set[int] = set()
    checkpoint_rows: list[dict] = []
    prime_rows: list[dict] = []

    for p in primes_up_to(args.exact_prime_bound):
        if p in (2, 3, 5):
            continue

        period, roots = zero_family(args.digits, p)
        rho = conditioned_zero_density(period, roots)
        exact_product *= 1.0 - rho
        naive_product *= 1.0 - 1.0 / p

        hits = interval_hits(lo, hi, admissible, period, roots)
        covered |= hits

        prime_rows.append(
            {
                "prime": p,
                "period": period,
                "root_count": len(roots),
                "rho_conditioned": rho,
                "interval_hits": len(hits),
            }
        )

        if p in checkpoint_set:
            actual_survival = (
                (len(admissible) - len(covered)) / len(admissible)
                if admissible
                else 1.0
            )
            checkpoint_rows.append(
                {
                    "prime_bound": p,
                    "actual_union_survival": actual_survival,
                    "local_product_survival": exact_product,
                    "naive_random_survival": naive_product,
                    "local_correction_factor": exact_product / naive_product,
                    "relative_product_error": (
                        exact_product / actual_survival - 1.0
                        if actual_survival
                        else None
                    ),
                }
            )

    # If a checkpoint lies between consecutive primes, report it at the final
    # prime <= checkpoint by reconstructing from prime_rows would add clutter.
    # The configured defaults are close enough to actual primes for diagnostics.
    final_actual = (
        (len(admissible) - len(covered)) / len(admissible)
        if admissible
        else 1.0
    )

    extrapolation = None
    if args.extrapolate_bound and args.extrapolate_bound > args.exact_prime_bound:
        tail_log = 0.0
        for p in primes_up_to(args.extrapolate_bound):
            if p > args.exact_prime_bound:
                tail_log += math.log1p(-1.0 / p)
        tail = math.exp(tail_log)
        prediction = exact_product * tail
        extrapolation = {
            "from_exact_bound": args.exact_prime_bound,
            "to_bound": args.extrapolate_bound,
            "random_tail_factor": tail,
            "predicted_survival": prediction,
        }
        if args.observed_survivors is not None:
            observed = args.observed_survivors / len(admissible)
            extrapolation["observed_survivors"] = args.observed_survivors
            extrapolation["observed_survival"] = observed
            extrapolation["relative_prediction_error"] = prediction / observed - 1.0

    result = {
        "digits": args.digits,
        "fixed_width_interval": [width_lo, width_hi],
        "measured_interval": [lo, hi],
        "admissible_count": len(admissible),
        "exact_prime_bound": args.exact_prime_bound,
        "final_actual_union_survival": final_actual,
        "final_local_product_survival": exact_product,
        "final_naive_random_survival": naive_product,
        "final_local_correction_factor": exact_product / naive_product,
        "checkpoints": checkpoint_rows,
        "extrapolation": extrapolation,
        "primes": prime_rows,
    }

    args.json_out.parent.mkdir(parents=True, exist_ok=True)
    args.json_out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")

    print(
        f"d={args.digits} interval={lo}..{hi} admissible={len(admissible)} "
        f"exact_bound={args.exact_prime_bound}"
    )
    for row in checkpoint_rows:
        print(
            "B={prime_bound} actual={actual_union_survival:.8f} "
            "local={local_product_survival:.8f} "
            "naive={naive_random_survival:.8f} "
            "corr={local_correction_factor:.8f} "
            "relerr={relative_product_error:+.4%}".format(**row)
        )
    if extrapolation:
        msg = (
            f"extrapolate B={args.exact_prime_bound}->{args.extrapolate_bound} "
            f"tail={extrapolation['random_tail_factor']:.8f} "
            f"pred={extrapolation['predicted_survival']:.8f}"
        )
        if "observed_survival" in extrapolation:
            msg += (
                f" observed={extrapolation['observed_survival']:.8f} "
                f"relerr={extrapolation['relative_prediction_error']:+.4%}"
            )
        print(msg)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
