# $Id$
: ${xinitrc_dispconf_xrdb_enable=YES}
: ${xinitrc_dispconf_sysresources="$x_xinitdir/.Xresources"}
: ${xinitrc_dispconf_userresources="$HOME/.Xresources"}
: ${xinitrc_dispconf_xmodmap_enable=YES}
: ${xinitrc_dispconf_sysmodmap="$x_xinitdir/.Xmodmap"}
: ${xinitrc_dispconf_usermodmap="$HOME/.Xmodmap"}

case "x$xinitrc_dispconf_xrdb_enable" in
    x[Yy][Ee][Ss])
    if test -f "$xinitrc_dispconf_sysresources"; then
	xrdb -merge "$xinitrc_dispconf_sysresources"
    fi
    if test -f "$xinitrc_dispconf_userresources"; then
	xrdb -merge "$xinitrc_dispconf_userresources"
    fi
    ;;
esac

case "x$xinitrc_dispconf_xmodmap_enable" in
    x[Yy][Ee][Ss])
    if test -f "$xinitrc_dispconf_sysmodmap"; then
	xmodmap "$xinitrc_dispconf_sysmodmap"
    fi
    if test -f "$xinitrc_dispconf_usermodmap"; then
	xmodmap "$xinitrc_dispconf_usermodmap"
    fi
    ;;
esac
