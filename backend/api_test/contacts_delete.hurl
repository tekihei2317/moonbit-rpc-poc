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


DELETE {{host}}/api/contacts/{{contact_id}}
HTTP 204


DELETE {{host}}/api/contacts/not-a-number
HTTP 404
[Asserts]
body == "Not Found"


DELETE {{host}}/api/contacts/999
HTTP 204
