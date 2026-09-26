# An unconditional Euclid-type theorem for A053067

This note proves a structural result in the direction suggested by the
prime-value heuristic. It does **not** prove that A053067 contains infinitely
many prime terms.

The strongest form is:

> For every integer modulus \(m\ge1\), there are infinitely many genuine
> fixed-width A053067 terms satisfying
>
> \[
> A(n)\equiv1\pmod m.
> \]

Consequently every finite set of prime divisors can be avoided, A053067 has an
infinite pairwise-coprime subsequence, and infinitely many distinct primes
divide its terms.

## Setup

Let

\[
L_n=\frac{n(n-1)}2+1,\qquad U_n=\frac{n(n+1)}2.
\]

If the whole block \(L_n,\ldots,U_n\) has decimal width \(d\), put
\(q=10^d\) and let \(A(n)\) denote its decimal concatenation.

When an odd modulus \(r\) is coprime to 10 and \(q\equiv1\pmod r\),

\[
A(n)
\equiv
\sum_{j=0}^{n-1}(L_n+j)
=
\frac{n(n^2+1)}2
\pmod r.
\]

## Universal residue-one theorem

Fix an arbitrary integer \(m\ge1\).

Write

\[
m=m_{10}m_*,
\]

where every prime divisor of \(m_{10}\) is 2 or 5, and

\[
\gcd(m_*,10)=1.
\]

Choose \(e\) so large that

\[
m_{10}\mid10^e.
\]

Let

\[
D=\operatorname{ord}_{m_*}(10),
\]

with \(D=1\) when \(m_*=1\). Define

\[
M=\operatorname{lcm}(m_*,\,2\cdot10^e).
\]

Choose any sufficiently large positive integer \(k\), and set

\[
d=2kD,\qquad N=10^{d/2}=10^{kD},
\]

also taking \(k\) large enough that \(d\ge e\).

Let \(n\) be the least integer at least \(N\) satisfying

\[
n\equiv1\pmod M.
\]

Then

\[
N\le n\le N+M.
\]

Once

\[
N\ge4(M+1),
\]

the entire A053067 block at \(n\) has exactly \(d\) decimal digits. Indeed,

\[
L_n
\ge\frac{N(N-1)}2+1
\ge\frac{N^2}{10}
=10^{d-1},
\]

while \(M+1\le N/4\) gives

\[
U_n
\le\frac{(N+M)(N+M+1)}2
\le\frac12\left(\frac{5N}{4}\right)^2
=\frac{25}{32}N^2
<N^2=10^d.
\]

Thus the fixed-width representation is valid.

### The part coprime to 10

Because \(D\mid d\),

\[
10^d\equiv1\pmod{m_*}.
\]

Also \(n\equiv1\pmod{m_*}\). Since 2 is invertible modulo \(m_*\),

\[
A(n)
\equiv
\frac{n(n^2+1)}2
\equiv
\frac{1(1+1)}2
\equiv1
\pmod{m_*}.
\]

### The 2-5 part

Because \(n\equiv1\pmod{2\cdot10^e}\), write

\[
n=1+2\cdot10^e t.
\]

Then

\[
\frac{n+1}{2}=1+10^e t
\]

and hence

\[
U_n
=
n\frac{n+1}{2}
\equiv1\pmod{10^e}.
\]

Since \(d\ge e\), every earlier fixed-width block contribution is multiplied
by a power of \(10^d\), so modulo \(10^e\) the concatenation is just its final
integer:

\[
A(n)\equiv U_n\equiv1\pmod{10^e}.
\]

Therefore

\[
A(n)\equiv1\pmod{m_{10}}.
\]

Combining the two coprime parts gives

\[
\boxed{A(n)\equiv1\pmod m.}
\]

Arbitrarily large \(k\) work, so there are infinitely many such indices.

## Corollary: finite-prime avoidance

Let \(S\) be any finite set of primes and put

\[
m=\prod_{p\in S}p.
\]

The theorem supplies infinitely many terms with

\[
A(n)\equiv1\pmod m,
\]

so no prime in \(S\) divides \(A(n)\).

Thus no finite set of primes can cover all A053067 terms.

## Corollary: infinitely many distinct prime divisors

Suppose only finitely many primes ever divided A053067 terms. Put their product
equal to \(m\). The universal residue-one theorem gives a term \(A(n)>1\) with

\[
A(n)\equiv1\pmod m,
\]

so none of those primes divides it, contradicting unique factorization.

Hence

\[
\boxed{
\text{infinitely many distinct primes divide terms of A053067.}
}
\]

## Corollary: an infinite pairwise-coprime subsequence

After choosing \(n_1,\ldots,n_j\), let

\[
m_j=\operatorname{rad}\bigl(A(n_1)\cdots A(n_j)\bigr),
\]

the product of the finitely many prime divisors seen so far.

Choose \(n_{j+1}>n_j\) from the infinitely many indices satisfying

\[
A(n_{j+1})\equiv1\pmod{m_j}.
\]

Then

\[
\gcd\left(
A(n_{j+1}),
A(n_1)\cdots A(n_j)
\right)=1.
\]

Therefore A053067 contains an infinite pairwise-coprime subsequence.

## Consequence for eventual-compositeness strategies

A finite Sierpinski/Riesel-style covering by fixed prime divisors is
mathematically impossible for A053067.

More strongly, no finite modulus captures a compulsory local obstruction:
for every modulus \(m\), infinitely many genuine terms occupy the invertible
residue class \(1\bmod m\).

This puts A053067 in the appropriate local-admissibility regime for a
Bateman-Horn / Grantham-Granville style prime-value heuristic.

## Remaining gap

Pairwise-coprime composite numbers can of course exist, so none of the above
implies infinitely many prime **terms**.

What has been proved is that finite local divisibility obstructions cannot be
the reason prime terms stop. Any proof of eventual compositeness would need a
global factorization, a division-sequence-type mechanism, or another
non-local phenomenon.

Conversely, a proof of infinitely many prime terms now has a clean starting
point: local admissibility is unconditional; the unresolved difficulty is the
classical parity/prime-values barrier.
