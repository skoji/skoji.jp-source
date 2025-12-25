---
layout: post
title: FreeBSD デスクトップ環境の構築
date: '2025-12-25T20:00:02+09:00'
categories:
 - computer/gadgets
---

<img class="small-img" src="/blog/images/freebsd-desktop-20251225.jpeg" alt="FreeBSD デスクトップ画面。" />

20年以上ぶりにFreeBSDを実機インストールした。
デスクトップ環境も構築した。昔に比べればずっと簡単なのだが、今時のUbuntuなどに比べればそこそこ手がかかったので、やったことを記録しておく。

試行錯誤もあったがそれらは省略して、最終段階の物を書いている。色々やっているので漏れがありそう。

## 前提

ハードウェアはLemur Pro (2020年のLemp9)。Intel i7-10510U, Intel UHD Graphics 620, WiFiはIntel AX201。
FreeBSD 15-Releaseを入れた。

## インストール

memstick imageを使う。基本はデフォルトで、FreeBSD 15ではtech preview扱いになっているpkgbaseを選択した。ZFSの暗号化などは設定していない。
一般ユーザもインストーラで設定する。WiFiなどスムーズに認識して特に問題はない。

## sudoerなどの設定

まず、一般ユーザのディレクトリがroot/wheelになっているので、chownする。
sudoがデフォルトでは入っていないので、pkg install sudoする。さらに、visudoで、wheelに権限を与える。これで一般ユーザ側でsudoが使えるようになる。

## デスクトップ環境: KDE Plasma

何度も試行錯誤したが、結局KDE Plasmaにした。

まず、Intel GPU向けのデバイスドライバを入れて設定する。
sysrcでrc.localに書き込まれる。

```
pkg install drm-kmod 
sysrc kld_list+=i915kms
```

xorgをいれ、ユーザをvideoグループに追加する。

```
pkg install xorg
pw groupmod video -m <username>
```

KDE Plasmaをインストールする。

```
pkg install kde
```

ハンドブックではplasma6-plasma, konsoleなどのインストールがあるが、不要だった。

dbusを使うので有効にする。

```
sysrc dbus_enable="YES"
```

sddmで自動起動するようにする。

```
pkg install sddm
sysrc sddm_enable="YES"
```

USキーボードなのでlang設定はしなかった。

## デスクトップ環境内で色々設定

これで再起動すれば、Plasmaのログイン画面が出るはず。
デフォルトではWaylandだが、Wayland + FreeBSDでこのマシンではsleepからの復帰に失敗する（実際のところは復帰するのだが、GUIが復帰しない）。なので左下でX11のセッションを指定して起動する。

### Emacs

`sudo pkg install emacs`で素直にEmacs 30がはいるのでありがたい。tree-sitter-langsが動かない、というマイナーな問題が発生するので単純にtree-sitter-langsを使わないようにする。

### 日本語入力

ibus-mozcを入れる。

```
sudo pkg install ibus ja-ibus-mozc
```

### 「ナチュラルスクロール」が効かない

トラックパッドで「ナチュラルスクロール」が効かない。Waylandでは設定すれば効いたのだが、X11だとダメだ。GUIに頼らずファイルで設定した。

`/usr/local/etc/X11/xorg.conf.d/40-libinput.conf`に以下を設定した。

```
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "NaturalScrolling" "true"
EndSection
```

### 中央ボタンクリックのペーストをやめる

Lemur Proは見た目はボタンがないが中央ボタンが存在するようで、間違ってクリックするとペーストされる。Wayland + Plasmaなら設定があるようだがX11だとない。
xmodmapで設定した。本当は中央クリックも左クリックと同じにしたいのだが、xmodmapだけでは出来なさそうだ。

`$HOME/.Xmodmap`

```
pointer = 1 24 3
```

