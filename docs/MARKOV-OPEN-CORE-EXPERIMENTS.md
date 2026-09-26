# Markov open-core research experiments

Research note, 2026-09-26.

This branch deliberately uses a research-first workflow. The goal is to attack the unresolved Frobenius/Markov uniqueness core with computation and informal algebra first, using Lean only when an exploratory statement survives falsification and looks genuinely structural.

Nothing in this note is an upstream submission and nothing here claims a proof of the open conjecture.

## 1. Important correction: the current Stern-Brocot bridge is not yet Zhang's planar Farey labeling

The live LeanFrontier module LeanFrontier/NumberTheory/MarkovTree/SternBrocot.lean identifies binary tree positions with oriented Markov tree positions after a path-convention reversal. Its own documentation explicitly stops before any numerical Markov-label claim.

That distinction matters. A direct computational transcription of the live definitions shows that using the same Boolean word on both sides does not preserve the planar left/centre/right Farey meaning needed by the classical Markov-index literature.

Under the planar Markov recursion from frame (1,2,1), the classical two-step left path has frame (1,13,5), hence centre label 13. Blindly following the same two Boolean child directions in the current coordinate-oriented recursion instead reaches a node with maximal label 29.

Therefore the shortcut “existing SternBrocot.pair path plus existing sternNode path already carries Zhang's numerical slope/Markov-number correspondence” is false.

## 2. A six-state orientation transducer repairs the mismatch

Carry a frame (L,M,R) telling us which physical Markov coordinate currently represents the left Farey boundary, the centre/maximal Markov number, and the right Farey boundary.

At the oriented root (1,1,2), choose:
- left boundary = coordinate 2,
- centre = coordinate 3,
- right boundary = coordinate 1.

The initial frame is therefore 231.

For a planar left step, the new centre is 3LM-R. We jump the coordinate tagged R and update
(L,M,R) -> (L,R,M).

For a planar right step, the new centre is 3MR-L. We jump the coordinate tagged L and update
(L,M,R) -> (M,L,R).

The actual Lean Boolean child bit is the unique dir for which forwardMove back dir is the coordinate to jump.

Only six frames occur:

| frame | planar L | planar R |
|---|---|---|
| 123 | Lean 1, next 132 | Lean 0, next 213 |
| 132 | Lean 1, next 123 | Lean 0, next 312 |
| 213 | Lean 1, next 231 | Lean 0, next 123 |
| 231 | Lean 0, next 213 | Lean 1, next 321 |
| 312 | Lean 0, next 321 | Lean 1, next 132 |
| 321 | Lean 0, next 312 | Lean 1, next 231 |

The companion script tools/research_markov_open_core.py checks this against an exact Python transcription of LeanFrontier's forwardMove, child, and Vieta jump definitions.

The current test exhaustively verifies all binary paths through depth 12: 8191 planar nodes, with exact equality of all three coordinates and the distinguished back coordinate after translation.

Sample translations:

| planar path | direct Lean follow bits | sternNode path |
|---|---|---|
| L | L | L |
| R | R | R |
| LL | LR | RL |
| LR | LL | LL |
| RL | RL | LR |
| RR | RR | RR |

The last column reverses the direct bits because sternNode follows path.reverse.

This gives a concrete route to a future planar Markov frame without rebuilding the Markov equation or tree. If the Zhang/Farey route becomes mathematically decisive, the Lean checkpoint should probably formalize this small finite-state orientation bridge first.

## 3. Two simple root-selection hypotheses fail

The general composite case can be viewed as selecting the genuine Markov square root of -1 from several CRT roots modulo a composite Markov number.

### 3.1 A narrow interval does not isolate the genuine root

Along large parts of the planar Markov tree the canonical coordinate-root ratio lies in a narrow range near

(3-sqrt(5))/2 = 0.381966...

and

sqrt(2)-1 = 0.414213....

A tempting hypothesis was that a Markov modulus might have only one square root of -1 in this interval.

It is false.

For the Markov number M = 48,928,105, both

18,915,767^2 == -1 mod M

and

20,226,717^2 == -1 mod M,

and both ratios lie inside that narrow interval.

So interval location alone cannot select the genuine CRT root.

### 3.2 Zhang's single-matrix inequalities do not isolate the root either

Zhang packages a Markov index u into a matrix of the form

[ 2M-u      2M+u-v ]
[ M         M+u    ]

with v = (u^2+1)/M, and proves strong inequalities for genuine Markov matrices.

Source:
Y. Zhang, “An elementary proof of uniqueness of Markoff numbers which are prime powers”, arXiv:math/0606283, especially Propositions 7-8.
https://arxiv.org/abs/math/0606283

Substitution gives local conditions including

2u <= M,
v <= 2u,
5u <= 2M + 2v.

These are also insufficient.

For the Markov number M = 985, both u = 183 and u = 408 satisfy u^2 == -1 mod 985, and both satisfy the displayed matrix-shape inequalities.

Thus the missing information is not merely square-root congruence, centered representative, positivity, or the elementary inequalities of a single candidate matrix.

The genuine root must remember ancestry / word / Farey-semigroup structure.

## 4. Collision-search sanity check

The research script also contains a bounded planar-tree collision search.

In this session, M <= 10^100 enumerated 19,337 planar path nodes, representing 9,669 distinct centre labels after the expected planar symmetries, and found no common maximal Markov label attached to two distinct unordered triples.

This is only a test of the implementation. A finite negative search says nothing about the general conjecture.

## 5. Revised research target

The strongest next question is now:

Given a Markov modulus M and a candidate centered root u^2 == -1 mod M, what efficiently checkable condition says that the associated positive SL_2(Z) matrix actually belongs to the Markov/Christoffel/Farey semigroup?

For small examples such as M = 985, the genuine and fake roots both pass the local arithmetic filters. Their difference must therefore become visible only when one tries to descend or factor the candidate matrix through the Markov-word structure.

Concrete next experiment:
1. construct Zhang/Cohn candidate matrices for every centered CRT root;
2. implement a descent or word-recognition procedure for the Markov/Christoffel semigroup;
3. compare descent traces of genuine and fake roots;
4. search for a small invariant at the first point where fake candidates fail;
5. formalize only that invariant if it survives broad computational testing.

This is now the preferred open-core route.

## 6. Workflow rule from here

For this branch:
- computation, notes, and intentionally disposable conjectures are welcome;
- failed hypotheses should be recorded when they materially narrow the search;
- Lean files should be added only to test a critical mathematical checkpoint;
- no upstream PR should be created merely because an exploratory lemma compiles;
- reusable independent mathematics can still graduate to the normal submission pipeline once its value is clear.


## 7. Cohn-monoid recognition is a strong root filter

The Cohn generators used here are

[
A=egin{pmatrix}1&1\\1&2end{pmatrix},
qquad
B=egin{pmatrix}2&1\\1&1end{pmatrix}.
]

For a candidate modular root (u^2equiv-1pmod M), with

[
v=(u^2+1)/M,
]

the transpose of Zhang's matrix is

[
X(M,u)=
egin{pmatrix}
2M-u & M\\
2M+u-v & M+u
end{pmatrix}.
]

The research script now recognizes membership in the positive free monoid
generated by (A,B) by repeatedly stripping a possible final generator using
the integral inverses

[
A^{-1}=egin{pmatrix}2&-1\\-1&1end{pmatrix},
qquad
B^{-1}=egin{pmatrix}1&-1\\-1&2end{pmatrix},
]

while requiring nonnegative entries.

For (M=985):

- the genuine centered Markov root (u=408) factors as the Cohn word
  `ababababb`;
- the other centered root (u=183) does not lie in the positive (A/B) monoid.

A larger computational test enumerated 326 distinct positive Markov triples
with (Mle10^{18}).  In every case the genuine centered coordinate root
produced an (A/B)-factorable candidate matrix, while no other centered CRT
root did.

This is a strong experimental filter, but it is not a proof mechanism: the
open uniqueness problem can reappear as uniqueness of the relevant special
words inside the positive Cohn monoid.

## 8. Candidate-shape matrices and palindromic inner words

A simple matrix calculation explains the relevant larger word class.

For

[
P=egin{pmatrix}x&y\\z&tend{pmatrix},
]

direct multiplication gives

[
operatorname{tr}(APB)-3(APB)_{12}=z-y.
]

Hence if (P) is symmetric, (APB) satisfies

[
operatorname{tr}(APB)=3(APB)_{12}.
]

Since (A) and (B) themselves are symmetric, every word of the form

[
a,p,b
]

with (p) a palindrome yields a matrix of the same numerical shape as a
Zhang candidate matrix.

Conversely, among nontrivial positive (A/B) words, exhaustive enumeration
suggests that the trace identity forces precisely this (a,p,b) form with
palindromic (p).  The endpoint exclusions also have elementary sign
certificates; for example the analogous trace-minus-three-upper-right
expressions for (APA), (BPA), and (BPB) are strictly negative for a
positive inner matrix.

This is not yet a Lean theorem on the research branch, because it is useful
only if the word route survives the next stage.

## 9. Arbitrary palindromes are too broad, but central palindromes look isolated

Proper Christoffel words have the classical form

[
a,p,b
]

where (p) is a **central word**, in particular a palindrome with the
appropriate coprime-period condition.  Thus the Markov/Christoffel subclass is
strictly smaller than the full palindromic Cohn class above.

The research script now enumerates arbitrary palindromic inner words and marks
the central ones using the period characterization.

Through inner palindrome length 36 the scan contains:

- 1,048,573 palindromic words;
- 524,151 distinct candidate denominators;
- 132 denominators supporting more than one centered root;
- 449 central-word entries;
- 225 distinct central/Markov denominators;
- no multi-root denominator involving a central word;
- no denominator shared at all between a central and a noncentral word in the
  scanned range.

The broad palindromic class therefore definitely does **not** have a uniqueness
property.

The first collision occurs already at

[
M=1130.
]

Four noncentral witnesses are:

| word | centered root |
|---|---:|
| `aaababaab` | 437 |
| `aabaaabab` | 467 |
| `ababbbabb` | 467 |
| `abbababbb` | 437 |

This is useful because it prevents us from mistaking the elementary palindrome
identity for the hard theorem.

### Empirical strengthening to investigate

The scan suggests the stronger statement:

> If (p) is central, (q) is any palindrome, and
> (m(a p b)=m(a q b)), then (q) is central (and hence the collision is
> already inside the classical Christoffel/Markov subclass).

No proof is claimed.  This could be strictly harder than the original
Frobenius conjecture.  Its value is that it places the problem inside a larger
class where genuine counterexamples exist, so one can ask what exact
central-word property prevents the observed (M=1130)-type collisions.

## 10. Connection with generalized Cohn m-values

Lagisquet, Pelantová, Tavenas and Vuillon extend Cohn's (m)-value from
Christoffel words to arbitrary lattice-path words.  Their work identifies
Christoffel paths as minimizers for fixed endpoint data and studies generalized
unicity phenomena beyond the coprime case.

This suggests a more structural version of the central-isolation experiment:

> Can equality of an arbitrary palindromic candidate denominator with a
> central/Christoffel denominator be combined with the Christoffel extremal
> property to force the arbitrary word to have the same endpoint and then be
> central?

The missing point is that equal (m)-value alone does not obviously imply
equal endpoint/count data.  That is now a concrete obstruction rather than an
unspecified need for “more word structure”.

## 11. New 2026 convex-geometry constraint

Cormac O'Sullivan's September 2026 preprint, *Patterns in the Markov numbers
and their generalizations*, gives a continuous convex encoding of the Markov
tree.

For the standard Markov case, after the paper's factor-of-three normalization,
Markov labels indexed by primitive lattice points ((n,k)) are represented by

[
m_{k/n}=2cosh(nPhi(k/n)).
]

The function (Phi) is strictly convex in the classical (D<4) regime.
Consequently equal labels correspond geometrically to two primitive lattice
points lying on the same dilate of a strictly convex level curve.

The paper explicitly does **not** close Frobenius uniqueness.  Its uniqueness
section proves a useful necessary condition instead: repeated labels must occur
along an index line whose slope lies inside the interval of slopes attained by
that convex curve.  For the standard Markov tree the numerical interval given
in the paper is approximately

[
-1.242 < s < -1.143.
]

This gives an independent filter on a hypothetical collision.

Combining it with the modular work, any genuine counterexample must now satisfy
both:

1. a nontrivial CRT sign split between the two coordinate roots modulo the
   prime-power factors of the common Markov number; and
2. an index-lattice displacement whose slope lies in the narrow convex-geometric
   interval above.

These constraints come from very different representations.  Their
interaction is now a higher-priority research target than further standalone
congruence lemmas.

## 12. Current preferred attack

The open-core work now has three nested representations of the same candidate:

1. **Arithmetic:** a centered root (u^2equiv-1pmod M), with its CRT sign
   vector.
2. **Word/matrix:** the Zhang candidate matrix (X(M,u)), tested for membership
   in the positive Cohn monoid and, more strongly, in the central/Christoffel
   subclass.
3. **Geometry:** a primitive index lattice point constrained by O'Sullivan's
   strictly convex encoding.

The immediate research question is:

> Can a nontrivial CRT sign change preserve central/Christoffel word membership
> while also keeping the corresponding two primitive index points inside
> O'Sullivan's allowable collision-slope window?

This is substantially narrower than asking directly why two incomparable
Markov-tree branches cannot share a label.

The next computational work should therefore recover the primitive
Farey/Christoffel index ((n,k)) together with the Cohn word and modular root,
then measure how CRT sign changes alter the word and index data.  Lean should
enter only if this produces a stable exact relation rather than another
numerical pattern.


## 13. Continued-fraction filter for CRT roots

The modular-root experiment now has a cleaner arithmetic form.

For a positive Markov triple with centre/maximal coordinate (M), let (u) be
the centered coordinate root obtained from the two complementary coordinates.
Then (u^2\equiv -1 \pmod M), and the regular continued fraction of (M/u)
is palindromic.

This is consistent with the classical continued-fraction descriptions of
Markov fractions and Markov numbers. In particular, work of Çanakçı and
Schiffler gives palindromic continued-fraction descriptions of Markov numbers
using only the partial quotients (1) and (2), with additional run
constraints depending on the Farey slope. Springborn's Markov-fraction picture
and Reutenauer's weak Markoff theory describe the same symbolic structure from
related viewpoints.

References:
- İ. Çanakçı, R. Schiffler, work on continued fractions of Markov numbers;
- B. Springborn, *The worst approximable rational numbers*;
- C. Reutenauer, *Christoffel words and weak Markoff theory*.

The finite experiment was enlarged to **1,011 distinct positive Markov
triples with (M\le 10^{32})**.

For each (M), all square roots of (-1\pmod M) were computed and reduced by
the sign symmetry (u\leftrightarrow M-u). The genuine centered root was
identified independently from the complementary coordinates of the actual
Markov triple.

Totals in this scan:

- 5,423 non-genuine centered roots;
- 1,752 non-genuine roots still satisfy the crude interval
  (M/3\le u\le M/2);
- **0 non-genuine roots** have a continued fraction (M/u) whose partial
  quotients are all in ({1,2});
- for every one of the 1,011 Markov triples, the genuine root is the **unique**
  centered root passing the ({1,2})-continued-fraction filter.

Examples:

- (M=985):
  - genuine (u=408), with (985/408=[2,2,2,2,2,2,2,2]);
  - fake (u=183), with
    (985/183=[5,2,1,1,1,1,2,5]).

- (M=48,928,105):
  - the genuine root (20,226,717) has only (1)'s and (2)'s;
  - the alternative root (18,915,767), despite lying in the same narrow
    numerical interval, has larger partial quotients (including (3) and
    (4)).

This is **not yet evidence of a new proof**. The literature already makes clear
that the Markov/Christoffel problem is deeply equivalent to special balanced
continued-fraction words on ({1,2}). The value of the experiment is that it
gives an exact interface between our CRT-sign language and that classical word
language:

> a hypothetical collision must produce two different square roots of
> (-1\pmod M) whose centered continued fractions both remain entirely inside
> the Markov alphabet ({1,2}), and in fact satisfy the stronger
> Christoffel/central balance condition.

This is a much sharper target than the earlier interval tests.

### Long fake prefixes rule out a purely local cutoff

The fake roots can imitate the allowed alphabet for a surprisingly long time
before failing.

In the (M\le10^{32}) scan, one fake root first leaves ({1,2}) only at
continued-fraction index 32. One explicit case is

[
M=401802671206705795353304445,
]

with genuine root

[
155339674974133842143735298
]

and a fake root

[
166102461991230794138908258.
]

The fake continued fraction stays in ({1,2}) for 32 terms before a (9)
appears; later a (52) also appears, symmetrically.

So no argument based only on checking a bounded initial block of partial
quotients is likely to work. The proof target must be global: balance,
centrality, a continuant inequality, or an interaction with the CRT factor
split.

## 14. New palindrome experiment: equal m-values appear to preserve endpoint counts

The broad Cohn-monoid scan gave another unexpectedly clean pattern.

For every inner palindrome (p), consider the word

[
w=a p b.
]

Its Cohn matrix satisfies

[
\operatorname{tr}(M_w)=3(M_w)_{12},
]

so it has exactly the same numerical “candidate shape” as a Zhang/Cohn Markov
matrix, even when (p) is not central.

The scan through inner palindrome length 36 contains:

- 1,048,573 words;
- 524,151 distinct candidate (m)-values;
- 132 (m)-values occurring with more than one centered modular root.

The first such collision is the already recorded (M=1130) example.

A new diagnostic records the unordered endpoint-count pair

[
{,|w|_a, |w|_b,}.
]

Across the entire scan there are:

- **132** repeated candidate (m)-values;
- **0** cases where one repeated (m)-value occurs for two different unordered
  endpoint-count pairs.

For example, all four (M=1130) witnesses have counts ((6,3)) or its
letter-exchanged version ((3,6)).

This suggests the stronger experimental statement:

> For words of the form (a p b) with (p) palindromic, the (m)-value may
> determine the Parikh vector ((|w|_a,|w|_b)) up to exchanging the letters.

If true, this would be extremely strong. A Christoffel word is determined by
its coprime endpoint counts, so applying such a theorem to two Christoffel
words with the same Markov number would immediately collapse a Frobenius
collision to the same Farey endpoint.

Accordingly, this conjecture is **at least as ambitious as the original
uniqueness problem on the central subclass**. It should not be mistaken for a
cheap lemma merely because it has a simple formulation.

Still, the larger palindrome class is useful experimentally because it has real
collisions. We can now compare:

- collisions that do occur: same (m), same endpoint counts, different
  palindrome arrangements;
- the collision we need to rule out: same (m), different primitive endpoint
  counts, with both words central.

That contrast gives a concrete combinatorial question rather than a raw
Diophantine one.

### Why the 2021 path-minimality theorem is relevant

Lagisquet--Pelantová--Tavenas--Vuillon prove that, for fixed endpoint counts,
the generalized Christoffel path minimizes the (m)-value among all lattice
paths with those counts.

Thus, if equal (m)-values really force equal endpoint counts, the rest would
be close to automatic on the Christoffel subclass: the central/Christoffel
word is the canonical minimizer for that endpoint.

What is missing is precisely the cross-endpoint statement. The numerical
ranges for different endpoint-count pairs overlap substantially, so this
cannot follow from a crude monotone interval bound; an exact structural
argument would be needed.

## 15. Immediate research direction

The best next bridge now looks like:

1. express a centered root (u^2\equiv-1\pmod M) by its palindromic
   continued fraction (M/u);
2. translate the CRT sign flip relative to the genuine Markov root into an
   operation on the associated continuant / palindrome;
3. use the Christoffel central-word characterization to ask why a nontrivial
   sign flip must either
   - create a partial quotient at least (3), or
   - destroy the central/balanced condition;
4. in parallel, investigate the stronger palindrome statement that equal
   trace-shaped (m)-values preserve endpoint counts.

Lean should stay out of this until one of these statements acquires an actual
proof mechanism.


## 16. Exact modular-root core and Euclidean-word interpretation

The computational filters above admit a clean exact algebraic package.

Let M > 0 and suppose u^2 == -1 (mod M). Write

v = (u^2 + 1) / M.

Define the symmetric matrix

P(M,u) =
  [ M - 2u + v    u - v ]
  [ u - v         v     ].

Then

det P(M,u) = (M - 2u + v)v - (u-v)^2 = Mv - u^2 = 1.

Moreover, with the Cohn generators

A = [1 1; 1 2],   B = [2 1; 1 1],

direct multiplication gives

A P(M,u) B =
  [ 2M-u       M   ]
  [ 2M+u-v     M+u ],

which is exactly the transposed Zhang candidate matrix used in the earlier experiments.

Conversely, for any positive symmetric unimodular matrix

P = [x y; y z],  xz-y^2=1,

put

M = x + 2y + z,   u = y + z.

Then

Mz = (x+2y+z)z = 1 + (y+z)^2 = 1+u^2,

so u^2 == -1 (mod M).

Thus centered square roots of -1 can be regarded as positive symmetric determinant-one matrices equipped with the linear functional M=(1,1)P(1,1)^T.

This separates two issues cleanly:

1. arithmetic: P is a positive symmetric unimodular matrix;
2. Markov/Cohn structure: P belongs to the much smaller positive monoid generated by A,B, and in the genuine case the corresponding palindrome is central/Christoffel.

### 16.1 Cohn generators are paired Euclidean generators

Introduce

L = [1 1; 0 1],   R = [1 0; 1 1].

Then exactly

A = R L,   B = L R.

A positive unimodular matrix has a deterministic Euclidean L/R factorization. Therefore a modular-root core belongs to the positive Cohn monoid precisely when its unique Euclidean word can be cut, in the correct phase, into two-letter blocks RL or LR.

The research script now prints this L/R word and the attempted pair decoding.

Examples:

- M=985, u=408 (genuine):
  P=[[338,239],[239,169]] and the Euclidean word is
  LRRLLRRLLRRLLR.
  It pairs as
  LR | RL | LR | RL | LR | RL | LR,
  hence gives the Cohn core word bababab.

- M=985, u=183 (alternative root):
  P=[[653,149],[149,34]] and the Euclidean word is
  LLLLRRLRLRLLRRRR.
  It fails the fixed two-letter phase.

- M=73, u=27:
  the continued fraction of 73/27 uses only 1s and 2s, but the Euclidean word
  LRLLRRLR
  pairs as LR | LL | RR | LR and therefore is not a Cohn word.

This exactly explains why the earlier “all partial quotients are 1 or 2” filter was strong but not sufficient for arbitrary moduli: it sees run lengths, but not the required pair phase.

### 16.2 Symmetry becomes an anti-palindrome

Transpose exchanges L and R. If P=P^T and positive L/R factorization is unique, its Euclidean word W satisfies

W = swap(reverse(W)).

So every modular-root core corresponds naturally to an anti-palindromic Euclidean word.

If W also has the valid Cohn two-letter phase, W is the image of a word p under

a -> RL,  b -> LR,

and anti-palindromicity implies that p is a palindrome.

The hierarchy is therefore:

1. centered root of -1 modulo M
   <-> positive symmetric unimodular core;
2. Cohn-compatible root
   <-> anti-palindromic L/R word with correct pair phase
   <-> palindromic A/B word;
3. genuine Markov root
   <-> the resulting palindrome is central / Christoffel.

This locates the remaining open difficulty very precisely.

## 17. Calibration against a known stronger continued-fraction conjecture

The continued-fraction root experiment is close to a known conjectural strengthening, not an easy missing lemma.

Çanakçı and Schiffler prove that every Markov number m>2 has coprime positive integers a<b with

m=a^2+b^2,   2a <= b < 3a,

and with the continued fraction of b/a using only 1s and 2s. They conjecture that this pair is unique, and explicitly state the version using only these arithmetic/continued-fraction conditions as a stronger conjecture.

For M=985 the two primitive decompositions are

985 = 12^2 + 29^2 = 16^2 + 27^2.

The genuine modular root u=408 corresponds to the first pair, whose ratio 29/12 has the Markov continued-fraction structure. The alternative root u=183 corresponds to the second pair and fails that selection criterion.

So the CRT-root, Gaussian-integer, continued-fraction, and Cohn-core experiments are different coordinate systems on essentially the same root-selection problem.

## 18. Endpoint-count stress test extended to inner length 42

For every word w=a p b with p palindromic and inner length at most 42, the exhaustive scan records its candidate m-value and unordered endpoint-count pair {|w|_a,|w|_b}.

The total is **8,388,605 palindromic candidates**.

No candidate m-value occurs for two different unordered endpoint-count pairs.

This is only computational evidence. On the central/Christoffel subclass, such a theorem would immediately imply Frobenius uniqueness, so it is necessarily a major target rather than a routine lemma.

The broad palindrome class is still useful because it contains many genuine equal-m collisions within one endpoint-count pair. It therefore supplies a larger laboratory in which equality exists, while the cross-endpoint equality we need to exclude has not appeared.

The current exact question is:

> For palindromic positive Cohn words, does the scalar m-value determine the abelianization (letter counts) up to swapping the two generators?

A proof would be major progress; a counterexample would be equally valuable because it would kill an overstrong route before formalization.


## 19. Endpoint-count scan pushed to inner length 44

A faster exact scanner is now recorded as
`tools/research_markov_palindrome_scan.cpp`.

It exploits symmetry of the Cohn generators. If the inner palindrome has even
length and half-word matrix (H), then its matrix is (H H^T); the analogous
odd-length formula uses the middle generator between a half-word and its
transpose. This reduces each palindrome to half-word work.

The exact exhaustive scan through inner length 44 covers

- **16,777,213** palindromic candidates;
- **8,388,169** distinct candidate (m)-values;
- **zero** (m)-values shared by two different unordered endpoint-count pairs.

This substantially extends the earlier length-42 check. It remains finite
evidence only.

## 20. Same-count collisions: cyclic trace symmetry is real but not the whole story

The first broad collision (M=1130) has an elementary explanation.

Two witnesses are

[
	exttt{aaababaab},qquad 	exttt{aabaaabab}.
]

They are cyclic rotations of one another. Since every word of the form
(a p b) with (p) palindromic satisfies

[
operatorname{tr}(M_w)=3m(w),
]

cyclic conjugacy preserves the trace and therefore preserves the (m)-value.
It also automatically preserves letter counts.

This extends to an infinite visible family. For (kge1), the two words with
inner palindromes

[
a^k b a^{k+2} b a^k
quad	ext{and}quad
a^{k+1} b a^k b a^{k+1}
]

give cyclic rotations after restoring the outer (a,b), explaining the
collisions

[
1130, 19786, 353770, 6344810,ldots
]

inside endpoint pairs ((3,6),(3,9),(3,12),(3,15),ldots).

However cyclic/dihedral symmetry does not explain all collisions. The first
non-dihedral example in the scan occurs at

[
M=57,204,005,
]

with distinct words of ordered counts ((14,7)).

The next tempting explanation was universal free-group trace equivalence.
That also fails eventually: at inner length 26, the scan finds for example

[
M=14,775,266,410
]

with two palindrome words of ordered counts ((15,12)) whose traces differ
under generic (SL_2) generator pairs.

This is another useful falsification: equal Cohn (m)-value does not imply
universal trace-equivalence.

## 21. Equal-trace character slice: a much sharper surviving pattern

Although the inner-length-26 example is not universally trace-equivalent, its
two trace functions agree exactly whenever the two free generators have equal
trace.

For the first pair this was checked symbolically using

[
A=egin{pmatrix}t&-1\\1&0end{pmatrix},qquad
B=egin{pmatrix}0&-lambda\\lambda^{-1}&tend{pmatrix},
]

for which

[
operatorname{tr}A=operatorname{tr}B=t.
]

The difference of the two word traces simplifies identically to zero as a
Laurent polynomial in (t,lambda).

This suggests the following stronger experimental statement.

### Equal-trace-slice conjecture for palindrome candidates

Let (w_1=a p_1 b) and (w_2=a p_2 b), with (p_1,p_2) palindromes. If

[
m(w_1)=m(w_2)
]

for the standard Cohn matrices

[
A=egin{pmatrix}1&1\\1&2end{pmatrix},qquad
B=egin{pmatrix}2&1\\1&1end{pmatrix},
]

then the Fricke trace polynomials agree after restriction to

[
x=operatorname{tr}A=operatorname{tr}B=y.
]

Equivalently, the two words should have the same trace for every (SL_2)
representation with equal generator traces.

This has been stress-tested with several exact symmetric equal-trace
representations through inner length 42:

- **8,388,605** palindrome candidates;
- **4,194,039** distinct Cohn (m)-values;
- no same-(m) fiber split by the equal-trace fingerprints.

The test points include several values of the common generator trace and
several different values of (operatorname{tr}(AB)), so this is much
stronger than merely rechecking the Cohn point. It is still not a proof of
polynomial equality.

### Why this would force endpoint counts

This conjecture has a clean exact consequence.

Suppose the two words contain (p_i) copies of (a) and (q_i) copies of
(b).

On the equal-trace character slice we may specialize to (B=A). Then

[
operatorname{tr}(w_i(A,A))
 = operatorname{tr}(A^{p_i+q_i}).
]

Equality as a trace function therefore forces

[
p_1+q_1=p_2+q_2
]

(for a generic hyperbolic (A)).

We may also specialize to (B=A^{-1}). Since
(operatorname{tr}(A^{-1})=operatorname{tr}(A)),

[
operatorname{tr}(w_i(A,A^{-1}))
 = operatorname{tr}(A^{p_i-q_i}).
]

Thus equality forces

[
|p_1-q_1|=|p_2-q_2|.
]

The sum and absolute difference determine the unordered pair, hence

[
{p_1,q_1}={p_2,q_2}.
]

So the equal-trace-slice conjecture would imply the endpoint-rigidity
phenomenon directly, and therefore imply Frobenius uniqueness on the
central/Christoffel subclass.

This is currently the most precise research target on the branch.

### Relation to the 2021 path work

Lagisquet--Pelantová--Tavenas--Vuillon already show that generalized
Christoffel paths minimize (m) at fixed endpoint and formulate a stronger
global uniqueness conjecture for the generalized minima. Their flip calculus
also exhibits nontrivial equal-(m) word identities.

The present slice conjecture is different and stronger: it concerns arbitrary
palindromic trace-shaped Cohn words, not only endpoint minima. Its advantage is
that the surviving empirical equality has a natural character-variety
interpretation and immediately explains why letter counts should be preserved.

Before any Lean formalization, the next task is to seek an algebraic proof (or
counterexample) of this slice statement.
