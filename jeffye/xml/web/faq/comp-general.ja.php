<?
$title = "F.A.Q. - コンパイル (1)";
$cvs_author = 'Author: babayoshihiko';
$cvs_date = 'Date: 2004/03/12 13:44:49';
$metatags = '<link rel="contents" href="index.php?phpLang=ja" title="F.A.Q. Contents"><link rel="next" href="comp-packages.php?phpLang=ja" title="コンパイルの問題 - 特定のバージョン"><link rel="prev" href="usage-fink.php?phpLang=ja" title="Fink のインストール、使用、メンテナンス">';

include_once "header.inc";
?>

<h1>F.A.Q. - 6 コンパイルの問題 - 一般</h1>


<a name="compiler">
<div class="question"><p><b>Q6.1: configure スクリプトが "acceptable cc" が見つからないといってきます。
これは何ですか?</b></p></div>
<div class="answer"><p><b>A:</b> ドキュメンテーションを読んでください。
パッケージをソースからコンパイルするには、 Developer Tools が必要です。
これには、 C コンパイラ <code>cc</code> など必要なものが入っています。
</p></div>
</a>
<a name="cvs">
<div class="question"><p><b>Q6.2: "fink selfupdate-cvs" をしようとしたら、このメッセージが出てきました: "cvs: Command not found."
</b></p></div>
<div class="answer"><p><b>A:</b> Developer Tools をインストールする必要があります。</p></div>
</a>
<a name="missing-make">
<div class="question"><p><b>Q6.3: <code>make</code> に関連したエラーがでました。</b></p></div>
<div class="answer"><p><b>A:</b> もしメッセージが以下のようであれば</p><pre>make: command not found</pre><p>あるいは</p><pre>Can't exec "make": No such file or directory at /sw/lib/perl5/Fink/Services.pm line 190.</pre><p>Developer Tools をインストールする必要があります。</p><p>もしメッセージが以下のようであれば</p><pre>make: illegal option -- C</pre><p>
Developer Tools に入っていた GNU 版の <code>make</code> ユーティリティーを、 BSD 版の make に換えてしまったようです。
パッケージの中には GNU 版の make でのみサポートされている特殊機能に依存しているものも多いので、 
<code>/usr/bin/make</code> が <code>gnumake</code> のシンボリックリンクであることを確認してください。
<code>bsdmake</code> ではありません。
さらに、 <code>/usr/local/bin/</code> に他の <code>make</code> がないことも確認してください。
</p></div>
</a>
<a name="head">
<div class="question"><p><b>Q6.4: head コマンドから変な使用方法メッセージが出ています。何がおかしいのですか?</b></p></div>
<div class="answer"><p><b>A:</b> もしこれでしたら:</p><pre>Unknown option: 1
Usage: head [-options] &lt;url&gt;...</pre><p>(後にオプションの説明リストが続く)
<code>head</code> が壊れています。
これは Perl libwww ライブラリを HFS+ システムボリュームにインストールすると起こります。
この時 <code>/usr/bin/HEAD</code> をインストールしようとするのですが、このファイルシステムは大文字と小文字を区別しないので、 <code>head</code> を上書きしてしまいます。
<code>head</code> の方はシェルスクリプトや Makefile で良く使われる標準的なコマンドです。
Fink を使うには、オリジナルの方の <code>head</code> に戻す必要があります。</p><p>ソースリリースのブートストラップスクリプトは、現在はこれを確認しますが、最初のインストールにバイナリリリースを使う場合、あるいは Fink をインストールした後で libwww をインストールする場合、まだこの問題に当たります。</p><p>この問題は、 <code>/sw/bin/HEAD</code> をインストールした場合も起こることが報告されています (Fink のパッケージではありません)。
これは簡単に解決できます: rename <code>/sw/bin/HEAD</code> </p></div>
</a>
<a name="also_in">
<div class="question"><p><b>Q6.5: あるパッケージをインストールしようとすると、他のパッケージのファイルを上書きしようとしているというエラーメッセージが出ました。
</b></p></div>
<div class="answer"><p><b>A:</b> これはスプリットオフパッケージ (-dev, -shlibs などがついてるもの) において、ファイルが移動する時 (<code>foo</code> から <code>foo-shlibs</code> など) に発生することがあります。
両者は実質同じものなので、インストールしようとしているパッケージから上書きしてしまっても良いでしょう:
</p><pre>sudo dpkg -i --force-overwrite <b>filename</b>
</pre><p>ここで <b>filename</b> はインストールしようとしているパッケージ用の .deb ファイルです。</p></div>
</a>
<a name="weak_lib">
<div class="question"><p><b>Q6.6: December 2002 Development Tools をインストールしてから、このメッセージが出るようになった: I get messages about "weak libraries"</b></p></div>
<div class="answer"><p><b>A:</b> これは December 2002 Tools のものです。
次のようなメッセージが出ることがあります (libgdk-pixbuf を例に選んでいます):</p><p>
<code>ld: warning dynamic shared library: /sw/lib/libgdk-pixbuf.dylib not made a weak library in output with MACOSX_DEPLOYMENT_TARGET environment variable set to: 10.1</code>
</p><p>これは実害はないといえます。
興味があれば、開発用ドキュメンテーションディレクトリの、特に GCC とリンカの、リリースノートをお読みください。
本質的には、弱い参照を使用するアプリケーションが、起動時に実行時の存在しないシンボルを致命的エラーとみなすかどうかに関わってきます。</p></div>
</a>
<a name="mv-failed">
<div class="question"><p><b>Q6.7: パッケージをインストールしようとした時の "execution of mv failed, exit code 1" とはどういう意味ですか?</b></p></div>
<div class="answer"><p><b>A:</b> StuffIt Pro がインストールされている場合、 "Archive Via Real Name" モードが設定されていると思われます。
システム環境設定の StuffIt 設定で "ArchiveViaRealName" を無効化してください。
これはいくつかの重要なシステムコールのバ再実装のバグで、この件のような不思議なエラーをたくさん出します。</p><p>この問題でない場合、 <code>mv</code> のエラーは通常、ビルドの前の方で発生した別のエラーを意味しています。
エラーは発生したもののビルドは続行したものです。
問題のあったファイルを追跡するには、ビルドの出力中の存在しないファイルを探します。
例えば:</p><pre>mv /sw/src/root-foo-0.1.2-3/sw/lib/libbar*.dylib \
 /sw/src/root-foo-shlibs-0.1.2-3/sw/lib/
 mv: cannot stat `/sw/src/root-foo-0.1.2-3/sw/lib/libbar*.dylib':
 No such file or directory
### execution of mv failed, exit code 1
Failed: installing foo-0.1.2-3 failed</pre><p>この場合、 <code>libbar</code> ファイルをビルド出力の前の方で探します。</p></div>
</a>
<a name="node-exists">
<div class="question"><p><b>Q6.8: '"node" already exists' というエラーメッセージが出て、インストール | アップデートができません。</b></p></div>
<div class="answer"><p><b>A:</b> このようなエラーが出ます:</p><pre>Failed: Internal error: node for system-xfree86 already exists</pre><p>パッケージ info ファイルが変更されて依存性エンジンが混乱しているために出た問題です。
修正するには:</p><ul>
<li>
<p>問題のあるパッケージを強制削除する。上の例の場合は:</p>
<pre>sudo dpkg -r --force-all system-xfree86</pre>
</li>
<li>
<p>再びインストール | アップグレードする。
途中、削除したパッケージの "virtual dependency" のプロンプトが出てくるので、これを選択する。
こうするとビルド中に再インストールされる。</p>
</li>
</ul></div>
</a>
<a name="usr-local-libs">
<div class="question"><p><b>Q6.9: /usr/local/lib にインストールされているライブラリが Fink のビルドの問題を起こすことがあると聞いたけど、本当ですか?</b></p></div>
<div class="answer"><p><b>A:</b> そういう場合もよくあります。
これは、パッケージの configure スクリプトは Fink のパスより先に <code>/usr/local/lib</code> の中を検索するからです。
もし問題が発生して、他の FAQ で解決ができそうになければ、 <code>/usr/local/lib</code> のライブラリを確認してください。
これが原因そうであれば、 <code>/usr/local</code> の名前を一時的に変えてください。
例えば:</p><pre>sudo mv /usr/local /usr/local.moved</pre><p>ビルド後、 <code>/usr/local</code> を元に戻しください:</p><pre>sudo mv /usr/local.moved /usr/local</pre></div>
</a>
<a name="toc-out-of-date">
<div class="question"><p><b>Q6.10: パッケージをビルドしようとしたら、 "table of contents" が古いというメッセージが出ました。何をしたらいいですか?
</b></p></div>
<div class="answer"><p><b>A:</b> このメッセージは重要なヒントです。
メッセージはこのようなものだと思われます:</p><pre>ld: table of contents for archive: /sw/lib/libintl.a is out of date; rerun ranlib(1) (can't load from it)</pre><p>この問題を起こしているライブラリに (root で) ranlib を実行する必要があります。
例えば、この例では:</p><pre>sudo ranlib /sw/lib/libintl.a</pre></div>
</a>
<a name="fc-atlas">
<div class="question"><p><b>Q6.11: atlas をインストールしようとすると、 Fink Commander がハングアップします。</b></p></div>
<div class="answer"><p><b>A:</b> <code>atlas</code> のビルド中にユーザーにプロンプトを送るステップがあり Fink Commander がこれを表示しないからです。
代わりに <code>fink install atlas</code> とする必要があります。</p></div>
</a>
<a name="basic-headers">
<div class="question"><p><b>Q6.12: stddef.h が見つからないというメッセージが出ます。
これはどこにありますか?</b></p></div>
<div class="answer"><p><b>A:</b> このヘッダは Developer Tools の DevSDK によって提供されるファイルです。
<code>/Library/Receipts/DevSDK.pkg</code> がシステムにあるか確認し、なければ  Dev Tools インストーラを起動してカスタムインストールを選択、 DevSDK パッケージをインストールして下さい。</p></div>
</a>
<a name="multiple-dependencies">
<div class="question"><p><b>Q6.13: Fink が "unable to resolve version conflict on multiple dependencies" と言って、アップデートできません。</b></p></div>
<div class="answer"><p><b>A:</b> この問題を解決するには、パッケージを一つだけアップデートしてみてください。
次に、再度 "fink update-all" を試してみてください。
まだ問題が出るようなら、これを繰り返してください。
</p></div>
</a>
<a name="dpkg-parse-error">
<div class="question"><p><b>Q6.14: "dpkg: parse error, in file `/sw/var/lib/dpkg/status'"
というメッセージが出て、何もインストールできません!</b></p></div>
<div class="answer"><p><b>A:</b> これは dpkg データベースが壊れてしまったか、クラッシュか他のリカバーできないエラーが原因です。
以前のバージョンのデータベースをコピーして直すことができます:</p><pre>
sudo cp /sw/var/lib/dpkg/status-old /sw/var/lib/dpkg/status
</pre><p>この問題が起きた最後の二つのパッケージを再インストールしたほうがよいでしょう。</p></div>
</a>
<a name="freetype-problems"> 
<div class="question"><p><b>Q6.15: freetype に関係したエラーが出ます。</b></p></div> 
<div class="answer"><p><b>A:</b> freetype に関係したエラーにはいくつかありますが、もしこのようなものであれば:</p><pre>/sw/include/pango-1.0/pango/pangoft2.h:52: error: parse error before '*' token 
/sw/include/pango-1.0/pango/pangoft2.h:57: error: parse error before '*' token 
/sw/include/pango-1.0/pango/pangoft2.h:61: error: parse error before '*' token 
/sw/include/pango-1.0/pango/pangoft2.h:86: error: parse error before "pango_ft2_font_get_face"
/sw/include/pango-1.0/pango/pangoft2.h:86: warning: data definition has no type or storage class 
make[2]: *** [rsvg-gz.lo] Error 1 
make[1]: *** [all-recursive] Error 1 
make: *** [all-recursive-am] Error 2 
### execution of make failed, exit code 2 
Failed: compiling librsvg2-2.4.0-3 failed</pre><p>あるいは</p><pre>In file included from vteft2.c:32: 
vteglyph.h:64: error: parse error before "FT_Library"
vteglyph.h:64: warning: no semicolon at end of struct or union 
vteft2.c: In function `_vte_ft2_get_text_width': 
vteft2.c:236: error: dereferencing pointer to incomplete type 
vteft2.c: In function `_vte_ft2_get_text_height': 
vteft2.c:244: error: dereferencing pointer to incomplete type 
vteft2.c: In function `_vte_ft2_get_text_ascent': 
vteft2.c:252: error: dereferencing pointer to incomplete type 
vteft2.c: In function `_vte_ft2_draw_text': 
vteft2.c:294: error: dereferencing pointer to incomplete type 
vteft2.c:295: error: dereferencing pointer to incomplete type 
make[2]: *** [vteft2.lo] Error 1 
make[1]: *** [all-recursive] Error 1 
make: *** [all] Error 2 
### execution of make failed, exit code 2 
Failed: compiling vte-0.11.10-3 failed</pre><p>あるいは</p><pre>checking for freetype-config... /usr/X11R6/bin/freetype-config 
checking For sufficiently new FreeType (at least 2.0.1)... no 
configure: error: pangoxft Pango backend found but did not find freetype libraries 
make: *** No targets specified and no makefile found.  Stop. 
### execution of LD_TWOLEVEL_NAMESPACE=1 failed, exit code 2 
Failed: compiling gtk+2-2.2.4-2 failed</pre><p>問題は X11 | XFree86 に含まれている、 <code>freetype</code> | <code>freetype-hinting</code> パッケージ間のヘッダを混同していることだと思われます。</p><pre>fink remove freetype freetype-hinting</pre><p>で、両方のインストールを削除します。
もし問題が上記のようではなく、以下のようであれば:</p><pre>ld: Undefined symbols: 
_FT_Access_Frame </pre><p>おそらく X11 インストールの残りファイルが原因です。
X11 SDK を再インストールしてみて下さい。
エラーが以下のようであれば:</p><pre>dyld: klines Undefined symbols: 
/sw/lib/libqt-mt.3.dylib undefined reference to _FT_Access_Frame </pre><p>おそらく Jaguar 上で<code>gcc3.3</code> でコンパイルしたバイナリが  Panther 上で動作しないためです。
この問題は既に修正されていますので、<code>sudo apt-get update ; sudo apt-get dist-upgrade</code> と更新するだけで直ります。</p></div> 
</a> 
<a name="dlfcn-from-oo"> 
<div class="question"><p><b>Q6.16: `Dl_info' のエラーが出ます。</b></p></div> 
<div class="answer"><p><b>A:</b> エラーが下記のようであれば:</p><pre>unix_dl.c: In function `rep_open_dl_library': 
unix_dl.c:328: warning: assignment discards qualifiers from pointer target type 
unix_dl.c: In function `rep_find_c_symbol': 
unix_dl.c:466: error: `Dl_info' undeclared (first use in this function) 
unix_dl.c:466: error: (Each undeclared identifier is reported only once 
unix_dl.c:466: error: for each function it appears in.) 
unix_dl.c:466: error: parse error before "info"
unix_dl.c:467: error: `info' undeclared (first use in this function) 
make[1]: *** [unix_dl.lo] Error 1</pre><p>おそらくヘッダファイル <code>/usr/local/include/dlfcn.h</code> が Panther と非互換だと思われます。
迷うことなく削除して下さい。</p><p>このファイルは通常、 Open Office によってインストールされるようです。
この後、次のヘッダファイルとライブラリ
<code>/usr/local/lib/libdl.dylib</code> を Panther に付随するファイルへのシンボリックリンクに変更します。</p><pre>sudo ln -s /usr/include/dlfcn.h /usr/local/include/dlfcn.h 
sudo ln -s /usr/lib/libdl.dylib /usr/local/lib/libdl.dylib</pre></div> 
</a>
<a name="gcc2"> 
<div class="question"><p><b>Q6.17: Fink が <code>gcc2</code> がないと言っていますが、インストールも出来ないようです。</b></p></div> 
<div class="answer"><p><b>A:</b> 
<code>gcc2</code> は gcc-2.95 のバーチャルパッケージです。
gcc2.95 を XCode Tools (古い OS バージョンは Developer Tools に gcc-2.95 が含まれていました) からインストールして下さい。</p></div>
</a>
<p align="right">
Next: <a href="comp-packages.php?phpLang=ja">7 コンパイルの問題 - 特定のバージョン</a></p>

<? include_once "footer.inc"; ?>
