GET {{host}}/api/rpc/contacts.list
HTTP 200
[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$" count == 0
