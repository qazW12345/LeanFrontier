import LeanFrontier.Geometry.FordCircleTangency
import LeanFrontier.NumberTheory.DescartesCircle
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# The Ford–Farey–Descartes configuration

The accepted Ford-circle development characterizes Euclidean tangency by the square of the
Farey cross determinant, while the accepted mediant development shows that replacing either
endpoint of a unimodular pair by its mediant preserves that determinant. The accepted Descartes
module, independently, formalizes the curvature relation for four mutually tangent generalized
circles.

This module composes all three interfaces. For a positive-denominator Farey-neighbour pair, the
two parent Ford circles and their mediant Ford circle are pairwise externally tangent as actual
Mathlib Euclidean spheres. Their reciprocal radii, together with curvature zero for the common
tangent line, satisfy the accepted Descartes relation.
-/

namespace LeanFrontier.FordCircle

/-- A positive-denominator unimodular pair and its mediant form the classical Ford–Farey
Descartes configuration: the three geometric Ford circles are pairwise externally tangent, and
their actual reciprocal radii together with the tangent line's zero curvature satisfy
Descartes' circle relation. -/
theorem farey_mediant_descartes_configuration
    {a b c d : ℤ} (hb : 0 < b) (hd : 0 < d)
    (hdet : Mediant.crossDet a b c d = 1) :
    (euclideanSphere (a : ℝ) (b : ℝ)).IsExtTangent
        (euclideanSphere (c : ℝ) (d : ℝ)) ∧
      (euclideanSphere (a : ℝ) (b : ℝ)).IsExtTangent
        (euclideanSphere ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ)) ∧
      (euclideanSphere ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ)).IsExtTangent
        (euclideanSphere (c : ℝ) (d : ℝ)) ∧
      DescartesCircle.IsQuadruple (0 : ℝ)
        (radius (b : ℝ))⁻¹
        (radius (d : ℝ))⁻¹
        (radius ((b + d : ℤ) : ℝ))⁻¹ := by
  have hb_real : (0 : ℝ) < (b : ℝ) := Int.cast_pos.mpr hb
  have hd_real : (0 : ℝ) < (d : ℝ) := Int.cast_pos.mpr hd
  have hbd : 0 < b + d := add_pos hb hd
  have hbd_real : (0 : ℝ) < ((b + d : ℤ) : ℝ) := Int.cast_pos.mpr hbd
  have hdet_real :
      Mediant.crossDet (a : ℝ) (b : ℝ) (c : ℝ) (d : ℝ) = 1 := by
    have hcast := congrArg (fun z : ℤ => (z : ℝ)) hdet
    simpa [Mediant.crossDet] using hcast
  have hleft_det :
      Mediant.crossDet (a : ℝ) (b : ℝ)
          ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ) = 1 := by
    simpa using
      (Mediant.crossDet_left_mediant (a : ℝ) (b : ℝ) (c : ℝ) (d : ℝ)).trans hdet_real
  have hright_det :
      Mediant.crossDet ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ)
          (c : ℝ) (d : ℝ) = 1 := by
    simpa using
      (Mediant.crossDet_mediant_right (a : ℝ) (b : ℝ) (c : ℝ) (d : ℝ)).trans hdet_real
  have hparent :
      (euclideanSphere (a : ℝ) (b : ℝ)).IsExtTangent
        (euclideanSphere (c : ℝ) (d : ℝ)) := by
    apply (isExtTangent_euclideanSphere_iff (ne_of_gt hb_real) (ne_of_gt hd_real)).2
    rw [hdet_real]
    norm_num
  have hleft :
      (euclideanSphere (a : ℝ) (b : ℝ)).IsExtTangent
        (euclideanSphere ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ)) := by
    apply (isExtTangent_euclideanSphere_iff (ne_of_gt hb_real) (ne_of_gt hbd_real)).2
    rw [hleft_det]
    norm_num
  have hright :
      (euclideanSphere ((a + c : ℤ) : ℝ) ((b + d : ℤ) : ℝ)).IsExtTangent
        (euclideanSphere (c : ℝ) (d : ℝ)) := by
    apply (isExtTangent_euclideanSphere_iff (ne_of_gt hbd_real) (ne_of_gt hd_real)).2
    rw [hright_det]
    norm_num
  have hdescartes :
      DescartesCircle.IsQuadruple (0 : ℝ)
        (radius (b : ℝ))⁻¹
        (radius (d : ℝ))⁻¹
        (radius ((b + d : ℤ) : ℝ))⁻¹ := by
    unfold DescartesCircle.IsQuadruple radius
    simp only [one_div, inv_inv]
    ring
  exact ⟨hparent, hleft, hright, hdescartes⟩

end LeanFrontier.FordCircle
