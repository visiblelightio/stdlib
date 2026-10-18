# CI

The [Woodpecker pilot decision](../adr/0001-woodpecker-ci-pilot.md) uses <https://ci.igas.dev> and existing owner-managed Kubernetes workers.
The owner manages hardware, capacity, worker isolation, and operations.

## Pipeline

The workflows in `.woodpecker/` run independently on pull requests and pushes to `main`, with a separate GitHub status for each category.
They use an official mise Debian image pinned by version and multi-platform digest and install the tools in `mise.toml`.
Workflows that run package commands also install npm dependencies with `npm ci`.
Together they cover the same checks as `mise run check`:

- `Typecheck` checks source and tooling types.
- `Lint` runs Oxlint.
- `Format` checks Oxfmt, Terraform and Pkl formatting, trailing whitespace, and final newlines.
- `Tests` runs the package-consumption test and Bats commit-message regression tests.
- `Hooks` validates the hook configuration with warnings denied.

There are no workflow dependencies, so a lint failure does not prevent tests or other checks from running.
Each workflow has its own checkout and tool installation; this trades repeated setup for independent results without shared build state.
No publishing or deployment runs in CI.

The image supports Linux amd64 and arm64.
Verify installation of the pinned tools on the actual worker architecture during rollout.
Workers need access to GHCR, tool downloads, GitHub releases for Pkl packages, and the npm registry.
The pipeline requests no secrets, privileged mode, host mounts, or shared caches.

To lint the workflows with a Woodpecker 3.19 CLI:

```sh
woodpecker-cli lint .woodpecker/*.yaml
```

## GitHub status names

The instance reports `Typecheck (pr)`, `Lint (pr)`, `Format (pr)`, `Tests (pr)`, and `Hooks (pr)` as GitHub status contexts.
Woodpecker derives workflow names from the case-sensitive YAML filenames, not the step names.
To remove the default `ci/woodpecker/pr/` prefix, configure this environment variable on the Woodpecker server and redeploy it:

```yaml
WOODPECKER_STATUS_CONTEXT_FORMAT: "{{ .workflow }} ({{ .event }})"
```

This server-wide setting affects every repository on the instance and cannot be configured in this repository's workflow YAML.
The event suffix keeps PR statuses separate from push statuses for the same commit SHA.
Verify the final names before configuring required statuses, and update any existing requirements when changing names.

## Activate and verify

Repository activation and settings require authenticated Woodpecker repository-admin access.
These settings are outside this repository's GitHub Terraform configuration.

1. Sign in to <https://ci.igas.dev> with GitHub and activate `visiblelightio/stdlib`.
   Keep the default pipeline path so Woodpecker discovers all workflows in `.woodpecker/`.
2. Enable pull request and push events.
   Set pipeline approval to **forks**, with no approval-exempt users.
   Review fork changes before approving each pipeline.
   Approval permits execution of contributor-controlled code, including modified CI commands.
3. Leave trusted capabilities disabled and do not add publishing, deployment, or infrastructure credentials to PR builds.
   Keep secret access for pull request events disabled.
   Confirm that the instance restricts credential-bearing clone plugins to its trusted plugin allowlist.
4. Confirm that Kubernetes workers can pick up every workflow, pull the pinned image, and install every pinned tool.
5. Open a same-repository PR and verify successful runs and a separate GitHub commit status for each workflow.
   Introduce deliberate failures in each category, confirm its status becomes failing while the other workflows still run, then restore the passing changes.
6. Open a fork PR and verify that it waits for approval without running its commands.
   Review and approve it, then confirm all workflows run successfully and report the same PR status contexts as a same-repository PR.
7. After merging the pipeline, verify that a push to `main` runs validation too.

## Require passing PR CI

`woodpecker_pr_status_contexts` in `infra/github/variables.tf` contains the five PR contexts observed on GitHub.
Applying the GitHub Terraform configuration makes every context required on `main`.

1. Read the exact PR status contexts from actual runs of all five workflows.
   With the server format above, require `Typecheck (pr)`, `Lint (pr)`, `Format (pr)`, `Tests (pr)`, and `Hooks (pr)`.
   If the server still uses its default format, the contexts will instead have the `ci/woodpecker/pr/` prefix.
   Configure the server format first so those prefixed names do not become required.
2. When changing workflow names or the server format, update the variable's committed default to the complete set of observed PR contexts through a PR.
   Keeping these values in Git avoids relying on a one-off local override for future Terraform runs.
3. Run `mise run infra:github:plan`, review the required-status change, and apply it with `mise run infra:github:apply` after confirmation.
4. Verify that any failing or pending PR workflow status blocks merging, including for administrators.

The existing `main` ruleset has no bypass actors, and adding the status requirements must preserve that policy.
Do not set a GitHub App integration ID for Woodpecker's OAuth-based commit statuses.
Once enforced, an instance outage, unavailable worker, unapproved fork pipeline, or skipped CI run blocks merging.
Restore CI and obtain a passing run rather than introducing an outage bypass.
