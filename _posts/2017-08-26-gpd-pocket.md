---
layout: post
title: GPD Pocket Ubuntu版設定
date: '2017-08-26T09:51:08+09:00'
categories:
- 開発環境
---

幻になるかと思われたGPD Pocket Ubuntu版がようやく届いたのでいろいろ設定した。

### CAPS lockをctrlに入れかえ

`/etc/default/keyboard`に`XKBDOPTIONS="ctrl:nocaps"`を指定

### mozc + fcitx

たぶんいちばん標準的な日本語入力方法。
```
im-config -n fcitx
（いったん再起動）
fcitx-configtool
```

### ssh

新たにkeyを生成して、あちこちにログインなどできるようにした。

### 起動時のドラム音

音量をmuteにしても、ログイン前には音がでてしまう。
`/usr/share/glib-2.0/schemas/com.canonical.unity-greeter.gschema.xml`を書き換える。以下の`false`を`true`に書き換える。

```
    <key name="play-ready-sound" type="b">
      <default>false</default>
      <summary>Whether to play sound when greeter is ready</summary>
    </key>
```

## GPD Pocket固有

### fan controlなど
[gpd-pocket-ubuntu-respin](https://github.com/stockmind/gpd-pocket-ubuntu-respin)に頼った。cloneして、`sudo sh update.sh`でOK。
fan control以外にも解像度調整などいろいろはいっている。

ただし、GPD Pocket標準ubuntuに適用すると、タッチパネルがさらに回転しておかしなことになる。`gpdtouch.sh`で以下の部分を変更する。このファイルは`update.sh`で`/usr/local/sbin/gpdtoush`にコピーされるので、そちらを直接変更してもよい。

```
--- a/display/gpdtouch.sh
+++ b/display/gpdtouch.sh
@@ -33,10 +33,10 @@ do
     currentmatrix=$(echo -e $(xinput list-props $id | grep 'Coordinate Transformation Matrix' | cut -d ':' -f2))
 	#echo "Current matrix: $currentmatrix"
 
-	if [ "$currentmatrix" != "0.000000, 1.000000, 0.000000, -1.000000, 0.000000, 1.000000, 0.000000, 0.000000, 1.000000" ]; then
+	if [ "$currentmatrix" != "1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000" ]; then
 		# Rotate every instance of Touchscreen, this will workaround the ambiguity warning problem
 		# that arise when calling xinput on "Goodix Capacitive Touchscreen"
-		xinput set-prop $id "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1
+		xinput set-prop $id "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
 
 		currentmatrix=$(echo -e $(xinput list-props $id | grep 'Coordinate Transformation Matrix' | cut -d ':' -f2))
 		#echo "Done. Current matrix: $currentmatrix"
```

## 全体的な感想

持ち出し用ssh使える端末としては十分以上。ハードウェアの工作精度は高く、キーボードもこのサイズとしては驚異的な違和感のなさだ。記号類はすこしだけひっかかる。動作にはちょっと不安がある。時々タッチパネルが効かなくなったり、スリープからなかなか復帰しなかったり。

この記事はGPD Pocketで書いてみた。ちょっと不便さはあるものの特に問題はなかった。
