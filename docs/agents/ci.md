# CI

When adding or changing checks, keep `.woodpecker/` workflows aligned with the checks covered by `mise run check`.
Keep check categories independent so a failure in one does not prevent the others from running.
See [ADR 0001](../adr/0001-woodpecker-ci.md) for the CI scope and no-bypass decision.

## Renaming workflows

Woodpecker derives workflow names from case-sensitive YAML filenames, not step names.
Renaming a file changes its GitHub status context and can leave a required check waiting forever.
When renaming workflows, verify the emitted contexts and update `woodpecker_pr_status_contexts` in `infra/github/variables.tf` in the same PR.
Status formatting is controlled by the server outside this repository; do not assume Woodpecker's default prefix.

## Validation

After changing workflow YAML, run `mise run check`, which includes Woodpecker workflow validation.
For a focused check, use:

```sh
mise run ci:lint
```
