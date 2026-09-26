# Convergence of the A053067 local correction

This note upgrades the period-corrected Euler product from a numerical
diagnostic to a rigorous fixed-width object.

For every fixed decimal width \(d\), the local correction product is shown
to converge to a finite positive constant.

This still does **not** prove prime terms occur infinitely often.  It proves
that the local congruence data do not make the prime heuristic collapse.

## 1. Local density

Fix \(d\ge1\), put

\[
q=10^d,
\]

and let \(p>5\) be prime.

Let

\[
r=\operatorname{ord}_p(q).
\]

The fixed-width residue \(A(n)\bmod p\) has period dividing \(pr\).

The exact elementary candidate classes are

\[
S=\{1,2,13,17,22,26,37,38,41,46,53,58\}\pmod{60}.
\]

Define \(\rho_{p,d}\) to be the exact density, over one joint period of
\(A(n)\bmod p\) and \(n\bmod60\), of elementary-admissible indices for which

\[
p\mid A(n).
\]

Thus the period-corrected local factor is

\[
1-\rho_{p,d}.
\]

The corresponding random-integer factor is

\[
1-\frac1p.
\]

## 2. Quadratic reduction

Assume first that

\[
q\not\equiv1\pmod p.
\]

For

\[
a=n\bmod p,\qquad b=n\bmod r,\qquad t=q^b,
\]

divisibility by \(p\) is equivalent to the quadratic congruence

\[
(q-1)(t-1)a^2-(q-1)(t+1)a+2q(t-1)\equiv0\pmod p.
\]

For \(t\ne1\), the discriminant is

\[
\Delta_q(t)
=
(q-1)\bigl(-(7q+1)t^2+(18q-2)t-(7q+1)\bigr).
\]

Outside the finite exceptional set of primes dividing

\[
(q-1)(7q+1),
\]

the polynomial in \(t\) is a genuine nonsquare quadratic with distinct roots.

Let \(\chi\) be the quadratic character modulo \(p\).  The number of roots
in \(a\) for a given exponent class \(b\) is

\[
1+\chi(\Delta_q(q^b)),
\]

apart from the single degenerate class \(b=0\), where the correct root count
is 1 rather than 2.

## 3. Conditioning on the elementary mod-60 sieve

Put

\[
g=\gcd(r,60).
\]

Over a joint period, fixing \(b\bmod r\) determines which residues in
\(S\bmod60\) are compatible with it.  The compatibility weight depends only
on \(b\bmod g\) and is bounded by 12.

Hence

\[
\rho_{p,d}-\frac1p
\]

is a weighted average of character sums of the form

\[
\sum_{\substack{b\bmod r\\b\equiv c\pmod g}}
\chi(\Delta_q(q^b)),
\]

plus the harmless correction from the class \(b=0\).

For fixed \(c\), the elements \(q^b\) with \(b\equiv c\pmod g\) form a coset
of the multiplicative subgroup

\[
\langle q^g\rangle\subseteq\mathbb F_p^*.
\]

A standard Weil bound for a multiplicative-character sum of a nonsquare
quadratic over a subgroup coset gives

\[
\left|
\sum_{\substack{b\bmod r\\b\equiv c\pmod g}}
\chi(\Delta_q(q^b))
\right|
\ll \sqrt p,
\]

with an absolute implied constant.

Since \(g\le60\), this yields

\[
\boxed{
\left|\rho_{p,d}-\frac1p\right|
\ll
\frac{1}{r\sqrt p}.
}
\]

The finitely many exceptional primes can simply be absorbed into the initial
part of the Euler product.

## 4. Relating the order of \(10^d\) to the order of 10

Let

\[
\ell_p=\operatorname{ord}_p(10).
\]

Then

\[
r
=
\operatorname{ord}_p(10^d)
=
\frac{\ell_p}{\gcd(\ell_p,d)}
\ge
\frac{\ell_p}{d}.
\]

Therefore

\[
\left|\rho_{p,d}-\frac1p\right|
\ll_d
\frac{1}{\ell_p\sqrt p}.
\]

## 5. Pappalardi's reciprocal-order estimate

A theorem of Pappalardi gives, for some constant \(\gamma>0\),

\[
\sum_{p\le x}\frac1{\operatorname{ord}_p(10)}
\ll
\frac{\sqrt x}{(\log x)^{1+\gamma}}.
\]

This estimate is quoted explicitly in Sungjin Kim,
"Average Results on the Order of a modulo p", and originates in

Francesco Pappalardi,
"On the Order of Finitely Generated Subgroups of Q*(mod p) and Divisors of
p-1", Journal of Number Theory 57 (1996), 207--222.

Let

\[
B(x)=\sum_{p\le x}\frac1{\ell_p}.
\]

Partial summation gives

\[
\sum_p\frac1{\ell_p\sqrt p}
<\infty,
\]

because

\[
\frac{B(x)}{\sqrt x}
\ll\frac1{(\log x)^{1+\gamma}}
\]

and

\[
\int^\infty
\frac{B(t)}{t^{3/2}}\,dt
\ll
\int^\infty
\frac{dt}{t(\log t)^{1+\gamma}}
<\infty.
\]

Consequently

\[
\boxed{
\sum_p
\left|\rho_{p,d}-\frac1p\right|
<\infty
}
\]

for every fixed \(d\).

## 6. Positive convergence of the singular correction

Define

\[
C_d(B)
=
\prod_{\substack{5<p\le B\\p\ {\rm prime}}}
\frac{1-\rho_{p,d}}{1-1/p}.
\]

For all sufficiently large \(p\),

\[
\rho_{p,d}=\frac1p+o(1/p^{1/2}),
\]

and in particular every factor is positive.

Using

\[
\log(1-x)=-x+O(x^2)
\]

together with the absolute convergence above and
\(\sum_p1/p^2<\infty\), we obtain absolute convergence of

\[
\sum_p
\log
\frac{1-\rho_{p,d}}{1-1/p}.
\]

Therefore

\[
\boxed{
C_d
=
\lim_{B\to\infty}C_d(B)
}
\]

exists and satisfies

\[
\boxed{
0<C_d<\infty.
}
\]

So for every fixed width, the period-corrected A053067 singular factor is a
genuine positive constant, not a finite-cutoff numerical artifact.

## 7. What this achieves

The two unconditional structural statements now fit together:

1. **Universal local admissibility.**  For every modulus \(m\), infinitely
   many genuine A053067 terms satisfy \(A(n)\equiv1\pmod m\).

2. **Positive fixed-width singular factor.**  For every fixed \(d\), the
   normalized local Euler product converges to \(C_d>0\).

These remove the standard finite local reasons for a prime-value heuristic to
vanish.

## 8. What remains

The missing step is global in the decimal width.

A \(d\)-digit-width band contributes heuristically

\[
E_d\sim\frac{3}{8}\frac{C_d}{d}
\]

prime terms.

Thus a sufficient condition for the heuristic expected number of prime terms
to diverge is

\[
\sum_{d\ge1}\frac{C_d}{d}=\infty.
\]

For fixed \(d\), positivity of \(C_d\) is now rigorous.  What is not yet known
is a uniform lower bound, or even a strong enough average lower bound, as
\(d\to\infty\).

That width-uniform problem is the next analytic target.
