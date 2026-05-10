import env
import gleam/erlang/application
import gleam/erlang/process
import gleam/result
import mist
import router
import web

pub fn main() {
  let ctx = web.Context(static_directory: static_directory(), assets: assets())

  let handler = router.make_handler(ctx)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(static_directory) = application.priv_directory("demo_web")
  static_directory <> "/static"
}

fn assets() -> web.Assets {
  case env.get("DEMO_WEB_ENV") {
    Ok("development") ->
      web.DevelopmentAssets(base_url: vite_origin() <> "/static")

    _ -> web.ProductionAssets
  }
}

fn vite_origin() -> String {
  env.get("VITE_DEV_SERVER_ORIGIN")
  |> result.unwrap("http://localhost:5173")
}
