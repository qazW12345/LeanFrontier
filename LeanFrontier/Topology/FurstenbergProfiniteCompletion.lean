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

private theorem diagramObj_topology_eq_bot (H : FiniteIndexNormalAddSubgroup (AddGrpCat.of ℤ)) :
    ((intProfiniteDiagram.obj H).toProfinite.toTop.str) =
      (⊥ : TopologicalSpace (intProfiniteDiagram.obj H)) := by
  haveI : Finite (intProfiniteDiagram.obj H) := by
    change Finite (ℤ ⧸ H.toAddSubgroup)
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
    letI : TopologicalSpace ℤ :=
      TopologicalSpace.induced furstenbergProfiniteMap
        (inferInstance : TopologicalSpace intProfiniteCompletion)
    have heta : Continuous furstenbergProfiniteMap :=
      continuous_induced_dom
    have hcoord :
        Continuous (fun x : ℤ => (furstenbergProfiniteMap x).1 H) :=
      (continuous_apply H).comp (continuous_subtype_val.comp heta)
    rw [diagramObj_topology_eq_bot H] at hcoord
    apply Continuous.le_induced
    simpa [
      furstenbergProfiniteMap,
      intProfiniteDiagram,
      ProfiniteAddGrp.ProfiniteCompletion.diagram,
      ProfiniteAddGrp.ProfiniteCompletion.finiteAddGrpDiagram,
      ProfiniteAddGrp.ofFiniteAddGrp
    ] using hcoord
  · apply Continuous.le_induced
    letI : TopologicalSpace ℤ := genericFiniteQuotientTopology
    change Continuous furstenbergProfiniteMap
    apply continuous_induced_rng.mpr
    exact continuous_pi fun H => by
      rw [diagramObj_topology_eq_bot H]
      change Continuous (fun x : ℤ =>
        (QuotientAddGroup.mk x : ℤ ⧸ H.toAddSubgroup))
      exact continuous_iff_le_induced.mpr (iInf_le _ H)

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
    eq_induced := furstenbergTopology_eq_induced_profiniteCompletion
    dense := ?_
  }
  simpa [
    furstenbergProfiniteMap,
    intProfiniteCompletion,
    intProfiniteDiagram,
    ProfiniteAddGrp.ProfiniteCompletion.completion,
    ProfiniteAddGrp.ProfiniteCompletion.etaFn
  ] using
    (ProfiniteAddGrp.ProfiniteCompletion.denseRange (G := AddGrpCat.of ℤ))

end LeanFrontier.Int
