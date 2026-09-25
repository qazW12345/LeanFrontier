import LeanFrontier.NumberTheory.MarkovTree.CoordinateRoot
import Mathlib.Data.ZMod.ValMinAbs
import Mathlib.Tactic

/-!
# Canonical integer index of an oriented Markov node

The coordinate-defined modular root attached to an oriented Markov node is naturally determined
only up to sign when one forgets the ordering of the two complementary coordinates.  Classical
work on Markov numbers packages this information as an integer index chosen in a half interval.

Mathlib's `ZMod.valMinAbs` provides exactly the required canonical representative.  We define
`markovIndex` as the absolute value of that centered representative.  It lies in
`[0, |M|/2]`, still represents one of the two signs of the coordinate root, and therefore
squares to `-1` modulo the Markov number.

This is the Lean bridge from the orientation-sensitive `coordinateRoot` to the unsigned
Frobenius/Zhang/Springborn-style Markov index used in classical uniqueness arguments.
-/

namespace LeanFrontier.MarkovTree

/-- The canonical unsigned integer representative of the coordinate-defined square root of
`-1` modulo the Markov number. -/
def OrientedNode.markovIndex (n : OrientedNode) : ℕ :=
  n.coordinateRoot.valMinAbs.natAbs

private theorem markovNumber_natAbs_ne_zero (n : OrientedNode) :
    n.markovNumber.natAbs ≠ 0 := by
  exact Int.natAbs_ne_zero.mpr (markovNumber_pos n).ne'

/-- The canonical Markov index lies in the standard half interval. -/
theorem markovIndex_le_half (n : OrientedNode) :
    n.markovIndex ≤ n.markovNumber.natAbs / 2 := by
  letI : NeZero n.markovNumber.natAbs :=
    ⟨markovNumber_natAbs_ne_zero n⟩
  exact ZMod.natAbs_valMinAbs_le n.coordinateRoot

/-- Casting the canonical unsigned index back modulo the Markov number recovers either the
coordinate root or its negative. -/
theorem markovIndex_cast_eq_coordinateRoot_or_neg (n : OrientedNode) :
    (n.markovIndex : ZMod n.markovNumber.natAbs) = n.coordinateRoot ∨
      (n.markovIndex : ZMod n.markovNumber.natAbs) = -n.coordinateRoot := by
  letI : NeZero n.markovNumber.natAbs :=
    ⟨markovNumber_natAbs_ne_zero n⟩
  rw [OrientedNode.markovIndex, ZMod.natCast_natAbs_valMinAbs]
  split_ifs <;> simp

/-- The canonical integer index is still a square root of `-1` after reduction modulo the
Markov number. -/
theorem markovIndex_sq (n : OrientedNode) :
    (n.markovIndex : ZMod n.markovNumber.natAbs) ^ 2 = -1 := by
  rcases markovIndex_cast_eq_coordinateRoot_or_neg n with h | h
  · rw [h]
    exact coordinateRoot_sq n
  · rw [h]
    calc
      (-n.coordinateRoot) ^ 2 = n.coordinateRoot ^ 2 := by ring
      _ = -1 := coordinateRoot_sq n

end LeanFrontier.MarkovTree
