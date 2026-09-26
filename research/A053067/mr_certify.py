#!/usr/bin/env python3
"""Produce replayable strong Miller-Rabin compositeness witnesses for A053067.

Input is one or more search CSV files. Rows already carrying explicit small
prime factors are ignored. For each `composite_prp` row, this script
reconstructs A053067(n), searches a fixed list of small bases, and records the
first base for which the strong probable-prime condition fails.

A failing strong Miller-Rabin base is a rigorous certificate of compositeness:
every odd prime passes the strong test for every base coprime to it.

This tool is intentionally separate from the fast search path. It upgrades
evidence after a bounded scan has completed.
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

# Python 3.11+ protects decimal-to-int conversions above a few thousand digits
# by default. Research terms are intentionally much larger.
if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(0)


BASES = [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
    53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107,
    109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167,
    173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
    233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
    293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359,
    367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431,
    433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491,
    499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571,
    577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641,
    643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709,
    719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787,
    797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859,
    863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941,
    947, 953, 967, 971, 977, 983, 991, 997,
]


def bounds(n: int) -> tuple[int, int]:
    return n * (n - 1) // 2 + 1, n * (n + 1) // 2


def decimal(n: int) -> str:
    lo, hi = bounds(n)
    return "".join(str(x) for x in range(lo, hi + 1))


def strong_mr_witness(N: int, a: int) -> bool:
    """True iff base a proves odd N composite by the strong MR criterion."""
    if N < 4 or N % 2 == 0:
        return N != 2

    a %= N
    if a in (0, 1):
        return False

    # A nontrivial gcd is already a compositeness witness.  We still classify
    # the base as successful; the verifier repeats the same gcd/test logic.
    from math import gcd

    g = gcd(a, N)
    if 1 < g < N:
        return True

    d = N - 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1

    x = pow(a, d, N)
    if x == 1 or x == N - 1:
        return False

    for _ in range(1, s):
        x = x * x % N
        if x == N - 1:
            return False
        if x == 1:
            return True

    return True


def find_witness(N: int) -> int | None:
    for a in BASES:
        if a >= N:
            break
        if strong_mr_witness(N, a):
            return a
    return None


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("csv", nargs="+", type=Path)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    targets: dict[int, int] = {}

    for path in args.csv:
        with path.open(newline="") as f:
            for row in csv.DictReader(f):
                if row["status"] != "composite_prp":
                    continue
                n = int(row["n"])
                if n in targets:
                    raise SystemExit(f"duplicate composite_prp n={n}")
                targets[n] = int(row["digits"])

    args.output.parent.mkdir(parents=True, exist_ok=True)
    unresolved = []

    with args.output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["n", "kind", "witness", "digits"])

        for n in sorted(targets):
            text = decimal(n)
            if targets[n] and len(text) != targets[n]:
                raise SystemExit(
                    f"n={n}: stored digit count {targets[n]} != reconstructed {len(text)}"
                )
            N = int(text)
            witness = find_witness(N)
            if witness is None:
                unresolved.append(n)
                writer.writerow([n, "unresolved", "", len(text)])
            else:
                # Replay immediately before persisting the certificate.
                assert strong_mr_witness(N, witness)
                writer.writerow([n, "strong_mr", witness, len(text)])
                print(f"n={n}: strong Miller-Rabin witness base {witness}")

    if unresolved:
        print(
            "No witness among configured bases for: "
            + ", ".join(map(str, unresolved)),
            file=sys.stderr,
        )
        return 1

    print(f"Certified {len(targets)} composite rows.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
