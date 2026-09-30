import LeanFrontier.Geometry.CurvatureCenterWilker
import LeanFrontier.NumberTheory.DescartesCircle
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Geometric Descartes theorem from augmented curvature-center coordinates

The curvature-center development now has the two ingredients needed to derive the classical
Descartes relation from actual circle geometry:

* every nonzero-curvature circle has Wilker self-pairing one;
* two positive-curvature circles are externally tangent exactly when their Wilker pairing is
  minus one.

For four pairwise externally tangent positive-curvature circles, the Gram matrix of their
augmented curvature-center rows is therefore the fixed matrix with diagonal entries one and
off-diagonal entries minus one.  This module performs the resulting finite-dimensional matrix
calculation.  The nullity of the curvature column for the inverse Gram form is exactly
Descartes' quadratic equation.

The public endpoint is geometric: the four curvatures of a positive Descartes configuration
satisfy the already accepted `DescartesCircle.IsQuadruple` relation.
-/

namespace LeanFrontier.CurvatureCenter

open Matrix
open scoped Matrix

private abbrev Index := Fin 4
private abbrev SquareMatrix := Matrix Index Index ℝ

private noncomputable def wilkerMatrix : SquareMatrix :=
  ![![0, -(1 : ℝ) / 2, 0, 0],
    ![-(1 : ℝ) / 2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def wilkerMatrixInv : SquareMatrix :=
  ![![0, -2, 0, 0],
    ![-2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def tangentGram : SquareMatrix :=
  fun i j => if i = j then 1 else -1

private noncomputable def tangentGramInv : SquareMatrix :=
  fun i j => if i = j then (1 : ℝ) / 4 else -(1 : ℝ) / 4

private theorem wilkerMatrixInv_mul_wilkerMatrix :
    wilkerMatrixInv * wilkerMatrix = (1 : SquareMatrix) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp only [Matrix.mul_apply, wilkerMatrixInv, wilkerMatrix, Fin.sum_univ_succ,
      Matrix.one_apply] <;>
    norm_num

private theorem tangentGram_mul_tangentGramInv :
    tangentGram * tangentGramInv = (1 : SquareMatrix) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp only [Matrix.mul_apply, tangentGram, tangentGramInv, Fin.sum_univ_succ,
      Matrix.one_apply] <;>
    norm_num

private noncomputable def augmentedMatrix (c : Index → Circle) : SquareMatrix :=
  fun i j => augmentedCoordinates (c i) j

private theorem augmentedGram_apply (c : Index → Circle) (i j : Index) :
    (augmentedMatrix c * wilkerMatrix * (augmentedMatrix c)ᵀ) i j =
      circlePairing (c i) (c j) := by
  simp_rw [Matrix.mul_apply]
  simp [augmentedMatrix, wilkerMatrix, circlePairing, wilkerPairing,
    Matrix.transpose_apply, Fin.sum_univ_succ]
  ring

/-- Four positive-curvature circles form a positive Descartes configuration when every distinct
pair is externally tangent. -/
def IsPositiveDescartesConfiguration (c : Fin 4 → Circle) : Prop :=
  (∀ i, 0 < (c i).curvature) ∧
    ∀ i j, i ≠ j → IsExternallyTangent (c i) (c j)

private theorem augmentedGram_eq_tangentGram
    (c : Index → Circle) (h : IsPositiveDescartesConfiguration c) :
    augmentedMatrix c * wilkerMatrix * (augmentedMatrix c)ᵀ = tangentGram := by
  rcases h with ⟨hpos, htan⟩
  ext i j
  rw [augmentedGram_apply]
  by_cases hij : i = j
  · subst j
    rw [circlePairing_self (c i) (hpos i).ne']
    simp [tangentGram]
  · have hp :=
      (isExternallyTangent_iff_circlePairing_eq_neg_one
        (c i) (c j) (hpos i) (hpos j)).1 (htan i j hij)
    rw [hp]
    simp [tangentGram, hij]

private theorem curvatureColumn_isQuadruple
    (W : SquareMatrix)
    (hgram : W * wilkerMatrix * Wᵀ = tangentGram) :
    DescartesCircle.IsQuadruple (W 0 1) (W 1 1) (W 2 1) (W 3 1) := by
  let L : SquareMatrix := wilkerMatrix * Wᵀ * tangentGramInv
  have hWL : W * L = (1 : SquareMatrix) := by
    dsimp [L]
    calc
      W * (wilkerMatrix * Wᵀ * tangentGramInv) =
          (W * wilkerMatrix * Wᵀ) * tangentGramInv := by
            simp [Matrix.mul_assoc]
      _ = tangentGram * tangentGramInv := by rw [hgram]
      _ = 1 := tangentGram_mul_tangentGramInv
  have hLW : L * W = (1 : SquareMatrix) := (mul_eq_one_comm.mp hWL)
  have hq : Wᵀ * tangentGramInv * W = wilkerMatrixInv := by
    have hh := congrArg (fun M : SquareMatrix => wilkerMatrixInv * M) hLW
    simpa [L, Matrix.mul_assoc, wilkerMatrixInv_mul_wilkerMatrix] using hh
  have h11 := congrArg (fun M : SquareMatrix => M (1 : Index) (1 : Index)) hq
  simp [Matrix.mul_apply, tangentGramInv, wilkerMatrixInv, Fin.sum_univ_four] at h11
  unfold DescartesCircle.IsQuadruple
  linear_combination -4 * h11

/-- The curvatures of four pairwise externally tangent positive-curvature Euclidean circles
satisfy Descartes' circle equation. -/
theorem isQuadruple_of_positive_descartes_configuration
    (c : Fin 4 → Circle) (h : IsPositiveDescartesConfiguration c) :
    DescartesCircle.IsQuadruple
      (c 0).curvature (c 1).curvature (c 2).curvature (c 3).curvature := by
  have hgram := augmentedGram_eq_tangentGram c h
  have hdesc := curvatureColumn_isQuadruple (augmentedMatrix c) hgram
  simpa [augmentedMatrix, augmentedCoordinates] using hdesc

end LeanFrontier.CurvatureCenter
