import LeanFrontier.NumberTheory.MarkovTree.MarkovIndex
import Mathlib.Tactic

/-!
# Coordinate congruence for the canonical Markov index

The canonical unsigned Markov index is the centered representative of the coordinate-defined
square root of `-1`.  Classical uniqueness arguments usually introduce the same integer through
a congruence between the two complementary coordinates.

This module exposes that formulation directly: if `M` is the Markov-number coordinate and
`u,v` are the two Boolean-ordered forward coordinates, then the canonical index `j` satisfies

`j * v = u` or `j * v = -u` in `ZMod |M|`.

Thus the index is exactly the classical coordinate ratio, with only the expected sign ambiguity
remaining after passing from the oriented root to its unsigned representative.
-/

namespace LeanFrontier.MarkovTree

private theorem coordinateRoot_mul_forwardCoordinate_true (n : OrientedNode) :
    n.coordinateRoot *
        (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) =
      (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) := by
  have hv :
      IsCoprime (n.forwardCoordinate true) (n.markovNumber.natAbs : ℤ) :=
    forwardCoordinate_isCoprime_markovNumber_natAbs n true
  have hvinv :
      (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹ = 1 :=
    ZMod.coe_int_mul_inv_eq_one hv
  rw [OrientedNode.coordinateRoot]
  calc
    (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹ *
        (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) =
      (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
        ((n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹) := by
            ring
    _ = (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) := by
          rw [hvinv, mul_one]

/-- The canonical Markov index realizes the classical complementary-coordinate congruence,
up to the sign quotient built into the unsigned representative. -/
theorem markovIndex_mul_forwardCoordinate_eq_or_neg (n : OrientedNode) :
    (n.markovIndex : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) =
        (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) ∨
    (n.markovIndex : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) =
        -(n.forwardCoordinate false : ZMod n.markovNumber.natAbs) := by
  have hroot := coordinateRoot_mul_forwardCoordinate_true n
  rcases markovIndex_cast_eq_coordinateRoot_or_neg n with h | h
  · left
    rw [h]
    exact hroot
  · right
    rw [h]
    calc
      -n.coordinateRoot *
            (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) =
          -(n.coordinateRoot *
            (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)) := by
              ring
      _ = -(n.forwardCoordinate false : ZMod n.markovNumber.natAbs) := by
            rw [hroot]

end LeanFrontier.MarkovTree
