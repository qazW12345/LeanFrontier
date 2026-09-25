import LeanFrontier.NumberTheory.MarkovTree.ModularRoot
import Mathlib.Data.ZMod.Units
import Mathlib.Tactic

/-!
# Coordinate-defined square roots of minus one for Markov nodes

The existential modular-root theorem says that every oriented Markov-number coordinate admits a
square root of `-1`.  For later comparison arguments it is useful to retain *which* root is
naturally determined by the other two coordinates.

If `M` is the Markov-number coordinate and `u,v` are the two non-back coordinates, then
`u² + v² ≡ 0 (mod M)` and both `u` and `v` are units modulo `M`.  Hence the quotient
`u / v` is a canonical square root of `-1` modulo `|M|`.

Swapping the two complementary coordinates replaces this quotient by its multiplicative inverse.
This records orientation-sensitive arithmetic information that is invisible in the mere
existence of a modular square root.
-/

namespace LeanFrontier.MarkovTree

/-- Either forward coordinate is coprime to the natural modulus `|M|` of the Markov number. -/
theorem forwardCoordinate_isCoprime_markovNumber_natAbs
    (n : OrientedNode) (dir : Bool) :
    IsCoprime (n.forwardCoordinate dir) (n.markovNumber.natAbs : ℤ) := by
  have h := (markovNumber_isCoprime_forwardCoordinate n dir).symm
  have hM : (n.markovNumber.natAbs : ℤ) = n.markovNumber :=
    Int.natAbs_of_nonneg (le_of_lt (markovNumber_pos n))
  rwa [hM]

/-- Modulo the absolute Markov-number label, the squares of the two complementary coordinates
sum to zero. -/
theorem forwardCoordinate_sq_add_sq_eq_zero_mod_markovNumber
    (n : OrientedNode) :
    (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) ^ 2 +
        (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) ^ 2 = 0 := by
  have hdiv := markovNumber_dvd_otherSquareSum n
  rw [otherSquareSum_back_eq_forwardCoordinate_squares n] at hdiv
  have hM : (n.markovNumber.natAbs : ℤ) = n.markovNumber :=
    Int.natAbs_of_nonneg (le_of_lt (markovNumber_pos n))
  have hdiv' :
      (n.markovNumber.natAbs : ℤ) ∣
        n.forwardCoordinate false ^ 2 + n.forwardCoordinate true ^ 2 := by
    rwa [hM]
  have hcast :
      ((n.forwardCoordinate false ^ 2 + n.forwardCoordinate true ^ 2 : ℤ) :
        ZMod n.markovNumber.natAbs) = 0 :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).2 hdiv'
  simpa only [Int.cast_add, Int.cast_pow, Int.cast_ofNat] using hcast

/-- The coordinate-defined square root `u / v` of `-1` modulo the Markov number. -/
def OrientedNode.coordinateRoot (n : OrientedNode) : ZMod n.markovNumber.natAbs :=
  (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
    (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹

/-- The quotient obtained after swapping the two non-back coordinates. -/
def OrientedNode.swappedCoordinateRoot (n : OrientedNode) : ZMod n.markovNumber.natAbs :=
  (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
    (n.forwardCoordinate false : ZMod n.markovNumber.natAbs)⁻¹

/-- The coordinate-defined quotient is a square root of `-1`. -/
theorem coordinateRoot_sq (n : OrientedNode) :
    n.coordinateRoot ^ 2 = -1 := by
  have hv :
      IsCoprime (n.forwardCoordinate true) (n.markovNumber.natAbs : ℤ) :=
    forwardCoordinate_isCoprime_markovNumber_natAbs n true
  have hvinv :
      (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹ = 1 :=
    ZMod.coe_int_mul_inv_eq_one hv
  have hsum := forwardCoordinate_sq_add_sq_eq_zero_mod_markovNumber n
  have huSq :
      (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) ^ 2 =
        -(n.forwardCoordinate true : ZMod n.markovNumber.natAbs) ^ 2 := by
    exact eq_neg_of_add_eq_zero_left hsum
  rw [OrientedNode.coordinateRoot, mul_pow, huSq]
  calc
    -(n.forwardCoordinate true : ZMod n.markovNumber.natAbs) ^ 2 *
          ((n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹) ^ 2 =
        -(((n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹) ^ 2) := by
            ring
    _ = -1 := by rw [hvinv]; simp

/-- Swapping the two complementary coordinates inverts the coordinate-defined root. -/
theorem coordinateRoot_mul_swappedCoordinateRoot (n : OrientedNode) :
    n.coordinateRoot * n.swappedCoordinateRoot = 1 := by
  have hu :
      IsCoprime (n.forwardCoordinate false) (n.markovNumber.natAbs : ℤ) :=
    forwardCoordinate_isCoprime_markovNumber_natAbs n false
  have hv :
      IsCoprime (n.forwardCoordinate true) (n.markovNumber.natAbs : ℤ) :=
    forwardCoordinate_isCoprime_markovNumber_natAbs n true
  have huinv :
      (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate false : ZMod n.markovNumber.natAbs)⁻¹ = 1 :=
    ZMod.coe_int_mul_inv_eq_one hu
  have hvinv :
      (n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹ = 1 :=
    ZMod.coe_int_mul_inv_eq_one hv
  rw [OrientedNode.coordinateRoot, OrientedNode.swappedCoordinateRoot]
  calc
    (n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹ *
        ((n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate false : ZMod n.markovNumber.natAbs)⁻¹) =
        ((n.forwardCoordinate false : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate false : ZMod n.markovNumber.natAbs)⁻¹) *
        ((n.forwardCoordinate true : ZMod n.markovNumber.natAbs) *
          (n.forwardCoordinate true : ZMod n.markovNumber.natAbs)⁻¹) := by
            ring
    _ = 1 := by rw [huinv, hvinv, one_mul]

end LeanFrontier.MarkovTree
