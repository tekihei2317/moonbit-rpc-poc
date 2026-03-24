///|
/// Base path for all RPC endpoints.
pub let base_path : String = "/api/rpc"

///|
/// The HTTP operation used by a route.
pub(all) enum Operation {
  Query
  Mutation
} derive(Debug)

///|
/// Shared route description used by both client and server.
pub(all) struct Route[Input, Output] {
  operation : Operation
  name : String
  input_type : Input?
  output_type : Output?
}

///|
pub fn[Input, Output] query(name : String) -> Route[Input, Output] {
  { operation: Query, name, input_type: None, output_type: None }
}

///|
pub fn[Input, Output] mutation(name : String) -> Route[Input, Output] {
  { operation: Mutation, name, input_type: None, output_type: None }
}

///|
pub fn[Input, Output] path(route : Route[Input, Output]) -> String {
  "\{base_path}/\{route.name}"
}

///|
/// RPC error represented as status code plus plain-text message.
pub(all) struct RpcError {
  status : Int
  message : String
} derive(Debug)

///|
pub fn RpcError::bad_request(message : String) -> RpcError {
  { status: 400, message }
}

///|
pub fn RpcError::not_found(message? : String = "Not Found") -> RpcError {
  { status: 404, message }
}

///|
pub fn RpcError::internal(
  message? : String = "Internal Server Error",
) -> RpcError {
  { status: 500, message }
}
