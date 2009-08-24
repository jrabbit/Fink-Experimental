#!/bin/sh -e
rsync -4 --address=85.214.23.162 -azv --delete --delete-after --exclude=LOCAL --exclude=TIMESTAMP rsync://distfiles.ber.de.eu.finkmirrors.net/finkinfo ~fink/finkinfo && \
printf "\n\n" && \
rsync -4 --address=85.214.23.162 -a --delete --delete-after rsync://distfiles.ber.de.eu.finkmirrors.net/finkinfo/TIMESTAMP ~fink/finkinfo
date -u +%s >~fink/finkinfo/LOCAL
