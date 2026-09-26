# Irreducibility of the fixed-width A053067 polynomial

For each index \(n\ge 1\), define

\[
L_n=\frac{n(n-1)}2+1,\qquad
U_n=\frac{n(n+1)}2,
\]

and the arithmetic-progression coefficient polynomial

\[
P_n(x)
=
L_nx^{n-1}
+(L_n+1)x^{n-2}
+\cdots
+(U_n-1)x
+U_n.
\]

Whenever the A053067 block at \(n\) has a single decimal width \(d\),

\[
A(n)=P_n(10^d).
\]

## Kakuma's 2026 criterion

Hiroaki Kakuma, in

> *Irreducibility of Polynomials with Coefficients in a Positive Arithmetic
> Progression*, INTEGERS 26 (2026), A92,

proves the following.

Let

\[
A_m(x)
=
a x^m+(a+\delta)x^{m-1}+\cdots+(a+m\delta),
\]

where \(a,\delta\) are coprime positive integers and \(m\ge2\).  If

\[
8a>m^2\delta^2,
\]

then \(A_m(x)\) is irreducible in \(\mathbb Z[x]\).

## Application to A053067

For \(P_n\), take

\[
m=n-1,\qquad a=L_n,\qquad \delta=1.
\]

The coprimality condition is automatic.  Moreover,

\[
8L_n
=
4n(n-1)+8,
\]

whereas

\[
m^2\delta^2=(n-1)^2.
\]

Their difference is

\[
8L_n-(n-1)^2
=
(n-1)(3n+1)+8>0.
\]

Therefore Kakuma's criterion applies for every \(n\ge3\).

Hence

\[
\boxed{
P_n(x)\ \text{is irreducible in }\mathbb Z[x]
\quad\text{for every }n\ge3.
}
\]

## Consequence for the A053067 prime problem

This does not imply that the particular value \(P_n(10^d)\) is prime.

It does rule out an important structural obstruction: no nontrivial
factorization

\[
P_n(x)=F_n(x)G_n(x)
\]

over \(\mathbb Z[x]\) can explain systematic compositeness of fixed-width
A053067 terms.

Together with the universal residue-one theorem

\[
\forall m\ge1,\quad
A(n)\equiv1\pmod m
\]

for infinitely many genuine fixed-width indices, two standard local/algebraic
ways for a prime-value sequence to fail have now been eliminated:

1. no finite set of fixed prime divisors can cover the sequence;
2. the underlying arithmetic-progression coefficient polynomial is
   irreducible for every \(n\ge3\).

This is closely analogous to the admissibility and irreducibility checks that
precede Bateman--Horn-type prime-value conjectures.

## Formalization value

The application of Kakuma's external theorem itself is not immediately a
LeanFrontier theorem unless the criterion is formalized.  However, the
A053067-specific inequality needed for it is elementary:

\[
8L_n>(n-1)^2.
\]

If desired, a standalone Lean development could formalize Kakuma's criterion
or a specialized proof for this arithmetic-progression family.
