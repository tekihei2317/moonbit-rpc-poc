# moonbit-rpc-poc

フルスタックMoonBitでRPCする検証

## Contacts App

サンプルアプリとして`isomorphic/contacts`を移植しています。フロントエンドのビルドツールは `vite` + `vite-plugin-moonbit` に変更し、Web エントリは `frontend/` にまとめています。

### Run

```bash
npm install
make backend-dev
```

```bash
make frontend-dev
```

- フロントエンド: http://localhost:5173
- API: http://localhost:4000
