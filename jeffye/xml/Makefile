# $Id$

# generate all documents

SUBDIRS = \
	cvsaccess \
	doc \
	faq \
	fink-readme \
	install \
	news \
	packaging \
	porting \
	usage \
	users-guide \
	x11

all clean force install check:
	@for i in $(SUBDIRS) ; do \
	  $(MAKE) -C $$i -w $@ ; \
	done

.PHONY: all clean force install

# eof
