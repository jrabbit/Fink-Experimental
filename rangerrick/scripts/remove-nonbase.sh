#!/bin/sh

dpkg --get-selections | \
	grep -E '[[:space:]]install$' | \
	grep -v '^apt[[:space:]]' | \
	grep -v '^apt-shlibs[[:space:]]' | \
	grep -v '^base-files[[:space:]]' | \
	grep -v '^bzip2[[:space:]]' | \
	grep -v '^debianutils[[:space:]]' | \
	grep -v '^dpkg[[:space:]]' | \
	grep -v '^fink[[:space:]]' | \
	grep -v '^gettext[[:space:]]' | \
	grep -v '^gzip[[:space:]]' | \
	grep -v '^libiconv[[:space:]]' | \
	grep -v '^ncurses[[:space:]]' | \
	grep -v '^storable-pm[[:space:]]' | \
	grep -v '^tar[[:space:]]' | \
	awk '{ print $1 }' | \
	xargs sudo dpkg -r

dpkg --get-selections | \
	grep -E '[[:space:]]install$' | \
	grep -v '^apt[[:space:]]' | \
	grep -v '^apt-shlibs[[:space:]]' | \
	grep -v '^base-files[[:space:]]' | \
	grep -v '^bzip2[[:space:]]' | \
	grep -v '^debianutils[[:space:]]' | \
	grep -v '^dpkg[[:space:]]' | \
	grep -v '^fink[[:space:]]' | \
	grep -v '^gettext[[:space:]]' | \
	grep -v '^gzip[[:space:]]' | \
	grep -v '^libiconv[[:space:]]' | \
	grep -v '^ncurses[[:space:]]' | \
	grep -v '^storable-pm[[:space:]]' | \
	grep -v '^tar[[:space:]]' | \
	awk '{ print $1 }' | \
	xargs sudo dpkg --purge

