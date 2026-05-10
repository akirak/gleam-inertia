import gleam/http.{Get, Head}
import gleam/http/request
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import web

pub fn make_handler(ctx: web.Context) -> web.Handler {
  fn(req: web.Request) -> web.Response {
    use req <- web.middleware(ctx, req)

    case request.path_segments(req) {
      ["greet", name] -> greet(name, req)

      // This matches all other paths.
      _ -> web.not_found()
    }
  }
}

fn greet(_name: String, req: web.Request) -> web.Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- web.require_methods(req, [Get, Head])

  let html =
    html([], [
      html.head([], [
        html.title([], "Greetings!"),
        html.script(
          [
            attribute.type_("module"),
            attribute.src("/static/inertia/js/app.jsx"),
          ],
          "",
        ),
      ]),
      html.body([], [html.div([attribute.id("app")], [])]),
    ])

  element.to_document_string(html)
  |> web.html_response
}
