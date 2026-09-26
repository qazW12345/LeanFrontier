# An unconditional Euclid-type theorem for A053067

This note proves a structural result in the direction suggested by the
prime-value heuristic. It does **not** prove that A053067 contains infinitely
many prime terms. It proves something weaker but unconditional:

> For every finite set of primes S, there are infinitely many genuine
> fixed-width A053067 terms divisible by none of the primes in S.

Consequently A053067 has an infinite pairwise-coprime subsequence and therefore
infinitely many distinct prime divisors.

## Setup

Let

\[
L_n=\frac{n(n-1)}2+1,\qquad U_n=\frac{n(n+1)}2.
\]

If the whole block \(L_n,\ldots,U_n\) has decimal width \(d\), put
\(q=10^d\) and let \(A(n)\) denote its decimal concatenation.

For any odd prime \(p\mid q-1\), the fixed-width congruence proved in
CONGRUENCES.md is

\[
A(n)\equiv \frac{n(n^2+1)}2\pmod p.
\]

## Finite-prime avoidance theorem

Let \(S\) be any finite set of primes.

Define

\[
M=\operatorname{lcm}\left(
20,\{p:p\in S,\ p\notin\{2,5\}\}
\right)
\]

and

\[
D=\operatorname{lcm}\left(
\{\operatorname{ord}_p(10):
p\in S,\ p\notin\{2,5\}\}
\right),
\]

with an empty lcm interpreted as 1.

Choose any sufficiently large positive integer \(k\), and set

\[
d=2kD,\qquad N=10^{d/2}=10^{kD}.
\]

Take the least integer \(n\ge N\) satisfying

\[
n\equiv1\pmod M.
\]

Then

\[
N\le n\le N+M.
\]

For all sufficiently large \(k\), for example once

\[
N\ge4(M+1),
\]

the whole A053067 block at \(n\) has exactly \(d\) decimal digits.

Indeed,

\[
L_n
\ge \frac{N(N-1)}2+1
\ge \frac{N^2}{10}
=10^{d-1},
\]

while, because \(M+1\le N/4\),

\[
U_n
\le\frac{(N+M)(N+M+1)}2
\le\frac12\left(\frac{5N}{4}\right)^2
=\frac{25}{32}N^2
<N^2=10^d.
\]

Thus the fixed-width formula applies.

Now let \(p\in S\) be odd and \(p\ne5\). Since \(d\) is a multiple
of \(\operatorname{ord}_p(10)\),

\[
10^d\equiv1\pmod p.
\]

Also \(M\) is a multiple of \(p\), so

\[
n\equiv1\pmod p.
\]

Therefore

\[
A(n)
\equiv
\frac{1(1^2+1)}2
\equiv1
\pmod p.
\]

Hence \(p\nmid A(n)\).

For \(p=2\) or \(p=5\), note that \(20\mid M\), hence
\(n\equiv1\pmod{20}\). Write \(n=20m+1\). Then

\[
U_n
=
\frac{n(n+1)}2
=
(20m+1)(10m+1)
\equiv1\pmod{10}.
\]

The decimal concatenation ends with the decimal expansion of \(U_n\), so

\[
A(n)\equiv1\pmod{10}.
\]

Thus neither 2 nor 5 divides \(A(n)\).

We have proved

\[
\boxed{
\gcd\!\left(A(n),\prod_{p\in S}p\right)=1.
}
\]

Since arbitrarily large multiples \(k\) may be used, infinitely many such
indices \(n\) exist.

## Corollary: infinitely many distinct prime divisors

Suppose, for contradiction, that only finitely many primes ever divide
A053067 terms. Let \(S\) be that finite set. The avoidance theorem produces
a term \(A(n)>1\) divisible by none of them, contradicting unique
factorization.

Therefore

\[
\boxed{
\text{infinitely many distinct primes divide terms of A053067.}
}
\]

## Stronger corollary: an infinite pairwise-coprime subsequence

Construct indices recursively.

After choosing \(n_1,\ldots,n_j\), let \(S_j\) be the finite set of prime
divisors of

\[
A(n_1)A(n_2)\cdots A(n_j).
\]

Apply the avoidance theorem to \(S_j\) and choose \(n_{j+1}>n_j\) among
the infinitely many available indices. Then

\[
\gcd\left(
A(n_{j+1}),
A(n_1)\cdots A(n_j)
\right)=1.
\]

Hence there exists an infinite subsequence

\[
A(n_1),A(n_2),A(n_3),\ldots
\]

whose terms are pairwise coprime.

This is stronger than merely saying that the set of prime divisors is
infinite.

## Consequence for covering proofs

No finite set of primes can cover all A053067 terms.

In particular, any proof of eventual compositeness based on a finite
Sierpinski/Riesel-style collection of fixed prime divisors is impossible:
the construction above explicitly escapes every such finite collection.

This formally strengthens the computational evidence from the CEGAR covering
search.

## What this does and does not say about prime terms

Pairwise coprime composite numbers are possible, so the theorem does not imply
that infinitely many A053067 terms are prime.

What it does establish is that the sequence has no finite local obstruction
to primality. Every finite collection of prime divisibility obstructions can
be escaped by infinitely many genuine terms.

Combined with the period-corrected Euler-product experiment, this puts the
sequence in the same qualitative regime assumed by prime-value heuristics:
local obstructions exist, but no finite set of them can account for all terms.

The remaining gap from this theorem to infinitely many prime terms is a
genuine prime-values problem rather than a missing finite congruence argument.
