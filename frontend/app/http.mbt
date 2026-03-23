///|
/// Fetch all contacts from the backend via GET /api/contacts.
fn fetch_contacts(dispatch : @rabbita.Dispatch[Msg]) -> @rabbita.Cmd {
  @http.get(
    @shared.api_contacts,
    expect=Json(result => dispatch(GotContacts(result)), json => {
      Ok(@json.from_json(json)) catch {
        _ => Err("Failed to decode contacts")
      }
    }),
  )
}

///|
/// Create a contact via POST /api/contacts.
fn add_contact(dispatch : @rabbita.Dispatch[Msg], body : Json) -> @rabbita.Cmd {
  @http.post(
    @shared.api_contacts,
    Json(body),
    expect=Json(result => dispatch(ContactAdded(result)), json => {
      Ok(@json.from_json(json)) catch {
        _ => Err("Failed to decode contact")
      }
    }),
  )
}

///|
/// Toggle a contact favorite via POST /api/contacts/:id/favorite.
fn toggle_favorite(dispatch : @rabbita.Dispatch[Msg], id : Int) -> @rabbita.Cmd {
  @http.post(
    @shared.api_contact_favorite(id),
    Json({}),
    expect=Json(result => dispatch(FavoriteToggled(result)), json => {
      Ok(@json.from_json(json)) catch {
        _ => Err("Failed to decode contact")
      }
    }),
  )
}

///|
/// Delete a contact via DELETE /api/contacts/:id.
#warnings("-unresolved_type_variable")
fn delete_contact(dispatch : @rabbita.Dispatch[Msg], id : Int) -> @rabbita.Cmd {
  @http.delete(
    @shared.api_contact(id),
    expect=Text(result => {
      dispatch(ContactDeleted(result |> Result::map(_ => id)))
    }),
  )
}
