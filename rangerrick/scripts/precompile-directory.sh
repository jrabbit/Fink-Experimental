#!/bin/sh

if [[ "$1" = "-v" ]]; then
	VERBOSE=true
	shift
fi

if [[ -z "$1" ]]; then
	echo "usage: $0 [-v] [directory1..directoryN]"
	exit 1
fi

CACHEDIR=/tmp/pch
if [[ -f "$CACHEDIR/last-updated" ]]; then
	NEWER="-newer $CACHEDIR/last-updated"
fi

INCLUDEDIRS=`find "$@" -type d -a ! -name \*.gch -exec echo -I{} \; | xargs echo`
find "$@" -name \*.h -type f $NEWER | while read HEADER; do
	if [[ -f "$HEADER.gch" ]]; then
		sudo rm -rf "$HEADER.gch"
	fi
	mkdir -p "$HEADER.gch"
	mkdir -p "$CACHEDIR"

	for type in "gcc:c" "g++:c++"; do
		COMPILER=`echo $type | cut -d: -f1`
		FILENAME=`echo $type | cut -d: -f2`
		if [[ "$VERBOSE" = "true" ]]; then
			echo -e "generating $HEADER.gch/$FILENAME.pch \c"
		fi
		transname=`echo $HEADER.gch/$FILENAME.pch | sed -e 's,//*,_,g'`
		if [[ -f "$CACHEDIR/$transname" ]] && ! [[ -s "$HEADER.gch/$FILENAME.pch" ]]; then
			if [[ "$VERBOSE" = "true" ]]; then
				echo "previously failed"
			fi
		elif [[ "$HEADER" -nt "$HEADER.gch/$FILENAME.pch" ]]; then
			if $COMPILER-no-cpp-precomp $INCLUDEDIRS -o $HEADER.gch/$FILENAME.pch $HEADER >/dev/null 2>&1 || \
				$COMPILER $INCLUDEDIRS -o $HEADER.gch/$FILENAME.pch $HEADER >/dev/null 2>&1; then
				if [[ "$VERBOSE" = "true" ]]; then
					echo "done"
				else
					echo "$HEADER precompiled for $FILENAME"
				fi
			else
				[[ "$VERBOSE" = "true" ]] && echo "failed"
			fi
		else
			[[ "$VERBOSE" = "true" ]] && echo "exists"
		fi
		touch "$CACHEDIR/$transname"
	done
done

touch "$CACHEDIR/last-updated"
