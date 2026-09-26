# Lean formalization route for A053067

This document is a research plan. It is not an ordinary LeanFrontier submission
and makes no claim that the OEIS problem has been solved.

## 1. Separate arithmetic concatenation from decimal bookkeeping

For a fixed base power (q=10^d), define the append recurrence for (n)
consecutive integers beginning at (L):

[
F(q,L,0)=0,qquad
F(q,L,n+1)=qF(q,L,n)+(L+n).
]

When (L,L+1,ldots,L+n-1) all have exactly (d) decimal digits,
(F(10^d,L,n)) is their decimal concatenation.

This should be the main algebraic object in Lean. It avoids carrying
`Nat.digits` through every proof.

A natural Lean shape is a primitive recursive function under a stable
number-theory namespace, with the algebraic lemmas proved over `ℤ` after
casting the recurrence.

## 2. Closed form without division

For (n\ge1), over the integers,

[
(q-1)^2F(q,L,n)
=
q^n((q-1)L+1)
-
((q-1)(L+n-1)+q).
]

This identity is preferable to a rational closed form: it has no division and
should admit a short induction using only the defining recurrence and `ring`.

For A053067 specialize

[
L=L_n=rac{n(n-1)}2+1,qquad
U=U_n=rac{n(n+1)}2=L_n+n-1.
]

The specialized form is

[
A(n)(q-1)^2
=
q^n((q-1)L_n+1)-((q-1)U_n+q)
]

whenever the whole block is (d)-digit.

## 3. Congruence lemmas

Avoid modular division by stating doubled identities where useful.

If an odd prime (pmid q-1), prove

[
2A(n)equiv n(n^2+1)pmod p.
]

Then any proof of (pmid n(n^2+1)) yields (pmid A(n)), because (p) is
odd.

If (pmid q+1), prove the parity split:

- even (n): (2A(n)equiv npmod p);
- odd (n): (2A(n)equiv n^2+1pmod p).

For general (p
mid10(q-1)), use the closed form together with a hypothesis
on (q^nmod p). This is the reusable theorem behind the periodic-family
search.

## 4. Decimal bridge

Define the A053067 endpoints in Lean:

[
L_n=n(n-1)/2+1,qquad U_n=n(n+1)/2.
]

A generic bridge theorem should say that if every integer in
([L_n,U_n]) has decimal width (d), then the list/fold decimal
concatenation equals (F(10^d,L_n,n)).

The width condition can be reduced to just the endpoints because decimal digit
length is monotone on positive naturals:

[
10^{d-1}le L_nquad	ext{and}quad U_n<10^d.
]

This keeps the string/digit machinery quarantined in one theorem.

## 5. What a positive search result would require

If the computation finds (N>2) with A053067(N) prime:

1. independently regenerate the decimal integer;
2. obtain a rigorous primality certificate, not merely a probable-prime result;
3. formalize the A053067 definition and bridge at (N);
4. formalize/check the certificate;
5. state the mathematically useful result as an existential theorem
   (exists n>2,operatorname{Prime}(A(n))), and, if all earlier terms have
   certified compositeness, the stronger least-index theorem.

The existential statement is preferable to exposing only a giant numeral:
the witness is new mathematical information and cannot be invented by a
bounded simplifier.

## 6. What a negative structural solution would require

A proof that no further prime exists would need a finite or otherwise
well-founded family of divisibility arguments covering every (n>2).
The periodic-family experiments suggest encoding states in terms of:

- decimal width (d);
- (n) modulo selected prime/order periods;
- the finite exceptional set of blocks crossing a power of ten.

A SAT/SMT/set-cover search may discover a finite family, but its output must be
converted into ordinary arithmetic lemmas. The SAT solver would be a discovery
tool, not part of the trusted Lean proof.

## 7. Intermediate formal work worth keeping

Even before the open problem is settled, the following are stable reusable
lemmas rather than bounded computational facts:

- fixed-width append recurrence;
- weighted-sum representation;
- closed form;
- (q=1) modulo (p) congruence;
- (q=-1) modulo (p) congruence;
- periodicity modulo (p);
- decimal-width bridge.

These are the right pieces to formalize first if the computational search
starts depending heavily on them.
