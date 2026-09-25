import LeanFrontier.NumberTheory.MarkovTree.BranchStructure
import Mathlib.Tactic

/-!
# First divergence below a common Markov-tree ancestor

The accepted `commonAncestor` API identifies the deepest path shared by two canonical
Stern-Brocot nodes.  This module adds the next structural step needed for later Markov-number
collision arguments: incomparable paths necessarily leave their deepest common ancestor through
different immediate children.

Because LeanFrontier's `sternNode` convention moves away from the root by prepending directions,
a descendant of the child `dir :: a` has the form

`tail ++ dir :: a`.

The main theorem packages the exact equivalence:

two paths are incomparable in the ancestor/suffix order iff they admit decompositions below
`commonAncestor p q` with different first child directions.

This is still purely tree combinatorics.  No Markov-number equality or uniqueness statement is
used.
-/

namespace LeanFrontier.MarkovTree

/-- Two canonical paths are incomparable when neither lies on the ancestor chain of the other. -/
def PathsIncomparable (p q : List Bool) : Prop :=
  ¬ p <:+ q ∧ ¬ q <:+ p

/-- A pair of paths diverges below `a` when they are descendants of different immediate
children of `a`. -/
def DivergesBelow (a p q : List Bool) : Prop :=
  ∃ left right : List Bool, ∃ dp dq : Bool,
    dp ≠ dq ∧
      p = left ++ dp :: a ∧
      q = right ++ dq :: a

private theorem prefix_before_commonAncestor_nonempty_left
    {p q : List Bool} (hpq : ¬ p <:+ q)
    {prefix : List Bool}
    (hprefix : prefix ++ commonAncestor p q = p) :
    prefix ≠ [] := by
  intro hnil
  subst prefix
  have hca : commonAncestor p q = p := by
    simpa using hprefix
  apply hpq
  rw [← hca]
  exact commonAncestor_isSuffix_right p q

private theorem prefix_before_commonAncestor_nonempty_right
    {p q : List Bool} (hqp : ¬ q <:+ p)
    {prefix : List Bool}
    (hprefix : prefix ++ commonAncestor p q = q) :
    prefix ≠ [] := by
  intro hnil
  subst prefix
  have hca : commonAncestor p q = q := by
    simpa using hprefix
  apply hqp
  rw [← hca]
  exact commonAncestor_isSuffix_left p q

/-- Incomparable paths leave their deepest common ancestor through distinct immediate children. -/
theorem divergesBelow_commonAncestor_of_incomparable
    {p q : List Bool} (h : PathsIncomparable p q) :
    DivergesBelow (commonAncestor p q) p q := by
  rcases h with ⟨hpq, hqp⟩
  rcases commonAncestor_isSuffix_left p q with ⟨leftPrefix, hleft⟩
  rcases commonAncestor_isSuffix_right p q with ⟨rightPrefix, hright⟩
  have hleft_ne : leftPrefix ≠ [] :=
    prefix_before_commonAncestor_nonempty_left hpq hleft
  have hright_ne : rightPrefix ≠ [] :=
    prefix_before_commonAncestor_nonempty_right hqp hright

  let dp : Bool := leftPrefix.getLast hleft_ne
  let dq : Bool := rightPrefix.getLast hright_ne
  let left : List Bool := leftPrefix.dropLast
  let right : List Bool := rightPrefix.dropLast

  have hleft_split :
      left ++ dp :: commonAncestor p q = p := by
    calc
      left ++ dp :: commonAncestor p q =
          (leftPrefix.dropLast ++ [leftPrefix.getLast hleft_ne]) ++
            commonAncestor p q := by
              simp [left, dp, List.append_assoc]
      _ = leftPrefix ++ commonAncestor p q := by
            rw [List.dropLast_append_getLast hleft_ne]
      _ = p := hleft

  have hright_split :
      right ++ dq :: commonAncestor p q = q := by
    calc
      right ++ dq :: commonAncestor p q =
          (rightPrefix.dropLast ++ [rightPrefix.getLast hright_ne]) ++
            commonAncestor p q := by
              simp [right, dq, List.append_assoc]
      _ = rightPrefix ++ commonAncestor p q := by
            rw [List.dropLast_append_getLast hright_ne]
      _ = q := hright

  have hdir : dp ≠ dq := by
    intro heq
    subst dq
    have hchild_left : dp :: commonAncestor p q <:+ p := by
      exact ⟨left, hleft_split⟩
    have hchild_right : dp :: commonAncestor p q <:+ q := by
      exact ⟨right, hright_split⟩
    have htoo_long :
        dp :: commonAncestor p q <:+ commonAncestor p q :=
      isSuffix_commonAncestor hchild_left hchild_right
    have hlen := htoo_long.length_le
    simp at hlen

  exact ⟨left, right, dp, dq, hdir, hleft_split.symm, hright_split.symm⟩

/-- A divergence decomposition below the deepest common ancestor forces path incomparability. -/
theorem incomparable_of_divergesBelow_commonAncestor
    {p q : List Bool}
    (h : DivergesBelow (commonAncestor p q) p q) :
    PathsIncomparable p q := by
  rcases h with ⟨left, right, dp, dq, hdir, hp, hq⟩
  constructor
  · intro hpq
    have hca : commonAncestor p q = p :=
      (commonAncestor_eq_left_iff p q).2 hpq
    have hlen := congrArg List.length hp
    simp [hca] at hlen
  · intro hqp
    have hca : commonAncestor p q = q :=
      (commonAncestor_eq_right_iff p q).2 hqp
    have hlen := congrArg List.length hq
    simp [hca] at hlen

/-- Exact first-divergence characterization for canonical Markov/Stern-Brocot paths.

Two paths are incomparable exactly when, below their deepest common ancestor, they enter
different immediate child subtrees. -/
theorem pathsIncomparable_iff_divergesBelow_commonAncestor (p q : List Bool) :
    PathsIncomparable p q ↔
      DivergesBelow (commonAncestor p q) p q := by
  constructor
  · exact divergesBelow_commonAncestor_of_incomparable
  · exact incomparable_of_divergesBelow_commonAncestor

/-- Incomparable paths have a strictly shorter common ancestor than both paths. -/
theorem commonAncestor_length_lt_both_of_incomparable
    {p q : List Bool} (h : PathsIncomparable p q) :
    (commonAncestor p q).length < p.length ∧
      (commonAncestor p q).length < q.length := by
  obtain ⟨left, right, dp, dq, hdir, hp, hq⟩ :=
    divergesBelow_commonAncestor_of_incomparable h
  constructor
  · rw [hp]
    simp
  · rw [hq]
    simp

end LeanFrontier.MarkovTree
