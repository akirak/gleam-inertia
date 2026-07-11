import gleam/json
import gleeunit
import inertia

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn adapter_dependency_smoke_test() {
  let page =
    inertia.page(component: "home", props: [], version: inertia.NullVersion)

  assert json.to_string(inertia.page_component_json("/", page))
    == "{\"component\":\"home\",\"props\":{},\"url\":\"/\",\"version\":null}"
}
