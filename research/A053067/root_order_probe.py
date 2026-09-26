#!/usr/bin/env python3
"""Probe A053067 sieve survivors via small orders of t=q^n.

For a fixed-width term let

  X=(q-1)L+1,  Y=(q-1)U+q.

If p divides A, p does not divide X, and t=q^n has exact order k modulo p,
then t=Y/X and therefore p divides

  H_k(X,Y) = X^phi(k) Phi_k(Y/X),

the homogenized k-th cyclotomic polynomial.

H_k is polynomial-sized in n and q.  This script intersects H_k with
Phi_k(q^n) and then independently verifies any resulting common factor against
A modulo that factor.  It never constructs A itself.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path


def divisors(n: int) -> list[int]:
    out = []
    for d in range(1, math.isqrt(n) + 1):
        if n % d == 0:
            out.append(d)
            if d * d != n:
                out.append(n // d)
    return sorted(out)


def trim(p: list[int]) -> list[int]:
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return p


def poly_div_exact(num: list[int], den: list[int]) -> list[int]:
    num = num[:]
    den = trim(den[:])
    if den[-1] != 1:
        raise ValueError("cyclotomic divisor must be monic")
    if len(num) < len(den):
        raise ValueError("non-exact polynomial division")

    q = [0] * (len(num) - len(den) + 1)
    while len(num) >= len(den):
        shift = len(num) - len(den)
        coeff = num[-1]
        q[shift] = coeff
        for i, c in enumerate(den):
            num[i + shift] -= coeff * c
        trim(num)

    if any(num):
        raise ValueError("polynomial division had a remainder")
    return trim(q)


def cyclotomic_table(kmax: int) -> dict[int, list[int]]:
    table: dict[int, list[int]] = {}
    for n in range(1, kmax + 1):
        poly = [-1] + [0] * (n - 1) + [1]  # x^n - 1
        for d in divisors(n):
            if d == n:
                continue
            poly = poly_div_exact(poly, table[d])
        table[n] = poly
    return table


def homogenized(coeffs: list[int], Y: int, X: int) -> int:
    degree = len(coeffs) - 1
    xp = [1] * (degree + 1)
    yp = [1] * (degree + 1)
    for i in range(1, degree + 1):
        xp[i] = xp[i - 1] * X
        yp[i] = yp[i - 1] * Y
    return sum(coeffs[i] * yp[i] * xp[degree - i] for i in range(degree + 1))


def poly_mod(coeffs: list[int], x: int, modulus: int) -> int:
    value = 0
    for c in reversed(coeffs):
        value = (value * x + c) % modulus
    return value


def compose(after, before, modulus: int):
    a2, b2, c2, k2 = after
    a1, b1, c1, k1 = before
    return (
        a2 * a1 % modulus,
        (a2 * b1 + b2) % modulus,
        (a2 * c1 + b2 * (k1 % modulus) + c2) % modulus,
        k1 + k2,
    )


def transition_pow(q: int, count: int, modulus: int):
    result = (1, 0, 0, 0)
    base = (q % modulus, 1 % modulus, 0, 1)
    while count:
        if count & 1:
            result = compose(base, result, modulus)
        count >>= 1
        if count:
            base = compose(base, base, modulus)
    return result


def concat_mod(n: int, q: int, modulus: int) -> int:
    L = n * (n - 1) // 2 + 1
    _, b, c, _ = transition_pow(q, n, modulus)
    return (b * (L % modulus) + c) % modulus


def fixed_width(n: int) -> int | None:
    L = n * (n - 1) // 2 + 1
    U = n * (n + 1) // 2
    dl = len(str(L))
    return dl if dl == len(str(U)) else None


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("csv", type=Path)
    p.add_argument("--kmax", type=int, default=20)
    p.add_argument("--output", type=Path, required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    cyclo = cyclotomic_table(args.kmax)

    rows = list(csv.DictReader(args.csv.open(newline="")))
    targets = [int(r["n"]) for r in rows if r["status"] == "sieve_survivor"]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    caught = 0

    with args.output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["n", "digits", "k", "factor"])

        for n in targets:
            d = fixed_width(n)
            if d is None:
                continue
            q = 10**d
            L = n * (n - 1) // 2 + 1
            U = n * (n + 1) // 2
            X = (q - 1) * L + 1
            Y = (q - 1) * U + q

            hit = None
            for k in range(2, args.kmax + 1):
                H = abs(homogenized(cyclo[k], Y, X))
                if H <= 1:
                    continue
                t = pow(q, n, H)
                candidate = math.gcd(H, poly_mod(cyclo[k], t, H))
                if candidate <= 1:
                    continue

                factor = math.gcd(candidate, concat_mod(n, q, candidate))
                if factor > 1:
                    hit = (k, factor)
                    break

            if hit is not None:
                caught += 1
                writer.writerow([n, d, hit[0], hit[1]])

    print(
        f"root-order probe targets={len(targets)} kmax={args.kmax} "
        f"caught={caught} unresolved={len(targets)-caught}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
