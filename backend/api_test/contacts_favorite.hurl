POST {{host}}/api/rpc/contacts.create
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice@example.com",
  "phone": "090-1234-5678"
}
HTTP 200
[Captures]
contact_id: jsonpath "$.id"


POST {{host}}/api/rpc/contacts.toggle_favorite
Content-Type: application/json

{
  "id": {{contact_id}}
}
HTTP 200
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$.id" == {{contact_id}}
jsonpath "$.favorite" == true


POST {{host}}/api/rpc/contacts.toggle_favorite
Content-Type: application/json

{
  "id": "not-a-number"
}
HTTP 400
[Asserts]
body == "Invalid input"
