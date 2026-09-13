# LeanFrontier fork — agent entry point

This file is the stable handoff for a new AI-agent session working on the `qazW12345/LeanFrontier` fork.

**Read this file first, then verify live GitHub state before acting.** Commit SHAs, PR numbers, CI states, and current targets below are checkpoints, not timeless truth.

## 1. Project and trust model

- Upstream: `carlok/LeanFrontier`
- Working fork: `qazW12345/LeanFrontier`
- LeanFrontier is a library of machine-generated, kernel-verified Lean mathematics.
- The upstream submission contract and receiver are authoritative. Do not weaken or patch trusted receiver rules just to make a candidate pass.
- Before producing an ordinary mathematical submission, read current upstream versions of:
  1. `CONTRACT.md`
  2. `prompts/SUBMITTER.md`
  3. `README.md`
  4. `prompts/TRY-LEANFRONTIER-EXTEND.md` for extension work
  5. the catalogue and the accepted source/claim being extended

Ordinary submissions may change only ordinary Lean source under `LeanFrontier/` plus exactly one new `Submissions/<submission-id>.json` claim. They must not modify workflows, tools, policy, schema, prompts, tests, toolchain files, or other trusted infrastructure.

## 2. Fork branch discipline

The fork deliberately separates upstream mathematics from fork-only operations.

- `main` — keep as an exact mirror of current `carlok/LeanFrontier:main`. Do not put OCI workflows, handoff files, or other fork-only material here.
- `submission/*` — ordinary mathematical candidates, always based on clean current `main`.
- `ops/oci-validator` — fork-only OCI validation workflow, operational documentation, and this handoff file.
- `archive/oci-validator-pre-sync-2026-09-13` — preserved historical fork state from before the branch-discipline cleanup.

Before starting a new mathematical candidate, verify that fork `main` and upstream `main` still match. If upstream has moved, sync the fork first, then branch from that exact clean baseline.

## 3. Preferred agent workflow

The human operator prefers the agent to own the GitHub/CI repair loop rather than asking for shell copy/paste when GitHub tooling can do the work.

For a mathematical candidate:

1. Inspect current upstream contract, submitter instructions, catalogue, relevant accepted module, and claim.
2. Choose or refine a meaningful theorem statement.
3. Create/update the `submission/*` branch through GitHub.
4. Keep a fork-local **draft PR** to `qazW12345/LeanFrontier:main` as a development/CI harness when useful.
5. Let GitHub Actions compile/validate the exact candidate.
6. Inspect job logs and receiver diagnostics.
7. Repair the Lean source or claim yourself and push a new exact candidate commit.
8. Repeat until the receiver accepts.
9. Perform an adversarial self-review of the theorem statement and proof boundary before treating it as ready upstream.
10. Only then open the real upstream PR.

Use the GitHub connector and CI/OCI runner directly whenever possible. Ask the human for OCI shell commands only when the required action genuinely cannot be performed through GitHub or the available runner workflow.

## 4. OCI / Lean environment

The free-tier OCI ARM64 host is already capable of building LeanFrontier.

Known environment from the 2026-09-13 setup:

- 2 ARM Neoverse-N1 vCPUs
- ~11 GiB RAM
- Lean 4.33.1 active for the current LeanFrontier release
- persistent Elan cache: `/srv/mathgraph-data/leanfrontier/cache/elan`
- persistent Mathlib archive cache: `/srv/mathgraph-data/leanfrontier/cache/mathlib`
- persistent development checkout: `/srv/mathgraph-data/leanfrontier/dev/work`
- self-hosted runner: `leanfrontier-runner`

The development checkout completed a full `lake build` successfully with **2296 jobs**. The persistent development `.lake` tree was ~7.7 GiB; Elan ~3.0 GiB; Mathlib archive cache ~440 MiB at that checkpoint.

The fork-only OCI workflow on `ops/oci-validator` was improved to:

- keep Elan persistently cached;
- keep Mathlib `.ltar` downloads persistently cached;
- serialize expensive validation;
- use disposable per-run `validation-*` workspaces;
- always remove those disposable workspaces, including after failure;
- retain the receiver report as a workflow artifact.

Do not reintroduce unbounded `validation-*` accumulation. Five stale validation trees previously consumed roughly 53 GiB.

### Known OCI receiver limitation

A known-good accepted Nesbitt candidate built successfully, passed kernel recheck and duplicate checks, but the final trusted receiver failed on the **fixed 30-second downstream-import smoke-test timeout** on the slow 2-core ARM host. Increasing the container memory limit did not change that. Treat this as an OCI performance limitation unless later evidence says otherwise; do **not** weaken or locally patch the trusted receiver rule merely to obtain acceptance.

The normal development/compile loop on OCI remains useful even if final canonical receiver acceptance has to come from faster upstream CI.

## 5. Mathematical direction preference

The human operator prefers **extensions that compose existing LeanFrontier mathematics** over isolated, unconnected theorems when both are reasonable.

A prior agent survey identified several worthwhile extension directions:

- Markov-tree descent/generation from the accepted Markov-equation/Vieta-jumping module;
- a Ford-circle bridge to Mathlib geometric tangency;
- Stern–Brocot / Calkin–Wilf positive-rational structure;
- Thue–Morse cube-freeness.

The agent recommended the Markov-tree direction as the best balance of mathematical interest, reuse of accepted LeanFrontier results, and likely feasibility. The human then selected that recommended option from the agent-proposed shortlist.

Under the LeanFrontier provenance rules, that human choice does **not** make the formal statement or proof human-authored. If the agent writes the formal theorem statement and proof, `statement_origin` and `proof_origin` remain `machine`; the human's role belongs in `source_context`.

## 6. Current Markov extension checkpoint

As of 2026-09-13, work is on:

- branch: `submission/markov-tree-descent`
- fork-local development PR: `qazW12345/LeanFrontier#2`
- candidate checkpoint: `0b5639d85382e0d7a2e1ed0160bcddd61614c845`
- base checkpoint: upstream/fork `main` at `9f708c18fccb311646b10af124c60ca70e41857b`

The candidate adds exactly:

- `LeanFrontier/NumberTheory/MarkovTree.lean`
- `Submissions/markov-tree-descent.json`

The public entrypoint is intended to be:

`LeanFrontier.MarkovTree.jump_descends_ordered_positive`

The goal is the local Markov-tree descent step: for a positive ordered Markov triple `x ≤ y ≤ z`, away from `(1,1,1)`, the Vieta jump in the largest coordinate remains positive, lies at or below the middle coordinate, and therefore strictly decreases the largest coordinate.

This is a genuine extension of the accepted `LeanFrontier.NumberTheory.MarkovEquation` API and is intended to use existing results such as `jump_pos` and `mul_jump_eq` rather than restating the Vieta involution.

The claim provenance records that:

- the agent surveyed several extension targets;
- the agent recommended Markov-tree descent;
- the human selected that recommendation from the shortlist;
- the formal statement and proof were authored by GPT-5.6 Sol / ChatGPT;
- no claim of new mathematics is made.

At the last checkpoint:

- ordinary `test` workflow: **PASS**
- `validate-submission` workflow for commit `0b5639d...`: **in progress**

A new agent must re-check the live PR head and workflow states rather than assuming those statuses remain current.

## 7. What to do when resuming

On a fresh session, do this before changing anything:

1. Read this file from `ops/oci-validator`.
2. Fetch current upstream `carlok/LeanFrontier:main` and fork `qazW12345/LeanFrontier:main`; confirm whether they still match.
3. Inspect open `submission/*` branches and fork PRs, especially PR #2 if it still exists.
4. Resolve the exact current candidate SHA.
5. Inspect all CI/receiver runs attached to that exact SHA.
6. If validation failed, read the full failing job log and repair only the mathematical source/claim as appropriate.
7. If validation passed, adversarially review the statement and proof for edge cases, hidden assumptions, accidental weakening, degeneracy, near-duplication, and whether the theorem genuinely depends on the accepted parent module.
8. Keep the ordinary submission limited to Lean source + exactly one claim file.
9. Do not merge the fork-local development PR merely because CI passes; it exists as a harness. Open the actual upstream PR only when the candidate is ready and receiver-compliant.

## 8. Important operating principle

The desired loop is:

`inspect live state → formulate/repair Lean → commit exact candidate → CI/receiver → inspect diagnostics → repair → repeat → adversarial review → upstream PR`

Do not substitute prose confidence for Lean/kernel evidence, and do not ask the human to manually relay information that GitHub/CI can provide directly.
