#! /bin/sh
# $Id$
# vim: set sw=4:
set -e

myfullname="$0"
old_LANG="$LANG"
old_LC_ALL="$LC_ALL"
LANG=C
LC_ALL=C

showhelp() {
    cat << EOF
Syntax:
    $myname [option]... [var=value]... mode [mode-specific options]

Modes:
    build
    install
    clean
    distclean
    fink [-r,--release]

Options:
    -n, --dry-run   display commands without modifying any files
    -q, --quiet	    don't print informational messages
    -d, --debug	    debug $myname
    -h, --help	    show this message

Variables:
    prefix[=/sw]
    destdir[empty]
    srcdir[auto($mydir)]

Examples:
    $myname -q destdir=/sw/src/foobar install
    $myname clean
EOF
    return 0
}

badarg() {
    test "x$1" != x && extra=" $1"
    echo "Bad argument$extra; try $myname -h for more information." >&2
    return 2
}

# Following constructs do not work:
#   go some-command > somewhere
#   go some-command | another-command
#   go some-command && another-command
# Instead use go_r or go_p:
#   go_r somewhere some-command
#   go_p 'another-command' some-command
# Or do manually:
#   $show some-command \&\& another-command
#   $run some-command && $run another-command
go() {
    $show "$@"
    $run "$@"
}

go_r() {
    dst="$1"
    shift
    $show "$@" \> "$dst"
    case "x$run" in
	x:) ;;
	*) $run "$@" > "$dst" ;;
    esac
}

go_p() {
    dst="$1"
    shift
    eval '$show "$@" \| '"$dst"
    $run "$@" | $run eval "$dst"
}

go_cd() {
    $show cd "$1"
    cd "$1"
}

dobuild() {
    go $mkinstalldirscmd "$builddir"
    $show "creating build.sed"
    case "x$run" in
	x:) ;;
	*)
    $run cat > "$builddir/build.sed" << EOF
s|@PREFIX@|$prefix|g
s|@EXEC_PREFIX@|$exec_prefix|g
s|@MYDATADIR@|$mydatadir|g
s|@FINK_PREFIX@|$fink_prefix|g
EOF
	;;
    esac
    for src in "$srcdir"/sedsrc/*.in; do
	base=`basename "$src" .in`
	go_r "$builddir/$base" sed -f "$builddir/build.sed" "$src"
    done
}

doinstall() {
    go_cd "$builddir"
    go $mkinstalldirscmd -m 755 "$destdir$bindir"
    go $installcmd -m 755 user-ja-conf "$destdir$bindir"

    go $mkinstalldirscmd -m 755 "$destdir$mydatadir/skel"
    go $installcmd -m 644 dot.* "$destdir$mydatadir/skel"

    go $installcmd -m 755 xinitrc "$destdir$mydatadir"

    go $mkinstalldirscmd -m 755 "$destdir$fink_sysconfdir/emacs/site-start.d"
    go $installcmd -m 644 user-ja.el "$destdir$fink_sysconfdir/emacs/site-start.d/90user-ja.el"

    go $mkinstalldirscmd -m 755 "$destdir$fink_sysconfdir/profile.d"
    go $installcmd -m 755 user-ja.sh "$destdir$fink_sysconfdir/profile.d/zz90user-ja.sh"
    go $installcmd -m 755 user-ja.csh "$destdir$fink_sysconfdir/profile.d/zz90user-ja.csh"

    go $mkinstalldirscmd -m 755 "$destdir$sysconfdir/xinitrc.d"
    go $installcmd -m 755 xmodmap-ja.sh "$destdir$sysconfdir/xinitrc.d/21xmodmap-ja.sh"

    go_cd "$firstpwd"
    go_cd "$srcdir/etcmlterm"
    go $mkinstalldirscmd -m 755 "$destdir$mydatadir/etcmlterm"
    go $installcmd -m 644 font main menu "$destdir$mydatadir/etcmlterm"

    go_cd "../simple"
    go $installcmd -m 644 dot.* "$destdir$mydatadir/skel"

    go $installcmd -m 644 inputrc user-ja.canna "$destdir$mydatadir"

    go $mkinstalldirscmd -m 755 "$destdir$sitelispdir"
    go $installcmd -m 644 appleotffonts-ja.el "$destdir$sitelispdir"
 
    go $mkinstalldirscmd -m 755 "$destdir$fink_sysconfdir/gtk"
    go $installcmd -m 644 gtkrc.ja_JP.utf8 "$destdir$fink_sysconfdir/gtk/gtkrc.ja_JP.utf8"
    go $installcmd -m 644 gtkrc.ja_JP.eucjp "$destdir$fink_sysconfdir/gtk/gtkrc.ja_JP.eucjp"

    go $mkinstalldirscmd -m 755 "$destdir$fink_sysconfdir/app-defaults/ja_JP.UTF-8"
    go $installcmd -m 644 Emacs.ad "$destdir$fink_sysconfdir/app-defaults/ja_JP.UTF-8/Emacs"
}

doclean() {
    go rm -rf "$builddir" "$pkgname.info" "$pkgname.patch"
}

dodistclean() {
    doclean
    go_p 'xargs rm -f' find . -name "semantic.cache" -or -name "*~" -or -name "*.bak" -or -name ".*.swp"
}

dofink() {
    version=`cat $srcdir/version`
    case "$1" in
	-r|--release)
	cvsver=
	fullver="$version"
	;;
	"")
	#cvsver=`awk '\$1 ~ /Id:/ { print \$3}' $srcdir/ChangeLog`
	idline=`tail -1 "$srcdir/ChangeLog"`
	case "$idline" in
	    \$Id\$) cvsver=unknown ;;
	    \$Id": "*\$) cvsver=`(set $idline; echo $3)` ;;
	    *) echo "ChangeLog must contain RCSID at the last line" >&1; exit 1 ;;
	esac
	fullver="$version+cvs-$cvsver"
	;;
	*) badarg "$1"; exit ;;
    esac

    files=".cvsignore ChangeLog build.sh doc/ etcmlterm/ $pkgname.info.in sedsrc/ simple/ version"

    workdir="$pkgname-$fullver"
    go rm -rf "$workdir" "$workdir.dummy"
    trap 'go rm -rf "$workdir" "$workdir.dummy"' 0
    go mkdir "$workdir" "$workdir.dummy"
    $show \( cd "$srcdir" \&\& tar cf - $files \) \| \( cd "$workdir" \&\& tar xf - \)
    ( cd "$srcdir" && $run tar cf - $files ) | ( $run cd "$workdir" && $run tar xf - )
    go_p 'xargs rm -r' find "$workdir" -name CVS -type d
    set +e
    go_r "$pkgname.patch" diff -Nru "$workdir.dummy" "$workdir"
    set -e

    go_r "$pkgname.info" sed -e '/\$''Id/ { s/\$ *//; s/ *\$//; }' -e "s/@FULLVERSION@/$fullver/g" "$srcdir/$pkgname.info.in"
}

myname=`basename "$0"`
case "$myfullname" in
    */*) mydir=`echo "$myfullname" | sed 's|/[^/]*$||'` ;;
    *) mydir=. ;;
esac
pkgname="user-ja"

destdir=
srcdir="$mydir"
builddir="build"
firstpwd=`pwd`

mkinstalldirscmd="mkdir -p"
installcmd="install"
echocmd="echo"
# more portable way
#echo="printf '%s\n'"

run=
show="$echocmd"

mode=
while test "$#" -gt 0; do
    case "$1" in
	-n|--dry-run) run=: ;;
	-q|--quiet) show=: ;;
	-d|--debug) set -x ;;
	-h|--help) showhelp; exit ;;
	-*) badarg "$1"; exit ;;
	*=*) eval "$1" ;;
	*) mode="$1"; shift; break ;;
    esac
    shift
done

: ${prefix="/sw"}
: ${exec_prefix="${prefix}"}
: ${bindir="${exec_prefix}/bin"}
: ${sbindir="${exec_prefix}/sbin"}
: ${libexecdir="${exec_prefix}/lib"}
: ${datadir="${prefix}/share"}
: ${sysconfdir="${prefix}/etc"}
: ${sharedstatedir="${prefix}/var"}
: ${localstatedir="${prefix}/var"}
: ${libdir="${exec_prefix}/lib"}
: ${includedir="${prefix}/include"}
: ${oldincludedir="/usr/include"}
: ${infodir="${prefix}/share/info"}
: ${mandir="${prefix}/share/man"}
: ${mydatadir="${datadir}/$pkgname"}
: ${sitelispdir="${datadir}/emacs/site-lisp"}

: ${fink_prefix="/sw"}
: ${fink_sysconfdir="$fink_prefix/etc"}

case "$mode" in
    ""|help) showhelp; exit ;;
    build) dobuild "$@" ;;
    install) doinstall "$@" ;;
    clean) doclean "$@" ;;
    distclean) dodistclean "$@" ;;
    fink) dofink "$@" ;;
    *) badarg "$mode"; exit ;;
esac

