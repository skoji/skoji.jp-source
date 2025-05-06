---
layout: post
title: Blender 4日目： 雪だるまモデリング終了
date: '2021-12-04T17:03:26+09:00'
categories:
- blender
- ひとりアドベントカレンダー
---

[CG制作演習資料](http://web.wakayama-u.ac.jp/~tokoi/cgpe2020.html)を読みながらのよちよちBlender4日目、雪だるまをさわるのは今日でおしまい。

![](/blog/images/snowman-rendered-m.jpg)

まずは背景に全天球画像を使うところから。実際の演習時には全天球画像が提供されるのだろうが、当然この資料に含まれているはずもなく、まずここで手が止まる。数年前にTHETAで撮影した、善福寺川の画像を発掘して使った。解像度は低めだし、手持ちなので中心位置がだいぶ高い。こういうのをBlenderの素材にするときは、撮影位置も考えたほうがよさそうだ。


そのあとは、Material Propertiesをいじっていろいろ質感を変える操作が続く。メタリックにしてみたり、透明度をあげてガラスのようにしてみたり。つるつるにしてみたり、マットな質感にしてみたり。鏡面や透明にすると、ちゃんと背景画像が適切に反射されたり屈折・透過されたりして楽しい。eeveeというレンダリングエンジンは高速で、ぐりぐりまわしても追従してくる。よりきっちりレンダリングするCyclesは、リアルタイムのプレビューで使うとノイズが載るし、Render Imageするとこの程度のモデルでも30秒前後かかる。

![](/blog/images/snowman-rendered-g.jpg)

いまのBlenderではM1なMacでGPUレンダリングが使えないが、[Blender 3.1ではMetalがサポートされる](http://www.cgchannel.com/2021/10/blender-3-1-to-get-apple-developed-metal-backend-for-cycles/)とのことで、そうなるとずいぶん速くなるのではないかと期待している。[来年3月リリース予定](https://developer.blender.org/project/view/135/)。

