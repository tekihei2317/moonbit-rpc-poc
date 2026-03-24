nuF# RPC Specification

tRPCと同じような実装にする。簡単のため、パスパラメータを考えなくていいから。

[HTTP RPC Specification | tRPC](https://trpc.io/docs/rpc)

```text
GET	.query()	Input JSON-stringified in query param. e.g. myQuery?input=${encodeURIComponent(JSON.stringify(input))}
POST	.mutation()	Input as POST body.
```

## 実装のイメージ

APIのパスを持った`Route`オブジェクトを作成し、クライアントはそのパスにHTTPリクエストを送る。サーバーサイドは、そのパスに対してハンドラを設定する。

サーバーサイドとクライアントで共通のフォーマットバリデーションを利用できる。

```mbt
enum Operation {
  Query
  Mutation
}

struct Route[Input, Output] {
  operation : Operation
  input: Vaidator[Input] // 入力をバリデーションする
  name: String
}

let get_contacts = Route[Unit, Array[@shared.Contact]]::{ operation: Query, name: "get_contacts" }
let add_contact = Route[ContactForm, @shared.Cotnact]::{ operation: Mutation, name: "add_contact" }
let toggle_favorite = Route[Int, @shared.Contact]::{ operation: Mutation, name: "toggle_favorite" }
let delete_contact = Route[Int, Unit]::{ operation: Mutation, name: "delete_contact" }
```

### クライアントサイド

```mbt
// TODO: エラー情報を持たせる
suberror RpcError {
  BadRequest
  Unauthorized
  Forbidden
  NotFound
  InternalServerError
}
```

```mbt
let add_contact = Route[ContactForm, @shared.Cotnact]::{ operation: Mutation, name: "add_contact" }
let result = @rpc.call(route, { name, email, phone }) // Result[@shared.Contact, RpcError]
//
```

### サーバーサイド

TODO:

```mbt
```
