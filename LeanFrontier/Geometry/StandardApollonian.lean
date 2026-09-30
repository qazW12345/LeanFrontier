import LeanFrontier.Geometry.OrientedCurvatureCenter
import LeanFrontier.NumberTheory.DescartesCircle
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# A geometric realization of the standard Apollonian Descartes quadruple

The scalar Descartes module contains the classical curvature quadruple `(-1, 2, 2, 3)`.
Signed curvature-center tangency now lets us realize that quadruple by actual circles.

Take the enclosing unit circle with curvature `-1` and centre `0`.  Inside it place two
radius-`1/2` circles centred at `-1/2` and `1/2` on the real axis, together with the
radius-`1/3` circle centred at height `2/3`.  Every distinct pair is oriented tangent.

This provides a concrete signed geometric base configuration for later Apollonian reflection
and orbit constructions.
-/

namespace LeanFrontier.CurvatureCenter

/-- Four nonzero-curvature circles form an oriented Descartes configuration when every distinct
pair is oriented tangent. -/
def IsOrientedDescartesConfiguration (c : Fin 4 → Circle) : Prop :=
  (∀ i, (c i).curvature ≠ 0) ∧
    ∀ i j, i ≠ j → IsOrientedTangent (c i) (c j)

/-- The enclosing unit circle of the standard Apollonian configuration. -/
def standardOuterCircle : Circle where
  curvature := -1
  center := 0

/-- The left radius-`1/2` circle of the standard Apollonian configuration. -/
def standardLeftCircle : Circle where
  curvature := 2
  center := ((-1 / 2 : ℝ) : ℂ)

/-- The right radius-`1/2` circle of the standard Apollonian configuration. -/
def standardRightCircle : Circle where
  curvature := 2
  center := ((1 / 2 : ℝ) : ℂ)

/-- The upper radius-`1/3` circle of the standard Apollonian configuration. -/
def standardTopCircle : Circle where
  curvature := 3
  center := ⟨0, 2 / 3⟩

/-- The classical geometric `(-1,2,2,3)` Apollonian configuration. -/
def standardApollonianConfiguration : Fin 4 → Circle :=
  ![standardOuterCircle, standardLeftCircle, standardRightCircle, standardTopCircle]

/-- The standard geometric configuration has curvature vector `(-1,2,2,3)`. -/
theorem standardApollonian_curvatures :
    (fun i => (standardApollonianConfiguration i).curvature) =
      ![-1, 2, 2, 3] := by
  funext i
  fin_cases i <;>
    rfl

/-- Every distinct pair of circles in the standard `(-1,2,2,3)` configuration is oriented
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

/-- The curvatures of the standard geometric configuration satisfy the accepted Descartes
relation, agreeing with the scalar `(-1,2,2,3)` example. -/
theorem standardApollonian_isQuadruple :
    DescartesCircle.IsQuadruple
      (standardApollonianConfiguration 0).curvature
      (standardApollonianConfiguration 1).curvature
      (standardApollonianConfiguration 2).curvature
      (standardApollonianConfiguration 3).curvature := by
  simpa [standardApollonianConfiguration, standardOuterCircle, standardLeftCircle,
    standardRightCircle, standardTopCircle] using
    (DescartesCircle.isQuadruple_neg_one_two_two_three (R := ℝ))

end LeanFrontier.CurvatureCenter
