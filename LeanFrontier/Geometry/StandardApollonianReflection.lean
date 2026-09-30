import LeanFrontier.Geometry.ReflectedDescartesTangency
import LeanFrontier.Geometry.StandardApollonian
import Mathlib.Tactic

/-!
# Reflection of the standard Apollonian configuration

The standard oriented Descartes configuration consists of the unit enclosing circle, two
radius-1/2 circles on the horizontal axis, and a radius-1/3 circle above them.  Reflecting the
fourth circle through the first three should produce the symmetric radius-1/3 circle below the
axis.

This module computes the canonical reflected circle from the general augmented-coordinate
construction and proves exactly that result.  It then obtains the bottom circle's three
tangencies and the reflected four-circle Descartes configuration from the general reflection
theorems.
-/

namespace LeanFrontier.CurvatureCenter

/-- The lower radius-1/3 circle completing the first three circles of the standard configuration. -/
noncomputable def standardBottomCircle : Circle where
  curvature := 3
  center := ⟨0, -2 / 3⟩

/-- In the standard configuration, the alternate fourth curvature is again 3. -/
theorem standard_reflectedLastCurvature :
    reflectedLastCurvature standardApollonianConfiguration = 3 := by
  norm_num [reflectedLastCurvature, reflectedLastAugmentedCoordinates,
    standardApollonianConfiguration, standardOuterCircle,
    standardLeftCircle, standardRightCircle, standardTopCircle,
    augmentedCoordinates]

/-- In the standard configuration, the reflected bend-center is -2i. -/
theorem standard_reflectedLastBendCenter :
    reflectedLastBendCenter standardApollonianConfiguration = ⟨0, -2⟩ := by
  apply Complex.ext <;>
    norm_num [reflectedLastBendCenter, reflectedLastAugmentedCoordinates,
      standardApollonianConfiguration, standardOuterCircle,
      standardLeftCircle, standardRightCircle, standardTopCircle,
      augmentedCoordinates, bendCenter]

/-- The canonical reflected fourth circle of the standard configuration is exactly the lower
radius-1/3 circle centered at height -2/3. -/
theorem standard_reflectedLastCircle :
    reflectedLastCircle standardApollonianConfiguration = standardBottomCircle := by
  apply Circle.ext
  · simpa [reflectedLastCircle, standardBottomCircle] using standard_reflectedLastCurvature
  · rw [show (reflectedLastCircle standardApollonianConfiguration).center =
        reflectedLastBendCenter standardApollonianConfiguration /
          (reflectedLastCurvature standardApollonianConfiguration : ℂ) by rfl]
    rw [standard_reflectedLastBendCenter, standard_reflectedLastCurvature]
    apply Complex.ext <;>
      norm_num [standardBottomCircle]

/-- The lower standard circle is oriented-tangent to each of the first three circles. -/
theorem standardBottomCircle_isOrientedTangent
    (i : Fin 4) (hi : i ≠ (3 : Fin 4)) :
    IsOrientedTangent (standardApollonianConfiguration i) standardBottomCircle := by
  have href : reflectedLastCurvature standardApollonianConfiguration ≠ 0 := by
    rw [standard_reflectedLastCurvature]
    norm_num
  have ht :=
    reflectedLastCircle_isOrientedTangent
      standardApollonianConfiguration
      standardApollonian_isOrientedDescartesConfiguration
      href i hi
  rwa [standard_reflectedLastCircle] at ht

/-- Replacing the upper radius-1/3 circle by the lower one gives the second standard oriented
Descartes configuration. -/
theorem standardBottom_replacement_isOrientedDescartesConfiguration :
    IsOrientedDescartesConfiguration
      (replaceLast standardApollonianConfiguration standardBottomCircle) := by
  have href : reflectedLastCurvature standardApollonianConfiguration ≠ 0 := by
    rw [standard_reflectedLastCurvature]
    norm_num
  have h :=
    replaceLast_reflectedLastCircle_isOrientedDescartesConfiguration
      standardApollonianConfiguration
      standardApollonian_isOrientedDescartesConfiguration href
  rwa [standard_reflectedLastCircle] at h

end LeanFrontier.CurvatureCenter
