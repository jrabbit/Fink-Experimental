#!/usr/bin/perl

$|++;

use lib '/home/ranger/cvs/fink/perlmod';
use lib '/home/ranger/cvs/experimental/rangerrick';

use Data::Dumper;
use Cwd qw(abs_path);
use File::Basename;
use File::Find;
use XML::RSS;
use Storable;
use Fink::Package;
use Text::Wrap qw(fill $columns);
use URI::Find;

$columns = 76;

#use utf8;
use strict;

use vars qw(
	$CUTOFF
	$DAYS
	$DISTDIR
	$DOCVS
	$EXPDIR
	$NOW
	$PREFIX
	$DOSCP
	$TOPDIR

	@FILES

	$STABLE_RSS
	$UNSTABLE_RSS

	%EXPERIMENTAL_PACKAGES
	%STABLE_PACKAGES
	%UNSTABLE_PACKAGES

	%CVS_FILES

	$CACHE
	$DOCACHE

	$basepath
	$Config

	$URIFINDER
);

$basepath = '/home/ranger/share/sw';
$TOPDIR   = abs_path(dirname($0));
$DAYS     = 8; # number of days to look back
$NOW      = time;
$CUTOFF   = ($NOW - (60 * 60 * 24 * $DAYS));
$PREFIX   = '/tmp/fink-rss';
$DISTDIR  = $PREFIX . '/dists';
$EXPDIR   = $PREFIX . '/experimental';
$DOSCP    = 0;
$DOCVS    = 1;
$DOCACHE  = 0;

$DISTDIR = '/sw/fink' if (-e '/sw/fink/dists');

$URIFINDER = URI::Find->new(
	sub {
		my($uri, $orig_uri) = @_;
		return qq|<a href="$uri">$orig_uri</a>|;
	}
);

if (-f '/tmp/rss.cache' and $DOCACHE) {
	$CACHE = retrieve('/tmp/rss.cache');
}

$ENV{CVS_RSH} = '/home/ranger/bin/ssh.sh';
#$ENV{CVS_RSH} = 'ssh';

print "- updating cvs repository... ";
`mkdir -p '$PREFIX'`;
if (-d $DISTDIR) {
	`cd $DISTDIR; CVS_RSH=/home/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink up -A >$PREFIX/dists.log 2>&1`;
} else {
	`cd $PREFIX; CVS_RSH=/home/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink co dists >$PREFIX/dists.log 2>&1`;
}
if (-d $EXPDIR) {
	`cd $EXPDIR; CVS_RSH=/home/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink up -A >$PREFIX/experimental.log 2>&1`;
} else {
	`cd $PREFIX; CVS_RSH=/home/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink co experimental >$PREFIX/experimental.log 2>&1`;
}
print "done\n";

print "- searching for new info files...\n";

my %options =
  (
   "dontask" => 0,
   "interactive" => 0,
   "verbosity" => 0,
   "keep_build" => 0,
   "keep_root" => 0,
  );

require Fink::Config;

my $configpath;
$configpath = "$basepath/etc/fink.conf";
if (-f $configpath) {
	$Config = &Fink::Services::read_config($configpath,
		{ Basepath => "$basepath" }
	);
}

find({ wanted => \&find_infofiles, follow => 0 }, $DISTDIR . '/');

print "- getting CVS log info... ";
get_cvs_log();
print "done\n";

#print Dumper(%CVS_FILES), "\n";
#print Dumper(%STABLE_PACKAGES), "\n";
#print Dumper(%UNSTABLE_PACKAGES), "\n";

print "- generating RSS...\n";
make_rss(\%STABLE_PACKAGES, 'Stable');
make_rss(\%UNSTABLE_PACKAGES, 'Unstable');

store($CACHE, '/tmp/rss.cache') if ($CACHE and $DOCACHE);

if ($DOSCP) {
	print "- copying feeds to the Fink website... ";
	system('echo > /tmp/rss-rsync.log');
	my $newfiles;
	for my $file (@FILES) {
		$newfiles .= ' ' . $file . '.new';
	}
	#print "rsync -av -e $ENV{CVS_RSH} $newfiles rangerrick\@fink.sourceforge.net:/home/groups/f/fi/fink/htdocs/news/rdf/ >/tmp/rss-rsync.log 2>&1\n";
	`rsync -av -e $ENV{CVS_RSH} $newfiles rangerrick\@fink.sourceforge.net:/home/groups/f/fi/fink/htdocs/news/rdf/ >/tmp/rss-rsync.log 2>&1`;

	my $movecommands;
	for my $file (@FILES) {
		$file =~ s/.*\///;
		$movecommands .= "; mv news/rdf/${file}.new news/rdf/${file}; chgrp fink news/rdf/${file}";
	}
	#print "$ENV{CVS_RSH} rangerrick\@fink.sourceforge.net 'cd /home/groups/f/fi/fink/htdocs; ./fix_perm.sh $movecommands' >/tmp/rss-mv.log 2>&1\n";
	`$ENV{CVS_RSH} rangerrick\@fink.sourceforge.net 'cd /home/groups/f/fi/fink/htdocs; ./fix_perm.sh $movecommands' >/tmp/rss-mv.log 2>&1`;
	print "done\n";
}

sub w3c_date {
	my @time = localtime(int(shift));
	$time[5] += 1900;
	$time[4] += 1;

	return sprintf('%04d-%02d-%02dT%02d:%02d:%02d-05:00', $time[5], $time[4], $time[3], $time[2], $time[1], $time[0]);
}

sub iso_date {
	my @time = localtime(int(shift));
	$time[5] += 1900;
	$time[4] += 1;

	my @days   = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
	my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

	return sprintf('%s, %02d %s %04d %02d:%02d:%02d EST', $days[$time[6]], $time[3], $months[$time[4]], $time[5], $time[2], $time[1], $time[0]);
}

sub get_cvs_log {
	return unless ($DOCVS);

	my @keys = map { $_ =~ s,^${DISTDIR}/,,; $_ } sort keys %CVS_FILES;

	my $filename;
	my $revdone = 0;
	my $lookfordesc = 0;
	my $author;
	my $spacecount = 100;
	my @lines;
	my $pwd = `pwd`;
	my $count = 0;
	chdir($DISTDIR);
	if (open(CVSLOG, "CVS_RSH=/home/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink log @keys 2>$PREFIX/cvslog.log |")) {
		$count = 0;
		open(FILEOUT, ">$PREFIX/cvslog-data.log");
		while (my $line = <CVSLOG>) {
			print FILEOUT $line;
			$count++;
			if ($line =~ m#\s*RCS file: /cvsroot/fink/dists/(.*),v#) {
				for my $index (0..$#lines) {
					$lines[$index] =~ s/^\s{$spacecount}//;
				}
				if (defined $author and int(@lines)) {
					$CVS_FILES{$filename} = [ $author, join('', @lines) ];
				}
				$filename = $DISTDIR . '/' . $1;
				$revdone = 0;
				$lookfordesc = 0;
				$spacecount = 0;
				@lines = ();
			} elsif ($line =~ m#\s*revision [\d\.]+#) {
				$lookfordesc = 1 unless ($revdone);
			} elsif ($lookfordesc) {
				if ($line =~ / author: (.*?);/) {
					$author = $1;
				} elsif ($line =~ /^----------------------------$/) {
					$lookfordesc = 0;
					$revdone = 1;
				} elsif ($line =~ /^=============================================================================$/) {
					$lookfordesc = 0;
					$revdone = 1;
				} else {
					push(@lines, $line);
					$line =~ s/\t/        /g;
					if ($line =~ /^(\s+)/) {
						my $count = length($1);
						$spacecount = $count if ($count < $spacecount);
					}
				}
			}
		}
		close(CVSLOG);
		close(FILEOUT);
		for my $index (0..$#lines) {
			$lines[$index] =~ s/^\s{$spacecount}//;
		}
		if (defined $author and int(@lines)) {
			$CVS_FILES{$filename} = [ $author, join('', @lines) ];
		}
	} else {
		die "unable to do 'cvs log': $!\n";
	}

	if ($count < 10) {
		die "cvs log was incomplete!\n";
	}

	chdir($pwd);

	return;
}


sub get_rss_object {
	my $tree = shift;

	my $rss = XML::RSS->new(version => '1.0');

	$rss->channel(
		title       => "Updated Fink Packages ($tree)",
		link        => 'http://fink.sourceforge.net/pdb/',
		description => "Updated Packages Released to the $tree Tree in the Last $DAYS Days.",
		dc          => {
			date      => w3c_date($NOW),
			subject   => 'Fink Software',
			creator   => 'fink-devel@lists.sourceforge.net',
			publisher => 'fink-devel@lists.sourceforge.net',
			language  => 'en-us',
		},
		syn         => {
			updatePeriod    => 'hourly',
			updateFrequency => '1',
			updateBase      => '2000-01-01T00:30:00-05:00',
		},
	);
	return $rss;
}

sub make_rss {
	my $packagehash = shift;
	my $tree        = shift;
	my $split_rss;

	for my $osver ('10.2', '10.2-gcc3.3', '10.3') {
		$split_rss->{$osver} = get_rss_object("${osver}/${tree}");
	}

	for my $package (keys %{$packagehash}) {
		my $package = $packagehash->{$package};
		if (not exists $split_rss->{$package->{'tree'}}) {
			$split_rss->{$package->{'tree'}} = get_rss_object($package->{'tree'} . '/' . $tree);
		}
	}

	my $rss = get_rss_object($tree);

	my $description;
	for my $package (sort { $packagehash->{$b}->{'date'} <=> $packagehash->{$a}->{'date'} || $a <=> $b } keys %{$packagehash}) {
		$package = $packagehash->{$package};

		next if ($CACHE->{$tree}->{$package->{'package'}} eq $package->{'version'} . '-' . $package->{'revision'});
		$CACHE->{$tree}->{$package->{'package'}} = $package->{'version'} . '-' . $package->{'revision'};

		my $packagestring;

		if ($package->{'type'} eq "info") {
			$packagestring = $package->{'package'} . '-' . $package->{'version'} . '-' . $package->{'revision'};
		} else {
			$packagestring = $package->{'package'} . ' rev. ' . $package->{'revision'};
		}

		print "  - ", $packagestring, "\n";
		if (not exists $package->{'descdetail'} or $package->{'descdetail'} =~ /^\s*$/gs) {
			$description = $package->{'description'};
		} else {
			$description = $package->{'descdetail'};
		}

		if ($package->{'type'} eq "info") {
			$description =~ s/[\r\n]+$//gsi;
			$description =~ s/<(http:\/\/[^>]+)>/$1/gsi;
			$description =~ s/<(.+\@[^\@]+)>/mailto:$1"/gsi;
			$description = encode_entities($description);
			$URIFINDER->find(\$description);
		} else {
			$description = encode_entities($description);
		}
			
		if ($DOCVS) {
			my $package_file;
			if ($package->{'type'} eq "info") {
				$package_file = $package->get_info_filename();
			} else {
				$package_file = $package->{'filename'};
			}
			if (exists $CVS_FILES{$package_file} and ref($CVS_FILES{$package_file}) eq "ARRAY") {
				my ($author, $content) = @{$CVS_FILES{$package_file}};
				$content = encode_entities($content);
				$description = $description . "\n\ncommit log from " .
					$author . ":\n" .  $content;
			} else {
				warn "no CVS information for " . $package->get_info_filename() . "\n";
				Dumper(%CVS_FILES);
			}
		}

		my %itemdata = (
			title       => encode_entities($package->{'package'} . ' ' . $package->{'version'} . '-' . $package->{'revision'} . ' (' . $package->{'description'} . ', ' . $package->{'tree'} . ' tree)'),
			description => '<![CDATA[<pre>' . $description . '</pre>]]>',
			#description => $description,
			link        => encode_entities('http://fink.sourceforge.net/pdb/package.php/' . $package->{'package'} . '#' . $package->{'version'} . '-' . $package->{'revision'}),
			dc          => {
				date => w3c_date($package->{'date'}),
			},
		);

		$rss->add_item( %itemdata ) or die "couldn't add item: $!\n";
		$split_rss->{$package->{'tree'}}->add_item( %itemdata ) or die "couldn't add item: $!\n";
	}

	my $lctree = lc($tree);
	$rss->save("$TOPDIR/fink-$lctree.rdf.new") or die "can't save rss: $!\n";
	push(@FILES, "$TOPDIR/fink-$lctree.rdf");

	for my $osver (sort keys %$split_rss) {
		$split_rss->{$osver}->save("$TOPDIR/fink-$osver-$lctree.rdf.new") or die "can't save rss: $!\n";
		push(@FILES, "$TOPDIR/fink-$osver-$lctree.rdf");
	}
}

sub find_infofiles {

	my ($shortname) = $_;
	my $is_info = ($File::Find::name =~ /\.info$/);
	my ($properties, @versions, $tree, $user);

	if ($File::Find::name =~ m#/experimental/([^/]*)/#) {
		$user = $1;
	} else {
		return unless ($is_info);
	}

	my @stat = stat($File::Find::name) or die "can't stat $_: $!\n";
	return unless ($stat[9] >= $CUTOFF);
	return unless ($stat[9] <= int ($NOW - 60 * 60 * 2)); # skip the newest 2 hours, to account for mirroring

	if ($is_info) {
		$properties = Fink::Package::read_properties($File::Find::name);
		$properties = Fink::Package->handle_infon_block($properties, $File::Find::name);
		@versions = Fink::Package->setup_package_object($properties, $File::Find::name);
		for my $index (0..$#versions) {
			$versions[$index]->{'type'} = 'info';
		}
	} else {
		my $descdetail;
		if ($File::Find::name =~ /\.(pl|pm)$/) {
			my $escaped = $File::Find::name;
			$escaped =~ s/\'/\\\'/gs;
			if (open (SCRIPT, "/usr/bin/code2html '$escaped' |")) {
				local $/ = undef;
				$descdetail = <SCRIPT>;
				$descdetail =~ s/^.*?<pre>\n//si;
				$descdetail =~ s/<\/pre>.*?$//si;
				close(SCRIPT);
			} else {
				warn "unable to run code2html on $File::Find::name: $!\n";
				if (open (SCRIPT, $File::Find::name)) {
					local $/ = undef;
					$descdetail = <SCRIPT>;
					close(SCRIPT);
				} else {
					warn "couldn't read from $File::Find::name: $!\n";
				}
			}
			# make the package hash
			my $package = {
				filename   => $File::Find::name,
				type       => 'perl',
				package    => $shortname,
				descdetail => $descdetail,
				tree       => 'experimental',
				owner      => $user,
			};
			push(@versions, $package);
		}
	}

	for my $version (@versions) {
		if ($version->{'type'} eq "info" and $version->get_info_filename() =~ /$DISTDIR\/([^\/]+)\//) {
			$version->{'tree'} = $1;
		}
		$version->{'date'} = $stat[9];
	
		$CVS_FILES{$File::Find::name} = undef;

		if ($version->{'tree'} eq 'experimental') {
			$EXPERIMENTAL_PACKAGES{$version->{'tree'} . '/' . $user} = $version;
		} elsif ($File::Find::name =~ m#$DISTDIR/$version->{'tree'}/stable/#) {
			$STABLE_PACKAGES{$tree . '/' . $version->get_name()} = $version;
		} elsif ($File::Find::name =~ m#$DISTDIR/$version->{'tree'}/unstable/#) {
			$UNSTABLE_PACKAGES{$tree . '/' . $version->get_name()} = $version;
		} else {
			warn "unknown tree: " . $version->{'tree'} . "\n";
		}
	}
}

sub encode_entities {
	my @lines = split(/\r?\n/, join("\n", @_));
	my $linelength = 0;
	my $spacecount = 999999;
	for my $line (@lines) {
		$linelength = length($line) if (length($line) > $linelength);
		$line =~ s/!\p{IsASCII}//gs;
#		$line =~ s/>/&gt;/gs;
#		$line =~ s/</&lt;/gs;
#		$line =~ s/&/&amp;/gs;
		$line =~ s/^\s*\.\s*$//gs;
		$line =~ s/\t/        /g;
		if ($line =~ /^(\s+)/) {
			my $count = length($1);
			$spacecount = $count if ($count < $spacecount);
		}
#		$_[$index] =~ s/([\x{80}-\x{FFFF}])/'&#' . ord($1) . ';'/gse;
#		$_[$index] =~ s/([^\x20-\x7F])/'&#' . ord($1) . ';'/gse;
#		$_[$index] =~ s/\xca//gs;
#		$_[$index] =~ tr/\x91\x92\x93\x94\x96\x97/''""\-\-/;
#		$_[$index] =~ tr/[\x80-\x9F]//d;
#		$_[$index] = pack("C*", unpack('U*', $_[$index]));
#		$_[$index] =~ s/\xa8//gs;
	}
	$spacecount = 0 if ($spacecount == 999999);
	my $lines = join("\n", map { $_ =~ s/^ {$spacecount}//; $_ } @lines);
	if ($linelength > 90) {
		$lines = fill("", "", $lines);
	}
	$lines =~ s/(<a)[\s\n]+(href=.*?)\n*(.*?<\/a>)/$1 $2$3/gsi;
	return($lines);
}
