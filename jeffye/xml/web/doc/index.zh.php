<?
$title = "文档";
$cvs_author = 'Author: jeff_yecn';
$cvs_date = 'Date: 2004/03/07 21:06:03';
$metatags = '';

include_once "header.inc";
?>

<h1>Fink－文档</h1><!--Generated from $Fink: doc.zh.xml,v 1.3 2004/03/07 21:06:03 jeff_yecn Exp $-->
<p>
这里收集了为 Fink 编写的各种文档。
有些文档可能会对使用 Mac OS X 的用户有用，或那些没有使用 Fink 但又向学习如何移植 Unix 软件的 Darwin 用户有用。
</p>
<h2><a name="userdoc">用户文档</a></h2>

<p>
当前 Fink 的用户文档：
</p>
<ul>
<li><a href="users-guide/index.php">Fink 用户指南</a> － 它涉及如何安装 Fink 自身，安装软件包，和升级到新的 Fink 版本。它包括对使用源代码版本和二进制版本的使用说明。
<b>正在编写中！</b></li>
<li><a href="x11/index.php">在 Darwin 和 Mac OS X 上运行 X11</a> － 涉及有关概念，安装和启动（同时面向 Darwin 和 Mac OS X 用户）</li>
</ul>

<p>
很多更完整的文档，但稍微有点过期而且不再被维护：
</p>
<ul>
<li><a href="bundled/install.php">安装和升级</a> －　如何安装 Fink 或升级到新的版本</li>
<li><a href="bundled/usage.php">使用</a>  － 如何使用 Fink 及其安装的软件</li>
<li><a href="bundled/readme.php">Fink 自述</a> － 源代码发布版本的自述文件</li>
<li><a href="cvsaccess/index.php">CVS 访问</a> － 如何访问 Fink CVS 库来在新版本发布前获取最新源代码包。</li>
</ul>

<h2><a name="developerdoc">开发者文档</a></h2>

<ul>
<li><a href="http://fink.sourceforge.net/doc/UsingFink.pdf">使用 Fink：开发者使用指南</a>  (2MB pdf 文件，英文版) － 一组用于 <a href="http://conferences.oreillynet.com/macosx2002/">O'Reilly Mac OS X 大会</a>上演示的幻灯片（同时也有 <a href="http://conferences.oreillynet.com/presentations/macosx02/morrison_david.ppt">PowerPoint 文件</a>版本）</li>
<li><a href="porting/index.php">移植技巧提示</a> － 关于如何移植 Unix 软件到 Darwin 上的资料</li>
<li><a href="packaging/index.php">软件打包手册</a> － 如何创建和维护 Fink 软件包</li>
</ul>



<? include_once "footer.inc"; ?>
