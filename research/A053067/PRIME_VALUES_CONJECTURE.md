# A period-corrected prime-value conjecture for A053067

This note states a precise conjectural bridge from the unconditional local
theory on this branch to actual prime terms.

It is deliberately separated from the proved statements.

## 1. Prime-width counting function

For each decimal width \(D\), let

\[
I_D=
\{n:
10^{D-1}\le L_n,\ U_n<10^D\}
\]

be the genuine fixed-width index interval.

Let

\[
\Pi_{\mathrm{pw}}(X)
=
\#\{
n:
A(n)\text{ is prime, and the fixed decimal width }D\le X
\text{ is prime}
\}.
\]

Mixed-width boundary terms are omitted. Their density is negligible on the
scale considered here.

## 2. Full local correction at the factorization scale

For prime width \(D\), let \(\rho_{p,D}\) be the exact density, conditioned on
the elementary \(2,3,5\) candidate classes, of fixed-width indices for which

\[
p\mid A(n).
\]

Let \(B_D\) be the uniform square-root factor bound from PRIME_WIDTHS.md:

\[
B_D=
\exp\!\left(
\frac{\log10}{\sqrt2}\,
D\,10^{D/2}
\right).
\]

Every composite term in the entire \(D\)-digit band has a prime factor
\(\le B_D\).

Define the complete factorization-scale local correction

\[
\mathfrak C_D
=
\prod_{5<p\le B_D}
\frac{1-\rho_{p,D}}{1-1/p}.
\]

The prime-width theorem proves unconditionally that there are absolute
constants

\[
0<c<C<\infty
\]

such that

\[
\boxed{
c\le\mathfrak C_D\le C
}
\]

for every sufficiently large prime width \(D\).

## 3. Natural expected mass of one width

A typical term in the \(D\)-digit band has

\[
\log A(n)\sim Dn\log10.
\]

Exactly \(1/5\) of indices survive the elementary \(2,3,5\) conditions, while
conditioning on avoidance of \(2,3,5\) multiplies the random prime density by

\[
\frac{15}{4}.
\]

The logarithmic length of the width interval satisfies

\[
\sum_{n\in I_D}\frac1n
\sim
\frac12\log10.
\]

Therefore the period-corrected expected prime mass of one full width is

\[
\boxed{
\lambda_D
\sim
\frac{3}{8}\frac{\mathfrak C_D}{D}.
}
\]

## 4. A053067 prime-value conjecture

The natural analogue of the Grantham--Granville period-corrected heuristic is:

> **Conjecture A053067-PV.**
> The actual prime count over prime decimal widths is asymptotic to the
> period-corrected local mass:
>
> \[
> \boxed{
> \Pi_{\mathrm{pw}}(X)
> \sim
> \frac38
> \sum_{\substack{D\le X\\D\ {\rm prime}}}
> \frac{\mathfrak C_D}{D}.
> }
> \]

A weaker lower-bound form would already suffice for infinitude:

\[
\Pi_{\mathrm{pw}}(X)
\gg
\sum_{\substack{D\le X\\D\ {\rm prime}}}
\frac{\mathfrak C_D}{D}.
\]

The conjecture is not a theorem and is not claimed to follow directly from the
Grantham--Granville recurrence conjecture: A053067 is a two-scale
concatenation family rather than a single fixed linear recurrence.

The analogy is structural: both heuristics correct the random prime
probability by exact periodic divisibility frequencies.

## 5. Conditional infinitude theorem

The unconditional prime-width theorem gives

\[
\mathfrak C_D\ge c>0
\]

for all sufficiently large prime widths.

Euler's theorem gives

\[
\sum_{\substack{D\le X\\D\ {\rm prime}}}\frac1D
=
\log\log X+O(1).
\]

Hence

\[
\sum_{\substack{D\le X\\D\ {\rm prime}}}
\frac{\mathfrak C_D}{D}
\ge
c\log\log X+O(1).
\]

Therefore Conjecture A053067-PV implies

\[
\boxed{
\Pi_{\mathrm{pw}}(X)\to\infty.
}
\]

In particular:

\[
\boxed{
\text{A053067 contains infinitely many prime terms.}
}
\]

More quantitatively, the conjecture and the uniform upper and lower bounds on
\(\mathfrak C_D\) predict

\[
\boxed{
\Pi_{\mathrm{pw}}(X)=\Theta(\log\log X).
}
\]

This conclusion uses only the thin subsequence of prime decimal widths.

## 6. Why this formulation is useful

The research programme has now separated into two logically clean pieces.

### Proved

- every finite modulus is escaped infinitely often;
- exponentially many rough values occur in every large width;
- the coefficient polynomial is irreducible for every \(n\ge3\);
- exact periodic local densities are known;
- fixed-width singular factors converge positively;
- on prime widths, the local correction is uniformly nondegenerate all the
  way to every prime factor relevant to primality.

### Conjectural

Only the final conversion of the local mass into actual prime occurrences.

That is a recognizable prime-values/parity barrier rather than an unidentified
defect in the local arithmetic.

## 7. A computational falsification programme

The conjecture can be tested without searching sequentially to the
astronomical median next-prime scale.

For selected widths \(D\):

1. compute \(\mathfrak C_D(B)\) for increasing practical cutoffs \(B\);
2. sample admissible indices uniformly or logarithmically across \(I_D\);
3. measure small-prime survival and compare it with the exact local product;
4. on manageable survivors, use PRP tests;
5. compare aggregate survivor/PRP frequencies with the predicted
   \(1/\log A(n)\) scale.

A systematic deviation from the local-product model would identify the global
correlation missing from the conjecture. Continued agreement strengthens the
case for A053067-PV but does not constitute a proof.
