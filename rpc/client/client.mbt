///|
#cfg(target="js")
extern "js" fn encode_uri_component(value : String) -> String =
  #| (value) => encodeURIComponent(value)

///|
#cfg(target="js")
fn[Output : FromJson] decode_output(json : Json) -> Result[Output, String] {
  let output : Output = @json.from_json(json) catch {
    _ => return Err("Failed to decode RPC response")
  }
  Ok(output)
}

///|
/// Call an RPC route using GET for queries and POST for mutations.
#cfg(target="js")
pub fn[Input : ToJson, Output : FromJson] call(
  route : @rpc_core.Route[Input, Output],
  input : Input,
  expect : (Result[Output, String]) -> @rabbita.Cmd,
) -> @rabbita.Cmd {
  let route_path = @rpc_core.path(route)
  match route.operation {
    Query => {
      let encoded = encode_uri_component(input.to_json().stringify())
      @http.get(
        "\{route_path}?input=\{encoded}",
        expect=Json(expect, decode_output),
      )
    }
    Mutation =>
      @http.post(
        route_path,
        Json(input.to_json()),
        expect=Json(expect, decode_output),
      )
  }
}
