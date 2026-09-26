# A053067 fixed-width analysis

This note records algebraic structure useful for reducing the search for prime terms of
OEIS A053067.

For
[
L_n = n(n-1)/2 + 1,qquad U_n = n(n+1)/2,
]
A053067(n) is the decimal concatenation of the integers
(L_n,L_n+1,ldots,U_n).

## Same-width blocks

Assume every integer in the block has exactly (d) decimal digits and put
[
q = 10^d.
]
Then concatenation is simply evaluation in base (q):
[
A_d(n)=sum_{j=0}^{n-1}(L_n+j)q^{n-1-j}.
]

Reindexing with (r=n-1-j) gives
[
A_d(n)=U_n S_n(q)-R_n(q),
]
where
[
S_n(q)=sum_{r=0}^{n-1}q^r,qquad
R_n(q)=sum_{r=0}^{n-1}r q^r.
]

Clearing denominators yields the useful closed identity
[
2(q-1)^2 A_d(n)
=
q^nigl(n(n-1)(q-1)+2qigr)
-
igl(n(n+1)(q-1)+2qigr).
]

This identity is only for a block whose members all have the same decimal width. Blocks crossing
a power of ten must be split at the boundary, exactly as the search program does.

## Primes dividing q - 1

Let (p) be an odd prime with (pmid q-1). Then (qequiv1pmod p), so positional weights
disappear:
[
A_d(n)
equiv
sum_{m=L_n}^{U_n}m
=
rac{n(n^2+1)}2
pmod p.
]

Therefore
[
pmid A_d(n)
quadLongleftarrowquad
nequiv0pmod p
 	ext{or} 
n^2equiv-1pmod p.
]

For example, for six-digit blocks (q=10^6) and
[
10^6-1=3^3cdot7cdot11cdot13cdot37.
]
This explains the frequent factors 7, 11, 13 and 37 in the computational scans.

## Primes dividing q + 1

Let (p) be an odd prime with (pmid q+1). Then (qequiv-1pmod p), and the concatenation
becomes an alternating sum of consecutive integers.

If (n) is even,
[
A_d(n)equiv n/2pmod p.
]

If (n) is odd,
[
A_d(n)equiv (n^2+1)/2pmod p.
]

Hence
[
pmid A_d(n)
]
whenever

- (n) is even and (nequiv0pmod{2p}), or
- (n) is odd and (n^2equiv-1pmod p).

These are cheap, proof-friendly divisor families and are candidates for eventual Lean lemmas.

## Same-width n-ranges

The first complete same-width ranges are:

| decimal width d | n range with every block member d digits |
|---:|---:|
| 1 | 1..3 |
| 2 | 5..13 |
| 3 | 15..44 |
| 4 | 46..140 |
| 5 | 142..446 |
| 6 | 448..1413 |
| 7 | 1415..4471 |
| 8 | 4473..14141 |
| 9 | 14143..44720 |
| 10 | 44722..141420 |

The omitted singleton gaps are precisely blocks that straddle a power of ten.

## Research direction

The computational sieve should be viewed as generating divisor certificates. The algebra above
suggests a second line of attack: cover large portions of each same-width n-range by congruence
classes coming from small-order values of (q=10^d) modulo primes. The (q=pm1) cases above
are the simplest instances.

A possible stronger approach is to derive the corresponding residue classes when q has small
multiplicative order (k>2), then search for a modular covering of admissible n. Such a covering,
if sufficiently systematic in d, could replace enormous primality tests with elementary divisor
proofs and would be particularly suitable for Lean formalization.
