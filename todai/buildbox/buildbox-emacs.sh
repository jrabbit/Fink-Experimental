#!/bin/sh
# vim: set sw=4 sts=4 ts=8 expandtab:
# $Id$
if test ! -r /buildbox.conf; then
    echo "/usr/bin/emacs(buildbox): cannot read /buildbox.conf" >&2
    exit 2
fi
. /buildbox.conf
case $disable_sys_emacs in
    [Yy][Ee][Ss])
    echo "/usr/bin/emacs(buildbox): disabled by buildbox.conf" >&2
    exit 2
    ;;
esac
case `uname -p` in
    i386) test -x /usr/sysemacs/emacs-i386 && exec /usr/sysemacs/emacs-i386 "$@";;
    powerpc) test -x /usr/sysemacs/emacs-ppc && exec /usr/sysemacs/emacs-ppc "$@";;
esac
exec /usr/sysemacs/emacs "$@"
