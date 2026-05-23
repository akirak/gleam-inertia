---
id: "ADR-0002"
slug: "use-playwright-js-for-e2e-testing"
status: "Draft"
date: "2026-05-23"
---

# ADR-0002: Use Playwright JS for E2E Testing

## Context

This repository is a full-stack project with a Gleam backend, Inertia, and a
React frontend. End-to-end testing is important because user-facing behavior
depends on the integration between the backend routes, server-rendered Inertia
responses, frontend React components, browser behavior, and client-side
navigation.

The repository already has a JavaScript package setup because React is used for
the frontend. Adding browser E2E tests through the JavaScript toolchain fits the
existing frontend runtime and dependency model.

Playwright has multiple language bindings and third-party integrations. The
JavaScript implementation is the primary and most current implementation. Other
libraries, such as third-party Elixir integrations, do not currently provide the
same feature coverage and may lag behind the main Playwright release cadence.

## Decision

This repository will use Playwright JS for end-to-end testing.

E2E tests will be authored and run through the existing JavaScript package
toolchain. The project will not use non-JavaScript Playwright libraries for E2E
testing unless this decision is revisited.

## Consequences

- Uses the most up-to-date Playwright implementation and documentation.
- Keeps browser automation close to the existing React and JavaScript frontend
  tooling.
- Avoids relying on third-party Playwright libraries that may lag behind the
  primary implementation or lack feature parity.
- Adds Node-based E2E test dependencies and scripts to the project.
- Requires coordination between the application server lifecycle and the
  Playwright test runner.

## Alternatives Considered

- Use a third-party Elixir Playwright library: Not chosen because available
  implementations do not have feature parity with Playwright JS and may not
  track the main Playwright release cadence closely enough.
- Use a different browser E2E testing framework: Not chosen because Playwright
  JS provides mature browser automation, broad documentation, and direct support
  in the JavaScript ecosystem already used by this repository.
- Do not add E2E testing: Not chosen because this is a full-stack project where
  important behavior spans backend responses, frontend rendering, and browser
  interaction.

## Related ADRs

- None.
