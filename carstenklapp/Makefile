# Fink maintainer's utility to automatically validate fink info files.
#
# Put this file in /sw/fink/dists
# cd /sw/fink/dists
# Type 'make' for usage information.

p=/sw
DISTS=${p}/fink/dists

FINK=${p}/bin/fink
FINK_COMMAND=check
# trap grep errors for no matches
#FILTER_COMMAND=| grep -v "Description ends with" | grep	\
# "^Warning\|Error" || true
FILTER_COMMAND=| grep "^Warning\|Error" || true

BRANCHES=unstable stable

CHECKDIRS=base database devel editors games gnome graphics kde		\
 languages libs libs/perlmods net sci shells sound text utils web x11	\
 x11-system x11-wm
#CHECKDIRS=games x11-wm

usage :
	@echo " "
	@echo "Copyright 2002,"
	@echo "Carsten Klapp <carstenklapp@users.sourceforge.net>"
	@echo " "
	@echo "This file is an unsupported part of Fink."
	@echo " "
	@echo "Fink is free software; you can redistribute it and/or modify"
	@echo "it under the terms of the GNU General Public License as published by"
	@echo "the Free Software Foundation; either version 2 of the License, or"
	@echo "(at your option) any later version."
	@echo " "
	@echo "Fink is distributed in the hope that it will be useful,"
	@echo "but WITHOUT ANY WARRANTY; without even the implied warranty of"
	@echo "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the"
	@echo "GNU General Public License for more details."
	@echo " "
	@echo "You should have received a copy of the GNU General Public License"
	@echo "along with Fink; if not, write to the Free Software"
	@echo "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA"
	@echo " "
	@echo "$Id$"
	@echo " "
	@echo "Fink maintainer's utility to automatically validate fink info files."
	@echo " "
	@echo "Usage:"
	@echo " "
	@echo "make -j1 check    validate all fink info files"
	@echo " "
	@echo "make cleancvs     delete all cvs temp & emacs temp files (.#*) in ${p}"
	@echo "make clean        delete .DS_Store files in ${p}"
	@echo "make clean~       delete all backup files (*.info~ and *.patch~) in ${p}"
	@echo "make cleanall     do all three clean actions"
	@echo " "

$(CHECKDIRS) :
	@echo " "
	@cd $(DISTS)/$(DIST)/main/finkinfo/$@/ && pwd && $(FINK) $(FINK_COMMAND) *.info $(FILTER_COMMAND)

$(BRANCHES) :
	@echo "validating branch $@..."
	@echo " "
	@cd $(DISTS)/$@/crypto/finkinfo/ && pwd && $(FINK) $(FINK_COMMAND) *.info $(FILTER_COMMAND)
	@$(MAKE) $(CHECKDIRS) DIST=$@
	@echo "done branch $@."
	@echo " "

check : $(BRANCHES)

clean :
	@echo "Removing .DS_Store files...";
	sudo find ${p} -name .DS_Store -print -exec rm {} \;
	@echo "Done removing .DS_Store files."

cleancvs :
	@echo "Removing emacs & cvs .#* files...";
	sudo find ${p} -name '.#*' -print -exec rm {} \;
	@echo "Done removing emacs & cvs .#* files."

clean~ :
	@echo "Removing backup info~ and patch~ files...";
	sudo find ${p} -name '*.info~' -print -exec rm {} \;
	sudo find ${p} -name '*.patch~' -print -exec rm {} \;
	@echo "Done removing backup info~ and patch~ files."

cleanall : clean cleancvs clean~

