---
title: code-server + iPad + SSH Port forward
date: 2025-05-06T10:23:00+09:00
image: /blog/images/IMG_2169.jpeg
categories:
  - ソフトウェア開発
---
iPadから使う目的でcode-serverをVPSに入れてみた。

インストールはものすごく簡単だ。[ドキュメント](https://coder.com/docs/code-server/install)に書いてある通りにやれば良い。

インストールスクリプトをまず走らせる。最初にdry-runして何が起きるか確認した方が良い。Ubutuだとこれだけで、systemd管理下に入れる準備までしてくれる。

```sh
curl -fsSL https://code-server.dev/install.sh | sh
```

最後の方で、systemdで有効にするためのやり方まで表示される。

その前に私はここでポート番号を変更するために、`~/.config/code-server/config.yml`のbind-addrを変更した。

それから、インストールスクリプトの指示通りにサービスを有効にする。

```
  sudo systemctl enable --now code-server@$USER
```

これでローカルでは起動している。

それから、nginx + Let's Encryptでの設定をする。これも指示通りにやればすぐにできる。公式ドキュメントの通りにやれば良いので省略する。

しかし公式にはSSH port forwardingを推奨していて、これはiPadなどではできない…と書いてあるが、しかしBlink.shではSSH port forwardingができるのだった。

これもcode-serverのドキュメント通りに、Blink.shでSSLするとあっさり動作した。ただ、直接SSLで繋ぐよりもだいぶ遅い感じがする。
