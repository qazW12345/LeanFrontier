import LeanFrontier.Geometry.ReflectedDescartesCircle
import LeanFrontier.NumberTheory.DescartesCurvatureAction
import Mathlib.Tactic

/-!
# The canonical reflected circle realizes the Descartes Vieta action

The augmented-coordinate construction defines a canonical alternate fourth circle by reflecting
the complete curvature-center row.  This module identifies its curvature coordinate with the
already accepted scalar Descartes reflection and then packages the result at the four-curvature
vector level.

Unlike the earlier completion theorem, these are exact identities for the constructed reflected
circle rather than disjunctions about an arbitrary second completion.  They provide the direct
bridge from the geometric replacement object to the accepted indexed Vieta action.
-/

namespace LeanFrontier.CurvatureCenter

/-- The curvature of the canonical reflected fourth circle is exactly the accepted scalar
Descartes reflected root. -/
theorem reflectedLastCurvature_eq_reflect (c : Fin 4 → Circle) :
    reflectedLastCurvature c =
      DescartesCircle.reflect
        (c 0).curvature (c 1).curvature (c 2).curvature (c 3).curvature := by
  simp [reflectedLastCurvature, reflectedLastAugmentedCoordinates,
    augmentedCoordinates, DescartesCircle.reflect]
  ring

/-- The bend-center of the reflected augmented row obeys the same complex Vieta formula. -/
theorem reflectedLastBendCenter_eq_reflect (c : Fin 4 → Circle) :
    reflectedLastBendCenter c =
      DescartesCircle.reflect
        (bendCenter (c 0)) (bendCenter (c 1))
        (bendCenter (c 2)) (bendCenter (c 3)) := by
  apply Complex.ext <;>
    simp [reflectedLastBendCenter, reflectedLastAugmentedCoordinates,
      augmentedCoordinates, DescartesCircle.reflect, bendCenter] <;>
    ring

/-- Replacing the fourth circle by the canonical reflected circle acts on the four curvatures
exactly by the accepted indexed Descartes reflection at coordinate 3. -/
theorem curvatureVector_replaceLast_reflectedLastCircle
    (c : Fin 4 → Circle) :
    curvatureVector (replaceLast c (reflectedLastCircle c)) =
      DescartesCircle.curvatureReflection (3 : Fin 4) (curvatureVector c) := by
  rw [DescartesCircle.curvatureReflection_last_eq]
  funext i
  fin_cases i <;>
    simp [curvatureVector, replaceLast, reflectedLastCircle,
      reflectedLastCurvature_eq_reflect]

end LeanFrontier.CurvatureCenter
