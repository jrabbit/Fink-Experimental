#!/bin/sh

if test -z "$1"; then
	echo "you must specify at least one directory!"
	exit 1
fi

CACHEDIR=/tmp/pch

INCLUDEDIRS=`find "$@" -type d -a ! -name \*.gch -exec echo -I{} \; | xargs echo`
find "$@" -name \*.h -type f | while read HEADER; do
	if test -f "$HEADER.gch"; then
		sudo rm -rf "$HEADER.gch"
	fi
	mkdir -p "$HEADER.gch"
	mkdir -p "$CACHEDIR"

	for type in "gcc:c" "g++:c++"; do
		COMPILER=`echo $type | cut -d: -f1`
		FILENAME=`echo $type | cut -d: -f2`
		echo -e "generating $HEADER.gch/$FILENAME.pch \c"
		transname=`echo $HEADER.gch/$FILENAME.pch | sed -e 's,//*,_,g'`
		if [ -f "$CACHEDIR/$transname" ] && ! [ -s "$HEADER.gch/$FILENAME.pch" ]; then
			echo "previously failed"
		elif [ "$HEADER" -nt "$HEADER.gch/$FILENAME.pch" ]; then
			if $COMPILER-no-cpp-precomp $INCLUDEDIRS -o $HEADER.gch/$FILENAME.pch $HEADER >/dev/null 2>&1 || \
				$COMPILER $INCLUDEDIRS -o $HEADER.gch/$FILENAME.pch $HEADER >/dev/null 2>&1; then
				echo "done"
			else
				echo "failed"
			fi
		else
			echo "exists"
		fi
		touch "$CACHEDIR/$transname"
	done
done
