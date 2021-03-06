#!/bin/sh
# Reconstitute the libtool archive *.la files in /usr/X11/lib from the *dylib files
# Copyright (c) 2008 Martin Costabel
# 
usage="\nUsage: sudo $0 [create|undo]\n
create: Write *.la files into /usr/X11/lib that are compatible with the existing *.dylib files there.
        Existing *.la files are moved to *.la.bak.\n
undo  : Restore the previous *.la files from *.la.bak.\n\n"
[ `id -u` -ne 0 ] && /usr/bin/printf "$usage" && exit

outputdir='/usr/X11/lib'
usrX11lib='/usr/X11/lib'

case $1 in
	*undo)
	  for LAbak in $outputdir/*.la.bak; do [ -e $LAbak ] && mv $LAbak ${LAbak%.bak}; done; exit;;
	*create)
	  ;;
	*)
	  /usr/bin/printf "$usage"; exit;;
esac

echo=/bin/echo
sed=/usr/bin/sed

PROGRAM=$0
PACKAGE=libtool
VERSION=1.5.22
TIMESTAMP=" (1.1220.2.365 2005/12/18 22:14:06)"

install_libdir=$usrX11lib
old_library=''
installed='yes'
module='no'
dlfiles=''
dlprefiles=''

find $usrX11lib -name \*.dylib | sed 's,\..*dylib,,g' | sort -u \
    | egrep -v 'Xaw$|GL|OSMesa|glut' \
    | while read LIB
    do
libname=$(basename $LIB)
libname=${libname/%.*dylib/}
outputname=$libname.la
dlname=$(otool -X -D $install_libdir/$libname.dylib)
  tdlname=$(basename $dlname)
## echo Considering $LIB : $tdlname

# For the library_names we take what is really there. 
# To be cautious, we place the install_name at the end.
library_names=$(cd $usrX11lib; ls $libname.*dylib | tr "\n" " ")
  library_names="${library_names/$tdlname/} $tdlname"
# The dependency_libs are extracted from otool -L, dylibs are replaced
# by *.la files, with the exception of /usr/lib/libz.dylib, which has no libz.la file.

dependency_libs=" -L/usr/X11/lib \
   $(otool -XL $usrX11lib/$libname.dylib \
     | /usr/bin/sed "1d" \
     | grep -v Frameworks \
     | grep -v libgcc \
     | grep -v libSystem \
     | tr " " "\t" | cut -f2,1 \
     | /usr/bin/sed 's|/usr/lib/libz.*|-lz|g' \
     | tr "\n" " " |tr "\t" " " \
     | /usr/bin/sed 's|\.[^:space:]*dylib|.la|g'
     ) "

# The current.age.revision numbers are set from the "current version" as reported by otool -L.
# "current version x.y.z" gives, arbitrarily, "x-1.0.0".
# This is not what is in the original *.la file, but the original information
# is impossible to reconstitute; this has probably no importance, anyway.
current=$(otool -XL $usrX11lib/$libname.dylib \
     | grep $tdlname \
     | grep -o "current version.*" \
     | /usr/bin/sed -E -e 's|[^0-9]*([0-9]+)\..*|\1|' \
     )
   current=$(($current - 1))
age='0'
revision='0'

# Now writing the  *.la file

output=$outputdir/$libname.la
echo Writing $output
if [ -e $output ]; then
	mv $output $output.bak
fi

# Output routine from /usr/bin/glibtool, lines 6012-6052

	  $echo > $output "\
# $outputname - a libtool library file
# Generated by $PROGRAM - with extracts from GNU $PACKAGE $VERSION$TIMESTAMP
#                        lines 6012 - 6051
#
# Please DO NOT delete this file!
# It is necessary for linking the library.

# The name that we can dlopen(3).
dlname='$tdlname'

# Names of this library.
library_names='$library_names'

# The name of the static archive.
old_library='$old_library'

# Libraries that this one depends upon.
dependency_libs='$dependency_libs'

# Version information for $libname.
current=$current
age=$age
revision=$revision

# Is this an already installed library?
installed=$installed

# Should we warn about portability when linking against -modules?
shouldnotlink=$module

# Files to dlopen/dlpreopen
dlopen='$dlfiles'
dlpreopen='$dlprefiles'

# Directory that this library needs to be installed in:
libdir='$install_libdir'"
	  if test "$installed" = no && test "$need_relink" = yes; then
	    $echo >> $output "\
relink_command=\"$relink_command\""
	  fi
  done

