---
layout: post
title: Jekyllが遅いのでMarked 2でプレビューする
category: MT・WP設定
---

[買い物ログ](/movabletype/)ととともにJekyllに引っ越してからあまりアクティブではない。来年はもっとブログを書こうーと思っている。しかし、Jekyllは記事数が増えてくると遅い。こっちのブログはまだ良いのだが、買い物ログの方は全記事のビルドに30秒から1分くらいかかっている。記事を書くときはレイアウトされた状態で確認しつつ書きたいのでこれでは遅すぎる…。

Go言語で書かれたHugoはこういうときも速いらしく、また引っ越すかでもレイアウト作り直しめんどくさい。

と悩んでいて見つけた落とし所は、EmacsのMarkdownプレビューで乗り切る方法。最近軽くMarkdown書類を書くときはMarked 2 + Emacsでやっていて、それをそのまま使えば良いやとなった。

まず、Marked 2起動スクリプトをかく。

``` bash
#!/bin/sh

if [ "$1" ]; then
    open -a "Marked 2" "$1";
else
    open -a "Marked 2";
fi
```

Emacs Lispには次の設定を追加する。

``` emacs-lisp
(setq markdown-open-command "path/to/marked2")
```

これで、`\C-c\C-c o` でMarked 2が開く。変更はリアルタイムでプレビューされる。スタイルシートはブログ本体とは異なるけれども、それは大した問題ではない。必要があれば設定もできそうだけれども、そこまでまだやっていない。




