# Markov uniqueness: literature review and attack notes

Research note, 2026-09-25.

This document records mathematical leads for the Frobenius/Markov uniqueness conjecture that
appear particularly relevant to LeanFrontier's current Markov-tree development. It is a research
note, not a claim that the open conjecture has been proved.

The review was performed against the current shared `main`
(`02f92e6108ef5842b07a63bf72a078b26f89b68f`) and against the newer fork-local Markov work,
especially the coordinate-root and ratio-reconstruction branches. Source statements are separated
below from deductions suggested by combining them with LeanFrontier.

## 1. Current LeanFrontier frontier

Accepted `main` already provides the ingredients needed to state the classical conjecture cleanly:

- `MarkovTree.UniquenessConjecture` and
  `uniquenessConjecture_iff_sternNode`;
- the canonical oriented binary Markov tree and its Stern-Brocot path convention;
- injectivity of complete labelled states along the canonical path model;
- `OrientedNode.markovNumber`, equal to the maximum coordinate;
- strict growth of `sternMarkovNumber` along ancestor chains.

The current fork goes further:

- `submission/markov-local-uniqueness-reduction-clean` localizes a bad collision to opposite
  child subtrees below a deepest common ancestor;
- `submission/markov-sibling-rigidity-v2` classifies immediate sibling ties;
- `submission/markov-coordinate-root-v2` defines an orientation-sensitive
  `coordinateRoot = u / v` in `ZMod |M|` and proves its square is `-1`;
- `submission/markov-ratio-reconstruction` proves that equal modular coordinate ratios plus
  a sufficiently small cross determinant reconstruct the two primitive coordinate pairs.

The literature strongly suggests that this modular root is not an incidental invariant. It is a
classical central object in the subject.

## 2. The coordinate root is the classical Markov index / Markov-fraction numerator

### Zhang's index

Ying Zhang's elementary proof of the prime-power case starts with an ordered Markoff triple
`(m,m1,m2)`, with `m` maximal, and defines a least nonnegative integer `u` by the congruence

`u*m1 ≡ ±m2 (mod m)`.

From the Markoff equation and coprimality he obtains

`u^2 + 1 ≡ 0 (mod m)`.

He then parametrizes Markoff numbers by Farey slopes and proves exact determinant identities and
strict monotonicity for `u/m`. This is the key input in his elementary proof that a prime power
(or twice a prime power) Markoff number is unique.

Source:
Y. Zhang, *An elementary proof of uniqueness of Markoff numbers which are prime powers*,
arXiv:math/0606283 (v2, 2007).
https://arxiv.org/abs/math/0606283

### Springborn's Markov fractions

Boris Springborn defines a rational Markov triple
`(p1/q1,p2/q2,p3/q3)` by requiring `(q1,q2,q3)` to be a Markov triple and

`p2*q1 - p1*q2 = q3`,
`p3*q2 - p2*q3 = q1`.

Modulo the middle denominator `q2=M`, the first identity gives

`p2*q1 ≡ q3 (mod M)`.

Therefore

`p2 ≡ q3 / q1 (mod M)`.

The second identity gives the inverse orientation:

`p2 ≡ -q1 / q3 (mod M)`.

Thus the middle numerator `p2` is exactly the oriented quotient of the two complementary
Markov coordinates, up to the swap/sign convention. Since `p2^2 ≡ -1 (mod M)`, swapping the
two coordinates inverts the root, which is the same as negating it.

This matches the fork-local `OrientedNode.coordinateRoot` construction extremely closely.

Examples:

- `(1,2,5)`: the canonical root is `2`, giving the Markov fraction `2/5`;
- `(2,5,29)`: `2/5 ≡ 12 (mod 29)`, giving `12/29`;
- `(2,29,169)`: `2/29 ≡ 70 (mod 169)`, giving `70/169`.

Source:
B. Springborn, *The worst approximable rational numbers*, J. Number Theory 263 (2024),
153-205; arXiv:2209.15542.
https://arxiv.org/abs/2209.15542

### Cohn-matrix interpretation

A. P. Veselov proves that Springborn's Markov fractions coincide with Aigner's indices of Cohn
matrices. Thus the same object is simultaneously:

1. a coordinate quotient modulo a Markov number;
2. Zhang/Frobenius's integer index;
3. the numerator of a Markov fraction;
4. the index of the associated Cohn matrix.

Source:
A. P. Veselov, *Markov fractions and Cohn matrices*, arXiv:2604.17401 (2026).
https://arxiv.org/abs/2604.17401

### Proposed Lean bridge

After the clean coordinate-root dependencies land, define a canonical integer representative,
for example

`markovIndex : OrientedNode -> Nat`

by taking the representative of `coordinateRoot` modulo `M` and quotienting the
`r ↔ -r` symmetry, e.g. the representative in `[0,M/2]`.

Useful target statements:

- `markovIndex_sq_modEq_neg_one`;
- `markovIndex_le_half`;
- compatibility with the two non-back coordinates:
  `u * v₁ ≡ ±v₂ [MOD M]`;
- swapping the complementary coordinates preserves the canonical integer index;
- a bridge theorem identifying this index with the numerator in a future Markov-fraction API.

This would put the existing fork work directly on the classical notation used in the uniqueness
literature.

## 3. A stronger two-collision identity: Srinivasan Lemma 2.1

The most immediately useful new observation in this review is an elementary identity recorded
by Anitha Srinivasan.

If `(a1,b1,c)` and `(a2,b2,c)` are Markoff triples with the same maximum `c`, then

`
(a1*a2 - b1*b2) * (a1*b2 - b1*a2)
  = c^2 * (a1*b1 - a2*b2).
`

Source:
A. Srinivasan, *Markoff numbers and ambiguous classes*,
J. Théorie des Nombres de Bordeaux 21 (2009), 757-770, Lemma 2.1.
https://www.numdam.org/articles/10.5802/jtnb.701/

This identity is very close to the current `coordinateCrossDet` machinery, but is stronger:
it relates the cross determinant to a second determinant-like factor and gains a full factor
`c^2`.

For an odd prime `g | c`, Srinivasan observes that `g` cannot divide both

`E = a1*a2 - b1*b2`

and

`D = a1*b2 - b1*a2`.

Consequently, for a hypothetical collision the prime-power factors of `c` split between the
two factors. In the prime-power case all of `c^2` must fall into one factor, and elementary size
bounds force equality, yielding uniqueness.

### Interpretation in coordinate-root language

Write, modulo an odd prime-power divisor of `c`,

`r1 = a1 / b1`,  `r2 = a2 / b2`.

Both satisfy `r_i^2 = -1`.

Then:

- `D ≡ 0` means `r1 = r2`;
- `E ≡ 0` means `r1*r2 = 1`, hence `r2 = r1^{-1} = -r1`.

So Srinivasan's factorization is exactly a **same-sign / opposite-sign decomposition of the two
square roots of -1 prime-power factor by prime-power factor**.

This appears to be the cleanest formulation yet of the general obstruction.

For a modulus with several distinct odd prime factors, Chinese remainder theory permits different
sign choices at different prime-power components. Prime powers are easy precisely because there
is no nontrivial partition of the components.

### Proposed Lean target

A very useful intermediate module would formalize the collision identity independently of the
pending modular-root stack.

Possible API:

`
def collisionSameFactor (a b : OrientedNode) : Int := ...
def collisionCrossFactor (a b : OrientedNode) : Int := ...

theorem collision_factorization
    (hM : a.markovNumber = b.markovNumber) :
    collisionSameFactor a b * collisionCrossFactor a b =
      a.markovNumber^2 * (...) := ...
`

For an ordered-triple API the statement will be cleaner.

Then prove an odd-prime localization theorem:

> If an odd prime `p` divides the common Markov number, it cannot divide both collision
> factors.

A subsequent valuation theorem should package the result as a coprime factorization
`c = p*q` (or of the odd part of `c`) with

`p^2 | E`,  `q^2 | D`.

This would formally expose the CRT sign partition.

## 4. Prime-power uniqueness is now a realistic formal milestone

There are two elementary proofs especially compatible with current LeanFrontier.

### Route A: Zhang's canonical root

Zhang proves that for `m=p^n` or `2p^n`, with `p` odd prime, the congruence

`x^2 + 1 ≡ 0 (mod m)`

has at most one solution in the canonical interval `0 < x < m/2`.

Combined with strict monotonicity of the Markov index along Farey slopes, equal Markov numbers
force equal slopes.

This route would require us to formalize the index/Farey determinant recurrence, but it aligns
perfectly with `coordinateRoot`.

### Route B: Srinivasan's collision factorization

Srinivasan's Theorem 2.2 proves the same prime-power/twice-prime-power uniqueness result using
only:

- pairwise coprimality;
- the collision factorization above;
- prime-factor separation between `E` and `D`;
- elementary size/congruence arguments.

This route appears shorter in Lean because it does not first require a full rational/Farey index
layer.

Recommended order:

1. formalize Srinivasan Lemma 2.1;
2. prove the prime-power restricted uniqueness theorem;
3. separately build the Markov-index bridge, because it is more valuable for the general attack.

A successful restricted theorem would be more than infrastructure: it would be a genuine
formalization of a classical nontrivial partial case of the open conjecture and a strong
end-to-end test of the current architecture.

## 5. The general conjecture as a CRT sign-coherence problem

The combination of the current Lean work and the literature suggests the following sharper
reduction.

For a hypothetical pair of distinct nodes with the same Markov number `M`:

1. ancestor-chain equality is already impossible;
2. the fork-local reduction puts the pair in opposite child subtrees of a common ancestor;
3. each node determines a canonical square root of `-1 mod M`;
4. for each odd prime-power factor `p^e || M`, the two roots must be equal or negatives;
5. Srinivasan's identity partitions the prime-power factors according to those two signs;
6. a genuine collision for composite `M` therefore requires a **nontrivial CRT sign pattern**.

This reframes the unresolved problem as:

> Why can two actual Markov-tree nodes with the same denominator not realize two different CRT
> sign patterns for the square root of `-1`?

That question seems substantially better aligned with our existing tree localization than the
raw global uniqueness statement.

### Speculative but concrete next experiment

Investigate whether the first divergent child direction constrains one component of this CRT
sign pattern. A theorem of the following flavor would be powerful:

> descendants in the two opposite child subtrees cannot have coordinate roots whose prime-power
> sign vectors differ in an arbitrary prescribed way.

No such theorem was found in the reviewed literature, so this is a research hypothesis, not an
established result.

A computational experiment over a large initial segment of the Markov tree could record, for
each node:

- its path;
- `M);
- factorization of the odd part of `M);
- canonical coordinate root;
- the root modulo each prime-power factor;
- parent and first-divergence data.

The goal would be to look for a stable branch/sign invariant before attempting a Lean statement.

## 6. A second classical route: quadratic forms and ambiguous classes

Srinivasan also gives a deeper reformulation for composite `c`.

For discriminant

`d = 9*c^2 - 4`,

non-uniqueness yields coprime `p,q>1`, `c=pq`, and a binary quadratic form of discriminant
`d` representing both `-p^2` and `q^2`, equivalent to its inverse. She proves that, for
non-prime-power `c`, Markov uniqueness is equivalent to the nonexistence of the corresponding
ambiguous ideal/form configuration in the quadratic field `Q(sqrt(d))`.

The same paper derives sufficient uniqueness criteria from ambiguous classes in the principal
genus and Legendre symbols of the prime divisors of `d`.

This is mathematically strong, but likely much more expensive to formalize in Lean than the
elementary collision/index route. It should be treated as a second-line route or source of
arithmetic invariants rather than the immediate implementation target.

Source:
A. Srinivasan, *Markoff numbers and ambiguous classes* (2009), especially Theorems 5.1, 5.3,
5.4 and 6.1.
https://www.numdam.org/articles/10.5802/jtnb.701/

Earlier ideal-theoretic sources include:

- A. Baragar, *On the unicity conjecture for Markoff numbers*, Canadian Math. Bulletin 39
  (1996), 3-9.
- J. O. Button, *Markoff numbers, principal ideals and continued fraction expansions*,
  J. Number Theory 87 (2001), 77-95.

## 7. Other relevant literature

### Zhang's `3c ± 2` route

The Markoff equation can be rewritten

`(b-a)^2 + c^2 = a*b*(3c-2)`,
`(a+b)^2 + c^2 = a*b*(3c+2)`.

Zhang uses these identities and elementary congruence arguments to prove uniqueness whenever
one of `3c-2` or `3c+2` is a prime power, four times a prime power, or eight times a prime
power.

Source:
Y. Zhang, *Congruence and uniqueness of certain Markoff numbers*,
Acta Arith. 128 (2007), 295-301; arXiv:math/0612620.
https://arxiv.org/abs/math/0612620

This looks like another relatively cheap restricted theorem after the prime-power case.

### Larger known arithmetic families

Button's 2001 work proves uniqueness for broader almost-prime-power families; Chen and Chen
(2013) give complementary criteria for `3c±2`. These results may be valuable later, but their
proof infrastructure is heavier than the two elementary Zhang/Srinivasan routes.

F.-J. Chen and Y.-G. Chen,
*On the Frobenius conjecture for Markoff numbers*, J. Number Theory 133 (2013), 2363-2373.
https://doi.org/10.1016/j.jnt.2012.12.018

### Christoffel/Sturmian word routes

Christoffel words give another parametrization of Markoff triples. Work by Bugeaud,
Reutenauer and Siksek and by Lapointe and Reutenauer proves injectivity on substantial
subclasses/languages.

- Y. Bugeaud, C. Reutenauer, S. Siksek,
  *A Sturmian sequence related to the uniqueness conjecture for Markoff numbers*,
  Theor. Comput. Sci. 410 (2009), 2864-2869.
- M. Lapointe, C. Reutenauer,
  *On the Frobenius conjecture*, INTEGERS 21 (2021), A67.

These are credible sources of additional formally provable subclasses, but they require a new
word/matrix representation and therefore do not currently beat the modular route in expected
progress per unit effort.

### q-deformed injectivity

A q-analogue of Markoff injectivity is known to be true, and newer q-deformed Cohn-matrix work
makes the rational label recoverable from the polynomial data. This is conceptually interesting:
the deformation contains more information than evaluation at q=1, precisely where collisions
could occur.

It is not currently an obvious direct proof route for the classical conjecture.

## 8. Mathlib feasibility

A scoped Mathlib search found useful existing infrastructure:

- `ZMod.chineseRemainder`;
- natural-number Chinese remainder theorems;
- `ZMod.isSquare_neg_one_of_dvd`;
- quadratic-residue / Legendre-symbol infrastructure;
- the sum-of-two-squares module already reasons about square roots of `-1` modulo composite
  moduli.

What appears not to be packaged exactly for us is the elementary theorem that for an odd
prime power `p^n`, the roots of `x^2=-1` are exactly one pair `±r`; this should nevertheless
be short to prove from

`(x-y)(x+y) ≡ 0 mod p^n`

because an odd prime cannot divide both factors when `x,y` are roots.

Thus the proposed modular formalizations look technically realistic.

## 9. Recommended next targets

### Immediate

1. **Srinivasan collision identity.**
   Small, independent, and directly strengthens our collision API.
2. **Prime-factor sign split.**
   Interpret the two factors as equal/opposite coordinate roots modulo prime-power factors.
3. **Restricted prime-power uniqueness theorem.**
   Prefer the collision-factorization proof first because it should require less new machinery.

### Then

4. **Canonical integer Markov index.**
   Bridge `coordinateRoot` to Zhang/Springborn/Aigner notation.
5. **Farey determinant identities / monotonicity.**
   Formalize the exact recurrence for the index along the accepted Stern-Brocot representation.
6. **Cross-subtree CRT sign coherence.**
   Combine the existing local uniqueness reduction with the new sign-partition invariant.

### Secondary

7. Zhang's `3M±2` restricted uniqueness families.
8. Sturmian/Christoffel injectivity subclasses.
9. Quadratic-form / ambiguous-class route if the elementary route stalls.

## 10. Main research conclusion

The literature review changes the interpretation of our current work.

The fork's modular coordinate root is essentially a rediscovery, in Lean-compatible form, of the
classical Markov index / Markov-fraction numerator. More importantly, Srinivasan's two-triple
identity shows exactly what goes wrong for general composite Markov numbers: prime-power
components can split between the two signs of the square root of `-1`.

So the current frontier can be expressed much more sharply as:

**rule out a nontrivial CRT sign split for two actual Markov-tree nodes having the same maximum.**

That is a concrete arithmetic/tree interaction problem, and LeanFrontier already contains much
of the structural machinery needed to attack it.
