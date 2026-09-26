# Period-corrected local Euler product for A053067

This experiment tests whether the exact local divisibility densities of the
fixed-width A053067 sequence behave approximately independently across primes.

It uses the genuine ten-digit interval

\[
50001\le n\le100000,
\]

which lies entirely inside the fixed-width \(d=10\) range. Exactly 10000
indices in this interval survive the exact elementary \(2,3,5\) filter.

## Exact local factor

For each prime \(p>5\), let \(P_{p,d}\) be the exact period of
\(A(n)\bmod p\), and let \(Z_{p,d}\) be the zero residue classes computed
by congruence_families.py.

The elementary admissible classes are

\[
S=\{1,2,13,17,22,26,37,38,41,46,53,58\}\pmod{60}.
\]

Put

\[
g=\gcd(P_{p,d},60).
\]

Over one joint period \(\operatorname{lcm}(P_{p,d},60)\), the exact
conditional divisibility density is

\[
\rho_{p,d}
=
\Pr\bigl(p\mid A(n)\mid n\bmod60\in S\bigr).
\]

Computationally,

\[
\rho_{p,d}
=
\frac{
\displaystyle\sum_{z\in Z_{p,d}}
\#\{s\in S:s\equiv z\pmod g\}
}{
12\,P_{p,d}/g
}.
\]

No independence assumption enters this local density.

The period-corrected product through \(B\) is then

\[
M_d(B)=\prod_{5<p\le B}(1-\rho_{p,d}).
\]

For comparison, the naive random-integer product is

\[
R(B)=\prod_{5<p\le B}\left(1-\frac1p\right),
\]

and the local correction factor is

\[
C_d(B)=\frac{M_d(B)}{R(B)}.
\]

## Hosted experiment

GitHub Actions run: 36262328025

Triggering commit: 4b7ee93a7b915f7635d1821c53e86ed31fc68c92

| prime cutoff B | exact sieve survival | local-product prediction | naive random product | local correction | relative error |
|---:|---:|---:|---:|---:|---:|
| 200 | 0.48440000 | 0.48267949 | 0.38960490 | 1.23889483 | -0.3552% |
| 1000 | 0.38120000 | 0.38277108 | 0.30361974 | 1.26069234 | +0.4121% |
| 5000 | 0.31150000 | 0.31102288 | 0.24680895 | 1.26017667 | -0.1532% |
| 10000 | 0.28890000 | 0.28764290 | 0.22831760 | 1.25983674 | -0.4351% |

Thus the exact local correction stabilizes near

\[
\boxed{C_{10}\approx1.260.}
\]

The naive random product is substantially low, but after applying the exact
A053067 local factors, the independence product tracks the true finite-interval
sieve to substantially better than one percent.

## Extrapolation to one million

The exact local product was computed through \(10^4\). For the tail
\(10^4<p\le10^6\), use the random-prime approximation justified by the
character-sum result

\[
\rho_{p,d}=\frac1p+O\!\left(\frac1{r\sqrt p}\right)
\]

when \(r=\operatorname{ord}_p(10^d)\) is large.

The exact Mertens tail factor is

\[
\prod_{10^4<p\le10^6}\left(1-\frac1p\right)
=
0.6674618616.
\]

Therefore the prediction is

\[
\boxed{0.1919906631}.
\]

The actual \(10^6\)-sieve run on the same 10000 elementary candidates found
1896 survivors, i.e.

\[
\boxed{0.1896000000}.
\]

The relative prediction error is only

\[
\boxed{+1.2609\%}.
\]

Equivalently, the model predicts about 1919.9 survivors and observes 1896,
a discrepancy of roughly 24 terms.

## Interpretation

This is strong empirical evidence for the following picture:

1. the exact A053067 congruence structure produces a nontrivial local
   correction (about +26% for ten-digit blocks);
2. after that correction is included, divisibility by different primes behaves
   remarkably close to independently;
3. the large-prime tail is already well approximated by ordinary random
   divisibility \(1/p\).

This does not prove that a later prime exists. It does, however, make a
universal-compositeness mechanism increasingly difficult to reconcile with the
data unless that mechanism is invisible to all ordinary local prime densities.

The experiment also supports the period-corrected prime heuristic advocated
for exponential/recurrence sequences: the right local factor is determined by
the actual zero density over the sequence's period modulo each prime, not by
blindly substituting \(1/p\).

## Reproduction

The exact calculation is implemented in

research/A053067/local_product.py

and the hosted workflow is

.github/workflows/research-a053067-local-product.yml.

The workflow artifact contains the complete per-prime table, including the
period, zero-class count, conditioned density, and finite-interval hit count.
