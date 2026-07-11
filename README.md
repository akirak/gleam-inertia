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

## Mist integration example

The following `web` module can be used for building a Mist integration with Vite
frontend (also support dev mode). For a complete example of application, see
[the directory in the package
repository](https://github.com/akirak/gleam-inertia/blob/main/examples/mist/).

```gleam
import gleam/bytes_tree
import gleam/http.{type Method, Get, Head}
import gleam/http/request.{type Request as HttpRequest}
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{None}
import http_inertia
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import mist

pub type Context {
  Context(static_directory: String, assets: Assets)
}

pub type Assets {
  ProductionAssets
  DevelopmentAssets(base_url: String)
}

pub type Request =
  HttpRequest(mist.Connection)

pub fn require_methods(
  req: Request,
  allowed allowed: List(Method),
  next handler: fn() -> Response,
) -> Response {
  case list.contains(allowed, req.method) {
    True -> handler()
    False ->
      text_response(405, "Method not allowed")
      |> response.set_header("allow", allowed_header(allowed))
  }
}

pub fn inertia_response(
  req: Request,
  ctx: Context,
  status: Int,
  title: String,
  page: http_inertia.Page,
) -> Response {
  let url = http_inertia.request_url(req)

  case http_inertia.is_inertia_request(req) {
    False -> {
      let body =
        html([], [
          html.head([], [html.title([], title)] |> list.append(asset_tags(ctx))),
          html.body([], http_inertia.app_script(url, page)),
        ])
        |> element.to_document_string
        |> bytes_tree.from_string

      response.Response(
        status: status,
        headers: [#("Content-Type", "text/html; charset=utf-8")],
        body: mist.Bytes(body),
      )
    }
    True -> {
      let body =
        http_inertia.page_component_json(url, page)
        |> json.to_string
        |> bytes_tree.from_string

      response.Response(
        status: status,
        headers: [
          #("X-Inertia", "true"),
          #("Content-Type", "application/json"),
        ],
        body: mist.Bytes(body),
      )
    }
  }
}

fn asset_tags(ctx: Context) -> List(element.Element(msg)) {
  let Context(assets: assets, ..) = ctx
  case assets {
    ProductionAssets -> [
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/assets/app.css"),
      ]),
      html.script(
        [
          attribute.type_("module"),
          attribute.src("/static/js/app.js"),
        ],
        "",
      ),
    ]

    DevelopmentAssets(vite_origin) -> [
      html.script(
        [
          attribute.type_("module"),
          attribute.src(vite_origin <> "/@vite/client"),
        ],
        "",
      ),
      html.script(
        [attribute.type_("module")],
        react_refresh_preamble(vite_origin),
      ),
      html.script(
        [
          attribute.type_("module"),
          attribute.src(vite_origin <> "/src-inertia/app.tsx"),
        ],
        "",
      ),
    ]
  }
}

fn react_refresh_preamble(vite_origin: String) -> String {
  "import RefreshRuntime from \""
  <> vite_origin
  <> "/@react-refresh\"\n"
  <> "RefreshRuntime.injectIntoGlobalHook(window)\n"
  <> "window.$RefreshReg$ = () => {}\n"
  <> "window.$RefreshSig$ = () => (type) => type\n"
  <> "window.__vite_plugin_react_preamble_installed__ = true\n"
}
```

Then you can define an application like:

``` gleam
import env
import gleam/erlang/application
import gleam/erlang/process
import mist
import web

pub fn main() {
  let ctx = web.Context(static_directory: static_directory(), assets: assets())
  let handler = make_handler(ctx)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.bind("127.0.0.1")
    |> mist.port(8080)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() -> String {
  // Change "demo_web" to the name of your application
  let assert Ok(static_directory) = application.priv_directory("demo_web")
  static_directory <> "/static"
}

fn assets() -> web.Assets {
  // This example uses an environment variable to run in development mode
  case env.get("DEMO_WEB_ENV") {
    Ok("development") ->
      web.DevelopmentAssets(base_url: vite_origin() <> "/static")

    _ -> web.ProductionAssets
  }
}

fn make_handler(ctx: web.Context) -> web.Handler {
  fn(req: web.Request) -> web.Response {
    use req <- web.middleware(ctx, req)

    case request.path_segments(req) {
      [] -> home(req, ctx)

      // This matches all other paths.
      _ -> web.not_found()
    }
  }
}

fn home(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let page =
    http_inertia.page(
      component: "home",
      props: [
        #("errors", json.object([])),
      ],
      version: http_inertia.NullVersion,
    )

  web.inertia_response(req, ctx, 200, "Demo Home", page)
}
```

## Further resources

- [Inertia protocol documentation](https://inertiajs.com/docs/v3/core-concepts/the-protocol)
- [Repository and development notes](https://github.com/akirak/gleam-inertia/blob/main/DEVELOPMENT.md)

## Acknowledgements

[wisp_inertia](https://github.com/keuller/wisp_inertia) by Keuller Magalhaes
inspired this package.
