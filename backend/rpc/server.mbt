///|
fn[Input : FromJson] parse_query_input(
  ctx : @mars.Context,
) -> Result[Input, @shared.RpcError] {
  let json = match ctx.query("input") {
    Some(input) =>
      @json.parse(input) catch {
        _ => return Err(@shared.RpcError::bad_request("Invalid input"))
      }
    None => Json::null()
  }
  let value : Input = @json.from_json(json) catch {
    _ => return Err(@shared.RpcError::bad_request("Invalid input"))
  }
  Ok(value)
}

///|
async fn[Input : FromJson] parse_body_input(
  ctx : @mars.Context,
) -> Result[Input, @shared.RpcError] raise Error {
  let json = match ctx.body_json() {
    Some(json) => json
    None => Json::null()
  }
  let value : Input = @json.from_json(json) catch {
    _ => return Err(@shared.RpcError::bad_request("Invalid input"))
  }
  Ok(value)
}

///|
async fn send_error(
  ctx : @mars.Context,
  err : @shared.RpcError,
) -> Unit raise Error {
  ctx.text(err.message, status=err.status)
}

///|
async fn[Output : ToJson] send_output(
  ctx : @mars.Context,
  output : Output,
) -> Unit raise Error {
  ctx.set_header("Content-Type", "application/json; charset=utf-8")
  ctx.json(output.to_json())
}

///|
/// Register a Mars handler for an RPC route.
pub fn[Input : FromJson, Output : ToJson] handle(
  app : @mars.Server,
  route : @shared.Route[Input, Output],
  handler : (Input) -> Result[Output, @shared.RpcError],
) -> Unit {
  match route.operation {
    Query =>
      app.get(
        @shared.path(route),
        @mars.handler(async fn(ctx) raise Error {
          let input = match parse_query_input(ctx) {
            Ok(input) => input
            Err(err) => {
              send_error(ctx, err)
              return
            }
          }
          let output = match handler(input) {
            Ok(output) => output
            Err(err) => {
              send_error(ctx, err)
              return
            }
          }
          send_output(ctx, output)
        }),
      )
    Mutation =>
      app.post(
        @shared.path(route),
        @mars.handler(async fn(ctx) raise Error {
          let input = match parse_body_input(ctx) {
            Ok(input) => input
            Err(err) => {
              send_error(ctx, err)
              return
            }
          }
          let output = match handler(input) {
            Ok(output) => output
            Err(err) => {
              send_error(ctx, err)
              return
            }
          }
          send_output(ctx, output)
        }),
      )
  }
}
