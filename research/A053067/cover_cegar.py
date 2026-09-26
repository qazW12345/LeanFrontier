#!/usr/bin/env python3
"""Counterexample-guided search for a finite A053067 fixed-width divisor covering.

This is a proof-discovery tool, not a proof checker.

For a hypothetical fixed-width A053067 block with decimal width d, put q=10^d.
For n>=1 define L=n(n-1)/2+1 and U=n(n+1)/2.  The fixed-width term F(d,n)
satisfies

  F(d,n) (q-1)^2 =
    q^n ((q-1)L+1) - ((q-1)U+q).

For a prime p, divisibility of F(d,n) depends only on d modulo ord_p(10)
and n modulo p*ord_p(10^d) (or modulo p when 10^d == 1 mod p).

The CEGAR loop asks Z3 for an admissible (d,n) not covered by the currently
known divisor progressions.  It then searches a finite prime pool for a prime
dividing F(d,n), adds the exact 2-D arithmetic progression containing that
counterexample, and repeats.

If Z3 eventually returns UNSAT, the emitted progression list is a finite
covering certificate for *all hypothetical fixed-width states* satisfying the
elementary A053067 filter, hence in particular for all genuine fixed-width
A053067 blocks.  This is stronger than needed.

If a SAT model has no factor in the configured prime pool, that does NOT mean
the corresponding term is prime; it only means the current discovery pool is
insufficient.
"""

from __future__ import annotations

import argparse
import csv
import math
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path


ADMISSIBLE_MOD_60 = (1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58)


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
    return [p for p in range(2, limit + 1) if sieve[p]]


def prime_factors(n: int) -> list[int]:
    out: list[int] = []
    p = 2
    while p * p <= n:
        if n % p == 0:
            out.append(p)
            while n % p == 0:
                n //= p
        p += 1 if p == 2 else 2
    if n > 1:
        out.append(n)
    return out


def multiplicative_order(a: int, p: int) -> int:
    a %= p
    if math.gcd(a, p) != 1:
        raise ValueError("order requires a unit")
    order = p - 1
    for r in prime_factors(order):
        while order % r == 0 and pow(a, order // r, p) == 1:
            order //= r
    return order


def fixed_mod(d: int, n: int, p: int) -> int:
    """F(d,n) mod p for the fixed-width algebraic term."""
    inv2 = pow(2, -1, p)
    a = n % p
    lo = (a * (a - 1) * inv2 + 1) % p
    hi = (a * (a + 1) * inv2) % p
    q = pow(10, d, p)

    if q == 1:
        return a * (a * a + 1) * inv2 % p

    numerator = (
        pow(q, n, p) * (((q - 1) * lo + 1) % p)
        - (((q - 1) * hi + q) % p)
    ) % p
    return numerator * pow((q - 1) * (q - 1) % p, -1, p) % p


@dataclass(frozen=True)
class Clause:
    prime: int
    d_period: int
    d_residue: int
    n_period: int
    n_residue: int

    @property
    def cell_size(self) -> int:
        return self.d_period * self.n_period


def clause_for(p: int, d: int, n: int) -> Clause:
    d_period = multiplicative_order(10, p)
    d_residue = d % d_period
    q = pow(10, d, p)
    q_order = 1 if q == 1 else multiplicative_order(q, p)
    n_period = p if q == 1 else p * q_order
    n_residue = n % n_period
    if fixed_mod(d, n, p) != 0:
        raise AssertionError("candidate clause does not divide model state")
    return Clause(p, d_period, d_residue, n_period, n_residue)


def smt_problem(clauses: list[Clause], min_d: int, timeout_ms: int) -> str:
    allowed = " ".join(f"(= (mod n 60) {r})" for r in ADMISSIBLE_MOD_60)
    lines = [
        f"(set-option :timeout {timeout_ms})",
        "(set-option :produce-models true)",
        "(declare-const d Int)",
        "(declare-const n Int)",
        f"(assert (>= d {min_d}))",
        "(assert (> n 2))",
        f"(assert (or {allowed}))",
    ]
    for c in clauses:
        lines.append(
            "(assert (not (and "
            f"(= (mod d {c.d_period}) {c.d_residue}) "
            f"(= (mod n {c.n_period}) {c.n_residue})"
            ")))"
        )
    lines += ["(check-sat)", "(get-value (d n))"]
    return "\n".join(lines) + "\n"


def solve(z3: str, smt: str) -> tuple[str, tuple[int, int] | None, str]:
    proc = subprocess.run(
        [z3, "-in"],
        input=smt,
        text=True,
        capture_output=True,
        check=False,
    )
    raw = (proc.stdout + "\n" + proc.stderr).strip()
    first = proc.stdout.splitlines()[0].strip() if proc.stdout.splitlines() else ""
    if first == "unsat":
        return "unsat", None, raw
    if first == "unknown":
        return "unknown", None, raw
    if first != "sat":
        return "error", None, raw

    m = re.search(r"\(\(d\s+(-?\d+)\)\s+\(n\s+(-?\d+)\)\)", proc.stdout)
    if not m:
        return "error", None, raw
    return "sat", (int(m.group(1)), int(m.group(2))), raw


def choose_factor(
    d: int,
    n: int,
    primes: list[int],
    selected: set[tuple[int, int, int, int, int]],
) -> Clause | None:
    best: Clause | None = None
    for p in primes:
        if p in (2, 3, 5):
            continue
        if fixed_mod(d, n, p) != 0:
            continue
        c = clause_for(p, d, n)
        key = (c.prime, c.d_period, c.d_residue, c.n_period, c.n_residue)
        if key in selected:
            continue
        if best is None or (c.cell_size, c.prime) < (best.cell_size, best.prime):
            best = c
    return best


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--prime-bound", type=int, default=100000)
    p.add_argument("--iterations", type=int, default=200)
    p.add_argument("--min-d", type=int, default=3)
    p.add_argument("--z3", default="z3")
    p.add_argument("--timeout-ms", type=int, default=10000)
    p.add_argument("--csv-out", type=Path, required=True)
    p.add_argument("--smt-out", type=Path)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    pool = primes_up_to(args.prime_bound)
    clauses: list[Clause] = []
    selected: set[tuple[int, int, int, int, int]] = set()

    args.csv_out.parent.mkdir(parents=True, exist_ok=True)
    with args.csv_out.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "iteration", "status", "model_d", "model_n", "prime",
            "d_period", "d_residue", "n_period", "n_residue",
        ])

        for iteration in range(args.iterations + 1):
            smt = smt_problem(clauses, args.min_d, args.timeout_ms)
            if args.smt_out:
                args.smt_out.parent.mkdir(parents=True, exist_ok=True)
                args.smt_out.write_text(smt)

            status, model, raw = solve(args.z3, smt)
            if status == "unsat":
                writer.writerow([iteration, "unsat", "", "", "", "", "", "", ""])
                print(
                    f"UNSAT after {len(clauses)} clauses: finite fixed-width covering found."
                )
                return 0

            if status != "sat" or model is None:
                writer.writerow([iteration, status, "", "", "", "", "", "", ""])
                print(raw)
                return 2

            d, n = model
            c = choose_factor(d, n, pool, selected)
            if c is None:
                writer.writerow([iteration, "pool_survivor", d, n, "", "", "", "", ""])
                print(
                    f"SAT model d={d} n={n} has no divisor <= {args.prime_bound} "
                    "in the configured pool."
                )
                return 3

            key = (c.prime, c.d_period, c.d_residue, c.n_period, c.n_residue)
            selected.add(key)
            clauses.append(c)
            writer.writerow([
                iteration, "add_clause", d, n, c.prime,
                c.d_period, c.d_residue, c.n_period, c.n_residue,
            ])
            f.flush()
            print(
                f"{iteration:4d}: model d={d} n={n}; add p={c.prime}, "
                f"d={c.d_residue} mod {c.d_period}, "
                f"n={c.n_residue} mod {c.n_period}"
            )

    print(f"Iteration limit reached with {len(clauses)} clauses.")
    return 4


if __name__ == "__main__":
    raise SystemExit(main())
