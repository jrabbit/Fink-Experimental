#!/bin/sh

clear
echo "checking for libraries..."
LIBS=`(dpkg -L $* 2>/dev/null | grep -E '(dylib|so|bundle)$'; dpkg -L $* 2>/dev/null | grep '/bin/') | sort | uniq`
echo "scanning library dependencies..."
DEPS=`otool -L $LIBS 2>/dev/null | grep -v : | awk '{ print $1 }' | sort | uniq`
echo "backtracking packages..."
PACKAGES=`dpkg --search $DEPS 2>/dev/null | awk -F: '{ print $1 }' | sort | uniq`

echo ""
echo "Packages:"
for PACK in $PACKAGES; do
	echo "  $PACK"
done
echo ""
