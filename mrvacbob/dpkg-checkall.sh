#!/bin/sh
fink_path=`which dpkg | sed -e 's:/bin/dpkg::'`
for foo in `cat $fink_path/var/lib/dpkg/info/*.list`
do
if (! test -e "$foo")
then
echo $foo not found
echo $foo is part of `dpkg -S $foo | awk '{print $1}' | sed -e 's;:;;g' | sort | uniq`
fi
done
