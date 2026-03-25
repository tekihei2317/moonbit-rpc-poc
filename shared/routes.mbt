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
pub let list_contacts : Route[Unit, Array[Contact]] = query("contacts.list")

///|
pub let create_contact : Route[CreateContactInput, Contact] = mutation(
  "contacts.create",
)

///|
pub let toggle_contact_favorite : Route[ContactIdInput, Contact] = mutation(
  "contacts.toggle_favorite",
)

///|
pub let delete_contact : Route[ContactIdInput, Unit] = mutation(
  "contacts.delete",
)
