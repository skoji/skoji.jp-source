---
layout: post
title: 『ゼロからのOS自作入門』Rustで5章までやった記録
date: '2021-04-18T12:51:37+09:00'
categories:
- ソフトウェア開発
- Rust
- LowLevel
- MikanOS
---

<figure>
<img style="max-width: 60%" src='/blog/images/laranja_on_gpd_pocket.jpg' alt='GPD Pocketでの動作。'>
<figcaption>GPD Pocketでは横倒しになるのをなんとかしたい</figcaption>
</figure>

先月発売された[『ゼロからのOS自作入門』](https://book.mynavi.jp/ec/products/detail/id=121220)（通称みかん本）を読みながら、[Rustで実装してみている](https://github.com/skoji/laranja-os)。途中まではrmikanと呼んでいたけれど、自分のやる気を出すためにLaranjaOSと名付けた。laranjaはポルトガル語でオレンジの意味だ。

3月22日の発売日によみはじめて、ほぼ4週間でようやく[5章相当のところまでできた](https://github.com/skoji/laranja-os/tree/osbook_day05f)。Consoleの実装を行い、`print`マクロも実装した。[MikanOS](https://github.com/uchan-nos/mikanos)に合わせてtagをつけているが、試行錯誤が含まれているし、「Makefileを使ってみる」のような部分は飛ばしている。

以下、ここまで実装する上での試行錯誤をメモしておく。

### UEFIアプリケーション

みかん本2章ではEDKⅡを使ってUEFIのアプリケーションをCで実装する。私はRustのUEFI API wrapperである[uefi-rs](https://github.com/rust-osdev/uefi-rs)を利用した。これを使えば、UEFIアプリを書くこと自体はかなり簡単になる。ただ、みかん本2.6「メモリマップのファイルへの保存」で出てくる`OpenProtocol`がuefi-rsには実装されておらず、UEFIなにも知らないのでそこでしばらく引っかかった。uefi-rsではLocateProtocolが実装されているので、それが利用できた。

### kernelのビルドで停滞

3章からは別途ビルドしたkernelを読み込むところから始まる。これにかなりハマった。

#### `image-base`の設定ができないなど、リンカ設定ができない

そもそもldにどうやって渡せるかわからないところからのスタートだった。ここにずいぶん時間を使ったが、LLVM 11のld.lldを使うことで、macOSでもLinuxでも動作するようになった。最終的には全ての設定を[カスタムターゲット](https://github.com/skoji/laranja-os/blob/0f574072dc3b69cae84304bb04be1d877f3201f2/kernel/x86_64-unknown-none-mikankernel.json)に入れた。

#### 呼び出せない

`asm!("hlt")`だけのkernelもUEFIアプリから呼び出せない。ここにもかなり時間を使って、途中で投げ出しそうになった。が、わかってしまえば簡単だった。targetがx86_64-unknown-uefiだと、`extern "C"`がUEFIのABI(= WindowsのABI)になってしまう。このため、普通に`extern "C"`にしたカーネルのentryが呼び出せない。`extern "sysv64"`にするか、kernelのentry pointを`extern "efiabi"`にすると動く。私は`extern "sysv64"`にしている。

### kernelが動くようになってから

#### placement new （配置new）

みかん本4.3「C++の機能を使って書き直す」ではピクセル書き込みのクラスを、配置newを使ってstaticな領域に置く。この時点では必ずしも必要ないので私は実装せずに済ませていたが、`print`マクロ実装時にはstaticなstructが必要になった。しかし、Rustには配置newに相当するものはない。

当初は`[u8; size_of::<TheStruct>]`の`static mut`な変数にコピー[していた](https://github.com/skoji/laranja-os/commit/5af9d38d53432e6d3eff6ada51cf8437a4d7100f)が、Mastodonで教えてもらったMaybeUninitを使うように[変更した](https://github.com/skoji/laranja-os/commit/136199dc4276219f2315aa551932836a83011a17)。

#### sprintfは実装していない

みかん本5.4「文字列描画とsprintf()」のsprintfは現時点では実装していない。Stringが使える環境ならwriteln!を使えば済むが、nostdでアロケータもないのでStringが存在しない。現時点では、文字の位置や色を指定したWriterを`writeln!`で使うか、`Console`クラスを使った`println!`は実装しているが、文字列にフォーマットして書き込むものはない。

#### フォント

みかん本5.3「フォントを増やそう」では、ASCIIのビットマップのテキストファイルからオブジェクトファイルを生成してリンクする方法をとっている。私は元のビットマップを描いたテキストファイルをsedなどで変形した上で[Rustのコード](https://github.com/skoji/laranja-os/blob/db717ebed22d2f516408ece1ff5d9e02a4f0b575/kernel/src/ascii_font.rs)に変換して、それを使っている。

### これから

みかん本6章は「マウス入力とPCI」。ここのUSBドライバは、著者提供のものをそのまま使うことになっているが、フルRustでやるつもりならそれはイチから書く必要がある。さすがにそれはキツそうだ…と思ったら、[先人がすでにいた](https://twitter.com/algon_320/status/1380466521592360961?s=21)。参考書として挙げられていた[『USB3.0ホストドライバ自作入門』](https://booth.pm/ja/items/1056355)は、みかん本著者による技術同人誌だ。私も自分で書く努力をしてみるつもりだ。rust-osdevの[xhci](https://github.com/rust-osdev/xhci)クレートも利用できるかもしれない。

Rust + nostd環境だと厳しい話が他にも出てきそうだけれども、可能な限り自力でやっていこうと思っている。







