# inertia

A Gleam adapter for the Inertia protocol. It provides page-object encoding,
initial-page markup, request detection, partial reload filtering, and once-prop
handling without depending on a specific Gleam HTTP server.

## Local dependency

```toml
[dependencies]
inertia = { path = "packages/inertia" }
```

Then import the public module:

```gleam
import inertia
```

Run this package's tests from its directory:

```sh
cd packages/inertia
gleam test
```
