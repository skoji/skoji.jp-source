---
title: アドベントカレンダーのページを作った
date: 2025-12-04T16:17:00+09:00
categories:
  - ひとりアドベントカレンダー
  - blog設定
layout: post
---
<p class="note">これは<a href="/blog/advent-calendar/2025/">ひとりアドベントカレンダー「日記ぽい」</a>4日目の記事です。ブログの設定更新も日記なのだ。</p>

<img class="small-img" src="/blog/images/advent-calendar-page.png" alt="advent calendar pageのスクリーンショット" />

ひとりアドベントカレンダーは過去にもやっていて、アドベントカレンダーの記事一覧ページがないのはさみしいなあ、と思っていた。やっと実装した。


今年のアドベントカレンダー記事一覧ページは[ここ](https://skoji.jp/blog/advent-calendar/2025/)だ。「ひとりアドベントカレンダー」カテゴリーの記事が追加されるとJekyllビルド時に増えていく。

[Jekyllのlayout](https://github.com/skoji/skoji.jp-source/blob/dcffd941aab08fe8406c64a6ab6e22c02712682b/_layouts/advent-calendar.html)として実装し、ページの定義自体は手動で追加する。今年のページ定義は[ここ](https://github.com/skoji/skoji.jp-source/blob/dcffd941aab08fe8406c64a6ab6e22c02712682b/advent-calendar-2025.md)にある。frontmatterだけで中身はない。

「カレンダーは表ではない」主義者なので、HTMLとしては`table`ではなく`ul`を使っている（`ul` = unordered listなのは適切じゃない、`ol`にすべきだ、と書いていて気がついた）。表形式へのレンダリングはCSS gridを使っている。初日の曜日は`grid-column-start`でコントロールしている。CSSは[こちら](https://github.com/skoji/skoji.jp-source/blob/dcffd941aab08fe8406c64a6ab6e22c02712682b/css/main.scss#L987-L989)。そして、Liquid Templateとしては[以下のようなこと](https://github.com/skoji/skoji.jp-source/blob/dcffd941aab08fe8406c64a6ab6e22c02712682b/_layouts/advent-calendar.html#L16-L17)をしている。

{% raw %}

```html
    {% assign first_date = year | append: "-" | append: month | append: "-01" %}_
_    {% assign first_day_of_week = first_date | date: "%u" | plus: 0 %}
    //...
   <ul class="calendar" style="--first-day: {{ first_day_of_week }}">
```

{% endraw %}

Liquidでは日付のフォーマットでstrftimeの文法が使える。`%u`では、月曜日を1とした数値表現が得られるから、月曜始まりカレンダーならそのまま使える。

<h5>追記</h5>

[修正した](https://github.com/skoji/skoji.jp-source/pull/34/files)。advent calendar pageの日付`ul`から`ol`に変更し、さらに曜日のラベルを外に出した（曜日ラベルは順序付きリストで並べた日付の一部とは言えないので）。
