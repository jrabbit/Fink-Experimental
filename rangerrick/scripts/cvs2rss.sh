#!/bin/sh -e

DIRNAME=`dirname $0`
DIRNAME=`cd $DIRNAME; pwd`

export CVS_RSH="$HOME/bin/ssh.sh"

pushd "$DIRNAME/.." >/dev/null 2>&1
echo "=== running 'cvs up' ==="
cvs up
echo "=== running cvs2cl ==="
$DIRNAME/cvs2cl.pl --xml --stdout > ChangeLog.xml
echo "=== running xsltproc ==="
xsltproc $DIRNAME/filter-cvs2cl.xslt ChangeLog.xml > ChangeLog-rangerrick.rdf
cp ChangeLog-rangerrick.rdf $HOME/public_html/misc/
popd >/dev/null 2>&1
