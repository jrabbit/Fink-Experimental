#!/usr/bin/perl

$|++;

BEGIN {
	# thetis
	our $CHECKOUTDIR = '/home/f/fink/finkinfo';
	our $DOWNLOADDIR = '/home/f/fink/distfiles';
	our $FINKROOT    = '/home/f/fink/fink';
	our $SVNROOT     = '/home/f/fink/svn';
	our $WORKDIR     = '/home/f/fink/mirwork';
	our $LOGFILE     = '/home/f/fink/log/mirror.log';
	our $CHANGELOG   = '/home/f/fink/log/change.log';
}

use lib $FINKROOT . '/perlmod';
use lib $WORKDIR;

use Data::Dumper;
use Fcntl qw(:DEFAULT :flock);
use File::Copy;
use File::Find;
use File::Path;
use Fink::NetAccess 1.10 qw(fetch_url_to_file);
use Fink::Package;
use Fink::PkgVersion;
use Fink::Services qw(&find_subpackages);
use Storable;

unshift(@INC, $WORKDIR);
mkpath($WORKDIR . '/Fink');

open (LOCKFILE, '>>' . $WORKDIR . '/mirror.lock') or die "could not open lockfile for append: $!";
if (not flock(LOCKFILE, LOCK_EX | LOCK_NB)) {
	if (grep(/^--?o/, @ARGV))
	{
		exit 0;
	}
	my $msg = "Another process is already running.\n";
	if (-f $LOGFILE && -r _) {
		$msg .= "Existing logfile:\n";
		$msg .= `grep -ve 'has not changed' -e 'fetching files for' -e 'exists$' $LOGFILE`;
	}
	die $msg;
}

open (LOG, '>', $LOGFILE);
print LOG "- $0 starting " . scalar(localtime(time)) . "\n";

use vars qw(
	$COUNT
	$CVSROOT
	$DEBUG
	$LAST_UPDATE_CACHE
	$VALIDATE_EXISTING_FILES
);

$VALIDATE_EXISTING_FILES = 0;
$COUNT = 0;
$CVSROOT=':ext:gecko2@fink.cvs.sourceforge.net:/cvsroot/fink';
$DEBUG = 0;
$ENV{CVS_RSH} = 'ssh';

if (-f $WORKDIR . '/update.cache')
{
	$LAST_UPDATE_CACHE = retrieve($WORKDIR . '/update.cache');
}

open (FILEIN, $FINKROOT . '/VERSION') or die "could not read VERSION: $!";
chomp(my $finkversion = <FILEIN>);
close (FILEIN);

open (FILEIN, $FINKROOT . '/perlmod/Fink/FinkVersion.pm.in') or die "could not read FinkVersion.pm.in: $!";
open (FILEOUT, '>' . $WORKDIR . '/Fink/FinkVersion.pm') or die "could not write to FinkVersion.pm: $!";
while (<FILEIN>)
{
	$_ =~ s/\@VERSION\@/${finkversion}/gs;
	$_ =~ s/\@ARCHITECTURE\@/0.28.0/gs;
	print FILEOUT;
}
close (FILEOUT);
close (FILEIN);

# set up Fink
require Fink::FinkVersion;
require Fink::Config;
$Fink::Config::ignore_errors++;

# create the temporary cvs checkout
mkpath($CHECKOUTDIR);
mkpath($DOWNLOADDIR);
chdir($CHECKOUTDIR);

if (grep(/^--?h(elp)?/, @ARGV))
{
	print "usage: $0 [--help] [--skip-update] [--only-update]\n\n";
	exit 0;
}

if (not grep(/^--s/, @ARGV))
{
	print LOG "- updating cvs\n";
	if (run_cvs_command('checkout', 'dists'))
	{
		system('rsync', '-avr', '--exclude=CVS', '--exclude=.cvsignore', '--delete-excluded', '--delete', '--delete-after', "--log-file=$CHANGELOG", 'dists/', 'dists.public/');
		if (open (FILEOUT, '>dists.public/TIMESTAMP.new'))
		{
			print FILEOUT time(), "\n";
			close (FILEOUT);
			move('dists.public/TIMESTAMP.new', 'dists.public/TIMESTAMP');
		}
		else
		{
			die "unable to write TIMESTAMP.new: $!";
		}
	}
}

if (grep(/^--o/, @ARGV))
{
	exit 0;
}

print LOG "- scanning info files\n";
opendir(DIR, $CHECKOUTDIR . '/dists') or die "unable to read from $CHECKOUTDIR/dists: $!";
for my $dir (readdir(DIR))
{
	if ($dir eq '10.3' or $dir eq '10.4')
	{
		print LOG "searching $dir\n";
		finddepth( { wanted => \&find_fetch_infofile, follow => 1 }, $CHECKOUTDIR . '/dists/' . $dir);
	}
}
closedir(DIR);

store($LAST_UPDATE_CACHE, $WORKDIR . '/update.cache');

print LOG "- $0 finished " . scalar(localtime(time)) . "\n";

sub find_fetch_infofile
{
	my $shortname = $_;
	my $dist;
	my $all_downloads_passed = 1;

	# dmacks ponders: doesn't the first of these make the second and third un-necessary?
	return unless ( $File::Find::name =~ m#\.info$# );
	return if     ( $File::Find::name =~ m#/CVS/# );
	return if     ( $File::Find::name =~ m#/10.2(-gcc3.3)?/# );

	if ( $File::Find::name =~ m#/dists/([^/]+)/# )
	{
		$dist = $1;
	}
	else
	{
		return;
	}

	$COUNT++;
	if ($DEBUG and $COUNT > 50)
	{
		print LOG "debug: already tried $COUNT files\n";
		return;
	}

	my @stat = stat($File::Find::name);
	if (exists $LAST_UPDATE_CACHE->{$File::Find::name} and $LAST_UPDATE_CACHE->{$File::Find::name} == $stat[9])
	{
		print LOG $File::Find::name, " has not changed\n";
		return;
	}

	my @arches;
	if ($dist =~ /^10.3/)
	{
		@arches = ('powerpc');
	}
	else
	{
		@arches = ('powerpc', 'i386');
	}

	if ($dist =~ /^10.4$/)
	{
		for my $dist ('10.4', '10.5', '10.6')
		{
			for my $arch (@arches)
			{
		
				$Fink::Config::config = Fink::Config->new_from_properties({
					basepath       => $WORKDIR,
					distribution   => $dist,
					#downloadmethod => 'lftpget',
					downloadmethod => 'wget',
					architecture   => $arch,
					downloadtimeout => 900, # try up to 15 minutes to download something
					ProxyPassiveFTP => 'true', # DAMN passiv PORT vs. PASV
					Verbose		=> 0,
				});
				$Fink::Config::libpath = $FINKROOT;
		
				my ($tree) = $File::Find::name =~ m#/dists/[^/]+/([^/]+)/#;
				print LOG "- fetching files for $shortname ($dist/$tree)\n";
				for my $package ( Fink::PkgVersion->pkgversions_from_info_file( $File::Find::name ) )
				{
					next if ( $package->get_license() =~ /Restrictive$/ );
					for my $suffix ($package->get_source_suffixes)
					{
						my $tarball = $package->get_tarball($suffix);
						print LOG "  - $tarball... ";
						my $checksums = {};
						$checksums->{'MD5'} = $package->param('Source' . $suffix . '-MD5');
						my($checksum_type, $checksum) = Fink::Checksum->parse_checksum($package->get_checksum($suffix));
						$checksums->{$checksum_type} = $checksum;
			
						if (not -l $DOWNLOADDIR . '/' . $tarball)
						{
							my $file_checksums = Fink::Checksum->get_all_checksums($DOWNLOADDIR . '/' . $tarball);
							my $master_checksum_type = 'MD5';
							if (exists $file_checksums->{$master_checksum_type})
							{
								mkpath($DOWNLOADDIR . '/md5/' . $file_checksums->{$master_checksum_type});
								move($DOWNLOADDIR . '/' . $tarball, $DOWNLOADDIR . '/md5/' . $file_checksums->{$master_checksum_type} . '/' . $tarball);
								for my $checksum_type (keys %$file_checksums)
								{
									next if ($key eq $master_checksum_type);
									mkpath($DOWNLOADDIR . '/' . lc($checksum_type) . '/' . lc($file_checksums->{$checksum_type}));
									symlink(
										'../../' . lc($master_checksum_type) . '/' . lc($file_checksums->{$master_checksum_type}) . '/' . $tarball,
										$DOWNLOADDIR . '/' . lc($checksum_type) . '/' . lc($file_checksums->{$checksum_type}) . '/' . $tarball
									);
									unlink( $DOWNLOADDIR . '/' . $tarball );
									symlink(
										lc($master_checksum_type) . '/' . lc($file_checksums->{$master_checksum_type}) . '/' . $tarball,
										$DOWNLOADDIR . '/' . $tarball,
									);
			
								}
							}
						}
			
						my $do_download = (not -e $DOWNLOADDIR . '/' . $tarball);
						for $checksum_type (keys %$checksums)
						{
							next if (not defined $checksum_type or $checksum_type =~ /^\s*$/);
							my $check_file = $DOWNLOADDIR . '/' . lc($checksum_type) . '/' . lc($checksums->{$checksum_type}) . '/' . $tarball;
							if (not -f $check_file)
							{
								print LOG "$check_file does not exist, downloading\n";
								$do_download = 1;
							}
							elsif ($VALIDATE_EXISTING_FILES)
							{
								if (not Fink::Checksum->validate($check_file, $checksums->{$checksum_type}, $checksum_type))
								{
									print LOG "checksum on $check_file does not match, downloading\n";
									$do_download = 1;
								}
							}
						}
						if ($do_download)
						{
							print LOG "downloading\n";
							my $master_checksum_type = 'MD5';
							if (not exists $checksums->{'MD5'})
							{
								my @types = sort keys %$checksums;
								$master_checksum_type = shift(@types);
							}
							my $download_path = $DOWNLOADDIR . '/' . lc($master_checksum_type) . '/' . $checksums->{$master_checksum_type};
							my $url = $package->get_source($suffix);
							my $returnval = &fetch_url_to_file({
								url                => $url,
								filename           => $tarball,
								custom_mirror      => $package->get_custom_mirror($suffix),
								skip_master_mirror => 1,
								download_directory => $download_path,
								checksum           => $checksums->{$master_checksum_type},
								checksum_type      => $master_checksum_type,
								try_all_mirrors    => 1,
							});
							if ($returnval != 0)
							{
								unlink($download_path . '/' . $tarball);
								print LOG "unable to download $url to $download_path\n";
								$all_downloads_passed = 0;
								next;
							}
			
							my $file_checksums = Fink::Checksum->get_all_checksums($download_path . '/' . $tarball);
							for my $checksum_type (keys %$file_checksums)
							{
								if ($checksum_type eq $master_checksum_type)
								{
									if ($file_checksums->{$checksum_type} ne $checksums->{$checksum_type})
									{
										print LOG "downloaded file has a different checksum than expected ($file_checksums->{$checksum_type} ne $checksums->{$checksum_type})\n";
									}
								}
								else
								{
									mkpath($DOWNLOADDIR . '/' . lc($checksum_type) . '/' . lc($file_checksums->{$checksum_type}));
									symlink(
										'../../' . lc($master_checksum_type) . '/' . lc($checksums->{$master_checksum_type}) . '/' . $tarball,
										$DOWNLOADDIR . '/' . lc($checksum_type) . '/' . lc($file_checksums->{$checksum_type}) . '/' . $tarball
									);
									unlink( $DOWNLOADDIR . '/' . $tarball );
									symlink(
										lc($master_checksum_type) . '/' . lc($checksums->{$master_checksum_type}) . '/' . $tarball,
										$DOWNLOADDIR . '/' . $tarball,
									);
								}
							}
						}
						else
						{
							print LOG "exists\n";
						}
					}
				}
			}
		}
	}

	if ($all_downloads_passed)
	{
		$LAST_UPDATE_CACHE->{$File::Find::name} = $stat[9];
	}
}

sub run_cvs_command
{
	my @command = @_;
	my $returnval = system('/usr/bin/cvs', '-q', '-z3', '-d', $CVSROOT, @command);
	if ($returnval == -1)
	{
		die "failed to execute: $!";
	}
	elsif ($returnval & 127)
	{
		die sprintf('cvs failed: child died with signal %d', ($returnval & 127));
	}
	elsif (($returnval >> 8) != 0)
	{
		die sprintf('cvs failed: child exited with value %d', ($returnval >> 8));
	}
	return 1;
}
