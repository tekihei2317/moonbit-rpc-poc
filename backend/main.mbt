///|
/// Entry point. Parses CLI args, opens the SQLite database, registers
/// RPC routes, then starts the Mars server.
async fn main {
  let matches = @argparse.parse(
    Command("contacts", about="Contact Manager backend", options=[
      OptionArg("port", short='p', long="port", about="Port to listen on", default_values=[
        "4000",
      ]),
    ]),
  ) catch {
    _ => {
      println("Failed to parse arguments")
      return
    }
  }
  guard matches is { values: { "port": [port_str], .. }, .. } else {
    println("Failed to parse arguments")
    return
  }
  let port = @strconv.parse_int(port_str) catch {
    _ => {
      println("Failed to parse port")
      return
    }
  }

  let conn = @sqlite3.Connection::open("contacts.db") catch {
    err => {
      println("Failed to open database: \{err}")
      return
    }
  }
  println("Database opened: contacts.db")

  init_db(conn) catch {
    err => {
      println("Failed to initialize database: \{err}")
      return
    }
  }
  println("Database initialized")

  let app = @mars.Server::new()
  app.middleware(@middleware.cors_allow_all())

  @rpc.handle(app, @shared.list_contacts, _ => {
    let contacts = get_all_contacts(conn) catch {
      _ => return Err(@shared.RpcError::internal())
    }
    Ok(contacts)
  })

  @rpc.handle(app, @shared.create_contact, input => {
    if !@shared.validate_name(input.name) {
      return Err(
        @shared.RpcError::bad_request(
          "Name must be 1-\{@shared.max_name_length} characters",
        ),
      )
    }
    if !@shared.validate_email(input.email) {
      return Err(
        @shared.RpcError::bad_request(
          "Email must be valid (contain @ and . after @)",
        ),
      )
    }
    if !@shared.validate_phone(input.phone) {
      return Err(
        @shared.RpcError::bad_request(
          "Phone must contain only digits, spaces, hyphens, parens, and +",
        ),
      )
    }
    let contact = create_contact(conn, input.name, input.email, input.phone) catch {
      _ => return Err(@shared.RpcError::internal())
    }
    Ok(contact)
  })

  @rpc.handle(app, @shared.toggle_contact_favorite, input => {
    let contact = toggle_favorite(conn, input.id) catch {
      _ => return Err(@shared.RpcError::internal())
    }
    Ok(contact)
  })

  @rpc.handle(app, @shared.delete_contact, input => {
    delete_contact(conn, input.id) catch {
      _ => return Err(@shared.RpcError::internal())
    }
    Ok(())
  })

  println("Server running at http://localhost:\{port}")
  app.serve(host="127.0.0.1", port~) catch {
    err => println("Server failed: \{err}")
  }
}
