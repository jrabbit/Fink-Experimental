# $Id$

# process XML files with stylesheet to produce HTML

basedir = ..

STYLESHEET_WEBSITE = $(basedir)/finkdoc-website.i18n.xsl
WANT_HTML = 1
DESTDIR = faq

LANGUAGES = en ja
BASE_SOURCE = uguide.xml
BASE_TARGET = index.php intro.php install.php upgrade.php packages.php conf.php usage.php
WANT_HTML = 1
DESTDIR = doc/users-guide

#SOURCE = $(patsubst %.xml,%.xml, $(BASE_SOURCE))
#SOURCE += $(patsubst %.xml,%.ja.xml, $(BASE_SOURCE))
SOURCE = $(foreach  LANGUAGE, $(LANGUAGES), $(patsubst %.xml,%.$(LANGUAGE).xml, $(BASE_SOURCE)))

TARGET = $(BASE_TARGET)
TARGET += $(foreach  LANGUAGE, $(LANGUAGES), $(patsubst %.php,%.$(LANGUAGE).php, $(BASE_TARGET)))
TARGET += $(foreach  LANGUAGE, $(LANGUAGES), header.$(LANGUAGE).inc)

include $(basedir)/Makefile.i18n.common

# eof

