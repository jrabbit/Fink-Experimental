#
# Fink::Shlibs class
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2003 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

$|++;

package Fink::Shlibs;
use Fink::Base;
use Fink::Services qw(&print_breaking);
use Fink::Config qw($config $basepath);
use File::Find;
use Fcntl ':mode'; # for search_comparedb

use strict;
use warnings;


BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION	= 1.00;
  @ISA		= qw(Exporter Fink::Base);
  @EXPORT	= qw();
  @EXPORT_OK	= qw(&get_shlib);
  %EXPORT_TAGS	= ( );
}
our @EXPORT_OK;

our ($have_shlibs, @shlib_list, %shlib_hash, $shlib_db_outdated,
     $shlib_db_mtime);

$have_shlibs = 0;
@shlib_list = ();
%shlib_hash = ();
$shlib_db_outdated = 1;
$shlib_db_mtime = 0;

END { }				# module clean-up code here (global destructor)


### get package name
sub get_shlib {
  my $self = shift;
  my $lib = shift;
  my ($dep);

  $self->require_shlibs();

  foreach $shlibs (keys %shlib_hash) {
    if ($shlibs eq $lib) {
      $dep = $shlib_hash{package};
    }
  }

  return $dep;
}

### make sure shlibs are available
sub require_shlibs {
  my $self = shift;

  if (!$have_shlibs) {
    $self->get_all_shlibs();
  }
}

### forget about all shlibs
sub forget_shlibs {
  my $self = shift;

  $have_shlibs = 0;
  @shlib_list = ();
  %shlib_hash = ();
  $shlib_db_outdated = 1;
}

### read list of shlibs, either from cache or files
sub get_all_shlibs {
  my $self= shift;
  my $time = time;
  my ($shlibname);
  my $db = "shlibs.db";

  $self->forget_shlibs();
	
  # If we have the Storable perl module, try to use the package index
  if (-e "$basepath/var/db/$db") {
    eval {
      require Storable; 

      # We assume the DB is up-to-date unless proven otherwise
      $shlib_db_outdated = 0;
		
      # Unless the NoAutoIndex option is set, check whether we should regenerate
      # the index based on its modification date and that of the package descs.
      if (not $config->param_boolean("NoAutoIndex")) {
        $shlib_db_mtime = (stat("$basepath/var/db/$db"))[9];

        if (((lstat("$basepath/etc/fink.conf"))[9] > $shlib_db_mtime)
            or ((stat("$basepath/etc/fink.conf"))[9] > $shlib_db_mtime)) {
          $shlib_db_outdated = 1;
        } else {
          $shlib_db_outdated =
            &search_comparedb( "$basepath/var/lib/dpkg/info" );
        }
      }
			
      # If the index is not outdated, we can use it, and thus safe a lot of time
      if (not $shlib_db_outdated) {
        %shlib_hash = %{Storable::retrieve("$basepath/var/db/$db")};
        my ($shlibtmp);
        foreach $shlibtmp (keys %shlib_hash) {
          push @shlib_list, $shlib_hash{$shlibtmp};
        }
      }
    }
  }
	
  # Regenerate the DB if it is outdated
  if ($shlib_db_outdated) {
    $self->update_shlib_db();
  }

  $have_shlibs = 1;

  print "Information about ".($#shlib_list+1)." shlibs read in ",
    (time - $time), " seconds.\n\n";
}

### scan for info files and compare to $db_mtime
sub search_comparedb {
  my $path = shift;
  my (@files, $file, $fullpath, @stats);

  opendir(DIR, $path) || die "can't opendir $path: $!";
    @files = grep { !/^[\.#]/ } readdir(DIR);
  closedir DIR;

  foreach $file (@files) {
    $fullpath = "$path/$file"; 

    if (-d $fullpath) {
      next if $file eq "CVS";
      return 1 if (&search_comparedb($fullpath));
    } else {
      next if !(substr($file, length($file)-5) eq ".shlibs");
      @stats = stat($fullpath);
      return 1 if ($stats[9] > $shlib_db_mtime);
    }
  }
	
  return 0;
}

### read shlibs and update the database, if needed and we are root
sub update_shlib_db {
  my $self = shift;
  my ($dir);
  my $db = "shlibs.db";

  # read data from descriptions
  print "Reading shlib info...\n";
  $dir = "$basepath/var/lib/dpkg/info";
  $self->scan($dir);

  eval {
    require Storable; 
    if ($> == 0) {
      print "Updating shlib index... ";
      unless (-d "$basepath/var/db") {
        mkdir("$basepath/var/db", 0755) ||
          die "Error: Could not create directory $basepath/var/db";
      }
      Storable::store (\%shlib_hash, "$basepath/var/db/$db");
      print "done.\n";
    } else {
      &print_breaking( "\nFink has detected that your shlib cache is out" .
        " of date and needs an update, but does not have privileges to" .
         " modify it. Please re-run fink as root," .
	" for example with a \"sudo fink-depends index\" command.\n" );
    }
  };
  $shlib_db_outdated = 0;
}

### scan for shlibs
sub scan {
  my $self = shift;
  my $directory = shift;
  my (@filelist, $wanted);
  my ($filename, $shlibname, $compat, $package);

  return if not -d $directory;

  # search for .shlibs files
  @filelist = ();
  $wanted =
    sub {
      if (-f and not /^[\.#]/ and /\.shlibs$/) {
        push @filelist, $File::Find::fullname;
      }
    };
  find({ wanted => $wanted, follow => 1, no_chdir => 1 }, $directory);

  foreach $filename (@filelist) {
    open(SHLIB, $filename) or die "can't open $filename: $!\n";
      while(<SHLIB>) {
        chomp($_);
        if ($_ =~ /^(.+) ([.0-9]+) (.*)$/) {
          $shlibname = $1;
          $compat = $2;
          $package = $3;
        }
      }
    close(SHLIB);

    unless ($shlibname) {
      print "No lib name in $filename\n";
      next;
    }
    unless ($compat) {
      print "No lib compatability version for $shlibname\n";
      next;
    }
    unless ($package) {
      print "No owner package(s) for $shlibname\n";
      next;
    }

    $self->inject_shlib($shlibname, $compat, $package);
  }
}

### create the hash
sub inject_shlib {
  my $self = shift;
  my $shlibname = shift;
  my $compat = shift;
  my $package = shift;

  $shlib_hash{$shlibname}->{compat} = $compat;
  $shlib_hash{$shlibname}->{packages} = $package;
}

### EOF
1;
