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


POST {{host}}/api/rpc/contacts.delete
Content-Type: application/json

{
  "id": {{contact_id}}
}
HTTP 200
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
body == "null"


POST {{host}}/api/rpc/contacts.delete
Content-Type: application/json

{
  "id": "not-a-number"
}
HTTP 400
[Asserts]
body == "Invalid input"


POST {{host}}/api/rpc/contacts.delete
Content-Type: application/json

{
  "id": 999
}
HTTP 200
[Asserts]
body == "null"
