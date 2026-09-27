#!/usr/bin/env python3
"""Exact two-prime correlation probe for fixed-width A053067.

For a fixed decimal width d and primes p,r>5, divisibility by each prime is
periodic in the index n.  This tool computes, exactly over the common period
with the elementary mod-60 filter,

    rho_p      = P(p | A(n) | n admissible),
    rho_r      = P(r | A(n) | n admissible),
    rho_{p,r}  = P(p r | A(n) | n admissible).

The joint density is obtained by the generalized CRT from the zero classes
returned by congruence_families.zero_family(); no interval sampling and no
independence assumption are used.

The main diagnostic is

    survival_ratio =
      (1-rho_p-rho_r+rho_{p,r}) / ((1-rho_p)(1-rho_r)).

It equals 1 under pairwise independence.  Deviations measure the first
composite-modulus obstruction that a classical multiplicative sieve would
need to control.

This is a research diagnostic, not a primality proof.
"""

from __future__ import annotations

import argparse
import csv
import math
from collections import Counter
from pathlib import Path

from congruence_families import primes_up_to, zero_family
from local_product import ADMISSIBLE_MOD_60, conditioned_zero_density


def joint_zero_density(
    period_p: int,
    roots_p: list[int],
    period_r: int,
    roots_r: list[int],
) -> float:
    """Exact conditioned density of simultaneous p- and r-divisibility.

    A triple of congruences

        n = a (mod period_p),
        n = b (mod period_r),
        n = s (mod 60)

    is solvable iff the three pairwise gcd-compatibility conditions hold.
    Every compatible triple gives exactly one class modulo the joint lcm.
    """

    g_pr = math.gcd(period_p, period_r)
    g_p60 = math.gcd(period_p, 60)
    g_r60 = math.gcd(period_r, 60)
    joint_period = math.lcm(period_p, period_r, 60)

    compatible = 0
    for s in ADMISSIBLE_MOD_60:
        p_classes = Counter(
            a % g_pr
            for a in roots_p
            if a % g_p60 == s % g_p60
        )
        r_classes = Counter(
            b % g_pr
            for b in roots_r
            if b % g_r60 == s % g_r60
        )
        compatible += sum(
            count * r_classes.get(residue, 0)
            for residue, count in p_classes.items()
        )

    admissible_classes = len(ADMISSIBLE_MOD_60) * (joint_period // 60)
    return compatible / admissible_classes


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--digits", type=int, required=True)
    p.add_argument("--prime-bound", type=int, default=500)
    p.add_argument("--top", type=int, default=30)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if args.digits <= 0:
        raise SystemExit("--digits must be positive")
    if args.prime_bound < 11:
        raise SystemExit("--prime-bound must be at least 11")
    if args.top <= 0:
        raise SystemExit("--top must be positive")

    primes = [p for p in primes_up_to(args.prime_bound) if p > 5]
    families: dict[int, tuple[int, list[int], float, int, bool]] = {}
    for p in primes:
        period, roots = zero_family(args.digits, p)
        rho = conditioned_zero_density(period, roots)
        q = pow(10, args.digits, p)
        linear_degenerate = (7 * q + 1) % p == 0
        families[p] = (period, roots, rho, q, linear_degenerate)

    rows: list[dict[str, float | int]] = []
    for i, p in enumerate(primes):
        period_p, roots_p, rho_p, q_p, degenerate_p = families[p]
        for r in primes[i + 1 :]:
            period_r, roots_r, rho_r, q_r, degenerate_r = families[r]
            rho_pr = joint_zero_density(period_p, roots_p, period_r, roots_r)

            independent_joint = rho_p * rho_r
            covariance = rho_pr - independent_joint
            actual_survival = 1.0 - rho_p - rho_r + rho_pr
            independent_survival = (1.0 - rho_p) * (1.0 - rho_r)
            survival_ratio = actual_survival / independent_survival

            variance_scale = math.sqrt(
                rho_p * (1.0 - rho_p) * rho_r * (1.0 - rho_r)
            )
            phi = covariance / variance_scale if variance_scale else 0.0

            order_p = period_p // p
            order_r = period_r // r
            order_gcd = math.gcd(order_p, order_r)
            cross_order = order_r % p == 0
            period_gcd = math.gcd(period_p, period_r)
            expected_period_gcd = order_gcd * (p if cross_order else 1)
            if period_gcd != expected_period_gcd:
                raise RuntimeError(
                    f"period gcd decomposition failed for p={p}, r={r}: "
                    f"{period_gcd} != {expected_period_gcd}"
                )

            fourier_scaled_cov = (
                abs(covariance)
                * math.sqrt(p * r)
                * order_p
                * order_r
                / order_gcd
                if not cross_order
                else None
            )

            rows.append(
                {
                    "p": p,
                    "r": r,
                    "period_p": period_p,
                    "period_r": period_r,
                    "order_p": order_p,
                    "order_r": order_r,
                    "order_gcd": order_gcd,
                    "cross_order": int(cross_order),
                    "degenerate_p": int(degenerate_p),
                    "degenerate_r": int(degenerate_r),
                    "period_gcd": period_gcd,
                    "fourier_scaled_cov": (
                        fourier_scaled_cov if fourier_scaled_cov is not None else ""
                    ),
                    "rho_p": rho_p,
                    "rho_r": rho_r,
                    "rho_joint": rho_pr,
                    "rho_joint_independent": independent_joint,
                    "covariance": covariance,
                    "phi": phi,
                    "survival_ratio": survival_ratio,
                    "log_survival_ratio": math.log(survival_ratio),
                }
            )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].keys()) if rows else []
    with args.output.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        if fieldnames:
            w.writeheader()
            w.writerows(rows)

    ranked = sorted(rows, key=lambda x: abs(float(x["log_survival_ratio"])), reverse=True)
    mean_abs_log = (
        sum(abs(float(row["log_survival_ratio"])) for row in rows) / len(rows)
        if rows
        else 0.0
    )
    rms_phi = (
        math.sqrt(sum(float(row["phi"]) ** 2 for row in rows) / len(rows))
        if rows
        else 0.0
    )

    mean_divisor_count = sum(float(families[p][2]) for p in primes)
    independent_variance = sum(
        float(families[p][2]) * (1.0 - float(families[p][2]))
        for p in primes
    )
    signed_pair_covariance = sum(float(row["covariance"]) for row in rows)
    absolute_pair_covariance = sum(abs(float(row["covariance"])) for row in rows)
    total_variance = independent_variance + 2.0 * signed_pair_covariance

    print(
        f"d={args.digits} B={args.prime_bound} primes={len(primes)} "
        f"pairs={len(rows)} mean_abs_log_survival_ratio={mean_abs_log:.9g} "
        f"rms_phi={rms_phi:.9g}"
    )
    print(
        f"divisor_count_mean={mean_divisor_count:.9g} "
        f"independent_variance={independent_variance:.9g} "
        f"signed_pair_covariance={signed_pair_covariance:+.9g} "
        f"absolute_pair_covariance={absolute_pair_covariance:.9g} "
        f"total_variance={total_variance:.9g} "
        f"variance_over_mean={total_variance / mean_divisor_count:.9g}"
    )

    noncross_nondegenerate = [
        row for row in rows
        if int(row["cross_order"]) == 0
        and int(row["degenerate_p"]) == 0
        and int(row["degenerate_r"]) == 0
    ]
    if noncross_nondegenerate:
        max_fourier_scaled = max(
            float(row["fourier_scaled_cov"]) for row in noncross_nondegenerate
        )
        mean_fourier_scaled = sum(
            float(row["fourier_scaled_cov"]) for row in noncross_nondegenerate
        ) / len(noncross_nondegenerate)
        print(
            f"fourier_nondegenerate_noncross pairs={len(noncross_nondegenerate)} "
            f"mean_scaled_cov={mean_fourier_scaled:.9g} "
            f"max_scaled_cov={max_fourier_scaled:.9g}"
        )

    degenerate_primes = [
        p for p in primes if bool(families[p][4])
    ]
    print(
        f"linear_degenerate_primes={len(degenerate_primes)} "
        f"values={','.join(map(str, degenerate_primes)) if degenerate_primes else '-'}"
    )

    for threshold in (13, 29, 53, 101, 211):
        subset = [row for row in rows if int(row["p"]) >= threshold]
        if not subset:
            continue
        subset_mean_abs_log = sum(
            abs(float(row["log_survival_ratio"])) for row in subset
        ) / len(subset)
        subset_rms_phi = math.sqrt(
            sum(float(row["phi"]) ** 2 for row in subset) / len(subset)
        )
        subset_max_abs_log = max(
            abs(float(row["log_survival_ratio"])) for row in subset
        )
        print(
            f"min_prime>={threshold} pairs={len(subset)} "
            f"mean_abs_log_survival_ratio={subset_mean_abs_log:.9g} "
            f"rms_phi={subset_rms_phi:.9g} "
            f"max_abs_log_survival_ratio={subset_max_abs_log:.9g}"
        )

    for label, subset in (
        ("cross_order", [row for row in rows if int(row["cross_order"]) == 1]),
        ("no_cross_order", [row for row in rows if int(row["cross_order"]) == 0]),
    ):
        if not subset:
            continue
        subset_mean_abs_log = sum(
            abs(float(row["log_survival_ratio"])) for row in subset
        ) / len(subset)
        subset_rms_phi = math.sqrt(
            sum(float(row["phi"]) ** 2 for row in subset) / len(subset)
        )
        subset_max_abs_log = max(
            abs(float(row["log_survival_ratio"])) for row in subset
        )
        print(
            f"{label} pairs={len(subset)} "
            f"mean_abs_log_survival_ratio={subset_mean_abs_log:.9g} "
            f"rms_phi={subset_rms_phi:.9g} "
            f"max_abs_log_survival_ratio={subset_max_abs_log:.9g}"
        )

    print("largest pairwise deviations from independent survival:")
    for row in ranked[: args.top]:
        print(
            "p={p:>5} r={r:>5} gcdP={period_gcd:>7} "
            "rho_pr={rho_joint:.8g} indep={rho_joint_independent:.8g} "
            "surv_ratio={survival_ratio:.9g} phi={phi:+.6g}".format(**row)
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
