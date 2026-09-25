import LeanFrontier.NumberTheory.MarkovTree

/-!
# Coordinate-independent descent in the Markov tree

The accepted local Markov-tree theorem
`LeanFrontier.MarkovTree.jump_descends_ordered_positive` assumes the coordinates have already
been ordered `x ≤ y ≤ z` and then jumps the largest coordinate.

For a reusable tree/path representation, callers should not have to duplicate six coordinate
permutations. This module packages the three possible Vieta moves into one neighbour relation
and lifts the ordered theorem to arbitrary positive Markov triples.

The descent measure is the coordinate sum rather than the maximum. Once the chosen largest
coordinate is replaced by a strictly smaller positive Vieta root, the sum decreases immediately;
this avoids carrying an artificial ordering into later termination arguments.
-/

namespace LeanFrontier.MarkovTree

/-- Two Markov triples are Vieta neighbours when exactly one coordinate is replaced by the
other root of the Markov equation, with the other two coordinates unchanged. -/
def IsVietaNeighbor (x y z x' y' z' : ℤ) : Prop :=
  (x' = MarkovEquation.jump y z x ∧ y' = y ∧ z' = z) ∨
    (x' = x ∧ y' = MarkovEquation.jump x z y ∧ z' = z) ∨
    (x' = x ∧ y' = y ∧ z' = MarkovEquation.jump x y z)

/-- The additive descent measure for a positive Markov triple. -/
def weight (x y z : ℤ) : ℤ := x + y + z

/-- Every positive Markov triple other than the root has a positive Vieta neighbour with
strictly smaller coordinate sum.

This removes the ordering hypothesis from the accepted local descent theorem in one
coordinate-symmetric statement. The proof orders only the two coordinates needed in each of
the six linear-order cases, applies `jump_descends_ordered_positive`, and then returns the
corresponding jump in the original coordinate order. -/
theorem exists_vietaNeighbor_weight_lt
    {x y z : ℤ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (h : MarkovEquation.IsSolution x y z)
    (hne : ¬ (x = 1 ∧ y = 1 ∧ z = 1)) :
    ∃ x' y' z' : ℤ,
      IsVietaNeighbor x y z x' y' z' ∧
        MarkovEquation.IsSolution x' y' z' ∧
        0 < x' ∧ 0 < y' ∧ 0 < z' ∧
        weight x' y' z' < weight x y z := by
  have hyxz : MarkovEquation.IsSolution y x z := by
    have h0 := h
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hxzy : MarkovEquation.IsSolution x z y := by
    have h0 := h
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hyzx : MarkovEquation.IsSolution y z x := by
    have h0 := h
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hzxy : MarkovEquation.IsSolution z x y := by
    have h0 := h
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hzyx : MarkovEquation.IsSolution z y x := by
    have h0 := h
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0

  have hsolX :
      MarkovEquation.IsSolution (MarkovEquation.jump y z x) y z := by
    have hj := MarkovEquation.isSolution_jump hyzx
    have h0 := hj
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hsolY :
      MarkovEquation.IsSolution x (MarkovEquation.jump x z y) z := by
    have hj := MarkovEquation.isSolution_jump hxzy
    have h0 := hj
    unfold MarkovEquation.IsSolution at h0 ⊢
    ring_nf at h0 ⊢
    exact h0
  have hsolZ :
      MarkovEquation.IsSolution x y (MarkovEquation.jump x y z) :=
    MarkovEquation.isSolution_jump h

  rcases le_total x y with hxy | hyx
  · rcases le_total y z with hyz | hzy
    · have hd :=
        jump_descends_ordered_positive hx hxy hyz h hne
      refine
        ⟨x, y, MarkovEquation.jump x y z,
          Or.inr (Or.inr ⟨rfl, rfl, rfl⟩), hsolZ, hx, hy, hd.1, ?_⟩
      unfold weight
      linarith [hd.2.2]
    · rcases le_total x z with hxz | hzx
      · have hne' : ¬ (x = 1 ∧ z = 1 ∧ y = 1) := by
          rintro ⟨hx1, hz1, hy1⟩
          exact hne ⟨hx1, hy1, hz1⟩
        have hd :=
          jump_descends_ordered_positive hx hxz hzy hxzy hne'
        refine
          ⟨x, MarkovEquation.jump x z y, z,
            Or.inr (Or.inl ⟨rfl, rfl, rfl⟩), hsolY, hx, hd.1, hz, ?_⟩
        unfold weight
        linarith [hd.2.2]
      · have hne' : ¬ (z = 1 ∧ x = 1 ∧ y = 1) := by
          rintro ⟨hz1, hx1, hy1⟩
          exact hne ⟨hx1, hy1, hz1⟩
        have hd :=
          jump_descends_ordered_positive hz hzx hxy hzxy hne'
        have hcomm :
            MarkovEquation.jump z x y = MarkovEquation.jump x z y := by
          unfold MarkovEquation.jump
          ring
        have hjpos : 0 < MarkovEquation.jump x z y := by
          rw [← hcomm]
          exact hd.1
        have hjlt : MarkovEquation.jump x z y < y := by
          rw [← hcomm]
          exact hd.2.2
        refine
          ⟨x, MarkovEquation.jump x z y, z,
            Or.inr (Or.inl ⟨rfl, rfl, rfl⟩), hsolY, hx, hjpos, hz, ?_⟩
        unfold weight
        linarith
  · rcases le_total x z with hxz | hzx
    · have hne' : ¬ (y = 1 ∧ x = 1 ∧ z = 1) := by
        rintro ⟨hy1, hx1, hz1⟩
        exact hne ⟨hx1, hy1, hz1⟩
      have hd :=
        jump_descends_ordered_positive hy hyx hxz hyxz hne'
      have hcomm :
          MarkovEquation.jump y x z = MarkovEquation.jump x y z := by
        unfold MarkovEquation.jump
        ring
      have hjpos : 0 < MarkovEquation.jump x y z := by
        rw [← hcomm]
        exact hd.1
      have hjlt : MarkovEquation.jump x y z < z := by
        rw [← hcomm]
        exact hd.2.2
      refine
        ⟨x, y, MarkovEquation.jump x y z,
          Or.inr (Or.inr ⟨rfl, rfl, rfl⟩), hsolZ, hx, hy, hjpos, ?_⟩
      unfold weight
      linarith
    · rcases le_total y z with hyz | hzy
      · have hne' : ¬ (y = 1 ∧ z = 1 ∧ x = 1) := by
          rintro ⟨hy1, hz1, hx1⟩
          exact hne ⟨hx1, hy1, hz1⟩
        have hd :=
          jump_descends_ordered_positive hy hyz hzx hyzx hne'
        refine
          ⟨MarkovEquation.jump y z x, y, z,
            Or.inl ⟨rfl, rfl, rfl⟩, hsolX, hd.1, hy, hz, ?_⟩
        unfold weight
        linarith [hd.2.2]
      · have hne' : ¬ (z = 1 ∧ y = 1 ∧ x = 1) := by
          rintro ⟨hz1, hy1, hx1⟩
          exact hne ⟨hx1, hy1, hz1⟩
        have hd :=
          jump_descends_ordered_positive hz hzy hzx hzyx hne'
        have hcomm :
            MarkovEquation.jump z y x = MarkovEquation.jump y z x := by
          unfold MarkovEquation.jump
          ring
        have hjpos : 0 < MarkovEquation.jump y z x := by
          rw [← hcomm]
          exact hd.1
        have hjlt : MarkovEquation.jump y z x < x := by
          rw [← hcomm]
          exact hd.2.2
        refine
          ⟨MarkovEquation.jump y z x, y, z,
            Or.inl ⟨rfl, rfl, rfl⟩, hsolX, hjpos, hy, hz, ?_⟩
        unfold weight
        linarith

end LeanFrontier.MarkovTree
