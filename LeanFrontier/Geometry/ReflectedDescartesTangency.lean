import LeanFrontier.Geometry.ReflectedDescartesCircle
import Mathlib.Tactic

/-!
# The reflected Descartes circle is the alternate geometric completion

The canonical reflected circle is defined from the alternate augmented curvature-center row.
This module proves that the construction actually realizes that row and is oriented-tangent to
the same first three circles whenever its reflected curvature is nonzero.

The key observation is that the reflected row r' = 2(r0+r1+r2)-r3 has Wilker norm one and
Wilker pairing -1 with each of r0,r1,r2.  The circle constructed from its curvature and
bend-center automatically has matching coordinates 1,2,3; its own Wilker norm one then forces
coordinate 0 to agree as well.  The signed tangency criterion converts the remaining pairings
back into geometric oriented tangency.
-/

namespace LeanFrontier.CurvatureCenter

private theorem configuration_wilkerPairing
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (i j : Fin 4) :
    wilkerPairing (augmentedCoordinates (c i)) (augmentedCoordinates (c j)) =
      if i = j then 1 else -1 := by
  rcases h with ⟨hnz, htan⟩
  by_cases hij : i = j
  · subst j
    simp only [if_pos rfl]
    simpa [circlePairing] using circlePairing_self (c i) (hnz i)
  · rw [if_neg hij]
    have hp :=
      (isOrientedTangent_iff_circlePairing_eq_neg_one
        (c i) (c j) (hnz i) (hnz j)).1 (htan i j hij)
    simpa [circlePairing] using hp

private theorem reflectedLastAugmentedCoordinates_self_pairing
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c) :
    wilkerPairing (reflectedLastAugmentedCoordinates c)
      (reflectedLastAugmentedCoordinates c) = 1 := by
  let u0 := augmentedCoordinates (c 0)
  let u1 := augmentedCoordinates (c 1)
  let u2 := augmentedCoordinates (c 2)
  let u3 := augmentedCoordinates (c 3)
  have hformula :
      wilkerPairing (reflectedLastAugmentedCoordinates c)
          (reflectedLastAugmentedCoordinates c) =
        4 * (wilkerPairing u0 u0 + wilkerPairing u1 u1 + wilkerPairing u2 u2 +
          2 * wilkerPairing u0 u1 + 2 * wilkerPairing u0 u2 +
          2 * wilkerPairing u1 u2) -
        4 * (wilkerPairing u0 u3 + wilkerPairing u1 u3 +
          wilkerPairing u2 u3) +
        wilkerPairing u3 u3 := by
    simp [u0, u1, u2, u3, reflectedLastAugmentedCoordinates, wilkerPairing]
    ring
  rw [hformula]
  have h00 := configuration_wilkerPairing c h 0 0
  have h11 := configuration_wilkerPairing c h 1 1
  have h22 := configuration_wilkerPairing c h 2 2
  have h33 := configuration_wilkerPairing c h 3 3
  have h01 := configuration_wilkerPairing c h 0 1
  have h02 := configuration_wilkerPairing c h 0 2
  have h12 := configuration_wilkerPairing c h 1 2
  have h03 := configuration_wilkerPairing c h 0 3
  have h13 := configuration_wilkerPairing c h 1 3
  have h23 := configuration_wilkerPairing c h 2 3
  simp [u0, u1, u2, u3] at h00 h11 h22 h33 h01 h02 h12 h03 h13 h23
  norm_num at h00 h11 h22 h33 h01 h02 h12 h03 h13 h23
  nlinarith

private theorem first_pairing_reflectedLastAugmentedCoordinates
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (i : Fin 4) (hi : i ≠ (3 : Fin 4)) :
    wilkerPairing (augmentedCoordinates (c i))
      (reflectedLastAugmentedCoordinates c) = -1 := by
  have hformula :
      wilkerPairing (augmentedCoordinates (c i))
          (reflectedLastAugmentedCoordinates c) =
        2 * (wilkerPairing (augmentedCoordinates (c i)) (augmentedCoordinates (c 0)) +
          wilkerPairing (augmentedCoordinates (c i)) (augmentedCoordinates (c 1)) +
          wilkerPairing (augmentedCoordinates (c i)) (augmentedCoordinates (c 2))) -
        wilkerPairing (augmentedCoordinates (c i)) (augmentedCoordinates (c 3)) := by
    simp [reflectedLastAugmentedCoordinates, wilkerPairing]
    ring
  rw [hformula]
  fin_cases i
  · have h00 := configuration_wilkerPairing c h 0 0
    have h01 := configuration_wilkerPairing c h 0 1
    have h02 := configuration_wilkerPairing c h 0 2
    have h03 := configuration_wilkerPairing c h 0 3
    norm_num at h00 h01 h02 h03 ⊢
    nlinarith
  · have h10 := configuration_wilkerPairing c h 1 0
    have h11 := configuration_wilkerPairing c h 1 1
    have h12 := configuration_wilkerPairing c h 1 2
    have h13 := configuration_wilkerPairing c h 1 3
    norm_num at h10 h11 h12 h13 ⊢
    nlinarith
  · have h20 := configuration_wilkerPairing c h 2 0
    have h21 := configuration_wilkerPairing c h 2 1
    have h22 := configuration_wilkerPairing c h 2 2
    have h23 := configuration_wilkerPairing c h 2 3
    norm_num at h20 h21 h22 h23 ⊢
    nlinarith
  · exact (hi rfl).elim

/-- If the reflected curvature is nonzero, the canonical reflected circle realizes the full
reflected augmented curvature-center row. -/
theorem augmentedCoordinates_reflectedLastCircle
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (href : reflectedLastCurvature c ≠ 0) :
    augmentedCoordinates (reflectedLastCircle c) =
      reflectedLastAugmentedCoordinates c := by
  let r := reflectedLastAugmentedCoordinates c
  let d := reflectedLastCircle c
  have hcast : (reflectedLastCurvature c : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.mpr href
  have hbend : bendCenter d = reflectedLastBendCenter c := by
    change
      (reflectedLastCurvature c : ℂ) *
          (reflectedLastBendCenter c / (reflectedLastCurvature c : ℂ)) =
        reflectedLastBendCenter c
    rw [mul_comm, div_mul_cancel₀ _ hcast]
  have h1 : augmentedCoordinates d 1 = r 1 := by
    simp [d, r, augmentedCoordinates, reflectedLastCircle, reflectedLastCurvature]
  have h2 : augmentedCoordinates d 2 = r 2 := by
    simpa [d, r, augmentedCoordinates, reflectedLastBendCenter] using congrArg Complex.re hbend
  have h3 : augmentedCoordinates d 3 = r 3 := by
    simpa [d, r, augmentedCoordinates, reflectedLastBendCenter] using congrArg Complex.im hbend
  have hdself :
      wilkerPairing (augmentedCoordinates d) (augmentedCoordinates d) = 1 := by
    simpa [circlePairing] using circlePairing_self d (by
      simpa [d, reflectedLastCircle] using href)
  have hrself : wilkerPairing r r = 1 := by
    simpa [r] using reflectedLastAugmentedCoordinates_self_pairing c h
  have hprod :
      (augmentedCoordinates d 0 - r 0) * r 1 = 0 := by
    simp [wilkerPairing, h1, h2, h3] at hdself
    simp [wilkerPairing] at hrself
    nlinarith
  have hr1 : r 1 ≠ 0 := by
    simpa [r, reflectedLastCurvature] using href
  have h0 : augmentedCoordinates d 0 = r 0 := by
    rcases mul_eq_zero.mp hprod with hz | hz
    · exact sub_eq_zero.mp hz
    · exact (hr1 hz).elim
  funext j
  fin_cases j
  · exact h0
  · exact h1
  · exact h2
  · exact h3

/-- If its curvature is nonzero, the canonical reflected circle is oriented-tangent to each of
the first three circles of the original configuration. -/
theorem reflectedLastCircle_isOrientedTangent
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (href : reflectedLastCurvature c ≠ 0)
    (i : Fin 4) (hi : i ≠ (3 : Fin 4)) :
    IsOrientedTangent (c i) (reflectedLastCircle c) := by
  rcases h with ⟨hnz, htan⟩
  rw [isOrientedTangent_iff_circlePairing_eq_neg_one
    (c i) (reflectedLastCircle c) (hnz i) (by
      simpa [reflectedLastCircle] using href)]
  rw [circlePairing, augmentedCoordinates_reflectedLastCircle c ⟨hnz, htan⟩ href]
  exact first_pairing_reflectedLastAugmentedCoordinates c ⟨hnz, htan⟩ i hi

/-- Replacing the fourth circle by the canonical reflected circle produces another oriented
Descartes configuration whenever the reflected curvature is nonzero. -/
theorem replaceLast_reflectedLastCircle_isOrientedDescartesConfiguration
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (href : reflectedLastCurvature c ≠ 0) :
    IsOrientedDescartesConfiguration (replaceLast c (reflectedLastCircle c)) := by
  rcases h with ⟨hnz, htan⟩
  constructor
  · intro i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [replaceLast, reflectedLastCircle] using href
    · simpa [replaceLast, hi] using hnz i
  · intro i j hij
    by_cases hi : i = (3 : Fin 4)
    · subst i
      have hj : j ≠ (3 : Fin 4) := Ne.symm hij
      have ht := reflectedLastCircle_isOrientedTangent c ⟨hnz, htan⟩ href j hj
      have hsym := (isOrientedTangent_comm (c j) (reflectedLastCircle c)).mp ht
      simpa [replaceLast, hj] using hsym
    · by_cases hj : j = (3 : Fin 4)
      · subst j
        have ht := reflectedLastCircle_isOrientedTangent c ⟨hnz, htan⟩ href i hi
        simpa [replaceLast, hi] using ht
      · simpa [replaceLast, hi, hj] using htan i j hij

end LeanFrontier.CurvatureCenter
