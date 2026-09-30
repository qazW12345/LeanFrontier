import LeanFrontier.Geometry.GeometricDescartesCompletion
import LeanFrontier.Geometry.OrientedGeometricDescartes
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Nlinarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Full augmented-coordinate replacement for oriented Descartes configurations

Curvature and bend-center replacement can each be described by the two roots of a Descartes
quadratic, but treating those coordinates separately leaves open whether they choose the same
root.  This module removes that ambiguity at the level of the complete augmented
curvature-center row.

For an oriented Descartes configuration let W be the 4 by 4 matrix whose rows are the augmented
circle coordinates.  Its Wilker Gram matrix is the fixed Descartes tangency matrix.  If the last
circle is replaced by another oriented-tangent completion, the new matrix W' has the same Gram
matrix and the same first three rows.  Since W is invertible, A = W' W⁻¹ fixes the first three
basis rows and preserves the tangency Gram form.  Its final row is therefore forced to be either

  (0, 0, 0, 1)

or

  (2, 2, 2, -1).

Consequently the replacement circle's entire augmented coordinate row is either unchanged or
exactly 2 times the sum of the first three rows minus the old fourth row.  In particular all
curvature-center coordinates select the same Descartes/Vieta branch.
-/

namespace LeanFrontier.CurvatureCenter

open Matrix
open scoped Matrix

private abbrev AIndex := Fin 4
private abbrev ASquareMatrix := Matrix AIndex AIndex ℝ

private noncomputable def completionWilkerMatrix : ASquareMatrix :=
  ![![0, -(1 : ℝ) / 2, 0, 0],
    ![-(1 : ℝ) / 2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def completionWilkerMatrixInv : ASquareMatrix :=
  ![![0, -2, 0, 0],
    ![-2, 0, 0, 0],
    ![0, 0, 1, 0],
    ![0, 0, 0, 1]]

private def completionTangentGram : ASquareMatrix :=
  fun i j => if i = j then 1 else -1

private noncomputable def completionTangentGramInv : ASquareMatrix :=
  fun i j => if i = j then (1 : ℝ) / 4 else -(1 : ℝ) / 4

private theorem completionWilkerMatrixInv_mul :
    completionWilkerMatrixInv * completionWilkerMatrix = (1 : ASquareMatrix) := by
  ext i j
  change (∑ k : AIndex, completionWilkerMatrixInv i k * completionWilkerMatrix k j) =
    (1 : ASquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [completionWilkerMatrixInv, completionWilkerMatrix,
      Fin.sum_univ_four, Matrix.one_apply]

private theorem completionTangentGram_mul_inv :
    completionTangentGram * completionTangentGramInv = (1 : ASquareMatrix) := by
  ext i j
  change (∑ k : AIndex, completionTangentGram i k * completionTangentGramInv k j) =
    (1 : ASquareMatrix) i j
  fin_cases i <;> fin_cases j <;>
    norm_num [completionTangentGram, completionTangentGramInv,
      Fin.sum_univ_four, Matrix.one_apply]

private noncomputable def completionAugmentedMatrix
    (c : AIndex → Circle) : ASquareMatrix :=
  fun i j => augmentedCoordinates (c i) j

private theorem completionAugmentedGram_apply
    (c : AIndex → Circle) (i j : AIndex) :
    (completionAugmentedMatrix c * completionWilkerMatrix *
        (completionAugmentedMatrix c)ᵀ) i j =
      circlePairing (c i) (c j) := by
  change
    (∑ k : AIndex,
      (∑ l : AIndex,
        completionAugmentedMatrix c i l * completionWilkerMatrix l k) *
        (completionAugmentedMatrix c)ᵀ k j) =
      circlePairing (c i) (c j)
  simp [completionAugmentedMatrix, completionWilkerMatrix,
    circlePairing, wilkerPairing, Matrix.transpose_apply, Fin.sum_univ_four]
  ring

private theorem completionAugmentedGram_eq
    (c : AIndex → Circle) (h : IsOrientedDescartesConfiguration c) :
    completionAugmentedMatrix c * completionWilkerMatrix *
        (completionAugmentedMatrix c)ᵀ =
      completionTangentGram := by
  rcases h with ⟨hnz, htan⟩
  ext i j
  rw [completionAugmentedGram_apply]
  by_cases hij : i = j
  · subst j
    rw [circlePairing_self (c i) (hnz i)]
    simp [completionTangentGram]
  · have hp :=
      (isOrientedTangent_iff_circlePairing_eq_neg_one
        (c i) (c j) (hnz i) (hnz j)).1 (htan i j hij)
    rw [hp]
    simp [completionTangentGram, hij]

private theorem replaceLast_isOrientedConfiguration
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    IsOrientedDescartesConfiguration (replaceLast c d) := by
  rcases h with ⟨hnz, htan⟩
  constructor
  · intro i
    by_cases hi : i = (3 : Fin 4)
    · subst i
      simpa [replaceLast] using hdnz
    · simpa [replaceLast, hi] using hnz i
  · intro i j hij
    by_cases hi : i = (3 : Fin 4)
    · subst i
      have hj : j ≠ (3 : Fin 4) := Ne.symm hij
      have ht := hdtan j hj
      have hsym := (isOrientedTangent_comm (c j) d).mp ht
      simpa [replaceLast, hj] using hsym
    · by_cases hj : j = (3 : Fin 4)
      · subst j
        simpa [replaceLast, hi] using hdtan i hi
      · simpa [replaceLast, hi, hj] using htan i j hij

/-- The alternate augmented-coordinate row determined by the first three rows and the old
fourth row. -/
noncomputable def reflectedLastAugmentedCoordinates
    (c : Fin 4 → Circle) : AugmentedCoordinates :=
  fun j =>
    2 * (augmentedCoordinates (c 0) j +
      augmentedCoordinates (c 1) j +
      augmentedCoordinates (c 2) j) -
    augmentedCoordinates (c 3) j

/-- A replacement circle tangent to the same first three circles has a fully aligned augmented
coordinate row: it is either the old fourth row or the Vieta-reflected row
2(r0+r1+r2)-r3. -/
theorem orientedCompletion_augmentedCoordinates_eq_or_eq_reflected
    (c : Fin 4 → Circle) (h : IsOrientedDescartesConfiguration c)
    (d : Circle) (hdnz : d.curvature ≠ 0)
    (hdtan : ∀ i, i ≠ (3 : Fin 4) → IsOrientedTangent (c i) d) :
    augmentedCoordinates d = augmentedCoordinates (c 3) ∨
      augmentedCoordinates d = reflectedLastAugmentedCoordinates c := by
  let W : ASquareMatrix := completionAugmentedMatrix c
  let c' : Fin 4 → Circle := replaceLast c d
  let W' : ASquareMatrix := completionAugmentedMatrix c'
  have hc' : IsOrientedDescartesConfiguration c' := by
    dsimp [c']
    exact replaceLast_isOrientedConfiguration c h d hdnz hdtan
  have hW : W * completionWilkerMatrix * Wᵀ = completionTangentGram := by
    dsimp [W]
    exact completionAugmentedGram_eq c h
  have hW' : W' * completionWilkerMatrix * W'ᵀ = completionTangentGram := by
    dsimp [W']
    exact completionAugmentedGram_eq c' hc'
  let L : ASquareMatrix :=
    completionWilkerMatrix * Wᵀ * completionTangentGramInv
  have hWL : W * L = (1 : ASquareMatrix) := by
    dsimp [L]
    calc
      W * (completionWilkerMatrix * Wᵀ * completionTangentGramInv) =
          (W * completionWilkerMatrix * Wᵀ) * completionTangentGramInv := by
            simp [Matrix.mul_assoc]
      _ = completionTangentGram * completionTangentGramInv := by rw [hW]
      _ = 1 := completionTangentGram_mul_inv
  have hLW : L * W = (1 : ASquareMatrix) := mul_eq_one_comm.mp hWL
  let A : ASquareMatrix := W' * L
  have hAW : A * W = W' := by
    dsimp [A]
    calc
      (W' * L) * W = W' * (L * W) := by simp [Matrix.mul_assoc]
      _ = W' * 1 := by rw [hLW]
      _ = W' := by simp
  have hrow (i : AIndex) (hi : i ≠ (3 : AIndex)) (j : AIndex) :
      A i j = (1 : ASquareMatrix) i j := by
    dsimp [A]
    change (∑ k : AIndex, W' i k * L k j) = (1 : ASquareMatrix) i j
    have hsame : ∀ k : AIndex, W' i k = W i k := by
      intro k
      simp [W', W, c', completionAugmentedMatrix, replaceLast, hi]
    simp_rw [hsame]
    have hij := congrArg (fun M : ASquareMatrix => M i j) hWL
    simpa [Matrix.mul_apply] using hij
  have hAgram : A * completionTangentGram * Aᵀ = completionTangentGram := by
    calc
      A * completionTangentGram * Aᵀ =
          A * (W * completionWilkerMatrix * Wᵀ) * Aᵀ := by rw [hW]
      _ = (A * W) * completionWilkerMatrix * (A * W)ᵀ := by
            simp [Matrix.mul_assoc, Matrix.transpose_mul]
      _ = W' * completionWilkerMatrix * W'ᵀ := by rw [hAW]
      _ = completionTangentGram := hW'
  have h30 := congrArg
    (fun M : ASquareMatrix => M (3 : AIndex) (0 : AIndex)) hAgram
  have h31 := congrArg
    (fun M : ASquareMatrix => M (3 : AIndex) (1 : AIndex)) hAgram
  have h32 := congrArg
    (fun M : ASquareMatrix => M (3 : AIndex) (2 : AIndex)) hAgram
  have h33 := congrArg
    (fun M : ASquareMatrix => M (3 : AIndex) (3 : AIndex)) hAgram
  have hrow0 : ∀ j : AIndex, A 0 j = (1 : ASquareMatrix) 0 j :=
    hrow 0 (by decide)
  have hrow1 : ∀ j : AIndex, A 1 j = (1 : ASquareMatrix) 1 j :=
    hrow 1 (by decide)
  have hrow2 : ∀ j : AIndex, A 2 j = (1 : ASquareMatrix) 2 j :=
    hrow 2 (by decide)
  simp [Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_four,
    completionTangentGram, hrow0, hrow1, hrow2, Matrix.one_apply] at h30 h31 h32 h33
  have hfactor : A 3 0 * (A 3 0 - 2) = 0 := by
    nlinarith [h30, h31, h32, h33]
  rcases mul_eq_zero.mp hfactor with hzero | htwo
  · left
    have ha0 : A 3 0 = 0 := hzero
    have ha1 : A 3 1 = 0 := by nlinarith [h30, h31]
    have ha2 : A 3 2 = 0 := by nlinarith [h30, h32]
    have ha3 : A 3 3 = 1 := by nlinarith [h30]
    funext j
    have haw := congrArg (fun M : ASquareMatrix => M (3 : AIndex) j) hAW
    change
      (∑ k : AIndex, A 3 k * W k j) = W' 3 j at haw
    simp [Fin.sum_univ_four, ha0, ha1, ha2, ha3] at haw
    simpa [W', W, c', completionAugmentedMatrix, replaceLast] using haw.symm
  · right
    have ha0 : A 3 0 = 2 := sub_eq_zero.mp htwo
    have ha1 : A 3 1 = 2 := by nlinarith [h30, h31]
    have ha2 : A 3 2 = 2 := by nlinarith [h30, h32]
    have ha3 : A 3 3 = -1 := by nlinarith [h30]
    funext j
    have haw := congrArg (fun M : ASquareMatrix => M (3 : AIndex) j) hAW
    change
      (∑ k : AIndex, A 3 k * W k j) = W' 3 j at haw
    simp [Fin.sum_univ_four, ha0, ha1, ha2, ha3] at haw
    simp [reflectedLastAugmentedCoordinates, W', W, c',
      completionAugmentedMatrix, replaceLast] at haw ⊢
    nlinarith [haw]

end LeanFrontier.CurvatureCenter
