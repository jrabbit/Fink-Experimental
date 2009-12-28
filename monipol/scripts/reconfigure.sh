#!/bin/sh

FINKDIR=$1

if [ -z "$FINKDIR" ]
then
	echo You must specify Fink\'s installation directory
	echo 
	echo Syntax:
	echo "    $0 fink_installation_directory"
	echo
	echo Example:
	echo "    $0 /sw"
	exit 1
fi

badpkgsfile=`mktemp /tmp/reconfigure.XXXXX`
cd $FINKDIR/var/lib/dpkg/info
for pkgfile in `ls *.list`
do
	pkgname=`echo $pkgfile | sed s/\.list$//`
	cat $pkgfile | while read file
	do
		if [ ! -e "$file" -a ! -L "$file" ]
		then
			echo File $file from package $pkgname is missing
			echo $pkgname >> $badpkgsfile
		fi
	done
done

badpkgs=`sort < $badpkgsfile | uniq`

echo
echo Run the following command to fix the missing files:
echo
echo fink reinstall $badpkgs
