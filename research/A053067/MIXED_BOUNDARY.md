# Mixed-width boundary structure

Let n_d be the unique index whose A053067 block crosses 10^d:

T_(n_d-1) < 10^d <= T_(n_d),  where T_n=n(n+1)/2.

## Exact boundary index

The index is the nearest integer to sqrt(2*10^d):

n_d = floor(sqrt(2*10^d) + 1/2).

Equivalently,

n_(2k)   = floor(sqrt(2) * 10^k + 1/2),
n_(2k+1) = floor(2*sqrt(5) * 10^k + 1/2).

This follows directly from comparing m(m-1) and m(m+1) with 2*10^d for
m=floor(sqrt(2*10^d)+1/2).

## Balanced-decimal recurrence

Define

e_d = n_(d+2) - 10 n_d.

Since sqrt(2*10^(d+2)) = 10 sqrt(2*10^d), nearest-integer rounding gives

e_d in {-5,-4,...,4,5}.

If epsilon_d = n_d - sqrt(2*10^d), then

-1/2 < epsilon_d < 1/2

and

epsilon_(d+2) = 10 epsilon_d + e_d.

Thus the correction sequence is a centered decimal digit stream coming from
sqrt(2) on even widths and 2*sqrt(5) on odd widths.

## Exact recurrence for the split point

Put

delta_d = T_(n_d) - 10^d.

Then 0 <= delta_d < n_d.  The mixed block has

b_d = delta_d + 1

high-width terms and

a_d = n_d - delta_d - 1

low-width terms.

Substituting n_(d+2)=10 n_d+e_d and
10^d=T_(n_d)-delta_d gives

delta_(d+2)
  = 100 delta_d
    + (10 e_d - 45) n_d
    + e_d(e_d+1)/2.

So the boundary subsequence has an exact integral two-step dynamical system.

## Split fraction

With epsilon_d as above,

delta_d
  = n_d(epsilon_d + 1/2) - epsilon_d^2/2.

Hence

delta_d / n_d = epsilon_d + 1/2 + O(1/n_d).

The point where the block changes decimal width is therefore controlled by
the same centered decimal dynamics.

## Two-base concatenation

Let q=10^d, n=n_d, delta=delta_d,

a=n-delta-1,
b=delta+1,
L=n(n-1)/2+1.

For

F(Q,L,0)=0,
F(Q,L,k+1)=Q F(Q,L,k)+(L+k),

the mixed term is exactly

A_mix(d) = (10q)^b F(q,L,a) + F(10q,q,b).

This is the modular formula used by mixed_boundary.py.

## Research implication

The fixed-width problem is periodic modulo a prime once d is fixed.  The
mixed-width boundary residues additionally inherit the decimal digit dynamics
of sqrt(2) and 2*sqrt(5), so they should be studied as a separate sparse
subsequence rather than assumed to obey a simple periodic-in-d covering.


## Finite-state reduction modulo a prime

Fix an odd prime p not dividing 10 and let

r = ord_p(10).

For the mixed decomposition

A_mix(d) = (10q)^b F(q,L,a) + F(10q,q,b),

the residue modulo p is determined by:

- q=10^d modulo p, hence by d modulo r;
- L modulo p, hence by n modulo p;
- the exponents a=n-delta-1 and b=delta+1 modulo the orders of q and 10q,
  both of which divide r.

Since gcd(p,r)=1, it is therefore enough to know

d mod r,
n mod (p r),
delta mod (p r).

Thus divisibility by p is a predicate on a finite state space.

The exact two-step recurrence

n' = 10 n + e,

delta' = 100 delta + (10e-45)n + e(e+1)/2

updates this finite state once the balanced digit e in {-5,...,5} is known.

Consequently the mixed-width divisibility problem for any fixed finite prime
set can be represented as a finite automaton driven by the two balanced-decimal
streams associated with sqrt(2) and 2*sqrt(5).

This is a useful reduction, but not by itself a global proof: controlling the
infinite driver stream requires information about the decimal expansions of
those algebraic irrationals beyond mere irrationality.
