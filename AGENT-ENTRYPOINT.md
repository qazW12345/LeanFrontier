# LeanFrontier fork — agent entry point

This is the stable handoff for a new AI-agent session working on `qazW12345/LeanFrontier`.

**Read this file first, then verify live GitHub state before acting.** SHAs, PR states, CI states, and targets below are checkpoints, not timeless truth.

## 1. Project and trust model

- Upstream: `carlok/LeanFrontier`
- Working fork: `qazW12345/LeanFrontier`
- LeanFrontier is a library of machine-generated, kernel-verified Lean mathematics.
- The current upstream contract, submitter prompt, policy, and trusted receiver are authoritative. Never weaken trusted receiver rules merely to make a candidate pass.
- For extension work, read current upstream `CONTRACT.md`, `prompts/SUBMITTER.md`, `README.md`, `prompts/TRY-LEANFRONTIER-EXTEND.md`, the catalogue, and the accepted source/claim being extended.
- An ordinary submission may change mathematical source under `LeanFrontier/` plus exactly one new `Submissions/<submission-id>.json`. It must not modify workflows, tools, policy, schema, prompts, tests, toolchain, generated catalogues, or other trusted infrastructure.

## 2. Fork branch discipline

The fork deliberately separates upstream mathematics from fork-only operations.

- `main` — keep as an exact mirror of current `carlok/LeanFrontier:main`.
- `submission/*` — ordinary mathematical candidates, based on clean current `main`.
- `ops/oci-validator` — fork-only OCI validation workflow, operational documentation, and this handoff file.
- `archive/oci-validator-pre-sync-2026-09-13` — historical fork state from before the branch-discipline cleanup.

Before starting a new candidate, verify fork `main` and upstream `main` still match. If upstream moved, sync the fork first, then branch from that clean baseline.

## 3. Preferred agent workflow

The human operator wants the agent to own the GitHub/CI repair loop rather than asking for shell copy/paste when GitHub tooling can do the work.

For a mathematical candidate, use the OCI diagnostic harness **before** canonical receiver CI. The diagnostic `lake build` exposes actual Lean elaborator/compiler errors, while the trusted receiver may intentionally collapse a compile failure to a generic `BUILD_FAILED` diagnostic.

1. Inspect current upstream rules and the relevant accepted mathematics.
2. Formulate a meaningful theorem that genuinely composes or extends the accepted corpus.
3. Create/update a clean `submission/*` branch from current mirrored `main`.
4. Point `.github/oci-validation-target` on `ops/oci-validator` at the exact trusted base SHA and exact candidate SHA.
5. Run the fork-only OCI diagnostic harness. If `Diagnostic Lake build` fails, inspect the exact Lean diagnostics, repair only the ordinary candidate source/claim, point the harness at the new exact SHA, and repeat.
6. Once the diagnostic build is clean, use a fork-local draft PR to `qazW12345/LeanFrontier:main` for canonical `test` + `validate-submission` receiver checks.
7. Inspect any receiver diagnostics directly and repair the candidate yourself; never weaken trusted validation infrastructure to obtain a pass.
8. After exact-head receiver acceptance, perform an adversarial self-review: actively try edge cases, hidden assumptions, accidental weakening, near-duplication, degenerate families, and cases where the claimed result could fail.
9. Recheck upstream `main` before submission. If it moved, rebase/recreate and revalidate the exact candidate as needed.
10. Only after those gates pass, open the real upstream PR and verify upstream canonical CI on the exact submitted head.
11. Never merge a fork-local development PR merely because its CI is green.

The browser userscript may wake ChatGPT when watched OCI or submission CI completes; nevertheless always re-resolve the live head SHA and CI state through GitHub before acting.

## 4. OCI / Lean environment

The free-tier OCI ARM64 host can build LeanFrontier.

Known environment from 2026-09-13:

- 2 ARM Neoverse-N1 vCPUs
- ~11 GiB RAM
- Lean 4.33.1 for the current LeanFrontier release
- persistent Elan cache: `/srv/mathgraph-data/leanfrontier/cache/elan`
- persistent Mathlib archive cache: `/srv/mathgraph-data/leanfrontier/cache/mathlib`
- persistent development checkout: `/srv/mathgraph-data/leanfrontier/dev/work`
- self-hosted runner: `leanfrontier-runner`

The fork-only OCI validator uses persistent caches plus disposable per-run `validation-*` workspaces and must always clean those workspaces; stale validator trees previously consumed roughly 53 GiB.

A successful Ford-circle run demonstrated the intended diagnostic-first path: the first candidate failed with concrete Lean errors (`noncomputable` definitions plus a residual ring-normalization goal), those errors were repaired, and the replacement exact SHA then passed both `lake build` and restricted formal validation.

Known OCI limitation: on this slow 2-core ARM host, some known-good submissions can hit the trusted receiver's fixed downstream-import timeout. Do not patch or weaken that trusted rule. Canonical upstream hosted CI is the final authority.

## 5. Provenance rules important for this operator

Under the current LeanFrontier contract, `statement_origin` and `proof_origin` describe who authored the formal Lean statement/proof, not merely who chose a topic.

- Markov-tree descent: the agent independently proposed a shortlist and recommended Markov-tree descent; the human selected that recommendation. The agent authored the formal statement/proof, so statement/proof origin remain `machine`, with the human selection described in `source_context`.
- Ford-circle sphere tangency: the human asked only for another independent LeanFrontier extension without naming a subject. The agent inspected the accepted corpus, independently selected the Ford-circle/Mathlib geometry bridge, and authored the formal statement/proof. Its claim therefore uses `origin_mode: autonomous_discovery`, `statement_origin: machine`, and `proof_origin: machine`.

Preserve those distinctions accurately in future edits.

## 6. Markov-tree extension checkpoint — 2026-09-13

Current candidate:

- branch: `submission/markov-tree-descent`
- exact candidate head: `ca6a1c3b092e56a24292d424c4ba389df72c63c6`
- baseline when submitted: `main @ 9f708c18fccb311646b10af124c60ca70e41857b`
- fork-local development PR: `qazW12345/LeanFrontier#2` — draft harness; do **not** merge it
- real upstream PR: `carlok/LeanFrontier#179` — `feat(NumberTheory): add ordered Markov-tree descent`

Changed files:

- `LeanFrontier/NumberTheory/MarkovTree.lean`
- `Submissions/markov-tree-descent.json`

Entrypoint: `LeanFrontier.MarkovTree.jump_descends_ordered_positive`

The exact candidate passed fork and upstream canonical CI. The trusted receiver reported build PASS, kernel recheck PASS, downstream import PASS, zero Mathlib exact matches, and exactly the two ordinary submission files.

Adversarial review already checked the root `(1,1,1)`, the equality edge case `(1,1,2)`, the `y = z` classification, the factorization/order argument, and the absence of coordinate-permuted theorem padding.

At the last checkpoint PR #179 remained open, green, and waiting for maintainer action. Recheck live state before relying on that status.

## 7. Ford-circle Euclidean-sphere extension checkpoint — 2026-09-13

Current candidate:

- branch: `submission/ford-circle-sphere-tangency`
- exact candidate head: `d46c9bbf2a7b78ba72982b6eed627cb7c55facbc`
- trusted/base SHA when submitted: `9f708c18fccb311646b10af124c60ca70e41857b`
- fork-local development PR: `qazW12345/LeanFrontier#3` — draft harness; do **not** merge it
- real upstream PR: `carlok/LeanFrontier#180` — `feat(Geometry): bridge Ford circles to Euclidean sphere tangency`

Changed files exactly:

- `LeanFrontier/Geometry/FordCircleTangency.lean`
- `Submissions/ford-circle-sphere-tangency.json`

Main entrypoint:

`LeanFrontier.FordCircle.isExtTangent_euclideanSphere_iff`

The module represents a Ford circle as a Mathlib `EuclideanGeometry.Sphere ℂ` and proves, for nonzero denominators, that Mathlib external tangency is equivalent to the accepted Ford-circle cross-determinant-square criterion. It composes the accepted `LeanFrontier.NumberTheory.FordCircle` API with Mathlib's `EuclideanGeometry.Sphere.isExtTangent_iff_dist_center` theorem.

### Repair history and diagnostic evidence

The first draft failed compilation. The OCI diagnostic harness exposed the exact issues instead of only `BUILD_FAILED`:

- `euclideanCenter` and `euclideanSphere` needed to be `noncomputable`;
- `dist_euclideanCenter_sq` needed a final `ring` normalization.

The repaired exact head `d46c9bbf...` then passed OCI run `34778283315`:

- trusted preflight: PASS
- diagnostic `lake build`: PASS (`2490` jobs)
- restricted formal validation: PASS
- cleanup: PASS

### Fork canonical CI

For exact head `d46c9bbf...`:

- `test` run `34778277093`: PASS
- `validate-submission` run `34778277095`: PASS
- receiver accepted with no diagnostics
- build: pass
- kernel recheck: pass
- downstream import smoke: pass
- Mathlib exact matches: 0
- exactly the two ordinary submission files observed

### Adversarial review

The exact candidate survived a deliberate theorem/proof/provenance review before upstream submission:

- zero denominators are intentionally excluded because the accepted algebraic equivalence requires nonzero denominators and division by zero would create degenerate objects;
- negative nonzero denominators do not create a radius-sign bug because `radius q = 1/(2*q^2)` is nonnegative;
- the reverse implication does not illicitly infer `a = b` merely from `a^2 = b^2`: the proof establishes nonnegativity of Euclidean distance and both radii before `nlinarith` recovers the unsquared equality;
- corpus search found no existing `IsExtTangent` Ford-circle bridge; the accepted parent source explicitly described that bridge as separate work;
- provenance is `autonomous_discovery` + machine/machine because the agent independently chose this subject after the human asked only for another independent extension.

### Upstream canonical CI

Upstream PR #180 ran canonical CI on the same exact head `d46c9bbf...`:

- `test` run `34779062695`: PASS
- `validate-submission` run `34779062687`: PASS
- trusted preflight: accepted, no diagnostics
- restricted formal validation: accepted, no diagnostics
- build: pass
- kernel recheck: pass
- downstream import smoke: pass
- Mathlib exact matches: 0
- audited main entrypoint: theorem, not alias, not generated, not restatement

At this checkpoint upstream PR #180 is open, non-draft, mergeable, and has no maintainer comments yet. Leave it waiting for maintainer action unless live GitHub shows a new request or changed base state.

## 8. What to do when resuming

On a fresh session:

1. Read this file.
2. Re-fetch upstream and fork `main`; do not assume any recorded SHA is still current.
3. Inspect both upstream PR #179 and PR #180, including exact heads, checks, comments/reviews, merge state, and whether upstream `main` moved.
4. If either PR was merged, verify the actual merge commit and current-main state; do not infer integration merely from a closed PR.
5. Keep fork PRs #2 and #3 unmerged; they are development harnesses only.
6. If a maintainer requests changes, repair only the corresponding ordinary submission source/claim, run the OCI diagnostic harness first on the replacement exact SHA, then canonical receiver CI, adversarially re-review changed boundaries, and update the upstream PR.
7. Independent additional submissions may be developed while these PRs wait, but always start from current upstream-mirrored `main`; if another open PR merges first, re-evaluate/revalidate candidates against the moved base where needed.

## 9. Operating principle

`inspect live state → formulate Lean → OCI diagnostic build → repair loop → canonical receiver → adversarial review → upstream PR → upstream canonical CI → maintainer/auto-merge policy`

Do not substitute prose confidence for Lean/kernel evidence, and do not ask the human to manually relay information that GitHub/CI can provide directly.
