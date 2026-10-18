# Project goals and non-goals

This library provides reusable TypeScript runtime functions and type-only utilities for the team's modern, strict TypeScript projects.
Broader public adoption is welcome, but does not take priority over the team's needs.

## How to make trade-offs

Requirements are release gates, not preferences.
Do not trade correctness, security, trustworthy types, or documented contracts for performance.

Among implementations that meet the requirements, use this priority order:

| Utility category                               | First                         | Second              | Third          |
| ---------------------------------------------- | ----------------------------- | ------------------- | -------------- |
| Browser-compatible, including shared utilities | Developer-machine performance | Runtime bundle size | Runtime speed  |
| Server-only                                    | Developer-machine performance | Runtime speed       | Not applicable |

Developer-machine performance means type-checking time, compiler and editor memory use, and autocomplete responsiveness.
It does not mean convenience when writing code.

Bundle size is a non-goal for server-only utilities.
Shared utilities retain the browser-compatible priority order even when a consumer runs them on a server.

Exceptions to the preference order require reproducible measurements on representative workloads and a documented rationale.
A server-only optimized variant of a shared utility needs measured justification.

Implementation complexity is acceptable.
Human readability is not a goal, and complexity alone is not a reason to reject an optimization.
Documentation, tests, and measurements must establish its behavior and benefit.

## Scope and admission

- Add a utility when a real project demonstrates a recurring technical need that native JavaScript or TypeScript does not express clearly enough.
- Runtime functions and type-only utilities are both eligible.
- Repeated application-specific business logic stays in the application.
- General-purpose utilities support browsers and servers equally.
  Platform-specific tools use separate, explicitly platform-specific imports.
- General-purpose utilities have no third-party runtime dependencies.
  Specialist tools need an explicit exception or a separate package;
  rejecting a utility is preferable to automatically reimplementing a specialist library.

## Correctness, types, and security

- Public types must not promise more than runtime behavior guarantees.
  Assumption-dependent shortcuts must make their assumptions explicit.
- Safe, broader types are preferable to exact inference that meaningfully increases compiler time or memory use.
- Explicit generics and annotations are acceptable.
  Avoiding them does not justify extra compiler work or bundle size.
- Type-only utilities follow the same developer-machine performance standard.
  Bound expensive computation, simplify its result, or reject the utility.
- Optimizations must preserve the documented contract.
  A narrower supported contract is acceptable;
  silently mishandling supported inputs is not.
- Default APIs do not mutate caller-owned inputs and accept readonly inputs where possible.
  In-place variants make mutation explicit in their APIs.
- Security is mandatory.
  In particular, object utilities must not enable prototype pollution, and errors and inspection APIs must not expose sensitive input values by default.
- Utilities may document input-size or depth limits rather than promise to handle unbounded hostile inputs.

## Contracts, errors, and inspection

- Document supported inputs, relevant edge cases, output behavior, mutation guarantees, validation, and errors for each utility.
- State explicitly whether relevant cases such as symbol keys, inherited properties, getters, and cycles are supported.
  Do not leave behavior accidental.
- Validate invalid arguments that TypeScript cannot rule out.
  Throw descriptive errors identifying the function, invalid argument, and expected constraint.
- Runtime validation and descriptive errors remain mandatory despite their size and execution cost.
- Represent expected absence or failure in return types.
  Reserve exceptions for invalid arguments and unexpected failures.
- Stateful utilities expose useful, read-only operational state without changing behavior.
  Do not expose internal implementation details merely for completeness.
- Useful inspection remains a requirement even when it adds bookkeeping or runtime code.
  Pure functions do not need inspection APIs.

## Packaging and compatibility

- Publish native ESM and TypeScript declarations.
  Do not maintain a separate CommonJS build.
- Require TypeScript 7 or newer.
  Exact supported compiler options remain to be defined beyond strict mode.
- Importing a utility includes only that utility and its dependencies, with no unrelated runtime code or import-time side effects.
  Verify this with bundle tests.
- Do not ship compatibility fallbacks or polyfills for older environments.
- Support the latest Node.js LTS release, Cloudflare Workers, and the Web Platform Baseline Widely available feature set.
  The latter covers features interoperable across the core browsers for at least 30 months.
- General-purpose utilities must work in Cloudflare Workers without assuming Node.js-specific APIs.
  Workers compatibility dates and any platform-specific compatibility flags remain to be defined.
- Choose concrete minimum environments first, then derive the newest ECMAScript target fully supported by them.
  Account for both syntax and built-in APIs.
- Raise minimum environment requirements through major releases when justified.
  Do not preserve a fixed compatibility baseline indefinitely.

## Testing and benchmarks

- Vitest is the default test runner.
- Require 100% line coverage and 100% branch coverage.
  Instrumentation scope and treatment of unreachable code remain to be defined;
  coverage is not a substitute for behavioral guarantees.
- Require extensive property-based testing and behavioral and type tests.
  Test documented edge cases, errors, mutation guarantees, and inspection behavior.
- Use reference-comparison tests where appropriate, particularly for complex optimized implementations.
  High line coverage alone does not justify an optimization.
- Maintain Gherkin scenarios as BDD documentation for selected behaviors alongside Vitest.
  They are not a comprehensive duplicate test suite or a commitment to a Gherkin execution framework.
- Require reproducible benchmarks.
  Measure representative consumer projects for TypeScript cost, actual bundled imports for size, and representative workloads for runtime speed.
- Establish compiler-time and memory, bundle-size, and runtime benchmark baselines with the first utilities.
  Until regression budgets are defined, require recorded measurements and review rather than arbitrary percentage gates.
- Set numerical budgets and regression thresholds after observing measurement variability and real consumer workloads.
  Do not invent thresholds before representative baselines exist.
- Mutation testing is an optional audit for weak assertions, especially in complex optimized code.
  It is not currently a release gate, and no mutation-score threshold is set.
  Reconsider after measuring its cost and usefulness.

## Documentation and evolution

- Version-matched API documentation and an agent skill are release requirements.
- API documentation is the authoritative reference.
  The agent skill explains utility selection, contracts, error handling, and common mistakes.
- Breaking API changes are acceptable.
  Preserve neither APIs nor implementation choices solely for stability across major versions.
- Breaking changes require a major version and migration guide suitable for agent-assisted upgrades.
- Prefer changes that make affected consumers fail type-checking where feasible.
  Migration guides must also cover behavioral breaks that type-checking cannot detect.

## Non-goals

- Human implementation readability.
- API writing convenience, including avoiding explicit generics or annotations.
- Exhaustive type inference or unbounded type-level computation.
- API stability across major versions.
- Feature parity with Lodash, Radashi, type-fest, or any other library.
- Supporting every JavaScript value or legacy environment.
- Application-specific business logic.
- Winning microbenchmarks without representative benefits.
- Bundle-size optimization for server-only utilities.

## Deferred details

These need explicit decisions before their corresponding release gates can be implemented:

- Exact supported TypeScript compiler options beyond strict mode.
- Concrete versions satisfying the runtime and browser policies, Workers compatibility dates and flags, and the resulting ECMAScript target.
- Coverage instrumentation scope and treatment of unreachable code.
- Representative benchmark fixtures with the first utilities, followed by regression thresholds and numerical budgets informed by observed variability and real consumer workloads.

These open details do not weaken the agreed requirements or change the priority order.
