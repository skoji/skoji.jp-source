---
layout: post
title: GitHub Actionsに移行してみた
date: '2019-12-01T11:24:33+09:00'
categories:
- ソフトウェア開発
- gepub
- ひとりアドベントカレンダー
---

<img src="/blog/images/actions-icon-actions.svg" alt="GitHub actions" style="width: 25%" />

テーマなしのひとりアドベントカレンダーの初回。

[gepub](https://github.com/skoji/gepub)ではずっと[Travis CI](https://travis-ci.org)でCIしていたが、[GitHub Actions](https://help.github.com/ja/actions)に移行してみた。

1. ActionsのNew workflowsから、Ruby　Gemを指定して生成
2. GitHub Packages Repositoryは今まで使っていなかったので、[Personal access tokens](https://github.com/settings/tokens)から、GitHub Package Repository用のtokenを作成。権限は`read:packages`と`write:packages`。
3. レポジトリのsecretに`RUBYGEMS_AUTH_TOKEN`と`GPR_AUTH_TOKEN`を設定
4. GPRへのリリース用の[OWNERを設定](https://github.com/skoji/gepub/pull/88/files#diff-581c78133e4ffd6ea688db13dcb5aa5fR29)
5. リリースのタイミングは[バージョンタグがpushされた時に限定](https://github.com/skoji/gepub/pull/88/files#diff-581c78133e4ffd6ea688db13dcb5aa5fR6)
6. pushごとにtestを走らせる[workflowも追加](https://github.com/skoji/gepub/pull/88/files#diff-fe8421955fd596131bb6f1b78984b2fb)。
7. READMEにGitHub Actions Testの[バッジを追加](https://github.com/skoji/gepub/pull/88/files#diff-04c6e90faac2675aa89e2176d2eec7d8R4)
8. `.travis.yml`を削除

これでGitHub Actionsでテストが走り、されにこれまで`rake release`でやっていたリリースがリリースタグつけてpushで実行されるようになった。GitHub Packages Repositoryにもpushするようになった。

今のところ、Travis CIよりもそれなりに高速に動いていて良い。残念ながらGitHub Actionsでは、`skip ci`などのコミットメッセージによる実行制御はできないようだ。

