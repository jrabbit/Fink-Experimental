#!/bin/sh
for foo in `cat /sw/var/lib/dpkg/info/*.list | uniq`
do
if (! test -e $foo)
then
echo $foo not found
echo $foo is part of `dpkg -S $foo | awk '{print $1}'`
fi
done
