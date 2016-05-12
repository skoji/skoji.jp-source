---
layout: post
title: Tweet数集計
category: R
date: 2016-05-12 17:10:55 +0900
---

自分のTweets数経過をグラフにしてみた。データは、Twitter公式サイトからダウンロードできる全ツイートアーカイブに含まれている、`tweets.csv`。
前処理などせずに、このデータを直接Rで集計してみた。

![Tweets数推移](/movabletype/assets/tweets-graph.png)

ソースコード

``` r
library(xts)
x <- read.csv("tweets.csv")
x <- x[,c(4)]
x.xts <- as.xts(read.zoo(x))
x.monthly = apply.monthly(x.xts[,1], length)
png("tweets-graph.png", width=800, height=400)
plot(x.monthly, main="Tweets", major.format="%Y-%m")
dev.off()
```

関連記事: [Tweet数とブログ](/movabletype/2016/05/tweets-and-blog.html)(買い物ログ)
