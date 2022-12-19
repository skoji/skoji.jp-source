---
title: Jekyll Adminを入れた
categories:
- blog設定
- Ruby
---

このブログはJekyllで作っていて、長いことEmacsで書くルーチンでやってきていたが、ちょっと気分を変えてみるためにローカルのGUIで編集できる[Jekyll Admin](https://github.com/jekyll/jekyll-admin)を入れてみた。

最初にいきなりつまづいて30分ほど調べたが、結局Jekyll Adminの[このバグ](https://github.com/jekyll/jekyll-admin/issues/699)のせいだった。昨日直されているがまだリリースされていないので、まずはワークアラウンドの`--no-watch`を使うことにした。

![](/blog/images/jekyll-admin.jpg)

残念ながら画像のロードなどは今までと同様ほぼ手動でやらなくてはならない。ちょっと使っていたら改善のコントリビュートもできそうかなと思っている。
