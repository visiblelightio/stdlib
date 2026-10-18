# CI

The [Woodpecker pilot decision](../adr/0001-woodpecker-ci-pilot.md) uses <https://ci.igas.dev> and existing owner-managed Kubernetes workers.
The owner manages hardware, capacity, worker isolation, and operations.

## Pipeline

`.woodpecker/check.yaml` runs on pull requests and pushes to `main`.
It uses an official mise Debian image pinned by version and multi-platform digest, installs the tools in `mise.toml`, installs npm dependencies with `npm ci`, and runs `mise run check`.
This covers package typechecking, linting, formatting, package-consumption tests, and repository hook file checks.
No publishing or deployment runs in CI.

The image supports Linux amd64 and arm64.
Verify installation of the pinned tools on the actual worker architecture during rollout.
Workers need access to GHCR, tool downloads, GitHub releases for Pkl packages, and the npm registry.
The pipeline requests no secrets, privileged mode, host mounts, or shared caches.

To lint the workflow with a Woodpecker 3.19 CLI:

```sh
woodpecker-cli lint .woodpecker/check.yaml
```

## Activate and verify

Repository activation and settings require authenticated Woodpecker repository-admin access.
These settings are outside this repository's GitHub Terraform configuration.

1. Sign in to <https://ci.igas.dev> with GitHub and activate `visiblelightio/stdlib`.
   Keep the default pipeline path so Woodpecker discovers `.woodpecker/check.yaml`.
2. Enable pull request and push events.
   Set pipeline approval to **forks**, with no approval-exempt users.
   Review fork changes before approving each pipeline.
   Approval permits execution of contributor-controlled code, including modified CI commands.
3. Leave trusted capabilities disabled and do not add publishing, deployment, or infrastructure credentials to PR builds.
   Keep secret access for pull request events disabled.
   Confirm that the instance restricts credential-bearing clone plugins to its trusted plugin allowlist.
4. Confirm that a Kubernetes worker can pick up the workflow, pull the pinned image, and install every pinned tool.
5. Open a same-repository PR and verify a successful run and its GitHub commit status.
   Introduce a deliberate check failure, confirm the status becomes failing, then restore the passing change.
6. Open a fork PR and verify that it waits for approval without running its commands.
   Review and approve it, then confirm it runs successfully and reports the same PR status context.
7. After merging the pipeline, verify that a push to `main` runs validation too.

## Require passing PR CI

The rollout is incomplete until the verified PR status is required on `main`.
`woodpecker_pr_status_context` in `infra/github/variables.tf` defaults to `null` only to avoid blocking merges before the instance is configured and verified.

1. Read the exact PR status context from an actual run.
   Woodpecker's default for this workflow is `ci/woodpecker/pr/check`, but the instance can override it.
   Do not use the separate push status, normally `ci/woodpecker/push/check`.
2. In a follow-up PR, change the variable's committed default from `null` to the observed PR context.
   Keeping this value in Git avoids relying on a one-off local override for future Terraform runs.
3. Run `mise run infra:github:plan`, review the required-status change, and apply it with `mise run infra:github:apply` after confirmation.
4. Verify that a failing or pending PR status blocks merging, including for administrators.

The existing `main` ruleset has no bypass actors, and adding the status requirement must preserve that policy.
Do not set a GitHub App integration ID for Woodpecker's OAuth-based commit statuses.
Once enforced, an instance outage, unavailable worker, unapproved fork pipeline, or skipped CI run blocks merging.
Restore CI and obtain a passing run rather than introducing an outage bypass.
