# @visiblelightio/stdlib

Runtime and type-only utilities for modern, strict TypeScript projects.
Licensed under MIT.

This package is being initialized and does not export any utilities yet.
See [the project goals](docs/goals.md) for admission criteria and release requirements.

## Compatibility

The package publishes native ESM and TypeScript declarations, with no CommonJS build or runtime dependencies.
Only the root import, `@visiblelightio/stdlib`, is public initially.
Internal file paths are not supported imports.

Consumers need TypeScript 7 or newer.
Runtime support covers current Node.js LTS, Cloudflare Workers, and the [Web Platform Baseline Widely available](https://web.dev/baseline) feature set.
Widely available features have been interoperable across Baseline's core browsers for at least 30 months.
tsdown uses its [`baseline-widely-available` target](https://tsdown.dev/options/target), rather than the latest ECMAScript edition.
The pinned tsdown version resolves this preset to Chrome and Edge 111, Firefox 114, and Safari and iOS 16.4.
Review changes to that browser set when upgrading tsdown.

Source typechecking and the package-consumption test use ES2022 API types as a conservative guard, not a complete Baseline check.
Check each runtime API's Baseline status before using it; syntax lowering does not supply API polyfills.
The library does not ship polyfills or require consumers to transpile it for the supported browser set.
Consumers targeting older environments handle any additional transpilation and polyfills.
Development tooling uses the pinned Node.js version and has a separate TypeScript configuration.

## Development

Install [mise](https://mise.jdx.dev/), review the repository configuration, then run:

```sh
mise trust
mise install
mise exec -- npm ci
mise run check
```

With mise shell integration enabled, the following commands use the pinned tools directly.
Otherwise, prefix them with `mise exec --`.
See [the hook instructions](docs/agents/git-hooks.md) for setup details and commit conventions.

```sh
npm run build
npm run typecheck
npm run lint
npm run format
npm test
npm run dev
```

tsdown preserves individual modules and generates declarations through Oxc.
TypeScript checks source and tooling separately.
Exported declarations require explicit annotations where `isolatedDeclarations` requires them.
General-purpose source has no ambient Node.js or DOM types.

Oxfmt is managed by mise, not installed as a package dependency.
Oxlint uses correctness rules, rejects warnings, and makes no automatic fixes.
Development dependencies use exact versions and a committed npm lockfile.
Dependency install scripts are disabled unless explicitly reviewed and allowed.

## Validation

`mise run check` runs package validation and the existing repository hook checks.
[Woodpecker CI](https://ci.igas.dev) is configured to run the same command on pull requests and pushes to `main`.
Fork pull requests require manual approval before execution.
See [the CI rollout instructions](docs/agents/ci.md) for activation and required-status setup.
GitHub Actions remains disabled.
Local checks and hooks are bypassable; the pilot requires passing PR CI with no merge bypass once rollout verification is complete.

The Vitest package-consumption test builds an npm archive, installs it into an isolated temporary project, and checks ESM imports, strict TypeScript resolution, and blocked internal imports.
It does not establish browser or Workers compatibility.
It checks that the initial package has no runtime dependencies and no public utility exports.
Update the empty-export assertions when adding the first utility.

Utility coverage gates, property tests, bundle-exclusion tests, benchmarks, and version-matched API documentation remain release requirements.
The empty package does not claim to satisfy those requirements.

## Publishing

Changesets records release notes and versions without automatically committing changes.
Keep version preparation separate from publication:

```sh
npm run changeset
npm run version-packages
mise run check
# Review and commit the version changes before publishing.
npm run release
```

Publishing requires npm authorization for the `@visiblelightio` scope.
Public access is configured explicitly.
`prepublishOnly` runs package validation before publication, and `prepack` rebuilds the package.
The archive includes compiled modules, declarations, available source and declaration maps, TypeScript source, this README, and the license.
The empty entry point produces no maps; map generation applies once there is code or a declaration to map.

Initialization does not publish a release.
