---
layout: post
title: Mastodon引越し作業2023
date: '2023-01-13T11:59:14+09:00'
categories:
- Mastodon
---

skoji.jpドメインのサーバのOSを、Ubuntu 18.04からクリーンインストールでUbuntu 22.04にした。引越しではなくバージョンアップだけれども、作業自体はほぼ引越しだ。自分のための記録として書きのこしておく。長いです。

## バックアップの前に、メディアのS3切り替え

Mastodonでは設定ファイルとDBとメディアのバックアップがあれば良い。このうち、メディアはシングルユーザサーバでもそれなりのサイズで面倒なので、先にAWS S3へ切り替えた。

* S3では仮想ホスト形式が推奨。仮想ホスト形式の場合bucket名にドットを入れるとAWS側のワイルドカード証明書とマッチしなくてhttpsできなくなるので注意
* 使い回してるMastodonの設定ファイルだと`S3_CLOUDFRONT_HOST`ってなってるところはそのままでも動くけど、いまは`S3_ALIAS_HOST`のほうが正式

### Bucket作成・設定

* IAMユーザ作成

  * AmazonS3FullAccess権限をもつグループを作成し、そこにIAMユーザを所属させる。
IAMユーザのアクセスキーIDとシークレットアクセスキーを控える。

* Bucket作成・設定
  * 作成する
  * 「アクセス許可」を開く
  * 「パブリックアクセスをすべてブロック」をオフにする
  * バケットポリシーをジェネレータでつくって設定する
    * Select Type of Policy: 「S3 Backet Policy」
    * Effect: 「Allow」
    * Principal: 「*」
    * AWS Service: 「Amazon S3」
    * Actions: 「GetObject」のみ選択
    * Amazon Resource Name(ARN): 「arn:aws:s3:::バケット名/*」
  * 「オブジェクト所有者」で「ACL有効」に設定し、「希望するバケット所有者」をチェックする

### Mastodon S3設定

#### .env.profile

```
S3_ENABLED=true
S3_BUCKET=<bucket name>
AWS_ACCESS_KEY_ID=<access key id>
AWS_SECRET_ACCESS_KEY=<secret access key>
S3_REGION=ap-northeast-1 # 東京リージョンの場合
# S3_PROTOCOL=https
# S3_ALIAS_HOST=images.sandbox.skoji.jp # ここはあとでproxy cacheを設定してから有効にする
```
変更した上でMastodonプロセスを再起動。

#### ローカルからコピー

* aws cliをインストール
* `aws configure`でACCESS KEY ID, SECRET ACCESS KEYを設定する
* `aws s3 sync public/system s3://<bucket name>`

#### pxoxy cache設定

`/etc/nginx/nginx.conf`の`http`セクションに以下を追加する。

```
proxy_cache_path /var/cache/nginx/proxy_cache_images levels=1:2 keys_zone=images:2m max_size=1g inactive=7d;
```

`/etc/nginx/conf.d/image-cache.conf`として以下を追加。(Lets Encrypt設定などもしたけど割愛）

```
server {
    server_name images.sandbox.skoji.jp;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    # <... SSL証明書関連省略 ...>

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
    proxy_pass https://<bucket name>.s3.ap-northeast-1.amazonaws.com$request_uri; 
    expires max;
  }
}

# httpからのリダイレクトまわりも省略
```

## バックアップ

以下をバックアップした。Mastodonに関係ないものも含まれている。

* postgres : `pg_dumpall`の結果
* `/var/lib/redis/dump.rdb`
* `.env.production`
* `/etc/letsencrypt`以下ぜんぶ
* `/etc/nginx/`以下ぜんぶ
* `/usr/share/nginx/html`以下ぜんぶ
* 自分のホームディレクトリ

## 新サーバ設置

### OS関連

* OSインストール
* IPv6有効化（さくらのVPSではデフォルト無効なので）
* ufw設定
* ssh設定: identity onlyにしてport変更
* mackerel-agentインストール
* nginxインストール
* snapdインストール、snapでcertbotインストール
* `/etc/letsencrypt`, `/etc/nginx`、`/usr/share/nginx/html`リストア
* 自分のホームディレクトリの必要部分リストア

### Mastodon

基本的には公式手順どおり。ただし以下が異なる。

* certbotはsnapでいれているのでapt版は入れない。
* DBは`psql -f <バックアップファイル>`で書き戻すのでユーザー作成などはやらない
* redisのdump.rdbもどす 
* もともと設定されているDB Userが`mastodon`ではなく`postgres`なので、`pg_hba.conf`を編集してpeerをmd5にする
* Ubuntu 22.04ではホームディレクトリのpermissionが750なので、`sudo chmod 755 /home/mastodon`する
* `rake mastodon:setup`はやらない。git clone後に`.env.production`を戻したら、`yarn install && bundle install && bundle exec rake assets:precompile`する。

### 定期実行ジョブ

systemd timerで、`media remove-orphans`や`media remove`をやるようにした（詳細は後日）。`media remove`は今は管理者のWebUIからできるので不要だけど、ログを手軽に確認できるのがよいので設定した。remove-orphansは週次、removeは日次で実行させている。





