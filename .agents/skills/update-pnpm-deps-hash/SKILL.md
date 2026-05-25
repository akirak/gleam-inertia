---
name: update-pnpm-deps-hash
description: Update the Nix `pnpmDeps.hash` value for this repo's client assets derivation by running `nix build .#client`, reading the `got:` hash from a fixed-output mismatch error, patching `assets.nix`, and rerunning the build until it succeeds. Use when `pnpm-lock.yaml` or frontend dependencies changed and the client build fails with a pnpm dependency hash mismatch.
---

# Update pnpmDeps Hash

## Goal

Refresh the `fetchPnpmDeps` fixed-output hash in `assets.nix` for `.#client`.

## Preferred workflow

1. Run `scripts/update-pnpm-deps-hash.sh` from this skill directory while your working directory is the repo root.
2. Let the script run `nix build .#client`.
3. If the build fails with a fixed-output hash mismatch, use the hash after `got:` from the error output.
4. Replace only the `hash = "...";` line inside `pnpmDeps = fetchPnpmDeps { ... };` in `assets.nix`.
5. Re-run `nix build .#client` immediately after changing the hash.
6. Stop when the build succeeds or when the failure is not a hash mismatch anymore.

## Manual fallback

1. Run `nix build .#client`.
2. Find the mismatch message and copy the full hash value after `got:`.
3. Update `assets.nix` so the `pnpmDeps.hash` value matches that `got:` hash.
4. Run `nix build .#client` again to confirm the new hash is correct.

Example mismatch snippet:

```text
specified: sha256-old-value
got:       sha256-new-value
```

Use `sha256-new-value`, not the `specified` value.

## Guardrails

- Run the build from the repository root so `.#client` resolves correctly.
- Do not edit unrelated hashes or package definitions.
- If `nix build .#client` fails for a reason other than a fixed-output mismatch, stop and report that failure instead of guessing.
- Preserve existing file formatting except for the hash value itself.
