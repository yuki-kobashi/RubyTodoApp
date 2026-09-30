# 開発ガイド

ソースを編集しながら開発するための手順をまとめています。アプリを動かして試すだけなら、[README](../README.md) の「[アプリを動かす(ローカル実行)](../README.md#アプリを動かすローカル実行)」を参照してください。

開発では、Linux 環境に入れた Ruby で Rails を直接動かし、MySQL だけを Docker(`compose.dev.yml`)で動かします。
コマンドは、リポジトリのディレクトリで Linux 環境のシェルから実行します。

## 目次

- [開発環境の構築](#開発環境の構築)
- [よく使うコマンド](#よく使うコマンド)
- [テスト](#テスト)
- [Lint・フォーマット(RuboCop)](#lintフォーマットrubocop)
- [DB を作り直す](#db-を作り直す)
- [メールを確認する](#メールを確認する)
- [gem を追加・更新する](#gem-を追加更新する)
- [2つの compose ファイルの使い分け](#2つの-compose-ファイルの使い分け)
- [Ruby を入れずにコンテナで開発する](#ruby-を入れずにコンテナで開発する)
- [改行コード](#改行コード)
- [トラブルシューティング](#トラブルシューティング)

## 開発環境の構築

先に README の「[準備:Linux 環境と Docker](../README.md#準備linux-環境と-docker)」を済ませてください。

| ソフトウェア | バージョン | 備考 |
|---|---|---|
| Ruby | 3.1.2 | `.ruby-version` と `Gemfile` で指定 |
| Bundler | 2.3.7 | `Gemfile.lock` で指定(Ruby 3.1.2 に同梱) |
| MySQL | 8.0 | `compose.dev.yml` で起動する |

1. Ruby と gem のビルドに必要なパッケージを入れます(Ubuntu の場合)。

   ```bash
   sudo apt update
   sudo apt install -y build-essential git curl libssl-dev libyaml-dev zlib1g-dev libreadline-dev libffi-dev default-libmysqlclient-dev pkg-config
   ```

2. [rbenv](https://github.com/rbenv/rbenv) と ruby-build を入れます(入っていれば不要です)。

   ```bash
   git clone https://github.com/rbenv/rbenv.git ~/.rbenv
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
   exec bash
   ```

3. リポジトリを取得し、Ruby 3.1.2 を入れます。`.ruby-version` があるので、このディレクトリでは 3.1.2 が使われます。

   ```bash
   git clone https://github.com/yuki-kobashi/RubyTodoApp.git
   cd RubyTodoApp
   rbenv install 3.1.2
   ruby -v  # ruby 3.1.2 と表示されれば OK
   ```

4. 環境変数のファイルを作ります。`.env` は Rails(dotenv-rails)と compose の両方が読み込みます。開発では `DATABASE_PASSWORD` があれば動きます(各項目の意味は README の「[設定(環境変数)](../README.md#設定環境変数)」)。

   ```bash
   cp .env.example .env
   ```

5. MySQL を起動します(準備ができるまで待ってから戻ります)。

   ```bash
   docker compose -f compose.dev.yml up -d --wait db
   ```

6. gem のインストールと DB の作成・マイグレーションを行います。初回は gem のコンパイルに数分かかります。

   ```bash
   bin/setup
   ```

7. サーバーを起動し、<http://localhost:3000> を開きます。

   ```bash
   bin/rails server
   ```

開発環境では、確認メールは <http://localhost:3000/letter_opener> で見られます。
ローカル実行(`compose.yml`)もアプリに 3000 番ポートを使うので、`bin/rails server` と同時には起動できません。

## よく使うコマンド

| やりたいこと | コマンド |
|---|---|
| MySQL を起動する | `docker compose -f compose.dev.yml up -d --wait db` |
| MySQL を止める(データは残る) | `docker compose -f compose.dev.yml down` |
| MySQL のログを見る | `docker compose -f compose.dev.yml logs -f db` |
| サーバーを起動する | `bin/rails server` |
| Rails コンソール | `bin/rails console` |
| DB コンソール | `bin/rails dbconsole -p` |
| マイグレーション | `bin/rails db:migrate` |
| ルーティングの一覧 | `bin/rails routes` |

`bin/rails dbconsole` には、MySQL のクライアント(`mysql` コマンド)が必要です。入っていない場合は `docker compose -f compose.dev.yml exec db mysql -u root -p` で、コンテナの中のクライアントを使えます。

## テスト

テストは Minitest で書いています(`test/` 配下)。MySQL を起動した状態で実行します。

```bash
# すべてのテストを実行する
bin/rails test

# ファイルを指定する
bin/rails test test/controllers/todos_controller_test.rb

# 行番号でテストを1つだけ実行する
bin/rails test test/controllers/todos_controller_test.rb:6
```

- テスト用の DB(`todo_app_test`)は `bin/setup` で作られます。マイグレーションの変更は、テストの実行時に `db/schema.rb` から自動で反映されます
- テストデータは `test/fixtures/*.yml` にあります。fixture のユーザーのパスワードは `password` です
- `test/system` のシステムテスト(ブラウザを使うテスト)は今はありません。実行するには Chrome が必要です

## Lint・フォーマット(RuboCop)

Linter・Formatter として RuboCop(rubocop-rails を含む)を使っています。設定は `.rubocop.yml` で、ルールは RuboCop・rubocop-rails の既定のままです。HAML のビューは対象外です。

```bash
# 検査する
bundle exec rubocop

# 安全に直せる指摘を自動で直す(フォーマット)
bundle exec rubocop -a

# ファイルを指定する
bundle exec rubocop app/models/todo.rb
```

### `.rubocop_todo.yml` について

RuboCop を導入した時点で既存のコードにあった指摘は、`.rubocop_todo.yml` に「ルールごとに、指摘のあったファイル」として記録し、検査から外しています。
記録されているのは、そのファイルのそのルールだけです。新しく作ったファイルや、記録されていないルールは検査されます。

指摘を直して記録を減らすときは、次のようにします。

1. `.rubocop_todo.yml` から、直したいルールの項目(またはその中のファイル)を消す
2. `bundle exec rubocop` を実行して指摘を確認し、コードを直す(`-a` で直せるものもある)
3. 指摘がなくなったら、コードと `.rubocop_todo.yml` の変更を一緒にコミットする

記録を今の状態に合わせて作り直すときは、次のコマンドを実行します(導入時と同じオプション)。

```bash
bundle exec rubocop --auto-gen-config --no-exclude-limit --no-auto-gen-timestamp
```

## DB を作り直す

データを消して最初からやり直すときは、ボリュームごと消してから `bin/setup` を実行します。

```bash
docker compose -f compose.dev.yml down -v
docker compose -f compose.dev.yml up -d --wait db
bin/setup
```

MySQL は動かしたまま、DB の中身だけを作り直すこともできます(`db/seeds.rb` も実行されます)。

```bash
bin/rails db:reset
```

## メールを確認する

ユーザー登録やパスワード再設定のメールは、実際には送られません。

- 開発:letter_opener_web が受け取ります。<http://localhost:3000/letter_opener> で見られます
- ローカル実行(`compose.yml`):Mailpit が受け取ります。<http://localhost:8025> で見られます

登録したユーザーは、確認メールのリンクを開くまでログインできません。

## gem を追加・更新する

1. `Gemfile` を編集する
2. `bundle install` を実行する(`Gemfile.lock` が更新される)
3. `Gemfile` と `Gemfile.lock` を一緒にコミットする

`Gemfile.lock` の Bundler のバージョン(`BUNDLED WITH`)は 2.3.7 です。`bundle update --bundler` で上げないでください。

## 2つの compose ファイルの使い分け

| | `compose.yml`(ローカル実行) | `compose.dev.yml`(開発) |
|---|---|---|
| 目的 | アプリを本番と同じイメージで試す | 開発・テストで使う MySQL を動かす |
| サービス | app(`Dockerfile`)・db・mailpit | db(コンテナで開発する場合は app も) |
| Rails の環境 | production | development / test(Rails は Linux 環境で直接動かす) |
| DB のデータ | ボリューム `rubytodoapp-local_mysql_data` | ボリューム `rubytodoapp-dev_mysql_data` |
| DB のポート | 公開しない | `127.0.0.1:3306`(`DATABASE_PORT` で変更可) |
| 確認メール | Mailpit(<http://localhost:8025>) | letter_opener_web(<http://localhost:3000/letter_opener>) |
| コマンド | `docker compose ...` | `docker compose -f compose.dev.yml ...` |

DB のデータは別々のボリュームに入るので、片方を作り直してももう片方には影響しません。

以前の `docker-compose.yml`(MySQL だけを起動していたもの)で作った DB のデータは、ボリューム `rubytodoapp_mysql_data` に残っていて、今の2つの compose からは使いません。不要になったら `docker volume rm rubytodoapp_mysql_data` で消せます(元に戻せないので、中身を確認してから)。

## Ruby を入れずにコンテナで開発する

Linux 環境に Ruby を入れたくない場合は、`compose.dev.yml` の app サービスを使って、Rails もコンテナの中で動かせます。
イメージは `Dockerfile.dev` から作ります(development・test の gem が入り、ソースはマウントします)。ソースの編集と git の操作は、今までどおりコンテナの外で行います。

```bash
# イメージを作る(Gemfile を変えたときも実行する)
docker compose -f compose.dev.yml build

# gem の確認と DB の作成・マイグレーション
docker compose -f compose.dev.yml run --rm app bin/setup

# サーバーを起動する(http://localhost:3000)
docker compose -f compose.dev.yml up

# テスト・RuboCop・Rails コンソール
docker compose -f compose.dev.yml run --rm app bin/rails test
docker compose -f compose.dev.yml run --rm --no-deps app bundle exec rubocop
docker compose -f compose.dev.yml run --rm app bin/rails console
```

- `--no-deps` を付けると、MySQL を起動せずに実行します(DB を使わないコマンド向け)
- gem を追加するときは、`docker compose -f compose.dev.yml run --rm --no-deps app bundle install` で `Gemfile.lock` を更新してから、`build` でイメージを作り直します
- `debug` gem のブレークポイント(`binding.break`)で止めたときは、`up -d` で起動しておき、`docker attach rubytodoapp-dev-app-1` で操作します。抜けるときは `Ctrl+P` → `Ctrl+Q` を押します

コンテナは UID・GID が 1000 のユーザーで動くので、コンテナが作ったファイル(`log/`、`tmp/` など)は、Linux 環境では UID 1000 の持ち物になります。
Linux 環境のユーザーの UID・GID が 1000 以外のとき(`id -u`・`id -g` で確認)は、`.env` に `DEV_UID`・`DEV_GID` を書いて、イメージを作り直してください。

```dotenv
DEV_UID=1001
DEV_GID=1001
```

## 改行コード

改行コードは LF にそろえています。

- `.gitattributes` の `* text=auto eol=lf` により、Windows 側で clone しても LF のまま取り出されます
- `.editorconfig` により、対応するエディタは LF・UTF-8・インデント2で保存します

CRLF のシェルスクリプト(`bin/docker-entrypoint` など)はコンテナの中で動かないので、改行コードを変えないでください。

## トラブルシューティング

**`.env に DATABASE_PASSWORD を設定してください` と表示されて MySQL が起動しない**
`.env` がありません。`cp .env.example .env` で作ってください。

**`secret_key_base ... must be a type of String` と表示されて Rails が起動しない**
`.env` の `SECRET_KEY_BASE` が空の値で有効になっています。行の先頭に `#` を付けてコメントにするか、README の「[アプリを動かす](../README.md#アプリを動かすローカル実行)」の手順 2 のコマンドで値を入れてください。

**`bin/setup` で mysql2 のビルドに失敗する**
MySQL のクライアントライブラリが足りていません。[開発環境の構築](#開発環境の構築)の手順 1 のパッケージ(特に `default-libmysqlclient-dev` と `pkg-config`)が入っているか確認してください。

**`Can't connect to MySQL server on '127.0.0.1'` と表示される**
MySQL が起動していません。`docker compose -f compose.dev.yml up -d --wait db` を実行してください。

**`port is already allocated` と表示される**
3000 番(アプリ)か 3306 番(開発用の MySQL)を、ほかのプログラムが使っています。ローカル実行(`compose.yml`)を起動したままにしていないか確認してください。Linux 環境に入れた MySQL などと 3306 番がぶつかる場合は、`.env` で `DATABASE_PORT=3307` のように変えられます。

**`.env` の `DATABASE_PASSWORD` を変えたら DB に接続できなくなった**
MySQL のパスワードは、DB のデータを最初に作ったときにだけ設定されます。[DB を作り直す](#db-を作り直す)の手順でデータを消してから作り直してください。

**Bundler のバージョンのエラーが出る**
`Gemfile.lock` に合わせて `gem install bundler -v 2.3.7` を実行してください。`bundle update --bundler` は `Gemfile.lock` を書き換えてしまうので使わないでください。
