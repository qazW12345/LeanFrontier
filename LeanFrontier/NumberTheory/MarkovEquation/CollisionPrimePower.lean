import LeanFrontier.NumberTheory.MarkovEquation.CollisionPrime
import Mathlib.Algebra.Prime.Lemmas
import Mathlib.Tactic

/-!
# Prime-power localization of Markov collision factors

For two positive Markov triples sharing an odd prime-power coordinate `c = p^n`, the full square
`c^2` divides exactly one of Srinivasan's two collision factors, while `p` does not divide the
other factor.

This upgrades the prime-by-prime exclusive split to the valuation statement needed in the
classical prime-power uniqueness argument.
-/

namespace LeanFrontier.MarkovEquation

/-- If the shared coordinate of two positive Markov triples is an odd prime power, then its square
divides one collision factor in full and the underlying prime does not divide the other. -/
theorem oddPrimePower_sq_dvd_one_collisionFactor
    {a₁ b₁ a₂ b₂ c : ℤ} {p n : ℕ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂) (hc : 0 < c)
    (h₁ : IsSolution a₁ b₁ c)
    (h₂ : IsSolution a₂ b₂ c)
    (hp : p.Prime) (hp_ne_two : p ≠ 2)
    (hn : 0 < n)
    (hcPow : c = (p : ℤ) ^ n) :
    ((c ^ 2 ∣ a₁ * a₂ - b₁ * b₂) ∧
      ¬((p : ℤ) ∣ a₁ * b₂ - b₁ * a₂)) ∨
    ((c ^ 2 ∣ a₁ * b₂ - b₁ * a₂) ∧
      ¬((p : ℤ) ∣ a₁ * a₂ - b₁ * b₂)) := by
  have hpc : (p : ℤ) ∣ c := by
    rw [hcPow]
    exact dvd_pow_self (p : ℤ) (Nat.ne_of_gt hn)
  have hexclusive :=
    oddPrime_dvd_exactly_one_collisionFactor
      ha₁ hb₁ ha₂ hb₂ hc h₁ h₂ hp hp_ne_two hpc
  have hcSqProd :
      c ^ 2 ∣
        (a₁ * a₂ - b₁ * b₂) * (a₁ * b₂ - b₁ * a₂) := by
    rw [collision_factorization h₁ h₂]
    exact dvd_mul_right (c ^ 2) (a₁ * b₁ - a₂ * b₂)
  have hcSqEq : c ^ 2 = (p : ℤ) ^ (2 * n) := by
    rw [hcPow]
    calc
      ((p : ℤ) ^ n) ^ 2 = (p : ℤ) ^ (n * 2) := by
        rw [pow_mul]
      _ = (p : ℤ) ^ (2 * n) := by
        rw [Nat.mul_comm]
  have hpPowProd :
      (p : ℤ) ^ (2 * n) ∣
        (a₁ * a₂ - b₁ * b₂) * (a₁ * b₂ - b₁ * a₂) := by
    rwa [← hcSqEq]
  have hpInt : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  rcases hexclusive with ⟨hE, hnotD⟩ | ⟨hD, hnotE⟩
  · left
    refine ⟨?_, hnotD⟩
    rw [hcSqEq]
    exact hpInt.pow_dvd_of_dvd_mul_right (2 * n) hnotD hpPowProd
  · right
    refine ⟨?_, hnotE⟩
    rw [hcSqEq]
    exact hpInt.pow_dvd_of_dvd_mul_left (2 * n) hnotE hpPowProd

end LeanFrontier.MarkovEquation
