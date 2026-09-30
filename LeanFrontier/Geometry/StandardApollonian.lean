import LeanFrontier.Geometry.OrientedGeometricDescartes
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# A geometric realization of the standard Apollonian Descartes quadruple

The signed geometric Descartes development allows one negative curvature, representing an
enclosing circle.  This module realizes the classical curvature quadruple (-1, 2, 2, 3) by
actual oriented circles.

Take the enclosing unit circle with curvature -1 and centre 0. Inside it place two radius-1/2
circles centred at -1/2 and 1/2 on the real axis, together with the radius-1/3 circle centred at
height 2/3. Every distinct pair is oriented tangent. The signed geometric Descartes theorem
then recovers the curvature equation directly from this geometry.
-/

namespace LeanFrontier.CurvatureCenter

/-- The enclosing unit circle of the standard Apollonian configuration. -/
noncomputable def standardOuterCircle : Circle where
  curvature := -1
  center := 0

/-- The left radius-1/2 circle of the standard Apollonian configuration. -/
noncomputable def standardLeftCircle : Circle where
  curvature := 2
  center := ((-1 / 2 : ℝ) : ℂ)

/-- The right radius-1/2 circle of the standard Apollonian configuration. -/
noncomputable def standardRightCircle : Circle where
  curvature := 2
  center := ((1 / 2 : ℝ) : ℂ)

/-- The upper radius-1/3 circle of the standard Apollonian configuration. -/
noncomputable def standardTopCircle : Circle where
  curvature := 3
  center := ⟨0, 2 / 3⟩

/-- The classical geometric (-1,2,2,3) Apollonian configuration. -/
noncomputable def standardApollonianConfiguration : Fin 4 → Circle :=
  ![standardOuterCircle, standardLeftCircle, standardRightCircle, standardTopCircle]

/-- The standard geometric configuration has curvature vector (-1,2,2,3). -/
theorem standardApollonian_curvatures :
    (fun i => (standardApollonianConfiguration i).curvature) =
      ![-1, 2, 2, 3] := by
  funext i
  fin_cases i <;>
    rfl

/-- Every distinct pair of circles in the standard (-1,2,2,3) configuration is oriented
tangent. -/
theorem standardApollonian_isOrientedDescartesConfiguration :
    IsOrientedDescartesConfiguration standardApollonianConfiguration := by
  constructor
  · intro i
    fin_cases i <;>
      norm_num [standardApollonianConfiguration, standardOuterCircle,
        standardLeftCircle, standardRightCircle, standardTopCircle]
  · intro i j hij
    fin_cases i <;> fin_cases j <;>
      simp [standardApollonianConfiguration, standardOuterCircle, standardLeftCircle,
        standardRightCircle, standardTopCircle, IsOrientedTangent, Complex.dist_eq,
        Complex.sq_norm, Complex.normSq_apply] at hij ⊢ <;>
      norm_num <;>
      ring

/-- The curvatures of the standard geometric configuration satisfy Descartes' relation as a
consequence of signed circle geometry. -/
theorem standardApollonian_isQuadruple :
    DescartesCircle.IsQuadruple
      (standardApollonianConfiguration 0).curvature
      (standardApollonianConfiguration 1).curvature
      (standardApollonianConfiguration 2).curvature
      (standardApollonianConfiguration 3).curvature :=
  isQuadruple_of_oriented_descartes_configuration _
    standardApollonian_isOrientedDescartesConfiguration

end LeanFrontier.CurvatureCenter
