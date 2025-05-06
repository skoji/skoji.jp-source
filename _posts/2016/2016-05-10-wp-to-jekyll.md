---
layout: post
date: 2016-05-10 17:22:46 +0900
title: WordPressからJekyllへの引っ越し記録
---

[買い物ログ](/movabletype)とともに、このブログはWordPressからJekyllに引っ越した。以下、引っ越しのために実施した作業を記録する。

## WordPressのデータを書き出し

WordPress管理画面 >  ツール > エクスポート から、「全ての記事を書き出し」でXMLをダウンロードする。

## Jekyllで新規サイト作成

```
$ gem install jekyll jekyll-import
$ jekyll new blog
$ cd blog
```

## XMLをインポート


まずImport用のscriptを用意する。

``` ruby
require "jekyll-import"
JekyllImport::Importers::WordpressDotCom.run(
    { "source" => "<path-to-wordpress-xml>",
      "no_fetch_images" => true
 })
```

そして、上記のblogディレクトリで実行する。

```
$ ruby ./import-script.rb
```

不足しているgemはメッセージが出たらインストールしていく。

self-hosted WordpressのDBを直接読むImporterである`JekyllImport::Importers::Wordpress`もあるが、元のWordpress記事のフォーマットによってはうまく取り込めない。

## configの設定

`_config.yml`に必要な設定を加える。

### premalinkの設定

もともとpermalinkは`YYYY/MM/title` という形式だった。permalinkは変更したくないので、設定を合わせる。

```yaml
permalink: /:year/:month/:title.html`
```

### base urlなどの設定

このブログは`skoji.jp/blog`に配置しているので、以下のように設定する。

```yaml
baseurl: "/blog" 
url: "https://skoji.jp"
```

### Category slugの設定

後述する、`jekyll-archives`の改変版で使うslugとカテゴリ名のマップを書く。
このブログでは次の通り。キーが表示名、値がslug。

```yaml
category_slug_map:
    .NET Framework: "net-framework"
    atom: "atom"
    Factor: "factor"
    gepub: "gepub"
    Lisp系: "lisp系"
    LowLevel: "lowlevel"
    Lua: "lua"
    R: "r"
    Ruby: "ruby"
    webapp: "webapp"
    イベント: "イベント"
    このブログについて: "このブログについて"
    その他: "その他"
    ソフトウェア開発: "ソフトウェア開発"
    プログラミング言語: "プログラミング言語"
    休むに似たり: "休むに似たり"
    未分類: "未分類"
    本: "本"
    開発環境: "開発環境"
    電子書籍: "電子書籍"
```

## templateの変更 

Wordpress Importerでできたpostでは、authorの中身がhashになっている。それに対応できるように、次の変更をする。

* authorを扱うLiquid Filterをかく
* post.htmlでそれを利用する

詳しくは[このコミット](https://github.com/skoji/skoji.jp-blog/commit/4a6f01df18976080f833da7ee9268884e2b06020)を参照。


(ただしauthorは私しかいないので、このあとでauthorはそもそも表示しないように変更した)

## plugin

### jekyll-archives

Wordpress版及びその前のMovableType版では、カテゴリーや月別のアーカイブページがあった。このリンクも再現しておく。
[Jekyll Archives](https://github.com/jekyll/jekyll-archives)が適切そうだったが、残念ながらカテゴリの表示名とslugを別々に管理することができない。
そこで、「configのcategory_slug_mapを読み込む」ように最小限の変更を加えた。変更は[このコミット](https://github.com/skoji/jekyll-archives-mod/commit/8e32383b1fd8785ebcf616d93a5b7655abe5d521)を参照。

#### jekyll-archives-modの配置

`_plugins`以下に、`jekyll-archives.rb`及び`jekyll-archives`ディレクトリをコピーする。

#### jekyll-archivesの設定

月別及びカテゴリーアーカイブしか必要ないので、次のように設定する。

```yaml
jekyll-archives:
  enabled: [month, categories]
  layouts:
    month: 'month-archive'
    category: 'category-archive'
  permalinks:
    month: '/:year/:month/'
    category: '/category/:name/'
```

### カテゴリー名からスラッグヘの変換フィルタ

以下のようなフィルタを書き、これを_plugins以下に配置する。

``` ruby
module Jekyll
  module CategoryNameToSlug
    def catname2slug(input)
      slug_map = @context.registers[:site].config['category_slug_map']
      (slug_map && slug_map[input]) || Utils.slugify(input)
    end
  end
end
Liquid::Template.register_filter(Jekyll::CategoryNameToSlug)
```

post.htmlでは、次のように書くことで、このフィルタを使い、カテゴリーアーカイブへのリンクを作ることができる。
{% raw  %}
```html
    {% if page.categories %}
      <ul>
      {% for category_name in page.categories %}
      <li><a class="category_link" href="{{site.baseurl}}/category/{{ category_name | catname2slug }}/">{{category_name}}</a></li>
      {% endfor %}
      </ul>
    {% endif %}
```
{% endraw %}

## layoutの追加

Category Archiveのレイアウト(category-archive.html)

{% raw  %}
```html
---
layout: default
---
<h1>カテゴリー: {{ page.title }}</h1>
<ul class="posts">
  {% for post in page.posts %}
    <li>
      <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span>
      <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
```
{% endraw %}

月別アーカイブのレイアウト(monthly-archive.html)

{% raw %}
```html
---
layout: default
---
<h1>月別アーカイブ: {{ page.date | date: "%Y年%m月" }}</h1>

<ul class="posts">
{% for post in page.posts %}
  <li>
    <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span>
    <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
```
{% endraw %}

## その他

* [jekyll-compose](https://github.com/jekyll/jekyll-compose)およびshell scriptの追加で、コマンドラインからEmacsで新規blog記事を開く設定を行った。
* GitHubにpushしたらdeployする仕組みを入れた。

## まとめ

この他にも細かいスタイルなどの調整や、ソーシャルボタンの追加などを行っている。ここのブログのソースは[https://github.com/skoji/skoji.jp-blog](https://github.com/skoji/skoji.jp-blog)にある。

ページネーションは、アーカイブまで含めると面倒そうなので実施していない。また検索機能も含めていない。コメントは[Disqus](https://disqus.com/)を試してみたが、そもそもコメント欄が必要なのか疑問があるので追加していない。



