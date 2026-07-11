# Development Notes

This document covers repository-specific workflows and project background. The
package documentation is in [README.md](README.md).

## Development

Run the package tests from the repository root:

```sh
gleam test
```

The root `flake.nix` is focused on the Mist example. Run its combined server
and frontend with:

```sh
nix run
```

See [examples/mist/README.md](examples/mist/README.md) for local development
and E2E test instructions.

## Protocol Coverage

The package implements these Inertia v3 page-object and request-handling
features:

- Deferred props and rescued deferred props
- Merge props and scroll props
- Once props
- Partial reload prop filtering

The following protocol behavior is not yet implemented by this package:

- Asset-version mismatch handling
- Restricting responses to supported HTTP status codes

## Background

This project explores an Inertia application architecture where Gleam owns
routing, data preparation, and HTTP responses on the BEAM, while React owns
interactive client-side views. It is intended for applications that want a
typed Gleam Backend-For-Frontend layer without a Node.js application server.

The package is not intended for Gleam applications running on JavaScript or
WASM runtimes, such as Cloudflare Workers.
