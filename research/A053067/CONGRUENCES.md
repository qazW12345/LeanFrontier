# Congruence lemmas for A053067

Let

- \(L_n=n(n-1)/2+1\),
- \(U_n=n(n+1)/2\),

and let \(A(n)\) be the decimal concatenation of the \(n\) consecutive
integers \(L_n,L_n+1,\ldots,U_n\).

This note records exact congruences useful both for the search and for a later
Lean formalization.

## Exactly one mixed-width block at each decimal boundary

The intervals

\[
[T_{n-1}+1,T_n],\qquad T_n=\frac{n(n+1)}2,
\]

partition the positive integers. Consequently each power of ten \(10^d\)
belongs to exactly one A053067 block.

Equivalently, for each \(d\ge1\) there is a unique index

\[
b_d=\min\{n:T_n\ge10^d\}
\]

such that the block for \(b_d\) crosses the boundary from \(d\)-digit to
\((d+1)\)-digit integers. Every other block has a single decimal width and is
covered by the fixed-width formulas below.

This is useful for a possible global compositeness proof: a periodic covering
argument only has to handle fixed-width blocks; the one exceptional index
\(b_d\) per width can be treated by a separate recurrence or congruence family.

## Fixed-width representation

Assume every integer in the block has the same decimal width \(d\), and put

\[
q=10^d.
\]

Then

\[
A(n)=\sum_{j=0}^{n-1}(L_n+j)q^{\,n-1-j}.
\]

Boundary-crossing blocks are handled by the general modular evaluator in
\`search.cpp\`.

## Closed form for a fixed-width block

The geometric and arithmetico-geometric sums collapse to the integer identity

\[
\boxed{
A(n)(q-1)^2
=
q^n\big((q-1)L_n+1\big)
-
\big((q-1)U_n+q\big)
}.
\]

One derivation is to reverse the index,

\[
A(n)=\sum_{k=0}^{n-1}(L_n+n-1-k)q^k,
\]

and use the standard finite formulas for \(\sum q^k\) and
\(\sum kq^k\). The result simplifies to the boxed identity.

A slightly more general form, useful for Lean, starts with any first term
\(L\) and concatenates \(n\ge1\) consecutive values. If \(F(q,L,n)\) denotes
that fixed-width concatenation, then

\[
(q-1)^2F(q,L,n)
=
q^n((q-1)L+1)
-
((q-1)(L+n-1)+q).
\]

This form avoids division entirely.

## The \(10^d-1\) lemma

Let \(p\) be an odd prime with \(p\mid10^d-1\). Then \(q\equiv1\pmod p\), so

\[
\begin{aligned}
A(n)
&\equiv \sum_{j=0}^{n-1}(L_n+j) \pmod p\\
&= \frac{n(L_n+U_n)}2\\
&= \frac{n(n^2+1)}2 \pmod p.
\end{aligned}
\]

Therefore

\[
p\mid n(n^2+1)\quad\Longrightarrow\quad p\mid A(n).
\]

Equivalently, whenever the block is fixed-width, every odd prime divisor of

\[
\gcd(10^d-1,\;n(n^2+1))
\]

is a divisor of \(A(n)\).

Two common subcases are immediate:

- \(p\mid n\);
- \(n^2\equiv-1\pmod p\).

Example: for six-digit blocks, \(13\mid10^6-1\), and the square roots of
\(-1\) modulo 13 are 5 and 8. Hence \(13\mid A(n)\) whenever
\(n\equiv0,5,8\pmod{13}\), provided the whole block consists of six-digit
integers.

Likewise \(37\mid10^6-1\), with square roots of \(-1\) equal to 6 and 31
modulo 37, so the corresponding residue classes are
\(0,6,31\pmod{37}\).

## The \(10^d+1\) lemma

Let \(p\) be an odd prime with \(p\mid10^d+1\). Then \(q\equiv-1\pmod p\).

If \(n=2k\) is even, consecutive terms pair as

\[
-(L_n+2r)+(L_n+2r+1)=1,
\]

so

\[
A(n)\equiv k=\frac n2\pmod p.
\]

Thus

\[
p\mid n\quad\Longrightarrow\quad p\mid A(n)
\]

for even \(n\).

If \(n=2k+1\) is odd, the alternating sum is

\[
L_n-(L_n+1)+\cdots-(L_n+2k-1)+(L_n+2k)
=\frac{n^2+1}{2},
\]

hence

\[
A(n)\equiv\frac{n^2+1}{2}\pmod p.
\]

Thus

\[
p\mid n^2+1\quad\Longrightarrow\quad p\mid A(n)
\]

for odd \(n\).

These \(q=-1\) cases explain factors by 11, 17, 101, and other divisors of
\(10^d+1\) that are not captured by the \(10^d-1\) lemma.

## General periodicity modulo a prime

For an odd prime \(p\nmid10\), fixed \(d\), and \(q=10^d\), the residue
\(A(n)\bmod p\) is periodic in \(n\).

If \(q\not\equiv1\pmod p\), the closed form shows that it is determined by

- \(n\bmod p\), through the quadratic endpoint expressions; and
- \(n\bmod\operatorname{ord}_p(q)\), through \(q^n\).

Since \(\operatorname{ord}_p(q)\mid p-1\), these moduli are coprime. A period
therefore divides

\[
p\,\operatorname{ord}_p(q).
\]

When \(q\equiv1\pmod p\), the simpler \(10^d-1\) formula has period \(p\).

The tool \`congruence_families.py\` enumerates these exact zero residue classes.

## Search consequence

The special \(10^d\pm1\) identities give certificate-producing prefilters
using only gcds. The full periodic formula explains many more repeated factors.

A possible negative solution would amount to finding a finite family of such
congruences that covers every admissible fixed-width state, together with a
separate argument for the one mixed-width index at each power of ten. The
current computations do not establish such a covering.
