---
layout: post
title: IPv4接続かIPv6接続か表示する
date: '2019-12-05T11:59:24+09:00'
categories:
- ひとりアドベントカレンダー
- blog設定
---

![IPv6 logo](/blog/images/World_IPv6_launch_logo_512.png)

今IPv4で接続しているのか、IPv6で接続するのか表示するページが時々ある。[So-netのトップページ](https://www.so-net.ne.jp)はそうだ（が、モバイル用のページだと表示していないようだ。[こっちのページ](http://www.so-net.ne.jp/common/IPv6/)はデスクトップ用しかなく、こちらなら表示される）。

このサイトでも[トップページ](/)で、下の方に「Connected via IPvナントカ」って出るようにしてみた。

やったことは以下の通り。

まず、nginxのconfigで、IPv4接続かIPv6接続かをチェックするために`geo`ディレクティブを使う。

```
geo $iptype {
  ::0/0 ipv6;
  0.0.0.0/0 ipv4;
}
```

`server`ディレクティブ内部で、この値を使う。

```
  location ~ ^/ipx {
    if ($iptype = 'ipv6') {
      return 200 'IPv6';
        add_header Content-Type text/plain;
    }
    if ($iptype = 'ipv4') {
      return 200 'IPv4';
      add_header Content-Type text/plain;
    }
  }
```

`/ipx`にアクセスすると、`IPv4`または`IPv6`の文字列が返る。これを、トップページのhtmlの中に埋め込む。

```
const now = Date.now();
fetch('/ipx?' + now).then(function(response) {
  return response.text();
}).then(function(text) {
  document.getElementById('ipvx').innerText = "Connected via " + text;
});
```

`Date.now()`使ってるのはキャッシュされないようにするため。


