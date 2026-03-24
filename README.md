# moonbit-rpc-poc

フルスタックMoonBitでRPCする検証

## アプリについて

[moonbit-community/isomorphic](https://github.com/moonbit-community/isomorphic)の`Contacts`を移植し、いくつか変更を加えています。

### ライブラリ

- フロントエンド: `vite`、`vite-plugin-moonbit`、`moonbit-community/rabbita`
- バックエンド: `mizchi/mars`、`moonbit-community/sqlite3`

## 実行方法

```bash
npm install
make backend-dev
```

```bash
make frontend-dev
```

- フロントエンド: http://localhost:5173
- API: http://localhost:4000

## RPCについて

RPCの仕様は[docs/rpc.md](/Users/tekihei2317/ghq/github.com/tekihei2317/moonbit-rpc-poc/docs/rpc.md)にまとめています。

共有パッケージに`route`を置き、frontendからは`@rpc.call`、backendからは`@rpc.handle` を使います。

```mbt
// shared/routes.mbt
pub let list_contacts : @rpc.Route[Unit, Array[Contact]] = @rpc.query(
  "contacts.list",
)

pub let create_contact : @rpc.Route[CreateContactInput, Contact] = @rpc.mutation(
  "contacts.create",
)
```

```mbt
// frontend
@rpc.call(@shared.list_contacts, (), result => dispatch(GotContacts(result)))

@rpc.call(
  @shared.create_contact,
  { name, email, phone },
  result => dispatch(ContactAdded(result)),
)
```

```mbt
// backend
@rpc.handle(app, @shared.list_contacts, _ => Ok(get_all_contacts(conn)))

@rpc.handle(app, @shared.create_contact, input => {
  Ok(create_contact(conn, input.name, input.email, input.phone))
})
```

clientとserverはtargetが違うのでpackageを分けています。

- `rpc`: 共通の route / error 型
- `rpc/client`: `@rpc.call`
- `rpc/server`: `@rpc.handle`
