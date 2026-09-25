import LeanFrontier.NumberTheory.MarkovTree.LocalUniquenessReduction
import LeanFrontier.NumberTheory.MarkovTree.ReRootedSubtree
import Mathlib.Tactic

/-!
# Purely local child-subtree formulation of Markov uniqueness

The path-based local reduction already shows that any bad equal-Markov-number pair can be placed
in opposite child subtrees of a canonical node.  The re-rooted subtree API lets us remove the
remaining global path bookkeeping.

A `LocalCrossCounterexample n` is defined directly on an `OrientedNode n`: descend arbitrarily
inside its `false` child subtree and inside its `true` child subtree, and ask for equal
Markov-number labels with non-permutation states.

For canonical nodes this is exactly the previously defined `CrossBranchCounterexampleAt`.
Consequently the global Frobenius/Markov uniqueness conjecture is equivalent to saying that no
canonical oriented node admits such a local counterexample.

This is a structural reformulation only.  It does not establish child-subtree separation.
-/

namespace LeanFrontier.MarkovTree

/-- Every node in either immediate child subtree has Markov number strictly larger than the
parent node's Markov number. -/
theorem markovNumber_lt_childSubtree
    (n : OrientedNode) (dir : Bool) (tail : List Bool) :
    n.markovNumber <
      (descendFrom (child n dir) tail).markovNumber := by
  exact lt_of_lt_of_le
    (markovNumber_lt_child n dir)
    (markovNumber_le_descendFrom (child n dir) tail)

/-- A bad equal-label pair living directly in the two opposite child subtrees of an oriented
Markov node. -/
def LocalCrossCounterexample (n : OrientedNode) : Prop :=
  ∃ left right : List Bool,
    (descendFrom (child n false) left).markovNumber =
        (descendFrom (child n true) right).markovNumber ∧
      ¬(descendFrom (child n false) left).state.Permutes
        (descendFrom (child n true) right).state

/-- The path-based cross-branch counterexample at a canonical path is exactly the purely local
counterexample at the corresponding oriented Markov node. -/
theorem crossBranchCounterexampleAt_iff_local
    (base : List Bool) :
    CrossBranchCounterexampleAt base ↔
      LocalCrossCounterexample (sternNode base) := by
  constructor
  · rintro ⟨left, right, hlabel, hnotperm⟩
    have hleftNode :=
      sternNode_childSubtree_eq_descendFrom base left false
    have hrightNode :=
      sternNode_childSubtree_eq_descendFrom base right true
    have hleftLabel :=
      congrArg OrientedNode.markovNumber hleftNode
    have hrightLabel :=
      congrArg OrientedNode.markovNumber hrightNode
    have hleftState :=
      congrArg OrientedNode.state hleftNode
    have hrightState :=
      congrArg OrientedNode.state hrightNode
    refine ⟨left, right, ?_, ?_⟩
    · change
        (descendFrom (child (sternNode base) false) left).markovNumber =
          (descendFrom (child (sternNode base) true) right).markovNumber
      change
        (sternNode (left ++ false :: base)).markovNumber =
          (sternNode (right ++ true :: base)).markovNumber at hlabel
      exact hleftLabel.symm.trans (hlabel.trans hrightLabel)
    · intro hperm
      apply hnotperm
      change
        (sternNode (left ++ false :: base)).state.coordMultiset =
          (sternNode (right ++ true :: base)).state.coordMultiset
      change
        (descendFrom (child (sternNode base) false) left).state.coordMultiset =
          (descendFrom (child (sternNode base) true) right).state.coordMultiset at hperm
      have hleftCoords := congrArg State.coordMultiset hleftState
      have hrightCoords := congrArg State.coordMultiset hrightState
      exact hleftCoords.trans (hperm.trans hrightCoords.symm)
  · rintro ⟨left, right, hlabel, hnotperm⟩
    have hleftNode :=
      sternNode_childSubtree_eq_descendFrom base left false
    have hrightNode :=
      sternNode_childSubtree_eq_descendFrom base right true
    have hleftLabel :=
      congrArg OrientedNode.markovNumber hleftNode
    have hrightLabel :=
      congrArg OrientedNode.markovNumber hrightNode
    have hleftState :=
      congrArg OrientedNode.state hleftNode
    have hrightState :=
      congrArg OrientedNode.state hrightNode
    refine ⟨left, right, ?_, ?_⟩
    · change
        (sternNode (left ++ false :: base)).markovNumber =
          (sternNode (right ++ true :: base)).markovNumber
      exact hleftLabel.trans (hlabel.trans hrightLabel.symm)
    · intro hperm
      apply hnotperm
      change
        (descendFrom (child (sternNode base) false) left).state.coordMultiset =
          (descendFrom (child (sternNode base) true) right).state.coordMultiset
      change
        (sternNode (left ++ false :: base)).state.coordMultiset =
          (sternNode (right ++ true :: base)).state.coordMultiset at hperm
      have hleftCoords := congrArg State.coordMultiset hleftState
      have hrightCoords := congrArg State.coordMultiset hrightState
      exact hleftCoords.symm.trans (hperm.trans hrightCoords)

/-- The Markov uniqueness conjecture is equivalent to a purely local separation property at
every canonical oriented node.

After this reduction, a proof may work with an arbitrary `sternNode base` and its two
`child` subtrees, without mentioning global common ancestors or path comparability. -/
theorem uniquenessConjecture_iff_no_localCrossCounterexample :
    UniquenessConjecture ↔
      ∀ base : List Bool,
        ¬LocalCrossCounterexample (sternNode base) := by
  rw [uniquenessConjecture_iff_no_crossBranchCounterexample]
  constructor
  · intro h base hlocal
    exact h base ((crossBranchCounterexampleAt_iff_local base).2 hlocal)
  · intro h base hcross
    exact h base ((crossBranchCounterexampleAt_iff_local base).1 hcross)

end LeanFrontier.MarkovTree
