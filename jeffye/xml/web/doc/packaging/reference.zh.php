<?
$title = "打包 - 操作手册";
$cvs_author = 'Author: jeff_yecn';
$cvs_date = 'Date: 2004/03/11 15:43:25';
$metatags = '<link rel="contents" href="index.php?phpLang=zh" title="打包 Contents"><link rel="prev" href="fslayout.php?phpLang=zh" title="文件系统布局">';

include_once "header.inc";
?>

<h1>打包 - 5 操作手册</h1>




<h2><a name="build">5.1 构建过程</a></h2>

<p>要理解一些字段的含义，你需要有对 Fink 所采用的构建过程有些了解。它由五个阶段组成：解压，补丁，编译，安装和构建。下面的示例路径是关于安装在 <code>/sw</code> 的 gimp-1.2.1-1 软件包的。</p>
<p>在<b>解压阶段</b>，<code>/sw/src/gimp-1.2.1-1</code> 这个目录会被创建，源代码压缩档会被在这里解压。多数情况下，这会创建一个名为 gimp-1.2.1 的目录，里面包括源代码；下面的操作步骤会在那个目录里面执行(即 <code>/sw/src/gimp-1.2.1-1/gimp-1.2.1</code>)。我们可以使用 SourceDirectory，NoSourceDirectory 和 Source<b>N</b>ExtractDir
这三个字段来控制有关细节。</p>
<p>在<b>补丁阶段</b>，源代码会被打上补丁，以使得可以在 Darwin 下面编译。由 UpdateConfigGuess，UpdateLibtool，Patch 和 PatchScrip 这几个字段所指明的操作将被按照顺序执行。</p>
<p>在<b>编译阶段</b>，源代码被配置和编译。通常这会以某些参数来调用 <code>configure</code> 脚本，然后执行一个 <code>make</code> 命令。
详细信息请查看 CompileScript 字段的描述。</p>
<p>在<b>安装阶段</b>，软件包被安装到一个临时目录，<code>/sw/src/root-gimp-1.2.1-1</code> (= %d)。(注意 "root-" 部分。)
所有通常应该安装到 <code>/sw</code> 的文件现在被安装在
<code>/sw/src/root-gimp-1.2.1-1/sw</code> (= %i = %d%p)。 
详细信息请查看 InstallScript 字段的描述。</p>
<p>(<b>从 fink 0.9.9 开始，</b>可以通过 <code>SplitOff</code> 字段从一个软件包描述文件生成几个软件包。在安装阶段的尾段，会为每个软件包建立一个单独的安装目录，文件会被移到相应的目录中，)</p>
<p>在<b>构建阶段</b>，会根据临时文件夹的内容构建一个二进制安装包(.deb)文件。你不能直接影响这个步骤，但软件包描述里面的许多字段会用于生成 dpkg 的 <code>control</code> 文件。</p>


<h2><a name="fields">5.2 字段</a></h2>

<p>我们在这里把字段分成几类。这里所描述的内容并不一定包括全部的字段。<code>:-)</code></p>
<p><b>初始化数据：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>Package</td><td>
<p>
软件包名。
可以包括小写字母，数字和这几个特殊字符："."'，
"+" 和 "-"。
不可以使用下划线("_"),不可以使用大写字母。
这是一个必需字段。
</p>
<p>从 fink 0.9.9 开始，这个字段以及 Depends，BuildDepends，Provides，Conflicts，Replaces，Recommends，Suggests 和 Enhances 字段可以使用百分号展开。</p>
</td></tr><tr valign="top"><td>Version</td><td>
<p>
上游版本号。与 Package 字段具有同样的限制。
这是一个必需字段。
</p>
</td></tr><tr valign="top"><td>Revision</td><td>
<p>
软件包的修订版号。
当你对一个相同的上游版本提供一个新的描述文件的时候，需要增加它。
修订版号从 1 开始。
这是一个必需字段。
</p>
</td></tr><tr valign="top"><td>Epoch</td><td>
<p>
<b>从 fink 0.12.0 开始。</b>
这个可选字段可以用来指明软件包关键版本号(如果没有提供，默认值为 0).更多信息参考<a href="http://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Version">Debian
规则手册</a>.
</p>
</td></tr><tr valign="top"><td>Description</td><td>
<p>
对软件包的一个简单描述(有关它是什么东西的问题。)这是一个会显示在列表中的一行描述，所以它要简单明了。它应该少于 45 字符，必需少于 60 字符。在这个字段里面不需要重复软件包的名字-它总会被显式正确的上下文中。这是一个必需字段。
</p>
</td></tr><tr valign="top"><td>Type</td><td>
<p>
这可以设为 <code>bundle</code>。
束(Bundle)软件包可以用于一套相关的软件包归类在一起。
它们只有依赖管理，但没有代码和安装文件。
对于束文件包，Source，PatchScript，CompileScript，InstallScript 以及其它相关的字段都会被忽略。
</p>
<p>
<code>nosource</code> 是一个很类似的类型。
它表明没有源程序压缩档，所以不会有东西被下载，解压阶段只是创建一个空目录。
不过，补丁，编译和安装阶段则会正常执行。
这样你可以通过补丁放进全部代码，或者只是在 InstallScript 中创建一些目录。
从 fink 0.18.0 开始，你可以通过设置 <code>Source: none</code> 来获得同样的效果。这样你可以把 "Type" 字段用于其它目的(比如：<code>Type: perl</code>，等等)。
</p>
<p>
最后，从 fink 0.9.5 开始，开始有 <code>perl</code> 类型，它会对编译和安装脚本使用另外一套默认值。
从 fink 0.13.0 开始，有个这种类型的变种，
<code>perl $version</code>，其中 $version 是 perl 的一个版本号，它由句点分开的三个数字组成，例如： 
<code>perl 5.6.0</code>。
</p>
</td></tr><tr valign="top"><td>License</td><td>
<p>
本字段给出软件包发布所依据的授权协议的性质。它必须是本文档前面<a href="policy.php?phpLang=zh#licenses">软件包授权协议</a>中所描述的值之一。 另外，只有软件包确实满足打包规则在这方面的要求时，比如已经在软件包的 doc 目录安装了一份授权协议，才能够设置这个字段。
</p>
</td></tr><tr valign="top"><td>Maintainer</td><td>
<p>
负责本软件包的人的姓名和电子邮件地址。这是一个必需字段，而且必需是下面格式的一个名字和地址：
</p>
<pre>Firstname Lastname &lt;user@host.domain.com&gt;</pre>
</td></tr><tr valign="top"><td>InfoN</td><td>
<p>
本字段允许 fink 在软件包描述文件中实现后向兼容的语法改变。
一个给定版本的 fink 被配置为能够处理某个最大的 "N" 整数值。
任意在更高的 InfoN 字段的软件包会被忽略，所以这种机制仅在有需要的时候才使用，否则那些使用较旧版本的用户就会被没有必要地区别出去了。
本文档其它字段的说明会描述必须使用哪个特定的 InfoN。
要使用这个机制，把整个软件包描述放到合适的 InfoN 字段中间。
参考前面的 "File Format" 部分了解多行字段的语法。
</p>

</td></tr></table>
<p><b>依赖关系：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>Depends</td><td>
<p>
在本软件包构建前必需安装的软件包的列表。
通常，它只是以逗号分割软件包名清单，但 Fink 现在也和 dpkg 一样支持替代软件包和版本子句。
一个体现全部特性的例子是：
</p>
<pre>Depends: daemonic (&gt;= 20010902-1), emacs | xemacs</pre>
<p>
注意，其实没有办法去表达真正的可选依赖关系。
如果一个软件包在有和没有另外一个软件包的情况下都可以工作，你必需要么确定即使有那个软件包存在的情况下都不会去使用它，或者把它添加到依赖关系字段中。
如果你想提供给用户两种选择，你应该使用两个软件包，例如：wget 和 wget-ssl。
</p><p>
从 fink 的 0.18.2 后 CVS 版本开始，你可以使用条件依赖关系。它通过在软件包名字前面放置
<code>(string1 op string2)</code> 来指定。首先会对这两个字符串进行通常的百分号展开，然后这两个字符串会按照 <code>op</code> 运算符进行比较：&lt;&lt;， &lt;=，=，!=，&gt;&gt;，&gt;=。只有在比较的结果为真的时候，后面的软件包才会被认为是一个依赖关系。
</p><p>
你可以使用这个格式来简化维护几个类似的软件包的工作。例如，elinks 和 elinks-ssl 里面都可以这样写：
</p>
<pre>Depends: (%n = elinks-ssl) openssl097-shlibs, expat-shlibs</pre>
<p>
这和在 elinks 中写：
</p>
<pre>Depends: expat-shlibs</pre>
<p>
elinks-ssl 中写：
</p>
<pre>Depends: openssl097-shlibs, expat-shlibs</pre>
<p>是等价的。</p></td></tr><tr valign="top"><td>BuildDepends</td><td>
<p>
<b>从 fink 0.9.0 开始。</b>
只在编译时需要的依赖关系的清单。
这可以用于列出构建软件包必须使用工具(比如 flex)。它支持和 Depends 相同的语法。
</p>
</td></tr><tr valign="top"><td>Provides</td><td>
<p>
一个逗号分隔的软件包名字清单，它表示本软件包会"提供"那些软件包的功能。
如果一个名为 "pine" 的软件包指明 <code>Provides: mailer</code> 的话，那么只要安装了"pine"，所有对"mailer"的依赖关系都会被认为已经满足。
你通常会把这些软件包名字同时列在 "Conflicts" 和 "Replaces" 字段。
</p>
</td></tr><tr valign="top"><td>Conflicts</td><td>
<p>
一个逗号分隔的软件包名清单，这些软件包不应该和本软件安装在同一台机器上。
对于虚拟软件包，可以把它们代表的软件包的名字列在这里，它们会被自动正确处理。这个也支持和 Depend 字段类似的版本相关的依赖关系，但没有替换选择(这也不符合逻辑)。如果一个软件被列为它自己的 Conflicts 字段中，它将被从中清除(不会有特别的提示)，这个功能在 fink 的 0.18.2 后 CVS 版本中提供。
</p>
<p>
<b>注意：</b>Fink 自己本身会忽略这个字段。不过，它会被传递给 dpkg 并做相应的处理。概括来说，它仅影响运行时，而不应该构建时。
</p>
</td></tr><tr valign="top"><td>Replaces</td><td>
<p>
这和 "Conflicts" 同时使用，当软件包不仅仅替代冲突的软件包的功能，还会有一些共同的文件的时候。
没有这个字段的话，dpkg 会按安装的时候报错，因为这些文件还由别的软件包所拥有。
它也可以作为一个提示说，这两个软件是真正的完全替代的，一个可以完全替代另外一个。如果一个软件列为它自己的 Replaces，它会被自动(没有提示)地从中清除(从 fink 的 0.18.2 后 CVS 版本开始提供)。
</p>
<p>
<b>注意：</b>Fink 自己本身会忽略这个字段。不过，它会被传递给 dpkg 并做相应的处理。概括来说，它仅影响运行时，而不应该构建时。
</p>
</td></tr><tr valign="top"><td>Recommends, Suggests, Enhances</td><td>
<p>
这些字段以其它依赖关系的风格，指明一些额外的软件包关系。这三个关系不会影响通过<code>dpkg</code> 或 <code>apt-get</code> 的实际安装过程。
它们由 <code>dselect</code> 或其它前端程序来帮助用户作出合理的选择。
</p>
</td></tr><tr valign="top"><td>Pre-Depends</td><td>
<p>
对 Depends 字段进行更强的要求的特殊变量。
本字段只有在开发者邮件列表中经过讨论，并被大部分人同意需要这样做以后才可以使用。
</p>
</td></tr><tr valign="top"><td>Essential</td><td>
<p>
一个表明是关键软件包的布尔值。关键软件包会被作为初始环境建立的过程的一部分而安装。所有的非关键软件包都隐含地依赖于关键软件包。dpkg 会拒绝从系统中删除关键软件包，除非设置了特别的标识来覆盖它。
</p>
</td></tr><tr valign="top"><td>BuildDependsOnly</td><td>
<p>
<b>从 fink 0.9.9 开始。</b>
一个布尔值，它表明没有其它软件包会依赖于它，它们应该只是 BuildDepend。
</p>
</td></tr></table>
<p><b>解压阶段：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>CustomMirror</td><td>
<p>
镜像站点的列表。每个镜像站点占一行，格式如下：<code>&lt;location&gt;: &lt;url&gt;</code>。
<b>location</b> 可以是洲代号(例如 <code>nam</code>)，也可以是国家代号(比如 <code>nam-us</code>)，或者其它的东西；镜像站点会按照它的顺序来进行尝试。
例如：
</p>
<pre>CustomMirror: &lt;&lt;
nam-US: ftp://ftp.fooquux.com/pub/bar
asi-JP: ftp://ftp.qiixbar.jp/pub/mirror/bar
eur-DE: ftp://ftp.barfoo.de/bar
Primary: ftp://ftp.barbarorg/pub/
&gt;&gt;</pre>
</td></tr><tr valign="top"><td>Source</td><td>
<p>
源代码压缩档的 URL。它应该是一个 HTTP 或 FTP URL，但 Fink 本身并不关心这一点-它只是把它传递给 wget。这个字段对镜像站点的 URL 标记模式：
<code>mirror:&lt;mirror-name&gt;:&lt;relative-path&gt;</code>。
这会在 Fink 的配置中寻找 <b>mirror-name</b> 镜像的设置，然后添加  <b>relative-path</b> 部分，并把结果作为实际的 URL。已知的 <b>mirror-name</b> 被列在 <code>/sw/lib/fink/mirror/_list</code> 中。它是 fink 或 fink-mirror 软件包的一部分。另一方面，使用 <code>custom</code> 作为 <b>mirror-name</b> 会使 Fink 使用 <code>CustomMirror</code>
字段。
在 URL 使用前，会进行百分号展开。
</p>
<p>
从 0.18.0 开始，<code>Source: none</code> 具有特别的含义。它标识不需要下载源文件。参考
<code>Type</code> 字段的描述获取更多信息。
<code>gnu</code> 这个值代表
<code>mirror:gnu:%n/%n-%v.tar.gz</code>；<code>gnome</code> 则代表
<code>mirror:gnome:stable/sources/%n/%n-%v.tar.gz</code>。默认值是 <code>%n-%v.tar.gz</code> (即一个手工指定的下载)。
</p>
</td></tr><tr valign="top"><td>Source<b>N</b></td><td>
<p>
如果一个软件包包含几个压缩档，在这些额外的字段中说明它们呢，从 N = 2 开始。所以，第一个压缩档(它应该是所谓的"主"压缩档)会被放在 <code>Source</code>，第二个压缩档则作为 <code>Source2</code>，依此类推。这里的规则和 Source 是一样的，区别只是 "gnu" 和 "gnome" 捷径不会被展开-那样做并没有意义。
</p>
</td></tr><tr valign="top"><td>SourceDirectory</td><td>
<p>
在压缩档被解压到一个目录里面的时候必须使用，但目录名会和压缩档的基本部分不同。
通常，一个名为 "foo-1.0.tar.gz" 会产生一个名为 "foo-1.0" 的目录。如果它产生不同名字的目录，用这个参数指明它。对这个字段会应用百分号展开。
</p>
</td></tr><tr valign="top"><td>NoSourceDirectory</td><td>
<p>
把这个布尔值参数设为真的话，压缩档不会展开到一个单独的目录中。
通常，一个名为 "foo-1.0.tar.gz"
会产生一个名为 "foo-1.0" 的目录。如果它只是把文件解压到当前目录，使用这个参数并把它设为真。
</p>
</td></tr><tr valign="top"><td>Source<b>N</b>ExtractDir</td><td>
<p>
通常，一个辅助压缩档会被解压到主压缩档相同的目录中。如果你需要把它解压到一个特别的子目录中，使用这个字段来指明它。
正如一般人想象的一样，Source2ExtractDir 对应于 Source2 压缩档。查阅 ghostscript，vim 和 tetex 作为使用的例子。
</p>
</td></tr><tr valign="top"><td>SourceRename</td><td>
<p>
这个字段可以在下载过程中改变源程序压缩档的名字。它经常用于在服务器上用目录来区别不同的版本，但压缩档的名字却都是相同的场合。例如：
://www.foobar.org/coolapp/1.2.3/source.tar.gz。要解决这个问题，你可以使用：
</p>
<pre>SourceRename: %n-%v.tar.gz</pre>
<p>
对于上面的例子，这会使得下载的源代码压缩档保存在
<code>/sw/src/coolapp-1.2.3.tar.gz</code>，以满足我们的一般命名约定。
</p>
</td></tr><tr valign="top"><td>Source<b>N</b>Rename</td><td>
<p>
这和 <code>SourceRename</code> 字段是一模一样的，除了它是用来重命名 <code>Source<b>N</b></code> 字段指定的第 N 个压缩档外。参考其它有关的部分来了解使用的例子。
</p>
</td></tr><tr valign="top"><td>Source-MD5</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
在这个字段中，你可以指定源程序文件的 MD5 校验值。
这个信息会被 Fink 用来检测是否使用了错误的源文件版本，也就是说，
那些和维护者所使用的版本不同的软件包。通常引起这个问题的原因是：未完全下载的压缩档；上游维护者在未通知的情况下修改了源代码；木马或类似的攻击；等等。
</p>
<p>
典型的使用例子是：
</p>
<pre>Source-MD5: 4499443fa1d604243467afe64522abac</pre>
<p>
要计算校验值，可以使用 <code>md5sum</code> 工具。如果你希望检查压缩档 <code>/sw/src/apache_1.3.23.tar.gz</code> 的校验值，
你可以运行下面的命令(下面还包括命令的输出结果)：
</p>
<pre>fingolfin% md5sum /sw/src/apache_1.3.23.tar.gz 
4499443fa1d604243467afe64522abac  /sw/src/apache_1.3.23.tar.gz</pre>
<p>
正如你所看见的一样，靠左边的数值就是你需要的结果。
</p>
</td></tr><tr valign="top"><td>Source<b>N</b>-MD5</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
这个字段和 <code>Source-MD5</code> 字段完全一样，除了它是指定与 <code>Source<b>N</b></code> 字段对应的第 N 个压缩档的 MD5 校验值。
</p>
</td></tr><tr valign="top"><td>TarFilesRename</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
这个字段只对那些使用 tar 格式的源程序文件有效。
</p>
<p>
通过这个字段，你可以在解压压缩档的时候，重命名给定的源程序压缩档里面的文件。这是针对 HFS+ 文件系统大小写不敏感的特性的一个解决办法。比方说在标准的 Mac OS X 环境下 <code>install</code> 和 <code>INSTALL</code> 这两个文件会发生冲突。通过这个字段，你可以不需要重新建立一个新的压缩档(过去需要这样做)就可以避免这个问题。
</p>
<p>
这个字段中，你只需要简单第列出需要重命名的文件。你可以使用通配符。
默认情况下，这些文件名后面会被加上 <code>_tmp</code>。你可以通过使用在 <code>Files</code> 和 <code>DocFiles</code>
字段中的相同语法来修改这个默认行为，就是在原来的文件名后面加上一个冒号，然后再加上新的文件名。
例如：
</p>
<pre>TarFilesRename: foo bar.* qux:quux
Tar2FilesRename: direcory/INSTALL:directory/INSTALL.txt</pre>
<p>
<b>注意：</b>这个字段的程序实现利用了 BSD tar 程序的特别特性。GNU tar 不支持这个特性。默认时，Fink 使用 GNU tar
(因为有些压缩档只能用 GNU tar 解开)，但当一个软件包使用了 TarFilesRename 字段，Fink 会通过直接调用
<code>/usr/bin/tar</code> 的方法来使用 BSD tar。
</p>
</td></tr><tr valign="top"><td>Tar<b>N</b>FilesRename</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
这和 <code>TarFilesRename</code> 字段一致，除了它作用于与 <code>Source<b>N</b></code> 字段对应的第 N 个压缩档以外。
</p>
</td></tr></table>


<p><b>补丁阶段：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>UpdateConfigGuess</td><td>
<p>
一个布尔值。如果为真的话，构建目录中的 config.guess 和 config.sub
会被替换为了解 Darwin 的版本。这发生在补丁阶段，并在 PatchScript
运行之前。<b>仅仅</b> 在你确定必须这么做的时候才使用它，即，当配置脚本以 "unknown host" 而失败的时候。
</p>
</td></tr><tr valign="top"><td>UpdateConfigGuessInDirs</td><td>
<p>
<b>从 0.9.0 后 CVS 版本开始。</b>
这是一些子目录的清单。
这和 UpdateConfigGuess 完成相同的工作，但只对那些在几个子目录里面的  config.guess 文件是过期的情况下使用。
以前，你需要在 PatchScript 中手工拷贝/移动那里面的文件。
而有了这个新的字段以后，你可以仅仅是列出目录。
使用 <code>.</code> 来更新处于构建目录本身的文件。
</p>
</td></tr><tr valign="top"><td>UpdateLibtool</td><td>
<p>
这是一个布尔值。如果为真的话，那么构建目录里面的 ltconfig 和 ltmain.sh 文件会被替换为与 Darwin 兼容的版本。
这发生在补丁阶段，在 PatchScript 脚本运行之前。
<b>仅仅</b>在你肯定需要软件包需要它的时候才这样做。
有些软件包会因为替换不正确版本的 libtool 脚本而被破坏。
查看<a href="http://fink.sourceforge.net/doc/porting/libtool.php">libtool
网页</a>获取更进一步的信息。
</p>
</td></tr><tr valign="top"><td>UpdateLibtoolInDirs</td><td>
<p>
<b>从 0.9.0 后 CVS 版本开始。</b>
一个子目录的清单。
它和 UpdateLibtool 的作用一样，但只对那些源代码中几个目录中有过期的 libtool 1.3.x 脚本的软件包有用。
以前你需要在 PatchScript 脚本中手工拷贝/移动这些文件。
有了这个新的字段以后，你只需要指定这些目录。
使用 <code>.</code> 来更新在构建目录本身里面的文件。
</p>
</td></tr><tr valign="top"><td>UpdatePoMakefile</td><td>
<p>
一个布尔值。
为真的话，在 <code>po</code> 目录中的 <code>Makefile.in.in</code> 文件会被替换为打过补丁的版本。
这发生在补丁阶段，并在 PatchScript 脚本运行之前。
</p>
<p>
打过补丁的版本可以识别 DESTDIR 并确保信息目录是在 <code>/sw/share/locale</code>，而不是 <code>/sw/lib/locale</code>。
在使用这个字段之前，确定你不会破坏软件包以及的确有这个必要。
你可以运行 <code>diff</code> 命令来找出软件包的版本和 Fink 的版本的区别(在
<code>/sw/lib/fink/update</code>)。
</p>
</td></tr><tr valign="top"><td>Patch</td><td>
<p>
应用于 <code>patch -p1
&lt;<b>patch-file</b></code> 命令的补丁文件的名字。这应该只是一个文件名；正确的路径会被自动添加。在本字段中会应用百分号展开。所以典型的设置值只是
<code>%f.patch</code> 或 <code>%n.patch</code>。补丁会在 PatchScript 脚本运行之前应用(如果有的话)。
</p>
</td></tr><tr valign="top"><td>PatchScript</td><td>
<p>
在补丁阶段运行的一系列命令。参阅下面关于脚本的注意事项。这是对软件包打补丁或修改软件包的地方。在这里没有默认运行的命令。在命令运行之前，会进行百分号展开。(查阅上一部分)。
</p>
</td></tr></table>
<p><b>编译阶段：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>Set<b>ENVVAR</b></td><td>
<p>
在编译和安装阶段设置一些环境变量。这可以用于传递一些编译器标志等信息到  configure 脚本和 Makefile 文件。目前支持的变量包括：CC，CFLAGS，CPP，CPPFLAGS，CXX，CXXFLAGS，LD，LDFLAGS，LIBS，MAKE，MFLAGS，MAKEFLAGS。你指定的值也会应用前面说过百分号展开。一个常见的例子是：
</p>
<pre>SetCPPFLAGS: -no-cpp-precomp</pre>
<p>
CPPFLAGS 和 LDFLAGS 变量是比较特别的。它们的默认值分别为
<code>-I%p/include</code> 和 <code>-L%p/lib</code>。如果你指定了这些值之一，它会被认为是默认值。
</p>
</td></tr><tr valign="top"><td>NoSet<b>ENVVAR</b></td><td>
<p>
当设为真时，停用上面所提到的
CPPFLAGS 和 LDFLAGS 的默认值设置。也就是说，如果你希望 LDFLAGS 保持没有设置，指定 <code>NoSetLDFLAGS: true</code>。
</p>
</td></tr><tr valign="top"><td>ConfigureParams</td><td>
<p>
传递给 configure 脚本的额外参数(查阅
CompileScript 字段的说明获取详细信息)。

对于 &lt; 0.13.7 的 fink 版本，这个参数也对 perl 模块<code>Type: Perl</code>有效，并会添加到默认的 perl Makefile.PL
字符串中。
</p>
</td></tr><tr valign="top"><td>GCC</td><td>
<p>
要求使用的 gcc 编译器版本。允许值包括：
<code>2.95.2</code> 或 <code>2.95</code>
(仅用于 10.1 软件包代码树)，<code>3.1</code>
(仅用于 10.2 软件包代码树)，和 <code>3.3</code>
(仅用于 10.2-gcc3.3 和 10.3 软件包代码树)。
</p>
<p>对于 fink 0.13.8，如果使用了这个标志，会使用 <code>gcc_select</code> 来检测 gcc 的版本，如果检测到错误的版本，fink 会出错退出。
</p>
<p>
这个字段被添加到 fink 以辅助在 gcc
编译器之间的转换，因为这些不同的编译器在涉及有关没有考虑版本区别的 C++ 代码中存在着不兼容。
</p>
</td></tr><tr valign="top"><td>CompileScript</td><td>
<p>
在编译阶段运行的一系列命令。参阅下面关于脚本的注解。这里是放置配置和编译软件包的命令的地方。通常默认值是：
</p>
<pre>./configure %c
make</pre>
<p>
这对于使用 GNU autoconf 的软件包是恰当的。
对于那些是 perl (通过 Type 字段指定)类型，但却没有指明 perl 版本的软件包，默认的替代值是：
</p>
<pre>perl Makefile.PL PREFIX=%p \
 INSTALLPRIVLIB=%p/lib/perl5 \
 INSTALLARCHLIB=%p/lib/perl5/darwin \
 INSTALLSITELIB=%p/lib/perl5 \
 INSTALLSITEARCH=%p/lib/perl5/darwin \
 INSTALLMAN1DIR=%p/share/man/man1 \
 INSTALLMAN3DIR=%p/share/man/man3
make
make test</pre>
<p>如果是指定版本的 <code>perl $version</code> 类型(比如 $version 可能是 5.6.0)，
默认值是：
</p>
<pre>perl$version Makefile.PL \
 PERL=perl$version PREFIX=%p \
 INSTALLPRIVLIB=%p/lib/perl5/$version \
 INSTALLARCHLIB=%p/lib/perl5/$version/darwin \
 INSTALLSITELIB=%p/lib/perl5/$version \
 INSTALLSITEARCH=%p/lib/perl5/$version/darwin \
 INSTALLMAN1DIR=%p/share/man/man1 \
 INSTALLMAN3DIR=%p/share/man/man3
make
make test</pre>
<p>
在命令执行之前，会进行百分号展开(参阅前面的章节)。
</p>
</td></tr><tr valign="top"><td>NoPerlTests</td><td> 
<p>
<b>从 fink 0.13.7 之后开始。</b>
一个针对 perl 模块软件包的布尔值。如果为真的话，<code>CompileScript</code> 的 <code>make test</code> 部分会对那些指定的 perl 模块忽略。
</p>
</td></tr></table>
<p><b>安装阶段：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>UpdatePOD</td><td>
<p>
<b>从 fink 0.9.5 开始。</b>
一个针对 perl 模块软件包的布尔值。
为真的话，它会添加代码到 install，postrm 和 postinst
脚本来维护 perl 软件包所提供的 .pod 文件。
这包括在中央的<code>/sw/lib/perl5/darwin/perllocal.pod</code>文件中添加和删除 .pod 数据。
(如果类型是以 <code>perl $version</code> 这样包括特定版本的形式给出，例如 5.6.0，那么这些脚本会被用于处理在
<code>/sw/lib/perl5/$version/perllocal.pod</code> 的中央 .pod 文件。)
</p>
</td></tr><tr valign="top"><td>InstallScript</td><td>
<p>
一系列在安装阶段运行的命令。查看下面关于脚本的注解。
这是把软件包的需要文件拷贝到正确的地方的指令。
通常的默认值是：
</p>
<pre>make install prefix=%i</pre>
<p>
这么默认值对使用 GNU autoconf 的软件包是合适的。
对于那些 perl (通过 Type 字段指明) 模块类型的软件包，
如果没有指定 perl 版本的话，
默认的值为：
</p>
<pre>make install INSTALLPRIVLIB=%i/lib/perl5 \
 INSTALLARCHLIB=%i/lib/perl5/darwin \
 INSTALLSITELIB=%i/lib/perl5 \
 INSTALLSITEARCH=%i/lib/perl5/darwin \
 INSTALLMAN1DIR=%i/share/man/man1 \
 INSTALLMAN3DIR=%i/share/man/man3</pre>
<p>如果类型是指定版本 <code>perl $version</code> (比如 $version 为 5.6.0)的 perl 模块，
默认值为：
</p>
<pre>make install INSTALLPRIVLIB=%i/lib/perl5/$version \
 INSTALLARCHLIB=%i/lib/perl5/$version/darwin \
 INSTALLSITELIB=%i/lib/perl5/$version \
 INSTALLSITEARCH=%i/lib/perl5/$version/darwin \
 INSTALLMAN1DIR=%i/share/man/man1 \
 INSTALLMAN3DIR=%i/share/man/man3</pre>
<p>
如果软件包支持的话，首选会使用 <code>make install
DESTDIR=%d</code>。在命令执行之前，会进行百分号替换(参看前面的章节)。
</p>
</td></tr><tr valign="top"><td>JarFiles</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
这个字段和 DocFiles 有些类似。它安装指定的 jar
文件到 <code>%p/share/java/%n</code> 目录中。
例如：
</p>
<pre>JarFiles: lib/*.jar foo.jar:fooBar.jar</pre>
<p>
这将安装全部原来在 lib 目录中 jar 文件，同时会把
foo.jar 安装为 fooBar.jar。
</p>
<p>
它同时确保这些 jar 文件(尤其是：所有在 <code>%p/share/java/%n</code> 目录中以 .jar 结尾的文件)
被添加到 CLASSPATH 环境变量中。
这使得象
configure 或 ant 之类的工具能够正确地检测到已安装的 jar 文件。
</p>
</td></tr><tr valign="top"><td>DocFiles</td><td>
<p>
这个字段提供一个安装软件包中 doc 目录中<code>%p/share/doc/%n</code> README 或 COPYING
文件的方便方法。
它的值是一些以空格分开的文件清单。
你可以从构建目录的子目录拷贝文件，但最后它们应该拷贝到 doc 目录本身，而不是它的子目录。
可以使用 Shell 通配符。
也可以在拷贝的同时重命名某个文件，这可以在一个冒号后面添加新的文件名来实现，
比如 <code>libgimp/COPYING:COPYING.libgimp</code>。
这个字段的功能是通过在 InstallScript 中添加合适的 <code>install</code> 命令。
</p>
</td></tr><tr valign="top"><td>Shlibs</td><td>
<p>
<b>从 fink 0.11.0 开始。</b>
这个字段声明软件包中要安装的共享库。
每个共享库占一行，每行包括以空格分开的三项：
共享库的 <code>-install_name</code>(安装名)，<code>-compatibility_version</code>(兼容版本号)，和版本相关的指明提供这个兼容版本的 Fink 软件包的依赖信息
依赖信息应该以下面的形式描述：<code> foo (&gt;= version-revision)</code> 其中 
<code>version-revision</code> 指提供(这个兼容版本)函数库的 Fink 软件包的 <b>第一个</b>版本。
Shlibs 声明表明维护者承诺这个名字和至少
<code>-compatibility_version</code>的兼容版本号的函数库会在这个 Fink 软件包的新版本中找到。
</p></td></tr><tr valign="top"><td>RuntimeVars</td><td>
<p>
<b>从 fink 0.10.0 开始。</b>
这个字段提供设置运行时环境变量为一些静态值的简便方法(如果你需要更灵活的方式，参考 <a href="#profile.d">profile.d 脚本部分</a>)。在你的软件包安装以后，这些变量会通过 <code>/sw/bin/init.[c]sh</code> 脚本设置。
</p>
<p>
你的环境的值可以包括空格(尾部的连续空格会被截断)；另外，百分号展开也会进行。例如：
</p>
<pre>RuntimeVars: &lt;&lt;
 SomeVar: %p/Value
 AnotherVar: foo bar
&lt;&lt;</pre>
<p>
会设置两个环境变量 "SomeVar" 和 "AnotherVar"，它们的值相应地被设置为 "/sw/Value" (或你选择的前缀)以及 "foo bar"。
</p>
<p>
这个字段通过添加合适的命令到 InstallScript 来实现。
这些命令为每个变量添加一行 setenv/export 到软件包的 profile.d 脚本，所以你也提供你自己，它们不会被覆盖。这些行被作为脚本考虑，你可以在你的脚本中使用这些变量。
</p>
</td></tr><tr valign="top"><td>SplitOff</td><td>
<p>
<b>从 fink 0.9.9 开始。</b>
在同一个编译/安装过程中产生第二个软件包。
有关详细信息，查看下面单独的
<a href="#splitoffs">剥离(splitoff)部分</a>。
</p>
</td></tr><tr valign="top"><td>SplitOff<b>N</b></td><td>
<p>
<b>Introduced in fink 0.9.9.</b>
这和 <code>SplitOff</code> 一样，用于从同一个编译/安装过程产生第三、第四个等等软件包。
</p>
</td></tr><tr valign="top"><td>Files</td><td>
<p>
<b>从 fink 0.9.9 开始。</b>
<b>仅</b>
在 <code>SplitOff</code> 或 <code>SplitOff<b>N</b></code> 字段内使用，
它用于指定哪些文件和目录需要从父文件包的安装目录 %I 移动到当前安装目录 %i。 注意这在父文件包的 InstallScript 和 DocFiles 之后，但在当前文件包的 InstallScript 和 Docfiles 之前执行。
</p>
</td></tr></table>
<p><b>构建阶段：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>PreInstScript, PostInstScript, PreRmScript, PostRmScript</td><td>
<p>
这些字段指明当软件包安装、升级或删除的时候执行的 shell 脚本。
Fink 会自动添加脚本的头部
<code>#!/bin/sh</code>，并调用 <code>set -e</code>，所以任何失败的命令都会导致脚本的立即终止。
Fink 还会在最后添加一个 <code>exit 0</code>。
要指明错误，从脚本中以一个非零值退出。
第一个参数 (<code>$1</code>) 被设为一个指明应该采用什么操作的值。
一些可能的值包括 <code>install</code>，<code>upgrade</code>，<code>remove</code> 和 <code>purge</code>。
注意还有更多的值，用于错误回退或因为另外一个文件包而删除的情况。
</p>
<p>
脚本会在下面的时候被调用：
</p>
<ul>
<li>PreInstScript: 当软件包第一次安装和升级到这个版本时。</li>
<li>PostInstScript: 解压和设置软件包之后。</li>
<li>PreRmScript: 软件包被删除或升级到新版本之前。</li>
<li>PostRmScript: 软件包被删除或升级到新版本之后。</li>
</ul>
<p>
更清楚地说，升级过程包括：新版本的 Inst scripts，和旧版本的 Rm scripts。
细节可以在 Debian 规则手册找到，
<a href="http://www.debian.org/doc/debian-policy/ch-maintainerscripts.html">第六章</a>.
</p>
<p>
脚本中会进行百分号展开。
命令通常会不使用完整路径来调用。
</p>
</td></tr><tr valign="top"><td>ConfFiles</td><td>
<p>
以空格分开的用户可以编辑的配置文件的列表。
这些文件必须以绝对路径指明，例如，<code>%p/etc/foo.conf</code>。
这些文件会被 dpkg 特别对待。
当软件包被升级，而软件包和磁盘上的文件相比被改动过的话，用户会被询问使用哪个版本，以及是否需要进行备份。
当一个软件包被删除后，配置文件仍然还保留在磁盘上。
只有 "purge" 会删除配置文件。
</p>
</td></tr><tr valign="top"><td>InfoDocs</td><td>
<p>
软件包安装在 %p/share/info 目录的信息文件的清单。
这会在 postinst 和 prerm 脚本中添加合适的代码来维护 Info 目录的文件 <code>dir</code>文件。
这个特性仍然在增加过程，将来可能会加入更多的字段以获得更精细的控制。
</p>
</td></tr><tr valign="top"><td>DaemonicFile</td><td>
<p>
给出 <code>daemonic</code> 的服务描述。
<code>daemonic</code> 被 Fink 用于创建和删除 daemon 进程的
StartupItems (例如 web 服务器)。
描述会被作为一个名为 <code>%p/etc/daemons/<b>name</b>.xml</code> 的文件添加到软件包中，这里 <b>name</b> 由 DaemonicName 字段指定，默认为软件包名字。
对本字段的内容可以进行百分号展开。
注意如果你的软件包需要使用它的时候，你必须添加 <code>daemonic</code> 到依赖关系清单中。
</p>
</td></tr><tr valign="top"><td>DaemonicName</td><td>
<p>
<code>daemonic</code> 服务描述文件的名字。
查看 DaemonicFile 字段的描述获取更多的信息。
</p>
</td></tr></table>
<p><b>额外数据：</b></p>
<table border="0" cellpadding="0" cellspacing="10"><tr valign="bottom"><th align="left">Field</th><th align="left">Value</th></tr><tr valign="top"><td>Homepage</td><td>
<p>
软件包上游提供者的首页 URL。
</p>
</td></tr><tr valign="top"><td>DescDetail</td><td>
<p>
一个相比 <code>Description</code> 字段更详细的描述(内容包括它是什么，我可以用它来做什么？)。
这里允许使用多行。因为这个字段在显示的时候不会由自动单词绕回，你应该手工插入分行符，使得每行不超过 79 个字符(如果可能的话)。
</p>
</td></tr><tr valign="top"><td>DescUsage</td><td>
<p>
这是对如果使用软件有关的信息(我怎么使用它？)。
就好象 "在使用 WindowMaker 运行 wmaker.inst 一次" 这样的信息。可以使用多行。因为这个字段在显示的时候不会由自动单词绕回，你应该手工插入分行符，使得每行不超过 79 个字符(如果可能的话)。
</p>
</td></tr><tr valign="top"><td>DescPackaging</td><td>
<p>
关于软件包的注解。类似 "对 Makefile 进行修正已使得正确放置所有的文件" 之类的信息会放在这里。可以使用多行。
</p>
</td></tr><tr valign="top"><td>DescPort</td><td>
<p>
这是专门针对移植到 Darwin 的软件包的。
象 "config.guess 和 libtool 脚本已被更新，需要使用 -no-cpp-precomp
" 之类的信息会被放在这里。可以使用多行。
</p>
</td></tr></table>


<h2><a name="splitoffs">5.3 剥离分支(SplitOffs)</a></h2>
<p>从 fink 0.9.9 开始，可以用一个单独的 .info 文件来构建多个软件包。
安装阶段和正常的类似，执行
<code>InstallScript</code> 和 <code>DocFiles</code> 命令。
如果存在 <code>SplitOff</code> 字段，会触发第二个安装目录的创建。
在 <code>SplitOff</code> 字段里面，新的安装目录以 %i 代表，
而父文件包的原始安装目录则用 %I 代表。
</p>
<p>
<code>SplitOff</code> 字段必须包含它自己的一系列字段。
事实上，它由一个备有包含字段的一个完整的软件包描述组成。下面是在子描述里面可以包含的内容(分类说明)：
</p>
<ul>
<li>初始化数据：只需要指明 <code>Package</code> 字段，其它的内容都可以从父软件包进行继承。你可能需要通过声明 <code>SplitOff</code> 内的字段修改 <code>Type</code> 和 <code>License</code> 字段。可以使用百分号扩展，而且通常使用 %N 来引用父软件包的名字会很方便。</li>
<li>依赖关系：所有的依赖关系有关的字段都可以使用。</li>
<li>解压阶段，补丁阶段，编译阶段：这些字段是无关的，会被忽略。</li>
<li>安装阶段，构建阶段：全部的字段都可以使用(除了 <code>SplitOff</code> 字段不能在 <code>SplitOff</code>
字段里面使用以外)。</li>
<li>额外数据：这会从父软件包继承，但可以通过在 <code>SplitOff</code> 中声明这些字段而进行修改。</li>
</ul>
<p>
在安装阶段，父文件包的 <code>InstallScript</code> 和 
<code>DocFiles</code> 会被首先执行。
然后是 <code>SplitOff</code> 字段里面的 <code>Files</code> 命令，它会导致命令中所列的文件和目录会从父文件包的安装目录 %I 移到当前的安装目录 %i。然后<code>SplitOff</code> 软件包的 <code>InstallScript</code>
和 <code>DocFiles</code> 会被执行。
</p><p>
如果还有通过 <code>SplitOff2</code>，<code>SplitOff3</code>等等指明的更多子软件包，命令
(<code>Files</code>，<code>InstallScript</code>，<code>DocFiles</code>)
会以同样的顺序依此对它们进行执行。
</p><p>
在构建阶段，每个软件包的安装/删除的前/后脚本会通过相应软件包构建阶段的命令来生成。
</p><p>
每个被构建的软件包都要求把授权协议文件存放到 %i/share/doc/%n (当然对于每个软件包 %n 有不同的取值)目录中。
注意
<code>DocFiles</code> 是拷贝文件而不是移动它们，所以可以通过多次使用 <code>DocFiles</code> 命令而把一个相同文档拷贝安装在几个不同的地方。
</p>




<h2><a name="scripts">5.4 脚本</a></h2>

<p>PatchScript，CompileScript 和 InstallScript 字段允许你指定需要执行的 shell 命令。支持两种形式。
</p><p>
这个字段可以是命令的简单罗列。它和一个
shell 脚本类似。不过，命令是通过 system() 调用执行的，每次一行，所以设置环境变量和更改路径只对同一行有效。从 fink 0.18.2 后的 CVS 版本开始，你可以用与普通 shell 脚本类似的方法来绕回太长的行：
在一行末尾的反斜线 (<code>\</code>) 表明下一行是一个续行。
</p><p>
作为替代方案，你可以在这里嵌入一个完整的脚本，使用你选择的解析器。
对于任何 Unix 脚本，第一行必须以 <code>#!</code> 开始，后面紧跟解析器的完整路径名以及需要的标志(例如 <code>#!/bin/csh</code>，<code>#!/bin/bash -ev</code>等等)。在这种情况下，整个
*Script 字段会被写到一个临时文件，然后被执行。
</p>


<h2><a name="patches">5.5 补丁</a></h2>

<p>如果你的软件包需要补丁采可以在 Darwin 上编译(或与 Fink 配合)，
把补丁命名为与软件包描述文件相同的名字，使用 ".patch" 来取代 ".info" 作为扩展名，并把它放在和 .info 文件相同的目录下面。
如果你在文件名中使用完整的软件包名，那么使用下面的任意一种方式(它们是等效的)：</p>
<pre>Patch: %f.patch</pre>
<pre>PatchScript: patch -p1 &lt;%a/%f.patch</pre>
<p>如果你使用比较新的简单软件包命名约定，使用 %n
来代替 %f。这两个字段不是互斥的，你可以两个都使用，它们都会被执行。这种情况下，PatchScript 会在后面被执行。</p>
<p>因为你可能会在补丁文件中允许用户选择安装前缀，建议在补丁文件中使用类似 <code>@PREFIX@</code> 的变量来代替 <code>/sw</code>，然后使用：</p>
<pre>PatchScript: sed 's|@PREFIX@|%p|g' &lt;%a/%f.patch | patch -p1</pre>
<p>补丁文件应该是 unidiff 格式，而且一般应该通过：</p>
<pre>diff -urN &lt;originalsourcedir&gt; &lt;patchedsourcedir&gt;</pre>
<p>命令产生。</p>
<p>如果你用过 emacs 编辑文件，你可以在上面的 diff 命令中加上 <code>-x'*~'</code> 来派出自动产生的后备文件。</p>
<p>另外需要注意的是非常大的补丁不应该放到 CVS 中。
它们应该被放到一个 web/ftp 服务器，并使用
<code>SourceN:</code> 字段来指明。如果你自己没有网站，fink 项目管理员可以把它放到 fink 自己的网站上。如果你的补丁大于 30Kb，你应该考虑把它作为一个单独的下载。
</p>


<h2><a name="profile.d">5.6 Profile.d 脚本</a></h2>

<p>
如果你的软件包需要一些运行时的初始化(例如，设置环境变量)，你可以使用 profile.d 脚本。
这些脚本片段由 <code>/sw/bin/init.[c]sh</code> 脚本所运行。通常，所有 fink 的用户都会把这些脚本放到它们的起动文件(<code>.cshrc</code> 或类似的文件)中。
你的软件包必须为两个变种都提供脚本：一个给 sh 兼容的 shells (sh, zsh, bash, ksh, ...) 而另一个给 csh 兼容的 shells (csh, tcsh)。它们应该被安装在 <code>/sw/etc/profile.d/%n.[c]sh</code> (和往常一样，%n 代表软件包名)。
另外，它们的可读和可执行属性都应该被设置(即，用 -m 755 参数安装它们)，否则它们不能被正确加载。
</p>
<p>
如果你只需要设置一些环境变量(例如，把 QTDIR 设置为 '/sw')，你可以使用 RuntimeVars 字段来比较方便地实现这个所说的功能。
</p>





<? include_once "footer.inc"; ?>
