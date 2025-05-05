---
layout: post
title: Decap CMSを入れた
date: '2025-05-05T19:05:41+09:00'
categories:
- blog設定
---

このブログをJekyllにして以来、更新には原則としてmacが必須だった。GitHubのWeb UIを使えばWebからの更新もできなくはないが、あまり現実的ではない。
思い立って、[Decap CMS](https://decapcms.org)を設定してみた。思ったよりもめんどうくさかったが、なんとかなった。記録しておく。

## 管理画面と設定の設置

このブログのルートに`admin`ディレクトリを作り、そこに`index.html`ファイルを入れる。内容は以下の通り。

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Content Manager</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/hithismani/responsive-decap@main/dist/responsive.css"> <!-- Unminfied -->    
  </head>
  <body>
    <!-- Include the script that builds the page and powers Decap CMS -->
    <script src="https://unpkg.com/decap-cms@^3.0.0/dist/decap-cms.js"></script>
  </body>
</html>
```

設定ファイルconfig.ymlも入れる。試行錯誤したが、最終的に以下のようになった。

```yaml
backend:
  name: github
  repo: skoji/skoji.jp-source
  branch: main
  base_url: https://decap-auth.skoji.jp
media_folder: 'images'
public_folder: '/blog/images/'
editor:
  preview: false
collections:
  - name: 'blog'
    label: 'Blog'
    create: true
    slug: '{{year}}-{{month}}-{{day}}-{{slug}}'
    folder: '_posts/'
    fields:
      - { label: 'Title', name: 'title', widget: 'string' }
      - { label: 'Publish Date', name: 'date', picker_utc: false, format: "YYYY-MM-DDTHH:mm:ssZ", widget: 'datetime' }
      - label: 'Categories'
        name: 'categories'
        widget: 'select'
        multiple: true
        options: [ "日常", "クルマ・バイク", "買い物", "computer/gadgets", "料理", "音楽",  "お酒", "本", "blog設定", "ソフトウェア", "ネタ", "写真", "映画", "このブログについて", "その他", ".NET Framework", "Ruby", "R", "ソフトウェア開発", "休むに似たり",  "Lua",  "atom",  "未分類",  "イベント",  "LowLevel",  "Factor",  "プログラミング言語",  "開発環境",  "Lisp系",  "電子書籍",  "gepub",  "電書",  "11日",  "webapp",  "目標",  "Rust",  "Mastodon",  "猫",  "ひとりアドベントカレンダー",  "英語の表現",  "個人事業主",  "font",  "日記",  "MikanOS",  "blender"]
      - { label: 'Body', name: 'body', widget: 'markdown' }
```

カテゴリに関しては追加したらここも更新しなくてはならないが、これ以上は当面追加しないだろう。

## OAuth関連

このブログのソースを置いているGitHub repoへの書き込みが必要になるので、OAuth関連の設定をする。

上記のconfigに、`https://decap-auth.skoji.jp`というのが出てくるが、これはOAuth Clientである。
Decap CMSは元々Netlify CMSで、NetlifyをOAuth Clientとして使うのが前提になっている。このブログは一瞬Netlifyにホストしていたこともあるが、今は自前ホストだ。Netlifyを使わなくて済むよう、OAuth Clientを設置する。

Decapのドキュメントに、[External OAuth Clientsのリスト](https://decapcms.org/docs/external-oauth-clients/)がある。今回はこの中から、Go製の[decapcms-oauth2](https://github.com/alukovenko/decapcms-oauth2)を使った。

### decapcms-oauth2の設定とビルド

まず、実行用ユーザを作成する。

```
sudo adduser --system --group --home /opt/decapcms-oauth2 decap
sudo mkdir -p /opt/decapcms-oauth2
sudo chown decap:decap /opt/decapcms-oauth2
```

それから、バイナリをビルドする。

```
git clone https://github.com/alukovenko/decapcms-oauth2.git
cd decapcms-oauth2
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o decapcms-oauth2
sudo mv decapcms-oauth2 /opt/decapcms-oauth2/
```

環境設定ファイル`/etc/decapcms-oauth2.env`を作る。

```
OAUTH_CLIENT_ID=xxxxxxxxxxx
OAUTH_CLIENT_SECRET=xxxxxxxxx
SERVER_HOST=127.0.0.1
SERVER_PORT=9000
TRUSTED_ORIGIN=https://skoji.jp
```

### systemdに登録

`/etc/systemd/system/decapcms-oauth2.service`を作成する。

```
[Unit]
Description=GitHub OAuth2 backend for Decap CMS
After=network-online.target
Wants=network-online.target
ConditionPathExists=/opt/decapcms-oauth2/decapcms-oauth2

[Service]
User=decap
Group=decap
EnvironmentFile=/etc/decapcms-oauth2.env
WorkingDirectory=/opt/decapcms-oauth2
ExecStart=/opt/decapcms-oauth2/decapcms-oauth2
Restart=on-failure
RestartSec=5s
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=yes
CapabilityBoundingSet=
AmbientCapabilities=

[Install]
WantedBy=multi-user.target
```

有効化し、起動する。

```
sudo systemctl daemon-reload
sudo systemctl enable --now decapcms-oauth2
```

### nginx設定

Let's Encryptの証明書を取得する。

```
sudo certbot certonly --nginx -d decap-auth.skoji.jp
```

nginx configを書く。

```
server {
    if ($host = decap-auth.skoji.jp) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name decap-auth.skoji.jp;
    return 301 https://$server_name$request_uri;


}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name decap-auth.skoji.jp;

    ssl_certificate /etc/letsencrypt/live/decap-auth.skoji.jp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/decap-auth.skoji.jp/privkey.pem;

    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass         http://127.0.0.1:9000;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto https;
    }

     location ~ ^/\.well-known/acme-challenge/ {
        root /var/www/html;
    }

    access_log /var/log/nginx/decapcms-oauth2.access.log;
    error_log  /var/log/nginx/decapcms-oauth2.error.log;
}
```

configのチェックとnginx再起動

```
sudo nginx -t && sudo systemctl reload nginx
```
