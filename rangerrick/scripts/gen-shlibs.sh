#!/bin/sh

get_package_shlibs() {
	PACKAGE="$1"; shift

	dpkg -L "$PACKAGE" | grep -E '.dylib$' | while read FILE; do
		if [ -f "$FILE" ]; then
			VERSION=`otool -L "$FILE" | grep -v "${FILE}:\$" | head -1 | awk '{ print $4 }' | sed -e 's/,//g'`
			if [ -n "$VERSION" ]; then
				echo "$FILE $VERSION $PACKAGE (>= 1.0-1)"
			fi
		fi
	done
}

for arg in "$@"; do
	get_package_shlibs "$arg"
done
