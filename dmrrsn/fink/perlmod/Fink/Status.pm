#
# Fink::Status class
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2002 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

package Fink::Status;

use Fink::Config qw($config $basepath $darwin_version $macosx_version);

use strict;
use warnings;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION = 1.00;
  @ISA         = qw(Exporter);
  @EXPORT      = qw();
  @EXPORT_OK   = qw();  # eg: qw($Var1 %Hashit &func3);
  %EXPORT_TAGS = ( );   # eg: TAG => [ qw!name1 name2! ],
}
our @EXPORT_OK;

my $the_instance = undef;

END { }       # module clean-up code here (global destructor)


### constructor

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;

  my $self = {};
  bless($self, $class);

  $self->initialize();

  $the_instance = $self;
  return $self;
}

### self-initialization

sub initialize {
  my $self = shift;
  my ($hash);

  # create dummy object for kernel version
  $hash = {};
  $hash->{package} = "darwin";
  $hash->{status} = "install ok installed";
  $hash->{version} = $darwin_version."-1";
  $hash->{description} = "[virtual package representing the kernel]";
  $self->{$hash->{package}} = $hash;
  
  # create dummy object for system version, if this is OS X at all
  if ($macosx_version ne 0) {
	$hash = {};
	$hash->{package} = "macosx";
	$hash->{status} = "install ok installed";
	$hash->{version} = $macosx_version."-1";
	$hash->{description} = "[virtual package representing the system]";
	$self->{$hash->{package}} = $hash;
  }

  $self->read();
}

### read dpkg's status file

sub read {
  my $self = shift;
  my ($file, $hash);

  $file = $basepath."/var/lib/dpkg/status";
  $hash = {};

  if (! -f $file) {
    print "WARNING: can't read dpkg status file \"$file\".\n";

    $self->{_invalid} = 0;
    return;
  }

  open(IN,$file) or die "can't open $file: $!";
  while (<IN>) {
    chomp;
    if (/^([0-9A-Za-z_.\-]+)\:\s*(\S.*?)\s*$/) {
      $hash->{lc $1} = $2;
    } elsif (/^\s*$/) {
      if (exists $hash->{package}) {
	$self->{$hash->{package}} = $hash;
      }
      $hash = {};
    }
    # we don't care about continuation lines
  }
  close(IN);

  if (exists $hash->{package}) {
    $self->{$hash->{package}} = $hash;
  }

  $self->{_invalid} = 0;
}

### update cached data if necessary

sub validate {
  my $self = shift;

  if ($self->{_invalid}) {
    $self->read();
  }
}

### invalidate cached data

sub invalidate {
  my $self = shift;

  if (not ref($self)) {
    if (defined($the_instance)) {
      $self = $the_instance;
    } else {
      $self = Fink::Status->new();
    }
  }

  $self->{_invalid} = 1;
}

### query by package name
# returns false when not installed
# returns full version when installed and configured

sub query_package {
  my $self = shift;
  my $pkgname = shift;
  my ($hash);

  if (not ref($self)) {
    if (defined($the_instance)) {
      $self = $the_instance;
    } else {
      $self = Fink::Status->new();
    }
  }

  $self->validate();

  if (not exists $self->{$pkgname}) {
    return 0;
  }
  $hash = $self->{$pkgname};
  if (not exists $hash->{status} or not exists $hash->{version}) {
    return 0;
  }
  if ($hash->{status} =~ /^\S+\s+ok\s+installed$/i) {
    return $hash->{version};
  }
  return 0;
}

### retreive whole list with versions
# doesn't care about installed status
# returns a hash ref, key: package name, value: hash with core fields
# in the hash, 'package' and 'version' are guaranteed to exist

sub list {
  my $self = shift;
  my ($list, $pkgname, $hash, $newhash, $field);

  if (not ref($self)) {
    if (defined($the_instance)) {
      $self = $the_instance;
    } else {
      $self = Fink::Status->new();
    }
  }

  $self->validate();

  $list = {};
  foreach $pkgname (keys %$self) {
    next if $pkgname =~ /^_/;
    $hash = $self->{$pkgname};
    next unless exists $hash->{version};

    $newhash = { 'package' => $pkgname,
		 'version' => $hash->{version} };
    foreach $field (qw(depends provides conflicts maintainer description)) {
      if (exists $hash->{$field}) {
	$newhash->{$field} = $hash->{$field};
      }
    }
    $list->{$pkgname} = $newhash;
  }

  return $list;
}


### EOF
1;
