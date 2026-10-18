# Use Woodpecker for the CI pilot

Use [Woodpecker](https://woodpecker-ci.org/) at <https://ci.igas.dev> for a `stdlib`-only CI pilot because of cost and GitHub Actions availability constraints.
The pilot uses existing, owner-managed hardware and containerized workers in a Kubernetes cluster, with no new paid infrastructure.
The owner manages worker isolation, capacity, and operations.

Run the existing `mise run check` on pull requests and pushes to `main`.
Require manual approval before running fork pull requests, and keep PR validation free of publishing and deployment credentials.
Publishing and deployment remain outside the pilot.

A passing PR CI status will be required to merge, with no bypass.
CI outages will therefore block merges; this is an accepted trade-off.

This records the accepted decision, not a completed rollout.
Before requiring the status, verify the agent environment, fork approval behavior, successful and failing PR runs, and the actual GitHub status context reported by the instance.
