# $Id$

# process XML files with stylesheet to produce HTML

basedir = ..

WANT_HTML = 1
DESTDIR = faq

LANGUAGES = en ja
BASE_SOURCE = faq.xml
BASE_TARGET = index.php general.php relations.php \
	 usage-fink.php comp-general.php comp-packages.php \
	 usage-general.php usage-packages.php upgrade-fink.php

#SOURCE = $(patsubst %.xml,%.xml, $(BASE_SOURCE))
#SOURCE += $(patsubst %.xml,%.ja.xml, $(BASE_SOURCE))
SOURCE = $(foreach  LANGUAGE, $(LANGUAGES), $(patsubst %.xml,%.$(LANGUAGE).xml, $(BASE_SOURCE)))

TARGET = $(foreach  LANGUAGE, $(LANGUAGES), $(patsubst %.php,%.$(LANGUAGE).php, $(BASE_TARGET)))

include $(basedir)/Makefile.common

# eof
