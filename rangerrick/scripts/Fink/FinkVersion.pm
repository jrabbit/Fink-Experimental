# -*- mode: Perl; tab-width: 4; -*-
#
# Fink::FinkVersion package
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2004 The Fink Package Manager Team
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
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA	 02111-1307, USA.
#

package Fink::FinkVersion;

use strict;
use warnings;

require Exporter;
our @ISA	 = qw(Exporter);
our @EXPORT_OK	 = qw(&fink_version &distribution_version &pkginfo_version &max_info_level);
our %EXPORT_TAGS = ('ALL' => \@EXPORT_OK);

use Fink::Config qw($basepath);
use Fink::Command qw(cat);


=head1 NAME

Fink::FinkVersion - Fink version numbers

=head1 SYNOPSIS

  use Fink::FinkVersion qw(:ALL);

  my $fink_version    = fink_version;
  my $dist_version    = distribution_version;
  my $pkginfo_version = pkginfo_version;
  my $max_info_level  = max_info_level;

=head1 DESCRIPTION

This module retrieves the version numbers of various parts of the fink
installation.

=head2 Functions

These functions are exported on request.  You can export them all with

  use Fink::FinkVersion qw(:ALL);

=over 4

=item fink_version

  my $fink_version = fink_version;

Returns the version of the fink source code.

=cut

sub fink_version {
	return "0.0";
}


=item distribution_version

  my $dist_version = distribution_version

Returns the fink distribution version you're currently using.

=cut

sub distribution_version {
	my $dv;
	if (-f "$basepath/fink/dists/VERSION") {
		chomp($dv = cat "$basepath/fink/dists/VERSION");
	} elsif (-f "$basepath/fink/VERSION") {
		chomp($dv = cat "$basepath/fink/VERSION");
	} elsif (-f "$basepath/etc/fink-release") {
		chomp($dv = cat "$basepath/etc/fink-release");
	} else {
		$dv = "unknown";
	}
	return $dv;
}


=item pkginfo_version

  my $pkginfo_version = pkginfo_version;

Returns from whence you updated your packages.  If you're using a point
release it will return that.  Otherwise if you're using one of the dynamic
methods...

    rsync       packages updated via rsync
    cvs         packages updated via cvs

=cut

sub pkginfo_version {
	my $pv = "0";
	my ($fn, $v);
# first, look in the new location for stamp files
	foreach $fn (glob("$basepath/fink/dists/stamp-*")) {
		if ($fn =~ m{/stamp-rsync}) {
			return "rsync";
		} elsif ($fn =~ m{/stamp-cvs}) {
			return "cvs";
		} elsif ($fn =~ m{/stamp-rel-(.+)$}) {
			$v = $1;
			$pv = $v if ($v gt $pv);
		}
	}
# if we haven't returned yet, and we didn't set the value of $v, look in the old location
	if (not defined $v) {
	foreach $fn (glob("$basepath/fink/stamp-*")) {
		if ($fn =~ m{/stamp-rsync}) {
			return "rsync";
		} elsif ($fn =~ m{/stamp-cvs}) {
			return "cvs";
		} elsif ($fn =~ m{/stamp-rel-(.+)$}) {
			$v = $1;
			$pv = $v if ($v gt $pv);
		}
				}
	}
	$pv = &distribution_version() if $pv eq "0";
	return $pv;
}


=item max_info_level

  my $max_info_level = max_info_level;

Returns the highest level of package description file that this fink
can parse. If a .info is componsed of a 'InfoN: <<' ... '<<' block
where N is a larger integer than that returned by this function, the
entire .info file should be ignored.

=cut

sub max_info_level {
	# 1 is the original level (same as none specified)
	# 2 gives percent-expansion in Package: and multiple Type: syntax.
	return 2;
}

=back

=cut

1;
