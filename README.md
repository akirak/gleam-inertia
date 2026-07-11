# http_inertia

`http_inertia` is a server-agnostic [Inertia](https://inertiajs.com/)
protocol adapter for [gleam/http](https://hexdocs.pm/gleam_http/). It provides
page-object encoding, initial-page markup, request detection, partial reload
filtering, and once-prop handling without depending on a specific Gleam HTTP
server.

The package currently has first-class usage coverage through the
[Mist example](examples/mist). Its public API works with `gleam/http` request
types so other server integrations can be built without adding a server
dependency to this package.

By using this package, you can:

- Use React for view code without adding a Node.js application server.
- Treat Inertia as the boundary between server routes and client pages.
- Preserve BEAM runtime strengths, especially predictable concurrency through
  its preemptive scheduler.

Unsupported use cases:

- Complex frontend: Client states should be kept minimal unless necessary
- Running the Gleam backend on a JavaScript runtime or WASM (like Cloudflare
  Workers)

## Installation

Add `http_inertia` to your Gleam project:

```sh
gleam add http_inertia
```

Then import the public module:

```gleam
import http_inertia
```

## Development

Run the package tests from the repository root:

```sh
gleam test
```

The repository's `flake.nix` remains focused on the Mist example. Run its
combined server and frontend with:

```sh
nix run
```

See [examples/mist/README.md](examples/mist/README.md) for development and E2E
test instructions.

## Protocol Status

This package aims to implement the [Inertia protocol
(v3)](https://inertiajs.com/docs/v3/core-concepts/the-protocol) faithfully.

- [x] Page objects with deferred props
- [x] Page objects with rescued deferred props
- [x] Page objects with merge props
- [x] Page objects with scroll props
- [x] Page objects with once props
- [ ] Asset versioning
- [ ] Partial reloads
- [ ] Restrict responses to supported HTTP status codes

## Why?

After trying [TanStack Start](https://tanstack.com/start/latest) in a few
personal projects, I wanted a deployment model that does not require
self-hosting a Node.js server for application logic. Bun is interesting, but it
does not change the main trade-off: the runtime still becomes part of the
server-side frontend stack.

For my homelab, I want that server-side boundary to run on the Erlang VM
(BEAM). Elixir and Phoenix LiveView are strong options, but Gleam is a better
fit for the kind of small, typed Backend-For-Frontend (BFF) layer I want to
write. The missing piece is a low-friction frontend story. I still want to build
the interface in React, keep client state minimal, and avoid inventing a new
server-side web framework for Gleam.

Inertia provides a useful protocol for that shape of application: Gleam can own
routing, data preparation, and HTTP responses while React owns the interactive
views.

## Acknowledgements

[wisp_inertia](https://github.com/keuller/wisp_inertia) by Keuller Magalhaes
inspired this package.
