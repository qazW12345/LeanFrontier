import LeanFrontier.NumberTheory.MarkovTree.ReRootedSubtree
import Mathlib.Tactic

/-!
# Quantitative growth in re-rooted Markov subtrees

The re-rooted subtree API proves that the Markov-number label strictly increases
at every forward edge.  Since the labels are integers, each strict increase is
at least one.

This module packages the resulting quantitative bound: descending through a
local tail of length `d` raises the Markov number by at least `d`.  The same
bound is then stated directly for descendants of either immediate child of an
arbitrary canonical Stern-Brocot node.

The bound is deliberately coarse, but it gives a useful finiteness principle:
below any fixed candidate Markov number, only finitely many local subtree
levels can contain a collision.
-/

namespace LeanFrontier.MarkovTree

/-- Re-rooted descent by `d` edges raises the Markov-number label by at least
`d`. -/
theorem markovNumber_add_length_le_descendFrom
    (n : OrientedNode) (tail : List Bool) :
    n.markovNumber + (tail.length : ℤ) ≤
      (descendFrom n tail).markovNumber := by
  induction tail with
  | nil =>
      simp [descendFrom]
  | cons dir tail ih =>
      have hstep := markovNumber_lt_child (descendFrom n tail) dir
      simp only [descendFrom, List.length_cons, Nat.cast_add, Nat.cast_one]
      omega

/-- Quantitative growth inside either immediate child subtree of a canonical
node. -/
theorem child_markovNumber_add_length_le_sternDescendant
    (base tail : List Bool) (dir : Bool) :
    (child (sternNode base) dir).markovNumber + (tail.length : ℤ) ≤
      sternMarkovNumber (tail ++ dir :: base) := by
  have h :=
    markovNumber_add_length_le_descendFrom
      (child (sternNode base) dir) tail
  unfold sternMarkovNumber
  rw [sternNode_childSubtree_eq_descendFrom]
  exact h

/-- Consequently, the local tail depth is bounded by the increase in
Markov-number label above the chosen child subtree root. -/
theorem tailLength_le_sternMarkovNumber_sub_child
    (base tail : List Bool) (dir : Bool) :
    (tail.length : ℤ) ≤
      sternMarkovNumber (tail ++ dir :: base) -
        (child (sternNode base) dir).markovNumber := by
  have h :=
    child_markovNumber_add_length_le_sternDescendant base tail dir
  linarith

end LeanFrontier.MarkovTree
