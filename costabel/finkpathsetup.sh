#! /bin/sh
# Shell script for preparing the user's shell startup scripts
# for Fink.
# (C) 2003 Martin Costabel
# This version works for csh type user login shells,
# for sh type shells nothing is done.

# A temporary file for communicating with a login shell 
TMPFILE=`/usr/bin/mktemp /tmp/resu.XXXXXX`

# Start a login session to see whether the PATH is 
# already set up for Fink. 
# PATH and SHELL are written into TMPFILE
#
/usr/bin/login -f $USER >$TMPFILE <<EOF
/usr/bin/printenv PATH
/bin/echo -n LOGINSHELL= 
/usr/bin/printenv SHELL 
exit
EOF

# Look whether sw/sbin was in the PATH 
if grep sw/sbin $TMPFILE >/dev/null 2>&1 ; then
    # already set up
    echo 
    echo Your environment seems to be correctly
    echo set up for Fink already.
    echo
else
    # we need to do something
    eval `grep LOGINSHELL $TMPFILE`
    LOGINSHELL=`basename $LOGINSHELL`
    case $LOGINSHELL in
    *csh)
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
	    echo 
	    echo I will create a file named $RC in your
	    echo home directory, containing one line
	    echo \"source /sw/bin/init.csh\"
	    ;;
	*)
	    echo
	    echo I will now append a line
	    echo \"source /sw/bin/init.csh\"
	    echo to the file $RC in your home directory.
	    ;;
	esac
	    echo
	    echo If you don\'t want me to do this, you can answer 
	    echo \"no\" here and do it later manually.
	    echo Otherwise answer \"yes\".
	    echo
	    echo -n "Do you want to continue? [Y/n] "
	    read answer
	    answer=`echo $answer | sed 's/^[yY].*$/y/'`
	    if [ -z "$answer" -o "x$answer" = "xy" ]; then
		echo "source /sw/bin/init.csh" >> $HOME/$RC
		echo Verifying...
# Start another login session to see whether the 
# PATH is now set up for Fink.
#
/usr/bin/login -f $USER >$TMPFILE <<EOF
/usr/bin/printenv PATH
exit
EOF
if grep sw/sbin $TMPFILE >/dev/null 2>&1 ; then
    echo ... OK. You should be fine now.
else
    echo Hmm. I tried my best, but it still doesn\'t work.
    echo Please check your $LOGINSHELL startup scripts. 
    echo The code I put into $RC has no effect.
    echo Perhaps there is some other file like ~/.login
    echo that resets the PATH after $RC is executed.
    echo Bye.
fi
		echo
	    else
		echo OK, you are on your own. Bye.
		echo
	    fi
    ;;
    *)
	echo 
    	echo Since you have changed your login shell to $LOGINSHELL,
	echo you are considered a Unix geek who knows what you are doing.
	echo So now add a line
	echo 
	echo "    source /sw/bin/init.sh"
	echo
	echo to one of your $LOGINSHELL startup scripts
	echo and you will be set up for using Fink.
	echo
    ;;
    esac	    
fi

rm -f $TMPFILE

