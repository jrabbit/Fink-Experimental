# $Id$

# process XML files with stylesheet to produce HTML

CURRDATE := `date '+%a, %d %b %Y %H:%M:%S %Z'`

basedir = ..

SOURCE = news.xml
TARGET = index.php news.rdf
#WANT_HTML = 1
DESTDIR = news

# Custom stylesheet
STYLESHEET_WEBSITE = finknews.i18n.xsl
STYLESHEET_RDF = finknews-rdf.xsl

LANGUAGES = en zh
include $(basedir)/Makefile.i18n.common

# Custom rendering
#news.inc.tmp index.php.tmp: news.xml $(STYLESHEET_WEBSITE)
#	xmllint --noout --valid news.xml
#	xsltproc -o index.php.tmp $(STYLESHEET_WEBSITE) news.xml

# Now, we only generate RDF from english version
news.rdf: news.en.xml $(STYLESHEET_RDF)
	xmllint --noout --valid news.en.xml
	xsltproc --stringparam currdate "$(CURRDATE)" -o news.rdf $(STYLESHEET_RDF) news.en.xml

#%.inc: %.inc.tmp $(PROCESS_WEBSITE)
#	$(PROCESS_WEBSITE) <$< >$@

install-hook:
	@echo "Installing RDF file(s)..."
	cp *.rdf $(basedir)/web/$(DESTDIR)/

# eof
