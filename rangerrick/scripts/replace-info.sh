#!/bin/sh

for file in `find /sw/fink/dists/local ~/cvs/darwin-kde/fink -name \*.info`; do
	perl -pi -e "$@" $file
done
