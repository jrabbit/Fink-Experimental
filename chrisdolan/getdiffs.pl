#!/usr/bin/perl -w

# Diff my own copies of packages against the unstable tree to see if
# anyone has updated them in CVS.

use strict;
use File::Find;

sub file
{
   my $f = $File::Find::name;
   return if ($f !~ /\.(info|patch)$/);
   (my $fink = $f) =~ s,^\./,/sw/fink/dists/unstable/main/finkinfo/,;
   if (! -f $fink)
   {
      (my $f2 = $f) =~ s/-[\d\.]+-\d+\.(info|patch)$/.$1/;
      return if (-f $f2);
      ($fink = $f2) =~ s,^\./,/sw/fink/dists/unstable/main/finkinfo/,;
   }
   if (-f $fink)
   {
      my $diff = `diff -u $f $fink`;
      if ($diff)
      {
         print "============= $f =============\n";
         print $diff;
      }
      else
      {
         print "============= $f =============\n";
         print "Match\n";
      }
   }
   else
   {
      print "============= $f =============\n";
      print "No Fink file\n";
   }
}

find({wanted => \&file, no_chdir => 1}, ".");
