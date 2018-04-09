---
layout: post
title: Gitで日本語長文のdiffをとる方法
date: '2018-04-09T19:32:06+09:00'
categories:
- 開発環境
---

日本語の長文をgitで管理していると、ほんのちょっとの変更でも、diffでは行丸ごと変更されたことになり、変更点がよくわからないことがある。

二泊三日で小説を書く過激なイベント[NovelJam](https://www.noveljam.org) 2018参加作品である高橋文樹氏の[「オートマティック クリミナル」](https://bccks.jp/bcck/153422/info)は、[GitHubを使って](https://github.com/fumikito/noveljam2018)執筆されている。小説ではこの欠点がはっきりでる。高橋氏は[参加レポート](https://takahashifumiki.com/literature/4445/)で、こう書いている。

> あと、今回得た重要な知見なのですが、Githubではある程度以上テキストが長くなってくると、数文字の調整で全部差分として判定されたりするので、小説には向いてないかなーと思いました。小説は行の移動とかがよく発生するので、GithubじゃなくてGitとの相性かもしれません。

確かに、普通にdiffをとるとその通り。コマンドラインで[「オートマティック クリミナル」リポジトリ](https://github.com/fumikito/noveljam2018)の途中経過diffを

```
git diff 8ae5f..d0394
```

上記でとった結果は、以下の通りになる。


![](/blog/images/normal-git-diff-japanese.png)


同じ変更を、`--word-diff-regex`を適切に指定して`git diff`してみる。

```
git diff --word-diff-regex=$'[^\x80-\xbf][\x80-\xbf]*' --word-diff=color 8ae5f..d0394
```

すると、このような結果が得られる。文字単位で変更点が把握できるのだ。

![](/blog/images/word-git-diff-japanese.png)

なお、`git diff --word-diff-regex=.`でも良さそうなものだが、これだと（少なくとも私の環境では）diff部分が文字化けしてしまう。unicodeの文字単位ではなく、byte単位でdiffが取られてしまっているようだ。

GitHubでは`--word-diff-regex`相当の設定はできなさそうで残念。
