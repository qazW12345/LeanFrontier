# Prime decimal widths and the generator-averaged singular series

This note isolates an infinite subsequence of decimal widths on which the
local A053067 congruence structure simplifies substantially.

The widths themselves are taken to be prime numbers.

This still does not prove infinitely many prime **terms**, but it gives a
rigorous positive averaged singular series with no order-collapse contribution
from smaller local primes.

## 1. Prime widths preserve multiplicative order

Let \(d\) be a prime decimal width and let \(p<d\) be a prime with \(p\nmid10\).

Put

\[
\ell_p=\operatorname{ord}_p(10).
\]

Since

\[
\ell_p\mid p-1<d
\]

and \(d\) is prime,

\[
\gcd(d,\ell_p)=1.
\]

Therefore

\[
\boxed{
\operatorname{ord}_p(10^d)=\ell_p.
}
\]

Equivalently, \(10^d\) is another generator of the same subgroup

\[
H_p=\langle10\rangle\subseteq\mathbb F_p^\times.
\]

Thus along prime widths, every local prime \(p<d\) lies in the
**maximal-order-within-\(H_p\)** case.

## 2. Generator local density

Fix \(p>5\), let \(\ell=\ell_p\), and let

\[
q=10^a,
\qquad
a\in(\mathbb Z/\ell\mathbb Z)^\times.
\]

Then \(q\) generates \(H_p\) and has order exactly \(\ell\).

Let \(\rho^S_p(q)\) be the exact local divisibility density conditioned on the
12 elementary candidate classes modulo 60.

The quadratic-character reduction in CONGRUENCES.md, applied to the finitely
many cosets forced by the mod-60 condition, gives uniformly over generators

\[
\boxed{
\rho^S_p(q)
=
\frac1p+
O\!\left(\frac1{\ell\sqrt p}\right).
}
\]

The implied constant is absolute: the mod-60 restriction introduces only a
bounded number of subgroup-coset sums.

Consequently the normalized logarithmic local factor

\[
\lambda_p(q)
=
\log
\frac{1-\rho^S_p(q)}{1-1/p}
\]

satisfies

\[
\boxed{
\lambda_p(q)
=
O\!\left(\frac1{\ell\sqrt p}+\frac1{p^2}\right)
}
\]

uniformly for generator \(q\).

## 3. Generator-averaged local factor

Define

\[
\overline{\lambda}^{\,\mathrm{gen}}_p
=
\frac1{\varphi(\ell_p)}
\sum_{a\in(\mathbb Z/\ell_p\mathbb Z)^\times}
\lambda_p(10^a).
\]

Then

\[
\left|
\overline{\lambda}^{\,\mathrm{gen}}_p
\right|
\ll
\frac1{\ell_p\sqrt p}+\frac1{p^2}.
\]

Pappalardi's reciprocal-order estimate states that, for some
\(\gamma>0\),

\[
\sum_{p\le x}\frac1{\ell_p}
\ll
\frac{\sqrt x}{(\log x)^{1+\gamma}}.
\]

Partial summation therefore gives

\[
\sum_p\frac1{\ell_p\sqrt p}<\infty.
\]

Since also

\[
\sum_p\frac1{p^2}<\infty,
\]

we obtain

\[
\boxed{
\sum_{p>5}
\left|
\overline{\lambda}^{\,\mathrm{gen}}_p
\right|
<\infty.
}
\]

Hence the generator-averaged Euler correction

\[
\boxed{
C_{\mathrm{gen}}
=
\exp\left(
\sum_{p>5}
\overline{\lambda}^{\,\mathrm{gen}}_p
\right)
}
\]

exists and satisfies

\[
\boxed{
0<C_{\mathrm{gen}}<\infty.
}
\]

This is an unconditional analytic statement, assuming the standard published
multiplicative-order and character-sum estimates cited in LITERATURE.md.

## 4. Why prime widths sample the generator average

Fix a finite local-prime cutoff \(B\), and put

\[
T_B=
\operatorname{lcm}_{5<p\le B}\ell_p.
\]

Every prime divisor of \(T_B\) is at most \(B\). Hence every prime width

\[
d>B
\]

is coprime to \(T_B\).

For a fixed \(p\le B\), the local factor depends on \(d\) only through

\[
d\bmod\ell_p.
\]

As prime widths vary, Dirichlet equidistribution in reduced residue classes
therefore makes \(d\bmod\ell_p\) equidistributed in

\[
(\mathbb Z/\ell_p\mathbb Z)^\times.
\]

The same statement holds with harmonic prime weights \(1/d\), by the Mertens
theorem for arithmetic progressions.

Thus for every fixed \(B\),

\[
\frac{
\displaystyle
\sum_{\substack{d\le D\\d\ {\rm prime}}}
\frac1d\,
\log C_d(B)
}{
\displaystyle
\sum_{\substack{d\le D\\d\ {\rm prime}}}\frac1d
}
\longrightarrow
\sum_{5<p\le B}
\overline{\lambda}^{\,\mathrm{gen}}_p.
\]

Taking \(B\to\infty\) on the right gives

\[
\log C_{\mathrm{gen}}.
\]

So the **iterated** prime-width / local-prime limit is rigorously positive.

## 5. Finite-cutoff harmonic mass along prime widths

For fixed \(B\), Jensen's inequality gives

\[
\frac{
\sum_{d\le D,\ d\ {\rm prime}} C_d(B)/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
\ge
\exp\left(
\frac{
\sum_{d\le D,\ d\ {\rm prime}}\log C_d(B)/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
\right).
\]

Therefore

\[
\liminf_{D\to\infty}
\frac{
\sum_{d\le D,\ d\ {\rm prime}} C_d(B)/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
>0.
\]

Since Euler's theorem gives

\[
\sum_{d\ {\rm prime}}\frac1d=\infty,
\]

we obtain, for every finite \(B\),

\[
\boxed{
\sum_{d\ {\rm prime}}\frac{C_d(B)}d=\infty.
}
\]

This is a prime-width refinement of the finite-cutoff harmonic divergence in
LOCAL_PRODUCT_THEORY.md.

## 6. Numerical evidence

Hosted run 36266549898 computed the exact \(B=5000\) correction for every
width \(1\le d\le1000\).

Restricting to the 168 prime widths in this range gives:

\[
\min C_d(5000)=0.937643835
\quad(d=7),
\]

\[
\max C_d(5000)=1.309706520
\quad(d=269),
\]

arithmetic mean

\[
1.126033695,
\]

geometric mean

\[
1.123184526,
\]

and harmonic-weighted mean

\[
\boxed{1.094852374}.
\]

Moreover,

\[
\sum_{\substack{d\le1000\\d\ {\rm prime}}}
\frac{C_d(5000)}d
=
2.406573245,
\]

whereas

\[
\sum_{\substack{d\le1000\\d\ {\rm prime}}}\frac1d
=
2.198080127.
\]

Thus prime widths are, empirically, **more prime-friendly** than the average
width at this cutoff, while displaying a notably tighter lower envelope.

## 7. Generator-only numerical check

An independent exact computation through local primes \(p\le1000\), averaging
only the generator width classes

\[
a\in(\mathbb Z/\ell_p\mathbb Z)^\times,
\]

gave

\[
\boxed{
C_{\mathrm{gen}}(1000)\approx1.124861734.
}
\]

Hosted run 36275541603 extended the exact generator average through
\(p\le5000\) and found

\[
\boxed{
C_{\mathrm{gen}}(5000)=1.125368461.
}
\]

The change from the \(p\le1000\) value is only about \(4.5\times10^{-4}\)
relative, strong numerical evidence that the generator Euler product is
already close to its limiting constant.

For comparison, the corresponding all-width geometric correction through
\(p\le5000\) is

\[
1.034377319.
\]

The result is also consistent with the direct prime-width \(B=5000\)
experiment, whose harmonic-weighted correction through prime widths
\(d\le1000\) is

\[
1.094852374.
\]

Thus the analytically privileged generator classes are also empirically among
the more prime-friendly width classes.

## 8. Moving-cutoff theorem along prime widths

There is an unconditional way to avoid the exceptional-pair interchange
problem for an ever-growing local sieve.

For a prime decimal width \(d\), define

\[
C_d^{<d}
=
\prod_{\substack{5<p<d\\p\ {\rm prime}}}
\frac{1-\rho_{p,d}}{1-1/p}.
\]

Because \(d\) is prime and \(p<d\),

\[
\gcd(d,\ell_p)=1,
\qquad
\ell_p=\operatorname{ord}_p(10),
\]

so **every factor in this product is a generator-class factor**.

Write

\[
\lambda_p(d)
=
\log
\frac{1-\rho_{p,d}}{1-1/p}.
\]

Uniformly whenever \(\gcd(d,\ell_p)=1\),

\[
|\lambda_p(d)|
\ll
\frac1{\ell_p\sqrt p}+\frac1{p^2}.
\]

The majorant is summable over \(p\), by Pappalardi plus
\(\sum p^{-2}<\infty\).

For a fixed local prime \(p\), prime widths \(d\) are equidistributed in the
reduced residue classes modulo \(\ell_p\). Therefore their harmonic average
satisfies

\[
\frac{
\sum_{d\le D,\ d\ {\rm prime}}
\lambda_p(d)/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
\longrightarrow
\overline{\lambda}^{\,\mathrm{gen}}_p.
\]

Since the absolute majorant is summable, dominated convergence gives the
moving-cutoff identity

\[
\boxed{
\frac{
\sum_{d\le D,\ d\ {\rm prime}}
\log C_d^{<d}/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
\longrightarrow
\log C_{\mathrm{gen}}.
}
\]

In particular,

\[
\boxed{
0<C_{\mathrm{gen}}<\infty
}
\]

is the exact harmonic-geometric limiting correction for the sieve by all local
primes smaller than the prime decimal width.

By Jensen's inequality,

\[
\liminf_{D\to\infty}
\frac{
\sum_{d\le D,\ d\ {\rm prime}}
C_d^{<d}/d
}{
\sum_{d\le D,\ d\ {\rm prime}}1/d
}
\ge
C_{\mathrm{gen}}>0.
\]

Euler's divergence

\[
\sum_{d\ {\rm prime}}\frac1d=\infty
\]

then implies

\[
\boxed{
\sum_{d\ {\rm prime}}\frac{C_d^{<d}}d=\infty.
}
\]

This is a genuine growing-sieve theorem: the prime cutoff is not fixed, but
tends to infinity with the decimal width.

It proves that **all local primes below the width scale** preserve divergent
prime mass along prime decimal widths.

## 9. Moving-cutoff numerical check

Hosted run 36278136877 computed the exact moving correction

\[
C_d^{<d}
=
\prod_{5<p<d}
\frac{1-\rho_{p,d}}{1-1/p}
\]

for every prime width \(d\le1000\).

Among the 165 prime widths \(7\le d\le1000\), it found

\[
\boxed{
0.976742016
\le
C_d^{<d}
\le
1.300545580.
}
\]

The minimum occurs at \(d=307\), the maximum at \(d=269\).

The harmonic-weighted arithmetic mean is

\[
\boxed{1.089671878},
\]

and the harmonic-weighted geometric mean is

\[
\boxed{1.087070212}.
\]

The accumulated moving-cutoff harmonic mass is

\[
\sum_{\substack{7\le d\le1000\\d\ {\rm prime}}}
\frac{C_d^{<d}}d
=
1.269191826,
\]

compared with the uncorrected baseline

\[
\sum_{\substack{7\le d\le1000\\d\ {\rm prime}}}\frac1d
=
1.164746794.
\]

Thus the exact growing sieve controlled by the moving-cutoff theorem not only
remains positive but enhances the harmonic mass over this range.

## 10. Subexponential moving cutoffs

The moving-cutoff theorem extends far beyond \(p<d\).

Let \(d\) be a prime width and let \(B(d)\ge d\). Split local primes into

- **generator primes**, for which \(d\nmid\ell_p\);
- **exceptional primes**, for which \(d\mid\ell_p\),

where

\[
\ell_p=\operatorname{ord}_p(10).
\]

Because \(d\) is prime,

\[
d\nmid\ell_p
\quad\Longrightarrow\quad
\gcd(d,\ell_p)=1,
\]

so every generator prime has

\[
\operatorname{ord}_p(10^d)=\ell_p.
\]

Its normalized logarithmic local factor satisfies the uniform summable bound

\[
|\lambda_p(d)|
\ll
\frac1{\ell_p\sqrt p}+\frac1{p^2}.
\]

Hence all generator-prime contributions are controlled by one absolutely
summable majorant, independently of \(d\).

For an exceptional prime,

\[
d\mid\ell_p\mid p-1,
\]

so necessarily

\[
\boxed{p\equiv1\pmod d.}
\]

For any fixed-width local factor, at most two roots occur for each exponent
class. Conditioning on the \(1/5\)-density elementary candidate set can
increase the zero density by at most a factor 5, so

\[
\rho_{p,d}\ll\frac1p.
\]

For all sufficiently large \(d\), every exceptional \(p\) is large enough that

\[
|\lambda_p(d)|\ll\frac1p.
\]

Therefore

\[
\sum_{\substack{p\le B(d)\\d\mid\ell_p}}
|\lambda_p(d)|
\ll
\sum_{\substack{p\le B(d)\\p\equiv1\pmod d}}\frac1p.
\]

Discarding primality and writing \(p=kd+1\) gives the elementary bound

\[
\sum_{\substack{p\le B(d)\\p\equiv1\pmod d}}\frac1p
\le
\sum_{1\le k\le B(d)/d}\frac1{kd+1}
\ll
\frac{1+\log(B(d)/d)}d.
\]

Consequently, whenever

\[
\boxed{\log B(d)=o(d),}
\]

the entire exceptional contribution tends to zero.

Thus for prime widths and every subexponential cutoff

\[
B(d)=\exp(o(d)),
\]

the normalized local product has exactly the same limiting harmonic-geometric
correction as the generator model:

\[
\boxed{
\text{prime-width local correction through }B(d)
\longrightarrow C_{\rm gen}
\text{ in harmonic logarithmic mean.}
}
\]

In particular this holds for every fixed power

\[
\boxed{B(d)=d^A,\qquad A>0.}
\]

So the positive local correction survives sieving by **all primes up to any
fixed polynomial in the decimal width**.

More generally, if

\[
B(d)=e^{cd}
\]

with fixed \(c>0\), the exceptional contribution is merely \(O(c)\); hence
the normalized product remains bounded away from zero by a constant depending
on \(c\).

This sharply strengthens the moving-cutoff theorem.  The unresolved local
range begins only when the prime cutoff grows faster than exponentially in
the decimal width.

## 11. Remaining full-product problem

The theorem above controls the iterated limit

1. first average over prime widths for a fixed finite set of local primes;
2. then let the local-prime cutoff tend to infinity.

To turn this directly into

\[
\sum_{d\ {\rm prime}}\frac{C_d}{d}=\infty
\]

for the full fixed-width singular constants \(C_d\), one still needs enough
uniformity to interchange the infinite local-prime product with the
prime-width harmonic average.

The exceptional local primes for a prime width \(d\) are those for which

\[
d\mid\operatorname{ord}_p(10).
\]

For each fixed local prime \(p\), only finitely many prime widths divide
\(\operatorname{ord}_p(10)\), so they disappear in the limiting
prime-width average.  Controlling these exceptional pairs uniformly in both
\(p\) and \(d\) is now the precise remaining local analytic issue.

This is substantially narrower than the original width-uniform problem.

## 12. Implication for the prime-term programme

Prime widths provide a natural infinite subsequence on which:

- all smaller local primes retain full decimal multiplicative order;
- the generator-averaged local Euler product is rigorously positive;
- every finite local-prime truncation has divergent harmonic mass;
- numerical corrections remain comfortably bounded away from zero.

If the remaining interchange problem is solved, the entire singular-series
part of the infinite-prime heuristic is rigorous along prime decimal widths.
The final obstacle would then be the same prime-values/parity barrier familiar
from Mersenne and Fibonacci prime problems.
