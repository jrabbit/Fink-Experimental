#! /bin/sh
# Shell script for preparing the user's shell startup scripts for Fink.
# (C) 2003 Martin Costabel
# This version is tested for csh type user login shells and for bash, 
# for other sh type shells it does nothing.

# Function declarations:

do_login_test () {
# Start a login session to see whether the PATH is already set up for Fink. 
# PATH and SHELL are written into TMPFILE
#
    /usr/bin/login -f $USER >$TMPFILE <<EOF
    /bin/echo -n LOGINSHELL= 
    /usr/bin/printenv SHELL
    /usr/bin/printenv PATH
    /bin/bash --norc --noprofile <<EOF2
#   for bash, we need a second opinion 
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

msg_create () {
    echo
    echo I will create a file named $RC in your
    echo home directory, containing one line
    echo \"$SOURCECMD\"
}

msg_append () {
    echo
    echo I will append a line
    echo \"$SOURCECMD\"
    echo to the file $RC in your home directory.
}		       

msg_choose_do () {
# propose choice, append line to startup script, and verify if it worked
    echo
    echo If you don\'t want me to do this, you can answer
    echo \"no\" here and do it later manually.
    echo Otherwise answer \"yes\".
    echo
    echo -n "Do you want to continue? [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ -z "$answer" -o "x$answer" = "xy" ]; then
	echo "$SOURCECMD" >> $HOME/$RC
	echo
	echo Done. Verifying...
	do_login_test
	if grep sw/sbin $TMPFILE >/dev/null 2>&1 ; then
	    echo ... OK. You should be fine now.
	else
	    echo Hmm. I tried my best, but it still doesn\'t work.
	    echo The code I put into $RC has no effect.
	    echo Please check your $LOGINSHELL startup scripts.
	    echo Perhaps there is some other file like ~/.login
	    echo that resets the PATH after $RC is executed. Bye.
	fi		    
	echo
    else
	echo
	echo OK, as you wish. You are on your own. Bye.
	echo
    fi		
    echo Have a nice day.
    echo
}
# End of function declarations

### Main program:

# A temporary file for communicating with a login shell 
TMPFILE=`/usr/bin/mktemp /tmp/resu.XXXXXX`

# Run a login shell to see whether the fink paths are already set up.
do_login_test

# Look whether sw/sbin was in the PATH. 
# TODO: Test for other sensible things, too. 
if grep sw/sbin $TMPFILE >/dev/null 2>&1 ; then
    # Yes: already set up
    echo 
    echo Your environment seems to be correctly
    echo set up for Fink already.
    echo
else
    # No: we need to do something
    echo
    echo Setting up your fink environment
    echo --------------------------------
    eval `grep LOGINSHELL $TMPFILE`
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
	    msg_create
	    ;;
	*)
	    msg_append
	    ;;
	esac
	    msg_choose_do
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
	    msg_create
	  ;;
	  *)
	    msg_append
	  ;;
	esac
     msg_choose_do
    ;;
    *)
    # Any shell except *csh and bash
	echo 
    	echo Since you have changed your login shell to $LOGINSHELL,
	echo I am confident that you know what you are doing.
	echo So now add a line equivalent to
	echo 
	echo "    source /sw/bin/init.sh"
	echo
	echo to one of your $LOGINSHELL startup scripts
	echo and you will be set up for using Fink.
	echo
	echo Have a nice day.
    ;;
    esac	    
fi

# rm -f $TMPFILE

# End of program.
