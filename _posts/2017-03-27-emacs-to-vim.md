---
layout: post
title: EmacsからVimへ
date: '2017-03-27T19:44:18+09:00'
image: 'http://www.hanmoto.com/bd/img/978-4048916592_400.jpg'
categories:
- 開発環境
---

20歳の頃からずっとEmacsを使っている。もう四半世紀が過ぎているから、ほとんど何も考えなくったって指が動くようになっている。それなのにVimに乗り換えようと思って、4日前から使い始めている。

いくつか試した上で、当面はMacVim + Kaoriyaパッチを使ってみることにした。ターミナルから使うVimだと、IME切り替えでそれなりにストレスがたまりそうに思ったからだ。neovimも気になるが、IMEの問題がやはり解決できない。

現時点で次の設定を行った。

* パッケージマネージャーdein.vim
* vimproc
* editorconfig-vim
* dash.vim
* marked.vim （markdownプレビューにMarked 2を呼び出し）
* dict.vim （macOSの標準辞書呼び出し）
* jsのセーブ時にvimprocで`eslint --fix`を走らせる（ここでvimproc使っている）
* js/ruby/cppのindent設定
* color schema設定
* SourceCode Proフォントの設定
* insert mode/command modeのカーソル移動はEmacs風に

まだ色々足りないけれども、とりあえず生活できる。時々カーソルを上に移動しようとしてペーストしてしまうことがあるけれども、「指がどうしてもEmacsに戻りたくなる」段階はようやく過ぎた。設定の発想はEmacsと大きく異なるので、まだ戸惑っているが、elispよりはだいぶ敷居が低そうに思っている。

数年前にしばらくSublime Text 2を使ってみたことがあるが、その時は結局半年でEmacsに戻ってきた。なかなか便利だったのだけれども、気に入った機能は調べると全部Emacsでも実現可能だった。Emacsと比較すると、私にとっては特に良くも悪くもなかったのだった。

Vimの場合は、表面的な機能がどうこう以前に、ノーマルモードが「コードを書く」のに近い発想があるように思っている。それがずいぶん前から羨ましくて、でも長年積み上げたEmacsの資産や経験を手放すのに躊躇していたのだった。

今回こそは、ついに乗り換えられそうな気がしている。半年後はわからないけれども。

これから[『実践Vim』](http://amzn.to/2o9isYu)を読む。
