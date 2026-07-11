# Mist Example

This example uses `http_inertia` with [Mist](https://github.com/rawhat/mist)
and a React frontend. It demonstrates a typed Gleam backend on the BEAM while
Inertia provides the protocol boundary for client-side pages.

The package is consumed from the repository root:

```toml
[dependencies]
http_inertia = { path = "../.." }
```

## Prerequisites

- Gleam
- Erlang (tested on Erlang 28)
- Node.js and pnpm

The root `flake.nix` provides these dependencies through its development shell.

## Development

From the repository root, install dependencies and start both development
servers:

```sh
just install
just dev
```

Alternatively, run the processes separately:

```sh
pnpm --dir examples/mist dev
cd examples/mist
DEMO_WEB_ENV=development gleam run -m demo_web
```

Visit <http://localhost:8000>.

## E2E Tests

Install the Playwright browsers once, then run the suite from this directory:

```sh
pnpm install
pnpm exec playwright install --with-deps chromium
pnpm test:e2e
```

The suite covers the home page, client-side navigation, and the dynamic greet
route.

## Nix

From the repository root, run the self-contained server and frontend package:

```sh
nix run
```

Build and load the container image with Podman:

```sh
nix build .#docker-image
zcat result | podman load
podman run -ti --rm -p 8000:8000 localhost/gleam-inertia-demo:latest
```
