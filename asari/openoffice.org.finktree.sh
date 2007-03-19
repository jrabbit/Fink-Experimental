#!/bin/sh
: ${INFOFILE="openoffice.org.info.m4"}
: ${M4="/usr/bin/m4"}
myname=`basename $0`

repo=`cat ../../dists/CVS/Repository 2>/dev/null || :`
case $repo in
    /cvsroot/fink/dists|dists) ;;
    *) echo "Not in the fink tree" >&2; exit 2;;
esac
set -e -x
for tree in 10.3 10.4-transitional 10.4; do
    $M4 -B32768 -S200 -DTREE="[$tree]" "$INFOFILE" > "../../dists/$tree/unstable/crypto/finkinfo/openoffice.org.info"
#    $M4 -B32768 -S200 -DTREE="[$tree]" -DUSE_FIREFOX=1 "$INFOFILE" > "../../dists/$tree/unstable/crypto/finkinfo/openoffice.org-firefox.info"
    cp openoffice.org.patch "../../dists/$tree/unstable/crypto/finkinfo/openoffice.org.patch"
    $M4 -B32768 -S200 -DTREE="[$tree]" -DUSE_CRYPTO=0 "$INFOFILE" > "../../dists/$tree/unstable/main/finkinfo/x11/openoffice.org-nocrypto.info"
    cp openoffice.org.patch "../../dists/$tree/unstable/main/finkinfo/x11/openoffice.org.patch"
done
