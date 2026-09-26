# Prime-occurrence heuristic for A053067

This is a search-planning heuristic, not a theorem.

For (n>2), the exact elementary sieve leaves 12 of the 60 residue classes
modulo 60, i.e. one fifth of all indices. At such an admissible index the
number (A(n)) is already conditioned not to be divisible by 2, 3, or 5.

If (A(n)) otherwise behaves roughly like a random integer of the same size,
the prime probability conditional on avoiding 2, 3, and 5 is approximately

[
rac{1}{log A(n)}
left((1-	frac12)(1-	frac13)(1-	frac15)ight)^{-1}
=
rac{3.75}{log A(n)}.
]

At the other four fifths of indices the probability is exactly zero because
one of 2, 3, or 5 divides the term.

The decimal length is computable without constructing (A(n)): sum the digit
widths of the integers from (L_n) to (U_n). Summing the conditional
(3.75/log A(n)) hazard over the exact admissible residue classes gives the
following rough cumulative expectations after (n=2):

| upper bound | expected further prime terms | Poisson-style chance of at least one |
|---:|---:|---:|
| 100 | 0.248 | 22% |
| 1,000 | 0.395 | 33% |
| 3,000 | 0.449 | 36% |
| 5,000 | 0.472 | 38% |
| 10,000 | 0.500 | 39% |
| 100,000 | 0.582 | 44% |
| 1,000,000 | 0.650 | 48% |

The last column is (1-e^{-lambda}) with the preceding column as
(lambda); it should not be interpreted as a rigorous probability.

## Interpretation

A negative search to a surprisingly large (n) is not, by itself, surprising.
The terms become longer roughly like (2nlog_{10}n), so the individual prime
hazard falls approximately as (1/(nlog n)). The cumulative hazard therefore
grows only like (loglog n).

The checked-in scans through 3000 are broadly compatible with ordinary
small-prime sieving rather than showing an obvious anomalous factor density.
That argues for two complementary tracks:

1. continue computational search for an explicit prime witness;
2. search for structural congruence coverings or factorizations capable of
   proving compositeness for whole residue families.

The fixed-width (10^d\pm1) lemmas in `CONGRUENCES.md` are the first
structural family found on the second track.
