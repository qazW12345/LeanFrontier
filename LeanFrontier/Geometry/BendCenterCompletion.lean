import LeanFrontier.Geometry.BendCenterDescartes
import LeanFrontier.Geometry.GeometricDescartesCompletion
import LeanFrontier.Geometry.OrientedGeometricDescartes
import LeanFrontier.NumberTheory.DescartesCurvatureAction

/-!
# Bend-center replacement in oriented Descartes configurations

The signed curvature completion theorem identifies the two possible fourth curvatures of a fixed
oriented-tangent triple.  The complex Descartes theorem for bend-centers gives the corresponding
two-root statement for the center-weighted coordinates b*z.

Thus, replacing the last circle by another nonzero-curvature circle oriented-tangent to the same
first three circles changes its bend-center either not at all or by the same Vieta reflection
formula.  Bundling all four bend-centers yields the indexed curvatureReflection action over the
complex numbers.
-/

namespace LeanFrontier.CurvatureCenter

private theorem bendReplaceLast_isOrientedDescartesConfiguration
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

/-- The bundled vector of complex bend-centers of a four-circle configuration. -/
noncomputable def bendCenterVector (c : Fin 4 → Circle) :
    DescartesCircle.CurvatureVector ℂ :=
  fun i => bendCenter (c i)

/-- A signed geometric completion of the same first three oriented-tangent circles has one of
the two complex bend-center roots: the old fourth bend-center or its Vieta reflection. -/
theorem orientedCompletion_bendCenter_eq_or_eq_reflect
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    bendCenter d = bendCenter (c 3) ∨
      bendCenter d =
        DescartesCircle.reflect
          (bendCenter (c 0)) (bendCenter (c 1))
          (bendCenter (c 2)) (bendCenter (c 3)) := by
  have hold :=
    bendCenter_isQuadruple_of_oriented_descartes_configuration c h
  have hreplacement :
      IsOrientedDescartesConfiguration (replaceLast c d) :=
    bendReplaceLast_isOrientedDescartesConfiguration c h d hdnz hdtan
  have hnew :=
    bendCenter_isQuadruple_of_oriented_descartes_configuration
      (replaceLast c d) hreplacement
  have hroots :=
    DescartesCircle.eq_or_eq_reflect hnew hold
  simpa [replaceLast] using hroots

/-- At the bundled level, signed geometric replacement of the last circle changes the
bend-center vector either not at all or by the indexed Vieta reflection at coordinate 3. -/
theorem orientedCompletion_bendCenterVector_eq_or_eq_curvatureReflection
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    bendCenterVector (replaceLast c d) = bendCenterVector c ∨
      bendCenterVector (replaceLast c d) =
        DescartesCircle.curvatureReflection (3 : Fin 4) (bendCenterVector c) := by
  rcases orientedCompletion_bendCenter_eq_or_eq_reflect c h d hdnz hdtan with hsame | href
  · left
    funext i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [bendCenterVector, replaceLast] using hsame
    · simp [bendCenterVector, replaceLast, hi]
  · right
    rw [DescartesCircle.curvatureReflection_last_eq]
    funext i
    fin_cases i <;>
      simp [bendCenterVector, replaceLast, href]

end LeanFrontier.CurvatureCenter
