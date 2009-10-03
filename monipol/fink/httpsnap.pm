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
use Fink::Command qw(chowname mkdir_p rm_rf);
use Fink::NetAccess qw(&fetch_url_to_file);
use Fink::Services qw(&version_cmp &execute &filename);

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
		warn "Before changing your selfupdate method to 'httpsnap', you must " .
			"install Xcode, available on your original OS X install disk, or " .
			"from http://connect.apple.com (after free registration).\n";
		return 0;
	}

#	my $answer = &prompt_boolean("WARNING: selfupdate-httpsnap removes EVERY .info and .patch file under $basepath/fink/dists/stable, and $basepath/fink/dists/unstable if you have enabled the unstable tree. You MUST move your local .info and .patch files to $basepath/fink/dists/local so that they don't get removed by selfupdate-httsnap.\n\nDo you wish to continue and change the selfupdate method to httsnap?", default => 0);
#	if (not $answer) {
#		warn "\nExiting without changing the selfupdate method to httsnap.\n";
#		return 0;
#	}

	return 1;
}

=item do_direct

Returns a null string.

=cut

sub do_direct {
	my $class = shift;  # class method for now

	# Get the list of distributions

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

	my $downloaddir = "$basepath/src/_httpsnap";
	mkdir_p $downloaddir;
	chdir $downloaddir or die "Can't cd to $downloaddir: $!\n";

	my $distdir = "$basepath/fink";
	if (! -d $distdir) {
		die "No $distdir found\n";
	}

	# Get the list of trees

	my @trees = grep { m,^(un)?stable/, } $config->get_treelist();
	die "Can't find any trees to update\n" unless @trees;
	# Get rid of trailing slash(es)
	map { s/\/*$// } @trees;
	my @trees_dashes = @trees;
	# Convert (non-trailing) slashes to dashes
	map { s/\//-/ } @trees_dashes;

	# Iterate the list of mirrors
	my $origmirror = Fink::Mirror->get_by_name("httpsnap");
	my $httpsnaphost;
	my $mostrecentts = 0;

RETRY:
	$httpsnaphost = $origmirror->get_site_retry("", 0);
	if (! grep(/^http:/, $httpsnaphost)) {
		print "No mirror worked. This seems unusual; please submit a short ".
			"summary of this event to mirrors\@finkmirrors.net\n Thank you\n";
		exit 1;
	}
	$httpsnaphost =~ s/\/*$//;

	# Download timestamps and newer package description tarballs
	for my $dist (@dists) {
		for my $tree (@trees_dashes) {
			my $url;
			my $urlhash;

			# Fetch the timestamp for comparison. Use &fetch_url_to_file so
			# that we can pass the option 'try_all_mirrors' which forces
			# re-download of the file even if it already exists
			$urlhash->{'url'} = "$httpsnaphost/$dist-$tree-LOCAL";
			$urlhash->{'filename'} = "$dist-$tree-TIMESTAMP.tmp";
			$urlhash->{'skip_master_mirror'} = 1;
			$urlhash->{'download_directory'} = $downloaddir;
			$urlhash->{'try_all_mirrors'} = 1;
			if (&fetch_url_to_file($urlhash)) {
				print "Failed to fetch $urlhash->{'url'}. Check the error " .
					"messages above.\n";
				goto RETRY;
			}

			my $ts_FH;
			open $ts_FH, '<', "$downloaddir/$dist-$tree-TIMESTAMP.tmp";
			my $newts = <$ts_FH>;
			close $ts_FH;
			chomp $newts;
			# Make sure the timestamp only contains digits
			if ($newts =~ /\D/) {
				unlink("$downloaddir/$dist-$tree-TIMESTAMP.tmp");
				die "The timestamp file fetched from $httpsnaphost " .
					"for $dist-$tree contains non-numeric characters. " .
					"This is illegal. Refusing to continue.\n";
			}

			# If there's no local TIMESTAMP file, then we haven't synced from
			# httpsnap before, so there's no checking we can do. Blaze on
			# past.
			if (-f "$distdir/$dist-$tree-TIMESTAMP") {
				open $ts_FH, '<', "$distdir/$dist-$tree-TIMESTAMP";
				my $oldts = <$ts_FH>;
				close $ts_FH;
				chomp $oldts;
				# Make sure the timestamp only contains digits
				if ($oldts =~ /\D/) {
					unlink("$downloaddir/$dist-$tree-TIMESTAMP.tmp");
					die "The timestamp file $distdir/$dist-$tree-TIMESTAMP " .
						"contains non-numeric characters. This is illegal. " .
						"Refusing to continue.\n";
				}

				if ($oldts > $newts) {
					# Error out complaining that we're trying to update from
					# something older than what we already have.
					unlink("$downloaddir/$dist-$tree-TIMESTAMP.tmp");
					print "The timestamp of the server is older than what " .
						"you already have.\n";
					exit 1;
				}
			}

			$url = "$httpsnaphost/$dist-$tree.tbz";
			$urlhash->{'url'} = $url;
			$urlhash->{'filename'} = &filename($url);
			$urlhash->{'skip_master_mirror'} = 1;
			$urlhash->{'download_directory'} = $downloaddir;
			$urlhash->{'try_all_mirrors'} = 1;
			if (&fetch_url_to_file($urlhash)) {
				print "Failed to fetch package descriptions from $url. " .
					"Check the error messages above.\n";
				goto RETRY;
			}

			if ($newts > $mostrecentts) {
				$mostrecentts = $newts;
			}
		}
	}

	# We've been able to grab the tarballs. Go ahead and extract them under
	# $downloaddir = /sw/src/_httpsnap
	for my $dist (@dists) {
		my $unpackdir = "$downloaddir/$dist";

		if (! -d "$unpackdir") {
			rm_rf "$unpackdir";
			mkdir_p "$unpackdir";
		}

		my $verbosity = "";
		if ($config->verbosity_level() > 1) {
			$verbosity = "v";
		}

		foreach my $tree (@trees_dashes) {
			my $pkgtarball = "$downloaddir/$dist-$tree.tbz";
			my $unpackcmd = "tar -xjph${verbosity}f $pkgtarball -C $unpackdir";
			if (&execute("$unpackcmd")) {
				die "Unpacking $pkgtarball failed\n";
			}
		}
	}

	# Ok, the tarballs have been unpacked under $downloaddir/$dist.
	# Go ahead and rsync $distdir/$dist with $unpackdir/$dist

	# But first let's set $verbosity to something amenable to rsync...
	my $verbosity = "-q";
	if ($config->verbosity_level() > 1) {
		$verbosity = "-v";
	}

	# ...and check that needed filesystem-specific flag for rsync
	my $nohfs = "";
	if (system("rsync -help 2>&1 | grep 'nohfs' > /dev/null") == 0) {
		$nohfs = "--nohfs";
	}

	my $rinclist = "";

	for my $dist (@dists) {
		# If the Distributions line has been updated...
		if (! -d "$distdir/$dist") {
			mkdir_p "$distdir/$dist";
		}
		my @sb = stat("$distdir/$dist");
		my $unpackdir = "$downloaddir";

		for my $tree (@trees) {
			my $oldpart = $dist;
			my @line = split /\//,$tree;

			$rinclist .= " --include='$dist/'";

			for (my $i = 0; defined $line[$i]; $i++) {
				$oldpart = "$oldpart/$line[$i]";
				$rinclist .= " --include='$oldpart/'";
			}

			$rinclist .= " --include='$oldpart/finkinfo/' " .
				"--include='$oldpart/finkinfo/*/' " .
				"--include='$oldpart/finkinfo/*' " .
				"--include='$oldpart/finkinfo/**/*'";

			if (! -d "$basepath/fink/$dist/$tree") {
				mkdir_p "$basepath/fink/$dist/$tree";
			}
		}

		my $cmd = "rsync -rtz --delete-after --delete $verbosity $nohfs " .
			"$rinclist " .
			"--include='VERSION' " .
			"--include='DISTRIBUTION' " .
			"--include='README' " .
			"--exclude='**' " .
			"'$unpackdir/' " .
			"'$basepath/fink/'";
		print "\n$cmd\n";
		if ($sb[4] != 0 and $> != $sb[4]) {
			my $username;
			($username) = getpwuid($sb[4]);
			if ($username) {
				$cmd = "/usr/bin/su $username -c \"$cmd\"";
				chowname $username, "$basepath/fink/$dist";
			}
		}

		if (&execute($cmd)) {
			print "Selfupdate failed. Check the error messages above.";
			goto CLEANUP;
		}
	}

CLEANUP:
	# Cleanup after ourselves
	my $mostrecent_FH;
	open $mostrecent_FH, '>', "$distdir/TIMESTAMP";
	print $mostrecent_FH $mostrecentts;
	close $mostrecent_FH;

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
