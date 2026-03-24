///|
/// Fetch all contacts via RPC.
fn fetch_contacts(dispatch : @rabbita.Dispatch[Msg]) -> @rabbita.Cmd {
  @rpc.call(@shared.list_contacts, (), result => dispatch(GotContacts(result)))
}

///|
/// Create a contact via RPC.
fn add_contact(
  dispatch : @rabbita.Dispatch[Msg],
  input : @shared.CreateContactInput,
) -> @rabbita.Cmd {
  @rpc.call(@shared.create_contact, input, result => {
    dispatch(ContactAdded(result))
  })
}

///|
/// Toggle a contact favorite via RPC.
fn toggle_favorite(dispatch : @rabbita.Dispatch[Msg], id : Int) -> @rabbita.Cmd {
  @rpc.call(@shared.toggle_contact_favorite, { id, }, result => {
    dispatch(FavoriteToggled(result))
  })
}

///|
/// Delete a contact via RPC.
fn delete_contact(dispatch : @rabbita.Dispatch[Msg], id : Int) -> @rabbita.Cmd {
  @rpc.call(@shared.delete_contact, { id, }, result => {
    dispatch(ContactDeleted(result |> Result::map(_ => id)))
  })
}
