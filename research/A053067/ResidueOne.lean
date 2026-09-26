import Mathlib

/-!
# A053067 research: fixed-width concatenation

Proof scaffolding for the A053067 research branch.

The main algebraic object is the fixed-width append recurrence

  F(q,L,0) = 0
  F(q,L,n+1) = q * F(q,L,n) + (L+n).

When q = 1 in a target semiring (in particular modulo a modulus dividing
q-1), the positional weights disappear and the recurrence is just the sum of
the consecutive block.
-/

namespace LeanFrontier.A053067Research

/-- Concatenate n consecutive values starting at L, using the fixed
positional base q. The definition is algebraic and works in any semiring. -/
def fixedConcat {R : Type*} [Semiring R] (q L : R) : ℕ → R
  | 0 => 0
  | n + 1 => q * fixedConcat q L n + (L + (n : R))

@[simp]
theorem fixedConcat_zero {R : Type*} [Semiring R] (q L : R) :
    fixedConcat q L 0 = 0 := rfl

@[simp]
theorem fixedConcat_succ {R : Type*} [Semiring R] (q L : R) (n : ℕ) :
    fixedConcat q L (n + 1) =
      q * fixedConcat q L n + (L + (n : R)) := rfl

/-- If the append base is 1, fixed-width concatenation is just the ordinary
sum of the consecutive block. -/
theorem fixedConcat_one_eq_sum {R : Type*} [Semiring R] (L : R) (n : ℕ) :
    fixedConcat (1 : R) L n =
      ∑ i ∈ Finset.range n, (L + (i : R)) := by
  induction n with
  | zero =>
      simp
  | succ n ih =>
      rw [fixedConcat_succ, Finset.sum_range_succ, ih]
      simp [add_assoc]

/-- A rewrite-friendly version: any base equal to 1 gives the same ordinary
sum. In applications R = ZMod m and the hypothesis is 10^d = 1. -/
theorem fixedConcat_eq_sum_of_eq_one {R : Type*} [Semiring R]
    (q L : R) (n : ℕ) (hq : q = 1) :
    fixedConcat q L n =
      ∑ i ∈ Finset.range n, (L + (i : R)) := by
  subst q
  exact fixedConcat_one_eq_sum L n


/-- Division-free closed form for n+1 consecutive appended values.

This is the form used throughout the A053067 congruence analysis. Stating the
theorem at n+1 avoids any subtraction on natural-number indices. -/
theorem fixedConcat_closed_succ {R : Type*} [CommRing R]
    (q L : R) (n : ℕ) :
    (q - 1)^2 * fixedConcat q L (n + 1) =
      q^(n + 1) * ((q - 1) * L + 1) -
        ((q - 1) * (L + (n : R)) + q) := by
  induction n with
  | zero =>
      simp [fixedConcat]
      ring
  | succ n ih =>
      calc
        (q - 1)^2 * fixedConcat q L (n + 1 + 1) =
            q * ((q - 1)^2 * fixedConcat q L (n + 1)) +
              (q - 1)^2 * (L + ((n + 1 : ℕ) : R)) := by
                rw [fixedConcat_succ]
                ring
        _ =
            q * (q^(n + 1) * ((q - 1) * L + 1) -
              ((q - 1) * (L + (n : R)) + q)) +
              (q - 1)^2 * (L + ((n + 1 : ℕ) : R)) := by
                rw [ih]
        _ =
            q^((n + 1) + 1) * ((q - 1) * L + 1) -
              ((q - 1) * (L + ((n + 1 : ℕ) : R)) + q) := by
                push_cast
                rw [pow_succ]
                ring

/-- Abstract residue-one criterion.

If the append base and first block value are both 1, the block length also
casts to 1, and the casted index offsets sum to zero, then the complete
fixed-width concatenation is 1. This separates the generic concatenation
algebra from the number-theoretic construction of suitable A053067 indices. -/
theorem fixedConcat_eq_one_of_residue_data {R : Type*} [CommRing R]
    (q L : R) (n : ℕ)
    (hq : q = 1)
    (hL : L = 1)
    (hn : (n : R) = 1)
    (hoffsets : (∑ i ∈ Finset.range n, (i : R)) = 0) :
    fixedConcat q L n = 1 := by
  rw [fixedConcat_eq_sum_of_eq_one q L n hq]
  calc
    (∑ i ∈ Finset.range n, (L + (i : R))) =
        (∑ _i ∈ Finset.range n, L) +
          (∑ i ∈ Finset.range n, (i : R)) := by
            rw [Finset.sum_add_distrib]
    _ = (n : R) * L + (∑ i ∈ Finset.range n, (i : R)) := by
          simp
    _ = 1 := by
          rw [hL, hn, hoffsets]
          simp

/-- Division-free formula for the casted sum of the offsets 0,...,n-1. -/
theorem two_mul_sum_range_cast {R : Type*} [CommRing R] (n : ℕ) :
    2 * (∑ i ∈ Finset.range n, (i : R)) =
      (n : R) * ((n : R) - 1) := by
  induction n with
  | zero =>
      simp
  | succ n ih =>
      rw [Finset.sum_range_succ]
      push_cast
      rw [mul_add, ih]
      ring

/-- If n casts to 1 and 2 is not a zero divisor, the triangular offset
sum vanishes. -/
theorem sum_range_cast_eq_zero_of_cast_eq_one {R : Type*} [CommRing R]
    [NoZeroDivisors R] (n : ℕ) (hn : (n : R) = 1) :
    (∑ i ∈ Finset.range n, (i : R)) = 0 := by
  have htwo :
      2 * (∑ i ∈ Finset.range n, (i : R)) = 0 := by
    rw [two_mul_sum_range_cast, hn]
    ring
  rcases mul_eq_zero.mp htwo with h2 | hsum
  · norm_num at h2
  · exact hsum

/-- In a domain, base 1, start 1, and length congruent to 1 force the
concatenation residue to be 1. -/
theorem fixedConcat_eq_one_of_cast_eq_one {R : Type*} [CommRing R]
    [NoZeroDivisors R] (q L : R) (n : ℕ)
    (hq : q = 1) (hL : L = 1) (hn : (n : R) = 1) :
    fixedConcat q L n = 1 := by
  exact fixedConcat_eq_one_of_residue_data q L n hq hL hn
    (sum_range_cast_eq_zero_of_cast_eq_one n hn)

end LeanFrontier.A053067Research
