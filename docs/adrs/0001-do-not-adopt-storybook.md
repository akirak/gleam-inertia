---
id: "ADR-0001"
slug: "do-not-adopt-storybook"
status: "Accepted"
date: "2026-05-23"
---

# ADR-0001: Do Not Adopt Storybook

## Context

This repository is intended for small projects, personal projects, and
prototypes. The README rationale emphasizes a low-friction application
structure: a small typed BFF in Gleam, React for interactive views, and minimal
operational overhead.

Storybook is most useful when a team needs a dedicated workflow for developing,
reviewing, and documenting a design system, a shared component library, or a
large application UI. That value is weaker in this repository's intended scope,
where the UI surface area is limited and component reuse is modest.

Adding Storybook would introduce additional setup, maintenance, and dependency
cost in both the frontend toolchain and the project conventions.

## Decision

This repository will not set up Storybook.

Component development and UI iteration will continue inside the application
itself, using the existing React and Inertia-based development workflow. If the
project later grows into a shared component library, design system, or a larger
application with more complex UI review needs, this decision can be revisited.

## Consequences

- Keeps the development setup focused on the main application runtime and
  workflow.
- Avoids extra configuration, scripts, dependencies, and maintenance overhead.
- Fits the repository's stated scope of small projects, personal projects, and
  prototypes.
- Reduces support for isolated component previews and standalone component
  documentation.
- Makes visual review and component exploration depend on application routes
  rather than a dedicated UI workbench.

## Alternatives Considered

- Adopt Storybook now: Not chosen because the expected benefits do not justify
  the extra complexity for this repository's intended scale and scope.
- Revisit Storybook only if the project evolves: Chosen implicitly as the
  fallback path if the repository grows into a design-system or
  component-library use case.

## Related ADRs

- None.
