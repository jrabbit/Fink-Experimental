#!/usr/bin/perl -w

# Create .info files for CPAN perl modules
## UNFINISHED.  Right now, this just collects info via CPANPLUS

use strict;
use Getopt::Long;
use CPANPLUS::Backend;
use CPANPLUS::Internals::Constants;

use Carp;
$SIG{__WARN__} = $SIG{__DIE__} = \&Carp::confess;

my %opts = (
            verbose    => 0,
            readonly   => 0,
            help       => 0,
            version    => 0,
            );

Getopt::Long::Configure("bundling");
GetOptions("v|verbose"  => \$opts{verbose},
           "r|readonly" => \$opts{readonly},
           "h|help"     => \$opts{help},
           "V|version"  => \$opts{version},
           ) or die;

my $cb = CPANPLUS::Backend->new();
print "Started CPANPLUS\n";

foreach my $module (@ARGV)
{
   print "Search for $module\n";
   my $mod = $cb->module_tree($module);
   if ($mod)
   {
      print "Found\n";
      #print join(".",
      #           $mod->package_name, 
      #           $mod->package_version, 
      #           $mod->package_extension)."\n";
      my $details = $mod->details;
      for my $key (keys %$details)
      {
         print "$key: $$details{$key}\n";
      }
      $mod->status->fetch || $mod->fetch;
      $mod->status->extract || $mod->extract;
      my $dist = $mod->dist(format => $mod->get_installer_type(),
                            target => TARGET_PREPARE);
      my $prereqs = $dist->_find_prereqs();
      for my $key (sort keys %$prereqs)
      {
         print "  Prereq: $key => $$prereqs{$key}\n";
      }
   }
   else
   {
      print "Not found\n";
   }
}

if ($opts{readonly})
{
   for (CPANPLUS::Internals->_return_all_objects())
   {
      CPANPLUS::Internals->_remove_id($_->_id);
   }
}
