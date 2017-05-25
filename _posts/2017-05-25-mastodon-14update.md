---
layout: post
title: Mastodonを1.4rc3にアップデートした
date: '2017-05-25T23:19:44+09:00'
categories:
- Mastodon
---

Mastodonの自分専用インスタンスを、1.4rc3にアップデートした。release candidateといいつつ、

>  which fixes some but not all bugs (yet)

なんて[書いていて](https://mastodon.social/users/Gargron/updates/2452607)すこしばかり不安である。

これがなぜか私の環境ではうまくアップデートできない。railsの`assets:precompile`が必ず失敗する。多くの環境ではちゃんと動作しているようだ。Docker環境なのでどこで実行しても基本的に同じはずなのに。Dockerのimageをまっさらにするなどいろいろやってみたが、うまくいかない。結局。[yarnのバージョンをさげる](https://github.com/tootsuite/mastodon/issues/3251#issuecomment-303361503)ことで不思議なことに動作している。この件は未解決だが、 なんとかわたしのインスタンスは[1.4rc3(1.4.0.3)になった](https://sandbox.skoji.jp/about/more)。

1.4からは、Dockerでの実行ユーザがrootではなくなり、デフォルトではUID991のユーザになっている。このため、多少手順が変わる部分がある。アップデートの手順を以下に書いておく。

#### 1. バックアップをとる

`public/system`以下、postgresとredisのデータをなんらかの手段でコピーする。

#### 2. ソースツリーを1.4rc3にアップデートする。

```
$ git stash # docker-compose.ymlの退避
$ git pull
$ git checkout v1.4rc3
$ git stash pop # docker-compose.ymlの復帰。私の環境ではそのままでOK。
```

#### 3. Docker内実行用Mastodonユーザの準備

私のサーバでは、UID911はすでに使われていた。すでに作成したmastodonユーザのUID（ここでは1000とする）をDockerfileに反映する。

```diff
--- a/Dockerfile
+++ b/Dockerfile
@@ -3,7 +3,7 @@ FROM ruby:2.4.1-alpine
 LABEL maintainer="https://github.com/tootsuite/mastodon" \
       description="A GNU Social-compatible microblogging server"
 
-ENV UID=991 GID=991 \
+ENV UID=1000 GID=1000 \
     RAILS_SERVE_STATIC_FILES=true \
     RAILS_ENV=production NODE_ENV=production
```

#### 4. 環境依存の問題への対処

[上記の問題](https://github.com/tootsuite/mastodon/issues/3251)への対処として、yarnのバージョンを指定する。

```diff
--- a/Dockerfile
+++ b/Dockerfile
@@ -34,7 +34,7 @@ RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/reposit
     protobuf \
     su-exec \
     tini \
- && npm install -g npm@3 && npm install -g yarn \
+ && npm install -g npm@3 && npm install -g yarn@0.18.2 \
  && update-ca-certificates \
  && rm -rf /tmp/* /var/cache/apk/*
```

#### 5. 既存のディレクトリ Ownerを変更する

このステップは不要かもしれない。
(docker_entrypoint.shでもowner変更はやっているため)

```
$ sudo chorn -R mastodon:mastodon public/system
```

#### 6. Dockerコンテナの再ビルドと生成

```
$ /usr/local/bin/docker-compose pull
$ /usr/local/bin/docker-compose build
$ /usr/local/bin/docker-compose run --rm web rails assets:precompile
$ /usr/local/bin/docker-compose stop && /usr/local/bin/docker-compose up -d
```


