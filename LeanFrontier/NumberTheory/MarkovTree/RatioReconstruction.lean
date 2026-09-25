import LeanFrontier.NumberTheory.MarkovTree.CoordinateRoot
import Mathlib.Tactic

/-!
# Rational reconstruction from Markov coordinate ratios

For an oriented Markov node, the two non-back coordinates form a positive primitive pair.
Comparing two such pairs modulo a common Markov modulus naturally produces their cross
determinant

`u₁ v₂ - u₂ v₁`.

If the two coordinate ratios agree modulo the modulus, that modulus divides the cross
determinant.  Therefore any independent estimate forcing the determinant to have absolute value
strictly smaller than the modulus makes the determinant vanish.  Positivity and primitivity then
force the two coordinate pairs to be equal.

This isolates a concrete quantitative bottleneck for later uniqueness arguments: prove a
small-determinant bound for two putative nodes with the same Markov label and the same modular
coordinate root.
-/

namespace LeanFrontier.MarkovTree

/-- Either non-back coordinate is strictly smaller than the Markov-number coordinate. -/
theorem forwardCoordinate_lt_markovNumber (n : OrientedNode) (dir : Bool) :
    n.forwardCoordinate dir < n.markovNumber := by
  change n.state.coordinate (forwardMove n.back dir) < n.markovNumber
  apply coordinate_lt_markovNumber_of_ne_back n
  cases n.back <;> cases dir <;> simp [forwardMove]

/-- Cross determinant of the two ordered non-back coordinate pairs. -/
def coordinateCrossDet (a b : OrientedNode) : ℤ :=
  a.forwardCoordinate false * b.forwardCoordinate true -
    b.forwardCoordinate false * a.forwardCoordinate true

/-- The ordered coordinate ratios of two nodes agree modulo the first node's Markov number. -/
def CoordinateRatiosCongruent (a b : OrientedNode) : Prop :=
  a.forwardCoordinate false * b.forwardCoordinate true ≡
    b.forwardCoordinate false * a.forwardCoordinate true
      [ZMOD a.markovNumber]

/-- Congruence of the two ordered coordinate ratios is exactly the divisibility input needed for
their cross determinant. -/
theorem markovNumber_dvd_coordinateCrossDet_of_ratioCongruent
    {a b : OrientedNode} (h : CoordinateRatiosCongruent a b) :
    a.markovNumber ∣ a.coordinateCrossDet b := by
  rw [CoordinateRatiosCongruent, Int.modEq_iff_dvd] at h
  have hneg :
      a.markovNumber ∣
        -(b.forwardCoordinate false * a.forwardCoordinate true -
          a.forwardCoordinate false * b.forwardCoordinate true) :=
    dvd_neg.mpr h
  simpa [coordinateCrossDet] using hneg

/-- If a congruent coordinate cross determinant is smaller than the modulus in absolute value,
then it is zero. -/
theorem coordinateCrossDet_eq_zero_of_ratioCongruent_of_small
    {a b : OrientedNode}
    (hratio : CoordinateRatiosCongruent a b)
    (hsmall : (a.coordinateCrossDet b).natAbs < a.markovNumber.natAbs) :
    a.coordinateCrossDet b = 0 := by
  exact Int.eq_zero_of_dvd_of_natAbs_lt_natAbs
    (markovNumber_dvd_coordinateCrossDet_of_ratioCongruent hratio) hsmall

private theorem forwardCoordinate_pair_isCoprime (n : OrientedNode) :
    IsCoprime (n.forwardCoordinate false) (n.forwardCoordinate true) := by
  have hcop := n.pairwiseCoprime
  rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
  change IsCoprime x y ∧ IsCoprime x z ∧ IsCoprime y z at hcop
  cases back with
  | first =>
      simpa [OrientedNode.forwardCoordinate, State.coordinate, forwardMove] using hcop.2.2
  | second =>
      simpa [OrientedNode.forwardCoordinate, State.coordinate, forwardMove] using hcop.2.1
  | third =>
      simpa [OrientedNode.forwardCoordinate, State.coordinate, forwardMove] using hcop.1

private theorem positive_coprime_pair_eq_of_cross_mul_eq
    {u v u' v' : ℤ}
    (hu : 0 < u) (hv : 0 < v) (hu' : 0 < u') (hv' : 0 < v')
    (hcop : IsCoprime u v) (hcop' : IsCoprime u' v')
    (hcross : u * v' = u' * v) :
    u = u' ∧ v = v' := by
  have hu_dvd_u' : u ∣ u' := hcop.dvd_of_dvd_mul_right (by
    rw [← hcross]
    exact dvd_mul_right u v')
  have hu'_dvd_u : u' ∣ u := hcop'.dvd_of_dvd_mul_right (by
    rw [hcross]
    exact dvd_mul_right u' v)
  have huu' : u = u' := le_antisymm
    (Int.le_of_dvd hu' hu_dvd_u')
    (Int.le_of_dvd hu hu'_dvd_u)
  have hvv' : v = v' := by
    rw [huu'] at hcross
    exact (mul_left_cancel₀ hu'.ne' hcross).symm
  exact ⟨huu', hvv'⟩

/-- A small cross determinant upgrades equality of coordinate ratios modulo the Markov number to
equality of the two positive primitive coordinate pairs.

This is the rational-reconstruction step needed by a potential uniqueness proof. -/
theorem forwardCoordinates_eq_of_ratioCongruent_of_crossDet_small
    {a b : OrientedNode}
    (hratio : CoordinateRatiosCongruent a b)
    (hsmall : (a.coordinateCrossDet b).natAbs < a.markovNumber.natAbs) :
    a.forwardCoordinate false = b.forwardCoordinate false ∧
      a.forwardCoordinate true = b.forwardCoordinate true := by
  have hzero :=
    coordinateCrossDet_eq_zero_of_ratioCongruent_of_small hratio hsmall
  have hcross :
      a.forwardCoordinate false * b.forwardCoordinate true =
        b.forwardCoordinate false * a.forwardCoordinate true := by
    exact sub_eq_zero.mp hzero
  exact positive_coprime_pair_eq_of_cross_mul_eq
    (forwardCoordinate_pos a false)
    (forwardCoordinate_pos a true)
    (forwardCoordinate_pos b false)
    (forwardCoordinate_pos b true)
    (forwardCoordinate_pair_isCoprime a)
    (forwardCoordinate_pair_isCoprime b)
    hcross

end LeanFrontier.MarkovTree
