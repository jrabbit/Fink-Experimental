# $Id$

# process XML files with stylesheet to produce HTML

CURRDATE := `date '+%a, %d %b %Y %H:%M:%S %Z'`

basedir = ..

SOURCE = news.xml
TARGET = index.php
#WANT_HTML = 1
WANT_RDF = 1
DESTDIR = news

# Custom stylesheet
STYLESHEET_WEBSITE = finknews.i18n.xsl
STYLESHEET_RDF = finknews-rdf.i18n.xsl

LANGUAGES = en zh
include $(basedir)/Makefile.i18n.common

# Custom rendering
#news.inc.tmp index.php.tmp: news.xml $(STYLESHEET_WEBSITE)
#	xmllint --noout --valid news.xml
#	xsltproc -o index.php.tmp $(STYLESHEET_WEBSITE) news.xml


# %.rdf: %.xml $(STYLESHEET_RDF)
#	xmllint --noout --valid $<
#	xsltproc --stringparam currdate "$(CURRDATE)" -o $@ $(STYLESHEET_RDF) $<

#%.inc: %.inc.tmp $(PROCESS_WEBSITE)
#	$(PROCESS_WEBSITE) <$< >$@

install-hook:
	@echo "Install inc files..."
	cp *.inc $(basedir)/web/$(DESTDIR)/
	@echo "Copy news.en.rdf to news.rdf"
	cp news.en.rdf $(basedir)/web/$(DESTDIR)/news.rdf

# eof
