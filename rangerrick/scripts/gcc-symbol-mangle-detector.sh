#!/bin/sh -e

for PACKAGE in "$@"; do
	MATCH=0
	echo -e "${PACKAGE}: \c"
	dpkg -L "$PACKAGE" | while read FILE; do
		if [ "$MATCH" -eq 0 ] && [ -f "$FILE" ]; then
			if [ `file "$FILE" 2>/dev/null | grep -c "Mach-O"` -gt 0 ]; then
				nm "$FILE" > /tmp/$$.before
				c++filt < /tmp/$$.before > /tmp/$$.after
				COUNT=`diff /tmp/$$.before /tmp/$$.after | wc -l`
				if [ "$COUNT" -gt 0 ]; then
					echo "$PACKAGE: mangled"
					MATCH=1
					break 2
				fi
			fi
		fi
	done
	echo "$PACKAGE: not mangled"
done
