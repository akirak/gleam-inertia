/// Server-side helpers for creating Inertia page objects and inspecting
/// Inertia requests.
///
/// This module is server-agnostic: it works with `gleam/http` request values
/// and produces the page data consumed by an Inertia client.
import gleam/http/request
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

/// An Inertia page object returned to the client.
///
/// Create a page with [`page`](#page), then use the `with_*` functions to add
/// optional protocol metadata.
pub type Page {
  Page(
    component: String,
    props: List(#(String, json.Json)),
    version: Version,
    deferred_props: DeferredProps,
    rescued_props: List(String),
    merge_props: MergeProps,
    scroll_props: ScrollProps,
    once_props: OnceProps,
  )
}

/// The asset version included in an Inertia page object.
pub type Version {
  /// A concrete asset version string.
  StringVersion(String)
  /// No asset version. This is encoded as JSON `null`.
  NullVersion
}

/// Deferred prop names grouped by the group that loads them.
pub type DeferredProps =
  List(#(String, List(String)))

/// Metadata that controls how the client merges props during a visit.
pub type MergeProps {
  MergeProps(
    append: List(String),
    prepend: List(String),
    deep_merge: List(String),
    match_on: List(String),
  )
}

/// Pagination metadata for a scrollable prop.
pub type ScrollProp {
  ScrollProp(
    page_name: String,
    previous_page: Option(Int),
    next_page: Option(Int),
    current_page: Int,
  )
}

/// Scroll metadata keyed by the corresponding prop name.
pub type ScrollProps =
  List(#(String, ScrollProp))

/// Metadata for a prop that the client should load only once.
pub type OnceProp {
  OnceProp(prop: String, expires_at: Option(Int))
}

/// Once-prop metadata keyed by the corresponding prop name.
pub type OnceProps =
  List(#(String, OnceProp))

/// Creates an Inertia page with no optional protocol metadata.
///
/// Use the `with_*` functions to add deferred, merge, scroll, rescued, or
/// once-prop metadata.
pub fn page(
  component component: String,
  props props: List(#(String, json.Json)),
  version version: Version,
) -> Page {
  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: [],
    rescued_props: [],
    merge_props: empty_merge_props(),
    scroll_props: [],
    once_props: [],
  )
}

/// Returns merge metadata with every prop list empty.
pub fn empty_merge_props() -> MergeProps {
  MergeProps(append: [], prepend: [], deep_merge: [], match_on: [])
}

/// Creates metadata that controls how the client merges the specified props.
///
/// Each list contains prop paths understood by the Inertia client.
pub fn merge_props(
  append append: List(String),
  prepend prepend: List(String),
  deep_merge deep_merge: List(String),
  match_on match_on: List(String),
) -> MergeProps {
  MergeProps(
    append: append,
    prepend: prepend,
    deep_merge: deep_merge,
    match_on: match_on,
  )
}

/// Creates pagination metadata for a scrollable prop.
///
/// `previous_page` and `next_page` are encoded as JSON `null` when absent.
pub fn scroll_prop(
  page_name page_name: String,
  previous_page previous_page: Option(Int),
  next_page next_page: Option(Int),
  current_page current_page: Int,
) -> ScrollProp {
  ScrollProp(
    page_name: page_name,
    previous_page: previous_page,
    next_page: next_page,
    current_page: current_page,
  )
}

/// Creates metadata for a prop the client should load only once.
///
/// `expires_at` is a Unix timestamp and is encoded as JSON `null` when absent.
pub fn once_prop(
  prop prop: String,
  expires_at expires_at: Option(Int),
) -> OnceProp {
  OnceProp(prop: prop, expires_at: expires_at)
}

/// Returns `page` with its deferred-prop metadata replaced by `deferred_props`.
pub fn with_deferred_props(page: Page, deferred_props: DeferredProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

/// Returns `page` with its rescued deferred-prop names replaced by `rescued_props`.
pub fn with_rescued_props(page: Page, rescued_props: List(String)) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

/// Returns `page` with its merge metadata replaced by `merge_props`.
pub fn with_merge_props(page: Page, merge_props: MergeProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

/// Returns `page` with its scroll metadata replaced by `scroll_props`.
pub fn with_scroll_props(page: Page, scroll_props: ScrollProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

/// Returns `page` with its once-prop metadata replaced by `once_props`.
pub fn with_once_props(page: Page, once_props: OnceProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

/// Renders the initial Inertia application elements.
///
/// The result contains the `#app` mount element and a JSON script element with
/// the initial page data for the client to read.
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

/// Encodes a page object in the JSON shape required by the Inertia protocol.
///
/// Empty optional metadata is omitted from the returned object.
pub fn page_component_json(url: String, page: Page) -> json.Json {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  ) = page

  let json_version = case version {
    StringVersion(v) -> json.string(v)
    NullVersion -> json.null()
  }

  let fields =
    [
      #("component", json.string(component)),
      #("props", json.object(props)),
      #("url", json.string(url)),
      #("version", json_version),
    ]
    |> add_optional_field("deferredProps", deferred_props_json(deferred_props))
    |> add_optional_field("rescuedProps", string_array_json(rescued_props))
    |> add_merge_props_fields(merge_props)
    |> add_optional_field("scrollProps", scroll_props_json(scroll_props))
    |> add_optional_field("onceProps", once_props_json(once_props))

  json.object(fields)
}

/// Returns `True` when `req` includes `X-Inertia: true`.
pub fn is_inertia_request(req: request.Request(connection)) -> Bool {
  case header(req, "x-inertia") {
    Some(value) -> value == "true"
    None -> False
  }
}

/// Returns the request path with its encoded query string when one is present.
///
/// If the query string cannot be parsed, this returns the path alone.
pub fn request_url(req: request.Request(connection)) -> String {
  case request.get_query(req) {
    Ok([]) | Error(_) -> req.path
    Ok(query) -> req.path <> "?" <> uri.query_to_string(query)
  }
}

/// Looks up a request header case-insensitively.
///
/// Returns `None` when the header is absent.
pub fn header(req: request.Request(connection), key: String) -> Option(String) {
  case request.get_header(req, string.lowercase(key)) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}

/// Splits a comma-separated request header into trimmed, non-empty values.
///
/// Returns an empty list when the header is absent or has no values.
pub fn header_csv(
  req: request.Request(connection),
  key: String,
) -> List(String) {
  case header(req, key) {
    Some(value) ->
      value
      |> string.split(on: ",")
      |> list.map(string.trim)
      |> list.filter(fn(item) { item != "" })

    None -> []
  }
}

/// Returns `True` when `req` is a partial reload for `component`.
pub fn is_partial_reload_for(
  req: request.Request(connection),
  component: String,
) -> Bool {
  header(req, "x-inertia-partial-component") == Some(component)
}

/// Returns whether a prop should be included in the response.
///
/// Props are included for full visits. For partial reloads, the
/// `X-Inertia-Partial-Data` and `X-Inertia-Partial-Except` headers determine
/// whether `key` is included; `except` takes precedence over `only`.
pub fn should_include_prop(
  req: request.Request(connection),
  component: String,
  key: String,
) -> Bool {
  case is_partial_reload_for(req, component) {
    False -> True
    True -> {
      let only = header_csv(req, "x-inertia-partial-data")
      let except = header_csv(req, "x-inertia-partial-except")

      case list.contains(except, key) {
        True -> False
        False ->
          case only {
            [] -> True
            _ -> list.contains(only, key)
          }
      }
    }
  }
}

/// Returns whether an already-loaded once prop should be omitted from a response.
///
/// The decision uses `X-Inertia-Except-Once-Props` and, for partial reloads,
/// the partial-data and partial-except headers.
pub fn should_skip_once_prop(
  req: request.Request(connection),
  component: String,
  prop_name: String,
  once_key: String,
) -> Bool {
  let loaded_keys = header_csv(req, "x-inertia-except-once-props")

  case list.contains(loaded_keys, once_key) {
    False -> False
    True -> {
      let requested_props = case is_partial_reload_for(req, component) {
        True -> header_csv(req, "x-inertia-partial-data")
        False -> []
      }

      let excluded_props = header_csv(req, "x-inertia-partial-except")

      case list.contains(excluded_props, prop_name) {
        True -> True
        False ->
          case requested_props {
            [] -> True
            _ -> !list.contains(requested_props, prop_name)
          }
      }
    }
  }
}

fn add_optional_field(
  fields: List(#(String, json.Json)),
  key: String,
  value: Option(json.Json),
) -> List(#(String, json.Json)) {
  case value {
    Some(value) -> list.append(fields, [#(key, value)])
    None -> fields
  }
}

fn add_merge_props_fields(
  fields: List(#(String, json.Json)),
  merge_props: MergeProps,
) -> List(#(String, json.Json)) {
  let MergeProps(
    append: append,
    prepend: prepend,
    deep_merge: deep_merge,
    match_on: match_on,
  ) = merge_props

  fields
  |> add_optional_field("mergeProps", string_array_json(append))
  |> add_optional_field("prependProps", string_array_json(prepend))
  |> add_optional_field("deepMergeProps", string_array_json(deep_merge))
  |> add_optional_field("matchPropsOn", string_array_json(match_on))
}

fn deferred_props_json(deferred_props: DeferredProps) -> Option(json.Json) {
  case deferred_props {
    [] -> None
    _ ->
      deferred_props
      |> list.map(fn(grouped_props) {
        let #(group, keys) = grouped_props
        #(group, json.array(keys, of: json.string))
      })
      |> json.object
      |> Some
  }
}

fn scroll_props_json(scroll_props: ScrollProps) -> Option(json.Json) {
  case scroll_props {
    [] -> None
    _ ->
      scroll_props
      |> list.map(fn(prop) {
        let #(key, value) = prop
        #(key, scroll_prop_json(value))
      })
      |> json.object
      |> Some
  }
}

fn scroll_prop_json(scroll_prop: ScrollProp) -> json.Json {
  let ScrollProp(
    page_name: page_name,
    previous_page: previous_page,
    next_page: next_page,
    current_page: current_page,
  ) = scroll_prop

  json.object([
    #("pageName", json.string(page_name)),
    #("previousPage", nullable_int_json(previous_page)),
    #("nextPage", nullable_int_json(next_page)),
    #("currentPage", json.int(current_page)),
  ])
}

fn once_props_json(once_props: OnceProps) -> Option(json.Json) {
  case once_props {
    [] -> None
    _ ->
      once_props
      |> list.map(fn(prop) {
        let #(key, value) = prop
        #(key, once_prop_json(value))
      })
      |> json.object
      |> Some
  }
}

fn once_prop_json(once_prop: OnceProp) -> json.Json {
  let OnceProp(prop: prop, expires_at: expires_at) = once_prop

  json.object([
    #("prop", json.string(prop)),
    #("expiresAt", nullable_int_json(expires_at)),
  ])
}

fn string_array_json(values: List(String)) -> Option(json.Json) {
  case values {
    [] -> None
    _ -> Some(json.array(values, of: json.string))
  }
}

fn nullable_int_json(value: Option(Int)) -> json.Json {
  case value {
    Some(value) -> json.int(value)
    None -> json.null()
  }
}
