<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.1">

<!-- set the variables used throughout the document -->
<xsl:variable name="lang-ext" ><xsl:text>.</xsl:text><xsl:value-of select="document/@lang" /></xsl:variable>

<!-- just a dummy, everything is written with xsl:document -->
<xsl:output method="text"/>

<!-- ***** whole document (renders contents page) ***** -->

<xsl:template match="document">

<xsl:document href="{@filename}{$lang-ext}.php" method="html" indent="no" encoding="utf-8">
<xsl:text disable-output-escaping="yes">&lt;?</xsl:text>

$title = "<xsl:value-of select="shorttitle"/>";
$cvs_author = '$Id$';
$cvs_date = '$Id$';
$metatags = '<link rel="contents" href="{@filename}{$lang-ext}.php" title="{shorttitle} Contents" />
<link rel="next" href="{chapter/@filename}{$lang-ext}.php" title="{chapter/title}" />';

include_once "header<xsl:value-of select="$lang-ext" />.inc"; 
<xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 

<h1><xsl:value-of select="title"/></h1>

<xsl:apply-templates select="preface" />

<!-- start TOC -->

<h2><xsl:text>Contents</xsl:text></h2>

<ul><xsl:text>
</xsl:text>
<xsl:for-each select="chapter">
<li><a><xsl:attribute name="href">
<xsl:value-of select="@filename"/><xsl:value-of select="$lang-ext"/><xsl:text>.php</xsl:text>
</xsl:attribute>
<b><xsl:number format="1 " /><xsl:value-of select="title" /></b></a></li><xsl:text>
</xsl:text>

<ul><xsl:text>
</xsl:text>
<xsl:for-each select="faqentry|section">
<li><a><xsl:attribute name="href">
<xsl:value-of select="../@filename" /><xsl:value-of select="$lang-ext"/><xsl:text>.php</xsl:text><xsl:text>#</xsl:text><xsl:value-of select="@name" />
</xsl:attribute>
<xsl:number count="chapter" format="1." /><xsl:number format="1 " />
<xsl:for-each select="question/p">
<xsl:if test='position() = 1'><xsl:call-template name="plain"/></xsl:if>
</xsl:for-each>
<xsl:value-of select="title" />
</a></li><xsl:text>
</xsl:text>
</xsl:for-each>
</ul><xsl:text>
</xsl:text>

</xsl:for-each>
</ul>

<!-- end TOC -->

<xsl:apply-templates select="cvsid" />

<xsl:apply-templates select="chapter" />

<xsl:text disable-output-escaping="yes">&lt;?</xsl:text> include_once "../footer.inc"; <xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 
</xsl:document>

<!-- Generate header.inc -->
<xsl:document href="{@xml:base}header{$lang-ext}.inc" method="text" indent="no" encoding="utf-8">
<xsl:text>&lt;?
/* This file is generated, do not edit manually! */

$section = "</xsl:text><xsl:value-of select="@section"/><xsl:text>";
$parents = array("doc/index.php", "Document List");
$navbox = array(
  "</xsl:text>
<xsl:value-of select="$DESTDIR"/>
<xsl:text>index.php", "Contents",
</xsl:text>
<xsl:for-each select="chapter">
<xsl:text>  "</xsl:text><xsl:value-of select="$DESTDIR"/><xsl:value-of select="@filename"/><xsl:text>.php</xsl:text><xsl:text>", "</xsl:text>
<xsl:value-of select="shorttitle"/>
<xsl:text>",
</xsl:text>
</xsl:for-each>
<xsl:text>);
$printlink = "</xsl:text>
<xsl:value-of select="$DESTDIR"/><xsl:value-of select="$PRINTFILE"/>
<xsl:text>";

$fsroot = $root = "</xsl:text><xsl:value-of select="@fsroot"/><xsl:text>";
include $fsroot."header.inc";
?&gt;
</xsl:text>
</xsl:document>

</xsl:template>

<!-- ***** chapter (renders to a separate file) ***** -->

<xsl:template match="chapter">
<xsl:document href="{@filename}{$lang-ext}.php" method="html" indent="no" encoding="utf-8">
<xsl:text disable-output-escaping="yes">&lt;?</xsl:text>

$title = "<xsl:value-of select="../shorttitle"/> - <xsl:value-of select="shorttitle"/>";
$cvs_author = 'Author: <xsl:value-of select="../cvsid" />';
$cvs_date = 'Date: <xsl:value-of select="../cvsid" />';
$metatags = '<link rel="contents" href="{../@filename}.php" title="{../shorttitle} Contents" />
<xsl:for-each select="following-sibling::chapter">
<xsl:if test="position()=1">
<link rel="next" href="{@filename}.php" title="{title}" />
</xsl:if>
</xsl:for-each>
<xsl:for-each select="preceding-sibling::chapter">
<xsl:if test="position()=last()">
<link rel="prev" href="{@filename}.php" title="{title}" />
</xsl:if>
</xsl:for-each>
<xsl:if test="position()=1">
<link rel="prev" href="{../@filename}{$lang-ext}.php" title="{../shorttitle} Contents" />
</xsl:if>';

include_once "header<xsl:value-of select="$lang-ext" />.inc"; 
<xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 

<h1><xsl:value-of select="../shorttitle"/><xsl:text> - </xsl:text><xsl:number format="1 " /><xsl:value-of select="title"/></h1>

<xsl:apply-templates/>

<xsl:for-each select="following-sibling::chapter">
<xsl:if test="position()=1">
<p align="right">
Next: <a href="{@filename}.php"><xsl:number format="1 " /><xsl:value-of select="title" /></a>
</p>
</xsl:if>
</xsl:for-each>

<xsl:text disable-output-escaping="yes">&lt;?</xsl:text> include_once "../footer.inc"; <xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 
</xsl:document>
</xsl:template>

<!-- ***** article (renders all on one page) ***** -->

<xsl:template match="article">
<xsl:document href="{@filename}{$lang-ext}.php" method="html" indent="no" encoding="utf-8">
<xsl:text disable-output-escaping="yes">&lt;?</xsl:text>
$title = "<xsl:value-of select="shorttitle" />";
$cvs_author = '$Id$';
$cvs_date = '$Id$';
include_once "header<xsl:value-of select="$lang-ext" />.inc"; 
<xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 

<h1><xsl:value-of select="title"/></h1>

<xsl:apply-templates select="cvsid" />

<xsl:apply-templates select="preface" />

<xsl:apply-templates select="section" />

<xsl:text disable-output-escaping="yes">&lt;?</xsl:text> include_once "../footer.inc"; <xsl:text disable-output-escaping="yes">?&gt;</xsl:text> 

</xsl:document>
</xsl:template>


<!-- ***** other structure elements ***** -->

<xsl:template match="preface">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="section">
<h2><a name="{@name}">
<xsl:if test="boolean(//document)">
<xsl:number count="chapter" format="1." /><xsl:number format="1 " />
</xsl:if>
<xsl:value-of select="title"/></a></h2>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="faqentry">
<a name="{@name}"><xsl:apply-templates/></a>
</xsl:template>

<xsl:template match="question">
<div class="question">
<p><b>Q<xsl:number count="chapter" format="1." /><xsl:number count="faqentry" format="1" /><xsl:text>: </xsl:text>
<xsl:for-each select="p">
<xsl:if test='position() = 1'><xsl:call-template name="plain" /></xsl:if>
</xsl:for-each>
</b></p>
<xsl:for-each select="p">
<xsl:if test='position() > 1'><xsl:apply-templates select="." /></xsl:if>
</xsl:for-each>
</div>
</xsl:template>

<xsl:template match="answer">
<div class="answer">
<p><b>A:</b><xsl:text> </xsl:text>
<xsl:for-each select="p">
<xsl:if test='position() = 1'><xsl:call-template name="plain" /></xsl:if>
</xsl:for-each>
</p>
<xsl:for-each select="p | codeblock | ul">
<xsl:if test='position() > 1'><xsl:apply-templates select="." /></xsl:if>
</xsl:for-each>
</div>
</xsl:template>

<!-- ***** block-level elements ***** -->

<xsl:template match="p">
<p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="codeblock">
<pre><xsl:apply-templates/></pre>
</xsl:template>

<xsl:template match="ol">
<ol><xsl:apply-templates/></ol>
</xsl:template>

<xsl:template match="ul">
<ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="li">
<li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="itemtable">
<table border="0" cellpadding="0" cellspacing="10">
<tr valign="bottom"><th align="left"><xsl:value-of select="@labelt" /></th><th align="left"><xsl:value-of select="@labeld" /></th></tr>
<xsl:apply-templates select="item" />
</table>
</xsl:template>

<xsl:template match="item">
<tr valign="top"><td><xsl:apply-templates select="itemt" /></td>
<td><xsl:apply-templates select="itemd" /></td></tr>
</xsl:template>

<xsl:template match="itemt|itemd">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="cvsid">
<p><xsl:text>Generated from </xsl:text><i><xsl:apply-templates/></i></p>
</xsl:template>


<!-- ***** character-level elements ***** -->

<xsl:template match="em">
<b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="i">
<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="quote">
<q><xsl:apply-templates/></q>
</xsl:template>

<xsl:template match="code|filename">
<code><xsl:apply-templates/></code>
</xsl:template>

<xsl:template match="link">
<a href="{@url}"><xsl:apply-templates/></a>
</xsl:template>

<xsl:template match="varlink">
<a href="{@url}"><xsl:apply-templates/></a>
</xsl:template>

<xsl:template match="xref">
<a><xsl:attribute name="href">
<xsl:if test="boolean(@chapter)"><xsl:value-of select="@chapter" />.<xsl:value-of select="../@lang" />.php</xsl:if>
<xsl:if test="boolean(@section)">#<xsl:value-of select="@section" /></xsl:if>
</xsl:attribute>
<xsl:apply-templates/></a>
</xsl:template>


<!-- *** special stuff *** -->

<xsl:template match="title|shorttitle">
</xsl:template>

<xsl:template name="plain">
<xsl:apply-templates/>
</xsl:template>



</xsl:stylesheet>
