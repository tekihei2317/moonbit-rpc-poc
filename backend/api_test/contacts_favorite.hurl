POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice@example.com",
  "phone": "090-1234-5678"
}
HTTP 201
[Captures]
contact_id: jsonpath "$.id"


POST {{host}}/api/contacts/{{contact_id}}/favorite
Content-Type: application/json

{}
HTTP 200
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$.id" == {{contact_id}}
jsonpath "$.favorite" == true


POST {{host}}/api/contacts/not-a-number/favorite
Content-Type: application/json

{}
HTTP 500
[Asserts]
body == "invalid syntax"
