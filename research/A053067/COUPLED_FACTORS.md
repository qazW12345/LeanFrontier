# Coupled prime-factor structure for fixed-width A053067 terms

Let a whole A053067 block have decimal width d and put q=10^d.  Write

  L = n(n-1)/2 + 1,
  U = n(n+1)/2,

and let A=A053067(n) for this fixed-width block.

Define

  X = (q-1)L + 1,
  Y = (q-1)U + q = X + n(q-1),
  R = 1 + q + ... + q^(n-1).

The basic identities are

  (q-1)^2 A = q^n X - Y

and

  (q-1) A = X R - n.

This note classifies what a prime divisor p can look like.

## Case 1: q = 1 mod p

Let p be an odd prime not dividing 10.  If q=1 mod p, positional weights
disappear and

  2 A = n(n^2+1) mod p.

Therefore

  p | A  <=>  p | n  or  n^2 = -1 mod p.

This is the complete q=1 case.

## Case 2: p divides n

For arbitrary q modulo p, if p|n then

  L = 1 mod p,
  U = 0 mod p,

hence X=Y=q mod p.  Since q is a unit,

  p | A  <=>  q^n = 1 mod p.

Equivalently,

  p | n  ==>  (p | A  <=>  ord_p(q) | n).

Since q=10^d,

  ord_p(q) = ord_p(10) / gcd(ord_p(10),d),

so this is also equivalent to

  ord_p(10) | d n.

Thus all factors inherited from the index n are completely classified.

## Case 3: the genuinely coupled factors p not dividing n

Assume p does not divide n and q != 1 mod p.

If p divided X, then p|A would force p|Y.  But Y-X=n(q-1), and both n and
q-1 are nonzero mod p, a contradiction.  Therefore X is invertible.

The factor condition becomes

  q^n = Y/X
      = 1 + n(q-1)/X                    (mod p).

The right side is not 1, hence

  ord_p(q) does not divide n.

This rules out every nontrivial cyclotomic factor q^n-1 in the hard case.

Writing t=q^n, and using

  2X = (q-1)n^2 - (q-1)n + 2q,
  2Y = (q-1)n^2 + (q-1)n + 2q,

the equation tX=Y is equivalent to

  (q-1)(t-1)n^2
  - (q-1)(t+1)n
  + 2q(t-1)
  = 0                                  (mod p).

Since q!=1 and t!=1, divide by (q-1)(t-1):

  n^2
  - ((t+1)/(t-1)) n
  + 2q/(q-1)
  = 0                                  (mod p).

Equivalently, under the Cayley transform,

  (t+1)/(t-1)
  =
  n + 2q/((q-1)n)                      (mod p).

This is the central coupled congruence.

## Quadratic-residue obstruction

For a hard factor p, the quadratic above must have a root.  Therefore its
discriminant must be a square mod p:

  Delta =
    (q-1)^2 (t+1)^2
    - 8q(q-1)(t-1)^2

must be a quadratic residue (or zero) modulo p, where t=q^n.

This supplies a necessary factor condition independent of constructing A.

## Root-count / density bound

Fix d and p, and put r=ord_p(q).

For each residue b modulo r, t=q^b is fixed.  If t != 1, the factor condition
is a quadratic congruence in n modulo p, hence has at most two roots modulo p.
By CRT, that exponent class contributes at most two roots modulo p*r.

If t=1 and q!=1, then p|A can occur only when p|n, so that exponent class has
at most one root modulo p.

If q=1, the exact formula n(n^2+1)=0 gives at most three roots modulo p.

Consequently a single odd prime p covers at most about 2/p of the n-states in
a fixed-width period (at most 3/p in the q=1 degeneration).  This makes precise
why ordinary finite-prime sieving behaves similarly to random-integer sieving.

## Checked data through n=3000

Among the 501 checked-in explicit small-prime factor witnesses through n=3000:

- 82 factors divide n and belong to the completely classified inherited family;
- 419 do not divide n and are genuinely coupled factors;
- among those 419, there are zero examples with q!=1 and q^n=1 mod p, exactly
  as the hard-factor theorem predicts.

The hard-factor orders are broad rather than concentrated in one tiny family:
the observed order ord_p(q) ranges from 1 to well above 500, with examples
above 200000 in the checked factor data.

## Consequence for proof search

A proof that every later term is composite cannot rely only on factors of n,
repunit/cyclotomic factors of q^n-1, or a short collection of tiny fixed primes.
The remaining mechanism is the exponential-rational intersection

  q^n =
  ((q-1)U+q) / ((q-1)L+1)              (mod p),

with p, n and d all varying.

This is the equation to target with further structural arguments.


## Small-order q^n resultants

Let t=q^n and suppose a hard factor p makes t have multiplicative order k.
Since t=Y/X modulo p, p must divide the homogenized cyclotomic polynomial

  H_k(X,Y) = X^phi(k) Phi_k(Y/X).

The first cases are

  H_2 = X + Y,
  H_3 = X^2 + X Y + Y^2,
  H_4 = X^2 + Y^2,
  H_6 = X^2 - X Y + Y^2.

This is useful computationally because X and Y are only polynomial-sized in
n and q, whereas A has n decimal blocks.

After clearing powers of 2 and writing s=n^2, the degree-two cases become
quadratics in s. Their discriminants factor very simply:

  discr_s(4 H_3) = (q-1)^3 (25q-1),

  discr_s(2 H_4) = (q-1)^3 (9q-1),

  discr_s(4 H_6) = 3 (q-1)^3 (11q-3).

Therefore, away from degenerate leading coefficients, a prime in one of these
small-order families must also satisfy the corresponding quadratic-residue
condition modulo p.  For example an order-3 hard factor requires

  (q-1)(25q-1)

to be a quadratic residue modulo p.

The research tool root_order_probe.py searches these families by intersecting
H_k(X,Y) with Phi_k(q^n) and then independently verifying any common factor
against A modulo that factor.


### Reciprocity: every H_k depends only on n^2

For every k>1 the cyclotomic polynomial Phi_k is reciprocal.  Therefore its
homogenization satisfies

  H_k(X,Y) = H_k(Y,X).

Write

  C = ((q-1)n^2 + 2q)/2,
  D = (q-1)n/2,

so that

  X=C-D,
  Y=C+D.

Swapping X and Y is exactly D -> -D.  Since H_k is symmetric, every odd power
of D cancels.  Consequently, after the harmless powers of 2 are cleared,

  H_k(X,Y)

is a polynomial in n^2 and q for every k>1.

Thus each fixed small order k gives a concrete algebraic curve in the two
variables s=n^2 and q=10^d.  The order-3, order-4 and order-6 quadratics above
are the first examples of this general phenomenon.


## Reverse-concatenation symmetry

Let B be the same fixed-width block concatenated in descending order.  Pairing
coefficients gives

  A + B = (n^2+1) R_n(q).

Therefore, for any odd prime p not dividing 10,

  p | A and p | B

implies p | n(n^2+1).

Indeed, if p does not divide n^2+1 then the displayed sum forces p|R_n(q),
and the repunit identity for A then forces p|n.

Thus the ascending and descending concatenations have no unexplained common
prime factors: their common support is confined to the already-understood
index and n^2+1 mechanisms.
