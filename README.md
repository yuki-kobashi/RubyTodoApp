# Ruby Todo App

deviceやレスポンシブデザインの学習用に作ったシンプルで使いやすいTodoアプリケーションです。

## 環境

- Ruby 3.1.2
- Rails 7.1.5.1
- MySQL 5.7以上

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone <repository-url>
cd RubyTodoApp
```

### 2. 依存関係をインストール

```bash
bundle install
```

### 3. データベースの設定

MySQLが起動していることを確認してください。デフォルトの設定は以下の通りです：

- ユーザー名: `root`
- パスワード: `password`
- ホスト: `127.0.0.1`
- ポート: `3306`

設定を変更する場合は `config/database.yml` を編集してください。

### 4. データベースを作成・マイグレーション

```bash
rails db:create
rails db:migrate
```

### 5. サーバーを起動

```bash
rails server
```

ブラウザで [http://localhost:3000](http://localhost:3000) にアクセスしてください。

## 機能

- ユーザー登録・ログイン機能（Devise使用）
- Todoの作成・編集・削除
- Todoの完了/未完了切り替え
- レスポンシブデザイン（Bootstrap 5使用）

## トラブルシューティング

### データベース接続エラーが発生する場合

1. MySQLが起動しているか確認してください
2. `config/database.yml` の認証情報が正しいか確認してください
3. データベースユーザーに適切な権限があるか確認してください

### Bundlerのバージョンエラーが発生する場合

```bash
gem install bundler
bundle update --bundler
```
