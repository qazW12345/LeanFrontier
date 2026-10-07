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

private abbrev intProfiniteDiagram :=
  ProfiniteAddGrp.ProfiniteCompletion.diagram (AddGrpCat.of ℤ)

/-- The additive profinite completion of the integers, using Mathlib's explicit limit
construction for its finite-quotient diagram. This is the defining limit used by
`ProfiniteAddGrp.ProfiniteCompletion.completion`. -/
abbrev intProfiniteCompletion :=
  ProfiniteAddGrp.limit intProfiniteDiagram

/-- The canonical map from the additive group of integers to its profinite completion, written in
the coordinate form used by Mathlib's `ProfiniteAddGrp.ProfiniteCompletion.etaFn`. -/
def furstenbergProfiniteMap (x : ℤ) : intProfiniteCompletion :=
  ⟨fun _ => QuotientAddGroup.mk x, fun _ _ _ => rfl⟩

private theorem diagramObj_type_eq (H : FiniteIndexNormalAddSubgroup (AddGrpCat.of ℤ)) :
    (intProfiniteDiagram.obj H : Type) = (ℤ ⧸ H.toAddSubgroup) := by
  rfl

private def diagramObjEquivQuotient
    (H : FiniteIndexNormalAddSubgroup (AddGrpCat.of ℤ)) :
    (intProfiniteDiagram.obj H : Type) ≃ (ℤ ⧸ H.toAddSubgroup) := by
  change (ℤ ⧸ H.toAddSubgroup) ≃ (ℤ ⧸ H.toAddSubgroup)
  exact Equiv.refl _

set_option linter.style.haveILetI false in
private theorem diagramObj_topology_eq_bot (H : FiniteIndexNormalAddSubgroup (AddGrpCat.of ℤ)) :
    ((intProfiniteDiagram.obj H).toProfinite.toTop.str) =
      (⊥ : TopologicalSpace (intProfiniteDiagram.obj H)) := by
  haveI : Finite (intProfiniteDiagram.obj H) := by
    rw [diagramObj_type_eq H]
    infer_instance
  exact DiscreteTopology.eq_bot

set_option linter.style.haveILetI false in
private theorem induced_furstenbergProfiniteMap_eq_genericFiniteQuotientTopology :
    TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion) =
      genericFiniteQuotientTopology := by
  apply le_antisymm
  · rw [genericFiniteQuotientTopology]
    refine le_iInf fun H => ?_
    let tZ : TopologicalSpace ℤ :=
      TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion)
    change tZ ≤
      (⊥ : TopologicalSpace (ℤ ⧸ H.toAddSubgroup)).induced
        (fun x : ℤ => (QuotientAddGroup.mk x : ℤ ⧸ H.toAddSubgroup))
    letI : TopologicalSpace ℤ := tZ
    have heta : Continuous furstenbergProfiniteMap :=
      continuous_induced_dom
    have hcoord :
        Continuous (fun x : ℤ => (furstenbergProfiniteMap x).1 H) :=
      (continuous_apply H).comp (continuous_subtype_val.comp heta)
    haveI : DiscreteTopology (intProfiniteDiagram.obj H) :=
      ⟨diagramObj_topology_eq_bot H⟩
    letI : TopologicalSpace (ℤ ⧸ H.toAddSubgroup) := ⊥
    letI : DiscreteTopology (ℤ ⧸ H.toAddSubgroup) := ⟨rfl⟩
    have htransport : Continuous (diagramObjEquivQuotient H) :=
      continuous_of_discreteTopology
    have hq := htransport.comp hcoord
    exact Continuous.le_induced <| by
      simpa [diagramObjEquivQuotient, furstenbergProfiniteMap] using hq
  · let tZ : TopologicalSpace ℤ := genericFiniteQuotientTopology
    change tZ ≤
      TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion)
    letI : TopologicalSpace ℤ := tZ
    apply Continuous.le_induced
    change Continuous furstenbergProfiniteMap
    apply continuous_induced_rng.mpr
    exact continuous_pi fun H => by
      letI : TopologicalSpace (ℤ ⧸ H.toAddSubgroup) := ⊥
      letI : DiscreteTopology (ℤ ⧸ H.toAddSubgroup) := ⟨rfl⟩
      have hq :
          Continuous (fun x : ℤ =>
            (QuotientAddGroup.mk x : ℤ ⧸ H.toAddSubgroup)) := by
        unfold tZ
        exact continuous_iff_le_induced.mpr (iInf_le _ H)
      have htransport : Continuous (diagramObjEquivQuotient H).symm :=
        continuous_of_discreteTopology
      have hcoord := htransport.comp hq
      simpa [diagramObjEquivQuotient, furstenbergProfiniteMap] using hcoord

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
  let tZ : TopologicalSpace ℤ := furstenbergTopology
  change @IsDenseInducing ℤ intProfiniteCompletion
    tZ
    (inferInstance : TopologicalSpace intProfiniteCompletion)
    furstenbergProfiniteMap
  letI : TopologicalSpace ℤ := tZ
  have hInducing : IsInducing furstenbergProfiniteMap :=
    ⟨furstenbergTopology_eq_induced_profiniteCompletion⟩
  have hDense : DenseRange furstenbergProfiniteMap := by
    simpa [
      furstenbergProfiniteMap,
      intProfiniteCompletion,
      intProfiniteDiagram,
      ProfiniteAddGrp.ProfiniteCompletion.completion,
      ProfiniteAddGrp.ProfiniteCompletion.etaFn
    ] using
      (ProfiniteAddGrp.ProfiniteCompletion.denseRange (G := AddGrpCat.of ℤ))
  exact ⟨hInducing, hDense⟩

end LeanFrontier.Int
