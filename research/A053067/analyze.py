#!/usr/bin/env python3
"""Validate and summarize A053067 search CSV evidence.

This analyzer is deliberately independent of the C++ searcher's modular code.
It verifies explicit factor witnesses, detects duplicate/missing indices, and
keeps GMP-only compositeness separate from mathematically checkable factors.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from collections import Counter
from pathlib import Path


def bounds(n: int) -> tuple[int, int]:
    return n * (n - 1) // 2 + 1, n * (n + 1) // 2


def elementary_candidate(n: int) -> bool:
    if n <= 2:
        return True
    if n % 3 == 0:
        return False
    _, hi = bounds(n)
    return hi % 10 in {1, 3, 7, 9}


def compose(
    after: tuple[int, int, int, int],
    before: tuple[int, int, int, int],
    modulus: int,
) -> tuple[int, int, int, int]:
    a2, b2, c2, k2 = after
    a1, b1, c1, k1 = before
    return (
        a2 * a1 % modulus,
        (a2 * b1 + b2) % modulus,
        (a2 * c1 + b2 * (k1 % modulus) + c2) % modulus,
        k1 + k2,
    )


def transition_pow(q: int, count: int, modulus: int) -> tuple[int, int, int, int]:
    result = (1, 0, 0, 0)
    base = (q % modulus, 1 % modulus, 0, 1)
    while count:
        if count & 1:
            result = compose(base, result, modulus)
        count >>= 1
        if count:
            base = compose(base, base, modulus)
    return result


def concat_mod(n: int, modulus: int) -> int:
    lo, hi = bounds(n)
    value = 0
    cur = lo
    while cur <= hi:
        digits = len(str(cur))
        p10 = 10**digits
        end = min(hi, p10 - 1)
        count = end - cur + 1
        a, b, c, _ = transition_pow(p10, count, modulus)
        value = (a * value + b * cur + c) % modulus
        cur = end + 1
    return value


def is_prime_small(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    p = 3
    while p * p <= n:
        if n % p == 0:
            return False
        p += 2
    return True


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("csv", nargs="+", type=Path)
    p.add_argument("--start", type=int)
    p.add_argument("--end", type=int)
    p.add_argument("--allow-partial", action="store_true")
    p.add_argument("--json-out", type=Path)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if (args.start is None) != (args.end is None):
        raise SystemExit("--start and --end must be supplied together")
    if args.start is not None and args.start > args.end:
        raise SystemExit("--start must not exceed --end")

    rows_by_n: dict[int, dict[str, str]] = {}
    files = []
    counts: Counter[str] = Counter()

    for path in args.csv:
        digest = sha256(path)
        file_rows = 0
        with path.open(newline="") as f:
            reader = csv.DictReader(f)
            expected_fields = ["n", "status", "witness", "digits"]
            if reader.fieldnames != expected_fields:
                raise SystemExit(f"{path}: unexpected CSV header {reader.fieldnames!r}")
            for row in reader:
                file_rows += 1
                n = int(row["n"])
                if n in rows_by_n:
                    raise SystemExit(f"duplicate n={n} across input CSVs")
                if not elementary_candidate(n):
                    raise SystemExit(f"n={n} should have been removed by the exact 2/3/5 sieve")

                status = row["status"]
                if status not in {"small_factor", "composite_prp", "probable_prime"}:
                    raise SystemExit(f"n={n}: unknown status {status!r}")

                if status == "small_factor":
                    if not row["witness"]:
                        raise SystemExit(f"n={n}: missing factor witness")
                    factor = int(row["witness"])
                    if not is_prime_small(factor):
                        raise SystemExit(f"n={n}: witness {factor} is not prime")
                    if concat_mod(n, factor) != 0:
                        raise SystemExit(f"n={n}: witness {factor} does not divide A053067(n)")
                elif row["witness"] and status == "composite_prp":
                    raise SystemExit(f"n={n}: unexpected witness on GMP-only composite row")

                rows_by_n[n] = row
                counts[status] += 1

        files.append({"path": str(path), "sha256": digest, "rows": file_rows})

    coverage = None
    if args.start is not None:
        expected = {
            n for n in range(args.start, args.end + 1)
            if elementary_candidate(n)
        }
        actual = set(rows_by_n)
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        coverage = {
            "start": args.start,
            "end": args.end,
            "expected_candidates": len(expected),
            "actual_rows": len(actual),
            "missing": missing,
            "extra": extra,
        }
        if (missing or extra) and not args.allow_partial:
            raise SystemExit(
                f"coverage mismatch: missing={missing[:20]} extra={extra[:20]}"
            )

    probable = sorted(
        n for n, row in rows_by_n.items()
        if row["status"] == "probable_prime"
    )

    manifest = {
        "sequence": "OEIS A053067",
        "files": files,
        "counts": dict(sorted(counts.items())),
        "rows": len(rows_by_n),
        "coverage": coverage,
        "probable_prime_candidates": probable,
        "evidence_boundary": {
            "small_factor": "explicit prime divisor independently rechecked",
            "composite_prp": "GMP reported composite; no standalone certificate stored",
            "probable_prime": "candidate only; requires independent rigorous certification",
        },
    }

    print(json.dumps(manifest, indent=2, sort_keys=True))
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")

    return 10 if probable else 0


if __name__ == "__main__":
    raise SystemExit(main())
