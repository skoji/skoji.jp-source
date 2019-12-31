---
layout: post
title: textlintの設定
date: '2019-12-31T10:41:50+09:00'
categories:
- blog設定
---

先日[textlintを導入](/blog/2019/12/textlint.html)してから色々設定をいじった結果、今はこういう設定に落ち着いた。

* [preset-japanese](https://github.com/textlint-ja/textlint-rule-preset-japanese)より厳し目の[preset-ja-technical-writing](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing)を導入
* [ja-no-weak-phrase](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing#弱い日本語表現の利用を使用しない)はオフ。ブログなので。「かもしれない」とか普通に使う。
* [arabic-kanji-numbers](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing#漢数字と算用数字を使い分けます)はオフ。『八百万の死にざま』みたいな書名がひっかかる。引用がひっかかることもあるだろう。
* [no-doubled-joshi](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing#同じ助詞を連続して使用しない)は少しゆるめる。特に、繰り返して使う言い回しが多い助詞は除外。

結果の`.textlintrc`は以下のとおり。

``` json
{
  "rules": {
    "preset-ja-technical-writing": {
      "ja-no-weak-phrase": false,
      "arabic-kanji-numbers": false,
      "no-doubled-joshi": {
        "allow": ["も","や","にも","でも","たり"],
        "min_interval": 3
      }
    }
  }
}
```

最近の投稿は基本的にこの設定でエラーが出ないようにしているが、完全に従うつもりもない。特に、助詞の連続はtextlintに指摘されたら考えるけれど、やはりこれが良いって場合もある。
