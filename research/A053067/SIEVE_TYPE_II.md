# Sieve and Type-II research route for A053067

This note records the main conclusion of the September 2026 literature pass
after the prime-width local theory reached a moving-cutoff theorem.

It is a research programme, not a claim that the prime-term problem has been
solved.

## 1. Where the problem now sits

The branch already proves strong one-prime/local statements:

- every finite set of primes can be escaped;
- fixed-width local densities are explicit;
- the normalized fixed-width Euler product is positive;
- prime widths avoid order collapse from all smaller local primes;
- a growing cutoff \(p<d\) has a positive harmonic-geometric limiting
  correction along prime decimal widths;
- exponentially many values in each large width are rough.

This rules out the mechanisms that make a classical finite covering work.

The remaining issue is not another one-prime estimate. It is whether
divisibility events for **several primes at once** have enough independence,
on average, to support an actual sieve and eventually a parity-breaking
argument.

## 2. Fixed-width A053067 is a degenerate linear recurrence

Fix the decimal width \(d\) and write \(q=10^d\). Extend the fixed-width
closed formula to all natural \(n\), whether or not the block is genuinely
\(d\)-digit. From

\[
(q-1)^2 F(q,L_n,n)
=
q^n((q-1)L_n+1)-((q-1)U_n+q),
\]

and the fact that both \(L_n\) and \(U_n\) are quadratic polynomials in \(n\),
we obtain

\[
(q-1)^2 F(q,L_n,n)
=
q^n P_2(n)+Q_2(n)
\]

for quadratic polynomials \(P_2,Q_2\).

Consequently the fixed-width extrapolation is a constant-coefficient linear
recurrence whose characteristic polynomial divides

\[
\boxed{(T-q)^3(T-1)^3.}
\]

This puts each width slice directly inside the exponential-polynomial /
linear-recurrence literature.

It is, however, a highly nongeneric recurrence: the characteristic roots are
the two rational numbers \(q\) and \(1\), both with multiplicity at most
three. Results requiring an irreducible characteristic polynomial with
Galois group \(S_k\), such as Järviniemi's positive-density theorem for prime
divisors of generic recurrences, therefore do not apply.

Also, the actual A053067 sequence uses only the genuine finite interval
\(I_d\) from this recurrence and then changes \(q\) when the decimal width
changes. A theorem for one fixed recurrence is not automatically a theorem
for A053067.

## 3. The sieve obstruction is exactly the one seen for sparse recurrences

Grantham--Granville, *Fibonacci primes, primes of the form \(2^n-k\) and
beyond*, JNT 261 (2024), Section 7, point out that for shifted exponentials
the natural divisor density is controlled by multiplicative orders. For
squarefree \(m\), the resulting period function is not multiplicative, so the
usual multiplicative sieve axioms are unavailable.

Browning--Verzobio, *Strong divisibility sequences and sieve methods*,
Mathematika 70 (2024), make the same issue explicit for strong divisibility
sequences: nonmultiplicative divisor-density functions and exponential growth
are the two major obstacles. Their positive results exploit the additional
strong-divisibility structure; A053067 does not currently have an analogue of
that structure.

This matches the A053067 data exactly. For a local prime \(p\), the zero set
has a period built from

\[
p\,\operatorname{ord}_p(10^d),
\]

and for a squarefree composite modulus the common period is an lcm, not a
product. Shared factors between the local periods can therefore correlate
prime-divisibility events.

## 4. Exact two-prime correlations are the next computable invariant

For primes \(p,r>5\), let

\[
\rho_{p,d},\qquad \rho_{r,d}
\]

be the exact conditioned one-prime densities, and define

\[
\rho_{p,r;d}
=
\Pr(
p\mid A(n),\ r\mid A(n)
\mid n\bmod60\in S
).
\]

The joint value is exactly computable from the two zero-class families by the
generalized Chinese remainder theorem. No sampling is required.

Two useful diagnostics are

\[
\kappa_{p,r;d}
=
\rho_{p,r;d}-\rho_{p,d}\rho_{r,d}
\]

and the survival ratio

\[
\boxed{
R_{p,r;d}
=
\frac{
1-\rho_{p,d}-\rho_{r,d}+\rho_{p,r;d}
}{
(1-\rho_{p,d})(1-\rho_{r,d})
}.
}
\]

Under pairwise independence, \(R_{p,r;d}=1\).

The script pair_correlation_probe.py computes these quantities exactly.
The first hosted experiment uses prime width \(d=101\) and local primes
through \(500\).

The immediate questions are:

1. Are large deviations concentrated on pairs whose periods have a large gcd?
2. Does the average of \(|\log R_{p,r;d}|\) decrease with prime width?
3. After grouping by period gcd, is there a summable majorant for the
   pair-correlation error?
4. Does restricting to prime widths materially suppress the worst
   correlations?

A positive answer to the third question would be the first real
composite-modulus theorem on this branch.

## 5. Why pairwise control is useful but not yet enough

Friedlander--Iwaniec's asymptotic sieve shows how a sieve can break the parity
barrier when, beyond ordinary local-density information, one has an additional
bilinear/Type-II axiom.

For A053067 the exact form of the needed Type-II statement has not yet been
proved or even optimized. A natural prototype is a bilinear bound for
centered divisibility errors over squarefree moduli:

\[
\sum_{m\sim M} \alpha_m
\left(
N_d(m;X)-\rho_d(m)X
\right),
\]

or, more ambitiously, a two-variable form

\[
\sum_{m\sim M}\sum_{k\sim K}
\alpha_m\beta_k
\left(
N_d(mk;X)-\rho_d(mk)X
\right),
\]

with cancellation beyond the bound obtained by summing absolute values.

Here \(N_d(m;X)\) counts admissible fixed-width indices in a subinterval for
which \(m\mid A(n)\), and \(\rho_d(m)\) is the exact periodic density over the
joint modulus.

The pair-correlation experiment is therefore a diagnostic for the first
nontrivial layer of this problem, not a substitute for a Type-II theorem.

## 6. Relevant literature added by this pass

### Järviniemi--Teräväinen (2023)

*Composite values of shifted exponentials*, Adv. Math. 429 (2023), 109187.

Even for \(a^n-b\), showing that almost all values are composite requires GRH
plus a Brun--Titchmarsh/Chebotarev-type hypothesis in their theorem. They also
show, under the same assumptions, that fixed-\(k\) almost-prime values have
density zero.

This is strong evidence that an unconditional prime-infinitude theorem for
A053067 should not be expected from local admissibility alone.

### Grantham--Pappalardi (2026)

*Two dimensional covering systems and possible prime producing
\(a^m-b^n\)*, arXiv:2601.10296v2.

They construct a new covering mechanism for a two-exponent family and
conjecture that finite-prime covering obstructions are the relevant
obstructions to infinitely many prime values in their setting.

For A053067, the residue-one theorem already rules out the analogous finite
prime covering of all sufficiently large genuine fixed-width terms. Their
paper therefore supports, rather than weakens, the decision to stop searching
for a finite covering and move to global correlation questions.

### Chang--Kerr--Shparlinski (2018)

*On the exponential large sieve inequality for sparse sequences modulo
primes*, J. Math. Anal. Appl. 459 (2018), 53--81.

Their large-sieve bounds for sparse exponential sequences show that averaging
over primes can recover cancellation unavailable from a single modulus. The
A053067 fixed-width congruence contains both an exponential component and a
low-degree polynomial in the index, so this is a plausible source of tools
for a future averaged Type-II estimate.

### Croot--Yip (2026)

*Diophantine tuples and product sets in shifted powers*, J. London Math. Soc.
113 (2026), e70499.

The final published version contains explicit Vinogradov- and Karatsuba-type
double character-sum estimates. These sharpen the finite-field toolkit
already used in WIDTH_AVERAGE_THEORY.md, although by themselves they do not
resolve the composite-modulus sieve problem.

## 7. Research decision

The next analytic programme should therefore be:

1. measure exact two-prime correlations on prime widths;
2. identify the arithmetic parameter controlling the outliers, expected to be
   shared factors of local periods;
3. prove a pair-correlation bound averaged over local primes;
4. generalize from pairs to squarefree composite moduli;
5. only then formulate the strongest credible Type-I/Type-II sieve axiom for
   A053067 and test whether an asymptotic-sieve argument can reach primes.

In parallel, the direct PRP search remains worthwhile: a single later prime
would answer the original OEIS question without crossing the parity barrier.
