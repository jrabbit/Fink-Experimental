<a name="2004-02-19 升起你的国旗"><span class="news-date">2004-02-19: </span><span class="news-headline">升起你的国旗</span></a><?php gray_line(); ?>
	<p>
非常感谢马场美彦，Fink 已经完成了国际化所必需的准备工作。
经过改进的网站架构使得我们可以向来自全世界的用户显示一个多语种的网站。
</p>
<p>
这也意味着我们需要志愿者。Fink 网站需要翻译到你希望的语言。
日语的翻译已经在进行中，法语的翻译则已经由 Michèle Garoche 承担。
你希望翻译什么语言呢？
</p>
<p>
如果你愿意成为我们国际化团队的一员，或希望对我们的网站提供反馈意见，你尽管参加我们的新邮件列表。
你可以到我们的<a href="@ROOT@lists/index.php">邮件列表页面</a>去加入。关于现有的邮件列表的完整清单请阅读<a href="http://article.gmane.org/gmane.os.apple.fink.devel/7554">这里</a>。
</p>
<a name="2004-02-02 Java 1.4.2 升级会删除 Java SDK"><span class="news-date">2004-02-02: </span><span class="news-headline">Java 1.4.2 升级会删除 Java SDK</span></a><?php gray_line(); ?>
	<p>
如果你以前安装了 Java 1.4.1 及 Java SDK，苹果新的 Java 1.4.2 会升级Java 运行时到 1.4.2，
但会<b>删除</b>以前的 1.4.1 Java 运行时和 SDK，<b>而没有</b> 相应升级 JDK。要在 Fink 中构建 Java 软件包，
你需要到<a href="http://connect.apple.com/">connect.apple.com 下载 Java 1.4.2 SDK</a>(需要免费注册)。
	</p>
	<a name="2004-01-18 10.3 二进制更新"><span class="news-date">2004-01-18: </span><span class="news-headline">10.3 二进制更新</span></a><?php gray_line(); ?>
	<p>
许多针对 10.3 的二进制文件已经被更新，消除了 qt 和 kde 以及其它的一些问题。
要获取更新后的文件，运行 <code>sudo apt-get update</code> 命令来更新你的二进制文件索引。
在这之后，你可以使用 apt-get，dselect 或 FinkCommander 来象平常一样安装二进制文件。
	</p>
	
