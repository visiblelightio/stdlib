# Domain Docs

## Before exploring

This repo uses a single-context layout:

- Read `GLOSSARY.md` at the repo root.
- Read decisions in `docs/adr/` relevant to the work.

If these files are absent, proceed silently.
Domain-modeling creates them lazily when terminology or decisions are resolved.

## Use the glossary's vocabulary

Use defined domain terms in issue titles, proposals, hypotheses, and tests.
Avoid synonyms the glossary explicitly excludes.

For an undefined concept, reconsider whether it fits the project;
note genuine vocabulary gaps for domain-modeling.

## Flag ADR conflicts

If a proposal contradicts an existing ADR, surface the conflict explicitly, naming the ADR and why reopening it is worthwhile.
