<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.1">

<!-- set the variables used throughout the document -->
<xsl:variable name="lang-ext" ><xsl:value-of select="news/@lang" /></xsl:variable>

<!-- just a dummy, everything is written with xsl:document -->
<xsl:output method="text" />

<!-- ***** whole document (renders contents page) ***** -->

<xsl:template match="news">

<!-- main php file, select the language automatically -->
<xsl:document href="{@filename}.php" method="html" indent="no" encoding="utf-8">
<xsl:text disable-output-escaping="yes">&lt;? include_once &quot;</xsl:text>
<xsl:value-of select="@fsroot"/>
<xsl:text disable-output-escaping="yes">phpLang.inc.php&quot;; ?&gt;</xsl:text>
</xsl:document>

<!-- localized .php.tmp -->
<xsl:document href="{@filename}.{$lang-ext}.php.tmp" method="html" indent="no" encoding="utf-8">
<!-- Header -->
<html><head>
<!-- this will be seen and then removed by postprocess.pl -->
<xsl:value-of select="cvsid" />
<title>News</title>
</head><body>

<!-- News items -->
<xsl:apply-templates select="newsitem" />

<!-- Footer -->
</body></html>
</xsl:document>


<!-- First three news items for the front page -->
<xsl:document href="{@xml:base}news.{$lang-ext}.inc" method="html" indent="no" encoding="utf-8">
<xsl:apply-templates select="newsitem[position()&lt;=3]" />
</xsl:document>

<!-- main inc file, select the language automatically -->
<xsl:document href="{@xml:base}news.inc" method="html" indent="no" encoding="utf-8">
<xsl:text disable-output-escaping="yes">&lt;? include_once &quot;phpLang.inc.php&quot;; $lang_code = 'en'; if ((phpLang_current)) $lang_code=phpLang_current; if (is_readable (&quot;</xsl:text>
<xsl:value-of select="@newsdir"/>
<xsl:text disable-output-escaping="yes">news.&quot; . $lang_code . &quot;.inc&quot;)) include_once &quot;news.&quot; . $lang_code . &quot;.inc&quot;; else include_once &quot;news.en.inc&quot;; ?&gt;</xsl:text>
</xsl:document>


</xsl:template>

<xsl:template match="newsitem">

<xsl:choose>
  <xsl:when test="boolean(headline)">
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="date" /><xsl:text> </xsl:text><xsl:value-of select="headline/@ref" />
      </xsl:attribute>
      <span class="news-date"><xsl:value-of select="date" /><xsl:text>: </xsl:text></span>
      <span class="news-headline"><xsl:value-of select="headline" /></span>
    </a>
  </xsl:when>
  <xsl:otherwise>
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="date" />
      </xsl:attribute>
      <span class="news-date"><xsl:value-of select="date" /></span>
    </a>
  </xsl:otherwise>
</xsl:choose>

<xsl:processing-instruction name="php">gray_line(); ?</xsl:processing-instruction>
<xsl:apply-templates select="body" />

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

<xsl:template match="cvsid">
<xsl:text>
</xsl:text>
<p><hr/><xsl:text>Generated from </xsl:text><i><xsl:apply-templates/></i></p>
</xsl:template>


<!-- ***** character-level elements ***** -->

<xsl:template match="em">
<b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="i">
<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="code|filename">
<code><xsl:apply-templates/></code>
</xsl:template>

<xsl:template match="link">
  <a>
    <xsl:attribute name="href">
      <xsl:text>@ROOT@</xsl:text>
      <xsl:value-of select="@url" />
    </xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<xsl:template match="extlink">
<a href="{@url}"><xsl:apply-templates/></a>
</xsl:template>

</xsl:stylesheet>
