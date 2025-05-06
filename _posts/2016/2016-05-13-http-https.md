---
layout: post
date: 2016-05-13 12:57:50 +0900
categories: [Ruby]
title: iframe/embedなどのhttpをhttpsに切り替える
---

このサイトはJekyll移行と同時に[Let's Encrypt](https://letsencrypt.org)を使ってhttps化した。その際に過去のポストのいくつかで埋め込んだ動画や、Amazonへのリンクが表示されなくなってしまった。

httpsのサイトにhttpなiframeを埋め込んだことによって、セキュリティ的な問題で読み込まれなくなっていたのだった。そしてほぼ全てが単純にhttpをhttpsに置き換えれば動作する。

関連するpostは[買い物ログ](/movabletype)の方では15postあったので、一括で文字列置換することにした。ちょっとだけ手間取ったので記録しておく。

## GNU sedを使う…のは一部動かず

最初は、`_post`ディレクトリ内でこのような対処を試みた。

```
git grep -l iframe | xargs gsed -i 's/iframe\(.+?\)src="http:/iframe\1src="https:/g' 
```

が、GNU sedでも、non-greedyなマッチ(上記でいうと、`.+?`の部分)がサポートされておらず、うまく動作しないケースがあった。
従って同じ行にiframeが並んでいると、後ろのiframeにあるsrcだけが置換されてしまう。

## Rubyでsed -i s///g 相当の使い捨てコードを書く

`rubygsub.rb`として次のコードを書く。

``` ruby
def sed(file, pattern, replacement)
  File.open(file, "r") do |f_in|
    buf = f_in.read
    buf.gsub!(Regexp.new(pattern), replacement)
    File.open(file, "w") do |f_out|
      f_out.write(buf)
    end
  end
end

ARGV[2..-1].each do |f|
  sed f, ARGV[0], ARGV[1]
end
```

これを次のように使う。

```
git grep -l iframe | xargs ruby rubygsub.rb 'iframe(.+?)src="http:' 'iframe\1src="https:'
git grep -l embed | xargs ruby rubygsub.rb 'embed(.+?)src="http:' 'embed\1src="https:' 
```

これで変更が一括でできた。

## 目視で確認する

`jekyll s` でローカルで各エントリを確認をする。`git status`の結果を見ながら手でエントリを探すのはだるいので、次のように、変更されたpostへのリンクを含むhtmlを生成した。

```
git status | grep modified | sed -e 's/^.*\(20..\)-\(..\)-..-\(.*\)$/<a href="127.0.0.1:4000\/movabletype\/\1\/\2\/\3">\3<\/a><\/br>/' > test.html
```

## 疑問

これWordPressだったらどうしたら良かったのだろう。

