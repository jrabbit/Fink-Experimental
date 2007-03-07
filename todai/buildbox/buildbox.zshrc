# Sample ~/.zshrc in buildbox
# $Id$
if test x${PS1+set} = xset; then
    PS1='%m(buildbox) %~%# '
    bindkey -e
fi
