import LeanFrontier.Geometry.OrientedGeometricDescartes
import LeanFrontier.NumberTheory.DescartesCircle
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases
import Mathlib.Tactic
import Mathlib.Tactic.NormNum

/-!
# The complex Descartes theorem for bend-centers

For an oriented circle with curvature b and centre z, the bend-center is b z.  In a signed
Descartes configuration the four bend-centers satisfy the same Descartes quadratic relation,
now over the complex numbers.

The proof uses the augmented curvature-center Gram identity.  The real and imaginary
bend-center columns have equal Lorentz norm, and their mutual Lorentz pairing is zero.  Those
three real identities combine into the complex Descartes equation.

This is the center-level companion to the signed curvature theorem and is the algebraic input
needed to identify the second geometric completion circle, not merely its curvature.
-/

namespace LeanFrontier.CurvatureCenter

open Matrix
open scoped Matrix

private abbrev BIndex := Fin 4
private abbrev BSquareMatrix := Matrix BIndex BIndex ℝ

private noncomputable def bendWilkerMatrix : BSquareMatrix :=
  ![![0, -(1 : ℝ) / 2, 0, 0],
    ![-(1 : ℝ) / 2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def bendWilkerMatrixInv : BSquareMatrix :=
  ![![0, -2, 0, 0],
    ![-2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def bendTangentGram : BSquareMatrix :=
  fun i j => if i = j then 1 else -1

private noncomputable def bendTangentGramInv : BSquareMatrix :=
  fun i j => if i = j then (1 : ℝ) / 4 else -(1 : ℝ) / 4

private theorem bendWilkerMatrixInv_mul :
    bendWilkerMatrixInv * bendWilkerMatrix = (1 : BSquareMatrix) := by
  ext i j
  change (∑ k : BIndex, bendWilkerMatrixInv i k * bendWilkerMatrix k j) =
    (1 : BSquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [bendWilkerMatrixInv, bendWilkerMatrix, Fin.sum_univ_four, Matrix.one_apply]

private theorem bendTangentGram_mul_inv :
    bendTangentGram * bendTangentGramInv = (1 : BSquareMatrix) := by
  ext i j
  change (∑ k : BIndex, bendTangentGram i k * bendTangentGramInv k j) =
    (1 : BSquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [bendTangentGram, bendTangentGramInv, Fin.sum_univ_four, Matrix.one_apply]

private noncomputable def bendAugmentedMatrix (c : BIndex → Circle) : BSquareMatrix :=
  fun i j => augmentedCoordinates (c i) j

private theorem bendAugmentedGram_apply (c : BIndex → Circle) (i j : BIndex) :
    (bendAugmentedMatrix c * bendWilkerMatrix * (bendAugmentedMatrix c)ᵀ) i j =
      circlePairing (c i) (c j) := by
  change
    (∑ k : BIndex,
      (∑ l : BIndex, bendAugmentedMatrix c i l * bendWilkerMatrix l k) *
        (bendAugmentedMatrix c)ᵀ k j) =
      circlePairing (c i) (c j)
  simp [bendAugmentedMatrix, bendWilkerMatrix, circlePairing, wilkerPairing,
    Matrix.transpose_apply, Fin.sum_univ_four]
  ring

private theorem bendAugmentedGram_eq
    (c : BIndex → Circle) (h : IsOrientedDescartesConfiguration c) :
    bendAugmentedMatrix c * bendWilkerMatrix * (bendAugmentedMatrix c)ᵀ =
      bendTangentGram := by
  rcases h with ⟨hnz, htan⟩
  ext i j
  rw [bendAugmentedGram_apply]
  by_cases hij : i = j
  · subst j
    rw [circlePairing_self (c i) (hnz i)]
    simp [bendTangentGram]
  · have hp :=
      (isOrientedTangent_iff_circlePairing_eq_neg_one
        (c i) (c j) (hnz i) (hnz j)).1 (htan i j hij)
    rw [hp]
    simp [bendTangentGram, hij]

private theorem bendDualGram
    (W : BSquareMatrix)
    (hgram : W * bendWilkerMatrix * Wᵀ = bendTangentGram) :
    Wᵀ * bendTangentGramInv * W = bendWilkerMatrixInv := by
  let L : BSquareMatrix := bendWilkerMatrix * Wᵀ * bendTangentGramInv
  have hWL : W * L = (1 : BSquareMatrix) := by
    dsimp [L]
    calc
      W * (bendWilkerMatrix * Wᵀ * bendTangentGramInv) =
          (W * bendWilkerMatrix * Wᵀ) * bendTangentGramInv := by
            simp [Matrix.mul_assoc]
      _ = bendTangentGram * bendTangentGramInv := by rw [hgram]
      _ = 1 := bendTangentGram_mul_inv
  have hLW : L * W = (1 : BSquareMatrix) := (mul_eq_one_comm.mp hWL)
  calc
    Wᵀ * bendTangentGramInv * W =
        (bendWilkerMatrixInv * bendWilkerMatrix) *
          Wᵀ * bendTangentGramInv * W := by
            rw [bendWilkerMatrixInv_mul]
            simp
    _ = bendWilkerMatrixInv *
        ((bendWilkerMatrix * Wᵀ * bendTangentGramInv) * W) := by
          simp [Matrix.mul_assoc]
    _ = bendWilkerMatrixInv * 1 := by rw [hLW]
    _ = bendWilkerMatrixInv := by simp

private def bendColumn (W : BSquareMatrix) (i : BIndex) : ℂ :=
  ⟨W i 2, W i 3⟩

private theorem bendColumn_isQuadruple
    (W : BSquareMatrix)
    (hgram : W * bendWilkerMatrix * Wᵀ = bendTangentGram) :
    DescartesCircle.IsQuadruple
      (bendColumn W 0) (bendColumn W 1) (bendColumn W 2) (bendColumn W 3) := by
  have hq := bendDualGram W hgram
  have h22 := congrArg (fun M : BSquareMatrix => M (2 : BIndex) (2 : BIndex)) hq
  have h33 := congrArg (fun M : BSquareMatrix => M (3 : BIndex) (3 : BIndex)) hq
  have h23 := congrArg (fun M : BSquareMatrix => M (2 : BIndex) (3 : BIndex)) hq
  change
    (∑ k : BIndex,
      (∑ l : BIndex, W l (2 : BIndex) * bendTangentGramInv l k) *
        W k (2 : BIndex)) =
      bendWilkerMatrixInv (2 : BIndex) (2 : BIndex) at h22
  change
    (∑ k : BIndex,
      (∑ l : BIndex, W l (3 : BIndex) * bendTangentGramInv l k) *
        W k (3 : BIndex)) =
      bendWilkerMatrixInv (3 : BIndex) (3 : BIndex) at h33
  change
    (∑ k : BIndex,
      (∑ l : BIndex, W l (2 : BIndex) * bendTangentGramInv l k) *
        W k (3 : BIndex)) =
      bendWilkerMatrixInv (2 : BIndex) (3 : BIndex) at h23
  simp [bendTangentGramInv, bendWilkerMatrixInv, Fin.sum_univ_four] at h22 h33 h23
  unfold DescartesCircle.IsQuadruple
  apply Complex.ext <;>
    simp [bendColumn, pow_two, Complex.mul_re, Complex.mul_im] <;>
    nlinarith [h22, h33, h23]

/-- The four complex bend-centers of an oriented Descartes configuration satisfy the Descartes
quadratic relation over the complex numbers. -/
theorem bendCenter_isQuadruple_of_oriented_descartes_configuration
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c) :
    DescartesCircle.IsQuadruple
      (bendCenter (c 0)) (bendCenter (c 1))
      (bendCenter (c 2)) (bendCenter (c 3)) := by
  have hgram := bendAugmentedGram_eq c h
  have hdesc := bendColumn_isQuadruple (bendAugmentedMatrix c) hgram
  simpa [bendColumn, bendAugmentedMatrix, augmentedCoordinates] using hdesc

end LeanFrontier.CurvatureCenter
