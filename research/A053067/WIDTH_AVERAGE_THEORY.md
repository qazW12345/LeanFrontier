# Width-averaged singular factor: analytic reduction

This note isolates the analytic statement needed to turn the numerical
stability of the A053067 singular correction across decimal widths into a
rigorous average theorem.

It does not yet claim the final estimate has been proved. It reduces the
problem to double multiplicative-character sums over subgroup pairs and
records the exact decomposition to which published bounds can be compared.

## 1. Width orbit for one prime

Fix a prime \(p>5\), and put

\[
H_p=\langle10\rangle\subseteq\mathbb F_p^\times,
\qquad
\ell=\operatorname{ord}_p(10).
\]

As the decimal width \(d\) runs through one complete period modulo \(\ell\),

\[
q=10^d
\]

runs once through every element of \(H_p\).

For \(q\in H_p\), write

\[
r(q)=\operatorname{ord}_p(q),
\qquad
K_q=\langle q\rangle.
\]

If \(q\ne1\), the unconditioned local zero density is

\[
\rho(q)
=
\frac1p+
\frac{S(q)-1}{p\,r(q)},
\]

where

\[
S(q)
=
\sum_{t\in K_q}\chi(\Delta_q(t))
\]

and

\[
\Delta_q(t)
=
(q-1)
\bigl(-(7q+1)t^2+(18q-2)t-(7q+1)\bigr).
\]

For \(q=1\), the exact sum formula gives a separate elementary contribution of
size \(O(1/p)\).

Hence the width-average has the exact shape

\[
\boxed{
\overline{\rho}_p-\frac1p
=
\frac{1}{p\ell}
\left(
\sum_{\substack{q\in H_p\\q\ne1}}
\frac{S(q)-1}{r(q)}
+O(1)
\right).
}
\]

The computation in prime_width_average.py strongly suggests

\[
\overline{\rho}_p-\frac1p
=
O\left(\frac1{p\ell}\right).
\]

Through \(p\le1000\), the observed normalized quantity

\[
p\ell\left(\overline{\rho}_p-\frac1p\right)
\]

has absolute value at most about 10.14.

## 2. Grouping by subgroup order

Because \(H_p\) is cyclic, for every divisor \(r\mid\ell\) there is a unique
subgroup \(K_r\subseteq H_p\) of order \(r\).

Let

\[
G_r=\{q\in H_p:\operatorname{ord}(q)=r\}
\]

be its set of generators and define

\[
T_r
=
\sum_{q\in G_r}
\sum_{t\in K_r}
\chi(\Delta_q(t)).
\]

Then

\[
\sum_{\substack{q\in H_p\\q\ne1}}
\frac{S(q)}{r(q)}
=
\sum_{\substack{r\mid\ell\\r>1}}
\frac{T_r}{r}.
\]

The generator restriction is removed by Möbius inversion:

\[
\boxed{
T_r
=
\sum_{s\mid r}
\mu(r/s)
\sum_{q\in K_s}
\sum_{t\in K_r}
\chi(\Delta_q(t)).
}
\]

Thus the width-average problem reduces to double multiplicative-character sums
over pairs of multiplicative subgroups.

## 3. Möbius form of the character

For \(q\ne1\) and \(t\ne1\),

\[
\Delta_q(t)
=
(q-1)^2(t-1)^2
\left[
\left(\frac{t+1}{t-1}\right)^2
-
8\frac{q}{q-1}
\right].
\]

The square prefactor disappears under the quadratic character. Put

\[
X(t)
=
\left(\frac{t+1}{t-1}\right)^2,
\qquad
Y(q)=\frac{q}{q-1}.
\]

Then

\[
\boxed{
\chi(\Delta_q(t))
=
\chi(X(t)-8Y(q)).
}
\]

The omitted pole values \(q=1\) or \(t=1\) contribute only explicit boundary
terms.

Therefore the central sum has the form

\[
\sum_{q\in K_s}
\sum_{t\in K_r}
\chi\bigl(X(t)-8Y(q)\bigr),
\]

where \(X\) and \(Y\) are fixed low-degree rational functions.

This is structurally close to the double multiplicative-character sums studied
by Chang--Shparlinski, Shkredov--Shparlinski and related work.

## 4. Exponent parametrisation

Let \(g\) generate \(H_p\). Writing

\[
q=g^a,
\]

and averaging over \(t\in\langle q\rangle\), one may replace a sum over one
period of \(t\) by a full \(\ell\)-period in an auxiliary exponent:

\[
\frac1{r(q)}
\sum_{t\in\langle q\rangle}F(q,t)
=
\frac1\ell
\sum_{b\bmod\ell}
F(g^a,g^{ab}).
\]

Thus

\[
\sum_{q\in H_p}
\frac1{r(q)}
\sum_{t\in\langle q\rangle}F(q,t)
=
\frac1\ell
\sum_{a,b\bmod\ell}
F(g^a,g^{ab}).
\]

For A053067 this gives a second exact representation of the difficult
first-order width bias as a two-dimensional character sum on the exponent
torus.

## 5. Mod-60 conditioning

The actual A053067 local product conditions on

\[
n\bmod60
\in
\{1,2,13,17,22,26,37,38,41,46,53,58\}.
\]

For fixed \(q\) of order \(r\), this restricts the exponent

\[
b=n\bmod r
\]

according to its residue modulo

\[
g=\gcd(r,60).
\]

Since \(g\le60\), each conditioned sum is a bounded linear combination of
sums in which \(b\) lies in one residue class modulo \(g\). Equivalently,
\(t=q^b\) runs over a coset of the subgroup

\[
\langle q^g\rangle
\]

of index at most 60.

Therefore the mod-60 conditioning changes the analytic problem only by a
bounded number of subgroup-coset sums. Any power-saving estimate uniform over
such cosets transfers to the exact conditioned density used in local_product.py.

## 6. Exact common-period formula with mod-60 conditioning

There is a cleaner formulation that absorbs the elementary candidate filter
exactly.

Put

\[
L=\operatorname{lcm}(\ell,60).
\]

For every width class \(d\bmod\ell\), use the common period \(pL\) in the
index variable \(n\). This is legitimate because the true period
\(p\,\operatorname{ord}_p(10^d)\) divides \(p\ell\), hence divides \(pL\).

By the Chinese remainder theorem, an index class modulo \(pL\) is described by

\[
a=n\bmod p,\qquad c=n\bmod L.
\]

The elementary filter is simply

\[
c\bmod60\in
S=
\{1,2,13,17,22,26,37,38,41,46,53,58\}.
\]

There are exactly \(L/5\) such classes \(c\bmod L\).

For \(d\ne0\bmod\ell\), set

\[
q=10^d,\qquad t=q^c.
\]

If \(t\ne1\), the number of roots in \(a\) is

\[
1+\chi(\Delta_q(t)).
\]

If \(t=1\), the quadratic degenerates to a nonzero linear equation and has
exactly one root, so its contribution relative to the baseline root count 1
is zero.

For \(d=0\), we have \(q=1\) and

\[
A(n)\equiv \frac{n(n^2+1)}2\pmod p.
\]

Let

\[
\nu_p=
\begin{cases}
3,&p\equiv1\pmod4,\\
1,&p\equiv3\pmod4.
\end{cases}
\]

Then \(\nu_p\) is the number of roots in \(a\) in the \(q=1\) width class.

It follows that the exact conditioned width-average satisfies

\[
\boxed{
p\ell
\left(
\overline{\rho}^{\,S}_p-\frac1p
\right)
=
\frac{5}{L}
\sum_{\substack{
d\bmod\ell,\ d\ne0\\
c\bmod L,\ c\bmod60\in S\\
(10^d)^c\ne1
}}
\chi\!\left(
\Delta_{10^d}((10^d)^c)
\right)
+
(\nu_p-1).
}
\]

No weighting by the varying order \(r(q)\) remains.

This is the exact expression measured indirectly by the width-average
experiment.

The numerical conjecture

\[
p\ell\left(
\overline{\rho}^{\,S}_p-\frac1p
\right)=O(1)
\]

is therefore equivalent to square-root-scale cancellation in this
two-dimensional character sum: there are \(O(\ell L)\) summands, while the
observed total is only \(O(L)\).

For a fixed candidate residue \(s\in S\), write

\[
c=s+60h.
\]

Then

\[
(10^d)^c
=
(10^d)^s
\bigl((10^d)^{60}\bigr)^h.
\]

Thus the inner \(c\)-sum is a character sum over a coset of the subgroup
generated by \(q^{60}\). The elementary mod-60 sieve therefore leads
naturally, and exactly, to subgroup-coset character sums of uniformly bounded
index.

## 7. Large-order / small-order split

A plausible unconditional strategy is to fix a threshold \(p^\alpha\) with
\(\alpha<1/2\).

### Large subgroup orders

For

\[
r,s\ge p^\alpha,
\]

seek a power-saving estimate of the form

\[
\left|
\sum_{q\in K_s}
\sum_{t\in K_r}
\chi(X(t)-8Y(q))
\right|
\ll
rs\,p^{-\delta}
\]

for some \(\delta=\delta(\alpha)>0\).

Published double-character-sum results already prove power savings for broad
ranges of subgroup sizes. Related sum-product and rational-image energy
methods suggest a route for the present fixed rational functions.

After division by the \(p\ell\) normalization in the width average, any fixed
power saving is strong enough to make this large-order part summable over
primes.

### Small subgroup orders

The total number of elements of a cyclic group having order at most
\(p^\alpha\) is at most

\[
\sum_{\substack{r\mid\ell\\r\le p^\alpha}}\varphi(r)
\le
\sum_{r\le p^\alpha}\varphi(r)
\ll p^{2\alpha}.
\]

Thus small-order width classes are sparse when \(\ell\) is large.

Primes for which \(\ell=\operatorname{ord}_p(10)\) itself is small are sparse
on average by Pappalardi-type multiplicative-order estimates.

This gives a natural three-region split:

1. large \(\ell\), large \(r\): double character-sum cancellation;
2. large \(\ell\), small \(r\): few width classes;
3. small \(\ell\): few primes.

The goal is to choose thresholds so the total contribution of all three
regions is summable.

## 8. Maximal-order model case

When \(q\) itself is primitive modulo \(p\), the inner subgroup is all of
\(\mathbb F_p^\times\) and the character sum is exactly evaluable:

\[
Z_{p,d}
=
p-2
-
2\chi(-(q-1)(7q+1)),
\]

with the simple linear degeneration \(7q+1=0\) handled separately.

Thus maximal-order width classes already satisfy

\[
\rho_{p,d}
=
\frac1p+O(1/p^2).
\]

This is the ideal local behaviour the width-average theorem is trying to
recover in aggregate.

## 9. Numerical evidence for the target scale

Hosted run 36269650244 averaged the exact conditioned local densities over the
full width period for every prime \(p\le1000\).

It found

\[
\max_{p\le1000}
\left|
p\,\operatorname{ord}_p(10)
\left(\overline{\rho}_p-\frac1p\right)
\right|
=
10.131944444.
\]

The sum of the mean logarithmic local corrections through \(p=1000\) is

\[
0.034203520,
\]

so their aggregate geometric correction is

\[
\boxed{1.034795187}.
\]

This is almost identical to the geometric mean

\[
1.034882931
\]

observed directly over decimal widths \(1\le d\le5000\) at the same prime
cutoff.

A larger hosted run, 36271857873, completed the same exact calculation
through \(p\le5000\).  It found

\[
\max_{p\le5000}
\left|
p\,\operatorname{ord}_p(10)
\left(\overline{\rho}_p-\frac1p\right)
\right|
=
15.505319149,
\]

while the cumulative mean logarithmic correction is

\[
0.033799621
\]

and hence the aggregate geometric correction is

\[
\boxed{1.034377319}.
\]

For comparison, the \(p\le1000\) aggregate was \(1.034795187\).  The entire
additional prime range \(1000<p\le5000\) changes the summed mean logarithmic
correction by only about

\[
-4.04\times10^{-4}.
\]

The largest individual normalized bias grows slowly, but the aggregate local
correction is remarkably stable.  This is strong numerical support for
convergence of the width-averaged local factor, though it does not by itself
prove the double-character-sum estimate proposed above.

## 10. Bilinear-character reformulation

For \(q,t\ne1\), recall

\[
\chi(\Delta_q(t))
=
\chi(X(t)-8Y(q)),
\]

where

\[
X(t)=\left(\frac{t+1}{t-1}\right)^2,
\qquad
Y(q)=\frac{q}{q-1}.
\]

Define

\[
a=X(t),
\qquad
b=(8Y(q))^{-1}=\frac{q-1}{8q}.
\]

Then

\[
X(t)-8Y(q)=8Y(q)(ab-1),
\]

so

\[
\boxed{
\chi(\Delta_q(t))
=
\chi(8Y(q))\,\chi(ab-1).
}
\]

Thus the difficult double subgroup sum is a weighted bilinear
multiplicative-character sum of Karatsuba/Vinogradov type.

The maps have useful low-multiplicity structure:

- \(q\mapsto(q-1)/(8q)=(1-q^{-1})/8\) is injective away from \(q=0\);
- \(t\mapsto((t+1)/(t-1))^2\) has multiplicity at most two away from its
  pole, because \(t\) and \(t^{-1}\) have the same image and are the only
  generic pair with that image.

Therefore standard weighted bilinear character-sum estimates apply without a
large multiplicity loss.

This creates a direct bridge to Karatsuba's high-moment bounds, Vinogradov's
bilinear estimate, and recent work on shifted multiplicative subgroups.

## 11. Divisor-scale width-bias conjecture

Let

\[
\ell_p=\operatorname{ord}_p(10)
\]

and let \(\overline{\rho}^{\,S}_p\) be the exact mod-60-conditioned local
density averaged over one full decimal-width period.

The computations through \(p\le5000\) suggest the much sharper bound

\[
\boxed{
\left|
p\ell_p
\left(\overline{\rho}^{\,S}_p-\frac1p\right)
\right|
\ll \tau(\ell_p).
}
\]

In fact, for every tested prime \(p\le5000\),

\[
\left|
p\ell_p
\left(\overline{\rho}^{\,S}_p-\frac1p\right)
\right|
<
2\tau(\ell_p).
\]

The largest observed ratio is approximately

\[
1.75410
\]

at \(p=733\), where \(\ell_p=61\).

The same phenomenon is present before conditioning on the elementary mod-60
classes.

### Why the divisor function is natural

For every divisor \(r\mid\ell_p\), let \(K_r\) be the unique subgroup of
\(H_p=\langle10\rangle\) of order \(r\), let \(G_r\) be its set of generators,
and put

\[
T_r=
\sum_{q\in G_r}
\sum_{t\in K_r}
\chi(\Delta_q(t)).
\]

For \(r>1\), every generator \(q\) is different from 1 and

\[
\Delta_q(1)=4(q-1)^2,
\]

hence

\[
\chi(\Delta_q(1))=1.
\]

Therefore the \(t=1\) slice contributes **exactly**

\[
\varphi(r)
\]

to \(T_r\). The width bias decomposes into the centered quantities

\[
\boxed{
\frac{T_r-\varphi(r)}{r},
\qquad r\mid\ell_p,\ r>1,
}
\]

plus the explicit \(q=1\) term.

Thus a uniform estimate

\[
|T_r-\varphi(r)|\ll r
\]

would immediately prove the divisor-scale conjecture after summing over
\(r\mid\ell_p\).

This is now the sharpest finite-field subproblem produced by the A053067
analysis.

## 12. Consequence of the divisor-scale conjecture

Suppose

\[
\left|
\overline{\rho}^{\,S}_p-\frac1p
\right|
\ll
\frac{\tau(\ell_p)}{p\ell_p}.
\]

Since \(p\mid10^{\ell_p}-1\),

\[
\ell_p\gg\log p.
\]

Also, for every fixed \(\varepsilon>0\),

\[
\tau(n)\ll_\varepsilon n^\varepsilon.
\]

Taking any \(\varepsilon<1\) gives

\[
\frac{\tau(\ell_p)}{p\ell_p}
\ll_\varepsilon
\frac1{p(\log p)^{1-\varepsilon}}.
\]

The prime sum on the right converges. Hence the averaged first-order local
bias would be absolutely summable over primes.

Because each local density is \(O(1/p)\), the quadratic and higher terms in
the logarithmic Euler factor are automatically summable. The divisor-scale
conjecture would therefore imply convergence to a positive width-averaged
singular correction.

In particular it would close the remaining **local-density** gap in
PRIME_TERM_STRATEGY.md. The only unresolved step toward infinitely many
prime terms would then be the genuine prime-values/parity barrier.

## 13. Desired analytic conclusion

A bound even somewhat weaker than the numerically suggested

\[
\left|
\overline{\rho}_p-\frac1p
\right|
\ll
\frac1{p\,\operatorname{ord}_p(10)}
\]

would be enough if its prime sum is absolutely convergent.

Since

\[
p\mid10^{\ell_p}-1
\quad\Longrightarrow\quad
\ell_p\gg\log p,
\]

we have

\[
\sum_p\frac1{p\,\ell_p}<\infty.
\]

Absolute summability of the averaged first-order local bias, together with
the automatically summable second-order logarithmic terms, would imply a
positive limiting width-averaged singular correction.

That would close the main analytic gap in PRIME_TERM_STRATEGY.md: it would
make the divergent harmonic prime mass over decimal widths rigorous at the
level of the singular series.

It would still not cross the final parity/prime-values barrier, but it would
remove the last local-density obstruction.
