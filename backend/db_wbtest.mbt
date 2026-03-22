///|
fn with_memory_db(f : (@sqlite3.Connection) -> Unit raise) -> Unit raise {
  let conn = @sqlite3.Connection::open(":memory:")
  init_db(conn)
  f(conn)
}

///|
test "get_all_contacts returns empty array for new database" {
  with_memory_db(conn => {
    let contacts = get_all_contacts(conn)
    assert_eq(contacts.length(), 0)
  })
}

///|
test "create_contact persists a contact" {
  with_memory_db(conn => {
    let created = create_contact(
      conn, "Alice Smith", "alice@example.com", "090-1234-5678",
    )
    assert_eq(created.id, 1)
    assert_eq(created.name, "Alice Smith")
    assert_eq(created.email, "alice@example.com")
    assert_eq(created.phone, "090-1234-5678")
    assert_false(created.favorite)

    let contacts = get_all_contacts(conn)
    assert_eq(contacts.length(), 1)
    let saved = contacts[0]
    assert_eq(saved.id, 1)
    assert_eq(saved.name, "Alice Smith")
    assert_eq(saved.email, "alice@example.com")
    assert_eq(saved.phone, "090-1234-5678")
    assert_false(saved.favorite)
  })
}

///|
test "get_all_contacts returns contacts ordered by id" {
  with_memory_db(conn => {
    ignore(create_contact(conn, "Alice Smith", "alice@example.com", "111"))
    ignore(create_contact(conn, "Bob Jones", "bob@example.com", "222"))

    let contacts = get_all_contacts(conn)
    assert_eq(contacts.length(), 2)
    assert_eq(contacts[0].name, "Alice Smith")
    assert_eq(contacts[1].name, "Bob Jones")
  })
}

///|
test "toggle_favorite flips favorite flag" {
  with_memory_db(conn => {
    let created = create_contact(
      conn, "Alice Smith", "alice@example.com", "090-1234-5678",
    )

    let favorited = toggle_favorite(conn, created.id)
    assert_true(favorited.favorite)

    let unfavorited = toggle_favorite(conn, created.id)
    assert_false(unfavorited.favorite)
  })
}

///|
test "delete_contact removes contact from database" {
  with_memory_db(conn => {
    let created = create_contact(
      conn, "Alice Smith", "alice@example.com", "090-1234-5678",
    )
    delete_contact(conn, created.id)

    let contacts = get_all_contacts(conn)
    assert_eq(contacts.length(), 0)
  })
}
