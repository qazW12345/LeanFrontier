import LeanFrontier.NumberTheory.MarkovEquation.CollisionPrime
import Mathlib.RingTheory.Coprime.Basic
import Mathlib.Tactic

/-!
# Rigidity of primitive Markov collision pairs

This module isolates the elementary primitive-pair arguments used after a collision factor is
forced to vanish.

For positive coprime pairs `(a₁,b₁)` and `(a₂,b₂)`:

* vanishing of the cross determinant `a₁*b₂ - b₁*a₂` forces the ordered pairs to be equal;
* vanishing of the companion factor `a₁*a₂ - b₁*b₂`, together with
  `aᵢ ≤ bᵢ`, also forces equality.

These are the final algebraic rigidity steps in Srinivasan's elementary prime-power uniqueness
argument.
-/

namespace LeanFrontier.MarkovEquation

/-- Two positive primitive integer pairs with zero cross determinant are equal. -/
theorem positiveCoprimePair_eq_of_cross_eq_zero
    {a₁ b₁ a₂ b₂ : ℤ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hcop₁ : IsCoprime a₁ b₁)
    (hcop₂ : IsCoprime a₂ b₂)
    (hcross : a₁ * b₂ - b₁ * a₂ = 0) :
    a₁ = a₂ ∧ b₁ = b₂ := by
  have hab : a₁ * b₂ = b₁ * a₂ := by
    linarith
  have ha₁_dvd_a₂ : a₁ ∣ a₂ := by
    apply hcop₁.dvd_of_dvd_mul_left
    exact ⟨b₂, hab.symm⟩
  have ha₂_dvd_a₁ : a₂ ∣ a₁ := by
    apply hcop₂.dvd_of_dvd_mul_left
    refine ⟨b₁, ?_⟩
    calc
      b₂ * a₁ = a₁ * b₂ := by ring
      _ = b₁ * a₂ := hab
      _ = a₂ * b₁ := by ring
  have ha₁_le_a₂ : a₁ ≤ a₂ := Int.le_of_dvd ha₂ ha₁_dvd_a₂
  have ha₂_le_a₁ : a₂ ≤ a₁ := Int.le_of_dvd ha₁ ha₂_dvd_a₁
  have ha : a₁ = a₂ := le_antisymm ha₁_le_a₂ ha₂_le_a₁
  subst a₂
  have hb : b₁ = b₂ := by
    have hne : a₁ ≠ 0 := ne_of_gt ha₁
    apply mul_left_cancel₀ hne
    simpa [mul_comm] using hab.symm
  exact ⟨rfl, hb⟩

/-- If two positive primitive pairs are ordered componentwise within each pair, then vanishing of
the companion collision factor also forces equality. -/
theorem positiveOrderedCoprimePair_eq_of_companion_eq_zero
    {a₁ b₁ a₂ b₂ : ℤ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hab₁ : a₁ ≤ b₁) (hab₂ : a₂ ≤ b₂)
    (hcop₁ : IsCoprime a₁ b₁)
    (hcop₂ : IsCoprime a₂ b₂)
    (hcomp : a₁ * a₂ - b₁ * b₂ = 0) :
    a₁ = a₂ ∧ b₁ = b₂ := by
  have hab : a₁ * a₂ = b₁ * b₂ := by
    linarith
  have ha₁_dvd_b₂ : a₁ ∣ b₂ := by
    apply hcop₁.dvd_of_dvd_mul_left
    exact ⟨a₂, hab.symm⟩
  have hb₂_dvd_a₁ : b₂ ∣ a₁ := by
    apply hcop₂.symm.dvd_of_dvd_mul_left
    refine ⟨b₁, ?_⟩
    calc
      a₂ * a₁ = a₁ * a₂ := by ring
      _ = b₁ * b₂ := hab
      _ = b₂ * b₁ := by ring
  have ha₁_le_b₂ : a₁ ≤ b₂ := Int.le_of_dvd hb₂ ha₁_dvd_b₂
  have hb₂_le_a₁ : b₂ ≤ a₁ := Int.le_of_dvd ha₁ hb₂_dvd_a₁
  have habSwap : a₁ = b₂ := le_antisymm ha₁_le_b₂ hb₂_le_a₁
  subst b₂
  have hbaSwap : b₁ = a₂ := by
    have hne : a₁ ≠ 0 := ne_of_gt ha₁
    apply mul_right_cancel₀ hne
    simpa [mul_comm] using hab
  subst b₁
  have ha : a₁ = a₂ := le_antisymm hab₁ hab₂
  subst a₂
  exact ⟨rfl, rfl⟩

end LeanFrontier.MarkovEquation
