#!/bin/sh

TOPDIR=/sw/fink/dists
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -e "$SSH_AUTH_SOCK" ]; then
	eval `ssh-agent -s`
	ssh-add ~/.ssh/id_dsa ~/.ssh/id_rsa
fi

for repository in `cd /sw/fink/dists; ls -1 | grep -v CVS`; do
	for dir in main crypto; do
		if [ -d $TOPDIR/$repository/$dir/finkinfo ]; then
			echo "- updating in $repository/$dir..."
			pushd $TOPDIR/$repository/$dir/finkinfo >/dev/null 2>&1
			cvs up
			popd >/dev/null 2>&1
		fi
	done
done

fink index
