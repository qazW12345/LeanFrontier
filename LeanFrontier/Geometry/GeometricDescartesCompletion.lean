import LeanFrontier.Geometry.GeometricDescartes
import LeanFrontier.NumberTheory.DescartesCurvatureAction
import Mathlib.Tactic.FinCases

/-!
# Geometric Descartes completions and curvature reflection

The geometric Descartes theorem shows that four pairwise externally tangent positive-curvature
circles satisfy the accepted Descartes curvature equation.  The scalar Descartes API already
proves that a fixed tangent triple has exactly two possible fourth curvatures, related by the
Vieta reflection.  This module joins those two facts.

Given a positive Descartes configuration, replace its last circle by another positive circle
externally tangent to the same first three circles.  The replacement is again a positive
Descartes configuration, hence its fourth curvature satisfies the same quadratic equation.
Consequently its curvature is either the original fourth curvature or the accepted reflected
curvature.  Bundling the four curvatures then identifies the replacement vector with either the
original curvature vector or `curvatureReflection 3` applied to it.

This is a curvature-level geometric replacement theorem.  It does not yet prove uniqueness of
the replacement circle's centre, nor identify a circle replacement with inversive reflection
as a map on the plane.
-/

namespace LeanFrontier.CurvatureCenter

/-- Replace the last circle of a four-circle configuration. -/
def replaceLast (c : Fin 4 → Circle) (d : Circle) : Fin 4 → Circle :=
  Function.update c (3 : Fin 4) d

/-- The bundled curvature vector of a four-circle configuration. -/
def curvatureVector (c : Fin 4 → Circle) : DescartesCircle.CurvatureVector ℝ :=
  fun i => (c i).curvature

private theorem isExternallyTangent_comm (c d : Circle) :
    IsExternallyTangent c d ↔ IsExternallyTangent d c := by
  simp [IsExternallyTangent, dist_comm, add_comm]

private theorem replaceLast_isPositiveDescartesConfiguration
    (c : Fin 4 → Circle) (h : IsPositiveDescartesConfiguration c)
    (d : Circle) (hdpos : 0 < d.curvature)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsExternallyTangent (c i) d) :
    IsPositiveDescartesConfiguration (replaceLast c d) := by
  rcases h with ⟨hpos, htan⟩
  constructor
  · intro i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [replaceLast] using hdpos
    · simpa [replaceLast, hi] using hpos i
  · intro i j hij
    by_cases hi : i = (3 : Fin 4)
    · subst i
      have hj : j ≠ (3 : Fin 4) := Ne.symm hij
      have ht := hdtan j hj
      have hsym := (isExternallyTangent_comm (c j) d).mp ht
      simpa [replaceLast, hj] using hsym
    · by_cases hj : j = (3 : Fin 4)
      · subst j
        have ht := hdtan i hi
        simpa [replaceLast, hi] using ht
      · have ht := htan i j hij
        simpa [replaceLast, hi, hj] using ht

/-- A positive circle tangent to the same first three circles has one of the two Descartes
completion curvatures: the original fourth curvature or its Vieta reflection. -/
theorem completion_curvature_eq_or_eq_reflect
    (c : Fin 4 → Circle) (h : IsPositiveDescartesConfiguration c)
    (d : Circle) (hdpos : 0 < d.curvature)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsExternallyTangent (c i) d) :
    d.curvature = (c 3).curvature ∨
      d.curvature =
        DescartesCircle.reflect
          (c 0).curvature (c 1).curvature (c 2).curvature (c 3).curvature := by
  have hold :=
    isQuadruple_of_positive_descartes_configuration c h
  have hreplacement :
      IsPositiveDescartesConfiguration (replaceLast c d) :=
    replaceLast_isPositiveDescartesConfiguration c h d hdpos hdtan
  have hnew :=
    isQuadruple_of_positive_descartes_configuration (replaceLast c d) hreplacement
  have hroots :=
    DescartesCircle.eq_or_eq_reflect hnew hold
  simpa [replaceLast] using hroots

/-- At the bundled level, a positive geometric replacement of the last circle changes the
curvature vector either not at all or by the accepted indexed Vieta reflection at coordinate
`3`. -/
theorem completion_curvatureVector_eq_or_eq_curvatureReflection
    (c : Fin 4 → Circle) (h : IsPositiveDescartesConfiguration c)
    (d : Circle) (hdpos : 0 < d.curvature)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsExternallyTangent (c i) d) :
    curvatureVector (replaceLast c d) = curvatureVector c ∨
      curvatureVector (replaceLast c d) =
        DescartesCircle.curvatureReflection (3 : Fin 4) (curvatureVector c) := by
  rcases completion_curvature_eq_or_eq_reflect c h d hdpos hdtan with hsame | href
  · left
    funext i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [curvatureVector, replaceLast] using hsame
    · simp [curvatureVector, replaceLast, hi]
  · right
    rw [DescartesCircle.curvatureReflection_last_eq]
    funext i
    fin_cases i <;>
      simp [curvatureVector, replaceLast, href]

end LeanFrontier.CurvatureCenter
