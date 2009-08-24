#!/bin/sh
rsync -av --delete --delete-after rsync://distfiles.master.finkmirrors.net/finkbindist ~fink/finkbindist
printf "\n\n"
cp -av ~fink/public_html/hostlogo.inc ~fink/finkbindist/hostlogo.inc
cp -av ~fink/public_html/hostlogo.inc ~fink/bindist/hostlogo.inc
ln -sf ~fink/distfiles ~fink/bindist/source
rm -v ~fink/bindist/fink.css ~fink/bindist/dists/fink.css
cp -av ~fink/public_html/fink.css ~fink/bindist/fink.css
cp -av ~fink/public_html/fink.css ~fink/bindist/dists/fink.css
