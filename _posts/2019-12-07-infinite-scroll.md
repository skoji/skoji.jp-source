---
layout: post
title: 無限スクロール
date: '2019-12-07T12:56:29+09:00'
categories:
- blog設定
- ひとりアドベントカレンダー
---

<img src="/blog/images/scroll.png" alt="巻物" width="50%" />

毎日ブログを書いていると、ブログの設定もいじりたくなるということがわかった。[先日のこの記事](/blog/2019/12/cooking.html)に書いたように、ページングしなくては。という気持ちが強まり、今日は朝からその設定をしていた。結局無限スクロールにしつつ、`pushState`でページ移動がわかるようにもした。vanilla JSで書きたいというのもあり、割とてこずった。

結果のコード変更点は[これ](https://github.com/skoji/skoji.jp-blog/pull/4)。

やったことの概要を以下に書く。

### jekyll-paginate-v2を導入

まずは単純に[ペジネーションをする](https://github.com/skoji/skoji.jp-blog/pull/4/commits/7a7bb27a11f5025a49818d5fea77057c30980512)。1ページあたりの記事数が60と多いが、それはウィンドウの幅がどのサイズでも、ぴったり記事がおさまるようにしたかったからだ。
ペジネーションすると、`page`が増えてしまい、その結果ヘッダにペジネーションしたページが並んでしまうので、indexおよび自動生成されたページは[除外する](https://github.com/skoji/skoji.jp-blog/pull/4/commits/7a7bb27a11f5025a49818d5fea77057c30980512#diff-822e9cf54ee310f9a7ebd0d16c9ae066R19)ようにした。

### JavaScriptで指定されたページの中身をDOMに追加

UIは変更せずに、「指定されたページをfetchして、その内容をappendChildで追加」する[コードを書き](https://github.com/skoji/skoji.jp-blog/pull/4/commits/49dbca8b9b5e9459946d9b57947950f19e954e3a)、開発者ツールから動作を確認した。

### 「もっと読む」ボタンを追加

fetchして追加のコードをリファクタしつつ、[UIにボタンを追加した](https://github.com/skoji/skoji.jp-blog/pull/4/commits/c3e2454cb0583d9ed5971475e2959c82f8f0fd55)。また、

### Window内でのページ位置を覚える

`pushState`の準備として、どのへんにどのページがあるかを[おぼえさせた](https://github.com/skoji/skoji.jp-blog/pull/4/commits/8fc368c9dfc5217208a1de543fed09c625c5d559)。（最終的なコードではこのコミットからさらに変更している）

### 途中ページが最初からロードされたら、その前のページを読み込む

`page-10`とか指定されたら、それより前も順次読み込んで[DOMに追加するようにした](https://github.com/skoji/skoji.jp-blog/pull/4/commits/43fe4db0a599a7afc4a0e0c6be5eeb708635ead3)。

### Scrollして、ページ移動したらpushStateする

スクロール位置によって、[pushStateでURLを書き換える](https://github.com/skoji/skoji.jp-blog/pull/4/commits/244dc9d08b77f8ae7de3b56d40d14435178db238)。その前のコードに色々問題があり、ここがいちばんてこずった。

### 今後の課題

* 途中ページ読んだときに、前のページを一気に読みに行くのはあまり良くない。前ページだけ読んで、徐々に読む方が良いかもしれない。
* これはこれとして、画像のlazy loadがあった方が良い気がする。




