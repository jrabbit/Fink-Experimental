# -*- mode: Perl; tab-width: 4; -*-
#
# Fink::Reporting module
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

package Fink::Reporting;

use Fink::Services qw(&execute &latest_version);
use Fink::CLI qw(&print_breaking);
use Fink::Config qw($config $basepath $libpath);
use Fink::Command qw(mkdir_p rm_f);
use Fink::FinkVersion qw(fink_version distribution_version);
use Fink::Package;
use Fink::PkgVersion;

use HTTP::Request;
use HTTP::Response;
use HTTP::Request::Common;
use LWP::UserAgent;
use File::Basename;
use Storable;

use strict;
use warnings;

BEGIN {
	use Exporter ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
	$VERSION	 = 1.00;
	@ISA		 = qw(Exporter);
	@EXPORT		 = qw();
	%EXPORT_TAGS = ( );			# eg: TAG => [ qw!name1 name2! ],

	# your exported package globals go here,
	# as well as any optionally exported functions
	@EXPORT_OK	 = qw(&report_stable &report_unstable &report_feedback &report_allcontents &report_contents &report_deb_contents );
}
our @EXPORT_OK;

END { }				# module clean-up code here (global destructor)
my ($user, $pass, $release, $ua, $response, %pkgcache, $cacheref);
my $sitehost = "www.opendarwin.org/~benh57";
my $rptstatus = ();
my $setup = 0;
#my $sitehost = "clef.no-ip.org";

sub setup_reporting {
	if($setup == 0) {  # Necessary because this is called in report_deb_contents
		$rptstatus->{sent} = 0;
		$rptstatus->{unbuilt} = 0;
		$rptstatus->{virtual} = 0;
		$rptstatus->{unknown} = 0;
		if(!$ua) {
			my $fink_version    = fink_version();
			my $dist_vers    = distribution_version();
			if($dist_vers =~ /cvs/) {
				$release = "current-" . $config->param("Distribution");
			} else {
				$release = $config->param("Distribution");
			}	
			$ua = LWP::UserAgent->new;
			$ua->agent("fink/$fink_version");
			get_userinfo();
		}
		$setup = 1;
	}
}

sub get_userinfo {

	if ($config->has_param("ReportUser")) {
		$user = $config->param("ReportUser");
	} else {		
		&print_breaking("WARNING: Reporting with no ReportUser specified in fink.conf! ".
			"Please add your username to the file or specify".
			"it using 'fink configure'. This will enable maintainers to reply to your".
			"feedback.");
		$user = 'anonymoususer@fink.sourceforge.net';
	}
	if ($config->has_param("ReportPassword")) {
		$pass = $config->param("ReportPassword");
	} else {		
		&print_breaking("WARNING: Reporting with no ReportPassword specified in fink.conf! ".
			"Please add your username to the file or specify".
			"it using 'fink configure'. This will enable maintainers to reply to your".
			"feedback.");
		$pass = "None";
	}
}

sub print_report_status { 
	my ($s, $status);
	print "\nCompleted report.\n";
	if($rptstatus->{"sent"}) {
		$status = sprintf " %s package%s submitted to fink site.\n", $rptstatus->{"sent"}, ($rptstatus->{"sent"} == 1) ? '' : 's';
		&print_breaking($status);
	}
	if($rptstatus->{"unbuilt"}) {
		$status = sprintf " %s outdated or unbuilt package%s not reported.\n", $rptstatus->{"unbuilt"}, ($rptstatus->{"unbuilt"} == 1) ? '' : 's';
		&print_breaking($status);
	}
	if($rptstatus->{"virtual"}) {
		$status = sprintf " %s virtual package%s not reported.\n", $rptstatus->{"virtual"}, ($rptstatus->{"virtual"} == 1) ? '' : 's';
		&print_breaking($status);
	}
	if($rptstatus->{"unknown"}) {
		$status = sprintf " %s package%s not reported for unknown reasons.\n", $rptstatus->{"unknown"}, ($rptstatus->{"unknown"} == 1) ? '' : 's';
		&print_breaking($status);
	}
}
sub report_stable {
	my ($pkg, $tree);
	setup_reporting();
	foreach $pkg (@_)
	{
		$tree = $pkg->get_tree();
		$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php",
			Content => [username => $user, password => $pass, release => "$release-$tree", package => $pkg->get_name(), 
						version => $pkg->get_fullversion(), stable => 1]);  
		if ( !$response->is_success ) { print $response->error_as_HTML; print "Stable report failed!\n"; }
		print $response->content;	
	}
}

sub report_unstable {
	my ($pkg, $tree);
	setup_reporting();
	foreach $pkg (@_)
	{
		$tree = $pkg->get_tree();
		$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php",
			Content => [username => $user, password => $pass, release => "$release-$tree", package => $pkg->get_name(), 
						version => $pkg->get_fullversion(), unstable => 1]);  
		if ( !$response->is_success ) { print $response->error_as_HTML; print "Unstable report failed!\n"; }
		print $response->content;	
	}
}

sub report_feedback {
	my ($pkg);
	setup_reporting();
#	$vers = $pkg->get_fullversion();
#	$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php",
#		Content => [username => $user, password => $pass, release => $release,  package => $pkg->get_name(), version => $pkg->get_fullversion(), feedback => $feedback]);  
#	if ( !$response->is_success ) { print $response->error_as_HTML; print "Feedback report failed!\n"; }
#	print $response->content;
}

sub report_allcontents {
	my ($package, $pkgvo, $pname, $lversion);
	&setup_reporting();
	foreach $pname (Fink::Package->list_packages()) {
		# package_by_name returns a Package object
		$package = Fink::Package->package_by_name($pname);
		# Turn it into a PkgVersion obj of the latest version
		$lversion = &latest_version($package->list_versions());
		$pkgvo = $package->get_version($lversion);
		if(! $pkgvo) {
			if($package->is_virtual) {
				$rptstatus->{"virtual"}++;
				&print_breaking("Looking for latest $pname... virtual package, not submitted.\n");
			} else {
				$rptstatus->{"unknown"}++;
			}
		} elsif ($pkgvo->is_present()) {
			$rptstatus->{"sent"}++;
			&report_deb_contents($pkgvo->get_tree(), $pkgvo->get_name(), $pkgvo->get_fullversion(), $pkgvo->get_debname());
		} else {
			$rptstatus->{"unbuilt"}++;
			&print_breaking("Looking for latest $pname... not built.\n");
		}
	}
	&print_report_status();
}

# Report contents for a list of PkgVersion objects.
sub report_contents {
	my ($pkg, $vers, $arg, $pname);
	&setup_reporting();
	foreach $pkg (@_)
	{	
		$pname = $pkg->get_name();
		if ($pkg->is_present()) {
			$rptstatus->{"sent"}++;
			&report_deb_contents($pkg->get_tree(), $pname, $pkg->get_fullversion(), $pkg->get_debname());
		} elsif (Fink::Package->package_by_name($pname)->is_virtual()) {
			$rptstatus->{"virtual"}++;
			&print_breaking("WARNING: $pname is virtual and will not be reported.");
		} else {		
			$rptstatus->{"unbuilt"}++;
			&print_breaking("WARNING: You do not have a built $pname-".$pkg->get_fullversion().
			 ". In order to submit files for this package, please 'fink build' it again.");
		}
	}
	&print_report_status();
}


### report contents for given deb
# returns 0 on success, 1 on error

sub report_deb_contents {
	my $tree = shift;
	my $pkg = shift;
	my $vers = shift;
	my $debname = shift;
	my ($md5, $cmd, $response, $uploadfile, $filename, $submitted, $verblevel);
	my $quiet = 0;
	
	&setup_reporting();
	
	if (! $config->has_param("ReportUser")) {
		# We warned about it above, for this function, die
		&print_breaking("ERROR: Cannot report contents without a ReportUser.");
		return 1;
	}
	
	if (! $config->has_param("ReportPassword")) {
		# We warned about it above, for this function, die
		&print_breaking("ERROR: Cannot report contents without a ReportPassword.");
		return 1;
	}
	
	###DYNAMIC_FILE_UPLOAD saves memory when sending large files.
	$HTTP::Request::Common::DYNAMIC_FILE_UPLOAD = 1;
	
	#$pass = md5_hex("password");
	
	&print_breaking("Listing package $pkg-$vers...\n");
	Fink::Command::mkdir_p("/tmp/finkul");
	$uploadfile = "/tmp/finkul/finkupload-".$pkg."-".$vers."-".$user;
	
	## Shut up Fink::Services::Execute at low verbose
	$verblevel = $config->param_default("Verbose", 1);
	if($verblevel > 1) {
		$quiet = 2;
	}
	
	#Extract only the fields we want.. ignores modification date, etc.
	$cmd = "$basepath/bin/dpkg -c $basepath/fink/debs/$debname | cut -c1-31,51- > ".$uploadfile;
	if(Fink::Services::execute($cmd, $quiet)) {		
		&print_breaking("ERROR: Error listing deb file! Files not submitted.\n\n");
		if($? == 2) {
			&print_report_status();
			die("caught SIGINT, Aborting...\n");
		}
		return 0;
	}
	
	&print_breaking("Calculating MD5...\n");
	$md5 = Fink::Services::file_MD5_checksum("$uploadfile");
	##### Check to see if we've already submitted this release-pkg-vers-md5 combo
	### The client keeps a cache to avoid submitting duplicate votes. 
	### (we could store each vote by username in the server db, but we don't just to avoid overloading the server) 
	### (Instead, only the first submission is counted, all other submissions are counted numerically)
	unless (-d "$basepath/var/db") {
		mkdir("$basepath/var/db", 0755) || die "Error: Could not create directory $basepath/var/db";
	}	
	unless (! -f "$basepath/var/db/finkreporting.db") { 
		$cacheref = Storable::retrieve("$basepath/var/db/finkreporting.db");
		$submitted = $cacheref->{"$release-$tree"}{"$pkg"}{"$vers"}{"$md5"}[0];
		if($submitted) {
			### We've already submitted this file, but check with the server for its earliest timestamp		
			### If this is later than the client's db time, we will clear the client submission cache and submit the file.
			$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php",
				 Content => [cachetimestamp => $submitted]);  	
			if ( !$response->is_success ) { print $response->error_as_HTML; print "Failed!\n"; return 1; }
			$_ = $response->content;
			if(/SERVEROLDER/) {
				&print_breaking("You've already submitted a vote for this package.");
				return 0;
			} elsif(/SERVERNEWER/) {
				&print_breaking("You've already submitted this vote, but it appears the server database has been cleared.");
				&print_breaking("Submission cache cleaned.");
				# The cached min server timestamp will be reset later, if the submission succeeds
			}
		} else {
		#	print "$release-$pkg-$vers-$md5 timestamp not found in reportingdb\n";
		}
	}
	##### Submit the Package, Version, MD5.
	&print_breaking("Sending Package MD5 for $release-$tree-$pkg-$vers...");
	$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php",
							Content => [username => $user, password => $pass, release => "$release-$tree", 
							package => $pkg, version => $vers, pkghash1 => $md5]);  	
	if ( !$response->is_success ) { print $response->error_as_HTML; print "Failed!\n"; return 1; }
#	print $response->content;
	
	##### Submit the data
	$_ = $response->content;
	if(/LOGINFAILED/)
	{
		&print_breaking("Error! Login failed. Please create a user using 'fink feedback' or check your username/password.");
		return 1;
	} elsif (/NOTPRESENT/)
	{
		#Package not in the database
		$cmd = "/usr/bin/gzip $uploadfile";
		if(Fink::Services::execute($cmd, $quiet)) {		
			&print_breaking("ERROR: Error gzipping file submission data! Files not submitted.\n\n");
			if($? == 2) {
				&print_report_status();
				die("caught SIGINT, Aborting...\n");
			}
			return 1;
		}
		$filename = basename($uploadfile, "");
		$response = $ua->request(POST "http://$sitehost/fink/pdb/submit.php", 
						Content_Type => 'form-data',
						Content => [username => $user, password => $pass, release => "$release-$tree", 
						package => $pkg, version => $vers, pkghash2 => $md5, "$filename" => ["$uploadfile.gz", "$filename"]]);  
		if ( !$response->is_success ) { print $response->error_as_HTML; print "Failed!\n"; return 1; }
		print $response->content;
		unlink("$uploadfile.gz");
		### Store the pkg submission cache db	
		if($response->content =~ /[A-Z]+-([0-9]+):/) {
			$submitted = $1;
		}
		store_cache("$release-$tree", $pkg, $vers, $md5, $submitted);
	} elsif(/PRESENT/)
	{
		### Package is already in the database - don't submit it, and remember that we voted.
		&print_breaking("Package files with MD5 $md5 are already in the DB. Your vote has been counted.\n");
		if($response->content =~ /[A-Z]+-([0-9]+):/) {
			$submitted = $1;
		}
		store_cache("$release-$tree", $pkg, $vers, $md5, $submitted);
		unlink($uploadfile);
	} elsif(/NOSUCHPKG/)
	{
		#Package is not in the web PDB.
		#We only accept packages in the file DB which the main PDB knows about
		&print_breaking("The Package $pkg-$vers is not present in the PDB. It may be obsolete.");
		&print_breaking("If the package is up to date, please try again in a few hours.\n");
		unlink($uploadfile);
	} else {
		print $response->content;
		unlink($uploadfile);	
	}	
	return 0;
}

### Store vote cache
### The client keeps a cache to avoid submitting duplicate votes. 
### (we could store each vote by username in the server db, but we don't just to avoid overloading the server) 
### (Instead, only the first submission is counted, all other submissions are counted numerically)
sub store_cache {
		my $release = shift;
		my $pkg = shift;
		my $vers = shift;
		my $md5 = shift;
		my $timestamp = shift;
		$cacheref->{"$release"}{"$pkg"}{"$vers"}{"$md5"}[0] = $timestamp;
		Storable::lock_store ($cacheref, "$basepath/var/db/finkreporting.db.tmp");
		rename "$basepath/var/db/finkreporting.db.tmp", "$basepath/var/db/finkreporting.db";
}

### EOF
1;
