import LeanFrontier.NumberTheory.MarkovTree.ChildLabels
import LeanFrontier.NumberTheory.MarkovTree.Coprime
import Mathlib.Algebra.Group.Int.Units
import Mathlib.Tactic

/-!
# Exceptional equality of sibling Markov-number labels

The child-label factorization shows that two immediate child Markov numbers are
equal exactly when the two non-back parent coordinates are equal.  Pairwise
coprimality now makes that equality rigid.

If the two positive non-back coordinates are equal and coprime, they are both
`1`.  Substituting into the Markov equation and using the oriented-node descent
condition forces the back/maximum coordinate to be `2`.  Conversely, if the
parent Markov number is `2`, positivity and the strict maximality theorem force
both other coordinates to be `1`.

Thus equal sibling labels occur exactly at Markov number `2`.  On the
canonical Stern-Brocot tree, the accepted depth bound then identifies this
exception with the empty path, i.e. the binary root.
-/

namespace LeanFrontier.MarkovTree

private theorem eq_one_of_pos_isUnit {a : ℤ} (ha : 0 < a) (hu : IsUnit a) :
    a = 1 := by
  rcases Int.isUnit_iff.mp hu with h | h
  · exact h
  · linarith

/-- If the two non-back coordinates of an oriented Markov node coincide, then
both are `1`. -/
theorem forwardCoordinates_eq_one_of_eq (n : OrientedNode)
    (h : n.forwardCoordinate false = n.forwardCoordinate true) :
    n.forwardCoordinate false = 1 ∧
      n.forwardCoordinate true = 1 := by
  have hcop := n.pairwiseCoprime
  rcases n with ⟨⟨x, y, z⟩, back, hpositive, hsolution, hdesc⟩
  rcases hpositive with ⟨hx, hy, hz⟩
  change
    IsCoprime x y ∧ IsCoprime x z ∧ IsCoprime y z at hcop
  cases back with
  | first =>
      change y = z at h
      subst z
      have hu : IsUnit y :=
        isCoprime_self.mp hcop.2.2
      have hy1 := eq_one_of_pos_isUnit hy hu
      change y = 1 at hy1
      simp [OrientedNode.forwardCoordinate, State.coordinate, forwardMove, hy1]
  | second =>
      change x = z at h
      subst z
      have hu : IsUnit x :=
        isCoprime_self.mp hcop.2.1
      have hx1 := eq_one_of_pos_isUnit hx hu
      change x = 1 at hx1
      simp [OrientedNode.forwardCoordinate, State.coordinate, forwardMove, hx1]
  | third =>
      change x = y at h
      subst y
      have hu : IsUnit x :=
        isCoprime_self.mp hcop.1
      have hx1 := eq_one_of_pos_isUnit hx hu
      simp [OrientedNode.forwardCoordinate, State.coordinate, forwardMove, hx1]

/-- The two non-back parent coordinates coincide exactly at Markov number `2`. -/
theorem forwardCoordinate_eq_iff_markovNumber_eq_two (n : OrientedNode) :
    n.forwardCoordinate false = n.forwardCoordinate true ↔
      n.markovNumber = 2 := by
  constructor
  · intro h
    have hone := forwardCoordinates_eq_one_of_eq n h
    rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
    cases back with
    | first =>
        change y = 1 ∧ z = 1 at hone
        rcases hone with ⟨rfl, rfl⟩
        change MarkovEquation.IsSolution x 1 1 at hsol
        unfold MarkovEquation.IsSolution at hsol
        simp [State.mass, move, MarkovEquation.jump] at hdesc
        change x = 2
        nlinarith
    | second =>
        change x = 1 ∧ z = 1 at hone
        rcases hone with ⟨rfl, rfl⟩
        change MarkovEquation.IsSolution 1 y 1 at hsol
        unfold MarkovEquation.IsSolution at hsol
        simp [State.mass, move, MarkovEquation.jump] at hdesc
        change y = 2
        nlinarith
    | third =>
        change x = 1 ∧ y = 1 at hone
        rcases hone with ⟨rfl, rfl⟩
        change MarkovEquation.IsSolution 1 1 z at hsol
        unfold MarkovEquation.IsSolution at hsol
        simp [State.mass, move, MarkovEquation.jump] at hdesc
        change z = 2
        nlinarith
  · intro hM
    have hfalsePos := forwardCoordinate_pos n false
    have htruePos := forwardCoordinate_pos n true
    have hfalseLt :
        n.forwardCoordinate false < n.markovNumber := by
      apply coordinate_lt_markovNumber_of_ne_back n
      cases n.back <;> simp [forwardMove]
    have htrueLt :
        n.forwardCoordinate true < n.markovNumber := by
      apply coordinate_lt_markovNumber_of_ne_back n
      cases hback : n.back <;> simp [forwardMove, OrientedNode.forwardCoordinate, hback]
    rw [hM] at hfalseLt htrueLt
    have hf : n.forwardCoordinate false = 1 := by omega
    have ht : n.forwardCoordinate true = 1 := by omega
    exact hf.trans ht.symm

/-- Two immediate children have the same Markov-number label exactly when their
parent has Markov number `2`. -/
theorem child_markovNumber_eq_iff_markovNumber_eq_two (n : OrientedNode) :
    (child n false).markovNumber = (child n true).markovNumber ↔
      n.markovNumber = 2 := by
  rw [child_markovNumber_eq_iff_forwardCoordinate_eq,
    forwardCoordinate_eq_iff_markovNumber_eq_two]

/-- On the canonical Stern-Brocot branch, Markov number `2` occurs only at
the empty path. -/
theorem sternMarkovNumber_eq_two_iff (path : List Bool) :
    sternMarkovNumber path = 2 ↔ path = [] := by
  constructor
  · intro hM
    have hbound := pathLength_add_two_le_sternMarkovNumber path
    rw [hM] at hbound
    have hlen : path.length = 0 := by omega
    exact List.length_eq_zero.mp hlen
  · rintro rfl
    norm_num [sternMarkovNumber, sternNode, follow, orientedRoot,
      OrientedNode.markovNumber, State.coordinate]

/-- Equal immediate sibling labels on the canonical tree occur exactly at the
binary root. -/
theorem sternNode_child_markovNumber_eq_iff (path : List Bool) :
    (child (sternNode path) false).markovNumber =
        (child (sternNode path) true).markovNumber ↔
      path = [] := by
  rw [child_markovNumber_eq_iff_markovNumber_eq_two]
  change sternMarkovNumber path = 2 ↔ path = []
  exact sternMarkovNumber_eq_two_iff path

end LeanFrontier.MarkovTree
