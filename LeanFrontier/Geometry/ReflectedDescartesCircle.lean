import LeanFrontier.Geometry.AugmentedDescartesCompletion
import Mathlib.Tactic

/-!
# The canonical reflected circle of an oriented Descartes triple

The augmented-coordinate completion theorem proves that any second completion of the same
oriented-tangent triple has its entire augmented row on one of two branches.  This module turns
the alternate branch back into an actual circle.

The reflected curvature is coordinate 1 of the reflected augmented row and the reflected
bend-center is formed from coordinates 2 and 3.  Their quotient is the reflected Euclidean
centre.  A replacement circle on the alternate augmented branch has nonzero curvature by
hypothesis, so its defining identity bendCenter = curvature * center lets us recover the centre
uniquely.

Thus any nonzero-curvature circle oriented-tangent to the same first three circles is literally
either the old fourth circle or one canonical reflected circle.  This is circle-level geometric
uniqueness, not merely uniqueness of a curvature root.
-/

namespace LeanFrontier.CurvatureCenter

/-- The curvature of the alternate augmented Descartes row. -/
noncomputable def reflectedLastCurvature (c : Fin 4 → Circle) : ℝ :=
  reflectedLastAugmentedCoordinates c 1

/-- The complex bend-center of the alternate augmented Descartes row. -/
noncomputable def reflectedLastBendCenter (c : Fin 4 → Circle) : ℂ :=
  ⟨reflectedLastAugmentedCoordinates c 2,
    reflectedLastAugmentedCoordinates c 3⟩

/-- The canonical alternate fourth circle determined by the reflected curvature and
bend-center.  When the reflected curvature is nonzero, division recovers its Euclidean centre. -/
noncomputable def reflectedLastCircle (c : Fin 4 → Circle) : Circle where
  curvature := reflectedLastCurvature c
  center := reflectedLastBendCenter c / (reflectedLastCurvature c : ℂ)

private theorem circle_eq_of_augmentedCoordinates_eq
    (c d : Circle) (hc : c.curvature ≠ 0)
    (h : augmentedCoordinates c = augmentedCoordinates d) :
    c = d := by
  have hcurv : c.curvature = d.curvature := by
    have h1 := congrFun h (1 : Fin 4)
    simpa [augmentedCoordinates] using h1
  have hre : (bendCenter c).re = (bendCenter d).re := by
    have h2 := congrFun h (2 : Fin 4)
    simpa [augmentedCoordinates] using h2
  have him : (bendCenter c).im = (bendCenter d).im := by
    have h3 := congrFun h (3 : Fin 4)
    simpa [augmentedCoordinates] using h3
  have hbend : bendCenter c = bendCenter d := by
    exact Complex.ext hre him
  have hcast : (c.curvature : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.mpr hc
  have hcenter : c.center = d.center := by
    apply mul_left_cancel₀ hcast
    simpa [bendCenter, hcurv] using hbend
  apply Circle.ext
  · exact hcurv
  · exact hcenter

/-- Any nonzero signed geometric completion of the same first three circles is either the old
fourth circle or the canonical reflected fourth circle. -/
theorem orientedCompletion_eq_or_eq_reflectedLastCircle
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    d = c 3 ∨ d = reflectedLastCircle c := by
  rcases orientedCompletion_augmentedCoordinates_eq_or_eq_reflected
      c h d hdnz hdtan with hsame | href
  · left
    exact circle_eq_of_augmentedCoordinates_eq d (c 3) hdnz hsame
  · right
    have hcurv :
        d.curvature = reflectedLastCurvature c := by
      have h1 := congrFun href (1 : Fin 4)
      simpa [augmentedCoordinates, reflectedLastCurvature] using h1
    have hre :
        (bendCenter d).re = (reflectedLastBendCenter c).re := by
      have h2 := congrFun href (2 : Fin 4)
      simpa [augmentedCoordinates, reflectedLastBendCenter] using h2
    have him :
        (bendCenter d).im = (reflectedLastBendCenter c).im := by
      have h3 := congrFun href (3 : Fin 4)
      simpa [augmentedCoordinates, reflectedLastBendCenter] using h3
    have hbend : bendCenter d = reflectedLastBendCenter c :=
      Complex.ext hre him
    have hcast : (d.curvature : ℂ) ≠ 0 :=
      Complex.ofReal_ne_zero.mpr hdnz
    have hcenter :
        d.center =
          reflectedLastBendCenter c / (reflectedLastCurvature c : ℂ) := by
      rw [← hcurv, ← hbend]
      simp [bendCenter, hcast]
    apply Circle.ext
    · simpa [reflectedLastCircle] using hcurv
    · simpa [reflectedLastCircle] using hcenter

end LeanFrontier.CurvatureCenter
