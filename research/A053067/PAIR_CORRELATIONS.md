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

## 3. Exact independence when the local periods are coprime

There is a large class of prime pairs for which the conditioned divisibility
events are **exactly independent**.

Let the exact local periods be \(P_p,P_r\), and assume

\[
\gcd(P_p,P_r)=1.
\]

The elementary candidate set has the exact CRT product description

\[
S=
\left\{
x\bmod60:
\begin{array}{l}
x\bmod3\in\{1,2\},\\
x\bmod4\in\{1,2\},\\
x\bmod5\in\{1,2,3\}
\end{array}
\right\}.
\]

Thus the mod-60 conditioning factors independently across the pairwise
coprime prime-power components \(3,4,5\).

Because \(P_p\) and \(P_r\) are coprime, the divisors

\[
\gcd(P_p,60),
\qquad
\gcd(P_r,60)
\]

are also coprime.  Consequently the compatibility restriction imposed by
\(S\) on the \(P_p\)-coordinate and on the \(P_r\)-coordinate separates by
the Chinese remainder theorem.

Therefore

\[
\boxed{
\gcd(P_p,P_r)=1
\quad\Longrightarrow\quad
\rho_{p,r}=\rho_p\rho_r
}
\]

even **after** conditioning on the elementary A053067 candidate classes.

Equivalently,

\[
\boxed{
\operatorname{Cov}
(1_{p\mid A(n)},1_{r\mid A(n)})
=0.
}
\]

### Generator-regime interpretation

Assume \(p<r<d\) and \(d\) is prime, so both local primes are in the
full-order generator regime. Then

\[
P_p=p\ell_p,
\qquad
P_r=r\ell_r,
\qquad
\ell_s=\operatorname{ord}_s(10).
\]

Since \(r>\ell_p\), the larger prime \(r\) cannot divide \(P_p\). Hence

\[
\gcd(P_p,P_r)=1
\]

is equivalent to the two conditions

\[
\gcd(\ell_p,\ell_r)=1
\]

and

\[
p\nmid\ell_r.
\]

The second condition is exactly the absence of the cross-order relation
observed by pair_correlation_probe.py.

For the \(d=1009,\ p,r<1000\) experiment, **5991 of 13530 pairs** satisfy
these conditions. Every one of those pairs had zero covariance to floating
precision, independently confirming the CRT argument.

This removes almost half of all tested pairs from the analytic correlation
problem entirely.

## 4. Why the remaining correlations should usually be small

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

## 3a. Exact shared-period decomposition

Write the local orders

\[
\ell_p=\operatorname{ord}_p(10^d),
\qquad
\ell_r=\operatorname{ord}_r(10^d),
\]

so that

\[
P_p=p\ell_p,\qquad P_r=r\ell_r.
\]

For distinct local primes \(p<r\), one has

\[
\ell_p\mid p-1<r,
\]

so \(r\nmid P_p\). Therefore

\[
\gcd(P_p,P_r)
=
\gcd(p\ell_p,\ell_r).
\]

Since \(p\nmid\ell_p\),

\[
\boxed{
\gcd(P_p,P_r)
=
\gcd(\ell_p,\ell_r)
\begin{cases}
p,&p\mid\ell_r,\\
1,&p\nmid\ell_r.
\end{cases}
}
\]

Thus the shared period has two mathematically distinct sources.

First, the **common-order part**

\[
h=\gcd(\ell_p,\ell_r)
\]

satisfies

\[
h\mid p-1,\qquad h\mid r-1.
\]

Hence both primes lie in the residue class \(1\bmod h\).

Second, the **cross-order resonance**

\[
p\mid\ell_r
\]

forces

\[
\boxed{r\equiv1\pmod p.}
\]

This gives an immediate analytic route to counting resonant pairs:
Brun--Titchmarsh controls the containing arithmetic progression, while the
more precise literature of Wiertelak--Moree gives natural densities for
primes \(r\) satisfying a prescribed divisibility condition

\[
m\mid\operatorname{ord}_r(10).
\]

Consequently the pair-correlation problem should be split into:

1. a sparse cross-order family \(p\mid\ell_r\);
2. a common-order family governed by divisors of
   \(\gcd(p-1,r-1)\);
3. discrepancy-energy bounds inside each shared-period class.

This is more precise than treating \(\gcd(P_p,P_r)\) as an opaque parameter.

## 5. Exact numerical experiments

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


The same run also separated the exact cross-order family.  Among all 13530
pairs,

\[
143
\]

satisfied

\[
p\mid\ell_r.
\]

For these pairs,

\[
\boxed{
\operatorname{mean}|\log R|
=
6.61669\times10^{-5},
}
\]

with RMS phi

\[
0.00661601.
\]

For the remaining 13387 pairs,

\[
\boxed{
\operatorname{mean}|\log R|
=
4.14842\times10^{-6},
}
\]

with RMS phi

\[
0.00170756.
\]

Thus cross-order pairs comprise only about one percent of the tested pairs but
have roughly sixteen times the mean log-survival deviation of the
non-cross-order family.

The largest non-cross-order deviation is still caused by the very smallest
local primes, so this is consistent with a two-stage decomposition:

1. remove or handle finitely many small primes exactly;
2. isolate the sparse cross-order family;
3. prove a summable tail estimate for the remaining common-order correlations.

## 6. Sieve-theoretic significance

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

## 7. Higher exact-independence and the covariance-scale conjecture

The CRT argument extends immediately from two local primes to any finite
family.

Let local primes \(p_1,\ldots,p_k\) have exact index periods
\(P_1,\ldots,P_k\). If

\[
\gcd(P_i,P_j)=1
\qquad(i\ne j),
\]

then after conditioning on the elementary candidate set \(S\bmod60\),

\[
\boxed{
\Pr(p_1\cdots p_k\mid A(n)\mid n\in S)
=
\prod_{i=1}^k
\Pr(p_i\mid A(n)\mid n\in S).
}
\]

Thus pairwise-coprime local periods give **exact mutual independence**, not
merely pairwise independence.

### Stress test at d = 2003, primes through 2000

Hosted run 36278790904 tested

\[
300
\]

local primes and all

\[
44850
\]

pairs in a full generator regime.

Exactly

\[
19619
\]

pairs, or

\[
\boxed{43.7436\%},
\]

had coprime local periods and therefore zero covariance exactly.

The remaining pairs split as follows:

- 24934 pairs (55.5942%) shared multiplicative-order factors but had no
  cross-order relation;
- 297 pairs (0.6622%) had a cross-order relation
  \(p\mid\operatorname{ord}_r(10)\).

The cross-order pairs have substantially larger average correlation and form
a sparse exceptional family.

### Empirical covariance-scale bound

For every one of the 44850 tested pairs,

\[
\boxed{
\frac{pr}{\gcd(P_p,P_r)}
\left|
\rho_{p,r}-\rho_p\rho_r
\right|
\le \frac12.
}
\]

Equivalently,

\[
\boxed{
\left|
\rho_{p,r}-\rho_p\rho_r
\right|
\le
\frac{\gcd(P_p,P_r)}{2pr}.
}
\]

The largest observed value of the normalized left-hand side is numerically
\(0.5\) to floating precision.

This is currently a **conjecture**, not a proved theorem.  It is much sharper
than the generic discrepancy-energy Cauchy bound and deserves direct
combinatorial investigation.

If true uniformly in the generator regime, it reduces pairwise dependence to
the arithmetic average of

\[
\gcd(P_p,P_r)
\]

and the sparse cross-order relations between multiplicative orders.

A larger \(d=3001,\ p<3000\) stress test is the next computational check.

## 8. Sharp elementary non-cross-order covariance bound

Assume a prime-width generator regime and distinct local primes \(p<r\) with
no cross-order relation

\[
p\nmid\ell_r,
\qquad
\ell_s=\operatorname{ord}_s(10).
\]

Put

\[
h=\gcd(\ell_p,\ell_r).
\]

Then

\[
\gcd(P_p,P_r)=h.
\]

### Root counts by exponent class

For local prime \(p\), let

\[
N_p(b)\in\{0,1,2\},
\qquad
b\bmod\ell_p,
\]

be the number of roots in \(a=n\bmod p\) for exponent class \(b\).

Write

\[
N_p(b)=1+e_p(b).
\]

The degenerate class \(b=0\) has exactly one root, hence \(e_p(0)=0\); every
other class comes from a quadratic and therefore

\[
\boxed{|e_p(b)|\le1.}
\]

For a residue \(c\bmod h\), define the number of local zero classes reducing
to \(c\) modulo \(h\):

\[
\alpha_c
=
\sum_{\substack{b\bmod\ell_p\\b\equiv c\pmod h}}
N_p(b).
\]

Since exactly \(\ell_p/h\) exponent classes lie above \(c\),

\[
\alpha_c
=
\frac{\ell_p}{h}+E_c,
\]

where

\[
E_c
=
\sum_{b\equiv c\pmod h}e_p(b).
\]

Thus

\[
|E_c|\le\frac{\ell_p}{h}.
\]

Subtracting the mean can only decrease squared Euclidean norm, so

\[
\sum_{c\bmod h}
\left(
\alpha_c-\frac{|R_p|}{h}
\right)^2
\le
\sum_{c\bmod h}E_c^2
\le
h\left(\frac{\ell_p}{h}\right)^2.
\]

Therefore

\[
\boxed{
E_p(h)\le\frac{\ell_p^2}{h}.
}
\]

The same argument gives

\[
E_r(h)\le\frac{\ell_r^2}{h}.
\]

No character-sum estimate is needed.

### Covariance

Insert these two elementary energy bounds into the exact unconditioned
covariance identity:

\[
|\rho_{p,r}-\rho_p\rho_r|
\le
\frac{h}{p\ell_p\,r\ell_r}
\sqrt{
\frac{\ell_p^2}{h}
\frac{\ell_r^2}{h}
}.
\]

Everything cancels:

\[
\boxed{
|\rho_{p,r}-\rho_p\rho_r|
\le
\frac1{pr}.
}
\]

This holds for every non-cross-order generator pair.

If \(h=1\), the discrepancy vectors have only one coordinate and are
identically zero, recovering the exact independence theorem.

### Elementary-filter conditioning

The mod-60 candidate restriction splits the calculation into a fixed bounded
number of CRT components. Repeating the same root-count argument inside those
components gives

\[
\boxed{
|\rho^S_{p,r}-\rho^S_p\rho^S_r|
\ll
\frac1{pr},
}
\]

with an absolute implied constant depending only on the fixed modulus 60.

The experiments indicate that the optimal conditioned constant may be much
smaller: through all tested generator pairs up to \(p,r<3000\),

\[
\frac{pr}{\gcd(P_p,P_r)}
|\rho^S_{p,r}-\rho^S_p\rho^S_r|
\le\frac12.
\]

That sharper factor remains conjectural.

### Consequence

The difficult part of pair correlation is therefore no longer generic
character-sum cancellation.

For non-cross pairs, an elementary \(1/(pr)\) covariance bound is automatic.
What remains is to exploit:

1. exact independence when \(h=1\);
2. arithmetic sparsity/average size of shared order factors when \(h>1\);
3. the sparse cross-order family \(p\mid\ell_r\).

This is a significantly simpler second-moment problem than the earlier
character-sum formulation suggested.

## 9. Analytic target

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
