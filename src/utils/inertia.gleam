import gleam/json
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub type Page {
  Page(
    component: String,
    url: String,
    props: List(#(String, json.Json)),
    version: Version,
  )
}

pub type Version {
  StringVersion(String)
  NullVersion
}

pub fn app_script(page: Page) -> List(Element(msg)) {
  [
    html.div([attribute.id("app")], []),
    html.script(
      [
        attribute.type_("application/json"),
        attribute.data("page", "app"),
      ],
      json.to_string(page_component_json(page)),
    ),
  ]
}

fn page_component_json(page: Page) -> json.Json {
  let json_version = case page.version {
    StringVersion(v) -> json.string(v)
    NullVersion -> json.null()
  }

  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(page.props)),
    #("url", json.string(page.url)),
    #("version", json_version),
    #("rescuedProps", json.array([], of: json.string)),
    #("flash", json.object([])),
    #("rememberedState", json.object([])),
  ])
}
