# Use Woodpecker for the CI pilot

Use [Woodpecker](https://woodpecker-ci.org/) at <https://ci.igas.dev> for a `stdlib`-only CI pilot because of cost and GitHub Actions availability constraints.
The pilot uses existing, owner-managed hardware and containerized workers in a Kubernetes cluster, with no new paid infrastructure.
The owner manages worker isolation, capacity, and operations.

Run the checks covered by `mise run check` as independent typecheck, lint, format, tests, and hook-validation workflows on pull requests and pushes to `main`.
Each workflow reports its own GitHub status so a failure in one category does not prevent the others from running.
Require manual approval before running fork pull requests, and keep PR validation free of publishing and deployment credentials.
Publishing and deployment remain outside the pilot.

Passing statuses from every PR CI workflow are required to merge, with no bypass.
CI outages therefore block merges; this is an accepted trade-off.
