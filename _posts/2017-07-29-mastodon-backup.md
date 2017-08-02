---
layout: post
title: 'Mastodon: Postgresqlのバックアップ'
date: '2017-07-29T12:03:42+09:00'
categories:
- Mastodon
---

ありがたいことに[本の虫](https://bookwor.ms)使っていただいている。ひとさまに使っていただいているからには、ちゃんとバックアップが必要だ。手動でDBバックアップはとっていたのだけれども、それだと不安もあるので自動化した。バックアップは14日分を同一マシン上に置いておく。さらにS3にもコピーしておく。S3側のコピーはS3の機能で2ヶ月程度で消す設定にしている。

## WALのアーカイブ設定

`/etc/postgresql/9.5/main/postgresql.conf` を編集して、WALのアーカイブをonにする。

```
archive_mode = on
archive_command = 'test ! -f /home/mastodon/backup/postgres-wal/%f && cp %p /home/mastodon/backup/postgres-wal/%f'
```

## pg_basebackを使うための設定

まず、`/etc/postgresql/9.5/main/postgresql.conf` を編集して、`max_wal_senders`を2以上の値にする。

```
max_wal_senders = 2
```

それから、`pg_hba.conf`を編集して、localからのreplicationを許可する。

```
local   replication     postgres                                peer
```

## s3cmdの設定

`sudo -sHu postgres`でpostgresユーザになった上で、`s3cmd`の設定をする。設定は接続先によるので割愛する

## base backupのスクリプト

```
et -u
DATE_STRING=$(date -u '+%Y-%m-%d-%H%M%S')
TMP_DIR=$(mktemp -d)
mkdir -p $TMP_DIR/base
mkdir -p $TMP_DIR/dump
pg_basebackup -D $TMP_DIR/base --xlog-method=stream && \
pg_dumpall > $TMP_DIR/dump/dump.db && \
  cd $TMP_DIR && tar cfz backup.tar.gz * && \
  cd /tmp && \
  s3cmd put $TMP_DIR/backup.tar.gz "s3://bookworms-backup/postgres/backup-$DATE_STRING.tar.gz" &&\
  cp $TMP_DIR/backup.tar.gz /home/mastodon/backup/postgres/backup-$DATE_STRING.tar.gz &&\
  rm -rf $TMP_DIR 
```

## wal backupのスクリプト

```
#/bin/sh

set -u

# check if wal files exists
RES=$(ls /home/mastodon/backup/postgres-wal)
if [ $? -ne 0 ]; then
  echo 'ls failed.' >&2
    exit 1
    elif [ -z "$RES" ]; then
      echo 'no wal files. skip backup.'
        exit 0;
        fi

        DATE_STRING=$(date -u '+%Y-%m-%d-%H%M%S')
        TMP_DIR=$(mktemp -d)
        mv /home/mastodon/backup/postgres-wal/* $TMP_DIR && \
        cd $TMP_DIR && \
        tar cfz wal-$DATE_STRING.tar.gz * && \
        s3cmd put wal-$DATE_STRING.tar.gz "s3://bookworms-backup/postgres/wal-$DATE_STRING.tar.gz" && \
        mv wal-$DATE_STRING.tar.gz /home/mastodon/backup/postgres/ && \
        cd /tmp && rm -rf $TMP_DIR
```

## cron

ユーザ `postgres` でcronを設定する。
base backupを毎日1回、wal backupを8時間に一回実施する。
さらに、/home/mastodon/backup/postgres/の下にある古いファイルを消す。

```
find /home/mastodon/backup/postgres -mtime +14 -exec rm -rf {} \; 
```

### 変更履歴

2017-07-30 `pg_basebackup`を`--xlog-method=stream`で実行するように変更。頻度を調整。
2017-07-31 バックアップすべきwalファイルがないときのチェックを追加
2017-08-01 `pb_dumpall`も取得する
