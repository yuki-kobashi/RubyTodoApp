# Ruby Todo App

ログインして使う、シンプルな Todo 管理の Web アプリケーションです。
Devise によるユーザー認証(メールアドレスの確認つき)、HAML、Bootstrap を使ったレスポンシブデザインを学ぶために作りました。
画面は Rails のサーバーサイドレンダリングで作っています。

この README には、アプリを動かすための手順を書いています。
ソースを編集しながら開発する場合(開発環境の構築・テスト・Lint)は、**[開発ガイド(docs/development.md)](docs/development.md)** を参照してください。

## 目次

- [機能](#機能)
- [動作要件](#動作要件)
- [リポジトリの構成](#リポジトリの構成)
- [準備:Linux 環境と Docker](#準備linux-環境と-docker)
- [アプリを動かす(ローカル実行)](#アプリを動かすローカル実行)
- [設定(環境変数)](#設定環境変数)
- [リリース(本番用イメージの作り方)](#リリース本番用イメージの作り方)
- [開発する](#開発する)
- [トラブルシューティング](#トラブルシューティング)
- [既知の制限](#既知の制限)

## 機能

- ユーザー登録・ログイン・パスワード再設定(Devise)
  - 登録すると確認メールが届き、メールのリンクを開くとログインできるようになります
- Todo の作成(タイトル・説明)と削除
- Todo の完了・未完了の切り替え、完了済みの Todo の表示・非表示
- Todo の件数(全体・完了・未完了)の表示
- スマートフォンでも使えるレスポンシブデザイン(Bootstrap 5)

## 動作要件

Linux 環境(Windows では WSL2)で動かす前提です。手順は WSL2 の Ubuntu 22.04 で確認しています。

| ソフトウェア | バージョン | 備考 |
|---|---|---|
| Ruby | 3.1.2 | `.ruby-version` と `Gemfile` で指定 |
| Ruby on Rails | 7.1.5.1 | |
| MySQL | 8.0 | Docker Compose で起動する(`mysql:8.0` イメージ) |
| Docker・Docker Compose | Docker Compose v2(`docker compose` コマンド) | Docker 28.5.1・Compose v2.40.0 で確認 |

アプリを動かすだけなら、必要なのは Docker だけです(Ruby と MySQL はコンテナの中で動きます)。

## リポジトリの構成

アプリの構成は Rails の標準どおりです(`app/`、`config/`、`db/`、`test/` など)。動かし方・開発環境に関わるファイルは次のとおりです。

| ファイル | 役割 |
|---|---|
| `compose.yml` | ローカル実行用。本番用イメージでアプリ・MySQL・Mailpit(メールの確認用)を起動する |
| `Dockerfile` | 本番用イメージ(マルチステージ、非 root ユーザーで実行) |
| `bin/docker-entrypoint` | 本番用イメージの起動時に DB の作成・マイグレーションを行う |
| `.env.example` | 環境変数の見本。`.env` にコピーして使う |
| `compose.dev.yml`・`Dockerfile.dev` | 開発用。開発・テストで使う MySQL などを起動する([開発ガイド](docs/development.md)) |
| `bin/setup` | 開発環境のセットアップ(gem のインストール、DB の作成・マイグレーション) |
| `.rubocop.yml`・`.rubocop_todo.yml` | RuboCop(Linter・Formatter)の設定と、導入時点の指摘の記録 |
| `.gitignore`・`.dockerignore` | Git の管理・Docker のビルドから外すファイル |
| `.gitattributes`・`.editorconfig` | 改行コード(LF)などの統一 |
| `docs/development.md` | 開発ガイド |

## 準備:Linux 環境と Docker

以降のコマンドは、すべて Linux 環境のシェル(bash)で実行します。

### Windows

WSL2 の Ubuntu を使います。

1. PowerShell を管理者として開き、Ubuntu 22.04 をインストールします。終わったら PC を再起動し、スタートメニューから「Ubuntu 22.04」を開いてユーザーを作ります。

   ```powershell
   wsl --install -d Ubuntu-22.04
   ```

2. [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) をインストールします。Settings → Resources → WSL integration で、使う Ubuntu を有効にします。
3. Ubuntu で `docker compose version` を実行し、バージョンが表示されれば準備完了です。

リポジトリは WSL の中(`~/` の下など)に clone してください。Windows 側のフォルダ(`/mnt/c/...`)に置くと、ファイルの読み書きが遅く、改行コードやファイルの権限の問題も起きやすくなります。

### macOS

[Colima](https://github.com/abiosoft/colima) などで同じように Linux 環境(Ubuntu など)と Docker を用意し、その中で以降の手順を実行してください。

### Linux

[Docker Engine](https://docs.docker.com/engine/install/) と Compose プラグインをインストールしてください。

## アプリを動かす(ローカル実行)

本番用のイメージでアプリを起動し、ブラウザで試す手順です。

1. リポジトリを取得します。

   ```bash
   git clone https://github.com/yuki-kobashi/RubyTodoApp.git
   cd RubyTodoApp
   ```

2. 環境変数のファイルを作り、署名用の鍵(`SECRET_KEY_BASE`)を書き込みます。

   ```bash
   cp .env.example .env
   sed -i "s/^#\? *SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$(openssl rand -hex 64)/" .env
   ```

3. 起動します。初回はイメージのビルド(gem のコンパイルを含む)に 10〜15 分ほどかかります。

   ```bash
   docker compose up --build
   ```

4. ブラウザで <http://localhost:3000> を開き、「新規登録」からユーザーを登録します。
5. 確認メールは Mailpit(<http://localhost:8025>)に届きます。メールのリンクを開くと、ログインできるようになります。

止めるときは `Ctrl+C` を押すか、別の端末で `docker compose down` を実行します。登録したデータも消すときは `docker compose down -v` を実行します。

## 設定(環境変数)

設定は環境変数で渡します。ローカル実行と開発では `.env`(見本は [`.env.example`](.env.example))に書きます。`.env` は Git の管理対象外です。

| 名前 | 用途 | 必須 | 既定値 |
|---|---|---|---|
| `DATABASE_PASSWORD` | MySQL のパスワード | **必須** | なし |
| `DATABASE_HOST` | MySQL のホスト | 任意 | `127.0.0.1` |
| `DATABASE_PORT` | MySQL のポート。`compose.dev.yml` では DB を公開するポートにもなる | 任意 | `3306` |
| `DATABASE_USERNAME` | MySQL のユーザー | 任意 | 開発・テストは `root`、本番は `ruby_todo_app` |
| `DATABASE_URL` | 接続情報をまとめて指定する(Rails の標準機能)。指定すると上の値より優先される | 任意 | なし |
| `SECRET_KEY_BASE` | Cookie などの署名に使う鍵 | **本番では必須** | なし |
| `RAILS_MASTER_KEY` | `config/credentials.yml.enc` の復号鍵。今の構成では使っていない | 任意 | なし |
| `RAILS_FORCE_SSL` | 本番で HTTPS を強制するか(`true` / `false`) | 任意 | `true` |
| `APP_HOST` | メールに載せるリンクのホスト名(本番) | 本番では必須 | `localhost` |
| `APP_PORT` | メールに載せるリンクのポート(本番) | 任意 | なし |
| `SMTP_ADDRESS` | メールを送る SMTP サーバー(本番)。未設定なら `localhost:25` に送る | 本番でメールを送るなら必須 | なし |
| `SMTP_PORT` | SMTP サーバーのポート | 任意 | `587` |
| `SMTP_USERNAME`・`SMTP_PASSWORD` | SMTP の認証情報 | 任意 | なし |
| `RAILS_LOG_LEVEL` | 本番のログレベル | 任意 | `info` |
| `RAILS_MAX_THREADS` | Puma のスレッド数と DB の接続数 | 任意 | `5` |
| `WEB_CONCURRENCY` | 本番の Puma のワーカー数(`0` ならワーカーを使わない) | 任意 | CPU の物理コア数 |
| `PORT` | Puma が待ち受けるポート | 任意 | `3000` |
| `DEV_UID`・`DEV_GID` | コンテナで開発する場合の、コンテナのユーザーの UID・GID([開発ガイド](docs/development.md#ruby-を入れずにコンテナで開発する)) | 任意 | `1000` |

`compose.yml` はコンテナの中の接続先(`DATABASE_HOST=db` など)を自分で設定するので、`.env` には `DATABASE_PASSWORD` と `SECRET_KEY_BASE` があれば動きます。

環境変数のほかに、次の設定ファイルがあります。

| ファイル | 内容 |
|---|---|
| `config/database.yml` | DB の接続設定(上の環境変数を読む) |
| `config/environments/*.rb` | 環境(development / test / production)ごとの Rails の設定 |
| `config/puma.rb` | Web サーバー(Puma)の設定 |

## リリース(本番用イメージの作り方)

本番では、`Dockerfile` から作ったイメージを動かします。このイメージは次のようになっています。

- アセットはビルドの時点でプリコンパイルされる
- アプリは root ではない `rails` ユーザーで動く
- 起動時に `bin/docker-entrypoint` が `bin/rails db:prepare` を実行し、DB の作成・マイグレーションを行う
- ログは標準出力に出る

手順は次のとおりです。

1. リリースするコミットにタグを付けます(例:`git tag v1.0.0`)。
2. そのタグでイメージを作ります。

   ```bash
   docker build -t ruby-todo-app:v1.0.0 .
   ```

3. 本番用の環境変数を渡して起動します。少なくとも `DATABASE_HOST`・`DATABASE_PASSWORD`・`SECRET_KEY_BASE`・`APP_HOST`・`SMTP_ADDRESS` を設定します([設定(環境変数)](#設定環境変数)を参照)。

   ```bash
   docker run -d -p 3000:3000 --env-file production.env ruby-todo-app:v1.0.0
   ```

   `production.env` は本番用の環境変数を書いたファイルです(`.env` と同じく Git に入れないこと)。

本番では HTTPS が強制されます(`RAILS_FORCE_SSL` の既定値が `true`)。TLS はロードバランサーなどで終端し、アプリには `X-Forwarded-Proto` ヘッダー付きで転送してください。
`compose.yml` は、このイメージをローカルで試すための構成です(HTTPS の強制を切り、DB とメールも一緒に起動します)。

## 開発する

ソースを編集しながら開発するための手順は、[開発ガイド(docs/development.md)](docs/development.md) にまとめています。

- [開発環境の構築](docs/development.md#開発環境の構築):rbenv で Ruby 3.1.2 を入れて Rails を動かし、MySQL は `compose.dev.yml` で起動する
- [テスト](docs/development.md#テスト):`bin/rails test`
- [Lint・フォーマット](docs/development.md#lintフォーマットrubocop):`bundle exec rubocop`
- [よく使うコマンド](docs/development.md#よく使うコマンド)、[DB の作り直し](docs/development.md#db-を作り直す)、[gem の追加](docs/development.md#gem-を追加更新する)
- [Ruby を入れずにコンテナで開発する方法](docs/development.md#ruby-を入れずにコンテナで開発する)

## トラブルシューティング

開発のときに起きる問題は、[開発ガイドのトラブルシューティング](docs/development.md#トラブルシューティング)を参照してください。

**`.env に DATABASE_PASSWORD を設定してください` などと表示されて起動しない**
`.env` がないか、必要な値が入っていません。[アプリを動かす](#アプリを動かすローカル実行)の手順 2 を実行してください。

**`port is already allocated` と表示される**
3000 番(アプリ)か 8025 番(Mailpit)を、ほかのプログラムが使っています。開発用のサーバー(`bin/rails server`)などを止めてから起動してください。

**`.env` の `DATABASE_PASSWORD` を変えたら DB に接続できなくなった**
MySQL のパスワードは、DB のデータを最初に作ったときにだけ設定されます。`docker compose down -v` でデータを消してから起動し直してください。

**コンテナが `bin/docker-entrypoint: not found` や `$'\r': command not found` で止まる**
シェルスクリプトの改行コードが CRLF になっています。Windows 側で clone したか、`.gitattributes` の設定が入る前に clone した可能性があります。WSL の中で clone し直してください。

**WSL で `docker` コマンドが見つからない**
Docker Desktop の Settings → Resources → WSL integration で、使っているディストリビューションを有効にしてください。

**イメージの取得が `EOF` で失敗する**
Docker Hub との通信が一時的に切れています。同じコマンドをもう一度実行してください。

## 既知の制限

- Ruby 3.1 とベースイメージの Debian 11(bullseye)は、どちらもサポートが終わっています。Debian 11 のセキュリティ更新のリポジトリから一部のパッケージを取得できなくなったため、`Dockerfile`・`Dockerfile.dev` では apt の取得先から外しています。根本的な対応は Ruby を上げてベースイメージを新しくすることです(未対応)。
