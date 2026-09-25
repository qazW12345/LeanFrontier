import LeanFrontier.NumberTheory.MarkovTree.QuadraticResidue
import Mathlib.Tactic

/-!
# Consequences of the Markov quadratic-residue invariant

Once `-1` is known to be a square modulo an oriented Markov-number label, several classical
arithmetic restrictions become immediate.

This module records three of them:

* every Markov-number label is a sum of two squares;
* every prime divisor is either `2` or congruent to `1 mod 4`;
* the label is never divisible by `4`.

The last point is especially cheap: if `4` divided the label, the square root of `-1` would
descend to `ZMod 4`, where no such square root exists.
-/

namespace LeanFrontier.MarkovTree

/-- The absolute value of every oriented Markov-number label is a sum of two natural squares. -/
theorem exists_markovNumber_natAbs_eq_sq_add_sq (n : OrientedNode) :
    ∃ x y : ℕ, n.markovNumber.natAbs = x ^ 2 + y ^ 2 :=
  Nat.eq_sq_add_sq_of_isSquare_mod_neg_one (isSquare_neg_one_mod_markovNumber n)

/-- Every prime divisor of an oriented Markov-number label is either `2` or `1 mod 4`. -/
theorem prime_dvd_markovNumber_eq_two_or_mod_four_eq_one
    (n : OrientedNode) {p : ℕ}
    (hp : p.Prime) (hd : p ∣ n.markovNumber.natAbs) :
    p = 2 ∨ p % 4 = 1 := by
  rcases hp.eq_two_or_odd with htwo | hodd
  · exact Or.inl htwo
  · right
    have hne := prime_dvd_markovNumber_mod_four_ne_three n hp hd
    omega

/-- The absolute value of an oriented Markov-number label is not divisible by `4`. -/
theorem four_not_dvd_markovNumber_natAbs (n : OrientedNode) :
    ¬ 4 ∣ n.markovNumber.natAbs := by
  intro hfour
  have hs : IsSquare (-1 : ZMod 4) :=
    ZMod.isSquare_neg_one_of_dvd hfour (isSquare_neg_one_mod_markovNumber n)
  have hnot : ¬ IsSquare (-1 : ZMod 4) := by
    decide
  exact hnot hs

end LeanFrontier.MarkovTree
