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
