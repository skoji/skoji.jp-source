---
title: Jekyll Adminを入れた
categories:
- blog設定
- Ruby
---

このブログはJekyllを使っていて、長いことEmacsで普通にテキストを書いていた。ちょっと気分を変えてみるためにローカルのGUIで編集できる[Jekyll Admin](https://github.com/jekyll/jekyll-admin)を導入した。

簡単に管理画面までは出たが、新たなポストを生成した途端にエラーが発生してしばらく手間取った。結局、Jekyll Adminの[このバグ](https://github.com/jekyll/jekyll-admin/issues/699)が原因だった。昨日直されているがまだリリースされていないので、まずはワークアラウンドの`--no-watch`を使うことにした。

![](/blog/images/jekyll-admin.jpg)

残念ながら画像の挿入は今までと同様ほぼ手動でやらなくてはならない。そして、この環境だと以前[設定したtextlint](/blog/2019/12/textlint.html)が使えないことにも気づいた。Chrome拡張でtextlintを使えるものもあるようだ。調べて試してみようと思う。

