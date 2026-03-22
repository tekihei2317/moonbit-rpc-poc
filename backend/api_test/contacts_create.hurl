POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice@example.com",
  "phone": "090-1234-5678"
}
HTTP 201
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$.id" == 1
jsonpath "$.name" == "Alice Smith"
jsonpath "$.email" == "alice@example.com"
jsonpath "$.phone" == "090-1234-5678"
jsonpath "$.favorite" == false


POST {{host}}/api/contacts
Content-Type: application/json

{
  "email": "alice@example.com",
  "phone": "090-1234-5678"
}
HTTP 400
[Asserts]
body == "Missing name field"


POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "phone": "090-1234-5678"
}
HTTP 400
[Asserts]
body == "Missing email field"


POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice@example.com"
}
HTTP 400
[Asserts]
body == "Missing phone field"


POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "",
  "email": "alice@example.com",
  "phone": "090-1234-5678"
}
HTTP 400
[Asserts]
body == "Name must be 1-50 characters"


POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice",
  "phone": "090-1234-5678"
}
HTTP 400
[Asserts]
body == "Email must be valid (contain @ and . after @)"


POST {{host}}/api/contacts
Content-Type: application/json

{
  "name": "Alice Smith",
  "email": "alice@example.com",
  "phone": "abc"
}
HTTP 400
[Asserts]
body == "Phone must contain only digits, spaces, hyphens, parens, and +"
