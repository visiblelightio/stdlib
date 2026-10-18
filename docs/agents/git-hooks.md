# Git hooks and commits

## Setup

Enable mise shell integration with `mise activate` using the instructions for your shell.
In a fresh checkout, review the configuration, then run:

```sh
mise trust
mise install
```

After trust, entering this repository with mise shell integration installs missing tools and repository-local hk hooks automatically.
`mise install` also installs the hooks.
Neither changes global Git hook settings or forces replacement of unrelated hooks.
Existing global hk installations are reused.

Without shell integration, run `mise run hooks:install` explicitly.
Git must be able to find `mise` on PATH, including when committing from an IDE.
Hook-install failures appear as mise warnings; rerun the explicit task to diagnose them.

## File checks

Pre-commit automatically fixes Terraform, Pkl, and Oxfmt-supported file formatting, trailing whitespace, and final newlines in staged files, then stages the fixes.
It temporarily stashes unstaged changes and restores them afterward.
If another check fails, formatting fixes may remain in the working tree and index.
Review the fixes and resolve remaining errors before retrying.

Pre-commit also runs the Bats-core shell tests and `hk validate --deny-warnings`.
Both run on every commit, regardless of which files changed, and are included in `hk check --all`.
Package typechecking also runs on every commit, and Oxlint runs when TypeScript files change.
Oxlint rejects warnings and does not automatically fix code.
Run `mise run check` for package tests and formatting checks as well as all hook checks.

To check the whole checkout without changing files:

```sh
hk check --all
```

Terraform formatting does not require initialization or provider downloads.
Oxfmt uses hk's builtin supported-file patterns, including Markdown, TypeScript, JSON, TOML, YAML, and CSS.
Node.js and npm are pinned separately through mise.
Install package development dependencies with `npm ci` before running checks or committing.
To format a Markdown file manually, run `oxfmt --write <file.md>`.
Pkl uses the formatter's default grammar, which hk's embedded evaluator supports.
To format the hook configuration manually, run `pkl format --write hk.pkl`.
These local hooks are bypassable, but the Woodpecker workflows run the same checks separately by category.
The CI pipeline does not validate PR titles or commit messages; the Bats tests validate the commit-message checker itself.

## Commit messages

Use `type: description` or `type(scope): description`.
The allowed types are `chore`, `feat`, `fix`, `revert`, and `style`.

Scopes are optional lowercase names, starting with a letter and containing letters, digits, or hyphens.
Use `build`, `ci`, `docs`, `perf`, `refactor`, and `test` as scopes rather than types.
Project-area scopes such as `github` and `infra` are also allowed.
Multiple scopes must be unique, alphabetically sorted, comma-separated, and have no spaces.

```text
feat: add capability
chore(ci,docs): document hook setup
fix(infra,test): correct configuration
feat(api)!: change interface
```

The checker preserves hk's exemptions for Git-generated merge/revert messages and `fixup!`, `squash!`, and `amend!` prefixes.
It imposes no header-length limit and does not validate bodies or footers.

Run the Bats-core commit-message regression tests with `mise run hooks:test`.
Tests live in `tests/` and use Bats-core's built-in assertions without extra assertion libraries.
The checker and test runner are executable file tasks in `mise-tasks/hooks/`.
To check a message manually, run `mise run hooks:check-commit-message <message-file>`.
