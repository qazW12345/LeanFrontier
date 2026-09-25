import LeanFrontier.NumberTheory.MarkovTree.BranchDivergence
import LeanFrontier.NumberTheory.MarkovTree.MarkovNumber
import LeanFrontier.NumberTheory.MarkovTree.UniquenessConjecture
import Mathlib.Tactic

/-!
# Local subtree reduction for Markov uniqueness

The preceding Markov-tree machinery isolates three structural facts:

* every positive Markov triple is represented on the canonical `sternNode` branch, up to
  coordinate permutation;
* the numerical Markov-number label is the maximum coordinate and strictly increases on each
  forward edge;
* incomparable paths split through opposite children of their deepest common ancestor.

This module combines those facts without attempting to solve the open uniqueness conjecture.

A `CrossBranchCounterexampleAt a` is a pair of descendants of the two opposite immediate
children of `a` which have equal Markov-number labels but whose triples are not permutations.
The main theorem proves that the global Frobenius/Markov uniqueness conjecture is equivalent to
the absence of such a counterexample at every canonical node.

Thus an eventual proof may work locally: at each oriented Markov node, show that the two child
subtrees cannot contain a bad equal-label pair.
-/

namespace LeanFrontier.MarkovTree

/-- On the canonical branch, the oriented Markov-number label is exactly the maximum coordinate
used by the global uniqueness formulation. -/
theorem sternMarkovNumber_eq_maxCoord (path : List Bool) :
    sternMarkovNumber path = (sternNode path).state.maxCoord := by
  simpa [sternMarkovNumber, State.maxCoord] using
    markovNumber_eq_max (sternNode path)

/-- The Markov-number label strictly increases from a proper ancestor to a proper descendant. -/
theorem sternMarkovNumber_lt_of_properSuffix
    {ancestor descendant : List Bool}
    (hsuffix : ancestor <:+ descendant)
    (hne : ancestor ≠ descendant) :
    sternMarkovNumber ancestor < sternMarkovNumber descendant := by
  rcases hsuffix with ⟨pre, hpre⟩
  subst descendant
  cases pre with
  | nil =>
      simp at hne
  | cons dir rest =>
      have hle :
          sternMarkovNumber ancestor ≤
            sternMarkovNumber (rest ++ ancestor) := by
        induction rest with
        | nil =>
            simp
        | cons d ds ih =>
            have hstep := sternMarkovNumber_lt_cons d (ds ++ ancestor)
            exact le_trans ih (le_of_lt hstep)
      have hstep :=
        sternMarkovNumber_lt_cons dir (rest ++ ancestor)
      simpa using lt_of_le_of_lt hle hstep

/-- Distinct canonical paths with the same Markov-number label must be incomparable in the tree
ancestor order. -/
theorem pathsIncomparable_of_eq_sternMarkovNumber_of_ne
    {p q : List Bool}
    (hlabel : sternMarkovNumber p = sternMarkovNumber q)
    (hne : p ≠ q) :
    PathsIncomparable p q := by
  constructor
  · intro hpq
    have hlt := sternMarkovNumber_lt_of_properSuffix hpq hne
    exact (ne_of_lt hlt) hlabel
  · intro hqp
    have hlt := sternMarkovNumber_lt_of_properSuffix hqp hne.symm
    exact (ne_of_lt hlt) hlabel.symm

/-- A bad equal-label pair living in opposite immediate child subtrees of the canonical node
`a`.  The tails `left` and `right` may be empty. -/
def CrossBranchCounterexampleAt (a : List Bool) : Prop :=
  ∃ left right : List Bool,
    sternMarkovNumber (left ++ false :: a) =
        sternMarkovNumber (right ++ true :: a) ∧
      ¬(sternNode (left ++ false :: a)).state.Permutes
        (sternNode (right ++ true :: a)).state

/-- Existence of an arbitrary bad canonical equal-label pair is equivalent to existence of one
localized between the opposite child subtrees of a single deepest common ancestor. -/
theorem exists_crossBranchCounterexample_iff :
    (∃ p q : List Bool,
      sternMarkovNumber p = sternMarkovNumber q ∧
        ¬(sternNode p).state.Permutes (sternNode q).state) ↔
      ∃ a : List Bool, CrossBranchCounterexampleAt a := by
  constructor
  · rintro ⟨p, q, hlabel, hnotperm⟩
    have hne : p ≠ q := by
      intro hpq
      subst q
      apply hnotperm
      rfl
    have hinc :=
      pathsIncomparable_of_eq_sternMarkovNumber_of_ne hlabel hne
    obtain ⟨left, right, hcases⟩ :=
      exists_opposite_child_decomposition_of_incomparable hinc
    refine ⟨commonAncestor p q, ?_⟩
    rcases hcases with hcase | hcase
    · rcases hcase with ⟨hp, hq⟩
      refine ⟨left, right, ?_, ?_⟩
      · exact
          (congrArg sternMarkovNumber hp).symm.trans
            (hlabel.trans (congrArg sternMarkovNumber hq))
      · intro hperm
        apply hnotperm
        change
          (sternNode p).state.coordMultiset =
            (sternNode q).state.coordMultiset
        change
          (sternNode (left ++ false :: commonAncestor p q)).state.coordMultiset =
            (sternNode (right ++ true :: commonAncestor p q)).state.coordMultiset at hperm
        have hpcoords :=
          congrArg (fun path : List Bool => (sternNode path).state.coordMultiset) hp
        have hqcoords :=
          congrArg (fun path : List Bool => (sternNode path).state.coordMultiset) hq
        exact hpcoords.trans (hperm.trans hqcoords.symm)
    · rcases hcase with ⟨hp, hq⟩
      refine ⟨right, left, ?_, ?_⟩
      · exact
          (congrArg sternMarkovNumber hq).symm.trans
            (hlabel.symm.trans (congrArg sternMarkovNumber hp))
      · intro hperm
        apply hnotperm
        change
          (sternNode p).state.coordMultiset =
            (sternNode q).state.coordMultiset
        change
          (sternNode (right ++ false :: commonAncestor p q)).state.coordMultiset =
            (sternNode (left ++ true :: commonAncestor p q)).state.coordMultiset at hperm
        have hpcoords :=
          congrArg (fun path : List Bool => (sternNode path).state.coordMultiset) hp
        have hqcoords :=
          congrArg (fun path : List Bool => (sternNode path).state.coordMultiset) hq
        have hqp :
            (sternNode q).state.coordMultiset =
              (sternNode p).state.coordMultiset :=
          hqcoords.trans (hperm.trans hpcoords.symm)
        exact hqp.symm
  · rintro ⟨a, left, right, hlabel, hnotperm⟩
    exact
      ⟨left ++ false :: a, right ++ true :: a,
        hlabel, hnotperm⟩

/-- **Local-subtree reduction of the Markov uniqueness conjecture.**

The global conjecture holds exactly when no canonical node has a bad equal-label pair split
between its `false` and `true` child subtrees.  This preserves the open boundary: the theorem
only changes the shape of a possible counterexample. -/
theorem uniquenessConjecture_iff_no_crossBranchCounterexample :
    UniquenessConjecture ↔
      ∀ a : List Bool, ¬CrossBranchCounterexampleAt a := by
  constructor
  · intro huniq a hcross
    have hcanonical :=
      (uniquenessConjecture_iff_sternNode).1 huniq
    rcases hcross with ⟨left, right, hlabel, hnotperm⟩
    apply hnotperm
    apply hcanonical
    calc
      (sternNode (left ++ false :: a)).state.maxCoord =
          sternMarkovNumber (left ++ false :: a) :=
        (sternMarkovNumber_eq_maxCoord _).symm
      _ = sternMarkovNumber (right ++ true :: a) := hlabel
      _ = (sternNode (right ++ true :: a)).state.maxCoord :=
        sternMarkovNumber_eq_maxCoord _
  · intro hlocal
    apply (uniquenessConjecture_iff_sternNode).2
    intro p q hmax
    by_contra hnotperm
    have hlabel :
        sternMarkovNumber p = sternMarkovNumber q := by
      calc
        sternMarkovNumber p = (sternNode p).state.maxCoord :=
          sternMarkovNumber_eq_maxCoord p
        _ = (sternNode q).state.maxCoord := hmax
        _ = sternMarkovNumber q :=
          (sternMarkovNumber_eq_maxCoord q).symm
    obtain ⟨a, hcross⟩ :=
      (exists_crossBranchCounterexample_iff).1
        ⟨p, q, hlabel, hnotperm⟩
    exact hlocal a hcross

end LeanFrontier.MarkovTree
