#! /bin/sh
# vim: set sw=4 sts=4 ts=8 expandtab:
# $Id$
set -e
case `uname -r` in
    7.x) exec /usr/bin/osacompile.bin "$@";;
esac
myname=`basename "$0"`
if test ! -r /buildbox.conf; then
    echo "osacompile(buildbox): cannot read /buildbox.conf" >&2
    exit 2
fi
. /buildbox.conf
tmpdir=`/sw/sbin/mktemp -d -t -p "/private/tmp" osacompile.XXXXXXXX || :`
if test "x$tmpdir" = x; then
    echo "osacompile(buildbox): could not create temporary directory under /private/tmp" >&2
    exit 2
fi
trap 'rm -rf "$tmpdir" "$buildbox_root$tmpdir"' 0
if mkdir "$buildbox_root$tmpdir"; then :; else
    echo "osacompile(buildbox): could not create temporary directory under \$buildbox_root/private/tmp" >&2
    exit 2
fi

outfile="a.scpt"
first=true
opt_o=false
for arg in "$@"; do
    if $first; then
        set x; shift
        first=false
    fi
    if $opt_o; then
        outfile=$arg
        opt_o=false
    elif test "x$arg" = x-o; then
        opt_o=true
    else
        set x "$@" "$arg"; shift
    fi
done

case "$outfile" in
    *.app)
    if test -d "$outfile"; then
        /usr/bin/osacompile.bin -o "$outfile/Contents/Resources/Scripts/main.scpt" -d "$@"
    else
        outbase=`basename "$outfile"`
        /bin/mkdir -p "$buildbox_root$tmpdir/$outbase/Contents"
        /usr/bin/osacompile.bin -o "$tmpdir/$outbase" "$@"
        /usr/bin/ditto --rsrc "$tmpdir/$outbase" "$outfile"
        /bin/cp -p "$buildbox_root$tmpdir/$outbase/Contents/Info.plist" "$outfile/Contents"
    fi
    ;;
    *.scptd)
    if test -d "$outfile"; then
        /usr/bin/osacompile.bin -o "$outfile/Contents/Resources/Scripts/main.scpt" -d "$@"
    else
        /usr/bin/osacompile.bin -o "$outfile" "$@"
    fi
    ;;
    *)
    /usr/bin/osacompile.bin -o "$outfile" "$@"
    ;;
esac
# The temporary directory is removed at exit anyway
