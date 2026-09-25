import LeanFrontier.NumberTheory.MarkovEquation.CollisionPrimeSplit
import LeanFrontier.NumberTheory.MarkovTree.Coprime
import Mathlib.Tactic

/-!
# Uniqueness for odd-prime-power Markov numbers

This module proves a classical partial case of the Frobenius/Markov uniqueness conjecture:
two positive ordered Markov triples with the same largest coordinate are equal when that common
coordinate is a positive power of an odd prime.

The proof follows the elementary collision-factorization route.  The prime-power split forces the
square of the common coordinate to divide one of two determinant-like collision factors.  Each
factor has absolute value strictly smaller than that square, so the selected factor vanishes.
Pairwise coprimality then reconstructs the coordinate pair; in the "opposite-root" case the
ordering removes the remaining swap.

This is a genuine restricted uniqueness theorem, not a proof of the full open conjecture.
-/

namespace LeanFrontier.MarkovTree

private theorem abs_mul_sub_mul_lt_sq
    {x y u v c : ℤ}
    (hx : 0 < x) (hy : 0 < y) (hu : 0 < u) (hv : 0 < v)
    (hxc : x ≤ c) (hyc : y ≤ c) (huc : u ≤ c) (hvc : v ≤ c) :
    |x * y - u * v| < c ^ 2 := by
  have hc : 0 < c := lt_of_lt_of_le hx hxc
  have hxy_pos : 0 < x * y := mul_pos hx hy
  have huv_pos : 0 < u * v := mul_pos hu hv

  have hxy_le : x * y ≤ c ^ 2 := by
    have h₁ : 0 ≤ (c - x) * y :=
      mul_nonneg (sub_nonneg.mpr hxc) (le_of_lt hy)
    have h₂ : 0 ≤ c * (c - y) :=
      mul_nonneg (le_of_lt hc) (sub_nonneg.mpr hyc)
    nlinarith

  have huv_le : u * v ≤ c ^ 2 := by
    have h₁ : 0 ≤ (c - u) * v :=
      mul_nonneg (sub_nonneg.mpr huc) (le_of_lt hv)
    have h₂ : 0 ≤ c * (c - v) :=
      mul_nonneg (le_of_lt hc) (sub_nonneg.mpr hvc)
    nlinarith

  rw [abs_lt]
  constructor <;> nlinarith

private theorem positive_coprime_pair_eq_of_cross_mul_eq
    {u v u' v' : ℤ}
    (hu : 0 < u) (hv : 0 < v) (hu' : 0 < u') (hv' : 0 < v')
    (hcop : IsCoprime u v) (hcop' : IsCoprime u' v')
    (hcross : u * v' = u' * v) :
    u = u' ∧ v = v' := by
  have hu_dvd_u' : u ∣ u' := hcop.dvd_of_dvd_mul_right (by
    rw [← hcross]
    exact dvd_mul_right u v')
  have hu'_dvd_u : u' ∣ u := hcop'.dvd_of_dvd_mul_right (by
    rw [hcross]
    exact dvd_mul_right u' v)
  have huu' : u = u' := le_antisymm
    (Int.le_of_dvd hu' hu_dvd_u')
    (Int.le_of_dvd hu hu'_dvd_u)
  have hvv' : v = v' := by
    rw [huu'] at hcross
    exact (mul_left_cancel₀ hu'.ne' hcross).symm
  exact ⟨huu', hvv'⟩

/-- **Odd-prime-power case of Markov uniqueness.**

Let `(a₁,b₁,c)` and `(a₂,b₂,c)` be positive Markov triples ordered increasingly in their
first two coordinates and bounded above by the common coordinate `c`.  If
`c = p^k` for an odd prime `p` and `k > 0`, then the two triples are equal.

This is the odd-prime-power part of the classical partial uniqueness theorem proved by elementary
methods in the Markov-number literature. -/
theorem ordered_unique_of_common_odd_prime_power
    {a₁ b₁ a₂ b₂ c : ℤ} {p k : ℕ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (ha₁b₁ : a₁ ≤ b₁) (hb₁c : b₁ ≤ c)
    (ha₂b₂ : a₂ ≤ b₂) (hb₂c : b₂ ≤ c)
    (h₁ : MarkovEquation.IsSolution a₁ b₁ c)
    (h₂ : MarkovEquation.IsSolution a₂ b₂ c)
    (hp : p.Prime) (hp2 : p ≠ 2) (hk : 0 < k)
    (hc : c = (p : ℤ) ^ k) :
    a₁ = a₂ ∧ b₁ = b₂ := by
  have hcpos : 0 < c := lt_of_lt_of_le hb₁ hb₁c
  have ha₁c : a₁ ≤ c := le_trans ha₁b₁ hb₁c
  have ha₂c : a₂ ≤ c := le_trans ha₂b₂ hb₂c

  have hcop₁ :
      (State.mk a₁ b₁ c).PairwiseCoprime := by
    exact pairwiseCoprime_of_positive_solution
      (State.mk a₁ b₁ c) ha₁ hb₁ hcpos h₁
  have hcop₂ :
      (State.mk a₂ b₂ c).PairwiseCoprime := by
    exact pairwiseCoprime_of_positive_solution
      (State.mk a₂ b₂ c) ha₂ hb₂ hcpos h₂

  change
    IsCoprime a₁ b₁ ∧ IsCoprime a₁ c ∧ IsCoprime b₁ c
      at hcop₁
  change
    IsCoprime a₂ b₂ ∧ IsCoprime a₂ c ∧ IsCoprime b₂ c
      at hcop₂

  have hpkc : ((p : ℤ) ^ k) ∣ c := by
    rw [hc]

  have hsplit :=
    MarkovEquation.odd_prime_power_collision_factor_split
      h₁ h₂ hcop₁.2.1 hcop₂.2.1 hp hp2 hk hpkc

  rcases hsplit.1 with hsame | hcross
  · have hdiv :
        c ^ 2 ∣ (a₁ * a₂ - b₁ * b₂) := by
      simpa [hc] using hsame
    have hsmall :
        |a₁ * a₂ - b₁ * b₂| < c ^ 2 :=
      abs_mul_sub_mul_lt_sq
        ha₁ ha₂ hb₁ hb₂ ha₁c ha₂c hb₁c hb₂c
    have hzero :
        a₁ * a₂ - b₁ * b₂ = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdiv hsmall
    have heq : a₁ * a₂ = b₁ * b₂ :=
      sub_eq_zero.mp hzero
    have hswap :
        a₁ = b₂ ∧ b₁ = a₂ := by
      apply positive_coprime_pair_eq_of_cross_mul_eq
        ha₁ hb₁ hb₂ ha₂ hcop₁.1 hcop₂.1.symm
      simpa [mul_comm] using heq
    have ha₂b₂' : b₂ ≤ a₂ := by
      calc
        b₂ = a₁ := hswap.1.symm
        _ ≤ b₁ := ha₁b₁
        _ = a₂ := hswap.2
    have ha₂_eq_b₂ : a₂ = b₂ :=
      le_antisymm ha₂b₂ ha₂b₂'
    constructor
    · calc
        a₁ = b₂ := hswap.1
        _ = a₂ := ha₂_eq_b₂.symm
    · calc
        b₁ = a₂ := hswap.2
        _ = b₂ := ha₂_eq_b₂
  · have hdiv :
        c ^ 2 ∣ (a₁ * b₂ - b₁ * a₂) := by
      simpa [hc] using hcross
    have hsmall :
        |a₁ * b₂ - b₁ * a₂| < c ^ 2 :=
      abs_mul_sub_mul_lt_sq
        ha₁ hb₂ hb₁ ha₂ ha₁c hb₂c hb₁c ha₂c
    have hzero :
        a₁ * b₂ - b₁ * a₂ = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdiv hsmall
    have heq : a₁ * b₂ = a₂ * b₁ := by
      have := sub_eq_zero.mp hzero
      simpa [mul_comm] using this
    exact positive_coprime_pair_eq_of_cross_mul_eq
      ha₁ hb₁ ha₂ hb₂ hcop₁.1 hcop₂.1 heq

end LeanFrontier.MarkovTree
