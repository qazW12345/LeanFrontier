# Pair correlations between local prime divisibility events

The one-prime Euler factors for A053067 predict the actual sieve remarkably
well.  This note studies the first possible obstruction to that model:
correlations between divisibility by two distinct primes.

## 1. Unconditioned exact covariance identity

Fix one decimal width \(d\).  Let distinct local primes \(p,r>5\) have exact
index periods

\[
P_p,\qquad P_r
\]

and zero-class sets

\[
R_p\subseteq\mathbb Z/P_p\mathbb Z,
\qquad
R_r\subseteq\mathbb Z/P_r\mathbb Z.
\]

Put

\[
g=\gcd(P_p,P_r).
\]

For each residue \(c\bmod g\), define

\[
\alpha_c
=
\#\{a\in R_p:a\equiv c\pmod g\},
\]

\[
\beta_c
=
\#\{b\in R_r:b\equiv c\pmod g\}.
\]

A pair of zero classes \(a,b\) is simultaneously realizable iff

\[
a\equiv b\pmod g.
\]

Hence over the common period

\[
L=\operatorname{lcm}(P_p,P_r)=\frac{P_pP_r}{g},
\]

the exact joint density is

\[
\boxed{
\rho_{p,r}
=
\frac{g}{P_pP_r}
\sum_{c\bmod g}\alpha_c\beta_c.
}
\]

The marginal densities are

\[
\rho_p=\frac{|R_p|}{P_p},
\qquad
\rho_r=\frac{|R_r|}{P_r}.
\]

Writing

\[
\bar\alpha=\frac{|R_p|}{g},
\qquad
\bar\beta=\frac{|R_r|}{g},
\]

gives the exact covariance formula

\[
\boxed{
\rho_{p,r}-\rho_p\rho_r
=
\frac{g}{P_pP_r}
\sum_{c\bmod g}
(\alpha_c-\bar\alpha)
(\beta_c-\bar\beta).
}
\]

Thus two-prime dependence comes **only** from nonuniform distribution of the
two zero sets modulo the shared period factor \(g\).

By Cauchy--Schwarz,

\[
\boxed{
|\rho_{p,r}-\rho_p\rho_r|
\le
\frac{g}{P_pP_r}
\sqrt{E_p(g)E_r(g)},
}
\]

where

\[
E_p(g)=
\sum_{c\bmod g}(\alpha_c-\bar\alpha)^2.
\]

This is the natural analytic object for pair-correlation bounds.

## 2. Exact elementary-filter conditioning

The actual A053067 sieve conditions on

\[
S=
\{1,2,13,17,22,26,37,38,41,46,53,58\}
\pmod{60}.
\]

The script pair_correlation_probe.py computes the conditioned analogue exactly.

For a candidate class \(s\in S\), retain only zero classes satisfying the
compatibility conditions with \(s\bmod60\), and count their residues modulo

\[
g=\gcd(P_p,P_r).
\]

The generalized CRT then gives the exact joint zero density over

\[
\operatorname{lcm}(P_p,P_r,60).
\]

No interval sampling or independence approximation is used.

The conditioned formula is therefore a bounded sum of the same discrepancy
inner products, one for each elementary candidate class.

## 3. Why correlations should usually be small

For prime decimal width \(d\) and local primes below \(d\),

\[
P_p=p\,\operatorname{ord}_p(10),
\]

because no order collapse occurs.

Large correlations then require two things simultaneously:

1. a nontrivial shared factor
   \[
   g=\gcd(P_p,P_r),
   \]
   and
2. biased root distributions modulo that shared factor.

The first requirement already suppresses most pairs.  The second is another
multiplicative-character equidistribution problem over subgroup cosets.

Thus the pairwise-independence question reduces naturally to the same
finite-field machinery that controls the one-prime local density.

## 4. Exact numerical experiments

### Width d = 101, primes through 500

Hosted run 36278395653 tested

\[
92
\]

local primes and all

\[
4186
\]

pairs.

It found

\[
\boxed{
\operatorname{mean}
\left|
\log
\frac{
1-\rho_p-\rho_r+\rho_{p,r}
}{
(1-\rho_p)(1-\rho_r)
}
\right|
=
1.29294\times10^{-5}.
}
\]

The RMS phi correlation was

\[
\boxed{0.00308886}.
\]

The largest visible deviations were driven by the very smallest primes.

### Width d = 503, primes through 500

Hosted run 36278516001 repeated the same 4186 exact pair calculations in a
larger prime-width generator regime.

It found

\[
\boxed{
\operatorname{mean\ absolute\ log\ survival\ deviation}
=
1.10541\times10^{-5},
}
\]

and

\[
\boxed{
\operatorname{RMS\ phi}=0.00252179.
}
\]

Thus pairwise dependence became slightly smaller rather than larger.

### Width d = 1009, primes through 1000

Hosted run 36278637510 tested all

\[
\binom{165}{2}=13530
\]

pairs of the 165 local primes through 1000.  Since

\[
p<d=1009
\]

for every tested prime, the entire experiment lies in the full-order
generator regime.

The global statistics improved again:

\[
\boxed{
\operatorname{mean}|\log R_{p,r;d}|
=
4.80390\times10^{-6},
}
\]

and

\[
\boxed{
\operatorname{RMS\ phi}
=
0.00182964.
}
\]

More importantly, stratifying by the smaller local prime shows a sharp
small-prime concentration:

| lower bound on both primes | pairs | mean \(|\log R|\) | RMS phi | maximum \(|\log R|\) |
| ---: | ---: | ---: | ---: | ---: |
| 13 | 13203 | \(1.20983\times10^{-6}\) | \(7.03185\times10^{-4}\) | \(1.15808\times10^{-3}\) |
| 29 | 12561 | \(3.52846\times10^{-7}\) | \(2.96191\times10^{-4}\) | \(1.38879\times10^{-4}\) |
| 53 | 11628 | \(2.52592\times10^{-7}\) | \(2.61938\times10^{-4}\) | \(1.38879\times10^{-4}\) |
| 101 | 10153 | \(9.14759\times10^{-8}\) | \(1.28618\times10^{-4}\) | \(2.36180\times10^{-5}\) |
| 211 | 7381 | \(3.08540\times10^{-8}\) | \(5.90840\times10^{-5}\) | \(4.94607\times10^{-6}\) |

Thus the average correlation tail falls by more than two orders of magnitude
once the smallest local primes are removed, while thousands of pairs remain
in each sample.

This strongly suggests a more precise analytic decomposition:

1. handle a finite set of small local primes explicitly;
2. seek a uniform or average bound for the discrepancy energy when
   \(\min(p,r)\) is large;
3. prove that the resulting tail is summable over prime pairs.

The data do not yet identify the optimal decay exponent, but they make this a
substantially sharper target than an undifferentiated two-prime correlation
bound.

## 5. Sieve-theoretic significance

The success of the one-prime local product could in principle have been an
accident caused by compensating higher correlations.

The exact pair experiments provide evidence against that explanation:
two-prime survival is already extremely close to the product of the one-prime
survivals.

A rigorous bound on the discrepancy energies

\[
E_p(g)
\]

uniform enough to sum over local-prime pairs would give a second-moment
version of the Euler-product heuristic.

This does not by itself cross the parity barrier to prime values, but it is a
natural route toward a theorem that the actual small-prime sieve has the
density predicted by the local product.

## 6. Analytic target

For generator-regime local primes, seek a bound of the schematic form

\[
E_p(g)
\ll
\frac{\ell_p}{g}\,p^{1-\delta}
\]

or any alternative estimate whose insertion into

\[
\frac{g}{P_pP_r}
\sqrt{E_p(g)E_r(g)}
\]

is summable over the relevant prime pairs.

Because \(g\) divides combinations of multiplicative orders, average-order
results for

\[
\operatorname{ord}_p(10)
\]

and gcds of such orders may combine naturally with character-sum estimates.

This is the next layer beyond the one-prime singular-series analysis.
