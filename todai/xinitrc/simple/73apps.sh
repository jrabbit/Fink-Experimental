# $Id$
: ${xinitrc_apps_term_enable=YES}
: ${xinitrc_apps_term_loginshell=NO}
case "`/usr/bin/uname -r`" in
    9*) xinitrc_apps_term_enable=NO ;;
esac

case x"${xinitrc_apps_termcmd-unset}" in
    xunset)
    xinitrc_apps__lsarg="-ls"
    if test -x "$fink_bindir/mlterm"; then
	xinitrc_apps_termcmd="$fink_bindir/mlterm"
	xinitrc_apps__lsarg="-L"
    elif test -x "$fink_bindir/urxvt"; then
	xinitrc_apps_termcmd="$fink_bindir/urxvt"
    elif test -x "$fink_bindir/rxvt"; then
	xinitrc_apps_termcmd="$fink_bindir/rxvt"
    elif test -x "$x_bindir/uxterm"; then
	xinitrc_apps_termcmd="$x_bindir/uxterm"
    elif test -x "$x_bindir/xterm"; then
	xinitrc_apps_termcmd="$x_bindir/xterm"
    else
	xinitrc_apps_termcmd="xterm"
    fi
    case x"$xinitrc_apps_term_loginshell" in
	x[Yy][Ee][Ss])
	xinitrc_apps_termcmd="$xinitrc_apps_termcmd $xinitrc_apps__lsarg"
	;;
    esac
    unset xinitrc_apps__lsarg
    ;;
esac

case x"$xinitrc_apps_term_enable" in
    x[Yy][Ee][Ss]) $xinitrc_apps_termcmd & ;;
esac
