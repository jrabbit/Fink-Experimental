#! /bin/sh 
#
# Shell script for preparing the user's shell startup scripts for Fink.
# Copyright (c) 2003-2004 Martin Costabel
# Copyright (c) 2003-2004 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#


# This version is tested for csh type user login shells and for bash, 
# for other sh type shells it does nothing.

# Function declarations:

do_login_test () {
# Start a login session to see whether the PATH is already set up for Fink. 
# PATH and SHELL are written into TMPFILE.
# We have to use basic shell speak here, because we don't know
# which shell will come up.
    /usr/bin/login -f $USER >$TMPFILE <<EOF
    /bin/echo -n LOGINSHELL= 
    /usr/bin/printenv SHELL
    /usr/bin/printenv PATH
    /bin/bash --norc --noprofile <<EOF2
#   For bash, we need a second opinion. 
#   We do the test for bash inside bash.
    if test $(/bin/echo $SHELL | /usr/bin/grep bash); then
	bash --login <<EOF3
        /usr/bin/printenv PATH
	exit
EOF3
    fi
    exit
EOF2
    exit
EOF
}

msg_title () {
    echo --------------------------------
    echo Setting up your Fink environment
    echo --------------------------------
}

msg_create () {
    echo I will create a file named $RC in your
    echo home directory, containing one line
    echo
    echo \\\"$SOURCECMD\\\"
}

msg_append () {
    echo I will append a line
    echo
    echo \\\"$SOURCECMD\\\"
    echo
    echo to the file $RC in your home directory.
}		       

msg_choose (){
    echo If you do not want me to do this, 
    echo you can answer \\\"No\\\" here  
    echo and do it later manually.
    echo
    echo Continue\?
    echo
}

display_choose () {
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\nYour login shell: $LOGINSHELL\n\n`$MSG` \n\n`msg_choose`\n" buttons {"No, thanks", "YES"} default button 2 with icon caution giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
}

display_result (){
# display final result
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n$Result\n" buttons {"OK"} default button 1 with icon caution giving up after 20
      set UserResponse to button returned of dd
   end tell
EOF
}

display_choose_do (){
# propose choice, append line to startup script, and verify if it worked
    answer=`display_choose`
    if [ "$answer" != "No, thanks" ]; then
	echo "" >> $HOME/$RC
	echo "$SOURCECMD" >> $HOME/$RC
	do_login_test
	if grep /sw/sbin $TMPFILE >/dev/null 2>&1 ; then
	    Result="\n Your Fink environment\n   should be fine now.\n"
	else
	    Result="\n
Hmm. I tried my best, but it still does not work.
The code I put into $RC has no effect.\n
Please check your $LOGINSHELL startup scripts.
Perhaps  some other file like\n
	    ~/.login\n
is resetting the PATH after $RC is executed.
		   \n"
	fi		    
    else
	Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}

msg_already_setup (){
    echo Your environment seems to be correctly
    echo set up for Fink already.
}

display_already_setup (){
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_already_setup`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
}
# End of function declarations

### Main program:

# A temporary file for communicating with a login shell 
TMPFILE=`/usr/bin/mktemp /tmp/resu.XXXXXX`

# Run a login shell to see whether the fink paths are already set up.
do_login_test

# Look whether /sw/sbin was in the PATH. 
# TODO: Test for other sensible things, too. 
if grep /sw/sbin $TMPFILE >/dev/null 2>&1 ; then
    # Yes: already set up
    display_already_setup
else
    # No: we need to do something
    eval `grep LOGINSHELL $TMPFILE`
    if [ -z $LOGINSHELL ]; then
	Result="\nYour startup scripts contain an error.\nI am giving up. Bye.\n"
	display_result
	exit
    fi
    LOGINSHELL=`basename $LOGINSHELL`
    case $LOGINSHELL in
    *csh)
    # For csh and tcsh
        SOURCECMD="source /sw/bin/init.csh"
        if [ -f $HOME/.tcshrc ]; then
	    RC=.tcshrc
	elif [ -f $HOME/.cshrc ]; then
	    RC=.cshrc
	else
	    RC=new
	fi
 	case $RC in
	new)
	    RC=.cshrc
	    MSG=msg_create
	    ;;
	*)
	    MSG=msg_append
	    ;;
	esac
	display_choose_do
    ;;
    bash)
    # Only bash here; other sh type shells are not supported
        SOURCECMD=". /sw/bin/init.sh"
        if [ -f $HOME/.bash_profile ]; then
	    RC=.bash_profile
	elif [ -f $HOME/.bash_login ]; then
	    RC=.bash_login
        elif [ -f $HOME/.profile ]; then
	    RC=.profile
	else
	    RC=new
	fi
	case $RC in
	  new)
	    RC=.profile
	    MSG=msg_create
	  ;;
	  *)
	    MSG=msg_append
	  ;;
	esac
	display_choose_do
    ;;
    *)
    # Any shell except *csh and bash
	Result="\n
Since you have changed your login shell to $LOGINSHELL,
I am confident that you know what you are doing.\n
So now add a line equivalent to
		
	source /sw/bin/init.sh

to one of your $LOGINSHELL startup scripts
and you will be set up for using Fink.
	    
    Have a nice day.
	    \n"
	display_result
    ;;
    esac	    
fi

rm -f $TMPFILE

# End of program.
