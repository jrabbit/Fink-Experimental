#! /bin/sh
# vim: set sw=4 sts=4 ts=8 expandtab:
# $Id$
set -e
PATH=/sw/bin:/sw/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin
myname=`echo "x$0"|sed 's,^.*/,,'`
mydir=`echo "x$0"|sed 's,^x,,; s,/[^/]*$,,'`
if test ! -x "$0" || test -z "$myname" || test -z "$mydir"; then
    echo "Cannot detect my path" >&2;
    exit 2;
fi
#finkversion=0.7.2
#finktarball=fink-$finkversion-full.tar.gz
#finktardir=fink-$finkversion-full
finkversion=0.24.26
finktarball=fink-$finkversion.tar.gz
finktardir=fink-$finkversion
rsynccmd=/usr/bin/rsync
installcmd="/usr/bin/install -c -C"

go() {
    echo "$@"
    "$@"
}

updatemain() {
    go $rsynccmd --files-from="$mydir/buildbox.rsync" --exclude-from="$mydir/buildbox-exclude.rsync" -arv --delete / "$boxdir"
    go $rsynccmd -av --delete /Developer/Tools/*Rez* "$boxdir/Developer/Tools.orig/"
    go $rsynccmd -av --delete /usr/bin/emacs* "$boxdir/usr/sysemacs/"
    go $installcmd -m 755 /usr/bin/osacompile "$boxdir/usr/bin/osacompile.bin"
    case `uname -r` in
        7.*) go $installcmd -m 644 /private/etc/manpath.config "$boxdir/private/etc/manpath.config";;
    esac
    go $installcmd -m 755 "$mydir/fink-build-forever.bash" "$mydir/fink-remove-all.sh" "$boxdir/usr/local/admin"
    go $installcmd -m 644 "$mydir/dontremove.sed" "$boxdir/usr/local/admin"
    go $installcmd -m 755 "$mydir/buildbox-Rez.sh" "$boxdir/Developer/Tools/Rez"
    go $installcmd -m 755 "$mydir/buildbox-emacs.sh" "$boxdir/usr/bin/emacs"
    go $installcmd -m 755 "$mydir/buildbox-dummy.sh" "$boxdir"
    go $installcmd -m 755 "$mydir/buildbox-osacompile.sh" "$boxdir/usr/bin/osacompile"
    if test ! -r "$boxdir/buildbox.conf"; then
        boxdirsed='s|@BUILDBOX_ROOT@|'`echo "$boxdir"|sed "s/'/'\\\\\\\\''/g"';s/\\\\/\\\\\\\\/g;s/|/\\\\|/g'`'|g'
        echo sed "$boxdirsed" "$mydir/buildbox.conf.in" \> "$boxdir/buildbox.conf"
        sed "$boxdirsed" "$mydir/buildbox.conf.in" > "$boxdir/buildbox.conf"
    fi
    test -r "$boxdir/buildbox.fstab" || go $installcmd -m 644 buildbox.fstab "$boxdir"
    test -r "$boxdir/private/var/root/.bashrc" || go $installcmd -m 644 buildbox.bashrc "$boxdir/private/var/root/.bashrc"
    test -r "$boxdir/private/var/root/.zshrc" || go $installcmd -m 644 buildbox.zshrc "$boxdir/private/var/root/.zshrc"
    while read f; do
        case x$f in x|x\#*) continue;; esac
        l=`echo "x$f"|sed 's,^x,,; s,[^/]*$,buildbox-dummy.sh,; s,[^/]*/,../,g'`
        go ln -sf "$l" "$boxdir/$f"
    done < "$mydir/buildbox-usedummy.list"
}

case x$1 in
    x|xhelp|x-h|x-help|x--help)
    echo "$myname create|mount|umount|update|chroot|finkbootstrap|cvsup|cleantmp <boxdir>"
    exit 0
    ;;
    xcreate|xmount|xumount|xupdate|xchroot|xfinkbootstrap|xcvsup|xcleantmp)
    if test "x$2" = x; then
        echo "boxdir unspecified"
        exit 1
    fi
    mode=$1
    boxdir=$2
    shift; shift
    ;;
    *)
    echo "invalid argument; try $myname help" >&2
    exit 1;
esac

case $boxdir in
    /) echo "boxdir should not be the root directory" >&2; exit 1;;
    /*) fullboxdir=$boxdir;;
    *) fullboxdir=`pwd`/$boxdir;;
esac

case $mode in
    create)
    go mkdir -p "$boxdir"
    old_PWD=$PWD
    go cd "$boxdir"
    fakeboxroot=`echo "$boxdir" | sed 's,^/*,,'`
    go mkdir -p "$fakeboxroot/System/Library" "$fakeboxroot/private/tmp" .vol dev
    go mkdir -p private/etc/X11/xinit private/tmp usr/local/admin
    go mkdir -p private/var/backups private/var/tmp private/var/root private/var/mail private/var/log private/var/run
    go mkdir -p Library/StartupItems Library/Fonts System/Library/Fonts
    go chmod 1777 "$fakeboxroot/private/tmp" private/tmp private/var/tmp
    go chmod 775 private/var/mail
    go chown root:mail private/var/mail
    go rm -f private/etc/sudoers
    echo echo "root ALL=(ALL) ALL" \> private/etc/sudoers
    echo "root ALL=(ALL) ALL" > private/etc/sudoers
    go chown root:wheel private/etc/sudoers
    go chmod 440 private/etc/sudoers
    echo echo "# An extra line to make anacron.prerm happy" \> private/etc/crontab
    echo "# An extra line to make anacron.prerm happy" > private/etc/crontab
    go $installcmd -m 444 /private/etc/X11/xinit/xinitrc private/etc/X11/xinit
    go touch private/var/run/utmp private/var/log/wtmp private/var/log/lastlog
    go ln -sf private/etc private/tmp private/var .
    go ln -sf ../../../System/Library/ScriptingAdditions "$fakeboxroot/System/Library"
    cd "$old_PWD"
    updatemain
    echo "buildbox $boxdir created. you probably want to bootstrap fink."
    ;;
    mount)
    if test -c "$boxdir/dev/null"; then
        echo "$boxdir/dev is already mounted. run $myname umount $boxdir first!" >&2
        exit 1
    fi
    go mount_devfs devfs "$fullboxdir/dev"
    go mount_fdesc -o union fdesc "$fullboxdir/dev"
    go mount_volfs "$fullboxdir/.vol"
    if test -f "$boxdir/buildbox.fstab"; then
        while read fs_spec fs_file fs_vfstype fs_mntops extra; do
            case x$fs_spec in x|x\#*) continue;; esac
            case x$fs_file in x/*);; *) continue;; esac
            case x$fs_mntops in x?*) ops="-o $fs_mntops";; esac
            go mount -t "$fs_vfstype" $ops "$fs_spec" "$fullboxdir$fs_file"
        done < "$boxdir/buildbox.fstab"
    fi
    ;;
    umount)
    set +e
    err=0
    if test -f "$boxdir/buildbox.fstab"; then
        # unmount in reverse order
        mlist=
        while read fs_spec fs_file fs_vfstype fs_mntops extra; do
            case x$fs_spec in x|x\#*) continue;; esac
            case x$fs_file in x/*) ;; *) continue;; esac
            case x$mlist in x) mlist=$fs_file;; *) mlist="$fs_file#$mlist";; esac
        done < "$boxdir/buildbox.fstab"
        old_IFS=$IFS; IFS="#"
        set dummy $mlist; shift
        IFS=$old_IFS
        for fs_file; do
            go umount "$fullboxdir$fs_file" || err=$?
        done
    fi
    go umount "$fullboxdir/.vol" || err=$?
    go umount "$fullboxdir/dev" || err=$?
    go umount "$fullboxdir/dev" || err=$?
    exit $err
    ;;
    update)
    updatemain
    ;;
    chroot)
    if test ! -c "$boxdir/dev/null"; then
        echo "$boxdir/dev is not mounted. run $myname mount $boxdir first!" >&2
        exit 1
    fi
    HOME=/var/root; export HOME
    exec chroot "$boxdir" "$@"
    ;;
    finkbootstrap)
    if test ! -c "$boxdir/dev/null"; then
        echo "$boxdir/dev is not mounted. run $myname mount $boxdir first!" >&2
        exit 1
    fi
    go cd "$boxdir"
    if test ! -f "$finktarball"; then
        go curl -f -L -O "http://eu.dl.sourceforge.net/sourceforge/fink/$finktarball"
    fi
    if test ! -d "$finktardir"; then
        go tar zxf "$finktarball"
    fi
    HOME=/var/root; export HOME
    exec chroot "$boxdir" sh -c "cd '$finktardir' && time ./bootstrap.sh"
    ;;

    cvsup)
    (cd $boxdir/sw/fink/dists/ecc; cvs -Q update -dP) || exit $?
    if test -d $boxdir/sw/fink/dists/eccprivate; then
        (cd $boxdir/sw/fink/dists/eccprivate; cvs -Q update -dP) || exit $?
    fi
    ;;

    cleantmp)
    # -ctime is important because "fink validate" expands *.deb with old mtime
    for d in "$boxdir/private/tmp" "$boxdir/private/var/tmp"; do
        /usr/bin/find "$d" -fstype local ! -type d -atime +3 -ctime +3 -print0 | /usr/bin/xargs -0 rm -f -- || :
        /usr/bin/find -d "$d" -fstype local ! -path "$d" -type d -mtime +1 -ctime +3 -print0 | /usr/bin/xargs -0 rmdir -- || :
    done >/dev/null 2>&1
    ;;
esac
