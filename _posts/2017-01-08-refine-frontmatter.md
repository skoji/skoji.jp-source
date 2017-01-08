---
layout: post
title: Frontmatter設定を改善する
date: '2017-01-08T20:49:28+09:00'
categories:
- blog設定
---

Jekyll移行後、新規post作成には[`jekyll-compose`](https://github.com/jekyll/jekyll-compose)を使っている。

便利なのだが、frontmatterにlayoutとtitleしか設定してくれない。追加の設定をする機能はない。起動時にdateを指定しても、frontmatterのdateには反映されない。

dateが設定できないと地味に[問題になる場合](https://skoji.jp/blog/2017/01/datetime-in-travis.html)がある。これを手動で毎度解決するのは気持ち悪いので、`jekyll-compose`を起動する前に簡単な前処理で書き換えることにした。

`jekyll-compose`で生成されたpostの雛形にはfrontmatter部分しかない。これを読み込んで、YAMLとして書き換える方法をとった。

``` ruby
require 'yaml'
y = YAML.load File.read(ARGV[0])
y['date'] = DateTime.now.to_s
y['categories'] = ['未分類']
File.write ARGV[0], YAML.dump(y) + "---\n"
```

こういうスクリプトを書いて、`jekyll-compose`直後に呼ぶようにする。

本来は`jekyll-compose`自体に修正を入れるのが筋だろう。
