# Prime decimal widths: a uniform truncated singular factor

This note gives a rigorous width-uniform result without requiring the full
width-average character-sum conjecture.

The idea is to restrict the decimal width itself to a prime \(D\).

## 1. No order collapse below a prime width

Let \(D\) be prime and let \(p<D\) be another prime with \(p\nmid10\). Put

\[
\ell_p=\operatorname{ord}_p(10).
\]

Since

\[
\ell_p\mid p-1<D,
\]

the prime \(D\) cannot divide \(\ell_p\). Therefore

\[
\gcd(D,\ell_p)=1.
\]

Hence

\[
\boxed{
\operatorname{ord}_p(10^D)=\ell_p.
}
\]

So for every local prime below the decimal width, passing from base 10 to
base \(10^D\) preserves the full multiplicative order.

This is exactly the regime in which the fixed-width character-sum estimate is
strongest.

## 2. Pointwise local density

Let \(\rho_{p,D}\) be the exact density, conditioned on the elementary
mod-60 candidate classes, of indices for which \(p\mid A(n)\) in a
\(D\)-digit fixed-width block.

The quadratic-character reduction in CONGRUENCES.md gives, with an absolute
constant \(K\),

\[
\left|
\rho_{p,D}-\frac1p
\right|
\le
\frac{K}{\ell_p\sqrt p},
\qquad p<D,
\]

apart from finitely many harmless small/degenerate cases, which may be
absorbed into the constant.

The mod-60 conditioning only splits the exponent sum into at most 60 subgroup
cosets, so \(K\) is independent of the prime width \(D\).

## 3. Reciprocal-order summability

Pappalardi proved that, for some \(\gamma>0\),

\[
\sum_{p\le x}\frac1{\ell_p}
\ll
\frac{\sqrt x}{(\log x)^{1+\gamma}}.
\]

Partial summation therefore gives

\[
\boxed{
\sum_p\frac1{\ell_p\sqrt p}<\infty.
}
\]

Consequently

\[
\sum_{p<D}
\left|
\rho_{p,D}-\frac1p
\right|
\]

is bounded by one convergent series, uniformly over all prime widths \(D\).

## 4. Uniform truncated correction

Define the prime-width truncated singular correction

\[
C_D^{<D}
=
\prod_{5<p<D}
\frac{1-\rho_{p,D}}{1-1/p}.
\]

For \(p>5\), the exact root count gives \(\rho_{p,D}<1\), so every local
factor is positive.

Using

\[
\log(1-x)=-x+O(x^2)
\]

and the uniform absolutely summable bound above, there exist constants

\[
0<c<C<\infty
\]

such that for every sufficiently large prime decimal width \(D\),

\[
\boxed{
c\le C_D^{<D}\le C.
}
\]

Thus the local singular correction contributed by all primes smaller than the
decimal width can neither collapse to zero nor blow up along prime widths.

This is a genuinely width-uniform theorem.

## 5. Divergent prime-width harmonic mass at the natural cutoff

The heuristic contribution of a full width band is proportional to \(C_D/D\).

At the truncated level \(p<D\), the theorem gives

\[
\frac{C_D^{<D}}D\ge\frac cD
\]

for prime \(D\).

Euler's theorem on reciprocals of the primes implies

\[
\sum_{\substack{D\ \mathrm{prime}}}\frac1D=\infty.
\]

Therefore

\[
\boxed{
\sum_{\substack{D\ \mathrm{prime}}}
\frac{C_D^{<D}}D
=
\infty.
}
\]

So even when the prime cutoff grows naturally with the width, all local
obstructions below the width leave divergent predicted prime mass on the
thin subsequence of prime decimal widths alone.

## 6. Numerical evidence

Hosted run 36266146082 computed \(C_d(1000)\) for every
\(1\le d\le5000\).

Restricting those data to the 669 prime widths gives

\[
\min C_D(1000)=0.939268248\quad(D=7),
\]

\[
\max C_D(1000)=1.313472125\quad(D=4139),
\]

with arithmetic mean

\[
1.127679917,
\]

geometric mean

\[
1.125065798,
\]

and harmonic-weighted mean

\[
\boxed{1.097368975}.
\]

The prime-width harmonic mass through 5000 is

\[
\sum_{\substack{D\le5000\\D\ \mathrm{prime}}}
\frac{C_D(1000)}D
=
2.639379411,
\]

compared with the uncorrected prime harmonic sum

\[
\sum_{\substack{D\le5000\\D\ \mathrm{prime}}}\frac1D
=
2.405188658.
\]

Thus the prime-width restriction is empirically even healthier than the
all-width average.

## 7. Extension to an almost-quadratic prime cutoff

The preceding theorem can be pushed substantially beyond the cutoff \(p<D\).

Fix any real

\[
0<\varepsilon<1
\]

and let \(D\) tend to infinity through prime decimal widths.  Put

\[
X_D=D^{2-\varepsilon}.
\]

Consider the normalized local correction contributed by primes

\[
D\le p<X_D.
\]

Split these local primes into two classes.

### Good local primes

If

\[
D\nmid\ell_p,
\qquad
\ell_p=\operatorname{ord}_p(10),
\]

then, because \(D\) is prime,

\[
\gcd(D,\ell_p)=1
\]

and therefore

\[
\operatorname{ord}_p(10^D)=\ell_p.
\]

The pointwise character-sum estimate gives

\[
\left|\rho_{p,D}-\frac1p\right|
\ll
\frac1{\ell_p\sqrt p}.
\]

Since

\[
\sum_p\frac1{\ell_p\sqrt p}<\infty,
\]

the total contribution from good primes \(p\ge D\) tends to zero as
\(D\to\infty\).

### Bad local primes

If

\[
D\mid\ell_p,
\]

then necessarily

\[
D\mid p-1,
\]

so

\[
p\equiv1\pmod D.
\]

Also

\[
\operatorname{ord}_p(10^D)=\frac{\ell_p}{D}.
\]

The character-sum bound therefore gives the crude but sufficient estimate

\[
\left|\rho_{p,D}-\frac1p\right|
\ll
\frac{D}{\ell_p\sqrt p}
\le
\frac1{\sqrt p}.
\]

It remains to sum \(p^{-1/2}\) over primes

\[
D\le p<D^{2-\varepsilon},
\qquad
p\equiv1\pmod D.
\]

For odd prime \(D\), there is no prime in the residue class \(1\bmod D\)
strictly between \(D\) and \(2D\).  On dyadic intervals

\[
2^jD<p\le2^{j+1}D,
\qquad j\ge1,
\]

Brun--Titchmarsh gives

\[
\#\{p\le2^{j+1}D:p\equiv1\pmod D\}
\ll
\frac{2^j}{j}.
\]

Hence the weighted contribution of this interval is

\[
\ll
\frac{2^{j/2}}{j\sqrt D}.
\]

Summing until \(2^jD\le D^{2-\varepsilon}\), the final dyadic interval
dominates and yields

\[
\boxed{
\sum_{\substack{D\le p<D^{2-\varepsilon}\\D\mid\ell_p}}
\frac1{\sqrt p}
\ll_\varepsilon
\frac{D^{-\varepsilon/2}}{\log D}.
}
\]

Thus the bad-prime contribution also tends to zero.

### Almost-quadratic local theorem

Combining the two classes,

\[
\sum_{D\le p<D^{2-\varepsilon}}
\left|
\rho_{p,D}-\frac1p
\right|
=o_\varepsilon(1)
\]

as \(D\to\infty\) through primes.

Therefore the normalized correction from this whole range tends to 1:

\[
\boxed{
\prod_{D\le p<D^{2-\varepsilon}}
\frac{1-\rho_{p,D}}{1-1/p}
=
1+o_\varepsilon(1).
}
\]

Together with the uniformly bounded correction below \(D\), there are
constants

\[
0<c_\varepsilon<C_\varepsilon<\infty
\]

such that for every sufficiently large prime width \(D\),

\[
\boxed{
c_\varepsilon
\le
\prod_{5<p<D^{2-\varepsilon}}
\frac{1-\rho_{p,D}}{1-1/p}
\le
C_\varepsilon.
}
\]

So the rigorous positive local regime extends from a linear cutoff all the
way to **almost the square of the decimal width**.

Consequently

\[
\boxed{
\sum_{D\ {\rm prime}}
\frac1D
\prod_{5<p<D^{2-\varepsilon}}
\frac{1-\rho_{p,D}}{1-1/p}
=
\infty.
}
\]

This is presently the strongest unconditional width-growing local statement
on the branch.

## 8. Remaining tail

The full singular factor \(C_D\) also contains primes \(p\ge D\).

For prime \(D\), order collapse in this tail can occur only when

\[
D\mid\operatorname{ord}_p(10),
\]

which in particular forces

\[
p\equiv1\pmod D.
\]

Thus the only unresolved local-density issue along prime widths is a very
specific sparse tail of local primes lying in the progression \(1\bmod D\)
and having decimal order divisible by \(D\).

Controlling this bad tail uniformly in \(D\) is substantially narrower than
the original all-width problem.

## 8. Strategic significance

We now have, unconditionally:

1. escape from every finite modulus;
2. infinitely many distinct prime divisors;
3. arbitrarily rough terms;
4. irreducibility of every fixed-width coefficient polynomial;
5. positive fixed-width singular factors;
6. divergent finite-cutoff harmonic mass over all widths;
7. and now a **uniformly positive growing-cutoff singular factor along prime
   decimal widths**, for every local prime \(p<D\).

The remaining local analytic target is the \(p\ge D\) tail above.

After that, the only remaining obstacle to infinitely many prime terms is the
genuine prime-values/parity barrier.
