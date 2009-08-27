# -*- mode: Perl; tab-width: 4; -*-
# vim: set filetype=perl expandtab tabstop=4 shiftwidth=4:
#
# Fink::SelfUpdate::httpsnap class
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2009 The Fink Package Manager Team
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
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
#

package Fink::SelfUpdate::httpsnap;

use base qw(Fink::SelfUpdate::Base);

use Fink::CLI qw(&prompt_boolean);
use Fink::Config qw($basepath $config $distribution);
use Fink::Mirror;
use Fink::Package;
use Fink::Command qw(mkdir_p rm_f);
use Fink::NetAccess qw(&fetch_url_to_file);
use Fink::Services qw(&version_cmp &execute &filename);

use Data::Dumper;

use strict;
use warnings;

our $VERSION = sprintf "%d.%d", q$Revision$ =~ /(\d+)/g;

=head1 NAME

Fink::SelfUpdate::httpsnap - downloads snapshots of package descriptions from an http server

=head1 DESCRIPTION

=head2 Public Methods

See documentation for the Fink::SelfUpdate base class.

=over 4

=item system_check

point method cannot remove .info files, so we don't support using
point if some other method has already been used.

=cut

sub system_check {
	my $class = shift;  # class method for now

	if (not Fink::VirtPackage->query_package("dev-tools")) {
		warn "Before changing your selfupdate method to 'httpsnap', you must install Xcode, available on your original OS X install disk, or from http://connect.apple.com (after free registration).\n";
		return 0;
	}

	my $answer = &prompt_boolean("WARNING: selfupdate-httpsnap removes EVERY .info and .patch file under $basepath/fink/dists/stable, and $basepath/fink/dists/unstable if you have enabled the unstable tree. You MUST move your local .info and .patch files to $basepath/fink/dists/local so that they don't get removed by selfupdate-httsnap.\n\nDo you wish to continue and change the selfupdate method to httsnap?", default => 0);
	if (not $answer) {
		warn "\nExiting without changing the selfupdate method to httsnap.\n";
		return 0;
	}

	return 1;
}

=item do_direct

Returns a null string.

=cut

sub do_direct {
	my $class = shift;  # class method for now

	my @dists = ($distribution);

	{
		my $temp_dist = $distribution;

		# workaround for people who upgraded to 10.5 without a fresh bootstrap
		if (not $config->has_param("SelfUpdateTrees")) {
			$temp_dist = "10.4" if ($temp_dist ge "10.4");
		}
		$temp_dist = $config->param_default("SelfUpdateTrees", $temp_dist);
		@dists = split(/\s+/, $temp_dist);
	}

	map { s/\/*$// } @dists;

	my $descdir = "$basepath/fink";
	chdir $descdir or die "Can't cd to $descdir: $!\n";

	my $origmirror = Fink::Mirror->get_by_name("httpsnap");
	my $httphost;

RETRY:
	$httphost = $origmirror->get_site_retry("", 0);
	if (! grep(/^http:/, $httphost)) {
		print "No mirror worked. This seems unusual; please submit a short summary of this event to mirrors\@finkmirrors.net\n Thank you\n";
		exit 1;
	}
	$httphost =~ s/\/*$//;

	# Fetch the timestamp for comparison. Use &fetch_url_to_file so that we can
	# pass the option 'try_all_mirrors' which fores re-download of the file
	# even if it already exists
	my $urlhash;
	$urlhash->{'url'} = "$httphost/TIMESTAMP";
	$urlhash->{'filename'} = "TIMESTAMP.tmp";
	$urlhash->{'skip_master_mirror'} = 1;
	$urlhash->{'download_directory'} = $descdir;
	$urlhash->{'try_all_mirrors'} = 1;
	if (&fetch_url_to_file($urlhash)) {
		print "Failed to fetch the timestamp file from the http server: $httphost. Check the error messages above.\n";
		goto RETRY;
	}

	# If there's no TIMESTAMP file, then we haven't synced from http/rsync
	# before, so there's no checking we can do. Blaze on past.
	if (-f "$descdir/TIMESTAMP") {
		my $ts_FH;
		open $ts_FH, '<', "$descdir/TIMESTAMP";
		my $oldts = <$ts_FH>;
		close $ts_FH;
		chomp $oldts;
		# Make sure the timestamp only contains digits
		if ($oldts =~ /\D/) {
			unlink("$descdir/TIMESTAMP.tmp");
			die "The timestamp file $descdir/TIMESTAMP contains non-numeric " .
				"characters. This is illegal. Refusing to continue.\n";
		}

		open $ts_FH, '<', "$descdir/TIMESTAMP.tmp";
		my $newts = <$ts_FH>;
		close $ts_FH;
		chomp $newts;
		# Make sure the timestamp only contains digits
		if ($newts =~ /\D/) {
			unlink("$descdir/TIMESTAMP.tmp");
			die "The timestamp file fetched from $httphost contains non-numeric characters. This is illegal. Refusing to continue.\n";
		}

		if ($oldts > $newts) {
			# Error out complaining that we're trying to update from something
			# older than what we already have.
			unlink("$descdir/TIMESTAMP.tmp");
			print "The timestamp of the server is older than what you already have.\n";
			exit 1;
		}
	}

	# Validating trees...
	my @trees = grep { m,^(un)?stable/, } $config->get_treelist();
	die "Can't find any trees to update\n" unless @trees;
	map { s/\/*$// } @trees;
	# Get rid of ./{main,crypto}
	map { s/(^(un)?stable)\/(.*)/$1/ } @trees;
	# Get rid of duplicates
	my %hash_trees = map { $_ => 1 } @trees;
	@trees = keys %hash_trees;

	# Let's try to download the tarballs before changing anything
	for my $dist (@dists) {
		for my $tree (@trees) {
			my $url;
			my $urlhash;
			$url = "$httphost/$dist-$tree.tbz";
			$urlhash->{'url'} = $url;
			$urlhash->{'filename'} = &filename($url);
			$urlhash->{'skip_master_mirror'} = 1;
			$urlhash->{'download_directory'} = $descdir;
			$urlhash->{'try_all_mirrors'} = 1;
			if (&fetch_url_to_file($urlhash)) {
				print "Failed to fetch package descriptions from $url.  Check the error messages above.\n";
				goto RETRY;
			}
		}
	}

	# We've been able to grab the tarballs. Go ahead and extract them

	for my $dist (@dists) {
		my $distdir = "$descdir/$dist";

		# If the Distributions line has been updated...
		if (! -d "$distdir") {
			mkdir_p "$distdir";
		}

		foreach my $tree (@trees) {
			if (-d "$distdir/$tree") {
				my $rm_info_cmd = "find $distdir/$tree -name *.info -exec rm -f {} \\;";
				my $rm_patch_cmd = "find $distdir/$tree -name *.patch -exec rm -f {} \\;";
				if (&execute("$rm_info_cmd")) {
					die "Removal of .info files failed\n";
				}
				if (&execute("$rm_patch_cmd")) {
					die "Removal of .patch files failed\n";
				}
			}

			my $verbosity = "";
			if ($config->verbosity_level() > 1) {
				$verbosity = "v";
			}

			my $pkgtarball = "$dist-$tree.tbz";
			my $unpack_cmd = "tar -xjph${verbosity}f $pkgtarball -C $distdir";
			if (&execute("$unpack_cmd")) {
				die "Unpacking $pkgtarball failed\n";
			}
		}
	}

	# Cleanup after ourselves
#	unlink "$descdir/TIMESTAMP";
#	rename "$descdir/TIMESTAMP.tmp", "$descdir/TIMESTAMP";

	$class->update_version_file();
	return 1;
}

=back

=head2 Private Methods

None yet.

=over 4

=back

=cut

1;
