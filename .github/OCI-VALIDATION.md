# Fork OCI validation operations

This branch is fork-only operational infrastructure. It must never be used as the base of an ordinary LeanFrontier mathematical submission.

## Branch discipline

- `main` mirrors `carlok/LeanFrontier:main` exactly. Do not add fork-only commits to it.
- Create ordinary mathematical branches (`submission/...`) from the exact current `main` commit after synchronizing it with upstream.
- Ordinary submission branches follow upstream `CONTRACT.md`: mathematical Lean source beneath `LeanFrontier/` plus exactly one new `Submissions/<id>.json`; no fork workflow or ops changes.
- `ops/oci-validator` contains the OCI-only validation harness.
- `archive/oci-validator-pre-sync-2026-09-13` preserves the former fork `main` and its original OCI harness history.

## Run an OCI validation

1. Synchronize fork `main` to the exact current upstream `carlok/LeanFrontier:main` SHA.
2. Create/update the mathematical candidate on a `submission/...` branch derived from that exact base.
3. Record the exact 40-hex upstream base SHA and exact 40-hex candidate SHA in `.github/oci-validation-target` on `ops/oci-validator`.
4. Change `REQUEST_ID` as well when intentionally rerunning the same SHA pair.
5. Commit only that control-file update on `ops/oci-validator`. Its push triggers `.github/workflows/validate-oci.yml`.
6. Require the OCI workflow and the trusted receiver report to pass before opening the upstream PR.

The workflow checks out trusted receiver code directly from `carlok/LeanFrontier` and the candidate from `qazW12345/LeanFrontier`, verifies both resolved SHAs, serializes OCI validations, reuses a persistent Elan/toolchain cache at `/srv/mathgraph-data/leanfrontier/cache/elan`, uploads the receiver report, and removes the disposable per-run validation workspace even on failure.

Do not make the per-candidate `.lake` tree persistent: it belongs to the untrusted/disposable candidate workspace. Only the Elan toolchain cache is shared across runs.
