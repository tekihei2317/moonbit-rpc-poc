# Tasks

## Todo

- 環境構築をする
  - フロントエンドは`rabitta`、`vite-plugin-moonbit`を使う
  - サーバーサイドは`mars`を使う
- [moonbit-community/isomorphic](https://github.com/moonbit-community/isomorphic)の`contacts`アプリを移植する
- RPCの機能を作成する

## In-Progress

## Done

## メモ

### 環境構築について

サーバーサイドはNativeビルドで、[mizchi/mars.mbt](https://github.com/mizchi/mars.mbt)を使う。

フロントエンドはJSビルドで、[moonbit-community/rabbita](https://github.com/moonbit-community/rabbita)を使う。

[mizchi/vite-plugin-moonbit](https://github.com/mizchi/vite-plugin-moonbit)で、フロントエンドのホットリロードができるようにする。

### 作成するアプリについて

[isomorphic/contacts](https://github.com/moonbit-community/isomorphic/tree/65d4bd9b5300f5e416a06b7aa230e20c7fef1126/contacts)を実装する。連絡先を登録するアプリ。1ページで完結していて、複数のフォームがあり、バリデーションの要件があるため。

まずはこのアプリを参考コードを元に実装する。E2Eテストを書いて、サーバーサイドを`mars`に移植し、納得いく形にリファクタリングする。

それから、RPCを実装していく。

### RPCについて
