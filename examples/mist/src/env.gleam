pub fn get(name: String) -> Result(String, Nil) {
  get_env(name)
}

@external(erlang, "env_ffi", "get_env")
fn get_env(name: String) -> Result(String, Nil)
