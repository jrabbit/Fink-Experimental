#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: $0 <pkg-name> [<pkg-name> ...]"
  exit 1
fi

cvs_add=
cvs_remove=

# Loop over the params
for pkgname in $*; do
  echo "Increasing revision of $pkgname..."
  # Grab the revision from the pkgname, and increase it by one
  old_rev=`grep "^Revision: " $pkgname | sed 's|^Revision: ||'`
  new_rev=`expr $old_rev + 1`
  # Compute the filename
  new_pkg=`echo $pkgname | sed "s|-$old_rev\.info|-$new_rev\.info|"`

  # Copy the .info file to its new name (and increase the revision doing so)
  cat $pkgname | sed "s|^Revision: $old_rev|Revision: $new_rev|" > $new_pkg
  rm $pkgname
  
  # Add new file to CVS, and remove the old
  cvs_add="$cvs_add $new_pkg"
  cvs_remove="$cvs_remove $pkgname"
  
  # If there is patch, we have to rename it, too
  patchname=`basename $pkgname .info`.patch
  new_patch=`basename $new_pkg .info`.patch
  if [ -e $patchname ]; then
    mv "$patchname" "$new_patch"
    cvs_add="$cvs_add $new_patch"
    cvs_remove="$cvs_remove $patchname"
  fi
done

cvs add $cvs_add
cvs remove $cvs_remove
