import gleam/erlang/application
import gleam/erlang/process
import mist
import router
import web

pub fn main() {
  let ctx = web.Context(static_directory: static_directory())

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
