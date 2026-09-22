import LeanFrontier.NumberTheory.SternDiatomic
import Mathlib.Data.Nat.Fib.Basic
import Mathlib.Tactic.NormNum

/-!
# Extremal values in dyadic rows of Stern's diatomic sequence

Stern's diatomic sequence has a classical Fibonacci extremal law: on the dyadic row

`2^r ≤ n < 2^(r+1)`,

the largest value of `fusc n` is `fib (r + 2)`.

The proof uses a stronger adjacent-pair invariant. On row `r`, both entries of every
consecutive pair are at most `F_(r+2)`, while their sum is at most `F_(r+3)`. The two
halving identities for `fusc` propagate exactly these bounds to the next row.

Attainment is proved separately rather than inferred from finiteness: an extremal adjacent
Fibonacci pair is propagated down alternating even/odd children. The public theorem therefore
states both the upper bound and an explicit existential witness, making the Fibonacci value a
genuine maximum rather than merely a bound.
-/

namespace LeanFrontier.SternDiatomic

private theorem dyadic_pair_bounds :
    ∀ r n : ℕ, (2 ^ r ≤ n ∧ n < 2 ^ (r + 1)) →
      fusc n ≤ Nat.fib (r + 2) ∧
      fusc (n + 1) ≤ Nat.fib (r + 2) ∧
      fusc n + fusc (n + 1) ≤ Nat.fib (r + 3) := by
  intro r
  induction r with
  | zero =>
      intro n hrow
      rcases hrow with ⟨hlo, hi⟩
      have hn : n = 1 := by
        norm_num at hlo hi
        omega
      subst n
      norm_num [fusc, Nat.fib]
  | succ r ih =>
      intro n hrow
      rcases hrow with ⟨hlo, hi⟩
      change 2 ^ (r + 1) ≤ n at hlo
      change n < 2 ^ (r + 2) at hi
      change
        fusc n ≤ Nat.fib (r + 3) ∧
          fusc (n + 1) ≤ Nat.fib (r + 3) ∧
          fusc n + fusc (n + 1) ≤ Nat.fib (r + 4)
      have hp₁ : 2 ^ (r + 1) = 2 ^ r * 2 := by
        rw [pow_succ]
      have hp₂ : 2 ^ (r + 2) = 2 ^ (r + 1) * 2 := by
        have hidx : r + 2 = (r + 1) + 1 := by omega
        rw [hidx, pow_succ]
      have hmono : Nat.fib (r + 2) ≤ Nat.fib (r + 3) :=
        Nat.fib_mono (by omega)
      have hrec : Nat.fib (r + 4) = Nat.fib (r + 2) + Nat.fib (r + 3) := by
        have h := (Nat.fib_add_two (n := r + 2))
        have h₁ : r + 2 + 2 = r + 4 := by omega
        have h₂ : r + 2 + 1 = r + 3 := by omega
        rw [h₁, h₂] at h
        exact h
      rcases Nat.even_or_odd' n with ⟨k, hk | hk⟩
      · subst hk
        have hklo : 2 ^ r ≤ k := by omega
        have hkhi : k < 2 ^ (r + 1) := by omega
        rcases ih k ⟨hklo, hkhi⟩ with ⟨ha, hb, hab⟩
        rw [fusc_two_mul, fusc_two_mul_add_one]
        exact ⟨ha.trans hmono, hab, by omega⟩
      · subst hk
        have hklo : 2 ^ r ≤ k := by omega
        have hkhi : k < 2 ^ (r + 1) := by omega
        rcases ih k ⟨hklo, hkhi⟩ with ⟨ha, hb, hab⟩
        have hsucc : 2 * k + 1 + 1 = 2 * (k + 1) := by omega
        rw [fusc_two_mul_add_one, hsucc, fusc_two_mul]
        exact ⟨hab, hb.trans hmono, by omega⟩

private theorem exists_dyadic_extremal_pair :
    ∀ r : ℕ, ∃ n : ℕ,
      2 ^ r ≤ n ∧ n < 2 ^ (r + 1) ∧
        ((fusc n = Nat.fib (r + 2) ∧ fusc (n + 1) = Nat.fib (r + 1)) ∨
          (n + 1 < 2 ^ (r + 1) ∧
            fusc n = Nat.fib (r + 1) ∧ fusc (n + 1) = Nat.fib (r + 2))) := by
  intro r
  induction r with
  | zero =>
      refine ⟨1, by norm_num, by norm_num, Or.inl ?_⟩
      norm_num [fusc, Nat.fib]
  | succ r ih =>
      obtain ⟨n, hlo, hi, horient⟩ := ih
      have hp₁ : 2 ^ (r + 1) = 2 ^ r * 2 := by
        rw [pow_succ]
      have hp₂ : 2 ^ (r + 2) = 2 ^ (r + 1) * 2 := by
        have hidx : r + 2 = (r + 1) + 1 := by omega
        rw [hidx, pow_succ]
      have hrec : Nat.fib (r + 3) = Nat.fib (r + 1) + Nat.fib (r + 2) := by
        have h := (Nat.fib_add_two (n := r + 1))
        have h₁ : r + 1 + 2 = r + 3 := by omega
        have h₂ : r + 1 + 1 = r + 2 := by omega
        rw [h₁, h₂] at h
        exact h
      rcases horient with hforward | hbackward
      · refine ⟨2 * n, ?_, ?_, Or.inr ⟨?_, ?_, ?_⟩⟩
        · change 2 ^ (r + 1) ≤ 2 * n
          omega
        · change 2 * n < 2 ^ (r + 2)
          omega
        · change 2 * n + 1 < 2 ^ (r + 2)
          omega
        · rw [fusc_two_mul, hforward.1]
        · rw [fusc_two_mul_add_one, hforward.1, hforward.2]
          have hidx : r + 1 + 2 = r + 3 := by omega
          rw [hidx]
          exact (Nat.add_comm _ _).trans hrec.symm
      · refine ⟨2 * n + 1, ?_, ?_, Or.inl ⟨?_, ?_⟩⟩
        · change 2 ^ (r + 1) ≤ 2 * n + 1
          omega
        · change 2 * n + 1 < 2 ^ (r + 2)
          omega
        · rw [fusc_two_mul_add_one, hbackward.2.1, hbackward.2.2]
          have hidx : r + 1 + 2 = r + 3 := by omega
          rw [hidx]
          exact hrec.symm
        · have hsucc : 2 * n + 1 + 1 = 2 * (n + 1) := by omega
          rw [hsucc, fusc_two_mul, hbackward.2.2]

/-- The maximum value of Stern's diatomic sequence on the half-open dyadic row
`2^r ≤ n < 2^(r+1)` is the Fibonacci number `fib (r + 2)`.

The first conjunct states the row-wide upper bound; the second gives an index in the same row
where equality is attained. -/
theorem fusc_dyadic_row_maximum (r : ℕ) :
    (∀ n : ℕ, (2 ^ r ≤ n ∧ n < 2 ^ (r + 1)) → fusc n ≤ Nat.fib (r + 2)) ∧
      ∃ n : ℕ, 2 ^ r ≤ n ∧ n < 2 ^ (r + 1) ∧ fusc n = Nat.fib (r + 2) := by
  constructor
  · intro n hrow
    exact (dyadic_pair_bounds r n hrow).1
  · obtain ⟨n, hlo, hi, horient⟩ := exists_dyadic_extremal_pair r
    rcases horient with hforward | hbackward
    · exact ⟨n, hlo, hi, hforward.1⟩
    · refine ⟨n + 1, ?_, hbackward.1, hbackward.2.2⟩
      omega

end LeanFrontier.SternDiatomic
