#!/bin/sh -e

: ${INFOFILE="openoffice.org.info.m4"}
: ${M4="/usr/bin/m4"}
if test -x "/sw/bin/curl"; then
    : ${CURL="/sw/bin/curl"}
else
    : ${CURL="/usr/bin/curl"}
fi
myname=`basename $0`

if test -x "/usr/bin/mktemp"; then
  tmpdir=`/usr/bin/mktemp -d "/tmp/$myname.XXXX"`
  # Just in case
  test -n "$tmpdir" || exit 1
else
  tmpdir=/tmp/$myname.$$
  mkdir "$tmpdir"
fi
trap 'rm -f "$tmpdir"/*.tmp; rmdir "$tmpdir"' 0

case x${SNAPSHOT+set} in
  xset) mode=DumpSnapshotMirrors;;
  x) mode=DumpMirrors;;
esac
$M4 -B32768 -S200 -DMODE=$mode "$INFOFILE" > "$tmpdir/mirrors.tmp"

exec 3< "$tmpdir/mirrors.tmp"
read version sourcespec <&3
source=`echo "$sourcespec" | sed "s/%v/$version/g"`
seq=1
while read enabled area url; do
  outputfile=`printf '%s/HEAD%03d.tmp' "$tmpdir" $seq`
  seq=`expr $seq + 1`
  case $enabled in
    1) disabled=;;
    0) disabled="DISABLED ";;
    *) exit 1;;
  esac
  {
    echo
    echo "${disabled}[${area}] ${url}"
    $CURL -fILsS "${url}${source}" 2>&1 &
  } > "$outputfile"
done <&3

wait

cat "$tmpdir"/HEAD*.tmp | tr -d '\r'
