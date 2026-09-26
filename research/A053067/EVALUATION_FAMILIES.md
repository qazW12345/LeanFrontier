# Evaluation divisor families

For a fixed-width block define the polynomial

P_n(x) = sum_(j=0)^(n-1) (L_n+j) x^(n-1-j).

Then A053067(n)=P_n(q) with q=10^d.

For every integer c,

P_n(q) = P_n(c)  (mod q-c).

Therefore

gcd(q-c, P_n(c)) | A053067(n).

This is a general divisor-production mechanism.

## Special cases

c=1 gives

P_n(1)=n(n^2+1)/2,

which is the q-1 lemma.

c=-1 gives the alternating-sum formulas behind the q+1 lemma.

Nothing in the argument requires c to be constant.  One may choose c=c(n)
or another explicit integer expression and obtain

gcd(q-c(n), P_n(c(n))) | A053067(n).

The value P_n(c) modulo q-c can be evaluated in O(log n) modular operations
using the same affine-transform exponentiation as search.cpp; the enormous
decimal concatenation is never needed.

## Initial negative search

On the 1896 sieve survivors from the checked GitHub-hosted scan
50001..100000 (all ten-digit fixed-width blocks, sieve bound 10^6), exploratory
tests found no nontrivial divisor from:

- every constant c from -50 through 500 (with the trivial c=0 omitted);
- c = +/-n, +/-2n, +/-n^2;
- c = +/-L_n and +/-U_n;
- nearby variants n+/-1 and -n+/-1.

These tests do not prove that evaluation families are useless, but they rule
out the simplest extensions of c=+/-1 on this hard survivor set.

A productive next version would search structured c(n) suggested by the
coupled equation rather than enumerate arbitrary small constants.
