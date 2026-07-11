import gleam/json
import gleeunit
import http_inertia

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn adapter_dependency_smoke_test() {
  let page =
    http_inertia.page(
      component: "home",
      props: [],
      version: http_inertia.NullVersion,
    )

  assert json.to_string(http_inertia.page_component_json("/", page))
    == "{\"component\":\"home\",\"props\":{},\"url\":\"/\",\"version\":null}"
}
