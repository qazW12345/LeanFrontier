import LeanFrontier.Geometry.CurvatureCenter
import LeanFrontier.Geometry.InversiveGeometry
import Mathlib.Analysis.Complex.Norm
import Mathlib.Geometry.Euclidean.Sphere.Power
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
# Curvature-center coordinates as Hermitian generalized circles

Curvature-center coordinates and the generalized-circle Hermitian form are two representations
of the same Euclidean circle. This module makes that identification explicit.

For a circle of nonzero curvature `b` and center `z₀`, define the co-curvature

`b * |z₀|² - b⁻¹`

and Hermitian linear coefficient `-conj (b * z₀)`. Substituting those coefficients into the
accepted inversive-geometry Hermitian form gives exactly `b` times Mathlib's Euclidean sphere
power. Consequently, for positive curvature its zero locus is precisely the corresponding
Euclidean sphere.

This gives an explicit representation bridge to the accepted inversive reflection: away from
the reflection pole, its fixed points are exactly the points of the Euclidean circle. No claim is
made here that this inversive reflection is the same operation as a Descartes curvature
reflection; connecting those operations still requires a geometric Descartes configuration.
-/

open ComplexConjugate

namespace LeanFrontier.CurvatureCenter

/-- The co-curvature coefficient of a curvature-center circle.

For curvature `b` and center `z₀`, this is `b * |z₀|² - b⁻¹`, the constant coefficient
in the normalized Hermitian circle equation. -/
noncomputable def coCurvature (c : Circle) : ℝ :=
  c.curvature * Complex.normSq c.center - c.curvature⁻¹

/-- The complex linear coefficient in the Hermitian form associated to a curvature-center
circle. -/
noncomputable def hermitianB (c : Circle) : ℂ :=
  -conj (bendCenter c)

/-- The accepted generalized-circle Hermitian form specialized to curvature-center
coefficients. -/
noncomputable def inversiveForm (c : Circle) (z : ℂ) : ℂ :=
  InversiveGeometry.hermitianForm c.curvature (coCurvature c) (hermitianB c) z

/-- The accepted inversive reflection specialized to the Hermitian form of a curvature-center
circle. -/
noncomputable def inversiveReflection (c : Circle) (z : ℂ) : ℂ :=
  InversiveGeometry.reflect c.curvature (coCurvature c) (hermitianB c) z

/-- The specialized Hermitian form is the centered circle equation
`b * |z-z₀|² - b⁻¹`, written in complex multiplicative form. -/
theorem inversiveForm_eq_centered (c : Circle) (z : ℂ) :
    inversiveForm c z =
      (c.curvature : ℂ) * (conj (z - c.center) * (z - c.center)) -
        (c.curvature⁻¹ : ℂ) := by
  apply Complex.ext <;>
    simp [inversiveForm, InversiveGeometry.hermitianForm, hermitianB, coCurvature,
      bendCenter, Complex.normSq_apply] <;>
    ring

/-- For nonzero curvature, the curvature-center Hermitian form is exactly curvature times
Mathlib's sphere-power function for the corresponding Euclidean sphere. -/
theorem inversiveForm_eq_curvature_mul_power (c : Circle) (z : ℂ)
    (hcurv : c.curvature ≠ 0) :
    inversiveForm c z =
      ((c.curvature * (toSphere c).power z : ℝ) : ℂ) := by
  rw [inversiveForm_eq_centered, ← Complex.normSq_eq_conj_mul_self]
  have hreal :
      c.curvature * Complex.normSq (z - c.center) - c.curvature⁻¹ =
        c.curvature * (toSphere c).power z := by
    simp [EuclideanGeometry.Sphere.power, toSphere, Complex.dist_eq, Complex.sq_norm]
    field_simp [hcurv]
    ring
  exact_mod_cast hreal

/-- For positive curvature, the Hermitian zero locus is exactly the Euclidean circle represented
by the same curvature-center data. -/
theorem inversiveForm_eq_zero_iff_mem_toSphere (c : Circle) (z : ℂ)
    (hcurv : 0 < c.curvature) :
    inversiveForm c z = 0 ↔ z ∈ toSphere c := by
  rw [inversiveForm_eq_curvature_mul_power c z hcurv.ne']
  have hradius : 0 ≤ (toSphere c).radius := by
    simp [toSphere, hcurv.le]
  rw [← EuclideanGeometry.Sphere.power_eq_zero_iff_mem_sphere hradius]
  simp [hcurv.ne']

/-- Away from its pole, the inversive reflection attached to a positive-curvature
curvature-center circle fixes exactly the points of that Euclidean circle. -/
theorem inversiveReflection_eq_self_iff_mem_toSphere
    (c : Circle) (z : ℂ) (hcurv : 0 < c.curvature)
    (hden : (c.curvature : ℂ) * conj z + hermitianB c ≠ 0) :
    inversiveReflection c z = z ↔ z ∈ toSphere c := by
  unfold inversiveReflection
  rw [InversiveGeometry.reflect_eq_self_iff
    (A := c.curvature) (C := coCurvature c) (B := hermitianB c) z hden]
  simpa [inversiveForm] using inversiveForm_eq_zero_iff_mem_toSphere c z hcurv

end LeanFrontier.CurvatureCenter
