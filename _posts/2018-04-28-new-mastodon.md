---
layout: post
title: サーバの引越し
date: '2018-04-28T11:18:15+09:00'
categories:
- Mastodon
- blog設定
---

サーバ引越し作業の記録。`skoji.jp`および、`sandbox.skoji.jp`を新たなサーバに引越した。ただ引っ越すだけでなく、次の変更を行った。

* CentOS7からUbuntu 18.04 LTSに変更
* MastodonをDockerで動かさない

## 0. さくらのVPSにUbuntu 16.04 LTSをインストール

## 1. sshポート変更・ファイアウォールの設定変更

```
sudo vi /etc/ssh/sshd_config
sudo systemctl restart ssh
sudo rm /etc/iptables/iptables.rules
sudo ufw enable
sudo ufw allow <ssh port>
sudo ufw allow 80
sudo ufw allow 443
sudo ufw default deny
```

## 2. 18.04 LTSにアップグレード
```
# update 16.04 LTS
sudo apt update && sudo apt dist-upgrade && sudo apt autoremove
# check LTS version is selected
sudo vi /etc/update-manager/release-upgrades
# do update
sudo do-release-upgrade -d
```
## 3. nginxインストール
* Ubuntu 17.10用をインストール

## 4. IPv6有効化

さくらのVPSはIPv6はデフォルトではオフになっているので有効にする。

## 4. nginx設定などのコピー

旧マシンからnginx設定や、`/usr/shar/nginx/html`以下の静的なコンテンツをコピーする。Let's encryptは再設定する。

## 5. Mastodon設置

[最新の設置ガイド](https://github.com/tootsuite/documentation/blob/d9ea83d90826d09ea1061369782489f6fd36c1a3/Running-Mastodon/Production-guide.md)に基づいて設置する。Nginxの設定、DBの初期化、Adminの作成などはスキップする。また、この時点ではまだ起動しない。

この時、ubuntu 18.04 LTSでは次のことに留意する。

* `libgdbm3`ではなく`libgdbm5`を入れる
* nodejsのrepository設定には`setup_6.x`ではなく`setup_8.x`を使う

## 6. 旧サーバからのDBコピー

旧サーバでDBのバックアップを取る。

```
docker-compose stop web streaming sidekiq redis
docker exec mastodon_db_1 pg_dumpall -U postgres > ./backup.sql
```

`backup.sql`を新サーバに`scp`などでコピーした上でレストアする。
```
psql -U postgres -f backup.sql
```

redisは、旧サーバの`<mastodonのディレクトリ>/redis/dump.rdb`を新サーバの`/var/lib/redis/`にコピーする

## 7. 旧サーバのmedia fileコピー

`<mastodonのディレクトリ>/public/system/`以下を新サーバ同じ場所にscpなどでコピーする。

## 8. Mastodonのサービスを起動する

これで動くはず。
