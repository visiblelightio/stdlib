# Agent workflow

## Branches

Before editing, inspect the branch and working tree and record the task-start commit as the review baseline.
If checked out on the default branch, create a feature branch before making changes.
Commit on the feature branch and submit changes through a pull request, rather than committing directly to the default branch.

## Review before committing

Review staged changes, unstaged changes, and new files against the recorded baseline before committing.
Distinguish pre-existing user changes from the task's changes.
When an upstream review skill expects committed changes, use the equivalent working-tree diff, including new files, rather than committing just to enable review.
Use the recorded baseline and the task's confirmed requirements unless the user supplies alternatives; ask only when either is genuinely ambiguous.

Run the standards and spec reviews once per substantive implementation batch.
For follow-up edits, review the delta since the last reviewed state instead of repeating the entire PR review.
Use targeted checks during implementation and the full repository check at the end of an implementation batch.
For documentation-only follow-ups, use formatting checks and normal Git hooks rather than repeating the full application test suite.

## Reviewing agent documentation

The documentation reviewer must apply `writing-for-agents` to changes in agent instructions or documents they reference.
Keep guidance that future agents need to perform repository work.
Request removal of completed setup checklists, temporary rollout notes, and descriptions already discoverable from configuration.
Keep one-time execution notes in the PR and decision rationale in ADRs.
Review the document's audience and usefulness, not just its formatting and consistency with existing prose.
