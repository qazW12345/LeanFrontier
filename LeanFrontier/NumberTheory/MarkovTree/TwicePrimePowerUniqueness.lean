import LeanFrontier.NumberTheory.MarkovTree.PrimePowerUniqueness
import LeanFrontier.NumberTheory.MarkovTree.ModFour
import Mathlib.Tactic

/-!
# Uniqueness for twice an odd prime power

This module extends the odd-prime-power Markov uniqueness theorem to the second classical
elementary family: a common maximum coordinate of the form `2 * p^k`, where `p` is an odd
prime and `k > 0`.

The prime-power collision split supplies divisibility by `p^(2k)` of one collision factor.
The modulo-four pattern of positive Markov triples shows that, when the common coordinate is even,
all four complementary coordinates are `1 mod 4`; hence both collision factors are divisible by
four.  Since `p^(2k)` is odd, the selected collision factor is divisible by the full square of
the common coordinate.  Its absolute value is strictly smaller than that square, so it vanishes,
and primitive-pair rigidity finishes the argument.

This is a classical restricted case, not a proof of the full Frobenius/Markov uniqueness
conjecture.
-/

namespace LeanFrontier.MarkovTree

private theorem twicePrimePower_abs_mul_sub_mul_lt_sq
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

private theorem twicePrimePower_positive_coprime_pair_eq_of_cross_mul_eq
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

/-- **Twice-an-odd-prime-power case of Markov uniqueness.**

Let `(a₁,b₁,c)` and `(a₂,b₂,c)` be positive Markov triples with
`aᵢ ≤ bᵢ ≤ c`.  If `c = 2 * p^k` for an odd prime `p` and `k > 0`, then the two
triples are equal. -/
theorem ordered_unique_of_common_twice_odd_prime_power
    {a₁ b₁ a₂ b₂ c : ℤ} {p k : ℕ}
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁)
    (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (ha₁b₁ : a₁ ≤ b₁) (hb₁c : b₁ ≤ c)
    (ha₂b₂ : a₂ ≤ b₂) (hb₂c : b₂ ≤ c)
    (h₁ : MarkovEquation.IsSolution a₁ b₁ c)
    (h₂ : MarkovEquation.IsSolution a₂ b₂ c)
    (hp : p.Prime) (hp2 : p ≠ 2) (hk : 0 < k)
    (hc : c = 2 * (p : ℤ) ^ k) :
    a₁ = a₂ ∧ b₁ = b₂ := by
  have hcpos : 0 < c := lt_of_lt_of_le hb₁ hb₁c
  have ha₁c : a₁ ≤ c := le_trans ha₁b₁ hb₁c
  have ha₂c : a₂ ≤ c := le_trans ha₂b₂ hb₂c

  have hcop₁ :
      (State.mk a₁ b₁ c).PairwiseCoprime :=
    pairwiseCoprime_of_positive_solution
      (State.mk a₁ b₁ c) ha₁ hb₁ hcpos h₁
  have hcop₂ :
      (State.mk a₂ b₂ c).PairwiseCoprime :=
    pairwiseCoprime_of_positive_solution
      (State.mk a₂ b₂ c) ha₂ hb₂ hcpos h₂

  change
    IsCoprime a₁ b₁ ∧ IsCoprime a₁ c ∧ IsCoprime b₁ c
      at hcop₁
  change
    IsCoprime a₂ b₂ ∧ IsCoprime a₂ c ∧ IsCoprime b₂ c
      at hcop₂

  have hpkc : ((p : ℤ) ^ k) ∣ c := by
    refine ⟨2, ?_⟩
    simpa [mul_comm] using hc

  have hsplit :=
    MarkovEquation.odd_prime_power_collision_factor_split
      h₁ h₂ hcop₁.2.1 hcop₂.2.1 hp hp2 hk hpkc

  have heven : (2 : ℤ) ∣ c := by
    refine ⟨(p : ℤ) ^ k, ?_⟩
    exact hc

  have hmod₁ :=
    modFour_of_even_third_coordinate ha₁ hb₁ hcpos h₁ heven
  have hmod₂ :=
    modFour_of_even_third_coordinate ha₂ hb₂ hcpos h₂ heven

  have hfourSame : (4 : ℤ) ∣ a₁ * a₂ - b₁ * b₂ := by
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hmod₁.1, hmod₂.1, hmod₁.2.1, hmod₂.2.1]
    norm_num

  have hfourCross : (4 : ℤ) ∣ a₁ * b₂ - b₁ * a₂ := by
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hmod₁.1, hmod₂.2.1, hmod₁.2.1, hmod₂.1]
    norm_num

  have hpOddNat : Odd p := (hp.eq_two_or_odd.resolve_left hp2)
  have hpOddInt : Odd (p : ℤ) := by
    exact_mod_cast hpOddNat
  have hpowOdd : Odd (((p : ℤ) ^ k) ^ 2) :=
    hpOddInt.pow.pow
  have hcopTwo : IsCoprime (2 : ℤ) (((p : ℤ) ^ k) ^ 2) := by
    rw [Int.isCoprime_two_left]
    exact hpowOdd
  have hcopFour : IsCoprime (4 : ℤ) (((p : ℤ) ^ k) ^ 2) := by
    simpa using (hcopTwo.pow_left (m := 2))

  rcases hsplit.1 with hsame | hcross
  · have hfullRaw :
        (4 : ℤ) * (((p : ℤ) ^ k) ^ 2) ∣
          (a₁ * a₂ - b₁ * b₂) :=
      hcopFour.mul_dvd hfourSame hsame
    have hdiv :
        c ^ 2 ∣ (a₁ * a₂ - b₁ * b₂) := by
      rw [hc]
      convert hfullRaw using 1 <;> ring
    have hsmall :
        |a₁ * a₂ - b₁ * b₂| < c ^ 2 :=
      twicePrimePower_abs_mul_sub_mul_lt_sq
        ha₁ ha₂ hb₁ hb₂ ha₁c ha₂c hb₁c hb₂c
    have hzero :
        a₁ * a₂ - b₁ * b₂ = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdiv hsmall
    have heq : a₁ * a₂ = b₁ * b₂ :=
      sub_eq_zero.mp hzero
    have hswap :
        a₁ = b₂ ∧ b₁ = a₂ := by
      apply twicePrimePower_positive_coprime_pair_eq_of_cross_mul_eq
        ha₁ hb₁ hb₂ ha₂ hcop₁.1 hcop₂.1.symm
      simpa [mul_comm] using heq
    have hb₂_le_a₂ : b₂ ≤ a₂ := by
      calc
        b₂ = a₁ := hswap.1.symm
        _ ≤ b₁ := ha₁b₁
        _ = a₂ := hswap.2
    have ha₂_eq_b₂ : a₂ = b₂ :=
      le_antisymm ha₂b₂ hb₂_le_a₂
    constructor
    · calc
        a₁ = b₂ := hswap.1
        _ = a₂ := ha₂_eq_b₂.symm
    · calc
        b₁ = a₂ := hswap.2
        _ = b₂ := ha₂_eq_b₂
  · have hfullRaw :
        (4 : ℤ) * (((p : ℤ) ^ k) ^ 2) ∣
          (a₁ * b₂ - b₁ * a₂) :=
      hcopFour.mul_dvd hfourCross hcross
    have hdiv :
        c ^ 2 ∣ (a₁ * b₂ - b₁ * a₂) := by
      rw [hc]
      convert hfullRaw using 1 <;> ring
    have hsmall :
        |a₁ * b₂ - b₁ * a₂| < c ^ 2 :=
      twicePrimePower_abs_mul_sub_mul_lt_sq
        ha₁ hb₂ hb₁ ha₂ ha₁c hb₂c hb₁c ha₂c
    have hzero :
        a₁ * b₂ - b₁ * a₂ = 0 :=
      Int.eq_zero_of_abs_lt_dvd hdiv hsmall
    have heq : a₁ * b₂ = a₂ * b₁ := by
      have h := sub_eq_zero.mp hzero
      simpa [mul_comm] using h
    exact twicePrimePower_positive_coprime_pair_eq_of_cross_mul_eq
      ha₁ hb₁ ha₂ hb₂ hcop₁.1 hcop₂.1 heq

end LeanFrontier.MarkovTree
