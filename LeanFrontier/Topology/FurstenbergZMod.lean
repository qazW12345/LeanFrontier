import LeanFrontier.Topology.Furstenberg
import Mathlib.Data.ZMod.Basic
import Mathlib.Topology.Order

/-!
# Finite quotient maps for the Furstenberg topology

The basic open sets of the Furstenberg topology are exactly congruence classes.  This module
connects that description to Mathlib's finite cyclic quotients.

For every natural modulus `n`, an arithmetic progression of step `n` is the fiber of the
canonical reduction map `ℤ → ZMod n`.  For nonzero `n`, those fibers are open in the
Furstenberg topology, so the reduction map is continuous when `ZMod n` carries its discrete
topology.

This is stated with explicit topology parameters.  In particular, importing the module does not
replace the ordinary topology instance on `ℤ`.
-/

namespace LeanFrontier.Int

open Set Topology TopologicalSpace

/-- An arithmetic progression with natural step `n` is exactly one fiber of reduction modulo
`n`.  This identity also handles `n = 0`: reduction into `ZMod 0` is equality on integers. -/
theorem arithProgression_eq_zmod_fiber (a : ℤ) (n : ℕ) :
    arithProgression a (n : ℤ) =
      (fun x : ℤ => (x : ZMod n)) ⁻¹' {(a : ZMod n)} := by
  ext x
  simp only [mem_arithProgression, mem_preimage, mem_singleton_iff]
  rw [eq_comm, ZMod.intCast_eq_intCast_iff_dvd_sub]

/-- For every nonzero modulus, reduction `ℤ → ZMod n` is continuous from the Furstenberg
topology to the discrete topology on the finite cyclic quotient. -/
theorem continuous_zmod_furstenberg (n : ℕ) (hn : n ≠ 0) :
    Continuous[furstenbergTopology, ⊥] (fun x : ℤ => (x : ZMod n)) := by
  letI : TopologicalSpace ℤ := furstenbergTopology
  letI : TopologicalSpace (ZMod n) := ⊥
  haveI : DiscreteTopology (ZMod n) := discreteTopology_bot _
  rw [continuous_discrete_rng]
  intro b
  rw [← ZMod.intCast_zmod_cast b]
  rw [← arithProgression_eq_zmod_fiber (ZMod.cast b) n]
  exact isOpen_arithProgression (ZMod.cast b) (n : ℤ) (Int.natCast_ne_zero.mpr hn)

end LeanFrontier.Int
