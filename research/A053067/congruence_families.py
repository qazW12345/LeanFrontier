#!/usr/bin/env python3
"""Discover periodic prime-divisor families for fixed-width A053067 blocks.

For a block in which every concatenated integer has d decimal digits, put
q = 10^d. For an odd prime p != 5, A053067(n) modulo p depends only on
n modulo lcm(p, ord_p(q)). Since ord_p(q) divides p-1, the two moduli are
coprime and the period is p * ord_p(q), except when q == 1 mod p where
the simpler period p suffices.

For each exponent class b modulo ord_p(q), the closed-form numerator is a
quadratic polynomial in a = n mod p. Solving that quadratic replaces the old
O(p * ord) exhaustive enumeration by O(ord) modular work.

The script enumerates the exact zero residue classes and measures how much
of the actual d-digit block interval they cover.
"""

from __future__ import annotations

import argparse
import json
from math import gcd


def bounds(n: int) -> tuple[int, int]:
    return n * (n - 1) // 2 + 1, n * (n + 1) // 2


def elementary_candidate(n: int) -> bool:
    if n <= 2:
        return True
    if n % 3 == 0:
        return False
    return bounds(n)[1] % 10 in {1, 3, 7, 9}


def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    p = 2
    while p * p <= limit:
        if sieve[p]:
            sieve[p * p : limit + 1 : p] = b"\x00" * (
                (limit - p * p) // p + 1
            )
        p += 1
    return [i for i in range(2, limit + 1) if sieve[i]]


def prime_factors(n: int) -> list[int]:
    result = []
    p = 2
    while p * p <= n:
        if n % p == 0:
            result.append(p)
            while n % p == 0:
                n //= p
        p += 1 if p == 2 else 2
    if n > 1:
        result.append(n)
    return result


def multiplicative_order(q: int, p: int) -> int:
    q %= p
    if gcd(q, p) != 1:
        raise ValueError("multiplicative order requires a unit")
    order = p - 1
    for r in prime_factors(order):
        while order % r == 0 and pow(q, order // r, p) == 1:
            order //= r
    return order


def crt_coprime(a: int, p: int, b: int, m: int) -> int:
    """x=a mod p, x=b mod m for coprime p,m."""
    if m == 1:
        return a % p
    return (a + p * (((b - a) * pow(p, -1, m)) % m)) % (p * m)


def sqrt_mod_prime(a: int, p: int) -> list[int]:
    """Square roots of a modulo an odd prime p (Tonelli-Shanks)."""
    a %= p
    if a == 0:
        return [0]
    if pow(a, (p - 1) // 2, p) != 1:
        return []

    if p % 4 == 3:
        r = pow(a, (p + 1) // 4, p)
    else:
        q = p - 1
        s = 0
        while q % 2 == 0:
            q //= 2
            s += 1

        z = 2
        while pow(z, (p - 1) // 2, p) != p - 1:
            z += 1

        c = pow(z, q, p)
        r = pow(a, (q + 1) // 2, p)
        t = pow(a, q, p)
        m = s

        while t != 1:
            i = 1
            tt = t * t % p
            while tt != 1:
                tt = tt * tt % p
                i += 1
                if i >= m:
                    raise RuntimeError("Tonelli-Shanks invariant failure")

            b = pow(c, 1 << (m - i - 1), p)
            r = r * b % p
            t = t * b * b % p
            c = b * b % p
            m = i

    other = (-r) % p
    return [r] if r == other else sorted([r, other])


def zero_family(d: int, p: int) -> tuple[int, list[int]]:
    """Return exact period and zero residues for fixed-width A053067 mod p."""
    if p in (2, 5):
        raise ValueError("2 and 5 are handled by the elementary decimal filter")

    q = pow(10, d, p)

    if q == 1:
        # A(n) == n(n^2+1)/2 (mod p).
        return p, sorted(set([0] + sqrt_mod_prime(-1, p)))

    order = multiplicative_order(q, p)
    period = p * order
    roots: list[int] = []
    q_minus_1 = (q - 1) % p
    qpow = 1

    # Let a = n mod p and b = n mod order, with t = q^b.
    # Twice the closed-form numerator is
    #
    #   (q-1)(t-1) a^2 - (q-1)(t+1) a + 2q(t-1).
    #
    # Thus each b gives a quadratic (or degenerate linear) congruence in a.
    for b in range(order):
        t = qpow
        A = q_minus_1 * (t - 1) % p
        B = -q_minus_1 * (t + 1) % p
        C = 2 * q * (t - 1) % p

        if A == 0:
            if B == 0:
                if C == 0:
                    # This branch is not expected for q != 1 and odd p,
                    # but keeping it makes the solver algebraically complete.
                    a_roots = range(p)
                else:
                    a_roots = ()
            else:
                a_roots = [(-C * pow(B, -1, p)) % p]
        else:
            discriminant = (B * B - 4 * A * C) % p
            inv_two_A = pow(2 * A % p, -1, p)
            a_roots = [
                (-B + root) * inv_two_A % p
                for root in sqrt_mod_prime(discriminant, p)
            ]

        for a in a_roots:
            roots.append(crt_coprime(a, p, b, order))

        qpow = qpow * q % p

    return period, sorted(set(roots))


def first_true(lo: int, hi: int, pred) -> int:
    while lo < hi:
        mid = (lo + hi) // 2
        if pred(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo


def last_true(lo: int, hi: int, pred) -> int:
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if pred(mid):
            lo = mid
        else:
            hi = mid - 1
    return lo


def fixed_width_interval(d: int) -> tuple[int, int]:
    """n interval whose entire A053067 block consists of d-digit integers."""
    low = 10 ** (d - 1)
    high = 10**d - 1

    # Generous monotone binary-search envelope.
    upper = 2 * 10 ** ((d + 1) // 2 + 1)

    nmin = first_true(1, upper, lambda n: bounds(n)[0] >= low)
    nmax = last_true(1, upper, lambda n: bounds(n)[1] <= high)
    if nmin > nmax:
        raise RuntimeError(f"no fixed-width interval for d={d}")
    return nmin, nmax


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--digits", type=int, required=True)
    p.add_argument("--prime-bound", type=int, default=200)
    p.add_argument("--top", type=int, default=20)
    p.add_argument("--json-out")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    if args.digits <= 0:
        raise SystemExit("--digits must be positive")
    if args.prime_bound < 7:
        raise SystemExit("--prime-bound must be at least 7")

    d = args.digits
    lo, hi = fixed_width_interval(d)
    admissible = [n for n in range(lo, hi + 1) if elementary_candidate(n)]
    admissible_set = set(admissible)

    families = []
    union: set[int] = set()

    for p in primes_up_to(args.prime_bound):
        if p in (2, 3, 5):
            continue
        period, roots = zero_family(d, p)
        hits: set[int] = set()
        for root in roots:
            first = lo + ((root - lo) % period)
            for n in range(first, hi + 1, period):
                if elementary_candidate(n):
                    hits.add(n)
        if not hits:
            continue
        union |= hits
        families.append(
            {
                "prime": p,
                "period": period,
                "root_count": len(roots),
                "root_density": len(roots) / period,
                "hits": len(hits),
                "roots": roots,
            }
        )

    families.sort(key=lambda row: (-row["hits"], row["prime"]))
    uncovered = sorted(admissible_set - union)

    result = {
        "digits": d,
        "prime_bound": args.prime_bound,
        "fixed_width_interval": [lo, hi],
        "admissible_count": len(admissible),
        "covered_count": len(union),
        "coverage_fraction": len(union) / len(admissible) if admissible else 1.0,
        "uncovered_count": len(uncovered),
        "uncovered": uncovered,
        "families": families,
    }

    print(
        f"d={d} interval={lo}..{hi} admissible={len(admissible)} "
        f"covered={len(union)} ({100 * result['coverage_fraction']:.2f}%) "
        f"uncovered={len(uncovered)}"
    )
    for row in families[: args.top]:
        print(
            f"p={row['prime']:>5} period={row['period']:>8} "
            f"roots={row['root_count']:>5} hits={row['hits']:>6}"
        )

    if args.json_out:
        from pathlib import Path

        path = Path(args.json_out)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
