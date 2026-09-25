import LeanFrontier.NumberTheory.MarkovTree.ModularRoot
import Mathlib.NumberTheory.SumTwoSquares

/-!
# ZMod form of the Markov modular-root invariant

The integer-congruence API proves that every oriented Markov number admits an integer
`r` with `r^2 ≡ -1` modulo the Markov number itself.

Many Mathlib arithmetic theorems consume the equivalent quotient-ring statement
`IsSquare (-1 : ZMod |M|)`.  This module is the thin bridge between those two interfaces.
-/

namespace LeanFrontier.MarkovTree

/-- The integer modular root attached to every oriented Markov number yields a square root of
`-1` in `ZMod |M|`. -/
theorem isSquare_neg_one_mod_markovNumber (n : OrientedNode) :
    IsSquare (-1 : ZMod n.markovNumber.natAbs) := by
  obtain ⟨r, hr⟩ := exists_sq_modEq_neg_one_markovNumber n
  refine ⟨(r : ZMod n.markovNumber.natAbs), ?_⟩
  have hr' :
      r ^ 2 ≡ -1 [ZMOD (n.markovNumber.natAbs : ℤ)] :=
    (Int.modEq_natAbs (n := n.markovNumber)).2 hr
  rw [← ZMod.intCast_eq_intCast_iff] at hr'
  simpa [Int.cast_pow, pow_two] using hr'.symm

end LeanFrontier.MarkovTree
