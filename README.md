# http_inertia

[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/http_inertia)
[![Hex.pm](https://img.shields.io/hexpm/v/http_inertia)](https://hex.pm/packages/http_inertia)
[![License](https://img.shields.io/hexpm/l/http_inertia)](https://github.com/akirak/gleam-inertia/blob/main/LICENSE)

`http_inertia` is a server-agnostic [Inertia](https://inertiajs.com/) protocol
adapter for [Gleam](https://gleam.run/). It works with
[`gleam/http`](https://hexdocs.pm/gleam_http/) request values and supplies the
server-side pieces needed to build Inertia responses: page-object encoding,
initial-page markup, request inspection, and prop-selection helpers.

It does not depend on a particular HTTP server or response type. Your web
framework remains responsible for turning the generated page data into an HTTP
response and serving the Inertia client assets.

## Installation

```sh
gleam add http_inertia
```

## Creating a page

Create a `Page` with a component name, JSON props, and an asset version. Encode
it with `page_component_json` when returning an Inertia response.

```gleam
import gleam/json
import http_inertia

let page =
  http_inertia.page(
    component: "users/index",
    props: [
      #("users", json.array(["Ada"], of: json.string)),
      #("errors", json.object([])),
    ],
    version: http_inertia.StringVersion("asset-version"),
  )

let page_json = http_inertia.page_component_json("/users", page)
```

For the initial non-Inertia visit, `app_script` produces the `#app` mount
element and the JSON page-data script expected by the Inertia client:

```gleam
let elements = http_inertia.app_script("/users", page)
```

## Request helpers

Use `is_inertia_request` to distinguish an Inertia visit from an initial page
load. `request_url` returns the path and query string for the current request.

For partial reloads, use `is_partial_reload_for` together with
`should_include_prop` before doing work to load optional props:

```gleam
let include_permissions =
  http_inertia.is_partial_reload_for(req, "users/index")
  && http_inertia.should_include_prop(req, "users/index", "permissions")
```

`should_skip_once_prop` applies the corresponding request rules for props
registered with `once_prop` and `with_once_props`.

## Protocol metadata

Start with `page`, then use the `with_*` functions to attach optional Inertia
metadata:

- `with_deferred_props` and `with_rescued_props`
- `with_merge_props`
- `with_scroll_props`
- `with_once_props`

See the [`http_inertia` module documentation](https://hexdocs.pm/http_inertia/http_inertia.html)
for each function's API and the [Mist example](https://github.com/akirak/gleam-inertia/tree/main/examples/mist)
for a complete server integration.

## Further resources

- [Inertia protocol documentation](https://inertiajs.com/docs/v3/core-concepts/the-protocol)
- [Repository and development notes](https://github.com/akirak/gleam-inertia/blob/main/DEVELOPMENT.md)

## Acknowledgements

[wisp_inertia](https://github.com/keuller/wisp_inertia) by Keuller Magalhaes
inspired this package.
