///|
/// Pick a consistent color for a contact based on their id.
fn person_color(id : Int) -> String {
  let colors = [
    "#667eea", "#e91e63", "#00bcd4", "#ff9800", "#8bc34a", "#9c27b0", "#009688",
    "#f44336", "#3f51b5", "#795548",
  ]
  colors[(id - 1) % colors.length()]
}

///|
/// Render a white card with a section title.
fn view_card(title : String, children : Array[@rabbita.Html]) -> @rabbita.Html {
  let all : Array[@rabbita.Html] = []
  if !title.is_empty() {
    all.push(@html.h2(style=card_title_style, title))
  }
  all.append(children[:])
  @html.div(style=card_style, all)
}

///|
/// Render a single contact row.
fn view_contact_row(
  dispatch : @rabbita.Dispatch[Msg],
  contact : @shared.Contact,
) -> @rabbita.Html {
  let color = person_color(contact.id)
  let initials = @shared.get_initials(contact.name)
  @html.div(style=contact_row_style, [
    @html.div(
      style=[
        "width: 42px",
        "height: 42px",
        "border-radius: 50%",
        "flex-shrink: 0",
        "background: \{color}",
        "color: white",
        "font-size: 15px",
        "font-weight: 700",
        "display: flex",
        "align-items: center",
        "justify-content: center",
      ],
      initials,
    ),
    @html.div(style=contact_info_style, [
      @html.div(style=contact_name_style, contact.name),
      @html.div(style=contact_email_style, contact.email),
      @html.div(style=contact_phone_style, @shared.format_phone(contact.phone)),
    ]),
    @html.button(
      on_click=dispatch(ToggleFavorite(contact.id)),
      style=fav_btn_style,
      if contact.favorite {
        "\u{2605}"
      } else {
        "\u{2606}"
      },
    ),
    @html.button(
      on_click=dispatch(DeleteContact(contact.id)),
      style=delete_btn_style,
      "X",
    ),
  ])
}
