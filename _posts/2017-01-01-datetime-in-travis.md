---
layout: post
title: Travisの日時とJekyll
date: 2017-01-01 00:47:10 +0900
---

今学んだこと。2017年1月1日0時台にJekyllで記事を書いて、Travis CIでビルドする。そうすると、Travis CI側ではその記事は生成されない。なぜならば、Travis CIのマシンがいるタイムゾーンはまだ2017年になっていないから。

frontmatterにdateフィールドがあって、そこに UTC+0900で日付が書いてあればもちろんOK。
