import LeanFrontier.NumberTheory.MarkovTree.ChildLabels
import LeanFrontier.NumberTheory.MarkovTree.Coprime
import Mathlib.NumberTheory.SumTwoSquares
import Mathlib.Tactic

/-!
# Quadratic residues attached to oriented Markov nodes

For an oriented positive Markov node, let `M` be its distinguished Markov-number coordinate and
let `u,v` be the two non-back coordinates.  The Markov equation, read as a quadratic in `M`,
gives

`M * M' = u^2 + v^2`

for the descending Vieta companion `M'`.  Pairwise coprimality of positive Markov triples makes
`u,v` a primitive pair.

Consequently `-1` is a square modulo `|M|`: the primitive sum of two squares
`u^2 + v^2` is divisible by `M`, and the standard sum-of-two-squares modular lemma descends
the resulting square root from `|u^2+v^2|` to `|M|`.

This packages a classical arithmetic invariant of Markov numbers in the oriented-tree API.  It
does not assert uniqueness of a Markov triple from its maximum coordinate.
-/

namespace LeanFrontier.MarkovTree

/-- The two non-back coordinates of an oriented Markov node are coprime. -/
theorem forwardCoordinates_isCoprime (n : OrientedNode) :
    IsCoprime (n.forwardCoordinate false) (n.forwardCoordinate true) := by
  have hcop := n.pairwiseCoprime
  rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
  change IsCoprime x y ∧ IsCoprime x z ∧ IsCoprime y z at hcop
  cases back with
  | first =>
      simpa [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] using hcop.2.2
  | second =>
      simpa [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] using hcop.2.1
  | third =>
      simpa [OrientedNode.forwardCoordinate, forwardMove, State.coordinate] using hcop.1

/-- Either non-back coordinate is coprime to the Markov-number coordinate. -/
theorem forwardCoordinate_isCoprime_markovNumber
    (n : OrientedNode) (dir : Bool) :
    IsCoprime (n.forwardCoordinate dir) n.markovNumber := by
  have hcop := n.pairwiseCoprime
  rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
  change IsCoprime x y ∧ IsCoprime x z ∧ IsCoprime y z at hcop
  cases back with
  | first =>
      cases dir with
      | false =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.1.symm
      | true =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.2.1.symm
  | second =>
      cases dir with
      | false =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.1
      | true =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.2.2.symm
  | third =>
      cases dir with
      | false =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.2.1
      | true =>
          simpa [OrientedNode.forwardCoordinate, OrientedNode.markovNumber,
            forwardMove, State.coordinate] using hcop.2.2

/-- The Markov-number coordinate divides the sum of the squares of the two non-back coordinates.

This is Vieta's product relation for the back coordinate, rewritten in the oriented-node API. -/
theorem markovNumber_dvd_forwardCoordinate_sq_add_sq (n : OrientedNode) :
    n.markovNumber ∣
      n.forwardCoordinate false ^ 2 + n.forwardCoordinate true ^ 2 := by
  rcases n with ⟨⟨x, y, z⟩, back, hpos, hsol, hdesc⟩
  change MarkovEquation.IsSolution x y z at hsol
  cases back with
  | first =>
      have hperm : MarkovEquation.IsSolution y z x := by
        unfold MarkovEquation.IsSolution at hsol ⊢
        nlinarith
      refine ⟨MarkovEquation.jump y z x, ?_⟩
      have h := MarkovEquation.mul_jump_eq hperm
      simpa [OrientedNode.markovNumber, OrientedNode.forwardCoordinate,
        State.coordinate, forwardMove] using h.symm
  | second =>
      have hperm : MarkovEquation.IsSolution x z y := by
        unfold MarkovEquation.IsSolution at hsol ⊢
        nlinarith
      refine ⟨MarkovEquation.jump x z y, ?_⟩
      have h := MarkovEquation.mul_jump_eq hperm
      simpa [OrientedNode.markovNumber, OrientedNode.forwardCoordinate,
        State.coordinate, forwardMove] using h.symm
  | third =>
      refine ⟨MarkovEquation.jump x y z, ?_⟩
      have h := MarkovEquation.mul_jump_eq hsol
      simpa [OrientedNode.markovNumber, OrientedNode.forwardCoordinate,
        State.coordinate, forwardMove] using h.symm

/-- Every oriented Markov-number label carries a square root of `-1` modulo its absolute value.

The two non-back coordinates form a primitive sum of two squares divisible by the label.  Mathlib's
sum-of-two-squares modular theorem gives a square root of `-1` modulo the full sum, and divisibility
then transports it to the Markov-number modulus. -/
theorem isSquare_neg_one_mod_markovNumber (n : OrientedNode) :
    IsSquare (-1 : ZMod n.markovNumber.natAbs) := by
  let u : ℤ := n.forwardCoordinate false
  let v : ℤ := n.forwardCoordinate true
  have hcop : IsCoprime u v := by
    simpa [u, v] using forwardCoordinates_isCoprime n
  have hs :
      IsSquare (-1 : ZMod (u ^ 2 + v ^ 2).natAbs) :=
    ZMod.isSquare_neg_one_of_eq_sq_add_sq_of_isCoprime rfl hcop
  have hdiv : n.markovNumber ∣ u ^ 2 + v ^ 2 := by
    simpa [u, v] using markovNumber_dvd_forwardCoordinate_sq_add_sq n
  have hdNat :
      n.markovNumber.natAbs ∣ (u ^ 2 + v ^ 2).natAbs := by
    rcases hdiv with ⟨k, hk⟩
    rw [hk, Int.natAbs_mul]
    exact dvd_mul_right _ _
  exact ZMod.isSquare_neg_one_of_dvd hdNat hs

/-- No prime divisor of an oriented Markov-number label is congruent to three modulo four.

This is the standard prime-factor consequence of the square root of `-1` modulo the label. -/
theorem prime_dvd_markovNumber_mod_four_ne_three
    (n : OrientedNode) {p : ℕ}
    (hp : p.Prime) (hd : p ∣ n.markovNumber.natAbs) :
    p % 4 ≠ 3 := by
  have hnonzero : n.markovNumber.natAbs ≠ 0 :=
    Int.natAbs_ne_zero.mpr (ne_of_gt (markovNumber_pos n))
  have hmem : p ∈ n.markovNumber.natAbs.primeFactors :=
    Nat.mem_primeFactors.mpr ⟨hp, hd, hnonzero⟩
  exact Nat.mod_four_ne_three_of_mem_primeFactors_of_isSquare_neg_one
    hmem (isSquare_neg_one_mod_markovNumber n)

end LeanFrontier.MarkovTree
