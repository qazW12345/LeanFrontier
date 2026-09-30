import LeanFrontier.Geometry.GeometricDescartes
import LeanFrontier.Geometry.OrientedCurvatureCenter
import LeanFrontier.NumberTheory.DescartesCircle
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.NormNum

/-!
# Signed geometric Descartes theorem

The positive-curvature geometric Descartes theorem uses ordinary external tangency. Apollonian
packings also contain an enclosing circle with negative curvature, so the natural geometric
hypothesis is instead signed/oriented tangency.

This module proves the same Descartes curvature equation for four arbitrary nonzero-curvature
circles that are pairwise oriented-tangent. The proof uses the same augmented curvature-center
Gram calculation as the positive theorem, but obtains every off-diagonal Wilker pairing from
oriented tangency, which is valid for either sign of curvature.
-/

namespace LeanFrontier.CurvatureCenter

open Matrix
open scoped Matrix

private abbrev OIndex := Fin 4
private abbrev OSquareMatrix := Matrix OIndex OIndex ℝ

private noncomputable def orientedWilkerMatrix : OSquareMatrix :=
  ![![0, -(1 : ℝ) / 2, 0, 0],
    ![-(1 : ℝ) / 2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def orientedWilkerMatrixInv : OSquareMatrix :=
  ![![0, -2, 0, 0],
    ![-2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def orientedTangentGram : OSquareMatrix :=
  fun i j => if i = j then 1 else -1

private noncomputable def orientedTangentGramInv : OSquareMatrix :=
  fun i j => if i = j then (1 : ℝ) / 4 else -(1 : ℝ) / 4

private theorem orientedWilkerMatrixInv_mul :
    orientedWilkerMatrixInv * orientedWilkerMatrix = (1 : OSquareMatrix) := by
  ext i j
  change (∑ k : OIndex, orientedWilkerMatrixInv i k * orientedWilkerMatrix k j) =
    (1 : OSquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [orientedWilkerMatrixInv, orientedWilkerMatrix, Fin.sum_univ_four, Matrix.one_apply]

private theorem orientedTangentGram_mul_inv :
    orientedTangentGram * orientedTangentGramInv = (1 : OSquareMatrix) := by
  ext i j
  change (∑ k : OIndex, orientedTangentGram i k * orientedTangentGramInv k j) =
    (1 : OSquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [orientedTangentGram, orientedTangentGramInv, Fin.sum_univ_four, Matrix.one_apply]

private noncomputable def orientedAugmentedMatrix (c : OIndex → Circle) : OSquareMatrix :=
  fun i j => augmentedCoordinates (c i) j

private theorem orientedAugmentedGram_apply (c : OIndex → Circle) (i j : OIndex) :
    (orientedAugmentedMatrix c * orientedWilkerMatrix * (orientedAugmentedMatrix c)ᵀ) i j =
      circlePairing (c i) (c j) := by
  change
    (∑ k : OIndex,
      (∑ l : OIndex, orientedAugmentedMatrix c i l * orientedWilkerMatrix l k) *
        (orientedAugmentedMatrix c)ᵀ k j) =
      circlePairing (c i) (c j)
  simp [orientedAugmentedMatrix, orientedWilkerMatrix, circlePairing, wilkerPairing,
    Matrix.transpose_apply, Fin.sum_univ_four]
  ring

/-- Four nonzero-curvature circles form an oriented Descartes configuration when every
distinct pair is oriented-tangent. -/
def IsOrientedDescartesConfiguration (c : Fin 4 → Circle) : Prop :=
  (∀ i, (c i).curvature ≠ 0) ∧
    ∀ i j, i ≠ j → IsOrientedTangent (c i) (c j)

private theorem orientedAugmentedGram_eq
    (c : OIndex → Circle) (h : IsOrientedDescartesConfiguration c) :
    orientedAugmentedMatrix c * orientedWilkerMatrix * (orientedAugmentedMatrix c)ᵀ =
      orientedTangentGram := by
  rcases h with ⟨hnz, htan⟩
  ext i j
  rw [orientedAugmentedGram_apply]
  by_cases hij : i = j
  · subst j
    rw [circlePairing_self (c i) (hnz i)]
    simp [orientedTangentGram]
  · have hp :=
      (isOrientedTangent_iff_circlePairing_eq_neg_one
        (c i) (c j) (hnz i) (hnz j)).1 (htan i j hij)
    rw [hp]
    simp [orientedTangentGram, hij]

private theorem orientedCurvatureColumn_isQuadruple
    (W : OSquareMatrix)
    (hgram : W * orientedWilkerMatrix * Wᵀ = orientedTangentGram) :
    DescartesCircle.IsQuadruple (W 0 1) (W 1 1) (W 2 1) (W 3 1) := by
  let L : OSquareMatrix := orientedWilkerMatrix * Wᵀ * orientedTangentGramInv
  have hWL : W * L = (1 : OSquareMatrix) := by
    dsimp [L]
    calc
      W * (orientedWilkerMatrix * Wᵀ * orientedTangentGramInv) =
          (W * orientedWilkerMatrix * Wᵀ) * orientedTangentGramInv := by
            simp [Matrix.mul_assoc]
      _ = orientedTangentGram * orientedTangentGramInv := by rw [hgram]
      _ = 1 := orientedTangentGram_mul_inv
  have hLW : L * W = (1 : OSquareMatrix) := (mul_eq_one_comm.mp hWL)
  have hq : Wᵀ * orientedTangentGramInv * W = orientedWilkerMatrixInv := by
    calc
      Wᵀ * orientedTangentGramInv * W =
          (orientedWilkerMatrixInv * orientedWilkerMatrix) *
            Wᵀ * orientedTangentGramInv * W := by
              rw [orientedWilkerMatrixInv_mul]
              simp
      _ = orientedWilkerMatrixInv *
          ((orientedWilkerMatrix * Wᵀ * orientedTangentGramInv) * W) := by
            simp [Matrix.mul_assoc]
      _ = orientedWilkerMatrixInv * 1 := by rw [hLW]
      _ = orientedWilkerMatrixInv := by simp
  have h11 := congrArg (fun M : OSquareMatrix => M (1 : OIndex) (1 : OIndex)) hq
  change
    (∑ k : OIndex,
      (∑ l : OIndex, W l (1 : OIndex) * orientedTangentGramInv l k) *
        W k (1 : OIndex)) =
      orientedWilkerMatrixInv (1 : OIndex) (1 : OIndex) at h11
  simp [orientedTangentGramInv, orientedWilkerMatrixInv, Fin.sum_univ_four] at h11
  unfold DescartesCircle.IsQuadruple
  linear_combination -4 * h11

/-- The signed curvatures of four pairwise oriented-tangent nonzero-curvature circles satisfy
Descartes' circle equation. -/
theorem isQuadruple_of_oriented_descartes_configuration
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c) :
    DescartesCircle.IsQuadruple
      (c 0).curvature (c 1).curvature (c 2).curvature (c 3).curvature := by
  have hgram := orientedAugmentedGram_eq c h
  have hdesc := orientedCurvatureColumn_isQuadruple (orientedAugmentedMatrix c) hgram
  simpa [orientedAugmentedMatrix, augmentedCoordinates] using hdesc

end LeanFrontier.CurvatureCenter
