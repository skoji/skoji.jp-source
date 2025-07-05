---
layout: post
title: Mastodonサーバアップデート2025
date: '2025-07-05T09:24:04+09:00'
categories:
 - Mastodon
 - blog設定
---

Mastodonひとりサーバ [sandbox.skoji.jp](https://sandbox.skoji.jp) とかこのブログとか設置しているサーバのOSを、Ubuntu 22.04から24.04にアップデートする作業を行なった。Ubuntuのdo-release-upgradeはトラブった経験がむかーしあり、これまで避けていたんだけど、今回は使ってみた。

### バックアップ

MastodonのDB、`/var/www/html`、`/etc/systemd/system/`、`/etc/nginx/`のconf、などをバックアップ。（なんかたりてない気もする）

### do-release-upgrade

さくらのVPS管理画面の、シリアルコンソールからdo-release-upgrade実施。設定ファイルの上書きは基本的にやらない（cronだけは確認の上やった）

### PostgreSQLのアップデート

これはOSバージョンアップ前にやっとくべきだった。

```sh
$ sudo systemctl stop mastodon-sidekiq.service mastodon-streaming.service mastodon-web.service # Mastodon止める
$ sudo pg_lsclusters # クラスタ確認, 15を使っている
$ sudo pg_upgradecluster 15 main # 15から、インストールされてる最新の17にアップグレード
$ sudo pg_lsclusters # クラスタ確認
$ sudo systemctl start mastodon-sidekiq.service mastodon-streaming.service mastodon-web.service # Mastodon開始
```

この後`pg_dropcluster`も実行

### libvips

MastodonはImageMagickからlibvips利用へ移行中。せっかく24.04にしたのでやっておく。

```
$ sudo apt install libvips-tools
```

* mastodonの`.env.production`に`MASTODON_USE_LIBVIPS=true`を追加
* マストドンrestart

### サードパーティapt repositoryの再有効化

使っていないものもあったが、mackerel・PostgreSQL・nginxのrpositoryを再有効化。`/etc/apt/sources.list.d/*`の書き換えではなく、再度設定手順を踏んだ。

