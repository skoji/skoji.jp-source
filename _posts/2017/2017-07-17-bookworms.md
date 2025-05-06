---
layout: post
title: Mastodon Dockerなし + さくらのオブジェクトストレージを設置した
date: '2017-07-17T10:17:16+09:00'
categories:
- Mastodon
---

いままで遊んでいた一人インスタンス[sandbox.skoji.jp](https://sandbox.skoji.jp)に加えて、[Bookwor.ms](https://bookwor.ms)という登録オープンなインスタンスを立ち上げた。今さら。

人数が多少増えても耐えられるように、今回は次の方針を決めた。

* Dockerなし
* メディアファイルはさくらのオブジェクトストレージ

はまりどころはなかったけれども、わりとめんどくさかったので、メモとして残しておく。

（2017-09-21追記：現時点ではさくらのオブジェクトストレージはおすすめしません。S3を使うほうが無難です。S3への引っ越しは[こちら](https://skoji.jp/blog/2017/08/mastodon-s3-setup.html)に書きました）

## Ubuntu Server設置

さくらのクラウド上にUbuntu Server 16.04.2 LTSを設置した。シンプルモードで、基本的な設定はさくら任せ。

## Mastodon実行ユーザ追加

Mastodonのドキュメント通り。普通にログインできないユーザとして追加する。

```
sudo useradd --system --user-group --shell /bin/false \ 
     --create-home --home /home/mastodon mstdn
```

## ssh port変更

SSHのportをデフォルトから変更しておく。

```
vi /etc/ssh/sshd_config 
sudo service ssh restart
```

## Firewall設定

SSH/HTTPSをあけておく。

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow <ssh port>
sudo ufw allow 443
sudo ufw allow 80
sudo ufw enable
```

## Nginx設置

[公式の設置ドキュメント](https://nginx.org/en/linux_packages.html)を参照した。

```
curl -sS https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
echo 'deb http://nginx.org/packages/ubuntu/ xenial nginx' | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt-get update
sudo apt-get install nginx
# vi /etc/nginx/conf.d/default.conf でserverのFQDNを設定しておく : certbotのため
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Let's Encrypt証明書

[公式のドキュメント](https://certbot.eff.org/#ubuntuxenial-nginx)どおりに設置。

```
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx 
sudo certbot --nginx
```

Ubuntuの場合はこれだけで`systemd`の`timer`が設定されていて、自動更新も安心。

## rbenv + ruby-build設置

```
sudo -sHu mstdn # Mastodon実行ユーザになっておく
# ruby-buildの依存関係
sudo add-apt-repository ppa:ubuntu-toolchain-r/tes
sudo apt-get update
sudo apt-get install gcc-6 autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
 # rbenv設置
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/shims:$PATH"' >> ~/.bashrc
 # ruby-build設置
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
 # ruby 2.4.1 インストール
rbenv install 2.4.1
rbenv global 2.4.1
```

## Postfix設置

メール送信はLocalのpostfixで実行する。

```
sudo apt-get install postfix
sudo systemctl start postfix
```

## ようやくMastodon本体設置

基本的には[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)を参照した。

### Nginx設定

公式のnginx設定例をほぼ踏襲する。`server_name`を`bookwor.ms`に設定するほか、SSL関係とログのみ変更する。

#### SSL

上記の`certbot`が`/etc/nginx/conf.d/default.conf`にSSL設定を書き込んでいる。このうち、以下の部分を`/etc/nginx/conf.d/mastodon.conf`の`server`内に移動させる。重複する設定は削除する。(`nginx -t`で確認できる）

```
ssl_certificate /etc/letsencrypt/live/bookwor.ms/fullchain.pem; # managed by Certbot
ssl_certificate_key /etc/letsencrypt/live/bookwor.ms/privkey.pem; # managed by Certbot
include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
``` 

#### ログ

ログを設定する。

```
access_log   /var/log/nginx/mastodon-access.log;
error_log   /var/log/nginx/mastodon-error.log;
```

### 依存ライブラリ設定

[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#general-dependencies)どおり。

### Redis

[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#redis)どおり。

### Postgres

[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#postgres)どおり。ただし、[Ubuntu 16.04](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#ubuntu-1604)に関する部分がうまく動作しなかった。IPv6が有効になっているためで、`/etc/postgresql/9.5/main/pg_hba.conf`に以下を追加した。

```
host    all             all             ::1/128           ident 
```

### Mastodon本体のコピーとbundle/yarnなど

[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#git)どおり。

### Mastodon設定

`.env.production`を以下のように設定する。

#### 基本

```
REDIS_HOST=localhost
DB_HOST=localhost
LOCAL_DOMAIN=bookwor.ms
PAPERCLIP_SECRET=<rake secretの値>
SECRET_KEY_BAE=<rake secretの値>
OTP_SECRET=<rake secretの値>
```

#### SMTP

ローカルのpostfixで、認証などはない。

```
SMTP_SERVER=localhost
SMTP_PORT=25
#SMTP_LOGIN=
#SMTP_PASSWORD=
SMTP_FROM_ADDRESS=admin@bookwor.ms
SMTP_AUTH_METHOD=none
SMTP_OPENSSL_VERIFY_MODE=none
```

#### メディアアップロード先
（2017-09-21追記：現時点ではさくらのオブジェクトストレージはおすすめしません。S3を使うのが無難です。S3への引っ越し・設定については[こちら](https://skoji.jp/blog/2017/08/mastodon-s3-setup.html)に書きました）

今回はS3互換のさくらのオブジェクトストレージにした。Mastodonでの使用例は[fnyaさんの記事](http://fnya.cocolog-nifty.com/blog/2017/04/mastodonvps-da0.html)があったおかげではまらずに済んだ。ありがとうございます。

```
S3_ENABLED=true
S3_BUCKET=skoji-mastos # バケット名
AWS_ACCESS_KEY_ID=<key id>
AWS_SECRET_ACCESS_KEY=<secret access key>
S3_REGION=tokyo # なんでもよい
S3_PROTOCOL=https
S3_HOSTNAME=b.sakurastorage.jp
S3_ENDPOINT=https://b.sakurastorage.jp
S3_SIGNATURE_VERSION=s3
```

Mastodon v1.4.7では、fnyaさんの記事のようにソースコードに手をいれなくても動作した。

### DBとassetのセットアップ

[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#setup)通り。

### Systemdへの登録

これも[公式ドキュメント](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md#systemd)通り。


