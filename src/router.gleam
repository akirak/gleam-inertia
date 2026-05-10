import gleam/http.{Get, Head}
import gleam/http/request
import gleam/json
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import web

pub fn make_handler(ctx: web.Context) -> web.Handler {
  fn(req: web.Request) -> web.Response {
    use req <- web.middleware(ctx, req)

    case request.path_segments(req) {
      ["greet", name] -> greet(name, req, ctx)

      // This matches all other paths.
      _ -> web.not_found()
    }
  }
}

fn greet(name: String, req: web.Request, ctx: web.Context) -> web.Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- web.require_methods(req, [Get, Head])

  let html =
    html([], [
      html.head(
        [],
        list.append([html.title([], "Greetings!")], asset_scripts(ctx)),
      ),
      html.body([], [
        html.div([attribute.id("app")], []),
        html.script(
          [
            attribute.type_("application/json"),
            attribute.data("page", "app"),
          ],
          inertia_page_json("greet", req.path, name),
        ),
      ]),
    ])

  element.to_document_string(html)
  |> web.html_response
}

fn asset_scripts(ctx: web.Context) -> List(element.Element(msg)) {
  let web.Context(assets: assets, ..) = ctx
  case assets {
    web.ProductionAssets -> [
      html.script(
        [
          attribute.type_("module"),
          attribute.src("/static/js/app.js"),
        ],
        "",
      ),
    ]

    web.DevelopmentAssets(vite_origin) -> [
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

fn inertia_page_json(component: String, url: String, name: String) -> String {
  json.object([
    #("component", json.string(component)),
    #(
      "props",
      json.object([
        #("name", json.string(name)),
        #("errors", json.object([])),
      ]),
    ),
    #("url", json.string(url)),
    #("version", json.null()),
    #("rescuedProps", json.array([], of: json.string)),
    #("flash", json.object([])),
    #("rememberedState", json.object([])),
  ])
  |> json.to_string
}
