import LeanFrontier.NumberTheory.CyclotomicEightGalois
import LeanFrontier.NumberTheory.CyclotomicEightGaussian
import Mathlib.Algebra.Module.ZMod
import Mathlib.FieldTheory.Finiteness
import Mathlib.GroupTheory.Index
import Mathlib.LinearAlgebra.Projectivization.Cardinality
import Mathlib.Tactic

/-!
# The three quadratic intermediate fields of the eighth cyclotomic field

The accepted structural pieces now give two complementary descriptions of
`ℚ(ζ₈)/ℚ`:

* its Galois group is Klein four;
* the three classical quadratic directions `√2`, `√-2`, and `i` are available
  internally.

This module proves the global counting statement: the extension has exactly three
quadratic intermediate fields.

The proof is structural. Galois correspondence identifies quadratic intermediate
fields with index-two subgroups of the Galois group. The accepted Klein-four
equivalence transports those subgroups to `Multiplicative (𝔽₂²)`. Reinterpreting
them additively turns index-two subgroups into one-dimensional `𝔽₂`-subspaces.
Those are precisely the points of the projective line `ℙ(𝔽₂²)`, whose cardinality
is `2 + 1 = 3` by Mathlib's projectivization cardinality theorem.
-/

namespace LeanFrontier.NumberTheory.DiscriminantTower

open NumberField
open scoped LinearAlgebra.Projectivization

noncomputable section

local instance : NeZero (8 : ℕ) := ⟨by decide⟩

local instance cyclotomicEight_isCyclotomic_classification :
    IsCyclotomicExtension {8} ℚ CyclotomicEight :=
  CyclotomicField.isCyclotomicExtension 8 ℚ

private abbrev GalEight := Gal(CyclotomicEight/ℚ)
private abbrev KleinFourModel := Multiplicative (ZMod 2 × ZMod 2)
private abbrev F2Plane := ZMod 2 × ZMod 2

/-- The type of quadratic intermediate fields of `ℚ(ζ₈)/ℚ`. -/
def CyclotomicEightQuadraticFields :=
  {K : IntermediateField ℚ CyclotomicEight // Module.finrank ℚ K = 2}

private def IndexTwoSubgroups (G : Type*) [Group G] :=
  {H : Subgroup G // H.index = 2}

private def OneDimensionalF2Subspaces :=
  {S : Submodule (ZMod 2) F2Plane // Module.finrank (ZMod 2) S = 1}

private noncomputable def quadraticFieldsEquivIndexTwoGal :
    CyclotomicEightQuadraticFields ≃ IndexTwoSubgroups GalEight where
  toFun K :=
    ⟨K.1.fixingSubgroup, by
      rw [← IntermediateField.finrank_eq_fixingSubgroup_index K.1]
      exact K.2⟩
  invFun H :=
    ⟨(IsGalois.intermediateFieldEquivSubgroup :
        IntermediateField ℚ CyclotomicEight ≃o (Subgroup GalEight)ᵒᵈ).symm
          (OrderDual.toDual H.1), by
      rw [IntermediateField.finrank_eq_fixingSubgroup_index]
      change H.1.index = 2
      exact H.2⟩
  left_inv K := by
    apply Subtype.ext
    exact (IsGalois.intermediateFieldEquivSubgroup :
      IntermediateField ℚ CyclotomicEight ≃o (Subgroup GalEight)ᵒᵈ).symm_apply_apply K.1
  right_inv H := by
    apply Subtype.ext
    exact (IsGalois.intermediateFieldEquivSubgroup :
      IntermediateField ℚ CyclotomicEight ≃o (Subgroup GalEight)ᵒᵈ).apply_symm_apply
        (OrderDual.toDual H.1)

private noncomputable def galIndexTwoEquivKleinIndexTwo :
    IndexTwoSubgroups GalEight ≃ IndexTwoSubgroups KleinFourModel :=
  Equiv.subtypeEquiv cyclotomicEightGalEquivKleinFour.mapSubgroup.toEquiv fun H => by
    change
      (Subgroup.map (cyclotomicEightGalEquivKleinFour : GalEight →* KleinFourModel) H).index = 2 ↔
        H.index = 2
    rw [Subgroup.index_map_equiv]

private noncomputable def kleinSubgroupToF2Subspace :
    Subgroup KleinFourModel ≃o Submodule (ZMod 2) F2Plane :=
  Subgroup.toAddSubgroup'.trans (AddSubgroup.toZModSubmodule 2)

private theorem card_kleinSubgroup_eq_card_subspace (H : Subgroup KleinFourModel) :
    Nat.card H = Nat.card (kleinSubgroupToF2Subspace H) := by
  let e : H ≃ (kleinSubgroupToF2Subspace H) :=
    Equiv.subtypeEquiv Multiplicative.ofAdd.symm (fun x => by rfl)
  exact Nat.card_congr e

private theorem klein_index_two_iff_finrank_one (H : Subgroup KleinFourModel) :
    H.index = 2 ↔ Module.finrank (ZMod 2) (kleinSubgroupToF2Subspace H) = 1 := by
  let S := kleinSubgroupToF2Subspace H
  have hamb : Nat.card KleinFourModel = 4 := by decide
  have hcard : Nat.card H = Nat.card S := card_kleinSubgroup_eq_card_subspace H
  have hpow : Nat.card S = 2 ^ Module.finrank (ZMod 2) S := by
    rw [Module.natCard_eq_pow_finrank (K := ZMod 2), Nat.card_zmod]
  constructor
  · intro hindex
    have hmul := H.index_mul_card
    rw [hindex, hamb] at hmul
    have hHcard : Nat.card H = 2 := by omega
    have hpowe : 2 ^ Module.finrank (ZMod 2) S = 2 ^ 1 := by
      rw [← hpow, ← hcard, hHcard]
      norm_num
    exact Nat.pow_right_injective (by omega) hpowe
  · intro hfinrank
    have hScard : Nat.card S = 2 := by
      rw [hpow, hfinrank]
      norm_num
    have hHcard : Nat.card H = 2 := hcard.trans hScard
    have hmul := H.index_mul_card
    rw [hHcard, hamb] at hmul
    omega

private noncomputable def kleinIndexTwoEquivOneDimensional :
    IndexTwoSubgroups KleinFourModel ≃ OneDimensionalF2Subspaces :=
  Equiv.subtypeEquiv kleinSubgroupToF2Subspace.toEquiv
    klein_index_two_iff_finrank_one

private noncomputable def quadraticFieldsEquivProjectiveLine :
    CyclotomicEightQuadraticFields ≃ ℙ (ZMod 2) F2Plane :=
  quadraticFieldsEquivIndexTwoGal.trans <|
    galIndexTwoEquivKleinIndexTwo.trans <|
      kleinIndexTwoEquivOneDimensional.trans <|
        Projectivization.equivSubmodule.symm

/-- The eighth cyclotomic field has exactly three quadratic intermediate fields. -/
theorem cyclotomicEight_quadraticFields_card :
    Nat.card CyclotomicEightQuadraticFields = 3 := by
  rw [Nat.card_congr quadraticFieldsEquivProjectiveLine]
  have hdim : Module.finrank (ZMod 2) F2Plane = 2 := by simp
  rw [Projectivization.card_of_finrank_two (ZMod 2) F2Plane hdim, Nat.card_zmod]
  norm_num

end

end LeanFrontier.NumberTheory.DiscriminantTower
