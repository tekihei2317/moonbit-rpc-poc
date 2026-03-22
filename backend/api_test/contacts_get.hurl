GET {{host}}/api/contacts
HTTP 200
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$" count == 0
