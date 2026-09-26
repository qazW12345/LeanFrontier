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
