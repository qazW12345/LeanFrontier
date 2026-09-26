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


## 22. Matrix recognition collapses to an arithmetic descent on modular roots

The Cohn-word recognizer can be eliminated from the inner loop.

For a centered modular root

[
0<ule M/2,qquad u^2equiv -1pmod M,
]

write

[
v=rac{u^2+1}{M}.
]

The associated centered symmetric determinant-one core is

[
P(M,u)=
egin{pmatrix}
M-2u+v & u-v\\
u-v & v
end{pmatrix}.
]

Since (M-2uge0), its first diagonal entry is at least its second.
For any nontrivial palindromic Cohn core this forces the outer Cohn letter to
be (B), because

[
AQA
]

has first diagonal strictly smaller than its second for positive (Q), while

[
BQB
]

has first diagonal strictly larger.

Stripping this forced outer (B) gives

[
Q=B^{-1}P(M,u)B^{-1}
 =
egin{pmatrix}
M-4u+4v & -M+5u-6v\\
-M+5u-6v & M-6u+9v
end{pmatrix}.
]

A direct calculation gives the striking identity

[
(1,1)Q(1,1)^T=v.
]

So the next candidate denominator in the descent is simply

[
M' = v = rac{u^2+1}{M}.
]

The off-diagonal entry is

[
h=-M+5u-6v.
]

For a centered root, the single inequality

[
hge0
]

is enough to put all of (Q) in the nonnegative cone.

Indeed (det Q=1), hence

[
q_{11}q_{22}=h^2+1>0.
]

Thus the diagonal entries have the same sign. If both were negative, writing
(a=-q_{11}>0), (b=-q_{22}>0) gives

[
ab=h^2+1,
]

so

[
a+b>2h
]

and consequently

[
v=q_{11}+2h+q_{22}=2h-a-b<0,
]

contradicting (v>0).

Therefore the first Cohn-membership test is purely arithmetic:
compute (v), then check (-M+5u-6vge0).

The root represented by the parent matrix (Q) is

[
q_{12}+q_{22}=3v-u,
]

which is congruent to (-u) modulo (v). Re-centering therefore gives

[
u'=min(umod v,; -umod v).
]

The parent needs the generator-exchange symmetry exactly when

[
2u<5v.
]

This follows from

[
q_{11}-q_{22}=2u-5v.
]

Hence the entire positive-palindrome recognition problem becomes the finite
recursion

[
(M,u)mapsto
left(
rac{u^2+1}{M},
operatorname{centered}(umod ((u^2+1)/M))
ight),
]

together with the scalar cone test at each step.

The two smallest centered cores are

- ((M,u)=(2,1)): the identity matrix, empty inner palindrome;
- ((M,u)=(5,2)): the single generator (B).

### Examples

For the genuine root of (M=985),

[
(985,408)	o(169,70)	o(29,12)	o(5,2).
]

For the alternative root (u=183),

[
v=34,qquad -985+5(183)-6(34)=-274<0,
]

so it leaves the positive Cohn cone immediately.

For the first broad noncentral collision (M=1130), both centered roots pass:

[
(1130,437)	o(169,70)	o(29,12)	o(5,2),
]

whereas

[
(1130,467)	o(193,81)	o(34,13)	o(5,2).
]

Thus the two accepted roots have genuinely different denominator descents.

Nevertheless, reconstructing the generator-count vector through the orientation
swaps gives the same whole-word endpoint counts ((3,6)) in both cases.

This is exactly the endpoint-rigidity phenomenon from the large palindrome
scan, now expressed without words or matrices.

### Purely arithmetic reformulation of the experimental rigidity statement

Define a centered root ((M,u)) to be *Cohn-admissible* when the above descent
reaches one of the two base cores without violating the cone inequality.

The computational endpoint-rigidity conjecture can then be stated entirely in
integer arithmetic:

> For fixed (M), all Cohn-admissible centered roots of (-1) modulo (M)
> reconstruct the same unordered generator-count pair.

On the central/Christoffel subfamily this would imply Frobenius uniqueness.

This formulation is currently preferable to the trace-slice conjecture as an
attack surface because it exposes an explicit decreasing parameter
(M'=(u^2+1)/M<M), an exact failure inequality, and a finite orientation bit
at every step.

The research script now implements this as the `descent-root` command.


## 23. The Cohn cone test is exactly a quotient-two Euclidean step

The arithmetic descent from Section 22 simplifies further.

Let ((M,u)) be a centered root,

[
0<ule M/2,qquad u^2equiv-1pmod M,
]

and put

[
v=rac{u^2+1}{M},qquad
h=-M+5u-6v.
]

A direct calculation gives the exact identity

[
v h=(u-2v)(3v-u)-1.
]

Because all quantities are integral, for every non-base strip this implies

[
hge0
quadLongleftrightarrowquad
2v<u<3v.
]

Thus the positive-cone test is not a mysterious matrix inequality at all:
it says that the Euclidean quotient of (u) by (v) is exactly (2).

Write

[
u=2v+r,qquad 0<r<v.
]

Since (vmid u^2+1), also (vmid r^2+1).  Define

[
w=rac{r^2+1}{v}.
]

Then the root equation collapses to

[
M=4v+4r+w
]

and the cone defect becomes simply

[
h=r-w.
]

The stripped parent matrix from Section 22 therefore has the normal form

[
Q=
egin{pmatrix}
w & r-w\
r-w & v-2r+w
end{pmatrix}.
]

The next centered root is

[
u'=min(r,v-r),
]

and (u'^2equiv-1pmod v).  Which of (r) and (v-r) is chosen is exactly
the generator-exchange/orientation bit already recorded by the descent.

So Cohn-admissibility can be viewed as a **folded Euclidean algorithm**:

1. form (v=(u^2+1)/M);
2. require the quotient condition (2v<u<3v);
3. take the remainder (r=u-2v);
4. fold it into ((0,v/2]) by (u'=min(r,v-r));
5. repeat with ((v,u')).

The research script now checks these identities exhaustively with
`verify-descent-normal-form`.  A local run through (Mle20{,}000) checked
4,780 centered modular roots, of which 1,607 satisfy a quotient-two strip, with
no failure of the normal-form identities.

### Why this matters

This strips away another representation layer.

The current open-core candidate no longer needs to be phrased as:

> Which modular roots produce positive Cohn matrices?

It can instead be phrased as:

> Which roots of (-1) survive a recursively folded quotient-two Euclidean
> algorithm, and among those, which survive the additional
> Christoffel/central-word constraints?

That is a much smaller arithmetic state space and should interact more
directly with the earlier CRT sign-splitting work.

## 24. Reutenauer's finite Markoff characterization explains why local filters stop short

Christophe Reutenauer's 2021 paper *Christoffel words and weak Markoff theory*
gives a useful conceptual warning for the current attack.

For words in the continuant model, he defines a numerical defect

[

u(w)=operatorname{tr}(P(w))-3,P(w)_{21}.
]

His Theorem 4.2 characterizes Christoffel conjugacy classes by requiring the
appropriate sign condition on (
u) for **every conjugate** of the word
(with a strict parity refinement).

Source:

C. Reutenauer, *Christoffel words and weak Markoff theory*,
Advances in Applied Mathematics 127 (2021), 102179.

This is highly relevant to the experiments above.  The arithmetic
root/Cohn tests are fundamentally local: they recognize whether one
trace-shaped matrix can be represented by a positive palindromic Cohn word.
Reutenauer's theorem says that being genuinely Christoffel is controlled by a
whole cyclic family of inequalities.

That helps explain several empirical facts:

- a simple interval for (u/M) is insufficient;
- single-matrix inequalities are insufficient;
- positive Cohn-monoid membership is insufficient;
- arbitrary palindromes exhibit genuine repeated (m)-values;
- central/Christoffel examples remain much more rigid.

The next serious arithmetic goal should therefore not be another one-step
filter.  It should try to transport Reutenauer-style cyclic inequalities
through the folded Euclidean descent, ideally obtaining a recursively
checkable condition directly on ((M,u)).

If such a condition can be expressed using the denominator/root descent and
the CRT sign partition, it would finally put the word-theoretic
"centrality" requirement and the earlier number-theoretic collision
factorization into the same language.


## 25. All observed palindrome collisions are imprimitive

A new exhaustive diagnostic was added to
`tools/research_markov_palindrome_scan.cpp`.

For a trace-shaped palindrome candidate

[
w=a p b,
]

the scanner now records not only its (m)-value and centered modular root,
but also the endpoint-count pair

[
(#a,#b).
]

The scan was repeated through inner palindrome length (44):

- **16,777,213** palindrome candidates;
- **8,388,169** distinct (m)-values;
- **876 repeated-root collision events**;
- **0 collisions involving a primitive endpoint pair**
  (gcd(#a,#b)=1).

Every repeated (m)-value found in this much larger palindromic class lies
entirely in the imprimitive/generalized sector.

Examples include the previously observed families with count pairs

[
(3,6), (3,9), (6,9), (5,10), (7,14), (12,15),ldots
]

and in every case the common gcd exceeds (1).

This is stronger experimentally than merely observing that colliding
palindromes have the same endpoint counts.  A genuine lower Christoffel word
has coprime endpoint counts, so the following stronger statement would imply
Frobenius uniqueness immediately:

> **Primitive palindrome-collision conjecture.**
> If (p_1,p_2) are palindromes and
> (m(a p_1 b)=m(a p_2 b)), with at least one of the two endpoint-count
> pairs primitive, then the two candidates have the same centered modular
> root (equivalently, no genuine distinct root collision occurs).

No proof is claimed.  The statement is deliberately stronger than Frobenius
because the second palindrome is not assumed central/Christoffel.

### Relation to Fisac's integral-necklace reformulation

David Fisac's 2025 paper *Markov's conjecture on integral necklaces* gives a
different but highly relevant primitive/imprimitive separation.

He parametrizes the simple length spectrum of the modular torus by
**primitive small-variation necklaces** and proves that the classical Markov
uniqueness conjecture is equivalent to injectivity of an explicit function on
that primitive necklace set.  In his parametrization, a small-variation
necklace is primitive exactly when the two multiplicities of its consecutive
entries are coprime.

Source:

D. Fisac, *Markov's conjecture on integral necklaces*,
Bull. London Math. Soc. 57 (2025), 4122--4131.

The present experiment is not the same statement:

- Fisac restricts to the small-variation/Christoffel geometry but keeps all
  primitive necklaces;
- our scan allows arbitrary palindromic Cohn candidates, far outside the
  Christoffel class, and asks whether collisions can touch the primitive
  endpoint sector at all.

The absence of primitive collisions in the larger palindrome class therefore
looks like a potentially useful strengthening rather than merely a numerical
restatement of Fisac's equivalence.

The next question is whether the gcd obstruction can be seen directly from
two distinct symmetric determinant-one matrices

[
P_i=
egin{pmatrix}
x_i&y_i\
y_i&z_i
end{pmatrix}
]

with the same linear value

[
x_i+2y_i+z_i=M
]

and both lying in the positive Cohn palindrome monoid.

A proof that every such distinct pair forces a common divisor in the
reconstructed generator-count vector would rule out primitive collisions and
therefore settle the original conjecture.  Because this is stronger than the
known problem, it should first be attacked algebraically and computationally,
not formalized in Lean.


## 26. Two-root dynamics: CRT splitting becomes descent-modulus separation

Take two distinct centered roots

[
0<u_1<u_2le M/2,qquad u_i^2equiv-1pmod M,
]

and define their first descent moduli

[
v_i=rac{u_i^2+1}{M}.
]

Put

[
d=u_2-u_1,qquad s=u_1+u_2.
]

Subtracting the two root equations gives the exact identity

[
M(v_2-v_1)=u_2^2-u_1^2=ds.
]

Thus, with

[
Delta=v_2-v_1,
]

we have

[
Delta=rac{ds}{M}.
]

This is exactly the arithmetic bridge between the earlier CRT sign split and
the new descent language:

- odd prime-power factors of (M) assigned to the “same root” case divide
  (d);
- those assigned to the “opposite root” case divide (s);
- after dividing by the full modulus, the normalized product is literally the
  separation (Delta) between the two next descent moduli.

For Markov moduli with the known modulo-four restriction, the only extra
bookkeeping is the single factor (2); the odd part still splits cleanly
between (d) and (s).

### Strong bounds when both roots pass the quotient-two strip

If both roots are Cohn-admissible for one step, Section 23 gives

[
rac{M}{3}<u_i<rac{M}{2}.
]

Hence

[
0<d<rac{M}{6},
qquad
rac{2M}{3}<s<M.
]

Substituting into (Delta=ds/M) gives

[
rac{2}{3}d<Delta<d.
]

So distinct admissible roots remain distinct after the first denominator
descent, but their separation contracts by a factor strictly between
(2/3) and (1).

Now write the quotient-two Euclidean remainders

[
r_i=u_i-2v_i.
]

Then

[
r_2-r_1
=(u_2-u_1)-2(v_2-v_1)
=d-2Delta,
]

and therefore

[
-d<r_2-r_1<-rac d3.
]

So before the centering/folding operation, the remainder order **reverses
strictly**:

[
r_1>r_2.
]

This is the first genuinely pairwise dynamical law found in the arithmetic
descent.  It is stronger than running the two root descents independently.

The research script now exposes this calculation with

`compare-roots M u1 u2`.

For the smallest broad palindrome collision,

[
(M,u_1,u_2)=(1130,437,467),
]

one gets

[
d=30,quad s=904,quad
(v_1,v_2)=(169,193),quad
Delta=24.
]

Indeed (24/30=0.8), in the predicted interval, and the raw remainders
reverse from

[
(99,81).
]

### Collision descents can recombine

The larger non-dihedral palindrome collision

[
M=57,204,005
]

has centered roots

[
22,115,492,qquad23,647,712.
]

Their descent chains are initially different, but later recombine at smaller
common moduli.  In particular they pass through the earlier collision
(M=1130), with its two distinct roots, before eventually reaching the same
base root at (M=5).

This shows that the collision structure in the broad palindrome class is
recursive rather than a collection of unrelated accidents.

A promising minimal-counterexample question is therefore:

> Must every distinct-root collision in the positive palindrome cone either
> descend to a smaller distinct-root collision or coalesce in a way that
> forces an imprimitive endpoint-count vector?

The current finite data are consistent with this.  Establishing such a
dichotomy in the primitive sector would be enough to rule out a Frobenius
counterexample.

## 27. Literature sanity check on the primitive/imprimitive boundary

The 2021 work of Lagisquet--Pelantová--Tavenas--Vuillon is important here
because it proves that, for every lattice endpoint ((q,p)), the minimum
(m)-value over all paths to that endpoint is attained by the Christoffel
word, or by a power of a Christoffel word in the imprimitive case.  They then
formulate a stronger generalized uniqueness conjecture for these endpoint
minima.  Their published theorem also proves strict monotonicity in the fixed
numerator, fixed denominator, and fixed sum directions.

So the new finite observation

> no distinct-root palindrome collision touches a coprime endpoint-count pair

is not something already supplied by that theorem.  It is a stronger
palindrome-level statement: arbitrary palindromic Cohn candidates are allowed,
not just endpoint minimizers.

Likewise, Fisac's 2025 integral-necklace reformulation isolates the original
Markov problem on the **primitive small-variation** sector, where primitivity
is equivalent to a coprimality condition on the two multiplicities.

These two external formulations reinforce the same boundary seen in the
experiment:

- imprimitive/generalized objects admit visible repeated-root phenomena;
- the primitive balanced/Christoffel sector is exactly where the classical
  uniqueness problem remains.

This makes the primitive/imprimitive divide a meaningful research target, not
just a numerical curiosity.

The current plan is therefore to keep attacking the pairwise descent law
above and ask whether distinct admissible roots can preserve primitivity all
the way through the folded quotient-two recursion.


## 28. Fake-root survival scan on genuine Markov labels

The arithmetic selector was then tested directly on genuine Markov numbers,
rather than on arbitrary palindromic denominators.

For each distinct positive Markov triple with maximal coordinate

[
Mle 10^{18},
]

the coordinate-defined genuine centered root was compared with every other
centered square root of (-1) modulo (M).  The optional research command

`scan-markov-fakes`

now reproduces this experiment (using SymPy only inside that command to
enumerate modular square roots).

The scan covered:

- **327 distinct Markov triples**;
- **889 non-genuine centered roots**;
- **0 non-genuine roots surviving the complete folded quotient-two descent**.

The failure-depth histogram was:

| successful strips before failure | number of fake roots |
|---:|---:|
| 0 | 623 |
| 1 | 187 |
| 2 | 40 |
| 3 | 23 |
| 4 | 7 |
| 5 | 4 |
| 6 | 4 |
| 9 | 1 |

So the selector is very strong empirically, but not merely a one-step test.

### A simple selector that fails

The tempting hypothesis that the genuine root is always the largest centered
root is false.

The Markov number

[
M=10,946
]

has centered roots

[
4181,qquad 5023,
]

and the genuine coordinate root is the **smaller** one, (4181).

The fake larger root (5023) even passes one quotient-two strip:

[
(10,946,5023)longmapsto(2305,413),
]

and only then fails the next cone test.

So no order statistic on the initial roots can replace the recursive
criterion.

### The longest fake shadow below (10^{18})

The deepest non-genuine survivor occurred for the genuine Markov number

[
M=10,910,721,905.
]

One fake root is

[
u_{mathrm{fake}}=4,218,159,922.
]

It survives nine quotient-two strips before failing:

[
egin{aligned}
10,910,721,905 &	o 1,630,769,557\
&	o 278,688,386\
&	o 48,928,105\
&	o 7,312,898\
&	o 1,249,585\
&	o 219,530\
&	o 32,677\
&	o 5,441\
&	o 1,105,
end{aligned}
]

where the root at (M=1105) is (242), and the next quotient-two condition
fails.

The genuine root

[
u_{mathrm{true}}=4,510,417,602
]

has a different descent but repeatedly meets the fake descent at the same
smaller moduli:

[
48,928,105,qquad219,530,qquad1105.
]

At those common moduli the two chains carry different centered roots.

For example:

| common modulus | fake root | genuine root |
|---:|---:|---:|
| (48,928,105) | (18,915,767) | (20,226,717) |
| (219,530) | (84,697) | (90,927) |
| (1105) | (242) | (463) |

This is strong evidence that a nontrivial CRT sign choice can be transported
through the descent for a long time while repeatedly returning to a common
modulus skeleton.

At the first two common moduli the odd CRT partition has one side containing
the factor (5); at (1105) the complementary global sign convention swaps
the two sides, but the same unordered partition still isolates the factor
(5).  This suggests that the correct invariant may be an **unordered
prime-power sign partition**, transported through common descent moduli, rather
than a signed root itself.

This is now the most promising arithmetic experiment:

> track the unordered CRT sign partition whenever two descent chains meet at
> the same modulus, and determine whether a nontrivial partition must
> eventually force violation of the quotient-two/Christoffel condition.

If such a termination statement can be proved for a chain containing one
genuine Markov root, it would give an induction mechanism for uniqueness.


## 25. The first q-derivative is not extra classical information

A tempting bridge to the injective q-deformed Markov theory was to use the
first derivative at q=1 of a q-Cohn matrix entry.

The 2026 Evans--Jouteur--Morier-Genoud--Ovsienko paper gives, for a
q-deformed Cohn matrix C=(c_ij), the exact identity

m_q = q^2 c_12 + q(1-q)c_22,

where m_q is the normalized q-Markov polynomial attached to the same tree
position.

The q-Markov polynomial is palindromic as a Laurent polynomial, hence

m_q'(1)=0.

Differentiating the displayed identity at q=1 therefore gives

c_12'(1) = c_22(1) - 2 c_12(1).

At q=1 the upper-right Cohn entry is the classical Markov number M.  Thus

c_12'(1)=c_22(1)-2M.

In the Zhang/Cohn convention used on this research branch,
c_22(1)=M+u, so

c_12'(1)=u-M,

and in particular

c_12'(1) == u (mod M).

This proves the experimentally observed derivative/root congruence, but also
shows that the first derivative contains no information beyond the classical
matrix (equivalently beyond M and the oriented modular root u).

So first-order q-deformation is **not** an independent obstruction to a
classical collision.  Any useful q-deformed attack would have to use genuinely
higher-order information.

Source: Evans, Jouteur, Morier-Genoud, Ovsienko, *On q-deformed Markov
numbers. Cohn matrices and perfect matchings with weighted edges* (2026),
Theorem 12, Lemma 13, and palindromicity of q-Markov numbers.

## 26. Exact Pell/CRT residual factor system for a hypothetical collision

Assume an odd common maximum M and two distinct normalized triples, oriented
so that

1 <= A < C < D < B < M,

with

(A,B,M), (C,D,M)

both Markov triples.

The fixed-M conic immediately gives two monotonicities on its reduced branch:

- B>D;
- AB>CD.

Put

K := AB-CD > 0,
Delta := BC-AD > 0,
E := BD-AC > 0.

Srinivasan's identity, with signs oriented positively, is

Delta * E = M^2 * K.

For every prime-power block of M, the two attached square roots of -1 are
either equal or opposite.  Let

M=P Q,  gcd(P,Q)=1,

where Q is the product of the complete prime-power blocks on which the two
roots are equal, and P the product of the blocks on which they are opposite.
Prime separation gives integers r,t>0 with

Delta = Q^2 r,
E     = P^2 t.

Because no prime of P divides Delta and no prime of Q divides E,

gcd(P,r)=1,
gcd(Q,t)=1.

Srinivasan's factorization then cancels the whole M^2 factor and leaves

K = r t.                                                    (26.1)

### Pell determinant factorization

Define

X_1=3AM-2B,
X_2=3CM-2D,
N=9M^2-4.

Then

X_1^2-N A^2=-4M^2,
X_2^2-N C^2=-4M^2.

Moreover

X_2 A-X_1 C = 2 Delta.

The conjugate sum

Sigma_A := 3ACM-(AD+BC)

satisfies

Delta * Sigma_A = M^2(C^2-A^2).

Since Delta=Q^2 r and gcd(P,r)=1, P^2 divides Sigma_A.  Write

Sigma_A=P^2 s.

Then

r s = C^2-A^2.                                             (26.2)

Exactly the same construction after swapping the second triple gives

U := 3ADM-(AC+BD),

E * U = M^2(D^2-A^2).

Since E=P^2 t and gcd(Q,t)=1, write U=Q^2 w.  Then

t w = D^2-A^2.                                             (26.3)

Thus the huge square divisibilities by P^2 and Q^2 leave behind only the
small residual products (26.1)--(26.3).

### Four elementary linear identities

The three positive bilinear differences also satisfy

Delta-K = (C-A)(B+D),
Delta+K = (A+C)(B-D),

E-K = (D-A)(B+C),
E+K = (A+D)(B-C).

Substituting Delta=Q^2 r, E=P^2 t and K=rt gives

r(Q^2-t) = (C-A)(B+D),                                    (26.4)
r(Q^2+t) = (A+C)(B-D),                                    (26.5)

t(P^2-r) = (D-A)(B+C),                                    (26.6)
t(P^2+r) = (A+D)(B-C).                                    (26.7)

In particular,

Q^2>t,
P^2>r.

Also, because gcd(Q,t)=gcd(P,r)=1,

gcd(Q^2-t,Q^2+t) divides 2,
gcd(P^2-r,P^2+r) divides 2.

So every odd common divisor occurring simultaneously in the two coordinate
products on the right sides of (26.4)--(26.5) must be absorbed by r, and the
analogous statement holds for t in (26.6)--(26.7).

### Two useful reconstruction equations

Combining (26.1) and (26.2) with Delta gives the exact linear relations

A Q^2 = C t + D s,                                        (26.8)
C Q^2 = A t + B s.                                        (26.9)

These follow directly, for example, from

A Delta - C K = D(C^2-A^2).

Similarly (26.1) and (26.3) give

A P^2 = D r + C w,                                        (26.10)
D P^2 = A r + B w.                                        (26.11)

This system is a compact arithmetic normal form for any odd hypothetical
collision.  It is stronger bookkeeping than the raw collision factorization:
the CRT blocks P,Q, the residual factors r,s,t,w, and the four lesser
coordinates are tied by simultaneous product, sum/difference, and linear
relations.

### A 3-adic consequence

No Markov coordinate is divisible by 3.  Reducing the three bilinear factors
Delta, E, K modulo 3 shows:

3 | K  iff  3 | Delta  iff  3 | E.

Since 3 does not divide M, (26.1) implies that if 3 divides K then both r and
t are divisible by 3.  Consequently

v_3(K)>0  =>  v_3(K)>=2.

Equivalently, the product difference AB-CD can never have 3-adic valuation
exactly one.

This does not by itself prove uniqueness, but it is a genuine local lifting
constraint on a hypothetical collision and is compatible with the residual
factor system above.

## 27. Fixed-M orbit interpretation

For fixed M, the conic

a^2+b^2+M^2=3Mab

is preserved by

(a,b) -> (b, 3Mb-a).

Modulo M this sends the quotient b/a to

-a/b.

For a Markov solution, (b/a)^2 == -1 (mod M), hence

-a/b == b/a (mod M).

Therefore the oriented modular root is an invariant of the entire fixed-M
integer orbit.

This gives the CRT split a conceptual meaning:

- one modular root = one fixed-M orbit label;
- a classical collision requires two different CRT sign choices whose orbits
  both enter the reduced window 0<a<b<M;
- the prime-power uniqueness theorem is the case in which there is no
  nontrivial CRT sign partition.

The remaining problem is therefore genuinely an orbit-selection problem, not
merely reconstruction of a pair once its modular root is known.


## 28. Universal factor-two gap and the sharpened Vieta contraction

Let

[
1le ale b<c
]

be a positive Markov triple.  Regard (c) as the larger root of

[
f(t)=t^2-3ab,t+(a^2+b^2).
]

At (t=2b),

[
f(2b)=a^2+(5-6a)b^2le0.
]

Hence

[
oxed{cge2b.}
]

Equality occurs at the exceptional root triple ((1,1,2)); beyond it the
inequality is strict.

Now let ((a,b,M)) be an ordered non-root triple and let

[
d=3ab-M
]

be the Vieta predecessor obtained by mutating the largest coordinate.  The
parent triple is ((a,d,b)), so applying the factor-two gap there gives

[
bge2d.
]

Therefore

[
M=3ab-dge(6a-1)d,
]

hence

[
oxed{dlerac{M}{6a-1}.}
]

This strictly sharpens the earlier universal (M/5) bound.  In particular,

- if (a=1), then (dle M/5);
- if (age2), then (dle M/11);
- if (age5), then (dle M/29).

The same estimate also gives

[
blerac{2M}{6a-1}.
]

### Collision-specific CRT consequence

For a hypothetical collision

[
(A,B,M),qquad(C,D,M),
]

normalized so that

[
A<C<D<B<M,
]

write the two nontrivial CRT sign blocks as (M=PQ), and orient the
Srinivasan factors so that

[
BC-AD=Q^2r,qquad BD-AC=P^2t
]

with (r,t>0).

Since both left-hand sides are (<BD),

[
P^2,Q^2<BD
   le rac{4M^2}{(6A-1)(6C-1)}.
]

Using (PQ=M) gives the lower bounds

[
oxed{
P,Q>
rac12sqrt{(6A-1)(6C-1)}.
}
]

Since (Cge A+1), each CRT side is in particular (>3A).

Equivalently any counterexample must satisfy

[
oxed{
M>rac{(6A-1)(6C-1)}4.
}
]

These bounds are collision-specific: they do not hold for an arbitrary
factorization of a Markov number.

## 29. Exact Gaussian short-form characterization of a Markov root

Let

[
pi=x+iyinmathbb Z[i],qquad x^2+y^2=M.
]

For an integer vector (eta=r+is), define

[
Q_pi(r,s)
 =
(1-3xy)r^2
-3(x^2-y^2)rs
+(1+3xy)s^2.
]

The discriminant of this form is

[
9M^2-4.
]

Put

[
a+ib=pieta.
]

Then

[
a=xr-ys,qquad b=xs+yr,
]

and direct expansion gives

[
Q_pi(r,s)
 =
(r^2+s^2)+M-3ab.
]

Consequently the two conditions

[
Q_pi(r,s)=-M,
qquad
r^2+s^2le M/5
]

are equivalent to saying that, after changing the common sign of (a,b) if
necessary,

[
(a,b,M)
]

is a positive Markov triple with (M) its largest coordinate.

Indeed (Q_pi=-M) gives

[
3ab=M+(r^2+s^2),
]

while

[
a^2+b^2=M(r^2+s^2).
]

Thus

[
a^2+b^2+M^2=3Mab.
]

The short-vector bound gives

[
a^2+b^2le M^2/5,
]

so (|a|,|b|<M), while (ab>0).

Conversely every ordered positive Markov triple gives such a vector by
factoring

[
a+ib=pi_Mpi_d
]

with

[
N(pi_M)=M,qquad N(pi_d)=d=3ab-Mle M/5.
]

Using Section 28, the genuine radius can in fact be sharpened to

[
N(pi_d)=dlerac{M}{6a-1}.
]

### Exact reformulation of Frobenius uniqueness

Modulo associates and global conjugation, the different primitive Gaussian
norm-(M) factors are exactly the different CRT square-root choices of
(-1) modulo (M).

Therefore the Frobenius uniqueness conjecture is equivalent to:

> Among the Gaussian norm-(M) factors corresponding to the different
> centered roots of (-1), at most one associated form (Q_pi) represents
> (-M) by an integer vector inside the Markov short-vector disk.

This is not merely an analogy; it is an exact equivalent formulation.

### Lattice Gram interpretation

With

[
p=(x,y),qquad q=(s,r),
]

the same factorization gives

[
|p|^2=M,qquad
|q|^2=d,
]

[
det(p,q)=a,qquad
pcdot q=b.
]

Hence

[
G=
egin{pmatrix}
M&b\
b&d
end{pmatrix}
]

is the Gram matrix of a pair of primitive lattice vectors and

[
det G=a^2,
qquad
operatorname{tr}G=M+d=3ab.
]

Thus (a) is literally the index of the sublattice generated by the two
Gaussian-factor vectors.

## 30. The CRT split is a primitive Pythagorean geometry

Let (p_1,p_2) be primitive Gaussian norm-(M) vectors corresponding to two
distinct centered roots, and set

[
J=det(p_1,p_2),
qquad
H=p_1cdot p_2.
]

Lagrange's identity gives

[
oxed{J^2+H^2=M^2.}
]

Choose representatives of the two roots so that their sign vectors agree on
the complete prime-power block (Q) and differ on the coprime block (P),
with

[
M=PQ.
]

In Gaussian-factor language one may write

[
pi_1=gammadelta,qquad
pi_2=gammaoverline{delta},
]

where

[
N(gamma)=Q,qquad N(delta)=P.
]

Then

[
pi_1overline{pi_2}=Q,delta^2.
]

Therefore both the dot product and determinant are divisible by (Q), and
for a nontrivial split no additional prime-power block of (M) divides both.
Thus

[
gcd(M,J)=gcd(M,H)=Q.
]

Writing

[
J=Qj,qquad H=Qh
]

gives

[
oxed{j^2+h^2=P^2,}
]

with ((j,h)) primitive.

So the angular separation of the two Gaussian root choices is itself encoded
by a primitive Pythagorean triple of hypotenuse (P):

[
sin(	heta_1-	heta_2)=rac{j}{P},
qquad
cos(	heta_1-	heta_2)=rac{h}{P}.
]

Because a nontrivial primitive leg is a nonzero integer and the other leg is
at most (P-1),

[
|j|,|h|gesqrt{2P-1}.
]

Hence

[
oxed{
|sin(	heta_1-	heta_2)|
ge
sqrt{rac{2}{P}-rac1{P^2}}.
}
]

This improves the useless generic (1/M) angular-separation estimate and
shows that a nontrivial CRT sign change produces a quantitatively structured
rotation.

At present this does not by itself contradict the two Markov short-vector
conditions; it is a new exact constraint to combine with the recursive
cofactor geometry.


## 31. Odd-M gcd collapse and the missing packet compatibility

Return to the collision-gap notation

[
r=gx,qquad s=gy,qquad gcd(x,y)=1,
]

and define

[
L=x^2+y^2+3Mxy,qquad T=y^2-x^2,
qquad Q=gcd(L,T).
]

The integer-line parameterization also uses

[
U_0=3Mx+2y,qquad V_0=3My+2x.
]

For odd (M) there is an exact gcd collapse:

[
oxed{gcd(U_0,V_0)=Q.}
]

Proof.  Since (Qmid L,T) and (gcd(Q,x)=gcd(Q,y)=1),

[
L+T=yU_0,qquad L-T=xV_0
]

imply (Qmid U_0,V_0).  Conversely a common divisor of (U_0,V_0)
divides both

[
yU_0-xV_0=2T
]

and

[
yV_0-xU_0=3MT.
]

Because (M) is odd, (gcd(2,3M)=1), so it divides (T), and then also
(L).  Hence equality.

Thus the gcd called (d) in the collision-line parameterization is simply

[
d=gQ.
]

In the surviving unitary split

[
M=DE,qquad L=E^2Q,qquad B=E^2H,
]

the identity (B=jK/d), with (K=g^2L), immediately gives

[
oxed{H=jg.}
]

This is the common scale forgotten when the two defect equations are viewed
as independent Diophantine packets.

### Canonical discriminant divisor from the scale packet

The scale defect equation is

[
n^2+3MHn+H^2=D^4.
]

Set

[
R=3MH+2n-2D^2,qquad Z=9M^2-4.
]

Direct expansion gives

[
R(R+4D^2)=ZH^2.
]

For an actual collision, the original gap construction gives

[
R=g^2Q.
]

Conversely, valuation analysis of the displayed product equation shows that
for an odd packet with (gcd(D,H)=1),

[
Q_{m scale}:=gcd(R,Z)
]

satisfies

[
R=Q_{m scale},g^2
]

for an integer (g), and (gmid H).

### Canonical discriminant divisor from the slope packet

The slope defect equation is

[
m^2+3MWm+W^2=E^4.
]

Put

[
alpha=gcd(m,E^2+W),qquad
x=rac malpha,qquad
y=rac{E^2+W}{alpha}.
]

Then (gcd(x,y)=1), and the packet equation gives the complementary
factorization

[
m=xalpha,qquad E^2+W=yalpha,
]

[
E^2-W=xeta,qquad 3MW+m=yeta
]

for an integer (eta).  In particular

[
Q_{m slope}
  =rac{y^2-x^2}{W}
  =rac{2(E^2+W)+3Mm}{alpha^2}.
]

For an actual collision the two independently reconstructed divisors must
coincide:

[
oxed{Q_{m scale}=Q_{m slope}.}
]

This compatibility is invisible if one merely enumerates the two defect
equations independently.

## 32. Factorization of the common discriminant divisor

For odd (M),

[
Z=9M^2-4=(3M-2)(3M+2),
]

and the two factors on the right are coprime.

Using

[
U_0+V_0=(3M+2)(x+y),
]

[
V_0-U_0=(3M-2)(y-x),
]

together with (gcd(x+y,y-x)mid2), the common gcd (Q) has the exact
factorization

[
oxed{
Q=
gcd(3M-2,x+y),
gcd(3M+2,y-x).
}
]

Define

[
F=gcd(3M-2,x+y),qquad
G=gcd(3M+2,y-x),
]

and complementary factors (A,B) by

[
3M-2=FA,qquad
3M+2=GB.
]

Then

[
Q=FG
]

and, crucially,

[
oxed{GB-FA=4.}
]

Write

[
x+y=Fho,qquad
y-x=Gsigma.
]

Then

[
x=rac{Fho-Gsigma}{2},
qquad
y=rac{Fho+Gsigma}{2},
]

and

[
oxed{W=hosigma.}
]

The transformed slope coefficients are

[
alpha=rac{Bho-Asigma}{2},
qquad
eta=rac{Bho+Asigma}{2},
]

so

[
oxed{
m=rac{(Fho-Gsigma)(Bho-Asigma)}4.
}
]

The identity (E^2=L/Q) becomes the binary quadratic equation

[
oxed{
BFho^2-AGsigma^2=4E^2.
}
]

On the scale side, (R=Qg^2) and (H=gj).  Substituting
(Q=FG) and

[
Z=QAB
]

into

[
Zj^2=Q(Qg^2+4D^2)
]

gives the perfectly symmetric companion equation

[
oxed{
ABj^2-FGg^2=4D^2.
}
]

Moreover

[
oxed{
n=rac{(Aj-Gg)(Bj-Fg)}4.
}
]

Thus the two-block root-switch problem can be written as the integer system

[
GB-FA=4,
]

[
BFho^2-AGsigma^2=4E^2,
]

[
ABj^2-FGg^2=4D^2,
]

[
M=DE,qquad
3M-2=FA,qquad
3M+2=GB,
]

together with

[
oxed{C=WH=hosigma gj<rac{DE}{3}.}
]

This is a much more symmetric normal form than the separated quartic defect
equations.  It makes explicit that both packets are tied to the same
determinant-four factor rectangle ((F,A;G,B)).
