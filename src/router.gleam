import gleam/http.{Get, Head}
import gleam/http/request
import gleam/json
import utils/inertia
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
  use <- web.require_methods(req, [Get, Head])

  let page =
    inertia.Page(
      component: "greet",
      url: req.path,
      props: [
        #("name", json.string(name)),
        #("errors", json.object([])),
      ],
      version: inertia.NullVersion,
    )

  web.inertia_response(ctx, 200, "Greeting", page)
}
