# Artifact Contract

The accelerator is distributed as `bedrock-self-managed-kb-accelerator-<version>.zip` with a sibling SHA-256 checksum file.

## Reproduction

Use the tool versions declared in `.terraform-version` and `.github/workflows/terraform.yml`, then run:

```bash
make package
```

The command runs all formatting, lint, initialization, validation, and Terraform tests before packaging. The ZIP uses:

- lexically sorted file order;
- fixed timestamps and normalized file permissions;
- no compression, avoiding zlib-version differences;
- explicit exclusion of credentials, state, plans, backend configuration, `.terraform`, and Git metadata; and
- an embedded `ARTIFACT_MANIFEST.json` containing a SHA-256 hash for every source file.

Running `make package` twice from identical source content produces the same archive checksum.

## Verification

```bash
cd dist
shasum -a 256 -c bedrock-self-managed-kb-accelerator-*.zip.sha256
```

Inspect `ARTIFACT_MANIFEST.json` inside the ZIP when provenance at individual-file level is required.

## Versioning

`VERSION` is the artifact version. Releases use semantic versioning:

- patch: documentation, validation, or backward-compatible fixes;
- minor: backward-compatible modules and examples; and
- major: input, output, state, or deployment-contract changes requiring customer migration.
