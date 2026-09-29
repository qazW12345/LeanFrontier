import LeanFrontier.NumberTheory.CyclotomicEightQuadraticClassification
import Mathlib.Tactic

/-!
# Explicit classification of the quadratic subfields of the eighth cyclotomic field

The preceding structural result proves that `ℚ(ζ₈)/ℚ` has exactly three quadratic
intermediate fields.  The witness and Gaussian modules already construct the three
classical candidates:

* `sqrtTwoField = ℚ(√2)`,
* `sqrtNegTwoField = ℚ(√-2)`,
* `gaussianField = ℚ(i)`.

This file closes the loop: the three fields are pairwise distinct and every quadratic
intermediate field is equal to one of them.
-/

namespace LeanFrontier.NumberTheory.DiscriminantTower

open Polynomial IntermediateField NumberField

noncomputable section

local instance : NeZero (8 : ℕ) := ⟨by decide⟩

local instance cyclotomicEight_isCyclotomic_explicit :
    IsCyclotomicExtension {8} ℚ CyclotomicEight :=
  CyclotomicField.isCyclotomicExtension 8 ℚ

local instance cyclotomicEight_finiteDimensional_explicit :
    FiniteDimensional ℚ CyclotomicEight :=
  IsCyclotomicExtension.finiteDimensional {8} ℚ CyclotomicEight

private theorem sqrtTwoField_degree_explicit :
    Module.finrank ℚ sqrtTwoField = 2 := by
  rw [sqrtTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtTwoGen), quadraticGenerator_minpolys.1]
  simp

private theorem sqrtNegTwoField_degree_explicit :
    Module.finrank ℚ sqrtNegTwoField = 2 := by
  rw [sqrtNegTwoField, IntermediateField.adjoin.finrank
      (IsIntegral.of_finite ℚ sqrtNegTwoGen), quadraticGenerator_minpolys.2]
  simp

private theorem gaussianField_degree_explicit :
    Module.finrank ℚ gaussianField = 2 := by
  simpa [gaussianFieldDegree] using gaussianField_degree

private theorem sqrtTwo_sup_sqrtNegTwo_eq_top_explicit :
    sqrtTwoField ⊔ sqrtNegTwoField =
      (⊤ : IntermediateField ℚ CyclotomicEight) := by
  have hzspec : IsPrimitiveRoot zetaEight 8 := by
    exact IsCyclotomicExtension.zeta_spec 8 ℚ CyclotomicEight
  have hzTop : ℚ⟮zetaEight⟯ =
      (⊤ : IntermediateField ℚ CyclotomicEight) := by
    rw [IntermediateField.adjoin_simple_eq_top_iff_of_isAlgebraic
      ((IsIntegral.of_finite ℚ zetaEight).isAlgebraic)]
    exact IsCyclotomicExtension.adjoin_primitive_root_eq_top hzspec
  apply top_unique
  rw [← hzTop, IntermediateField.adjoin_le_iff]
  intro x hx
  simp only [Set.mem_singleton_iff] at hx
  subst x
  have hz :
      zetaEight =
        (2 : CyclotomicEight)⁻¹ * (sqrtTwoGen + sqrtNegTwoGen) := by
    rw [sqrtTwoGen, sqrtNegTwoGen]
    norm_num
    ring
  rw [hz]
  have hhalf :
      (2 : CyclotomicEight)⁻¹ ∈ sqrtTwoField ⊔ sqrtNegTwoField := by
    simpa using
      ((sqrtTwoField ⊔ sqrtNegTwoField).algebraMap_mem ((2 : ℚ)⁻¹))
  have hu0 : sqrtTwoGen ∈ sqrtTwoField := by
    simpa [sqrtTwoField] using
      (IntermediateField.mem_adjoin_simple_self ℚ sqrtTwoGen)
  have hv0 : sqrtNegTwoGen ∈ sqrtNegTwoField := by
    simpa [sqrtNegTwoField] using
      (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegTwoGen)
  have hu : sqrtTwoGen ∈ sqrtTwoField ⊔ sqrtNegTwoField :=
    (show sqrtTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_left) hu0
  have hv : sqrtNegTwoGen ∈ sqrtTwoField ⊔ sqrtNegTwoField :=
    (show sqrtNegTwoField ≤ sqrtTwoField ⊔ sqrtNegTwoField from le_sup_right) hv0
  exact (sqrtTwoField ⊔ sqrtNegTwoField).mul_mem hhalf
    ((sqrtTwoField ⊔ sqrtNegTwoField).add_mem hu hv)

private theorem sqrtTwo_sup_gaussian_eq_top :
    sqrtTwoField ⊔ gaussianField =
      (⊤ : IntermediateField ℚ CyclotomicEight) := by
  apply top_unique
  rw [← sqrtTwo_sup_sqrtNegTwo_eq_top_explicit]
  apply sup_le
  · exact (show sqrtTwoField ≤ sqrtTwoField ⊔ gaussianField from le_sup_left)
  · rw [sqrtNegTwoField, IntermediateField.adjoin_le_iff]
    intro x hx
    simp only [Set.mem_singleton_iff] at hx
    subst x
    have hu0 : sqrtTwoGen ∈ sqrtTwoField := by
      simpa [sqrtTwoField] using
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtTwoGen)
    have hi0 : sqrtNegOneGen ∈ gaussianField := by
      simpa [gaussianField] using
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegOneGen)
    have hu : sqrtTwoGen ∈ sqrtTwoField ⊔ gaussianField :=
      (show sqrtTwoField ≤ sqrtTwoField ⊔ gaussianField from le_sup_left) hu0
    have hi : sqrtNegOneGen ∈ sqrtTwoField ⊔ gaussianField :=
      (show gaussianField ≤ sqrtTwoField ⊔ gaussianField from le_sup_right) hi0
    have hrel : sqrtNegOneGen * sqrtTwoGen = sqrtNegTwoGen := by
      calc
        sqrtNegOneGen * sqrtTwoGen =
            (sqrtTwoGen ^ 2 * sqrtNegTwoGen) / 2 := by
          rw [sqrtNegOneGen]
          ring
        _ = sqrtNegTwoGen := by
          rw [sqrtTwoGen_sq]
          norm_num
    rw [← hrel]
    exact (sqrtTwoField ⊔ gaussianField).mul_mem hi hu

private theorem sqrtNegTwo_sup_gaussian_eq_top :
    sqrtNegTwoField ⊔ gaussianField =
      (⊤ : IntermediateField ℚ CyclotomicEight) := by
  apply top_unique
  rw [← sqrtTwo_sup_sqrtNegTwo_eq_top_explicit]
  apply sup_le
  · rw [sqrtTwoField, IntermediateField.adjoin_le_iff]
    intro x hx
    simp only [Set.mem_singleton_iff] at hx
    subst x
    have hv0 : sqrtNegTwoGen ∈ sqrtNegTwoField := by
      simpa [sqrtNegTwoField] using
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegTwoGen)
    have hi0 : sqrtNegOneGen ∈ gaussianField := by
      simpa [gaussianField] using
        (IntermediateField.mem_adjoin_simple_self ℚ sqrtNegOneGen)
    have hv : sqrtNegTwoGen ∈ sqrtNegTwoField ⊔ gaussianField :=
      (show sqrtNegTwoField ≤ sqrtNegTwoField ⊔ gaussianField from le_sup_left) hv0
    have hi : sqrtNegOneGen ∈ sqrtNegTwoField ⊔ gaussianField :=
      (show gaussianField ≤ sqrtNegTwoField ⊔ gaussianField from le_sup_right) hi0
    have hrel : -(sqrtNegOneGen * sqrtNegTwoGen) = sqrtTwoGen := by
      calc
        -(sqrtNegOneGen * sqrtNegTwoGen) =
            -(sqrtTwoGen * sqrtNegTwoGen ^ 2 / 2) := by
          rw [sqrtNegOneGen]
          ring
        _ = sqrtTwoGen := by
          rw [sqrtNegTwoGen_sq]
          ring
    rw [← hrel]
    exact (sqrtNegTwoField ⊔ gaussianField).neg_mem
      ((sqrtNegTwoField ⊔ gaussianField).mul_mem hi hv)
  · exact (show sqrtNegTwoField ≤ sqrtNegTwoField ⊔ gaussianField from le_sup_left)

private theorem ne_of_quadratic_sup_eq_top
    {K L : IntermediateField ℚ CyclotomicEight}
    (hK : Module.finrank ℚ K = 2)
    (hsup : K ⊔ L = (⊤ : IntermediateField ℚ CyclotomicEight)) :
    K ≠ L := by
  intro h
  have hKtop : K = (⊤ : IntermediateField ℚ CyclotomicEight) := by
    calc
      K = K ⊔ L := by simp [h]
      _ = ⊤ := hsup
  have hdeg : Module.finrank ℚ K = 4 := by
    rw [hKtop, IntermediateField.finrank_top']
    exact cyclotomicEight_ambient_invariants.1
  omega

private theorem sqrtTwoField_ne_sqrtNegTwoField :
    sqrtTwoField ≠ sqrtNegTwoField :=
  ne_of_quadratic_sup_eq_top sqrtTwoField_degree_explicit
    sqrtTwo_sup_sqrtNegTwo_eq_top_explicit

private theorem sqrtTwoField_ne_gaussianField :
    sqrtTwoField ≠ gaussianField :=
  ne_of_quadratic_sup_eq_top sqrtTwoField_degree_explicit
    sqrtTwo_sup_gaussian_eq_top

private theorem sqrtNegTwoField_ne_gaussianField :
    sqrtNegTwoField ≠ gaussianField :=
  ne_of_quadratic_sup_eq_top sqrtNegTwoField_degree_explicit
    sqrtNegTwo_sup_gaussian_eq_top

/-- The three classical quadratic intermediate fields of `ℚ(ζ₈)/ℚ` are pairwise distinct. -/
theorem classicalQuadraticFields_pairwise_distinct :
    sqrtTwoField ≠ sqrtNegTwoField ∧
      sqrtTwoField ≠ gaussianField ∧
      sqrtNegTwoField ≠ gaussianField :=
  ⟨sqrtTwoField_ne_sqrtNegTwoField,
    sqrtTwoField_ne_gaussianField,
    sqrtNegTwoField_ne_gaussianField⟩

/-- Every quadratic intermediate field of `ℚ(ζ₈)/ℚ` is one of the three classical fields:
`ℚ(√2)`, `ℚ(√-2)`, or `ℚ(i)`. The quadratic-degree hypothesis is carried by the
compact subtype `CyclotomicEightQuadraticFields`. -/
private theorem quadraticIntermediateField_eq_classical
    (K : CyclotomicEightQuadraticFields) :
    K.1 = sqrtTwoField ∨ K.1 = sqrtNegTwoField ∨ K.1 = gaussianField := by
  classical
  let A : CyclotomicEightQuadraticFields :=
    ⟨sqrtTwoField, sqrtTwoField_degree_explicit⟩
  let B : CyclotomicEightQuadraticFields :=
    ⟨sqrtNegTwoField, sqrtNegTwoField_degree_explicit⟩
  let C : CyclotomicEightQuadraticFields :=
    ⟨gaussianField, gaussianField_degree_explicit⟩
  have hAB : A ≠ B := by
    intro h
    apply sqrtTwoField_ne_sqrtNegTwoField
    simpa [A, B] using congrArg Subtype.val h
  have hAC : A ≠ C := by
    intro h
    apply sqrtTwoField_ne_gaussianField
    simpa [A, C] using congrArg Subtype.val h
  have hBC : B ≠ C := by
    intro h
    apply sqrtNegTwoField_ne_gaussianField
    simpa [B, C] using congrArg Subtype.val h
  letI : Finite CyclotomicEightQuadraticFields :=
    Nat.finite_of_card_ne_zero (by
      rw [cyclotomicEight_quadraticFields_card]
      norm_num)
  letI : Fintype CyclotomicEightQuadraticFields := Fintype.ofFinite _
  let s : Finset CyclotomicEightQuadraticFields := {A, B, C}
  have hs : s.card = 3 := by
    simp [s, hAB, hAC, hBC]
  have htype : Fintype.card CyclotomicEightQuadraticFields = 3 := by
    rw [← Nat.card_eq_fintype_card]
    exact cyclotomicEight_quadraticFields_card
  have hsuniv : s = Finset.univ :=
    Finset.eq_univ_of_card s (hs.trans htype.symm)
  have hK : K ∈ s := by
    rw [hsuniv]
    simp
  simp only [s, Finset.mem_insert, Finset.mem_singleton] at hK
  rcases hK with hKA | hKB | hKC
  · exact Or.inl (by
      simpa [A] using congrArg Subtype.val hKA)
  · exact Or.inr (Or.inl (by
      simpa [B] using congrArg Subtype.val hKB))
  · exact Or.inr (Or.inr (by
      simpa [C] using congrArg Subtype.val hKC))


/-- The set of all degree-two intermediate fields of the eighth cyclotomic extension. -/
def cyclotomicEightQuadraticFieldSet :
    Set (IntermediateField ℚ CyclotomicEight) :=
  {K | Module.finrank ℚ K = 2}

/-- The three explicitly constructed classical quadratic fields. -/
def classicalQuadraticFieldSet :
    Set (IntermediateField ℚ CyclotomicEight) :=
  {sqrtTwoField, sqrtNegTwoField, gaussianField}

/-- The quadratic intermediate fields of `ℚ(ζ₈)/ℚ` are exactly
`ℚ(√2)`, `ℚ(√-2)`, and `ℚ(i)`. -/
theorem cyclotomicEight_quadraticFieldSet_eq_classical :
    cyclotomicEightQuadraticFieldSet = classicalQuadraticFieldSet := by
  ext K
  constructor
  · intro hK
    have hdeg : Module.finrank ℚ K = 2 := by
      simpa [cyclotomicEightQuadraticFieldSet] using hK
    have hclass :=
      quadraticIntermediateField_eq_classical
        (⟨K, hdeg⟩ : CyclotomicEightQuadraticFields)
    rcases hclass with h | h | h
    · simp [classicalQuadraticFieldSet, h]
    · simp [classicalQuadraticFieldSet, h]
    · simp [classicalQuadraticFieldSet, h]
  · intro hK
    have hclass :
        K = sqrtTwoField ∨ K = sqrtNegTwoField ∨ K = gaussianField := by
      simpa [classicalQuadraticFieldSet] using hK
    change Module.finrank ℚ K = 2
    rcases hclass with h | h | h
    · simpa [h] using sqrtTwoField_degree_explicit
    · simpa [h] using sqrtNegTwoField_degree_explicit
    · simpa [h] using gaussianField_degree_explicit

end

end LeanFrontier.NumberTheory.DiscriminantTower
