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

end LeanFrontier.A053067Research
