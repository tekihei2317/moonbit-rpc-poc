# RPC

このリポジトリの RPC は、shared の `Route[Input, Output]` を frontend と backend で共有する薄い実装です。

## HTTP 形式

- `query`: `GET /api/rpc/<name>?input=<json>`
- `mutation`: `POST /api/rpc/<name>`

`query` の入力は query param の `input` に JSON string を入れます。`mutation` の入力は JSON body です。レスポンスは成功時に JSON、失敗時に plain text を返します。

## パッケージ構成

- `rpc`: `Route`, `RpcError`, `query`, `mutation`
- `rpc/client`: frontend 用の `@rpc.call`
- `rpc/server`: backend 用の `@rpc.handle`

target が分かれるので、client と server は別 package にしています。

## Route 定義

Route は shared package で定義します。

```moonbit
pub let list_contacts : @rpc.Route[Unit, Array[Contact]] = @rpc.query(
  "contacts.list",
)

pub let create_contact : @rpc.Route[CreateContactInput, Contact] = @rpc.mutation(
  "contacts.create",
)

pub let toggle_contact_favorite : @rpc.Route[ContactIdInput, Contact] = @rpc.mutation(
  "contacts.toggle_favorite",
)

pub let delete_contact : @rpc.Route[ContactIdInput, Unit] = @rpc.mutation(
  "contacts.delete",
)
```

## サーバー側

backend では `@rpc.handle` で route と handler を結びます。

```moonbit
@rpc.handle(app, @shared.list_contacts, _ => Ok(get_all_contacts(conn)))

@rpc.handle(app, @shared.create_contact, input => {
  let contact = create_contact(conn, input.name, input.email, input.phone)
  Ok(contact)
})
```

handler は `Result[Output, RpcError]` を返します。

## クライアント側

frontend では `@rpc.call` を使います。

```moonbit
@rpc.call(@shared.list_contacts, (), result => dispatch(GotContacts(result)))

@rpc.call(
  @shared.create_contact,
  @shared.create_contact_input(name, email, phone),
  result => dispatch(ContactAdded(result)),
)
```

`@rpc.call` は route、input、`Result` を `Cmd` に変換する callback の 3 引数を取ります。
