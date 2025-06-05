---
layout: post
title: GoAccessを導入した
date: '2025-06-05T21:25:59+09:00'
categories:
 - blog設定
---

ずいぶん前にGoogle Analyticsははずしてしまった。でもアクセス解析は何かほしいあなと思っていて、[GoAccess](https://goaccess.io)を導入した。
色々試行錯誤したが、結論だけ自分の記録のために残しておく。なお、ダッシュボードはbasic認証だけかけているが、パスは以下では隠している。

### GoAccessのインストール

aptでのインストールを行う。[公式の手順](https://goaccess.io/download#distro)に従った。

### nginxのログ

JSONフォーマットとして記録するようにした（これはやらなくてもよかったかもしれない）

```
log_format  main_json  escape=json
'{'
  '"ts":"$time_iso8601",'
  '"ip":"$remote_addr",'
  '"xff":"$http_x_forwarded_for",'
  '"host":"$host",'
  '"method":"$request_method",'
  '"uri":"$request_uri",'
  '"status":$status,'
  '"bytes":$body_bytes_sent,'
  '"referer":"$http_referer",'
  '"ua":"$http_user_agent",'
  '"req_time":$request_time'
'}';

access_log  /var/log/nginx/access.json  main_json;
```

### 過去のデフォルトフォーマットのログをgoaccessのDBに保存

```
$ sudo mkdir /var/lib/goaccess
$ sudo zcat -f /var/log/nginx/access.log*.gz /var/log/nginx/access.log | sudo goaccess --log-format=COMBINED --date-format=%d/%b/%Y --time-format=%T --db-path=/var/lib/goaccess --persist
$ sudo chown -R nginx /var/lib/goaccess/*
```

### systemdでの起動設定

以下を`/etc/systemd/system/goaccess.service`として記述した。

```
Unit]
Description=GoAccess real-time analytics (JSON nginx logs)
After=network.target nginx.service

[Service]
User=nginx
Group=nginx

ExecStart=/usr/bin/goaccess \
  /var/log/nginx/access.json \
  --config-file=/etc/goaccess/goaccess.conf \
  --db-path=/var/lib/goaccess \
  --restore \
  --real-time-html \
  --port=7890 \
  --addr=127.0.0.1 \
  --ws-auth=jwt \
  --ws-auth-expire=24h \
  --origin=https://skoji.jp \
  --ws-url=wss://skoji.jp:443/<path_to_analytics>/ws
  --output=<path to output>

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### nginx設定

htpasswdでBASIC認証用パスワードを`/etc/ngix/.htpasswd`として生成した上で、以下をnginx設定に追加した。

```
location <path to analytics> {
    index  index.html;
    auth_basic           "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
}

location <path to analytics>/ws {
    proxy_pass         http://127.0.0.1:7890;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection "upgrade";
    proxy_set_header   Host $host;
    proxy_set_header   Origin $http_origin;

}
```

### log rotation時の対応

以下を`/etc/logrotate.d/nginx`に追加

```
        postrotate
        # ... 他の処理
                systemctl kill -s USR1 goaccess.service
        endscript
```

また、ブロックの先頭に/var/log/nginx/*.jsonも追加しておく。

```
/var/log/nginx/*.log /var/log/nginx/*.json {
        daily
        ...
```

### 苦労したポイント

WebSocketが全然動かなかった。よく見ると7890にアクセスにいっていた。
