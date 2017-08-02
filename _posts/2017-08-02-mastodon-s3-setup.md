---
layout: post
title: Mastodon S3設定 / proxy cache設定
date: '2017-08-02T09:58:31+09:00'
categories:
- Mastodon
---

[bookwor.ms](https://bookwor.ms)の画像サーバをさくらのオブジェクトストレージからAWS S3に引っ越した。
さらに、S3へのアクセスをキャッシュするように設定した。S3へはパブリックからリードアクセスできるようにしている。

## S3への引っ越し

### さくらのオブジェクトストレージからのコピー

`s3cmd`を使った。前提として、さくらむけの設定を`.s3cfg-sakura`に、AWS向けの設定を`.s3cfg`（デフォルト）に設定している。
さくらのオブジェクトストレージからローカルに同期する。

```
s3cmd sync --signature-v2 s3://<さくらのバケット名>/ s3-backup/ -c ~/.s3cfg-sakura
```

ローカルに同期した内容を、AWS S3に同期する。

```
s3cmd sync s3-backup/ s3://<AWSのバケット名>/ 
```

`.env.production`のS3設定を編集し、AWSの設定に変更する。ここでいったんMastodonを停止し、再度同期する。
Mastodonを起動する。

## proxyの設定

`https://images.bookwor.ms/`をproxy cacheにしている。

### SSL証明書

まず、HTTPアクセスの設定で`/etc/nginx/conf.d/image-cache.conf`を書いておく。
ここで`server: images.bookwor.ms;`を指定しておく。

`sudo certbot --nginx`で、`images.bookwor.ms`を追加する。

### nginx.confの設定

次の設定を追加する。

```
proxy_cache_path /var/cache/nginx/proxy_cache_images levels=1:2 keys_zone=images:2m max_size=1g inactive=7d; 
```

### image-cache.confの設定

次のように設定した。

```
server {
  server_name images.bookwor.ms;

  listen 443 ssl http2; 
  listen [::]:443 ssl http2;
  
  ssl_certificate /etc/letsencrypt/live/images.bookwor.ms/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/images.bookwor.ms/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot

  ssl_session_cache shared:SSL:10m;

  root /usr/share/nginx/html;

  add_header Strict-Transport-Security "max-age=31536000";
  add_header Content-Security-Policy "style-src 'self' 'unsafe-inline'; script-src 'self'; object-src 'self'; img-src data: https:; media-src data: https:; upgrade-insecure-requests";

  location / {
    limit_except GET {
      deny all;
    } 
    proxy_ignore_headers set-cookie;
    proxy_hide_header set-cookie;
    proxy_set_header cookie "";

    proxy_hide_header x-amz-delete-marker;
    proxy_hide_header x-amz-id-2;
    proxy_hide_header x-amz-request-id;
    proxy_hide_header x-amz-version-id;

    proxy_hide_header etag;

    proxy_cache images;
    proxy_cache_valid 200 28d;
    proxy_intercept_errors on;

    resolver 8.8.8.8 valid=100s;
    proxy_pass https://s3-ap-northeast-1.amazonaws.com/<bucket_name>$request_uri;

    expires max;

  }
```

## Mastodon側での設定

`S3_CLOUDFRONT_HOST`にproxy cacheのサーバ名を記述して、Mastodonサービスを再起動する。

```
S3_CLOUDFRONT_HOST=images.bookwor.ms
```
