import LeanFrontier.Probability.PaleyZygmund
import Mathlib.Tactic

/-!
# Chung-Erdős second-moment union inequality

For a finite family of events in a finite weighted probability space, the Chung-Erdős
inequality lower-bounds the mass of their union using the first two moments of the number of
occurring events.

In denominator-free form,

`(∑ᵢ P(Aᵢ))² ≤ P(⋃ᵢ Aᵢ) * ∑ᵢ∑ⱼ P(Aᵢ ∩ Aⱼ)`.

The proof is a direct structural application of the accepted finite weighted Paley-Zygmund
inequality at threshold zero.  The observable is the number of events containing the sampled
point.  Its first moment is the sum of event masses, its second moment is the sum of pairwise
intersection masses, and its positive set is exactly the union.

This is a standard second-moment tool in probabilistic combinatorics and supplies a concrete
consumer of the new LeanFrontier probability infrastructure.
-/

open scoped BigOperators

namespace LeanFrontier.FiniteProbability

variable {Ω ι : Type*} [Fintype Ω] [DecidableEq Ω]

/-- **Chung-Erdős inequality for a finite weighted probability space.**

Let `w` be nonnegative weights on a finite sample space with total mass one, and let
`A i` be a finite family of events indexed by `s`. Then the square of the sum of the event
masses is at most the mass of their union times the sum of all pairwise intersection masses.

This product form has no denominator-positivity side condition and is equivalent to the usual
ratio lower bound whenever the pairwise-intersection sum is positive. -/
theorem chungErdos
    (s : Finset ι) (A : ι → Finset Ω) (w : Ω → ℝ)
    (hw : ∀ ω, 0 ≤ w ω)
    (hnorm : ∑ ω : Ω, w ω = 1) :
    (∑ i ∈ s, ∑ ω ∈ A i, w ω) ^ 2 ≤
      (∑ ω ∈ s.biUnion A, w ω) *
        ∑ i ∈ s, ∑ j ∈ s, ∑ ω ∈ A i ∩ A j, w ω := by
  classical

  let count : Ω → ℝ := fun ω =>
    ∑ i ∈ s, if ω ∈ A i then 1 else 0

  have hcount0 (ω : Ω) : 0 ≤ count ω := by
    dsimp [count]
    apply Finset.sum_nonneg
    intro i hi
    split_ifs <;> norm_num

  have hsingle (i : ι) :
      (∑ ω : Ω, w ω * (if ω ∈ A i then (1 : ℝ) else 0)) =
        ∑ ω ∈ A i, w ω := by
    calc
      (∑ ω : Ω, w ω * (if ω ∈ A i then (1 : ℝ) else 0)) =
          ∑ ω : Ω, if ω ∈ A i then w ω else 0 := by
            apply Fintype.sum_congr
            intro ω
            by_cases hω : ω ∈ A i <;> simp [hω]
      _ = ∑ ω ∈ A i, w ω := by
            rw [← Finset.sum_filter]
            simp

  have hmean :
      (∑ ω : Ω, w ω * count ω) =
        ∑ i ∈ s, ∑ ω ∈ A i, w ω := by
    calc
      (∑ ω : Ω, w ω * count ω) =
          ∑ ω : Ω, ∑ i ∈ s,
            w ω * (if ω ∈ A i then (1 : ℝ) else 0) := by
              apply Fintype.sum_congr
              intro ω
              dsimp [count]
              rw [Finset.mul_sum]
      _ = ∑ i ∈ s, ∑ ω : Ω,
            w ω * (if ω ∈ A i then (1 : ℝ) else 0) := by
              rw [Finset.sum_comm]
      _ = ∑ i ∈ s, ∑ ω ∈ A i, w ω := by
              apply Finset.sum_congr rfl
              intro i hi
              exact hsingle i

  have hcount_sq (ω : Ω) :
      count ω ^ 2 =
        ∑ i ∈ s, ∑ j ∈ s,
          (if ω ∈ A i then (1 : ℝ) else 0) *
            (if ω ∈ A j then (1 : ℝ) else 0) := by
    dsimp [count]
    rw [pow_two, Finset.sum_mul_sum]

  have hpair (i j : ι) :
      (∑ ω : Ω,
          w ω *
            ((if ω ∈ A i then (1 : ℝ) else 0) *
              (if ω ∈ A j then (1 : ℝ) else 0))) =
        ∑ ω ∈ A i ∩ A j, w ω := by
    calc
      (∑ ω : Ω,
          w ω *
            ((if ω ∈ A i then (1 : ℝ) else 0) *
              (if ω ∈ A j then (1 : ℝ) else 0))) =
          ∑ ω : Ω, if ω ∈ A i ∩ A j then w ω else 0 := by
            apply Fintype.sum_congr
            intro ω
            by_cases hi : ω ∈ A i <;>
              by_cases hj : ω ∈ A j <;> simp [hi, hj]
      _ = ∑ ω ∈ A i ∩ A j, w ω := by
            rw [← Finset.sum_filter]
            congr 1
            ext ω
            simp

  have hsecond :
      (∑ ω : Ω, w ω * count ω ^ 2) =
        ∑ i ∈ s, ∑ j ∈ s, ∑ ω ∈ A i ∩ A j, w ω := by
    calc
      (∑ ω : Ω, w ω * count ω ^ 2) =
          ∑ ω : Ω, ∑ i ∈ s, ∑ j ∈ s,
            w ω *
              ((if ω ∈ A i then (1 : ℝ) else 0) *
                (if ω ∈ A j then (1 : ℝ) else 0)) := by
            apply Fintype.sum_congr
            intro ω
            rw [hcount_sq]
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro i hi
            rw [Finset.mul_sum]
      _ = ∑ i ∈ s, ∑ ω : Ω, ∑ j ∈ s,
            w ω *
              ((if ω ∈ A i then (1 : ℝ) else 0) *
                (if ω ∈ A j then (1 : ℝ) else 0)) := by
            rw [Finset.sum_comm]
      _ = ∑ i ∈ s, ∑ j ∈ s, ∑ ω : Ω,
            w ω *
              ((if ω ∈ A i then (1 : ℝ) else 0) *
                (if ω ∈ A j then (1 : ℝ) else 0)) := by
            apply Finset.sum_congr rfl
            intro i hi
            rw [Finset.sum_comm]
      _ = ∑ i ∈ s, ∑ j ∈ s, ∑ ω ∈ A i ∩ A j, w ω := by
            apply Finset.sum_congr rfl
            intro i hi
            apply Finset.sum_congr rfl
            intro j hj
            exact hpair i j

  have hcount_pos (ω : Ω) :
      0 < count ω ↔ ω ∈ s.biUnion A := by
    dsimp [count]
    rw [Finset.sum_boole]
    simpa [Finset.card_pos, Finset.filter_nonempty_iff]

  have hfilter :
      (Finset.univ : Finset Ω).filter (fun ω => 0 < count ω) =
        s.biUnion A := by
    ext ω
    simp [hcount_pos]

  have hcore :=
    paleyZygmund
      (s := (Finset.univ : Finset Ω))
      (w := w) (X := count)
      (fun ω _ => hw ω)
      (fun ω _ => hcount0 ω)
      (by simpa using hnorm)
      (θ := 0) (by norm_num) (by norm_num)

  norm_num at hcore
  rw [hmean, hfilter, hsecond] at hcore
  exact hcore

end LeanFrontier.FiniteProbability
