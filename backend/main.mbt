///|
/// Entry point. Parses CLI args, opens the SQLite database, registers
/// REST API routes, then starts the Mars server.
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
  app
  ..get(
    @shared.api_contacts,
    @mars.handler(async fn(ctx) -> Unit {
      println("GET \{@shared.api_contacts}")
      let contacts = get_all_contacts(conn)
      println("  -> 200 (\{contacts.length()} contacts)")
      ctx.set_header("Content-Type", "application/json; charset=utf-8")
      ctx.json(contacts.to_json())
    }),
  )
  ..post(
    @shared.api_contacts,
    @mars.handler(async fn(ctx) -> Unit {
      println("POST \{@shared.api_contacts}")
      guard ctx.body_json() is Some(json) else {
        println("  -> 400 Missing name")
        ctx.text("Missing name field", status=400)
        return
      }
      let name = match json {
        { "name": String(name), .. } => name
        _ => {
          println("  -> 400 Missing name")
          ctx.text("Missing name field", status=400)
          return
        }
      }
      let email = match json {
        { "email": String(email), .. } => email
        _ => {
          println("  -> 400 Missing email")
          ctx.text("Missing email field", status=400)
          return
        }
      }
      let phone = match json {
        { "phone": String(phone), .. } => phone
        _ => {
          println("  -> 400 Missing phone")
          ctx.text("Missing phone field", status=400)
          return
        }
      }
      if !@shared.validate_name(name) {
        println("  -> 400 Invalid name")
        ctx.text(
          "Name must be 1-\{@shared.max_name_length} characters",
          status=400,
        )
        return
      }
      if !@shared.validate_email(email) {
        println("  -> 400 Invalid email")
        ctx.text("Email must be valid (contain @ and . after @)", status=400)
        return
      }
      if !@shared.validate_phone(phone) {
        println("  -> 400 Invalid phone")
        ctx.text(
          "Phone must contain only digits, spaces, hyphens, parens, and +",
          status=400,
        )
        return
      }
      let contact = create_contact(conn, name, email, phone)
      println("  -> 201 created contact: \{name}")
      ctx.set_header("Content-Type", "application/json; charset=utf-8")
      ctx.json(contact.to_json(), status=201)
    }),
  )
  ..post(
    "\{@shared.api_contacts}/:id/favorite",
    @mars.handler(async fn(ctx) -> Unit {
      guard ctx.param("id") is Some(id_str) else {
        println("  -> 400 Missing id")
        ctx.text("Missing id field", status=400)
        return
      }
      println("POST /api/contacts/\{id_str}/favorite")
      let id = @strconv.parse_int(id_str) catch {
        _ => {
          println("  -> 404 Not Found")
          ctx.text("Not Found", status=404)
          return
        }
      }
      let contact = toggle_favorite(conn, id)
      println("  -> 200 toggled favorite for contact \{id}")
      ctx.set_header("Content-Type", "application/json; charset=utf-8")
      ctx.json(contact.to_json())
    }),
  )
  .delete(
    "\{@shared.api_contacts}/:id",
    @mars.handler(async fn(ctx) -> Unit {
      guard ctx.param("id") is Some(id_str) else {
        println("  -> 400 Missing id")
        ctx.text("Missing id field", status=400)
        return
      }
      println("DELETE /api/contacts/\{id_str}")
      let id = @strconv.parse_int(id_str) catch {
        _ => {
          println("  -> 404 Not Found")
          ctx.text("Not Found", status=404)
          return
        }
      }
      delete_contact(conn, id)
      println("  -> 204 deleted contact \{id}")
      ctx.text("", status=204)
    }),
  )

  println("Server running at http://localhost:\{port}")
  app.serve(host="127.0.0.1", port~) catch {
    err => println("Server failed: \{err}")
  }
}
