#!/bin/sh

KDEREL="1"

clear
echo "[$@]"
echo "checking for libraries..."
LIBS=`(dpkg -L "$@" 2>/dev/null | grep -E '(dylib$|so$|bundle$|/sbin/|/bin/)') | sort | uniq`
echo "scanning library dependencies..."
DEPS=`otool -L $LIBS 2>/dev/null | grep -v : | awk '{ print $1 }' | sort | uniq`
echo "backtracking packages..."
PACKAGES=`dpkg --search $DEPS 2>/dev/null | awk -F: '{ print $1 }' | sort | uniq`

echo ""
echo "Packages:"
PACKLIST=""
for PACK in $PACKAGES; do
	case $PACK in
#		)					PACKLIST="$PACKLIST, $PACK";;
		*-common)				PACKLIST="$PACKLIST, %N-common";;
		arts*)					PACKLIST="$PACKLIST, $PACK (>= 1.1.1-1)";;
		bzip2*)					;;
		dlcompat*)				PACKLIST="$PACKLIST, $PACK (>= 20021117-1)";;
		freetype2*-shlibs)			PACKLIST="$PACKLIST, freetype2-shlibs | freetype2-hinting-shlibs";;
		freetype2*)				PACKLIST="$PACKLIST, freetype2";;
		gettext*)				;;
		giflib-shlibs|libungif-shlibs)		PACKLIST="$PACKLIST, giflib-shlibs | libungif-shlibs";;
		giflib|libungif)			PACKLIST="$PACKLIST, giflib | libungif";;
		giflib-bin|libungif-bin)		PACKLIST="$PACKLIST, giflib-bin | libungif-bin";;
		imlib*)					PACKLIST="$PACKLIST, $PACK (>= 1.9.14-2)";;
		kdebase*-dev)				PACKLIST="$PACKLIST, kdebase3-ssl-dev (>= %v-${KDEREL}) | kdebase3-dev (>= %v-${KDEREL})";;
		kdebase*)				PACKLIST="$PACKLIST, kdebase3-ssl (>= %v-${KDEREL}) | kdebase3 (>= %v-${KDEREL})";;
		kdelibs*-dev)				PACKLIST="$PACKLIST, kdelibs3-ssl-dev (>= %v-${KDEREL}) | kdelibs3-dev (>= %v-${KDEREL})";;
		kdelibs*)				PACKLIST="$PACKLIST, kdelibs3-ssl (>= %v-${KDEREL})| kdelibs3 (>= %v-${KDEREL})";;
		libiconv*)				;;
		libpng3*)				PACKLIST="$PACKLIST, $PACK (>= 1.2.5-4)";;
		libpoll*)				PACKLIST="$PACKLIST, $PACK (>= 1.1-1)";;
		libxml2*)				PACKLIST="$PACKLIST, $PACK (>= 2.5.2-1)";;
		libxslt*)				PACKLIST="$PACKLIST, $PACK (>= 1.0.27-1)";;
		ncurses*)				;;
		openslp*-dev)				PACKLIST="$PACKLIST, openslp-ssl-dev | openslp-dev";;
		openslp*-shlibs)			PACKLIST="$PACKLIST, openslp-ssl-shlibs | openslp-shlibs";;
		openslp*-doc)				PACKLIST="$PACKLIST, openslp-ssl-doc | openslp-doc";;
		openslp*)				PACKLIST="$PACKLIST, openslp-ssl | openslp";;
		pilot-link9*)				PACKLIST="$PACKLIST, $PACK";;
		qt3*)					PACKLIST="$PACKLIST, $PACK (>= 3.1.0-1)";;
		system-xfree86|xfree86-*)		if echo $PACKLIST | grep -v -q "x11"; then PACKLIST="$PACKLIST, x11"; fi;;
		tcltk*)					PACKLIST="$PACKLIST, $PACK";;
		*)
			case "$@" in
				*${PACK}*)
					echo "self-referential: $PACK"
					;;
				*)
					echo "warning, $PACK has no version"; PACKLIST="$PACKLIST, $PACK"
					;;
			esac
			;;
	esac
done
PACKLIST=`echo $PACKLIST | sed -e 's#^, ##'`
echo ${PACKLIST}, '%N-base'
echo ""
