import LeanFrontier.Geometry.CurvatureCenterHermitian
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Augmented curvature-center coordinates and the Wilker pairing

For a positive-curvature Euclidean circle, the accepted curvature-center representation can be
augmented by its co-curvature to the four real coordinates

`(bar b, b, b x, b y)`.

These are the classical augmented curvature-center coordinates used in matrix formulations of
the Descartes circle theorem. The natural Lorentz/Wilker pairing on these coordinates has norm
one on every nonzero-curvature circle. More importantly, two positive-curvature circles are
externally tangent exactly when their augmented coordinates have pairing `-1`.

This is the matrix-ready geometric interface needed before assembling four mutually tangent
circles and deriving the Descartes quadratic relation.
-/

namespace LeanFrontier.CurvatureCenter

/-- Four real augmented curvature-center coordinates
`(co-curvature, curvature, bend-center real part, bend-center imaginary part)`. -/
abbrev AugmentedCoordinates := Fin 4 → ℝ

/-- The augmented curvature-center coordinates of a circle. -/
noncomputable def augmentedCoordinates (c : Circle) : AugmentedCoordinates :=
  ![coCurvature c, c.curvature, (bendCenter c).re, (bendCenter c).im]

/-- The symmetric Wilker/Lorentz pairing on augmented curvature-center coordinates.

With coordinates `(bar b, b, h, k)`, this is
`h h' + k k' - (bar b * b' + b * bar b') / 2`. -/
def wilkerPairing (u v : AugmentedCoordinates) : ℝ :=
  u 2 * v 2 + u 3 * v 3 - (u 0 * v 1 + u 1 * v 0) / 2

/-- The Wilker pairing of two circles through their augmented coordinates. -/
noncomputable def circlePairing (c d : Circle) : ℝ :=
  wilkerPairing (augmentedCoordinates c) (augmentedCoordinates d)

/-- Every nonzero-curvature circle has Wilker norm one. -/
theorem circlePairing_self (c : Circle) (hcurv : c.curvature ≠ 0) :
    circlePairing c c = 1 := by
  simp [circlePairing, wilkerPairing, augmentedCoordinates, coCurvature, bendCenter,
    Complex.normSq_apply]
  field_simp [hcurv] <;> ring

/-- Twice the Wilker pairing is a centered-distance expression. This identity is the algebraic
bridge from augmented coordinates to Euclidean tangency. -/
theorem two_mul_circlePairing (c d : Circle)
    (hc : c.curvature ≠ 0) (hd : d.curvature ≠ 0) :
    2 * circlePairing c d =
      -c.curvature * d.curvature * Complex.normSq (c.center - d.center) +
        c.curvature * d.curvature⁻¹ + c.curvature⁻¹ * d.curvature := by
  simp [circlePairing, wilkerPairing, augmentedCoordinates, coCurvature, bendCenter,
    Complex.normSq_apply]
  field_simp [hc, hd] <;> ring

/-- For positive-curvature circles, external Euclidean tangency is exactly the Wilker
inner-product condition `-1` on augmented curvature-center coordinates. -/
theorem isExternallyTangent_iff_circlePairing_eq_neg_one
    (c d : Circle) (hc : 0 < c.curvature) (hd : 0 < d.curvature) :
    IsExternallyTangent c d ↔ circlePairing c d = -1 := by
  have hc0 : c.curvature ≠ 0 := hc.ne'
  have hd0 : d.curvature ≠ 0 := hd.ne'
  have htwo := two_mul_circlePairing c d hc0 hd0
  constructor
  · intro htangent
    have hsq :
        Complex.normSq (c.center - d.center) =
          (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 := by
      rw [← Complex.sq_norm, ← Complex.dist_eq]
      exact congrArg (fun x : ℝ => x ^ 2) htangent
    have hrhs :
        -c.curvature * d.curvature *
              (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 +
            c.curvature * d.curvature⁻¹ + c.curvature⁻¹ * d.curvature =
          -2 := by
      field_simp [hc0, hd0] <;> ring
    rw [hsq] at htwo
    nlinarith
  · intro hpair
    have hsq :
        Complex.normSq (c.center - d.center) =
          (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 := by
      rw [hpair] at htwo
      field_simp [hc0, hd0] at htwo ⊢
      nlinarith
    have hdistSq :
        dist c.center d.center ^ 2 =
          (c.curvature⁻¹ + d.curvature⁻¹) ^ 2 := by
      rw [Complex.dist_eq, Complex.sq_norm]
      exact hsq
    have hdistNonneg : 0 ≤ dist c.center d.center := dist_nonneg
    have hsumPos : 0 < c.curvature⁻¹ + d.curvature⁻¹ :=
      add_pos (inv_pos.mpr hc) (inv_pos.mpr hd)
    unfold IsExternallyTangent
    nlinarith

end LeanFrontier.CurvatureCenter
