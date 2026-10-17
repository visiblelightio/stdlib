# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `visiblelightio/stdlib`.
Use the `gh` CLI from this clone.

## Issue and PR bodies

When creating or updating an issue or PR, write the body to a temporary Markdown file and pass it with `--body-file`.
Use this instead of inline `--body` text.

- Create issue: `gh issue create --title "..." --body-file <temp.md>`
- Update issue: `gh issue edit <number> --body-file <temp.md>`
- Create PR: `gh pr create --title "..." --body-file <temp.md>`
- Update PR: `gh pr edit <number> --body-file <temp.md>`

## Conventions

- Read: `gh issue view <number> --json number,title,body,labels,comments`.
- List: `gh issue list --state open --json number,title,body,labels,comments`.
  Add appropriate label and state filters.
- Comment: `gh issue comment <number> --body "..."`.
- Label: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close: `gh issue close <number> --comment "..."`.

When a skill says "publish to the issue tracker", create a GitHub issue.
When it says "fetch the relevant ticket", read the issue.

## Pull requests as a triage surface

**PRs as a request surface: no.**

## Wayfinding operations

- Map: one issue labelled `wayfinder:map`, containing Notes, Decisions-so-far, and Fog.
- Child ticket: link as a GitHub sub-issue using `gh issue create --parent <parent> ...` or `gh issue edit <parent> --add-sub-issue <child>`.
- Ticket labels: `wayfinder:<type>`, where type is research, prototype, grilling, or task.
- Blocking: use native GitHub issue dependencies `gh api --method POST repos/visiblelightio/stdlib/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`.
  Obtain database IDs with `gh api repos/visiblelightio/stdlib/issues/<number> --jq .id`.
- Frontier: consider open children in map order;
  exclude assigned tickets and tickets with open blockers.
  Native dependencies expose open blockers through `issue_dependencies_summary.blocked_by`.
- Claim: `gh issue edit <number> --add-assignee @me` as the session's first write.
- Resolve: comment with the answer, close the ticket, then append a summary and link to the map's Decisions-so-far.
