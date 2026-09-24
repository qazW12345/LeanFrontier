import LeanFrontier.NumberTheory.DiscriminantTower
import Mathlib.NumberTheory.NumberField.Cyclotomic.Basic
import Mathlib.FieldTheory.LinearDisjoint
import Mathlib.FieldTheory.Minpoly.IsIntegrallyClosed
import Mathlib.RingTheory.Polynomial.Eisenstein.IsIntegral
import Mathlib.Tactic

/-!
# The explicit quadratic tower inside the eighth cyclotomic field

This file constructs the intended witness for
`LeanFrontier.NumberTheory.DiscriminantTower.CoprimalityIsLoadBearing`.

Let `ζ` be a primitive eighth root of unity.  The two elements

* `u = ζ + ζ^7`,
* `v = ζ - ζ^7`

satisfy `u^2 = 2` and `v^2 = -2`.  Their generated intermediate fields are therefore
the two quadratic subfields corresponding to `ℚ(√2)` and `ℚ(√-2)`.

The first layer below records the explicit field-theoretic structure: both subfields have degree
two, their supremum is the full eighth cyclotomic field, and hence they are linearly disjoint.
The discriminant computation is developed on top of this structure.
-/

namespace LeanFrontier.NumberTheory.DiscriminantTower

open scoped IntermediateField
open Polynomial IntermediateField NumberField

noncomputable section

set_option linter.defProp false
set_option warn.classDefReducibility false

abbrev CyclotomicEight := CyclotomicField 8 ℚ

local instance cyclotomicEight_isCyclotomic :
    IsCyclotomicExtension {8} ℚ CyclotomicEight :=
  CyclotomicField.isCyclotomicExtension 8 ℚ

noncomputable def zetaEight : CyclotomicEight :=
  IsCyclotomicExtension.zeta 8 ℚ CyclotomicEight

private def zetaEight_spec : IsPrimitiveRoot zetaEight 8 := by
  exact IsCyclotomicExtension.zeta_spec 8 ℚ CyclotomicEight

private def zetaEight_pow_eight : zetaEight ^ 8 = 1 :=
  zetaEight_spec.pow_eq_one

private def zetaEight_pow_four : zetaEight ^ 4 = -1 := by
  have hsq : (zetaEight ^ 4) ^ 2 = 1 := by
    rw [← pow_mul]
    norm_num
    exact zetaEight_pow_eight
  exact (sq_eq_one_iff.mp hsq).resolve_left <|
    zetaEight_spec.pow_ne_one_of_pos_of_lt (by decide) (by decide)

noncomputable def sqrtTwoGen : CyclotomicEight :=
  zetaEight + zetaEight ^ 7

noncomputable def sqrtNegTwoGen : CyclotomicEight :=
  zetaEight - zetaEight ^ 7

private def zetaEight_pow_six : zetaEight ^ 6 = -(zetaEight ^ 2) := by
  calc
    zetaEight ^ 6 = zetaEight ^ 2 * zetaEight ^ 4 := by ring
    _ = -(zetaEight ^ 2) := by rw [zetaEight_pow_four]; ring

private def zetaEight_pow_fourteen : zetaEight ^ 14 = zetaEight ^ 6 := by
  calc
    zetaEight ^ 14 = zetaEight ^ 6 * zetaEight ^ 8 := by ring
    _ = zetaEight ^ 6 := by rw [zetaEight_pow_eight, mul_one]

theorem sqrtTwoGen_sq : sqrtTwoGen ^ 2 = (2 : CyclotomicEight) := by
  rw [sqrtTwoGen]
  calc
    (zetaEight + zetaEight ^ 7) ^ 2 =
        zetaEight ^ 2 + 2 * zetaEight ^ 8 + zetaEight ^ 14 := by ring
    _ = 2 := by
      rw [zetaEight_pow_eight, zetaEight_pow_fourteen, zetaEight_pow_six]
      ring

theorem sqrtNegTwoGen_sq : sqrtNegTwoGen ^ 2 = (-2 : CyclotomicEight) := by
  rw [sqrtNegTwoGen]
  calc
    (zetaEight - zetaEight ^ 7) ^ 2 =
        zetaEight ^ 2 - 2 * zetaEight ^ 8 + zetaEight ^ 14 := by ring
    _ = -2 := by
      rw [zetaEight_pow_eight, zetaEight_pow_fourteen, zetaEight_pow_six]
      ring

noncomputable def sqrtTwoField : IntermediateField ℚ CyclotomicEight :=
  ℚ⟮sqrtTwoGen⟯

noncomputable def sqrtNegTwoField : IntermediateField ℚ CyclotomicEight :=
  ℚ⟮sqrtNegTwoGen⟯

private def quadPlusZ : ℤ[X] := X ^ 2 - C 2
private def quadMinusZ : ℤ[X] := X ^ 2 - C (-2)
private def quadPlusQ : ℚ[X] := X ^ 2 - C 2
private def quadMinusQ : ℚ[X] := X ^ 2 - C (-2)

private def spanTwo : Ideal ℤ := Ideal.span ({(2 : ℤ)} : Set ℤ)

private def spanTwo_prime : spanTwo.IsPrime := by
  rw [spanTwo, Ideal.span_singleton_prime (by norm_num : (2 : ℤ) ≠ 0),
    Int.prime_iff_natAbs_prime]
  norm_num

private def quadPlusZ_monic : quadPlusZ.Monic := by
  rw [quadPlusZ]
  exact monic_X_pow_sub_C (2 : ℤ) (by decide)

private def quadMinusZ_monic : quadMinusZ.Monic := by
  rw [quadMinusZ]
  exact monic_X_pow_sub_C (-2 : ℤ) (by decide)

private def quadPlusZ_eisenstein : quadPlusZ.IsEisensteinAt spanTwo := by
  apply quadPlusZ_monic.isEisensteinAt_of_mem_of_notMem
  · exact spanTwo_prime.ne_top
  · intro n hn
    have hn2 : n < 2 := by
      rw [quadPlusZ, natDegree_X_pow_sub_C] at hn
      exact hn
    interval_cases n <;>
      simp [quadPlusZ, spanTwo]
  · have hcoeff : quadPlusZ.coeff 0 = (-2 : ℤ) := by
      simp [quadPlusZ]
    rw [hcoeff, spanTwo, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    norm_num

private def quadMinusZ_eisenstein : quadMinusZ.IsEisensteinAt spanTwo := by
  apply quadMinusZ_monic.isEisensteinAt_of_mem_of_notMem
  · exact spanTwo_prime.ne_top
  · intro n hn
    have hn2 : n < 2 := by
      rw [quadMinusZ, natDegree_X_pow_sub_C] at hn
      exact hn
    interval_cases n <;>
      simp [quadMinusZ, spanTwo]
  · have hcoeff : quadMinusZ.coeff 0 = (2 : ℤ) := by
      simp [quadMinusZ]
    rw [hcoeff, spanTwo, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    norm_num

private def quadPlusZ_irreducible : Irreducible quadPlusZ :=
  quadPlusZ_eisenstein.irreducible spanTwo_prime
    quadPlusZ_monic.isPrimitive
    (by rw [quadPlusZ, natDegree_X_pow_sub_C]; norm_num)

private def quadMinusZ_irreducible : Irreducible quadMinusZ :=
  quadMinusZ_eisenstein.irreducible spanTwo_prime
    quadMinusZ_monic.isPrimitive
    (by rw [quadMinusZ, natDegree_X_pow_sub_C]; norm_num)

private def quadPlusQ_irreducible : Irreducible quadPlusQ := by
  have h :=
    (Polynomial.IsPrimitive.Int.irreducible_iff_irreducible_map_cast
      quadPlusZ_monic.isPrimitive).mp
      quadPlusZ_irreducible
  have hmap : Polynomial.map (Int.castRingHom ℚ) quadPlusZ = quadPlusQ := by
    rw [quadPlusZ, quadPlusQ, Polynomial.map_sub, Polynomial.map_pow]
    simp [Polynomial.C_ofNat]
  rw [← hmap]
  exact h

private def quadMinusQ_irreducible : Irreducible quadMinusQ := by
  have h :=
    (Polynomial.IsPrimitive.Int.irreducible_iff_irreducible_map_cast
      quadMinusZ_monic.isPrimitive).mp
      quadMinusZ_irreducible
  have hmap : Polynomial.map (Int.castRingHom ℚ) quadMinusZ = quadMinusQ := by
    rw [quadMinusZ, quadMinusQ, Polynomial.map_sub, Polynomial.map_pow]
    simp [Polynomial.C_ofNat]
  rw [← hmap]
  exact h

private def minpoly_sqrtTwoGen : minpoly ℚ sqrtTwoGen = quadPlusQ := by
  symm
  apply minpoly.eq_of_irreducible_of_monic quadPlusQ_irreducible
  · rw [quadPlusQ]
    simp only [map_sub, map_pow, aeval_X, aeval_C]
    rw [sqrtTwoGen_sq]
    norm_num
  · rw [quadPlusQ]
    exact monic_X_pow_sub_C (2 : ℚ) (by decide)

private def minpoly_sqrtNegTwoGen : minpoly ℚ sqrtNegTwoGen = quadMinusQ := by
  symm
  apply minpoly.eq_of_irreducible_of_monic quadMinusQ_irreducible
  · rw [quadMinusQ]
    simp only [aeval_sub, aeval_pow, aeval_X, aeval_C]
    rw [sqrtNegTwoGen_sq]
    norm_num
  · rw [quadMinusQ]
    exact monic_X_pow_sub_C (-2 : ℚ) (by decide)

/-- The two explicit subfields generated by `ζ + ζ^7` and `ζ - ζ^7` are both quadratic. -/
theorem quadraticFields_degrees :
    Module.finrank ℚ sqrtTwoField = 2 ∧
      Module.finrank ℚ sqrtNegTwoField = 2 := by
  constructor
  · rw [sqrtTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtTwoGen), minpoly_sqrtTwoGen]
    simp [quadPlusQ]
  · rw [sqrtNegTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtNegTwoGen), minpoly_sqrtNegTwoGen]
    simp [quadMinusQ]

private def zetaEight_eq_half_sum :
    zetaEight = (2 : CyclotomicEight)⁻¹ * (sqrtTwoGen + sqrtNegTwoGen) := by
  rw [sqrtTwoGen, sqrtNegTwoGen]
  norm_num
  ring

/-- The two quadratic subfields generate the full eighth cyclotomic field. -/
theorem quadraticFields_sup :
    sqrtTwoField ⊔ sqrtNegTwoField = (⊤ : IntermediateField ℚ CyclotomicEight) := by
  have hzTop : ℚ⟮zetaEight⟯ = (⊤ : IntermediateField ℚ CyclotomicEight) := by
    rw [IntermediateField.adjoin_simple_eq_top_iff_of_isAlgebraic
      ((IsIntegral.of_finite ℚ zetaEight).isAlgebraic)]
    exact IsCyclotomicExtension.adjoin_primitive_root_eq_top zetaEight_spec
  apply top_unique
  rw [← hzTop, IntermediateField.adjoin_le_iff]
  intro x hx
  simp only [Set.mem_singleton_iff] at hx
  subst x
  rw [zetaEight_eq_half_sum]
  exact (sqrtTwoField ⊔ sqrtNegTwoField).mul_mem
    (by
      simpa using
        ((sqrtTwoField ⊔ sqrtNegTwoField).algebraMap_mem ((2 : ℚ)⁻¹)))
    ((sqrtTwoField ⊔ sqrtNegTwoField).add_mem
      ((show sqrtTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_left)
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtTwoGen))
      ((show sqrtNegTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_right)
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegTwoGen)))

private def cyclotomicEight_degree :
    Module.finrank ℚ CyclotomicEight = 4 := by
  rw [IsCyclotomicExtension.Rat.finrank 8 CyclotomicEight]
  rw [show 8 = 2 ^ 3 by norm_num,
    Nat.totient_prime_pow Nat.prime_two (by norm_num)]
  norm_num

private def cyclotomicEight_discr_abs :
    (NumberField.discr CyclotomicEight).natAbs = 256 := by
  letI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h := IsCyclotomicExtension.Rat.discr_prime_pow 2 3 CyclotomicEight
  have hφ : Nat.totient (2 ^ 3) = 4 := by
    rw [Nat.totient_prime_pow Nat.prime_two (by norm_num)]
    norm_num
  norm_num [hφ] at h
  rw [h]
  norm_num

/-- The two explicit quadratic subfields are linearly disjoint over `ℚ`. -/
theorem quadraticFields_linearDisjoint :
    sqrtTwoField.LinearDisjoint sqrtNegTwoField := by
  apply IntermediateField.LinearDisjoint.of_finrank_sup
  rw [quadraticFields_sup, IntermediateField.finrank_top', cyclotomicEight_degree,
    quadraticFields_degrees.1, quadraticFields_degrees.2]

/-- The ambient eighth cyclotomic field already has the degree and discriminant required by the
load-bearing witness. -/
theorem cyclotomicEight_ambient_invariants :
    Module.finrank ℚ CyclotomicEight = 4 ∧
      (NumberField.discr CyclotomicEight).natAbs = 256 :=
  ⟨cyclotomicEight_degree, cyclotomicEight_discr_abs⟩

private noncomputable def sqrtTwoPowerBasis : PowerBasis ℚ sqrtTwoField :=
  IntermediateField.adjoin.powerBasis (IsIntegral.of_finite ℚ sqrtTwoGen)

private noncomputable def sqrtNegTwoPowerBasis : PowerBasis ℚ sqrtNegTwoField :=
  IntermediateField.adjoin.powerBasis (IsIntegral.of_finite ℚ sqrtNegTwoGen)

private def minpoly_sqrtTwoPowerBasis :
    minpoly ℚ sqrtTwoPowerBasis.gen = quadPlusQ := by
  rw [sqrtTwoPowerBasis, IntermediateField.adjoin.powerBasis_gen]
  exact (IntermediateField.minpoly_gen ℚ sqrtTwoGen).trans minpoly_sqrtTwoGen

private def minpoly_sqrtNegTwoPowerBasis :
    minpoly ℚ sqrtNegTwoPowerBasis.gen = quadMinusQ := by
  rw [sqrtNegTwoPowerBasis, IntermediateField.adjoin.powerBasis_gen]
  exact (IntermediateField.minpoly_gen ℚ sqrtNegTwoGen).trans minpoly_sqrtNegTwoGen

private def sqrtTwoPowerBasis_discr :
    Algebra.discr ℚ sqrtTwoPowerBasis.basis = 8 := by
  rw [Algebra.discr_powerBasis_eq_norm, quadraticFields_degrees.1,
    minpoly_sqrtTwoPowerBasis]
  norm_num [quadPlusQ, Algebra.PowerBasis.norm_gen_eq_coeff_zero_minpoly,
    minpoly_sqrtTwoPowerBasis, quadraticFields_degrees.1, Algebra.norm_natCast]

private def sqrtNegTwoPowerBasis_discr :
    Algebra.discr ℚ sqrtNegTwoPowerBasis.basis = -8 := by
  rw [Algebra.discr_powerBasis_eq_norm, quadraticFields_degrees.2,
    minpoly_sqrtNegTwoPowerBasis]
  norm_num [quadMinusQ, Algebra.PowerBasis.norm_gen_eq_coeff_zero_minpoly,
    minpoly_sqrtNegTwoPowerBasis, quadraticFields_degrees.2, Algebra.norm_natCast]

/-- Before passing to rings of integers, the canonical quadratic power bases already have the
expected signed discriminants `8` and `-8`. -/
theorem quadraticPowerBasis_discriminants :
    Algebra.discr ℚ sqrtTwoPowerBasis.basis = 8 ∧
      Algebra.discr ℚ sqrtNegTwoPowerBasis.basis = -8 :=
  ⟨sqrtTwoPowerBasis_discr, sqrtNegTwoPowerBasis_discr⟩


private theorem sqrtTwoPowerBasis_gen_isIntegral :
    IsIntegral ℤ sqrtTwoPowerBasis.gen := by
  have hζ : IsIntegral ℤ zetaEight := zetaEight_spec.isIntegral (by decide)
  have hu : IsIntegral ℤ sqrtTwoGen := by
    rw [sqrtTwoGen]
    exact hζ.add (hζ.pow 7)
  rw [← IntermediateField.coe_isIntegral_iff]
  simpa [sqrtTwoPowerBasis, IntermediateField.adjoin.powerBasis_gen] using hu

private theorem sqrtNegTwoPowerBasis_gen_isIntegral :
    IsIntegral ℤ sqrtNegTwoPowerBasis.gen := by
  have hζ : IsIntegral ℤ zetaEight := zetaEight_spec.isIntegral (by decide)
  have hv : IsIntegral ℤ sqrtNegTwoGen := by
    rw [sqrtNegTwoGen]
    exact hζ.sub (hζ.pow 7)
  rw [← IntermediateField.coe_isIntegral_iff]
  simpa [sqrtNegTwoPowerBasis, IntermediateField.adjoin.powerBasis_gen] using hv

private theorem minpoly_sqrtTwoPowerBasis_int :
    minpoly ℤ sqrtTwoPowerBasis.gen = quadPlusZ := by
  apply map_injective (algebraMap ℤ ℚ) (algebraMap ℤ ℚ).injective_int
  rw [← minpoly.isIntegrallyClosed_eq_field_fractions' ℚ
      sqrtTwoPowerBasis_gen_isIntegral, minpoly_sqrtTwoPowerBasis]
  simp [quadPlusZ, quadPlusQ]

private theorem minpoly_sqrtNegTwoPowerBasis_int :
    minpoly ℤ sqrtNegTwoPowerBasis.gen = quadMinusZ := by
  apply map_injective (algebraMap ℤ ℚ) (algebraMap ℤ ℚ).injective_int
  rw [← minpoly.isIntegrallyClosed_eq_field_fractions' ℚ
      sqrtNegTwoPowerBasis_gen_isIntegral, minpoly_sqrtNegTwoPowerBasis]
  simp [quadMinusZ, quadMinusQ]


private theorem quadraticOrders_areIntegralClosures :
    IsIntegralClosure
        (Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField)) ℤ sqrtTwoField ∧
      IsIntegralClosure
        (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField)) ℤ
          sqrtNegTwoField := by
  constructor
  · refine ⟨Subtype.val_injective, @fun x => ⟨fun h => ⟨⟨x, ?_⟩, rfl⟩, ?_⟩⟩
    swap
    · rintro ⟨y, rfl⟩
      exact
        IsIntegral.algebraMap
          ((le_integralClosure_iff_isIntegral.1
              (adjoin_le_integralClosure sqrtTwoPowerBasis_gen_isIntegral)).isIntegral _)
    have H :=
      Algebra.discr_mul_isIntegral_mem_adjoin ℚ sqrtTwoPowerBasis_gen_isIntegral h
    rw [sqrtTwoPowerBasis_discr] at H
    have H' :
        (2 : ℤ) ^ 3 • x ∈
          Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField) := by
      simpa [Algebra.smul_def] using H
    have hmin :
        (minpoly ℤ sqrtTwoPowerBasis.gen).IsEisensteinAt spanTwo := by
      rw [minpoly_sqrtTwoPowerBasis_int]
      exact quadPlusZ_eisenstein
    exact
      mem_adjoin_of_smul_prime_pow_smul_of_minpoly_isEisensteinAt
        (p := (2 : ℤ)) (n := 3)
        (Nat.prime_iff_prime_int.1 Nat.prime_two)
        sqrtTwoPowerBasis_gen_isIntegral h H' hmin
  · refine ⟨Subtype.val_injective, @fun x => ⟨fun h => ⟨⟨x, ?_⟩, rfl⟩, ?_⟩⟩
    swap
    · rintro ⟨y, rfl⟩
      exact
        IsIntegral.algebraMap
          ((le_integralClosure_iff_isIntegral.1
              (adjoin_le_integralClosure sqrtNegTwoPowerBasis_gen_isIntegral)).isIntegral _)
    have H :=
      Algebra.discr_mul_isIntegral_mem_adjoin ℚ sqrtNegTwoPowerBasis_gen_isIntegral h
    rw [sqrtNegTwoPowerBasis_discr] at H
    have Hpos :
        (8 : ℚ) • x ∈
          Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField) := by
      have := Subalgebra.neg_mem _ H
      simpa [neg_smul] using this
    have H' :
        (2 : ℤ) ^ 3 • x ∈
          Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField) := by
      simpa [Algebra.smul_def] using Hpos
    have hmin :
        (minpoly ℤ sqrtNegTwoPowerBasis.gen).IsEisensteinAt spanTwo := by
      rw [minpoly_sqrtNegTwoPowerBasis_int]
      exact quadMinusZ_eisenstein
    exact
      mem_adjoin_of_smul_prime_pow_smul_of_minpoly_isEisensteinAt
        (p := (2 : ℤ)) (n := 3)
        (Nat.prime_iff_prime_int.1 Nat.prime_two)
        sqrtNegTwoPowerBasis_gen_isIntegral h H' hmin


/-- The explicit eighth-cyclotomic tower closes the counterexample promised by
`LeanFrontier.DiscriminantTower.loadBearing_of_witness`. -/
theorem coprimalityIsLoadBearing :
    LeanFrontier.DiscriminantTower.CoprimalityIsLoadBearing := by
  letI :
      IsIntegralClosure
        (Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField)) ℤ sqrtTwoField :=
    quadraticOrders_areIntegralClosures.1
  letI :
      IsIntegralClosure
        (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField)) ℤ
          sqrtNegTwoField :=
    quadraticOrders_areIntegralClosures.2

  let e₁ :
      Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField) ≃ₐ[ℤ]
        (𝓞 sqrtTwoField) :=
    IsIntegralClosure.equiv ℤ
      (Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField))
      sqrtTwoField (𝓞 sqrtTwoField)
  let e₂ :
      Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField) ≃ₐ[ℤ]
        (𝓞 sqrtNegTwoField) :=
    IsIntegralClosure.equiv ℤ
      (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField))
      sqrtNegTwoField (𝓞 sqrtNegTwoField)

  let pB₁ : PowerBasis ℤ (𝓞 sqrtTwoField) :=
    (Algebra.adjoin.powerBasis' sqrtTwoPowerBasis_gen_isIntegral).map e₁
  let pB₂ : PowerBasis ℤ (𝓞 sqrtNegTwoField) :=
    (Algebra.adjoin.powerBasis' sqrtNegTwoPowerBasis_gen_isIntegral).map e₂

  have hpB₁_gen :
      pB₁.gen =
        (⟨sqrtTwoPowerBasis.gen, sqrtTwoPowerBasis_gen_isIntegral⟩ :
          𝓞 sqrtTwoField) := by
    apply Subtype.ext
    change algebraMap (𝓞 sqrtTwoField) sqrtTwoField pB₁.gen =
      sqrtTwoPowerBasis.gen
    rw [pB₁, PowerBasis.map_gen, Algebra.adjoin.powerBasis'_gen]
    simp [e₁]
  have hpB₂_gen :
      pB₂.gen =
        (⟨sqrtNegTwoPowerBasis.gen, sqrtNegTwoPowerBasis_gen_isIntegral⟩ :
          𝓞 sqrtNegTwoField) := by
    apply Subtype.ext
    change algebraMap (𝓞 sqrtNegTwoField) sqrtNegTwoField pB₂.gen =
      sqrtNegTwoPowerBasis.gen
    rw [pB₂, PowerBasis.map_gen, Algebra.adjoin.powerBasis'_gen]
    simp [e₂]

  have hdisc₁ : NumberField.discr sqrtTwoField = 8 := by
    apply (algebraMap ℤ ℚ).injective_int
    rw [← NumberField.discr_eq_discr _ pB₁.basis,
      ← Algebra.discr_localizationLocalization ℤ ℤ⁰ sqrtTwoField]
    convert! sqrtTwoPowerBasis_discr using 1
    · have hdim : pB₁.dim = sqrtTwoPowerBasis.dim := by
        rw [← PowerBasis.finrank, ← PowerBasis.finrank]
        exact RingOfIntegers.rank sqrtTwoField
      rw [← Algebra.discr_reindex _ _ (finCongr hdim)]
      congr 1
      ext i
      simp_rw [Function.comp_apply, Module.Basis.localizationLocalization_apply,
        PowerBasis.coe_basis, hpB₁_gen]
      convert! ← (sqrtTwoPowerBasis.basis_eq_pow i).symm using 1
    · norm_num

  have hdisc₂ : NumberField.discr sqrtNegTwoField = -8 := by
    apply (algebraMap ℤ ℚ).injective_int
    rw [← NumberField.discr_eq_discr _ pB₂.basis,
      ← Algebra.discr_localizationLocalization ℤ ℤ⁰ sqrtNegTwoField]
    convert! sqrtNegTwoPowerBasis_discr using 1
    · have hdim : pB₂.dim = sqrtNegTwoPowerBasis.dim := by
        rw [← PowerBasis.finrank, ← PowerBasis.finrank]
        exact RingOfIntegers.rank sqrtNegTwoField
      rw [← Algebra.discr_reindex _ _ (finCongr hdim)]
      congr 1
      ext i
      simp_rw [Function.comp_apply, Module.Basis.localizationLocalization_apply,
        PowerBasis.coe_basis, hpB₂_gen]
      convert! ← (sqrtNegTwoPowerBasis.basis_eq_pow i).symm using 1
    · norm_num

  apply LeanFrontier.DiscriminantTower.loadBearing_of_witness
    CyclotomicEight sqrtTwoField sqrtNegTwoField
  · exact ⟨quadraticFields_linearDisjoint, quadraticFields_sup⟩
  · exact cyclotomicEight_discr_abs
  · simpa [LeanFrontier.DiscriminantTower.discrAbs, hdisc₁]
  · simpa [LeanFrontier.DiscriminantTower.discrAbs, hdisc₂]
  · simpa [LeanFrontier.DiscriminantTower.degree] using quadraticFields_degrees.1
  · simpa [LeanFrontier.DiscriminantTower.degree] using quadraticFields_degrees.2

end

end LeanFrontier.NumberTheory.DiscriminantTower
