///|
pub(all) struct Model {
  contacts : Array[@shared.Contact]
  search_query : String
  name_input : String
  email_input : String
  phone_input : String
  show_form : Bool
} derive(Debug)

///|
pub(all) enum Msg {
  Init
  /// Response from fetching all contacts from the server.
  GotContacts(Result[Array[@shared.Contact], String])
  /// User changed the search input text.
  SearchChanged(String)
  /// Toggle visibility of the add-contact form.
  ToggleForm
  /// User changed the name field in the add-contact form.
  NameInputChanged(String)
  /// User changed the email field in the add-contact form.
  EmailInputChanged(String)
  /// User changed the phone field in the add-contact form.
  PhoneInputChanged(String)
  /// User submitted the add-contact form.
  AddContact
  /// Response from the server after creating a new contact.
  ContactAdded(Result[@shared.Contact, String])
  /// User clicked the favorite star on a contact.
  ToggleFavorite(Int)
  /// Response from the server after toggling favorite status.
  FavoriteToggled(Result[@shared.Contact, String])
  /// User clicked the delete button on a contact.
  DeleteContact(Int)
  /// Response from the server after deleting a contact.
  ContactDeleted(Result[Int, String])
} derive(Debug)

///|
#warnings("-unresolved_type_variable")
pub fn Model::update(
  self : Model,
  msg~ : Msg,
  dispatch~ : @rabbita.Dispatch[Msg],
) -> (Model, @rabbita.Cmd) {
  match msg {
    Init => (self, fetch_contacts(dispatch))
    GotContacts(Ok(contacts)) => ({ ..self, contacts, }, @rabbita.none)
    GotContacts(Err(_)) => (self, @rabbita.none)
    SearchChanged(v) => ({ ..self, search_query: v }, @rabbita.none)
    ToggleForm => ({ ..self, show_form: !self.show_form }, @rabbita.none)
    NameInputChanged(v) => ({ ..self, name_input: v }, @rabbita.none)
    EmailInputChanged(v) => ({ ..self, email_input: v }, @rabbita.none)
    PhoneInputChanged(v) => ({ ..self, phone_input: v }, @rabbita.none)
    AddContact => {
      if !@shared.validate_name(self.name_input) {
        return (self, @rabbita.none)
      }
      if !@shared.validate_email(self.email_input) {
        return (self, @rabbita.none)
      }
      if !@shared.validate_phone(self.phone_input) {
        return (self, @rabbita.none)
      }
      let body : Json = {
        "name": self.name_input,
        "email": self.email_input,
        "phone": self.phone_input,
      }
      (
        {
          ..self,
          name_input: "",
          email_input: "",
          phone_input: "",
          show_form: false,
        },
        add_contact(dispatch, body),
      )
    }
    ContactAdded(Ok(contact)) => {
      let contacts = self.contacts.copy()
      contacts.push(contact)
      ({ ..self, contacts, }, @rabbita.none)
    }
    ContactAdded(Err(_)) => (self, @rabbita.none)
    ToggleFavorite(id) => (self, toggle_favorite(dispatch, id))
    FavoriteToggled(Ok(updated)) => {
      let contacts = self.contacts.map(fn(c) {
        if c.id == updated.id {
          updated
        } else {
          c
        }
      })
      ({ ..self, contacts, }, @rabbita.none)
    }
    FavoriteToggled(Err(_)) => (self, @rabbita.none)
    DeleteContact(id) => (self, delete_contact(dispatch, id))
    ContactDeleted(Ok(id)) => {
      let contacts = self.contacts.filter(fn(c) { c.id != id })
      ({ ..self, contacts, }, @rabbita.none)
    }
    ContactDeleted(Err(_)) => (self, @rabbita.none)
  }
}

///|
pub fn Model::view(
  self : Model,
  dispatch : @rabbita.Dispatch[Msg],
) -> @rabbita.Html {
  let sorted = @shared.sort_contacts(self.contacts)
  let filtered = @shared.filter_contacts(sorted, self.search_query)
  let favorites = filtered.filter(fn(c) { c.favorite })
  let non_favorites = filtered.filter(fn(c) { !c.favorite })

  let sections : Array[@rabbita.Html] = []

  sections.push(
    @html.div(style=header_style, [
      @html.h1(style=header_title_style, "Contacts"),
      @html.p(style=header_subtitle_style, "Your address book"),
    ]),
  )

  sections.push(
    @html.div(style=search_wrapper_style, [
      @html.input(
        input_type=Text,
        placeholder="Search contacts...",
        value=self.search_query,
        on_input=fn(v) { dispatch(SearchChanged(v)) },
        style=search_input_style,
        "",
      ),
    ]),
  )

  let contact_count = self.contacts.length()
  let count_suffix = if contact_count != 1 { "s" } else { "" }
  let form_section = if self.show_form {
    @html.form(on_submit=dispatch(AddContact), style=form_style, [
      @html.input(
        input_type=Text,
        placeholder="Name",
        value=self.name_input,
        on_input=fn(v) { dispatch(NameInputChanged(v)) },
        style=input_style,
        "",
      ),
      @html.input(
        input_type=Text,
        placeholder="Email",
        value=self.email_input,
        on_input=fn(v) { dispatch(EmailInputChanged(v)) },
        style=input_style,
        "",
      ),
      @html.input(
        input_type=Text,
        placeholder="Phone",
        value=self.phone_input,
        on_input=fn(v) { dispatch(PhoneInputChanged(v)) },
        style=input_style,
        "",
      ),
      @html.button(type_="submit", style=submit_btn_style, "Save Contact"),
    ])
  } else {
    @html.div(style=[], "")
  }

  sections.push(
    view_card("", [
      @html.div(style=toolbar_style, [
        @html.span(
          style=contact_count_style,
          "\{contact_count} contact\{count_suffix}",
        ),
        @html.button(
          on_click=dispatch(ToggleForm),
          style=add_contact_btn_style,
          if self.show_form {
            "Cancel"
          } else {
            "+ Add Contact"
          },
        ),
      ]),
      form_section,
    ]),
  )

  if !favorites.is_empty() {
    sections.push(
      view_card(
        "Favorites",
        favorites.map(fn(c) { view_contact_row(dispatch, c) }),
      ),
    )
  }

  if !non_favorites.is_empty() {
    sections.push(
      view_card(
        if !favorites.is_empty() {
          "Other Contacts"
        } else {
          "All Contacts"
        },
        non_favorites.map(fn(c) { view_contact_row(dispatch, c) }),
      ),
    )
  } else if favorites.is_empty() &&
    !self.contacts.is_empty() &&
    !self.search_query.is_empty() {
    sections.push(
      view_card("Contacts", [
        @html.p(style=empty_msg_style, "No contacts match your search"),
      ]),
    )
  } else if self.contacts.is_empty() {
    sections.push(
      view_card("Contacts", [
        @html.p(
          style=empty_msg_style,
          "No contacts yet. Add your first contact!",
        ),
      ]),
    )
  }

  @html.div(style=container_style, sections)
}
