import LeanFrontier.Geometry.GeometricDescartesCompletion
import LeanFrontier.Geometry.OrientedGeometricDescartes
import LeanFrontier.NumberTheory.DescartesCurvatureAction

/-!
# Signed geometric Descartes completions

The positive completion theorem identifies the two possible fourth curvatures of a fixed
externally tangent triple.  This module extends that result to the signed/oriented setting used
by classical Apollonian packings, where one circle may have negative curvature.

If a four-circle oriented Descartes configuration is given and the last circle is replaced by
another nonzero-curvature circle oriented-tangent to the same first three circles, then the new
fourth curvature is either unchanged or is the accepted Descartes Vieta reflection.  At the
bundled level the entire curvature vector is either unchanged or exactly
curvatureReflection 3 of the original vector.
-/

namespace LeanFrontier.CurvatureCenter

private theorem replaceLast_isOrientedDescartesConfiguration
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    IsOrientedDescartesConfiguration (replaceLast c d) := by
  rcases h with ⟨hnz, htan⟩
  constructor
  · intro i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [replaceLast] using hdnz
    · simpa [replaceLast, hi] using hnz i
  · intro i j hij
    by_cases hi : i = (3 : Fin 4)
    · subst i
      have hj : j ≠ (3 : Fin 4) := Ne.symm hij
      have ht := hdtan j hj
      have hsym := (isOrientedTangent_comm (c j) d).mp ht
      simpa [replaceLast, hj] using hsym
    · by_cases hj : j = (3 : Fin 4)
      · subst j
        have ht := hdtan i hi
        simpa [replaceLast, hi] using ht
      · have ht := htan i j hij
        simpa [replaceLast, hi, hj] using ht

/-- A signed nonzero-curvature completion of the same first three oriented-tangent circles has
one of the two Descartes completion curvatures: the original fourth curvature or its Vieta
reflection. -/
theorem orientedCompletion_curvature_eq_or_eq_reflect
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    d.curvature = (c 3).curvature ∨
      d.curvature =
        DescartesCircle.reflect
          (c 0).curvature (c 1).curvature (c 2).curvature (c 3).curvature := by
  have hold :=
    isQuadruple_of_oriented_descartes_configuration c h
  have hreplacement :
      IsOrientedDescartesConfiguration (replaceLast c d) :=
    replaceLast_isOrientedDescartesConfiguration c h d hdnz hdtan
  have hnew :=
    isQuadruple_of_oriented_descartes_configuration (replaceLast c d) hreplacement
  have hroots :=
    DescartesCircle.eq_or_eq_reflect hnew hold
  simpa [replaceLast] using hroots

/-- At the bundled level, signed geometric replacement of the last circle changes the curvature
vector either not at all or by the accepted indexed Vieta reflection at coordinate 3. -/
theorem orientedCompletion_curvatureVector_eq_or_eq_curvatureReflection
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    curvatureVector (replaceLast c d) = curvatureVector c ∨
      curvatureVector (replaceLast c d) =
        DescartesCircle.curvatureReflection (3 : Fin 4) (curvatureVector c) := by
  rcases orientedCompletion_curvature_eq_or_eq_reflect c h d hdnz hdtan with hsame | href
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
