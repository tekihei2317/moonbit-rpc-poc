///|
pub(all) struct CreateContactInput {
  name : String
  email : String
  phone : String
} derive(ToJson, FromJson)

///|
pub(all) struct ContactIdInput {
  id : Int
} derive(ToJson, FromJson)

///|
pub let list_contacts : @rpc.Route[Unit, Array[Contact]] = @rpc.query(
  "contacts.list",
)

///|
pub let create_contact : @rpc.Route[CreateContactInput, Contact] = @rpc.mutation(
  "contacts.create",
)

///|
pub let toggle_contact_favorite : @rpc.Route[ContactIdInput, Contact] = @rpc.mutation(
  "contacts.toggle_favorite",
)

///|
pub let delete_contact : @rpc.Route[ContactIdInput, Unit] = @rpc.mutation(
  "contacts.delete",
)
