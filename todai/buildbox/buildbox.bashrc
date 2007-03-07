# Sample ~/.bashrc in buildbox
# $Id$
if test x${PS1+set} = xset; then
    PS1='\h(buildbox):\w \u\$ '
    shopt -s checkwinsize
fi
