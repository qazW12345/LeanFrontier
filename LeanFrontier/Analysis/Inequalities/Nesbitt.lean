import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic

/-!
# Nesbitt's inequality and its sum-of-squares certificate

For positive real numbers `a,b,c`, Nesbitt's classical inequality says
`3/2 ≤ a/(b+c) + b/(c+a) + c/(a+b)`.

We expose the exact cubic sum-of-squares defect underlying the inequality.
This algebraic certificate is stronger than a direct application of a
three-variable inequality, and allows equality to be investigated by its
nonnegative summands.
-/

namespace LeanFrontier.Inequalities

/-- The exact sum-of-squares certificate for Nesbitt's inequality.

Multiplying the deficit by the positive product of the three denominators
gives a sum of three squared differences with nonnegative weights. -/
theorem nesbitt_defect_identity
    (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    (2 * (a / (b + c) + b / (c + a) + c / (a + b)) - 3) *
        ((a + b) * (b + c) * (c + a)) =
      (a - b) ^ 2 * (a + b) +
        (b - c) ^ 2 * (b + c) +
        (c - a) ^ 2 * (c + a) := by
  have hab : a + b ≠ 0 := ne_of_gt (add_pos ha hb)
  have hbc : b + c ≠ 0 := ne_of_gt (add_pos hb hc)
  have hca : c + a ≠ 0 := ne_of_gt (add_pos hc ha)
  field_simp
  <;> ring

/-- **Nesbitt's inequality.** The cyclic sum of each positive variable
divided by the sum of the other two is at least three halves. -/
theorem nesbitt_inequality
    (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    (3 : ℝ) / 2 ≤ a / (b + c) + b / (c + a) + c / (a + b) := by
  let d : ℝ := (a + b) * (b + c) * (c + a)
  have hd : 0 < d := by
    dsimp [d]
    positivity
  have hcertificate := nesbitt_defect_identity a b c ha hb hc
  have hsos : 0 ≤
      (a - b) ^ 2 * (a + b) +
      (b - c) ^ 2 * (b + c) +
      (c - a) ^ 2 * (c + a) := by
    positivity
  have hnonneg :
      0 ≤ 2 * (a / (b + c) + b / (c + a) + c / (a + b)) - 3 := by
    by_contra hn
    have hn' : 2 * (a / (b + c) + b / (c + a) + c / (a + b)) - 3 < 0 :=
      lt_of_not_ge hn
    have hnegative :
        (2 * (a / (b + c) + b / (c + a) + c / (a + b)) - 3) * d < 0 :=
      mul_neg_of_neg_of_pos hn' hd
    dsimp [d] at hnegative
    rw [hcertificate] at hnegative
    exact (not_lt_of_ge hsos) hnegative
  linarith

end LeanFrontier.Inequalities
