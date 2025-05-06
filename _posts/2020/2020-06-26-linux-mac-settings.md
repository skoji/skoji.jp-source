---
layout: post
title: Linux環境の設定
date: '2020-06-26T08:20:22+09:00'
categories:
- 開発環境
- computer/gadgets
---

[Lemur Proを買った](/blog/2020/06/lemur-pro.html)ので、開発に使えるようベース環境の設定をした。

Emacsとzshの設定ファイルはMacと共有で設定することにした。

## Zsh

macでは、`.zshrc`と`.zprofile`を使っている。実体はDropboxにあり、シンボリックリンクを貼っていた。さらにgitでバージョン管理もしている。これを基本的にそのままLinux側でも使う。

### macOSとLinuxの切り替え

必要があれば、こんなふうに`OSTYPE`で切り替える。

``` shell
case ${OSTYPE} in
    darwin*)
        export PATH=$(brew --prefix)/smlnj/bin:"$PATH"
        ;;
    linux*)
        
        ;;
esac
```

### .zprofileが読まれない

が、Linux側で`.zprofile`が読み込まれない。GNOME Terminalで`Run command as login shell`をオンにする必要があった。

## Emacs

同じinit.elを共有し、`window-system`が`mac`なのか`x`なのか、または`system-type`が`darwin`なのか`gnu/linux`なのかで切り替える。

### フォントの設定

Noto Fontはひととおり最初から入っているので、日本語はNoto Sans JPを選ぶ。欧文フォントは、ずっと使っている[Source Code Pro](https://github.com/adobe-fonts/source-code-pro/releases/tag/2.030R-ro%2F1.050R-it)にした。試行錯誤した結果、以下の設定にした。

``` emacs-lisp
(when (equal window-system 'x)
  (let* ((size 12)
         (asciifont "Source Code Pro")
         (jpfont "Noto Sans CJK JP") 
         (h (* size 10))
         (fontspec (font-spec :family asciifont))
         (jp-fontspec (font-spec :family jpfont :size 15)))
    (set-face-attribute 'default nil :family asciifont :height h)
    (set-fontset-font nil 'japanese-jisx0213.2004-1 jp-fontspec)
    (set-fontset-font nil 'japanese-jisx0213-2 jp-fontspec)
    (set-fontset-font nil 'katakana-jisx0201 jp-fontspec)
    (set-fontset-font nil '(#x0080 . #x024F) fontspec)
    (set-fontset-font nil '(#x0370 . #x03FF) fontspec)
    )
  )

```

### クリップボード

GNOMEのクリップボードとEmacsのkill/yankを相互に行き来できるようにする。

``` emacs-lisp
(when (equal window-system 'x)
  (setq x-select-enable-clipboard t)
  (setq x-select-enable-primary t)
  )
```

### 日本語入力

最初はGNOMEのibus-mozcをそのまま使っていたが、Emacs上ではインライン変換にならないのが気持ち悪くて、emacs-mozcをいれた。emacs-mozcは、mozc.elのほかに、サポート用のバイナリemacs-mozc-binが必要になる。mozc.elはmelpaにもあるが、`init.el`をまるごとMacと共有する関係上aptで入れることにした。（なお、melpaのmozcをMac側のEmacsにいれても、特に問題は起きなかった）

#### emacs-mozcパッケージのインストール

``` shell
sudo apt install emacs-mozc # これでmozc.elと、emacs-mozc-binが両方インストールされる
```

#### init.el

``` emacs-lisp
(when (equal system-type 'gnu/linux)
  (require 'mozc)
  (setq default-input-method "japanese-mozc") 
  )
```

最初は`(set-language-environment "Japanese")`を入れていたのだが、ただこれだけ行うと非ASCII文字の入ったファイルは、文字コードがEUC-JP(!)になる。`set-language-environment`はヘルプによると

> This sets the coding system priority and the default input method and sometimes other things.

とのことだ。UTF-8がデフォルトでよくて、mozcを明示的に指定する場合には特にメリットもなさそうだ。また、MacのEmacsではずっと、`set-language-environment`なしで特に問題なくつかってきた。

Emacs上で`C-\`を使って日本語入力するのはとても久しぶりでなつかしい感覚だ。そういえばMacのEmacsでも`C-\`を使ってみるとEmacs標準の使いやすいとはいえない日本語入力が起動した。Emacsの設定ではもともとMac特有のものは別にしていたこともあり（fontの設定・Markdownプレビューアプリの設定など）、この程度の追加で普通にいつもの環境でEmacsが使えるようになった。RustやRubyのコードをLinux側でも編集し動かしてみているが、特に違和感なく使えている。

このブログはJekyllで構築しており、記事の編集中はtextlintが動作するようにしている。その環境もLinux側で問題なく動いていている。この記事はLemur Proで書いている。

