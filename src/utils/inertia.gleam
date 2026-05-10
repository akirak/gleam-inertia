import gleam/http/request
import gleam/json
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import mist

pub type Page {
  Page(component: String, props: List(#(String, json.Json)), version: Version)
}

pub type Version {
  StringVersion(String)
  NullVersion
}

pub fn app_script(url: String, page: Page) -> List(Element(msg)) {
  [
    html.div([attribute.id("app")], []),
    html.script(
      [
        attribute.type_("application/json"),
        attribute.data("page", "app"),
      ],
      json.to_string(page_component_json(url, page)),
    ),
  ]
}

pub fn page_component_json(url: String, page: Page) -> json.Json {
  let json_version = case page.version {
    StringVersion(v) -> json.string(v)
    NullVersion -> json.null()
  }

  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(page.props)),
    #("url", json.string(url)),
    #("version", json_version),
    #("rescuedProps", json.array([], of: json.string)),
    #("flash", json.object([])),
    #("rememberedState", json.object([])),
  ])
}

pub fn is_inertia_request(request: request.Request(mist.Connection)) -> Bool {
  let maybe_value =
    request.headers
    |> list.find(fn(pair) {
      let #(name, _value) = pair
      string.lowercase(name) == "x-inertia"
    })

  case maybe_value {
    Ok(#(_, value)) -> value == "true"
    Error(_) -> False
  }
}
