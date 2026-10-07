import LeanFrontier.Topology.FurstenbergProfiniteTopology
import Mathlib.Topology.Algebra.Category.ProfiniteGrp.Completion
import Mathlib.Topology.DenseEmbedding

/-!
# The Furstenberg topology inside the additive profinite completion of the integers

The accepted finite-quotient comparison identifies the Furstenberg topology with the topology
jointly induced by all generic finite-index additive quotients of `ℤ`. Mathlib defines the
additive profinite completion as the projective limit of exactly those quotients.

This module identifies the remaining interface directly: the topology induced on `ℤ` by
Mathlib's canonical map into its additive profinite completion is the Furstenberg topology.
Together with Mathlib's density theorem for the canonical map, this packages the map as a dense
inducing of the Furstenberg integers into their profinite completion.
-/

namespace LeanFrontier.Int

open Topology TopologicalSpace

/-- The additive profinite completion of the integers, using Mathlib's generic construction. -/
abbrev intProfiniteCompletion :=
  ProfiniteAddGrp.ProfiniteCompletion.completion (AddGrpCat.of ℤ)

/-- Mathlib's canonical map from the additive group of integers to its profinite completion. -/
def furstenbergProfiniteMap : ℤ → intProfiniteCompletion :=
  ProfiniteAddGrp.ProfiniteCompletion.etaFn (AddGrpCat.of ℤ)

private theorem induced_furstenbergProfiniteMap_eq_genericFiniteQuotientTopology :
    TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion) =
      genericFiniteQuotientTopology := by
  apply le_antisymm
  · rw [genericFiniteQuotientTopology]
    refine le_iInf fun H => ?_
    have heta :
        @Continuous ℤ intProfiniteCompletion
          (TopologicalSpace.induced furstenbergProfiniteMap
            (inferInstance : TopologicalSpace intProfiniteCompletion))
          (inferInstance : TopologicalSpace intProfiniteCompletion)
          furstenbergProfiniteMap :=
      continuous_induced_dom
    have hval :=
      continuous_subtype_val.comp heta
    have hcoord :=
      (continuous_apply H).comp hval
    rw [DiscreteTopology.eq_bot
      (α := (ProfiniteAddGrp.ProfiniteCompletion.diagram (AddGrpCat.of ℤ)).obj H)] at hcoord
    apply Continuous.le_induced
    simpa [
      furstenbergProfiniteMap,
      ProfiniteAddGrp.ProfiniteCompletion.etaFn,
      ProfiniteAddGrp.ProfiniteCompletion.diagram,
      ProfiniteAddGrp.ProfiniteCompletion.finiteAddGrpDiagram,
      ProfiniteAddGrp.ofFiniteAddGrp
    ] using hcoord
  · apply Continuous.le_induced
    change
      @Continuous ℤ intProfiniteCompletion
        genericFiniteQuotientTopology
        (inferInstance : TopologicalSpace intProfiniteCompletion)
        (ProfiniteAddGrp.ProfiniteCompletion.etaFn (AddGrpCat.of ℤ))
    apply continuous_induced_rng.mpr
    exact continuous_pi fun H => by
      rw [DiscreteTopology.eq_bot
        (α := (ProfiniteAddGrp.ProfiniteCompletion.diagram (AddGrpCat.of ℤ)).obj H)]
      have hq :
          @Continuous ℤ (ℤ ⧸ H.toAddSubgroup)
            genericFiniteQuotientTopology
            (⊥ : TopologicalSpace (ℤ ⧸ H.toAddSubgroup))
            (fun x : ℤ => (QuotientAddGroup.mk x : ℤ ⧸ H.toAddSubgroup)) :=
        continuous_iff_le_induced.mpr (iInf_le _ H)
      simpa [
        ProfiniteAddGrp.ProfiniteCompletion.etaFn,
        ProfiniteAddGrp.ProfiniteCompletion.diagram,
        ProfiniteAddGrp.ProfiniteCompletion.finiteAddGrpDiagram,
        ProfiniteAddGrp.ofFiniteAddGrp
      ] using hq

/-- The topology induced on `ℤ` by the canonical map into Mathlib's additive profinite
completion is exactly the Furstenberg topology. -/
theorem furstenbergTopology_eq_induced_profiniteCompletion :
    furstenbergTopology =
      TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion) := by
  rw [induced_furstenbergProfiniteMap_eq_genericFiniteQuotientTopology]
  exact furstenbergTopology_eq_genericFiniteQuotientTopology

/-- The canonical map from the Furstenberg integers into their additive profinite completion is
a dense inducing: it induces exactly the Furstenberg topology and has dense range. -/
theorem isDenseInducing_furstenbergProfiniteMap :
    @IsDenseInducing ℤ intProfiniteCompletion
      furstenbergTopology
      (inferInstance : TopologicalSpace intProfiniteCompletion)
      furstenbergProfiniteMap := by
  refine {
    toIsInducing := ⟨furstenbergTopology_eq_induced_profiniteCompletion⟩
    dense := ?_
  }
  exact ProfiniteAddGrp.ProfiniteCompletion.denseRange (G := AddGrpCat.of ℤ)

end LeanFrontier.Int
