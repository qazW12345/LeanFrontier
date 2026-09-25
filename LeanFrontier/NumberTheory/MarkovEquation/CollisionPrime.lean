import LeanFrontier.NumberTheory.MarkovEquation.Collision
import LeanFrontier.NumberTheory.MarkovTree.Coprime
import Mathlib.Data.Nat.Prime.Int
import Mathlib.Tactic

/-!
# Odd-prime separation of Markov collision factors

For two positive Markov triples sharing a coordinate `c`, Srinivasan's collision factorization
uses the two comparison factors

`
E = a₁*a₂ - b₁*b₂
D = a₁*b₂ - b₁*a₂.
`

An odd prime divisor of `c` cannot divide both `E` and `D`.  This is the local arithmetic
fact that later lets prime-power factors of a hypothetical equal-Markov-number collision split
between the same-root and opposite-root cases.

The proof is elementary.  Divisibility of both factors forces the prime to divide
`a₁^2 - b₁^2`; the first Markov equation modulo the common coordinate forces it to divide
`a₁^2 + b₁^2`.  Hence it divides `2*a₁^2`, contradicting oddness and the accepted pairwise
coprimality theorem for positive Markov triples.
-/

namespace LeanFrontier.MarkovEquation

/-- Let two positive Markov triples share their third coordinate `c`.  No odd prime divisor of
`c` divides both of Srinivasan's collision factors. -/
theorem oddPrime_not_dvd_both_collisionFactors
    {a₁ b₁ a₂ b₂ c : ℤ} {p : ℕ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂) (hc : 0 < c)
    (h₁ : IsSolution a₁ b₁ c)
    (h₂ : IsSolution a₂ b₂ c)
    (hp : p.Prime) (hp_ne_two : p ≠ 2)
    (hpc : (p : ℤ) ∣ c) :
    ¬((p : ℤ) ∣ a₁ * a₂ - b₁ * b₂ ∧
      (p : ℤ) ∣ a₁ * b₂ - b₁ * a₂) := by
  have hcop₁ :=
    LeanFrontier.MarkovTree.pairwiseCoprime_of_positive_solution
      (LeanFrontier.MarkovTree.State.mk a₁ b₁ c)
      ha₁ hb₁ hc (by
        simpa [LeanFrontier.MarkovTree.State.IsSolution] using h₁)
  have hcop₂ :=
    LeanFrontier.MarkovTree.pairwiseCoprime_of_positive_solution
      (LeanFrontier.MarkovTree.State.mk a₂ b₂ c)
      ha₂ hb₂ hc (by
        simpa [LeanFrontier.MarkovTree.State.IsSolution] using h₂)
  have ha₁c : IsCoprime a₁ c := hcop₁.2.1
  have hb₂c : IsCoprime b₂ c := hcop₂.2.2
  have hpInt : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hp_not_dvd_a₁ : ¬(p : ℤ) ∣ a₁ := by
    intro hpa₁
    have hself : IsCoprime (p : ℤ) (p : ℤ) :=
      ha₁c.mono hpa₁ hpc
    exact hpInt.not_isUnit (isCoprime_self.mp hself)
  have hp_not_dvd_b₂ : ¬(p : ℤ) ∣ b₂ := by
    intro hpb₂
    have hself : IsCoprime (p : ℤ) (p : ℤ) :=
      hb₂c.mono hpb₂ hpc
    exact hpInt.not_isUnit (isCoprime_self.mp hself)
  rintro ⟨hE, hD⟩
  have hdiffProd : (p : ℤ) ∣ b₂ * (a₁ ^ 2 - b₁ ^ 2) := by
    have hsumDvd :
        (p : ℤ) ∣
          a₁ * (a₁ * b₂ - b₁ * a₂) +
            b₁ * (a₁ * a₂ - b₁ * b₂) :=
      dvd_add (hD.mul_left a₁) (hE.mul_left b₁)
    convert hsumDvd using 1 <;> ring
  have hdiff : (p : ℤ) ∣ a₁ ^ 2 - b₁ ^ 2 := by
    rcases Int.Prime.dvd_mul' hp hdiffProd with hpb₂ | hdiff
    · exact (hp_not_dvd_b₂ hpb₂).elim
    · exact hdiff
  have hsumEq :
      a₁ ^ 2 + b₁ ^ 2 = c * (3 * a₁ * b₁ - c) := by
    unfold IsSolution at h₁
    nlinarith
  have hsum : (p : ℤ) ∣ a₁ ^ 2 + b₁ ^ 2 := by
    rw [hsumEq]
    exact hpc.mul_right (3 * a₁ * b₁ - c)
  have htwoSq : (p : ℤ) ∣ 2 * a₁ ^ 2 := by
    have hboth := dvd_add hsum hdiff
    convert hboth using 1 <;> ring
  rcases Int.Prime.dvd_mul' hp htwoSq with hpTwo | hpSq
  · have hpTwoNat : p ∣ 2 := Int.natCast_dvd_natCast.mp hpTwo
    have hle : p ≤ 2 := Nat.le_of_dvd (by norm_num) hpTwoNat
    exact hp_ne_two (Nat.le_antisymm hle hp.two_le)
  · exact hp_not_dvd_a₁ (Int.Prime.dvd_pow' hp hpSq)


/-- Every odd prime divisor of the common Markov coordinate divides exactly one of Srinivasan's
two collision factors.  This is the prime-by-prime same-root/opposite-root split underlying the
CRT formulation of a possible composite collision. -/
theorem oddPrime_dvd_exactly_one_collisionFactor
    {a₁ b₁ a₂ b₂ c : ℤ} {p : ℕ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂) (hc : 0 < c)
    (h₁ : IsSolution a₁ b₁ c)
    (h₂ : IsSolution a₂ b₂ c)
    (hp : p.Prime) (hp_ne_two : p ≠ 2)
    (hpc : (p : ℤ) ∣ c) :
    (((p : ℤ) ∣ a₁ * a₂ - b₁ * b₂) ∧
      ¬((p : ℤ) ∣ a₁ * b₂ - b₁ * a₂)) ∨
    (((p : ℤ) ∣ a₁ * b₂ - b₁ * a₂) ∧
      ¬((p : ℤ) ∣ a₁ * a₂ - b₁ * b₂)) := by
  have hnotboth :=
    oddPrime_not_dvd_both_collisionFactors
      ha₁ hb₁ ha₂ hb₂ hc h₁ h₂ hp hp_ne_two hpc
  have hcSq : (p : ℤ) ∣ c ^ 2 := by
    simpa [pow_two] using hpc.mul_right c
  have hprod :
      (p : ℤ) ∣
        (a₁ * a₂ - b₁ * b₂) * (a₁ * b₂ - b₁ * a₂) := by
    rw [collision_factorization h₁ h₂]
    exact hcSq.mul_right (a₁ * b₁ - a₂ * b₂)
  rcases Int.Prime.dvd_mul' hp hprod with hE | hD
  · exact Or.inl ⟨hE, fun hD => hnotboth ⟨hE, hD⟩⟩
  · exact Or.inr ⟨hD, fun hE => hnotboth ⟨hE, hD⟩⟩

end LeanFrontier.MarkovEquation
