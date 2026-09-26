#!/usr/bin/env python3
"""Probe sieve survivors for factors coming from q^k +/- 1.

For a fixed-width A053067 block of decimal width d, q=10^d.  Any nontrivial
gcd(A_d(n), q^k-1) or gcd(A_d(n), q^k+1) supplies an exact structural divisor,
possibly much larger than the original trial-prime sieve bound.

The modular evaluator works without constructing A_d(n).
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path


def compose(after, before, modulus):
    a2,b2,c2,k2=after
    a1,b1,c1,k1=before
    return (
        a2*a1 % modulus,
        (a2*b1+b2) % modulus,
        (a2*c1+b2*(k1 % modulus)+c2) % modulus,
        k1+k2,
    )


def transition_pow(q: int, count: int, modulus: int):
    result=(1,0,0,0)
    base=(q % modulus,1 % modulus,0,1)
    while count:
        if count & 1:
            result=compose(base,result,modulus)
        count >>= 1
        if count:
            base=compose(base,base,modulus)
    return result


def fixed_mod(n: int, d: int, modulus: int) -> int:
    lo=n*(n-1)//2+1
    q=10**d
    a,b,c,_=transition_pow(q,n,modulus)
    return (b*(lo % modulus)+c) % modulus


def main() -> int:
    p=argparse.ArgumentParser()
    p.add_argument("csv", type=Path)
    p.add_argument("--digits", type=int, required=True)
    p.add_argument("--max-k", type=int, default=60)
    p.add_argument("--output", type=Path)
    args=p.parse_args()

    rows=list(csv.DictReader(args.csv.open(newline="")))
    survivors=[int(r["n"]) for r in rows if r["status"]=="sieve_survivor"]
    q=10**args.digits
    found=[]

    for n in survivors:
        hit=None
        for k in range(1,args.max_k+1):
            for sign in (-1,1):
                modulus=q**k+sign
                g=math.gcd(fixed_mod(n,args.digits,modulus),modulus)
                if g>1:
                    hit=(n,k,sign,g)
                    break
            if hit:
                break
        if hit:
            found.append(hit)

    lines=[
        f"survivors={len(survivors)}",
        f"digits={args.digits}",
        f"max_k={args.max_k}",
        f"caught={len(found)}",
    ]
    for n,k,sign,g in found:
        op="+" if sign==1 else "-"
        lines.append(f"n={n}: gcd(A, q^{k}{op}1)={g}")

    text="\n".join(lines)+"\n"
    print(text,end="")
    if args.output:
        args.output.parent.mkdir(parents=True,exist_ok=True)
        args.output.write_text(text)
    return 0


if __name__=="__main__":
    raise SystemExit(main())
