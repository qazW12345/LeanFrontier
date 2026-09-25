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

abbrev CyclotomicEight := CyclotomicField 8 ℚ

local instance cyclotomicEight_isCyclotomic :
    IsCyclotomicExtension {8} ℚ CyclotomicEight :=
  CyclotomicField.isCyclotomicExtension 8 ℚ

noncomputable def zetaEight : CyclotomicEight :=
  IsCyclotomicExtension.zeta 8 ℚ CyclotomicEight

private opaque zetaEight_spec : IsPrimitiveRoot zetaEight 8 := by
  exact IsCyclotomicExtension.zeta_spec 8 ℚ CyclotomicEight

private opaque zetaEight_pow_eight : zetaEight ^ 8 = 1 :=
  zetaEight_spec.pow_eq_one

private opaque zetaEight_pow_four : zetaEight ^ 4 = -1 := by
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

private opaque zetaEight_pow_six : zetaEight ^ 6 = -(zetaEight ^ 2) := by
  calc
    zetaEight ^ 6 = zetaEight ^ 2 * zetaEight ^ 4 := by ring
    _ = -(zetaEight ^ 2) := by rw [zetaEight_pow_four]; ring

private opaque zetaEight_pow_fourteen : zetaEight ^ 14 = zetaEight ^ 6 := by
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

private opaque spanTwo_prime : spanTwo.IsPrime := by
  rw [spanTwo, Ideal.span_singleton_prime (by norm_num : (2 : ℤ) ≠ 0),
    Int.prime_iff_natAbs_prime]
  norm_num

private opaque quadPlusZ_monic : quadPlusZ.Monic := by
  rw [quadPlusZ]
  exact monic_X_pow_sub_C (2 : ℤ) (by decide)

private opaque quadMinusZ_monic : quadMinusZ.Monic := by
  rw [quadMinusZ]
  exact monic_X_pow_sub_C (-2 : ℤ) (by decide)

private opaque quadPlusZ_eisenstein : quadPlusZ.IsEisensteinAt spanTwo := by
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

private opaque quadMinusZ_eisenstein : quadMinusZ.IsEisensteinAt spanTwo := by
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

private opaque quadPlusZ_irreducible : Irreducible quadPlusZ :=
  quadPlusZ_eisenstein.irreducible spanTwo_prime
    quadPlusZ_monic.isPrimitive
    (by rw [quadPlusZ, natDegree_X_pow_sub_C]; norm_num)

private opaque quadMinusZ_irreducible : Irreducible quadMinusZ :=
  quadMinusZ_eisenstein.irreducible spanTwo_prime
    quadMinusZ_monic.isPrimitive
    (by rw [quadMinusZ, natDegree_X_pow_sub_C]; norm_num)

private opaque quadPlusQ_irreducible : Irreducible quadPlusQ := by
  have h :=
    (Polynomial.IsPrimitive.Int.irreducible_iff_irreducible_map_cast
      quadPlusZ_monic.isPrimitive).mp
      quadPlusZ_irreducible
  have hmap : Polynomial.map (Int.castRingHom ℚ) quadPlusZ = quadPlusQ := by
    rw [quadPlusZ, quadPlusQ, Polynomial.map_sub, Polynomial.map_pow]
    simp
    exact (Polynomial.C_ofNat (R := ℚ) 2).symm
  rw [← hmap]
  exact h

private opaque quadMinusQ_irreducible : Irreducible quadMinusQ := by
  have h :=
    (Polynomial.IsPrimitive.Int.irreducible_iff_irreducible_map_cast
      quadMinusZ_monic.isPrimitive).mp
      quadMinusZ_irreducible
  have hmap : Polynomial.map (Int.castRingHom ℚ) quadMinusZ = quadMinusQ := by
    rw [quadMinusZ, quadMinusQ, Polynomial.map_sub, Polynomial.map_pow]
    simp
    exact (Polynomial.C_ofNat (R := ℚ) 2).symm
  rw [← hmap]
  exact h

private opaque minpoly_sqrtTwoGen : minpoly ℚ sqrtTwoGen = quadPlusQ := by
  symm
  apply minpoly.eq_of_irreducible_of_monic quadPlusQ_irreducible
  · rw [quadPlusQ]
    simp only [map_sub, map_pow, aeval_X, aeval_C]
    rw [sqrtTwoGen_sq]
    norm_num
  · rw [quadPlusQ]
    exact monic_X_pow_sub_C (2 : ℚ) (by decide)

private opaque minpoly_sqrtNegTwoGen : minpoly ℚ sqrtNegTwoGen = quadMinusQ := by
  symm
  apply minpoly.eq_of_irreducible_of_monic quadMinusQ_irreducible
  · rw [quadMinusQ]
    simp only [map_sub, map_pow, aeval_X, aeval_C]
    rw [sqrtNegTwoGen_sq]
    norm_num
  · rw [quadMinusQ]
    exact monic_X_pow_sub_C (-2 : ℚ) (by decide)


/-- The two explicit elements `ζ₈ + ζ₈^7` and `ζ₈ - ζ₈^7` have the expected quadratic
minimal polynomials over `ℚ`.  These are the generators of the real and imaginary quadratic
subfields used in the discriminant-tower witness. -/
theorem quadraticGenerator_minpolys :
    minpoly ℚ sqrtTwoGen = X ^ 2 - C 2 ∧
      minpoly ℚ sqrtNegTwoGen = X ^ 2 + C 2 := by
  constructor
  · simpa [quadPlusQ] using minpoly_sqrtTwoGen
  · simpa [quadMinusQ] using minpoly_sqrtNegTwoGen

/-- The two explicit subfields generated by `ζ + ζ^7` and `ζ - ζ^7` are both quadratic. -/
private theorem quadraticFields_degrees :
    Module.finrank ℚ sqrtTwoField = 2 ∧
      Module.finrank ℚ sqrtNegTwoField = 2 := by
  constructor
  · rw [sqrtTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtTwoGen), minpoly_sqrtTwoGen]
    simp [quadPlusQ]
  · rw [sqrtNegTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtNegTwoGen), minpoly_sqrtNegTwoGen]
    simp [quadMinusQ]

private opaque zetaEight_eq_half_sum :
    zetaEight = (2 : CyclotomicEight)⁻¹ * (sqrtTwoGen + sqrtNegTwoGen) := by
  rw [sqrtTwoGen, sqrtNegTwoGen]
  norm_num
  ring

/-- The two quadratic subfields generate the full eighth cyclotomic field. -/
private theorem quadraticFields_sup :
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
  have hhalf : (2 : CyclotomicEight)⁻¹ ∈ sqrtTwoField ⊔ sqrtNegTwoField := by
    simpa using
      ((sqrtTwoField ⊔ sqrtNegTwoField).algebraMap_mem ((2 : ℚ)⁻¹))
  have hu : sqrtTwoGen ∈ sqrtTwoField ⊔ sqrtNegTwoField := by
    exact
      (show sqrtTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_left)
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtTwoGen)
  have hv : sqrtNegTwoGen ∈ sqrtTwoField ⊔ sqrtNegTwoField := by
    exact
      (show sqrtNegTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_right)
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegTwoGen)
  exact (sqrtTwoField ⊔ sqrtNegTwoField).mul_mem hhalf
    ((sqrtTwoField ⊔ sqrtNegTwoField).add_mem hu hv)

private opaque cyclotomicEight_degree :
    Module.finrank ℚ CyclotomicEight = 4 := by
  calc
    Module.finrank ℚ CyclotomicEight = Nat.totient 8 :=
      IsCyclotomicExtension.Rat.finrank 8 CyclotomicEight
    _ = 4 := by
      change Nat.totient (2 ^ 3) = 4
      rw [Nat.totient_prime_pow Nat.prime_two (by norm_num : 0 < 3)]
      norm_num

private opaque cyclotomicEight_discr_abs :
    (NumberField.discr CyclotomicEight).natAbs = 256 := by
  letI : IsCyclotomicExtension {2 ^ 3} ℚ CyclotomicEight := by
    norm_num
    infer_instance
  have hdisc :=
    IsCyclotomicExtension.Rat.discr_prime_pow 2 3 CyclotomicEight
  rw [hdisc, Int.natAbs_mul, Int.natAbs_pow]
  norm_num

/-- The two explicit quadratic subfields are linearly disjoint over `ℚ`. -/
private theorem quadraticFields_linearDisjoint :
    sqrtTwoField.LinearDisjoint sqrtNegTwoField := by
  apply IntermediateField.LinearDisjoint.of_finrank_sup
  rw [quadraticFields_sup, IntermediateField.finrank_top', cyclotomicEight_degree,
    quadraticFields_degrees.1, quadraticFields_degrees.2]

/-- Inside the eighth cyclotomic field there exist two quadratic subfields which generate the
whole field and are linearly disjoint over `ℚ`.

The proof uses the explicit generators `ζ₈ + ζ₈^7` and `ζ₈ - ζ₈^7`, but the statement exposes
only the compact structural interface needed downstream. -/
private theorem exists_quadratic_subfields_cyclotomicEight :
    ∃ K₁ K₂ : IntermediateField ℚ CyclotomicEight,
      Module.finrank ℚ K₁ = 2 ∧
      Module.finrank ℚ K₂ = 2 ∧
      K₁ ⊔ K₂ = ⊤ ∧
      K₁.LinearDisjoint K₂ := by
  refine ⟨sqrtTwoField, sqrtNegTwoField,
    quadraticFields_degrees.1, quadraticFields_degrees.2,
    quadraticFields_sup, quadraticFields_linearDisjoint⟩

/-- The ambient eighth cyclotomic field already has the degree and discriminant required by the
load-bearing witness. -/
theorem cyclotomicEight_ambient_invariants :
    Module.finrank ℚ CyclotomicEight = 4 ∧
      (NumberField.discr CyclotomicEight).natAbs = 256 :=
  ⟨cyclotomicEight_degree, cyclotomicEight_discr_abs⟩



private noncomputable def sqrtTwoPowerBasis : PowerBasis ℚ sqrtTwoField := by
  rw [sqrtTwoField]
  exact IntermediateField.adjoin.powerBasis (IsIntegral.of_finite ℚ sqrtTwoGen)

private noncomputable def sqrtNegTwoPowerBasis : PowerBasis ℚ sqrtNegTwoField := by
  rw [sqrtNegTwoField]
  exact IntermediateField.adjoin.powerBasis (IsIntegral.of_finite ℚ sqrtNegTwoGen)

private theorem sqrtTwoPowerBasis_gen_sq :
    sqrtTwoPowerBasis.gen ^ 2 = (2 : sqrtTwoField) := by
  apply Subtype.ext
  simpa [sqrtTwoPowerBasis, sqrtTwoField] using sqrtTwoGen_sq

private theorem sqrtNegTwoPowerBasis_gen_sq :
    sqrtNegTwoPowerBasis.gen ^ 2 = (-2 : sqrtNegTwoField) := by
  apply Subtype.ext
  simpa [sqrtNegTwoPowerBasis, sqrtNegTwoField] using sqrtNegTwoGen_sq

private theorem sqrtTwoPowerBasis_minpoly :
    minpoly ℚ sqrtTwoPowerBasis.gen = quadPlusQ := by
  change minpoly ℚ (IntermediateField.AdjoinSimple.gen ℚ sqrtTwoGen) = quadPlusQ
  rw [IntermediateField.minpoly_gen, minpoly_sqrtTwoGen]

private theorem sqrtNegTwoPowerBasis_minpoly :
    minpoly ℚ sqrtNegTwoPowerBasis.gen = quadMinusQ := by
  change minpoly ℚ (IntermediateField.AdjoinSimple.gen ℚ sqrtNegTwoGen) = quadMinusQ
  rw [IntermediateField.minpoly_gen, minpoly_sqrtNegTwoGen]

private theorem sqrtTwoPowerBasis_gen_integral :
    IsIntegral ℤ sqrtTwoPowerBasis.gen := by
  refine ⟨quadPlusZ, quadPlusZ_monic, ?_⟩
  rw [quadPlusZ]
  simp only [map_sub, map_pow, aeval_X, aeval_C]
  rw [sqrtTwoPowerBasis_gen_sq]
  norm_num

private theorem sqrtNegTwoPowerBasis_gen_integral :
    IsIntegral ℤ sqrtNegTwoPowerBasis.gen := by
  refine ⟨quadMinusZ, quadMinusZ_monic, ?_⟩
  rw [quadMinusZ]
  simp only [map_sub, map_pow, aeval_X, aeval_C]
  rw [sqrtNegTwoPowerBasis_gen_sq]
  norm_num

private theorem sqrtTwoPowerBasis_minpoly_int :
    minpoly ℤ sqrtTwoPowerBasis.gen = quadPlusZ := by
  apply Polynomial.map_injective (algebraMap ℤ ℚ) (algebraMap ℤ ℚ).injective_int
  rw [minpoly.isIntegrallyClosed_eq_field_fractions' ℚ sqrtTwoPowerBasis_gen_integral,
    sqrtTwoPowerBasis_minpoly]
  simp [quadPlusZ, quadPlusQ]

private theorem sqrtNegTwoPowerBasis_minpoly_int :
    minpoly ℤ sqrtNegTwoPowerBasis.gen = quadMinusZ := by
  apply Polynomial.map_injective (algebraMap ℤ ℚ) (algebraMap ℤ ℚ).injective_int
  rw [minpoly.isIntegrallyClosed_eq_field_fractions' ℚ sqrtNegTwoPowerBasis_gen_integral,
    sqrtNegTwoPowerBasis_minpoly]
  simp [quadMinusZ, quadMinusQ]

private theorem sqrtTwoPowerBasis_discr :
    Algebra.discr ℚ sqrtTwoPowerBasis.basis = 8 := by
  rw [Algebra.discr_powerBasis_eq_norm, quadraticFields_degrees.1,
    sqrtTwoPowerBasis_minpoly]
  norm_num [quadPlusQ, Algebra.norm_algebraMap,
    PowerBasis.norm_gen_eq_coeff_zero_minpoly, sqrtTwoPowerBasis_minpoly]

private theorem sqrtNegTwoPowerBasis_discr :
    Algebra.discr ℚ sqrtNegTwoPowerBasis.basis = -8 := by
  rw [Algebra.discr_powerBasis_eq_norm, quadraticFields_degrees.2,
    sqrtNegTwoPowerBasis_minpoly]
  norm_num [quadMinusQ, Algebra.norm_algebraMap,
    PowerBasis.norm_gen_eq_coeff_zero_minpoly, sqrtNegTwoPowerBasis_minpoly]

private theorem sqrtTwo_isIntegralClosure :
    IsIntegralClosure
      (Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField))
      ℤ sqrtTwoField := by
  refine ⟨Subtype.val_injective, @fun x => ⟨fun h => ⟨⟨x, ?_⟩, rfl⟩, ?_⟩⟩
  swap
  · rintro ⟨y, rfl⟩
    exact IsIntegral.algebraMap
      ((le_integralClosure_iff_isIntegral.1
        (adjoin_le_integralClosure sqrtTwoPowerBasis_gen_integral)).isIntegral _)
  have H :=
    Algebra.discr_mul_isIntegral_mem_adjoin ℚ sqrtTwoPowerBasis_gen_integral h
  rw [sqrtTwoPowerBasis_discr] at H
  refine
    Algebra.adjoin_le ?_
      (mem_adjoin_of_smul_prime_pow_smul_of_minpoly_isEisensteinAt (n := 3)
        (by norm_num : Prime (2 : ℤ)) sqrtTwoPowerBasis_gen_integral h (by simpa using H) ?_)
  · simpa [sqrtTwoPowerBasis_minpoly_int, spanTwo] using quadPlusZ_eisenstein
  · simp only [Set.singleton_subset_iff, SetLike.mem_coe]
    exact Algebra.self_mem_adjoin_singleton ℤ sqrtTwoPowerBasis.gen

private theorem sqrtNegTwo_isIntegralClosure :
    IsIntegralClosure
      (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField))
      ℤ sqrtNegTwoField := by
  refine ⟨Subtype.val_injective, @fun x => ⟨fun h => ⟨⟨x, ?_⟩, rfl⟩, ?_⟩⟩
  swap
  · rintro ⟨y, rfl⟩
    exact IsIntegral.algebraMap
      ((le_integralClosure_iff_isIntegral.1
        (adjoin_le_integralClosure sqrtNegTwoPowerBasis_gen_integral)).isIntegral _)
  have H :=
    Algebra.discr_mul_isIntegral_mem_adjoin ℚ sqrtNegTwoPowerBasis_gen_integral h
  rw [sqrtNegTwoPowerBasis_discr] at H
  have H' : (8 : ℚ) • x ∈
      Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField) := by
    simpa using
      (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField)).neg_mem H
  refine
    Algebra.adjoin_le ?_
      (mem_adjoin_of_smul_prime_pow_smul_of_minpoly_isEisensteinAt (n := 3)
        (by norm_num : Prime (2 : ℤ)) sqrtNegTwoPowerBasis_gen_integral h
        (by simpa using H') ?_)
  · simpa [sqrtNegTwoPowerBasis_minpoly_int, spanTwo] using quadMinusZ_eisenstein
  · simp only [Set.singleton_subset_iff, SetLike.mem_coe]
    exact Algebra.self_mem_adjoin_singleton ℤ sqrtNegTwoPowerBasis.gen

private noncomputable def sqrtTwoAdjoinEquivRingOfIntegers :
    Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField) ≃ₐ[ℤ]
      𝓞 sqrtTwoField :=
  let _ := sqrtTwo_isIntegralClosure
  IsIntegralClosure.equiv ℤ
    (Algebra.adjoin ℤ ({sqrtTwoPowerBasis.gen} : Set sqrtTwoField))
    sqrtTwoField (𝓞 sqrtTwoField)

private noncomputable def sqrtNegTwoAdjoinEquivRingOfIntegers :
    Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField) ≃ₐ[ℤ]
      𝓞 sqrtNegTwoField :=
  let _ := sqrtNegTwo_isIntegralClosure
  IsIntegralClosure.equiv ℤ
    (Algebra.adjoin ℤ ({sqrtNegTwoPowerBasis.gen} : Set sqrtNegTwoField))
    sqrtNegTwoField (𝓞 sqrtNegTwoField)

private noncomputable def sqrtTwoIntegralPowerBasis :
    PowerBasis ℤ (𝓞 sqrtTwoField) :=
  (Algebra.adjoin.powerBasis' sqrtTwoPowerBasis_gen_integral).map
    sqrtTwoAdjoinEquivRingOfIntegers

private noncomputable def sqrtNegTwoIntegralPowerBasis :
    PowerBasis ℤ (𝓞 sqrtNegTwoField) :=
  (Algebra.adjoin.powerBasis' sqrtNegTwoPowerBasis_gen_integral).map
    sqrtNegTwoAdjoinEquivRingOfIntegers

private theorem sqrtTwoIntegralPowerBasis_gen_coe :
    algebraMap (𝓞 sqrtTwoField) sqrtTwoField sqrtTwoIntegralPowerBasis.gen =
      sqrtTwoPowerBasis.gen := by
  simp [sqrtTwoIntegralPowerBasis, sqrtTwoAdjoinEquivRingOfIntegers,
    IsIntegralClosure.equiv, IsIntegralClosure.lift, IsIntegralClosure.mk']

private theorem sqrtNegTwoIntegralPowerBasis_gen_coe :
    algebraMap (𝓞 sqrtNegTwoField) sqrtNegTwoField sqrtNegTwoIntegralPowerBasis.gen =
      sqrtNegTwoPowerBasis.gen := by
  simp [sqrtNegTwoIntegralPowerBasis, sqrtNegTwoAdjoinEquivRingOfIntegers,
    IsIntegralClosure.equiv, IsIntegralClosure.lift, IsIntegralClosure.mk']

private theorem sqrtTwoField_discr :
    NumberField.discr sqrtTwoField = 8 := by
  let pB := sqrtTwoIntegralPowerBasis
  apply (algebraMap ℤ ℚ).injective_int
  rw [← NumberField.discr_eq_discr _ pB.basis,
    ← Algebra.discr_localizationLocalization ℤ ℤ⁰ sqrtTwoField]
  convert! sqrtTwoPowerBasis_discr using 1
  · have hdim : pB.dim = sqrtTwoPowerBasis.dim := by
      rw [← PowerBasis.finrank, ← PowerBasis.finrank]
      exact RingOfIntegers.rank sqrtTwoField
    rw [← Algebra.discr_reindex _ _ (finCongr hdim)]
    congr 1
    ext i
    simp_rw [Function.comp_apply, Module.Basis.localizationLocalization_apply,
      PowerBasis.coe_basis]
    rw [map_pow, sqrtTwoIntegralPowerBasis_gen_coe]
  · norm_num

private theorem sqrtNegTwoField_discr :
    NumberField.discr sqrtNegTwoField = -8 := by
  let pB := sqrtNegTwoIntegralPowerBasis
  apply (algebraMap ℤ ℚ).injective_int
  rw [← NumberField.discr_eq_discr _ pB.basis,
    ← Algebra.discr_localizationLocalization ℤ ℤ⁰ sqrtNegTwoField]
  convert! sqrtNegTwoPowerBasis_discr using 1
  · have hdim : pB.dim = sqrtNegTwoPowerBasis.dim := by
      rw [← PowerBasis.finrank, ← PowerBasis.finrank]
      exact RingOfIntegers.rank sqrtNegTwoField
    rw [← Algebra.discr_reindex _ _ (finCongr hdim)]
    congr 1
    ext i
    simp_rw [Function.comp_apply, Module.Basis.localizationLocalization_apply,
      PowerBasis.coe_basis]
    rw [map_pow, sqrtNegTwoIntegralPowerBasis_gen_coe]
  · norm_num

/-- The two quadratic subfields in the eighth cyclotomic field both have absolute
discriminant 8. -/
theorem quadraticFields_discr_abs :
    (NumberField.discr sqrtTwoField).natAbs = 8 ∧
      (NumberField.discr sqrtNegTwoField).natAbs = 8 := by
  rw [sqrtTwoField_discr, sqrtNegTwoField_discr]
  norm_num

/-- The explicit quadratic subfields of the eighth cyclotomic field witness that the
coprimality hypothesis in the compositum discriminant identity is load-bearing. -/
theorem coprimalityIsLoadBearing :
    LeanFrontier.DiscriminantTower.CoprimalityIsLoadBearing := by
  apply LeanFrontier.DiscriminantTower.loadBearing_of_witness
    CyclotomicEight sqrtTwoField sqrtNegTwoField
  · exact ⟨quadraticFields_linearDisjoint, quadraticFields_sup⟩
  · exact cyclotomicEight_discr_abs
  · simpa [LeanFrontier.DiscriminantTower.discrAbs] using quadraticFields_discr_abs.1
  · simpa [LeanFrontier.DiscriminantTower.discrAbs] using quadraticFields_discr_abs.2
  · simpa [LeanFrontier.DiscriminantTower.degree] using quadraticFields_degrees.1
  · simpa [LeanFrontier.DiscriminantTower.degree] using quadraticFields_degrees.2


end

end LeanFrontier.NumberTheory.DiscriminantTower
