import LeanFrontier.NumberTheory.MarkovTree.ChildLabels
import Mathlib.Tactic

/-!
# The exceptional equal-sibling case in the oriented Markov tree

The child-label algebra reduces equality of the two immediate child Markov numbers to equality of
the two non-back coordinates of the parent.  This module closes that local degeneracy.

For a positive Markov solution with equal non-back coordinates `a` and largest coordinate `M`,
let `j` be the descending Vieta companion of `M`.  Vieta gives

`M * j = 2 a^2` and `M + j = 3 a^2`.

Since `0 < j < M`, one gets `j^2 < 2a^2`.  Multiplying the sum identity by `j` and using the
product identity gives `a^2 (3j - 2) = j^2`; hence `j` cannot be at least two.  Thus
`j = a = 1` and `M = 2`.

Consequently the two immediate child labels of an oriented node are equal exactly at Markov
number two.  On the canonical Stern-Brocot branch, that happens exactly at the binary root.
-/

namespace LeanFrontier.MarkovTree

private theorem symmetric_descending_solution_eq_one_two
    {a m : ℤ}
    (ha : 0 < a) (hm : 0 < m)
    (hsol : MarkovEquation.IsSolution a a m)
    (hdesc : MarkovEquation.jump a a m < m) :
    a = 1 ∧ m = 2 := by
  let j : ℤ := MarkovEquation.jump a a m

  have hjpos : 0 < j := by
    simpa [j] using MarkovEquation.jump_pos ha hm hsol

  have hjlt : j < m := by
    simpa [j] using hdesc

  have hprod : m * j = 2 * a ^ 2 := by
    have h := MarkovEquation.mul_jump_eq hsol
    change m * j = a ^ 2 + a ^ 2 at h
    nlinarith

  have hsum : m + j = 3 * a ^ 2 := by
    dsimp [j]
    unfold MarkovEquation.jump
    ring

  have hj_sq_lt : j ^ 2 < 2 * a ^ 2 := by
    have hmul : 0 < j * (m - j) :=
      mul_pos hjpos (sub_pos.mpr hjlt)
    nlinarith [hprod]

  have hsum_mul :
      (m + j) * j = (3 * a ^ 2) * j :=
    congrArg (fun t : ℤ => t * j) hsum

  have hrel : a ^ 2 * (3 * j - 2) = j ^ 2 := by
    nlinarith [hprod, hsum_mul]

  have hj : j = 1 := by
    by_contra hjne
    have hjge : 2 ≤ j := by omega
    have hcoeff : 4 ≤ 3 * j - 2 := by omega
    have hmul_le :
        4 * a ^ 2 ≤ (3 * j - 2) * a ^ 2 :=
      mul_le_mul_of_nonneg_right hcoeff (sq_nonneg a)
    have hfour : 4 * a ^ 2 ≤ j ^ 2 := by
      nlinarith [hrel, hmul_le]
    nlinarith

  have ha_sq : a ^ 2 = 1 := by
    rw [hj] at hrel
    norm_num at hrel ⊢
    exact hrel

  have ha1 : a = 1 := by
    nlinarith

  have hm2 : m = 2 := by
    rw [hj, ha1] at hsum
    norm_num at hsum
    omega

  exact ⟨ha1, hm2⟩

/-- Equality of the two non-back coordinates forces Markov number two. -/
theorem markovNumber_eq_two_of_forwardCoordinate_eq
    (n : OrientedNode)
    (hcoord : n.forwardCoordinate false = n.forwardCoordinate true) :
    n.markovNumber = 2 := by
  rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
  rcases hpos with ⟨hx, hy, hz⟩
  cases back with
  | first =>
      simp [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] at hcoord
      have hsym : y = z := hcoord
      subst z
      have hsol' : MarkovEquation.IsSolution y y x := by
        unfold State.IsSolution at hsol
        unfold MarkovEquation.IsSolution at hsol ⊢
        nlinarith
      have hdesc' : MarkovEquation.jump y y x < x := by
        simp only [State.mass, move] at hdesc
        linarith
      have hclass :=
        symmetric_descending_solution_eq_one_two hy hx hsol' hdesc'
      simpa [OrientedNode.markovNumber, State.coordinate] using hclass.2
  | second =>
      simp [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] at hcoord
      have hsym : x = z := hcoord
      subst z
      have hsol' : MarkovEquation.IsSolution x x y := by
        unfold State.IsSolution at hsol
        unfold MarkovEquation.IsSolution at hsol ⊢
        nlinarith
      have hdesc' : MarkovEquation.jump x x y < y := by
        simp only [State.mass, move] at hdesc
        linarith
      have hclass :=
        symmetric_descending_solution_eq_one_two hx hy hsol' hdesc'
      simpa [OrientedNode.markovNumber, State.coordinate] using hclass.2
  | third =>
      simp [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] at hcoord
      have hsym : x = y := hcoord
      subst y
      have hdesc' : MarkovEquation.jump x x z < z := by
        simp only [State.mass, move] at hdesc
        linarith
      have hclass :=
        symmetric_descending_solution_eq_one_two hx hz hsol hdesc'
      simpa [OrientedNode.markovNumber, State.coordinate] using hclass.2

/-- Conversely, Markov number two forces both non-back coordinates to equal one, hence to each
other. -/
theorem forwardCoordinate_eq_of_markovNumber_eq_two
    (n : OrientedNode) (hmarkov : n.markovNumber = 2) :
    n.forwardCoordinate false = n.forwardCoordinate true := by
  have hne (dir : Bool) : forwardMove n.back dir ≠ n.back := by
    cases n.back <;> cases dir <;>
      simp [forwardMove]

  have hlt (dir : Bool) :
      n.forwardCoordinate dir < n.markovNumber := by
    exact coordinate_lt_markovNumber_of_ne_back n (hne dir)

  have hposFalse := forwardCoordinate_pos n false
  have hposTrue := forwardCoordinate_pos n true
  have hltFalse := hlt false
  have hltTrue := hlt true
  rw [hmarkov] at hltFalse hltTrue
  omega

/-- The two non-back parent coordinates are equal exactly at Markov number two. -/
theorem forwardCoordinate_eq_iff_markovNumber_eq_two (n : OrientedNode) :
    n.forwardCoordinate false = n.forwardCoordinate true ↔
      n.markovNumber = 2 := by
  constructor
  · exact markovNumber_eq_two_of_forwardCoordinate_eq n
  · exact forwardCoordinate_eq_of_markovNumber_eq_two n

/-- The two immediate child Markov numbers coincide exactly when the parent Markov number is two. -/
theorem child_markovNumber_eq_iff_markovNumber_eq_two (n : OrientedNode) :
    (child n false).markovNumber = (child n true).markovNumber ↔
      n.markovNumber = 2 := by
  rw [child_markovNumber_eq_iff_forwardCoordinate_eq,
    forwardCoordinate_eq_iff_markovNumber_eq_two]

/-- On the canonical Stern-Brocot branch, Markov number two occurs only at the empty path. -/
theorem sternMarkovNumber_eq_two_iff (path : List Bool) :
    sternMarkovNumber path = 2 ↔ path = [] := by
  constructor
  · intro hmarkov
    have hbound := pathLength_add_two_le_sternMarkovNumber path
    rw [hmarkov] at hbound
    have hlen : path.length = 0 := by omega
    exact List.length_eq_zero_iff.mp hlen
  · intro hpath
    subst path
    norm_num [sternMarkovNumber, sternNode, follow, orientedRoot,
      OrientedNode.markovNumber, State.coordinate]

/-- Therefore equal labels for the two immediate children of a canonical node occur exactly at
the canonical root.  This isolates the only local sibling tie before any deeper subtree analysis. -/
theorem sternNode_child_markovNumber_eq_iff_path_nil (path : List Bool) :
    (child (sternNode path) false).markovNumber =
        (child (sternNode path) true).markovNumber ↔
      path = [] := by
  rw [child_markovNumber_eq_iff_markovNumber_eq_two]
  change sternMarkovNumber path = 2 ↔ path = []
  exact sternMarkovNumber_eq_two_iff path

end LeanFrontier.MarkovTree
