import LeanFrontier.Geometry.CurvatureCenterWilker
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Nlinarith
import Mathlib.Tactic.Ring

/-!
# Signed tangency for oriented curvature-center circles

The positive-curvature bridge uses ordinary external tangency, where both reciprocal curvatures
are positive radii.  Apollonian configurations also use an enclosing circle with negative
curvature, so ordinary external tangency is not the right invariant there.

For nonzero signed curvatures, oriented tangency is expressed by the squared signed-radius
equation

`dist(center₁, center₂)² = (b₁⁻¹ + b₂⁻¹)²`.

Squaring is essential: if one curvature is negative, the signed radius sum may be negative even
though Euclidean distance is nonnegative.  This equation is exactly the Wilker pairing condition
`-1`.  When both curvatures are positive, it is equivalent to the existing ordinary external
tangency predicate.
-/

namespace LeanFrontier.CurvatureCenter

/-- Signed/oriented tangency for nonzero-curvature circles, written as the squared signed-radius
equation.  The definition itself is total; nonzero-curvature hypotheses are required by the
coordinate identities that interpret reciprocal curvature as signed radius. -/
def IsOrientedTangent (c d : Circle) : Prop :=
  dist c.center d.center ^ 2 =
    (c.curvature⁻¹ + d.curvature⁻¹) ^ 2

/-- Positive-curvature oriented tangency is exactly ordinary external tangency. -/
theorem isExternallyTangent_iff_isOrientedTangent
    (c d : Circle) (hc : 0 < c.curvature) (hd : 0 < d.curvature) :
    IsExternallyTangent c d ↔ IsOrientedTangent c d := by
  unfold IsExternallyTangent IsOrientedTangent
  constructor
  · intro h
    rw [h]
  · intro h
    have hdist : 0 ≤ dist c.center d.center := dist_nonneg
    have hsum : 0 < c.curvature⁻¹ + d.curvature⁻¹ :=
      add_pos (inv_pos.mpr hc) (inv_pos.mpr hd)
    nlinarith

/-- For arbitrary nonzero signed curvatures, oriented tangency is exactly the Wilker pairing
condition `-1`. -/
theorem isOrientedTangent_iff_circlePairing_eq_neg_one
    (c d : Circle) (hc : c.curvature ≠ 0) (hd : d.curvature ≠ 0) :
    IsOrientedTangent c d ↔ circlePairing c d = -1 := by
  have htwo := two_mul_circlePairing c d hc hd
  constructor
  · intro htangent
    have hnorm :
        Complex.normSq (c.center - d.center) =
          (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 := by
      simpa [IsOrientedTangent, Complex.dist_eq, Complex.sq_norm] using htangent
    rw [hnorm] at htwo
    have hrhs :
        -c.curvature * d.curvature *
              (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 +
            c.curvature * d.curvature⁻¹ + c.curvature⁻¹ * d.curvature =
          -2 := by
      field_simp [hc, hd]
      ring
    nlinarith
  · intro hpair
    rw [hpair] at htwo
    unfold IsOrientedTangent
    rw [Complex.dist_eq, Complex.sq_norm]
    field_simp [hc, hd] at htwo ⊢
    nlinarith

/-- Oriented tangency is symmetric. -/
theorem isOrientedTangent_comm (c d : Circle) :
    IsOrientedTangent c d ↔ IsOrientedTangent d c := by
  simp [IsOrientedTangent, dist_comm, add_comm]

end LeanFrontier.CurvatureCenter
