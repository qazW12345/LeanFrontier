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

For a mathematical candidate:

1. Inspect current upstream rules and the relevant accepted mathematics.
2. Formulate a meaningful theorem that genuinely composes or extends the accepted corpus.
3. Create/update a `submission/*` branch through GitHub.
4. Use a fork-local draft PR to `qazW12345/LeanFrontier:main` as a development/CI harness when useful.
5. Let CI compile and validate the exact candidate SHA.
6. Inspect failing job logs/receiver diagnostics directly and repair the Lean source or claim yourself.
7. Repeat until receiver acceptance.
8. Perform an adversarial self-review: actively try edge cases, hidden assumptions, accidental weakening, near-duplication, degenerate families, and cases where the claimed invariant/result could fail.
9. Only after that review passes, open the real upstream PR.
10. Never merge the fork-local development PR merely because its CI is green.

The browser userscript may wake ChatGPT when watched CI completes; nevertheless always re-resolve the live head SHA and CI state through GitHub before acting.

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

A full development `lake build` completed successfully. The fork-only OCI validator uses persistent caches plus disposable per-run `validation-*` workspaces and must always clean those workspaces; stale validator trees previously consumed roughly 53 GiB.

Known OCI limitation: on this slow 2-core ARM host, a known-good submission can hit the trusted receiver's fixed 30-second downstream-import timeout. Do not patch or weaken that trusted rule. Canonical upstream hosted CI is the final authority.

## 5. Provenance rule important for this operator

The human prefers extensions that compose accepted LeanFrontier mathematics. A prior agent survey proposed several directions, including Markov-tree descent, a Ford-circle/Mathlib geometry bridge, Stern–Brocot/Calkin–Wilf structure, and Thue–Morse cube-freeness. The agent recommended Markov-tree descent and the human selected that recommendation from the agent's shortlist.

Under the current LeanFrontier contract, human subject selection from a producer-proposed shortlist is **not** formal statement authorship. If the agent writes the formal Lean statement and proof, `statement_origin` and `proof_origin` remain `machine`; describe the human selection in `source_context`.

## 6. Current Markov-tree extension checkpoint — 2026-09-13

Current candidate:

- branch: `submission/markov-tree-descent`
- exact candidate head: `ca6a1c3b092e56a24292d424c4ba389df72c63c6`
- baseline: upstream and fork `main` were both `9f708c18fccb311646b10af124c60ca70e41857b` when the upstream PR was opened
- fork-local development PR: `qazW12345/LeanFrontier#2` — keep as a draft harness; do **not** merge it
- real upstream PR: `carlok/LeanFrontier#179` — `feat(NumberTheory): add ordered Markov-tree descent`

The candidate changes exactly:

- `LeanFrontier/NumberTheory/MarkovTree.lean`
- `Submissions/markov-tree-descent.json`

Public entrypoint:

`LeanFrontier.MarkovTree.jump_descends_ordered_positive`

Statement: for a positive ordered Markov solution `x ≤ y ≤ z`, excluding `(1,1,1)`, the accepted Vieta jump in the largest coordinate is positive, is at most the middle coordinate, and is therefore strictly below the largest coordinate.

The proof genuinely composes the accepted `LeanFrontier.NumberTheory.MarkovEquation` API, notably `jump_pos` and `mul_jump_eq`; it does not add the two coordinate-permuted jump variants.

### Adversarial review already performed

The exact candidate survived a deliberate statement/proof-boundary review before the upstream PR was opened:

- `(1,1,1)` shows the root exclusion is necessary: its jump is `2`, so descent would fail.
- `(1,1,2)` shows `jump ≤ y` must be non-strict: its jump is `1 = y`.
- The private helper proves that a positive ordered Markov solution with `y = z` is necessarily `(1,1,1)`, so a non-root candidate really has `y < z`.
- The comparison proof uses `z * jump = x² + y²` from the accepted parent module and the factorization `(y-z)(y-jump) = x² + 2y² - 3xy²`.
- With `1 ≤ x ≤ y`, the right-hand side is nonpositive, forcing `jump ≤ y`; combined with `y < z`, this gives strict descent.
- No hidden proof-trust issue remains: the trusted receiver kernel-rechecked the exact theorem.
- Search found no existing upstream Markov-tree descent submission; the accepted MarkovEquation source explicitly left descent ordering for later Markov-tree work.

### Exact-head CI evidence

Fork CI for `ca6a1c3b092e56a24292d424c4ba389df72c63c6`:

- `test` run `34775490375`: PASS
- `validate-submission` run `34775490324`: PASS

Upstream PR #179 CI for the same exact SHA:

- `test` run `34776784578`: PASS
- `validate-submission` run `34776784563`: PASS
- trusted preflight: accepted, no diagnostics
- restricted formal validation: accepted, no diagnostics
- build: pass
- kernel recheck: pass
- downstream import smoke: pass
- Mathlib exact matches: 0
- receiver observed exactly the two ordinary submission files

At this checkpoint upstream PR #179 is open and mergeable, with all required candidate checks green. The submitter login `qazW12345` is **not** in the current upstream auto-merge allowlist (`carlok` and `leanfrontier-receiver[bot]` only), so an accepted outside-author PR is expected to wait for maintainer merge/action. Do not try to bypass that policy.

## 7. What to do when resuming

On a fresh session:

1. Read this file.
2. Re-fetch upstream and fork `main`; do not assume the recorded SHA is still current.
3. Inspect `carlok/LeanFrontier#179` first. If already merged, verify the merge commit and post-merge/current-main state before beginning anything new.
4. If #179 remains open, verify its exact head and current checks/comments/reviews. If the exact accepted head is unchanged and no maintainer-requested change exists, leave it waiting for maintainer action.
5. Keep fork PR #2 unmerged; it is only the development harness.
6. If a maintainer requests changes, repair only the ordinary submission source/claim, rerun exact-head CI, adversarially re-review any changed theorem boundary, and update the upstream PR.
7. Only after the Markov submission is settled should a new extension target be selected.

## 8. Operating principle

`inspect live state → formulate/repair Lean → exact candidate SHA → CI/receiver → inspect diagnostics → repair → adversarial review → upstream PR → maintainer/auto-merge policy`

Do not substitute prose confidence for Lean/kernel evidence, and do not ask the human to manually relay information that GitHub/CI can provide directly.
