#!/usr/bin/perl -w

# Create first-cut .info file for CPAN perl module
#    Syntax: mkpkg.pl -m "Joe Maintainer <joe@foo.com>" Some::Module
# if you specify more than one module, it will process them sequentially
#   Args:
#     -v   verbose
#     -m   specify the maintainer
#     -p   show prereq info (not yet finished)
#     -f   force overwrite of .info file
#     -h   help (not yet implemented)

# Caveats:
#   Does not do Depends, Recommends, BuildDepends, etc
#   Does not do variants or SplitOffs
#   Just guesses at DocFiles
#   License may not be right - confirm manually
#   Does not indicate crypto or main dependencies

# Note: requires CPANPLUS 0.051 to be installed
#       untested with other versions of CPANPLUS
# Note: requires file-slurp-pm.info to be installed

use strict;
use Getopt::Long;
use CPANPLUS::Backend;
use CPANPLUS::Internals::Constants;
use File::Slurp;
use Carp;
$SIG{__WARN__} = $SIG{__DIE__} = \&Carp::confess;

my %opts = (
            verbose    => 0,
            readonly   => 0,
            help       => 0,
            version    => 0,
            force      => 0,
            dir        => "/sw/fink/dists/local/main/finkinfo/libs/perlmods",
            maintainer => "Chris Dolan <chrisdolan\@users.sourceforge.net>",
            prereqs    => 0, # not finished
            );

Getopt::Long::Configure("bundling");
GetOptions("v|verbose"  => \$opts{verbose},
           "r|readonly" => \$opts{readonly},
           "h|help"     => \$opts{help},
           "V|version"  => \$opts{version},
           "f|force"    => \$opts{force},
           "m|maintainer=s" => \$opts{maintainer},
           "p|prereqs"  => \$opts{prereqs},
           ) or die;

# This is a translation from CPAN "dslip" codes to Fink license words
my %licenses = (
                p   => "Artistic/GPL",
                g   => "GPL",
                l   => "LGPL",
                b   => "BSD",
                a   => "Artistic",
                o   => "Restrictive/Distributable",
                );

my $cb = CPANPLUS::Backend->new();
print "Started CPANPLUS\n";

foreach my $module (@ARGV)
{
   print "Search for $module\n";
   my $mod = $cb->module_tree($module);
   if ($mod)
   {
      print "Found\n";

      my $pkg = lc($mod->package_name)."-pm";
      my $file = "$opts{dir}/$pkg.info";
      if (-f $file && !$opts{force})
      {
         print "info package already exists\n";
         print "$file\n";
         next;
      }

      if ($opts{verbose})
      {
         my $details = $mod->details;
         for my $key (keys %$details)
         {
            print "$key: $$details{$key}\n";
         }
      }

      if (!$mod->status->fetch)
      {
         print "Fetch module\n";
         $mod->fetch;
      }
      if (!$mod->status->extract)
      {
         print "Extract module\n";
         $mod->extract;
      }
      print "Extracted to ".$mod->status->extract."\n";

      if ($opts{prereqs})
      {
         my $dist = $mod->dist(format => $mod->get_installer_type(),
                               target => TARGET_PREPARE);
         my $prereqs = $dist->_find_prereqs();
         for my $key (sort keys %$prereqs)
         {
            print "  Prereq: $key => $$prereqs{$key}\n";
         }
      }

      # Debugging: dump the module object to a file
      #use Data::Dumper;
      #write_file("/tmp/module", Dumper($mod));

      # license code is 5th character in "DSLIP" code
      my $dslip = $mod->dslip;
      my $license_code = substr($dslip, 4, 1);
      my $license = $licenses{$license_code} || "";

      # Get list of files in the root of the distro.  Some of them
      # will be the DocFiles
      my @files = grep {-f $_} map {$mod->status->extract."/".$_} read_dir($mod->status->extract);

      # Prepare the .info fields.  Note that we use "_" instead of "-"
      # in field names to keep perl happy.
      my @data = (
                  Package => $pkg,
                  Version => $mod->package_version,
                  Revision => "1",
                  Source => ("mirror:cpan:" . $mod->path . "/" . 
                             $mod->package_name . "-%v." . 
                             $mod->package_extension),
                  Source_MD5 => $mod->status->checksum_value,
                  Type => "perl",
                  UpdatePOD => "true",
                  DocFiles => "@files",
                  License => $license,
                  Description => $mod->description,
                  Maintainer => $opts{maintainer},
                  Homepage => "http://search.cpan.org/dist/".$mod->package_name,
                  );

      # Write the .info file
      my $output = "";
      for (my $i=0; $i<@data; $i+=2)
      {
         my $label = $data[$i];
         my $value = $data[$i+1];
         $label =~ s/_/-/g;
         $output .= "$label: $value\n";
      }
      write_file($file, $output);
      print "Wrote file $file\n";
   }
   else
   {
      print "Not found\n";
   }
}

## This was an experiment to speed up the cleanup phase.  But, it
## broke the persistent caching that CPANPLUS performs...
#if ($opts{readonly})
#{
#   for (CPANPLUS::Internals->_return_all_objects())
#   {
#      CPANPLUS::Internals->_remove_id($_->_id);
#   }
#}
