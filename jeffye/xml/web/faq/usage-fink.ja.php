<?
$title = "F.A.Q. - Fink の使用方法";
$cvs_author = 'Author: babayoshihiko';
$cvs_date = 'Date: 2004/03/12 13:44:49';
$metatags = '<link rel="contents" href="index.php?phpLang=ja" title="F.A.Q. Contents"><link rel="next" href="comp-general.php?phpLang=ja" title="コンパイルの問題 - 一般"><link rel="prev" href="upgrade-fink.php?phpLang=ja" title="Fink のアップグレード (バージョン固有の問題対処法)">';

include_once "header.inc";
?>

<h1>F.A.Q. - 5 Fink のインストール、使用、メンテナンス</h1>


<a name="what-packages">
<div class="question"><p><b>Q5.1: Fink がサポートしているパッケージはどのように探せますか?</b></p></div>
<div class="answer"><p><b>A:</b> Fink 0.2.3 以降は、 <code>list</code> コマンドがあります。
このコマンドは、あなたの Fink 環境の管理している全てのパッケージのリストを作成します。
例:
</p><pre>fink list</pre><p>バイナリ・ディストリビューションを使っている場合、 <code>dselect</code> でパッケージリストを閲覧することができます。
dselect からパッケージを選択してインストールする場合、 root 権限が必要ですので注意して下さい。</p><p>または、本サイトに <a href="http://fink.sourceforge.net/pdb/">パッケージ・データベース</a> もあります。
</p></div>
</a>
<a name="proxy">
<div class="question"><p><b>Q5.2: ファイヤーウォールの内側にいます。どう設定したら Fink で HTTP プロキシが使えますか?</b></p></div>
<div class="answer"><p><b>A:</b> 
<code>fink</code> コマンドは、明示的にプロキシを設定できます。
この設定は <code>wget</code>/<code>curl</code> に渡されます。
新規インストール時に聞かれなかった場合、または設定し直したい場合、 <code>fink configure</code> を実行することができます。
もしインストールガイドを読み、 <code>/sw/bin/init.csh</code> (または <code>/sw/bin/init.sh</code>) を使ったなら、次のようにプロキシの前にプロトコルをつけるようにして下さい。</p><pre>ftp://proxy.yoursite.somewhere</pre><p>もしこれでも問題があるようなら、システム環境設定からネットワークを選択し、プロキシのタブをクリックし、 "Use Passive FTP Mode (PASV)" がチェックされているか確認して下さい。</p></div>
</a>
<a name="firewalled-cvs">
<div class="question"><p><b>Q5.3: ファイヤーウォールの内側から CVS でパッケージをアップデートするにはどうしたらいいですか?</b></p></div>
<div class="answer"><p><b>A:</b> パッケージ <b>cvs-proxy</b> は HTTP プロキシを介して通ります。</p><ul>
<li>
<p>まず、  <a href="http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/fink/dists/10.2/unstable/main/finkinfo/devel/">cvs-proxy</a> ファイル (.info と a .patch) をダウンロードし、ローカルツリー ( /sw/fink/dists/local/main/finkinfo/) に入れる。</p>
</li>
<li>
<p><b>cvs-proxy</b> パッケージを、次のコマンドでインストールする:</p>
<p>
<code>fink install <b>cvs-proxy</b>
</code>
</p>
</li>
<li>
<p>パッケージを次のコマンドでアップデートする:</p>
<p>
<code>fink selfupdate-cvs</code>
</p>
<p>
<code>fink update-all</code>
</p>
</li>
</ul><p>fink がプロキシを使うように設定されていなかったら、設定を行ないます:</p><p>
<code>fink configure</code></p></div>
</a>
<a name="moving">
<div class="question"><p><b>Q5.4: インストール後に Fink を他の場所に移動できますか?</b></p></div>
<div class="answer"><p><b>A:</b> 
できません。
もちろん、 mv やファインダからファイルを動かすことはできますが、 99% の確率で動かなくなるプログラムがでてきます。
これは、全ての Unix ソフトウェアはファイルやライブラリなどを検索するのに、ハードコードのパスに依存しているからである。
</p></div>
</a>
<a name="moving-symlink">
<div class="question"><p><b>Q5.5: Fink をインストール後、他の場所に移動してシンボリックリンクを張ったら、動きますか?</b></p></div>
<div class="answer"><p><b>A:</b> 
動くかも知れない。
動くと予想されますが、どこに落し穴があるかわかったものじゃありません。
</p></div>
</a>
<a name="removing">
<div class="question"><p><b>Q5.6: Fink を全てアンインストールするには?</b></p></div>
<div class="answer"><p><b>A:</b> Fink でインストールしたファイルはほとんど /sw (あるいはインストール時に選択した場所) にあります。
なので、 Fink を削除するには、通常このコマンドを入力します:</p><pre>sudo rm -rf /sw</pre><p>唯一の例外は XFree86 です。もし XFree86 を Fink でインストールした (<code>xfree86</code> または
<code>xfree86-rootless</code> パッケージ) なら、次のコマンドも必要です:
</p><pre>sudo rm -rf /usr/X11R6 /etc/X11 /Applications/XDarwin.app</pre><p>Fink をインストールし直すことがないのでしたら、テキストエディタを使い、 <code>.cshrc</code> ファイルの中の "<code>source /sw/bin/init.csh</code>" と書かれている行、あるいは <code>.bashrc</code> ファイルの中の "<code>source /sw/bin/init.sh</code>" と書かれている行を削除して下さい。</p></div>
</a>
<a name="bindist">
<div class="question"><p><b>Q5.7: ウェブのパッケージデータベースは、パッケージ xxx を表示しているのに、 apt-get と dselect は何もしない。どっちが嘘をついてるのですか?
</b></p></div>
<div class="answer"><p><b>A:</b> 
どちらも正しいです。
パッケージデータベースは unstable セクションにあるものも含め、全てのパッケージを管理します。
<code>dselect</code> と <code>apt-get</code> は、コンパイル済みバイナリパッケージしか関与しません。
パッケージがコンパイルされないのは様々な理由があります。
パッケージがコンパイルするかどうかを判定するには、まず最新リリースの "stable" セクションになければなりません。 更にポリシーに合っているか、ライセンスや知的所有権を侵していないかチェックされます。</p><p><code>dselect</code> / <code>apt-get</code> が対応していないパッケージをインストールする場合、 <code>fink install <b>packagename</b></code> を使ってソースからコンパイルします。
このコマンドを実行する前に、 Developer Tools がインストールされているか確認して下さい。
(Developer Tools インストーラがない場合、 <a href="http://connect.apple.com/">Apple Developer Connection</a> で登録後、入手して下さい)
下記の unstable に関する質問も合わせて参照して下さい。
</p></div>
</a>
<a name="unstable">
<div class="question"><p><b>Q5.8: unstable にあるパッケージをインストールしようとすると、 fink が 'no package found' といいます。どうしたらインストールできるのですか?</b></p></div>
<div class="answer"><p><b>A:</b> まず、 'unstable' の意味を理解して下さい。
unstable ツリーにあるパッケージは通常一人以上にはテストされていません。
このため、 Fink はデフォルトでは unstable ツリーを検索するようにはなっていません。
unstable を使用する場合、何か上手くいったら（上手くいかなかっても）メンテナにメールを送るのを忘れないで下さい。
あなたのようなユーザーからのフィードバックが、 stable にするかどうかの判定材料なのです!
メンテナの情報は <code>fink info &lt;packagename&gt;</code> で取得できます。</p><p>パッケージには依存性があり、 unstable にあるパッケージは unstable にある他のパッケージに依存していることも多いのです。
このため、全ての unstable を更新するのが最適です。</p><p>Fink が unstable を使うようにするには、 <code>/sw/etc/fink.conf</code> ファイルの <code>Trees:</code> の行に <code>unstable/main</code> と <code>unstable/crypto</code> を追加します。
この後、 <code>fink selfupdate; fink index</code> を実行します。
</p><p>unstable のパッケージのうち、一つか小数だけ使用したいのであれば、 CVS アップデート (<code>fink selfupdate-cvs</code>) に切替えます。デフォルトの rsync は <code>fink.conf</code> にあるツリーしかアップデートしないからです。
次に、<code>/sw/etc/fink.conf</code> ファイルの <code>Trees:</code> の行に <code>local/main</code> を追加します。
次に、 <code>.info</code> ファイルと <code>.patch</code> ファイルを <code>/sw/fink/dists/unstable/main/finkinfo</code> (または <code>/sw/fink/dists/unstable/crypto/finkinfo</code>) から、 <code>/sw/fink/dists/local/main/finkinfo</code> にコピーします。
注意すべきことは、依存しているパッケージ (または特定のバージョン) も unstable にある可能性があり、これらのパッケージの <code>.info</code> と <code>.patch</code> もコピーしなければなりません。
すべてのファイルをコピーしたら、 <code>fink index</code> を実行します。
これで Fink のパッケージリストがアップデートされます。
この後、 rsync に戻したい場合、 <code>fink selfupdate-rsync</code> を実行します。</p></div>
</a>

<a name="sudo">
<div class="question"><p><b>Q5.9: sudo でパスワードを何度も何度も入力するのは疲れます。何か良い方法はありませんか?</b></p></div>
<div class="answer"><p><b>A:</b> sudo がパスワードを聞いてこないように設定することができます。
root 権限で <code>/etc/sudoers</code> を開き、次の行を追加します:</p><pre>username ALL = NOPASSWD: ALL</pre><p>もちろん、 <code>username</code> は実際のユーザー名に変えて下さい。</p></div>
</a>
<a name="exec-init-csh">
<div class="question"><p><b>Q5.10: init.csh or init.sh を実行しようとすると、 "Permission denied" エラーが出ます。
何がおかしいのですか?</b></p></div>
<div class="answer"><p><b>A:</b> init.csh と init.sh は通常のコマンドのように実行するものではありません。
これらのファイルは環境変数の PATH や MANPATH を設定するものです。
これをシェルに保持させるには、csh/tcsh では <code>source</code> コマンド、bash/zsh では <code>.</code> コマンドを使い:</p><p> csh/tcsh の場合:</p><pre>source /sw/bin/init.csh</pre><p> bash の場合:</p><pre>. /sw/bin/init.sh</pre><p>と入力します。</p></div>
</a>
<a name="dselect-access">
<div class="question"><p><b>Q5.11: うぎゃ! dselect で "[A]ccess" メニューを使ったら、パッケージをダウンロードできなくなった!</b></p></div>
<div class="answer"><p><b>A:</b> 
おそらく、 apt を Debian ミラーを指定したのでしょう。
当然、 Debian ミラーには Fink ファイルはありません。
これを直す方法には、手動と dselect を通す二通りがあります。
手動では、 root 権限で <code>/sw/etc/apt/sources.list</code> ファイルを開き、 debian.org の行を削除して:
</p><pre>deb http://us.dl.sourceforge.net/fink/direct_download release main crypto
deb http://us.dl.sourceforge.net/fink/direct_download current main crypto</pre><p>に置き換えます (日本では <code>jp.dl.sourceforge.net</code>) 。</p><p>dselect を通すには、再度 "[A]ccess" を実行し、 "apt" を選択して:</p><p>
URL: http://us.dl.sourceforge.net/fink/direct_download -
Distribution: release -
Components: main crypto
</p><p>と入力します。
他の source を追加するならば、  "release" の部分を "current" と変えて繰り返して下さい。
</p><p>現在、 apt パッケージの修正版 (設定スクリプトが dselect のプラグインとして付随) が CVS から入手できます。</p></div>
</a>
<a name="cvs-busy">
<div class="question"><p><b>Q5.12: <q>fink selfupdate</q> か "fink selfupdate-cvs" を実行しようとした時、  "<code>Updating using CVS failed. Check the error messages above.</code>" エラーが出ました。</b></p></div>
<div class="answer"><p><b>A:</b> メッセージが、</p><pre>Can't exec "cvs": No such file or directory at
/sw/lib/perl5/Fink/Services.pm line 216, &lt;STDIN&gt; line 3.
### execution of cvs failed, exit code -1</pre><p>であれば、 Developer Tools をインストールする必要があります。</p><p>もし最後の行が、</p><pre>### execution of su failed, exit code 1</pre><p>であれば、エラーを詳細に見る必要があります。
もし接続が拒否されたとあれば:</p><pre>(Logging in to anonymous@cvs.sourceforge.net)
CVS password:
cvs [login aborted]: connect to cvs.sourceforge.net:2401 failed:
Connection refused
### execution of su failed, exit code 1
Failed: Logging into the CVS server for anonymous read-only access failed.</pre><p>あるいは</p><pre>cvs [update aborted]: recv() from server cvs.sourceforge.net:
Connection reset by peer
### execution of su failed, exit code 1
Failed: Updating using CVS failed. Check the error messages above.</pre><p>あるいは</p><pre>cvs [update aborted]: End of file received from server</pre><p>あるいは</p><pre>cvs [update aborted]: received broken pipe signal</pre><p>であれば、 cvs サーバが過負荷になっていると思われますので、時間をおいてアップデートを試してみて下さい。</p><p>この他、パーミッションをもっていない可能性もあります。
この場合は "Permission denied" メッセージ:</p><pre>cvs update: in directory 10.2/stable/main:
cvs update: cannot open CVS/Entries for reading: No such file or directory
cvs server: Updating 10.2/stable/main
cvs update: cannot write 10.2/stable/main/.cvsignore: Permission denied
cvs [update aborted]: cannot make directory 10.2/stable/main/finkinfo: No such file or directory
### execution of su failed, exit code 1
Failed: Updating using CVS failed. Check the error messages above.
</pre><p>が出ます。この場合は cvs ディレクトリをリセットする必要があります。コマンド:</p><pre>sudo find /sw/fink -type d -name 'CVS' -exec rm -rf {} \;
fink selfupdate-cvs</pre><p>を入力して下さい。</p><p>以上のいずれのメッセージとも異なる場合、おそらく /sw/fink/dists 内のファイルを、あなたとメンテナの双方が書き換えたためです。
selfupdate-cvs の出力で、 "C" から始まる行で:</p><pre>C 10.2/unstable/main/finkinfo/libs/db31-3.1.17-6.info
...
(other info and patch files)
...
### execution of su failed, exit code 1
Failed: Updating using CVS failed. Check the error messages above.</pre><p>のようになっている箇所を探して下さい。
"C" というのは CVS で最新版へ更新時にコンフリクトがあったことを意味しています。</p><p>これを修正するには、 selfupdate-cvs の出力にでてきたファイルを一つずつ削除して、コマンドを再実行します。</p><pre>sudo rm /sw/fink/10.2/unstable/main/finkinfo/libs/db31-3.1.17-6.info
fink selfupdate-cvs</pre></div>
</a>
<a name="kernel-panics">
<div class="question"><p><b>Q5.13: Fink を使うと、マシンがフリーズする/カーネルパニックする/固まる。助けて!</b></p></div>
<div class="answer"><p><b>A:</b> 最近の
<a href="http://sourceforge.net/mailarchive/forum.php?forum=fink-users">fink-users mailing list</a>
の報告によると、こういった問題 (カーネルパニックやパッチ当て中の無限ループを含む) が発生するのはアンチウィルスソフトウェアがインストールされている時です。
Fink を使う際はアンチウィルスソフトウェアを終了する必要があるかもしれません。</p></div>
</a>
<a name="not-found">
<div class="question"><p><b>Q5.14: パッケージをインストールしようとすると、 Fink がダウンロードできません。
ダウンロードサイトとは Fink よりも新しいバージョンを示しています。
何をしたらいいですか?</b></p></div>
<div class="answer"><p><b>A:</b> 新しいバージョンのリリースにともない、本家サイトでのパッケージソースが移動しました。</p><p>最初にまず  <code>fink selfupdate</code> を実行して下さい。
メンテナが既に修正している場合、新しいバージョンか別のダウンロード URL のパッケージ詳細を取得できます。</p><p>もしこれでも問題が残るなら、ほとんどのソースは
<a href="http://distfiles.master.finkmirrors.net/">http://distfiles.master.finkmirrors.net/</a>
にある (Rob Braun 氏に感謝) ので、 <code>fink configure</code> を実行して "Master" ソースミラー を検索して下さい。
Fink が自動的にここを探しにいきます。
</p><p>これでも問題が残るなら、パッケージメンテナ
("<code>fink describe <b>packagename</b></code>" からわかります)
に URL が壊れている旨を知らせて下さい。
メンテナがいつでもメーリングリストを読んでいるとは限りません。</p><p>使えるソースを入手するには、まずは他のディレクトリ ("old" ディレクトリなど)  にあるリモートサイトの中で必要なバージョンを探して見て下さい。
もし公式サイトになければ、ウェブを検索してみて下さい。
非公式サイトに必要なバージョンの tarball が見つかることがあります。
他には <a href="http://us.dl.sourceforge.net/fink/direct_download/source/">http://us.dl.sourceforge.net/fink/direct_download/source/</a> があります。
ここは Fink がバイナリとしてリリースされたパッケージのソースファイルを保存する場所です。
いずれも駄目な場合、
<a href="http://sourceforge.net/mailarchive/forum.php?forum=fink-users">fink-users mailing list</a>
で古いソースをもっている人を探してみて下さい。
</p><p>Once you locate the proper source tarball, download it manually, and then move the file into your Fink source location (i.e. for a default Fink install,
もしソースの tarball が見つかったら、手動でダウンロードし、 Fink ソース保存先に移して下さい:
"<code>sudo mv <b>package-source.tar.gz</b> /sw/src/</code>"
この後、通常通り '<code>fink install <b>packagename</b></code>' して下さい。</p><p>ソースファイルが見つからない場合、メンテナが問題に対処するまで待つしかありません。
古いソースか、新しいバージョン用の .info と .patch ファイルへのリンクが投稿されることでしょう。</p></div>
</a>
<a name="fink-not-found">
<div class="question"><p><b>Q5.15: Fink や Fink でインストールしたものを実行しようとすると
"command not found" エラーが出ます。</b></p></div>
<div class="answer"><p><b>A:</b> 常にこのエラーが出るようでしたら、誤ってスタートアップスクリプトを書き換えてしまったと思われます。
<code>/sw/bin/pathsetup.command</code> スクリプトを実行
(ファインダからダブルクリックするか、ターミナルから実行)
すると、初期の設定を検出しようとします。
この後、新規ターミナルを開いて環境変数が読み込まれているか確認して下さい。</p><p>このエラーが Apple X11 ターミナルでのみ出る場合，
<a href="http://fink.sourceforge.net/doc/x11/run-xfree86.php#xinitrc%20">.xinitrc</a> 
というファイルを作成し、</p><pre>. /sw/bin/init.sh</pre><p>の一行を最初の方
(他のプログラムが実行される前)
に追加します。
X11 が立ち上がっている場合、リスタートします。</p><pre>source ~/.cshrc</pre></div>
</a>
<a name="invisible-sw">
<div class="question"><p><b>Q5.16: Finder で /sw を隠して、ユーザーが Fink の構成を壊すのを防ぎたい。</b></p></div>
<div class="answer"><p><b>A:</b> できます。
Development Tools がインストールされていれば、次のコマンドを実行してください:</p><pre>sudo /Developer/Tools/SetFile -a V /sw</pre><p>これで /sw が標準的なシステムのフォルダ (/usr など) のように不可視になります。
Developer Tools がない場合はサードパーティー製のアプリケーションで /sw が不可視になるよう、属性値を変更してください。</p></div>
</a>
<a name="install-info-bad">
<div class="question"><p><b>Q5.17: 何もインストールできません。
"install-info: unrecognized option `--infodir=/sw/share/info'"
のエラーが出るだけです。</b></p></div>
<div class="answer"><p><b>A:</b> これは普通、 PATH の問題です。ターミナルで:</p><pre>printenv PATH</pre><p>と入力し、 <code>/sw/sbin</code> が出てこないなら、環境変数を
<a href="http://fink.sourceforge.net/doc/users-guide/install.php#setup">instructions</a>
内の Users Guide を参照してください。
<code>/sw/sbin</code> があるが、他のディレクトリ (例えば /usr/local/bin) がそれより前にある場合、 PATH の順序を変えて先頭近くに移動するか、どうしても順序を変えられない理由があるならば、 Fink を使う時に Fink ではない方の <code>install-info</code> のファイル名を一時的に変える必要があります。</p></div>
</a>
<a name="bad-list-file">
<div class="question"><p><b>Q5.18: 何もインストールできないし、削除もできません。 "files list file" と出るだけです。</b></p></div>
<div class="answer"><p><b>A:</b> 通常、このエラーはこういう形で出ます:</p><pre>files list file for package <b>packagename</b> contains empty filename</pre><p>または</p><pre>files list file for package <b>packagename</b> is missing final newline</pre><p>This can be fixed, with a little work. If you have the .deb file for the offending package currently available on your system, then check its integrity by running
これは直すことができます。
エラーメッセージ中のパッケージの .deb ファイルがシステム上にあれば、その状態を確認します:
</p><pre>dpkg --contents <b>full-path-to-debfile</b>
</pre><p>例えば</p><pre>dpkg --contents /sw/fink/debs/libgnomeui2-dev_2.0.6-2_darwin-powerpc.deb</pre><p>ディレクトリやファイルの一覧が表示されたら、 .deb ファイルは大丈夫です。
もし出力されたのがファイルやディレクトリ以外であるか、 .deb ファイルがなくても、このエラーはビルドに影響しないので、次に進んでください。
</p><p>バイナリインストールを試みている場合、あるいはインストールしたバージョンと現在のバイナリバージョンが一致する場合
(例えば、 <a href="http://fink.sourceforge.net/pdb/index.php">パッケージデータベース</a> で調べたなら)、
.deb ファイルを取得することができます:
<code>sudo apt-get install --reinstall --download-only <b>packagename</b></code>
。あるいは、自分でビルドすることもできます:
<code>fink rebuild <b>packagename</b></code>
。この時点ではまだインストールはされていません。</p><p>.deb ファイルを作成したら、ファイルを再構築することができます。
まず、 root になるために <code>sudo -s</code> と入力します (必要があれば管理ユーザーパスワードを入力する) 。
次に、このコマンドを入力します (一行で - 画面上では複数行になっていますが)
</p><pre>dpkg -c <b>full-path-to-debfile</b>
  | awk '{if ($6 == "./"){ print "/."; } else if (substr($6, length($6), 1) == "/")
    {print substr($6, 2, length($6) - 2); } else { print substr($6, 2, length($6) - 1);}}'
  &gt; /sw/var/lib/dpkg/info/<b>packagename</b>.list</pre><p>例えば、</p><pre>dpkg -c /sw/fink/debs/libgnomeui2-dev_2.0.6-2_darwin-powerpc.deb
  | awk '{if ($6 == "./") { print "/."; } else if (substr($6, length($6), 1) == "/")
   {print substr($6, 2, length($6) - 2); } else { print substr($6, 2, length($6) - 1);}}'
  &gt; /sw/var/lib/dpkg/info/libgnomeui2-dev.list</pre><p>このコマンドは、 .deb ファイルの中身を解凍して、ファイル名以外を除いて .list ファイルに書き込んでいます。</p></div>
</a>
<a name="error-nineteen">
<div class="question"><p><b>Q5.19: Fink バイナリインストーラを使うと、ウィンドウ中に大きく "19" と出て、何もインストールできません。</b></p></div>
<div class="answer"><p><b>A:</b> 19 という数字は、 OS X システムのシステム言語が英語以外になっている時に出ることがあります。
(これは Apple のインストーラのバグで、英語でエラーメッセージを出さないだけです。)</p><p>この19番のメッセージは、英語ではこうなっています。</p><p>"A root directory /sw exists. Please see the Read Me file for update instructions, or for information on installing Fink on a separate volume."</p><p>このエラーは、以前 Fink を使っていて、 <code>/sw</code> を削除していないと発生します。
もし Fink をインストールしたことがなければ、 いちばん可能性が高いのは Virex プログラムをインストールしたためです。
これは .Mac ユーザーには無料で、 Fink のウェブサイトにあるとおり Fink とは互換性がありません。
(Virex 側の独自方式が原因です)
</p></div>
</a>
<a name="dselect-garbage">
<div class="question"><p><b>Q5.20: <code>dselect</code> でパッケージを選択すると、大量のゴミがでてきます。
これはどうやったら使えますか?</b></p></div>
<div class="answer"><p><b>A:</b> <code>dselect</code> と <code>Terminal.app</code> の関係に問題があります。
どうにかするには、 <code>dselect</code> を実行する前に次のコマンドを入力してください:
</p><p>tcsh の場合:</p><pre>setenv TERM xterm-color</pre><p>before you run <code>dselect</code>.</p><p>bash の場合:</p><pre>export TERM=xterm-color</pre><p>このコマンドをログイン時に自動的に実行するには、起動ファイル (例 <code>.cshrc</code> | <code>.profile</code>) に記述して下さい。</p></div>
</a>
<a name="perl-undefined-symbol">
<div class="question"><p><b>Q5.21: なぜ Fink コマンドを実行すると "dyld: perl undefined symbols" エラーが大量にでるのですか?</b></p></div>
<div class="answer"><p><b>A:</b> このようなエラー:</p><pre>dyld: perl Undefined symbols:
_Perl_safefree
_Perl_safemalloc
_Perl_saferealloc
_Perl_sv_2pv
_perl_call_sv
_perl_eval_sv
_perl_get_sv</pre><p>がでる場合、 Perl を アップデートしていて、 <code>storable-pm</code> をアップグレードする必要があります。
Fink をアップグレードしてください。
インストール時に、 <code>perl-core</code> と <code>system-perl</code> のどちらをインストールするか聞かれるので、後者を選択してください。
さらに、 <code>storable-pm</code> もアップデートしてください。</p><p>OS 10.1.x では、次のコマンドを実行します (Developer Tools が必要です):</p><pre>sudo mv /sw/lib/perl5/darwin/Storable.pm /tmp
sudo mv /sw/lib/perl5/darwin/auto/Storable /tmp
fink rebuild storable-pm
fink selfupdate-cvs</pre></div>
</a>
<a name="cant-upgrade">
<div class="question"><p><b>Q5.22: Fink のバージョンをアップデートできないようです。</b></p></div>
<div class="answer"><p><b>A:</b> この状況専用の <a href="http://fink.sourceforge.net/download/fix-upgrade.php">special instructions</a> に従ってください。</p></div>
</a>
<a name="spaces-in-directory">
<div class="question"><p><b>Q5.23: 名前に空白が入っているボリュームやディレクトリに Fink を入れることはできますか?</b></p></div>
<div class="answer"><p><b>A:</b> 名前に空白が入っているディレクトリに Fink を入れるないよう薦めます。</p></div>
</a>
<a name="packages-gz">
<div class="question"><p><b>Q5.24: バイナリアップデートをしようとすると、 "File not found" というメッセージが大量に出ます。</b></p></div>
<div class="answer"><p><b>A:</b> もし次のようであれば:</p><pre>
Err file: local/main Packages
  File not found
Ign file: local/main Release
Err file: stable/main Packages
  File not found
Ign file: stable/main Release
Err file: stable/crypto Packages
  File not found
Ign file: stable/crypto Release
Hit http://us.dl.sourceforge.net 10.3/release/main Packages
Hit http://us.dl.sourceforge.net 10.3/release/main Release
Hit http://us.dl.sourceforge.net 10.3/release/crypto Packages
Hit http://us.dl.sourceforge.net 10.3/release/crypto Release
Hit http://us.dl.sourceforge.net 10.3/current/main Packages
Hit http://us.dl.sourceforge.net 10.3/current/main Release
Hit http://us.dl.sourceforge.net 10.3/current/crypto Packages
Hit http://us.dl.sourceforge.net 10.3/current/crypto Release
Failed to fetch
file:/sw/fink/dists/local/main/binary-darwin-powerpc/Packages
File not found
Failed to fetch
file:/sw/fink/dists/stable/main/binary-darwin-powerpc/Packages
File not found
Failed to fetch
file:/sw/fink/dists/stable/crypto/binary-darwin-powerpc/Packages
File not found
Reading Package Lists... Done
Building Dependency Tree... Done
E: Some index files failed to download, they have been ignored, or old
ones used instead.

update available list script returned error exit status 1.
</pre><p><code>fink scanpackages</code> をするだけです。
これによって見つからなかったファイルを作成します。</p></div>
</a>
<a name="wrong-tree"> 
<div class="question"><p><b>Q5.25: OS | Developer Tools を変えたら、 Fink が認識してくれません。</b></p></div> 
<div class="answer"><p><b>A:</b> Fink ディストリビューション（ソースとバイナリはそのサブセットです）を変更するには、 Fink に指示する必要があります。
これは Fink の新規インストール時に実行するスクリプトを実行します:
</p><pre>/sw/lib/fink/postinstall.pl</pre><p>これにより、 Fink は正しく場所を指示されます。</p></div> 
</a> 
<a name="seg-fault"> 
<div class="question"><p><b>Q5.26: 何かをインストールしようとしたら <code>gzip</code> | <code>dpkg-deb</code> のエラーが出る! 助けて!</b></p></div> 
<div class="answer"><p><b>A:</b> 以下の形式のエラー:</p><pre>gzip -dc /sw/src/dpkg-1.10.9.tar.gz | /sw/bin/tar -xf - 
### execution of gzip failed, exit code 139</pre><p>あるいは</p><pre>gzip -dc /sw/src/aquaterm-0.3.0a.tar.gz | /sw/bin/tar -xf - 
gzip: stdout: Broken pipe 
### execution of gzip failed, exit code 138</pre><p>あるいは</p><pre>dpkg-deb -b root-base-files-1.9.0-1 
/sw/fink/dists/unstable/main/binary-darwin-powerpc/base 
### execution of dpkg-deb failed, exit code 10 
Failed: can't create package base-files_1.9.0-1_darwin-powerpc.deb</pre><p>であれば、バイナリにおけるプリバインドのエラーです。修正するには:</p><pre>sudo /sw/var/lib/fink/prebound/update-package-prebinding.pl -f</pre><p>と実行します。</p></div> 
</a> 
<a name="pathsetup-keeps-running"> 
<div class="question"><p><b>Q5.27: ターミナルウィンドウを開くと、
"Your environment seems to be correctly set up for Fink already."
というメッセージが出てログアウトします。</b></p></div> 
<div class="answer"><p><b>A:</b> 
これは、何らかの理由で OSX ターミナルがログインする度に
<code>/sw/bin/pathsetup.command</code>
 を実行するように設定されているからです。
修正するには、 初期設定ファイル <code>~/Library/Preferences/com.apple.Terminal.plist</code> を削除します。</p><p>他の設定を失いたくない場合、削除する代わりにテキストエディタでこのファイルを開き、
<code>/sw/bin/pathsetup.command</code>
と書かれている部分を削除します。</p></div> 
</a>
<p align="right">
Next: <a href="comp-general.php?phpLang=ja">6 コンパイルの問題 - 一般</a></p>

<? include_once "footer.inc"; ?>
