# A053067 covering-proof search

The goal of this track is stronger than bounded primality testing: construct a
finite family of exact congruence implications whose union covers every
A053067 index that could otherwise be prime.

For a fixed-width block with decimal width d, let q=10^d.  The exact identity

    A(n) (q-1)^2
      = q^n ((q-1)L_n + 1) - ((q-1)U_n + q)

shows that, for every prime p not dividing 10, divisibility by p is periodic
in d and n.

A covering clause has the form

    d == a (mod ord_p(10))
    n == b (mod m)
    -----------------------
            p | A(n)

where m is p*ord_p(10^d), or just p when 10^d == 1 (mod p).

## Counterexample-guided construction

`cover_cegar.py` asks Z3 for an admissible state not covered by the clauses
currently known.  For that state it searches a finite prime pool, chooses a
prime divisor whose arithmetic progression is as broad as possible, adds the
corresponding exact clause, and asks Z3 again.

If Z3 returns UNSAT, the accumulated clause list is a finite covering
certificate.

## First experiment: deliberately over-strong domain

The first run required the clauses to cover every pair

    d >= 3
    n > 2
    n mod 60 in {1,2,13,17,22,26,37,38,41,46,53,58}

even when n is not in the genuine d-digit A053067 interval.

Z3 first produced

    d=3, n=17

which is covered by p=109, yielding the exact clause

    d == 3 (mod 108)
    n == 17 (mod 3924)
    => 109 | A_d(n).

After adding that clause, Z3 produced

    d=108, n=66718

for which no divisor <= 100000 was found.

This is not a meaningful obstruction to A053067: n=66718 is vastly too small
to be a genuine 108-digit fixed-width block.  The experiment therefore showed
that the unrestricted two-dimensional covering target is unnecessarily
strong.

## Refined experiment

The current search constrains each tested d to its actual fixed-width interval

    10^(d-1) <= L_n
    U_n < 10^d,

with d=3..10 in the first run, and a divisor-discovery pool up to 10^6.

This finite experiment has two purposes:

1. determine whether exact congruence families can completely cover genuine
   widths at all; and
2. inspect the first genuine uncovered states when they cannot.

If the same pattern repeats across consecutive d, the next step is to search
for a periodic-in-d family and prove that it covers every sufficiently large
fixed-width interval.

## Important empirical warning

The sieve-only run on 100001..1000000 found:

- 180000 indices surviving the exact 2/3/5 filter;
- 153627 with an explicit factor <= 10^6;
- 26373 with no factor <= 10^6.

The survivor fraction among admissible indices is about 0.1465.  Mertens'
heuristic for random integers conditioned not to be divisible by 2,3,5 gives
about 0.1524 after sieving by primes through 10^6.

So the observed small-prime factor density is quite close to random-integer
behaviour.  This is evidence against expecting a very small finite set of
prime divisors to cover all terms.  It does not rule out a deeper structural
covering, an unbounded factor family, or a later prime term.

## Mixed-width blocks

For each decimal boundary 10^d there is one block crossing from d to d+1
digits.  Fixed-width congruence lemmas do not apply to that block.

A preliminary modular scan of the first 300 boundaries found 53 mixed-width
indices that survive the exact 2/3/5 filter.  Of those, 41 have a factor below
10000 and 12 do not.  Thus a full negative solution would need a separate
argument for this sparse boundary subsequence even if the fixed-width covering
problem were solved.
