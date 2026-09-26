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

gives the finite-cutoff generator product

\[
\boxed{
C_{\mathrm{gen}}(1000)\approx1.124861734.
}
\]

This is noticeably larger than the corresponding all-width geometric
correction

\[
1.034795187.
\]

The result is consistent with the direct prime-width \(B=5000\) experiment,
whose harmonic-weighted correction through prime widths \(d\le1000\) is

\[
1.094852374.
\]

Thus the analytically privileged generator classes are also empirically among
the more prime-friendly width classes.

A hosted exact generator computation through \(p\le5000\) is running under
the prime-width-average workflow and will provide the higher-cutoff comparison.

## 8. Remaining interchange problem

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

## 9. Implication for the prime-term programme

Prime widths provide a natural infinite subsequence on which:

- all smaller local primes retain full decimal multiplicative order;
- the generator-averaged local Euler product is rigorously positive;
- every finite local-prime truncation has divergent harmonic mass;
- numerical corrections remain comfortably bounded away from zero.

If the remaining interchange problem is solved, the entire singular-series
part of the infinite-prime heuristic is rigorous along prime decimal widths.
The final obstacle would then be the same prime-values/parity barrier familiar
from Mersenne and Fibonacci prime problems.
