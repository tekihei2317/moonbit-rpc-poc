///|
/// Base path for all RPC endpoints.
pub let base_path : String = "/api/rpc"

///|
/// The RPC route kind.
pub enum Operation {
  Query
  Mutation
}

///|
/// Shared route description used by both client and server.
///
/// TODO: Suppress `unused_type_variable` only for this phantom-typed struct
/// once MoonBit supports declaration-local suppression for this warning.
pub struct Route[Input, Output] {
  operation : Operation
  name : String
}

///|
pub fn[Input, Output] query(name : String) -> Route[Input, Output] {
  { operation: Query, name }
}

///|
pub fn[Input, Output] mutation(name : String) -> Route[Input, Output] {
  { operation: Mutation, name }
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
