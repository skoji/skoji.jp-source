---
layout: post
title: Emacs設定変更
date: '2021-02-17T17:14:36+09:00'
image: '/blog/images/emacs.png'
categories:
- 開発環境
---

VS Codeに乗り換えようかと少し迷っていたが、結局Emacsの設定を充実させる方に舵を切った。この1ヶ月ほどで変えた設定について書いておく。全て`package-install`で導入した。

### NeotreeからTreemacsに乗り換え

Neotreeはあまり使わなくなっていて、[Treemacs](https://github.com/Alexander-Miller/treemacs)の方が少しだけ私の目的にあっていそうに思ったので、乗り換えた。
設定は以下のようにした。F1を基本として使う。

``` emacs-lisp
;; treemacs
(use-package treemacs
  :bind
  (:map global-map
        ([f1] . treemacs)
        ([(meta f1)] . treemacs-projectile)
        ("M-1" . treemacs-select-window)
        )
  )
```

### helmからivy + counselに乗り換え

[Helm development is now stalled](https://github.com/emacs-helm/helm/issues/2386)というIssueをたまたま発見した。これ他のドキュメントにはまだどこにも書いてないように思われる。ともあれ、他に似たようなものは、と探して[ivy + counsel](https://github.com/abo-abo/swiper)にたどりついた。`counsel-M-x`は`helm-M-x`と違ってそのままでは履歴順になってくれないので、[smex](https://github.com/nonsequitur/smex)も導入した。

設定は以下のとおり。

``` emacs-lisp
;; counsel
(when (require 'counsel nil t)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "M-y") 'counsel-yank-pop)
  (global-set-key (kbd "C-M-z") 'counsel-fzf)
  (global-set-key (kbd "C-M-r") 'counsel-recentf)
  (global-set-key (kbd "C-x C-b") 'counsel-ibuffer)
  (global-set-key (kbd "C-M-f") 'counsel-ag)
  (global-set-key (kbd "C-M-g") 'counsel-git-grep)
  (counsel-mode 1))

(when (require 'smex nil t)
  (setq smex-history-length 30)
  (setq smex-completion-method 'ivy))

```

### modeline整理

modelineがめちゃくちゃ長くなって、普段右端に表示している行数が見えなくなることがよく起きていた。[diminish.el](https://github.com/myrjola/diminish.el)を導入し、いくつかの、私にとっては表示不要なminor mode表示を消した。もっとまともなやり方がありそうだけれども、素朴な設定をした。

``` emacs-lisp
(eval-after-load "projectile"
  '(diminish 'projectile-mode))
(eval-after-load "editorconfig"
  '(diminish 'editorconfig-mode))
(eval-after-load "company"
  '(diminish 'company-mode))
(eval-after-load "ivy"
  '(diminish 'ivy-mode))
(eval-after-load "counsel"
  '(diminish 'counsel-mode))
(eval-after-load "which-key"
  '(diminish 'which-key-mode))
(eval-after-load "yasnippet"
  '(diminish 'yas-minor-mode))
(diminish 'eldoc-mode)
```

<figure>
<img style="max-width: 99%" src='/blog/images/2021-emacs-modeline-before.png' alt='キーボード比較' />
<figcaption>before</figcaption>
</figure>
<figure>
<img style="max-width: 99%" src='/blog/images/2021-emacs-modeline-after.png' alt='キーボード比較' />
<figcaption>after</figcaption>
</figure>



