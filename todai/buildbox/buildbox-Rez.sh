#! /bin/sh
# vim: set sw=4 sts=4 ts=8 expandtab:
# $Id$
set -e
myname=`basename "$0"`
if test ! -r /buildbox.conf; then
    echo "Rez(buildbox): cannot read /buildbox.conf" >&2
    exit 2
fi
. /buildbox.conf
tmpdir=`/sw/sbin/mktemp -d -t -p "/private/tmp" Rez.XXXXXXXX || :`
if test "x$tmpdir" = x; then
    echo "Rez(buildbox): could not create temporary directory under /private/tmp" >&2
    exit 2
fi
trap 'rm -rf "$tmpdir" "$buildbox_root$tmpdir"' 0
if mkdir "$buildbox_root$tmpdir"; then :; else
    echo "Rez(buildbox): could not create temporary directory under \$buildbox_root/private/tmp" >&2
    exit 2
fi

outfile="/tmp/Rez.out"
first=true
opt_o=false
for arg; do
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

if test -f "$outfile"; then
    /Developer/Tools/CpMac "$outfile" "$tmpdir/Rez.out"
fi
/Developer/Tools.orig/Rez "$@" -o "$buildbox_root$tmpdir/Rez.out"
/Developer/Tools/CpMac "$tmpdir/Rez.out" "$outfile"
# The temporary directory is removed at exit anyway
