#!/sw/bin/perl5.8.0

$|++;

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
	$DOCVS
	$NOW
	$PREFIX
	$DOSCP
	$TOPDIR

	@FILES

	$STABLE_RSS
	$UNSTABLE_RSS
	%STABLE_PACKAGES
	%UNSTABLE_PACKAGES

	%CVS_FILES

	$CACHE
	$DOCACHE

	$basepath
	$Config

	$URIFINDER
);

$basepath = '/sw';
$TOPDIR   = abs_path(dirname($0));
$DAYS     = 3; # number of days to look back
$NOW      = time;
$CUTOFF   = ($NOW - (60 * 60 * 24 * $DAYS));
$PREFIX   = '/tmp/fink-rss';
$DOSCP    = 1;
$DOCVS    = 1;
$DOCACHE  = 0;

$URIFINDER = URI::Find->new(
	sub {
		my($uri, $orig_uri) = @_;
		return qq|<a href="$uri">$orig_uri</a>|;
	}
);

if (-f '/tmp/rss.cache' and $DOCACHE) {
	$CACHE = retrieve('/tmp/rss.cache');
}

$ENV{CVS_RSH} = '/Users/ranger/bin/ssh.sh';
#$ENV{CVS_RSH} = 'ssh';

print "- updating cvs repository... ";
`mkdir -p '$PREFIX'`;
unless (-f $PREFIX . '/dists/CVS') {
  unlink($PREFIX . '/dists');
}
if (-d $PREFIX . '/dists') {
	`cd $PREFIX . '/dists'; CVS_RSH=/Users/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink up -A >$PREFIX/cvs.log 2>&1`;
} else {
	`cd $PREFIX; CVS_RSH=/Users/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink co dists >$PREFIX/cvs.log 2>&1`;
}
#`cd $PREFIX; cvs -d :pserver:anonymous\@cvs.sourceforge.net:/cvsroot/fink co dists >$PREFIX/cvs.log 2>&1`;
#`cd $PREFIX; rsync -azvr rsync://master.us.finkmirrors.net/finkinfo/ dists >$PREFIX/rsync.log 2>&1`;
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

find(\&find_infofiles, $PREFIX);

print "- getting CVS log info... ";
get_cvs_log();
print "done\n";

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
	#print "rsync -av -e $ENV{CVS_RSH} $newfiles rangerrick\@fink.sourceforge.net:/home/groups/f/fi/fink/htdocs/news/ >/tmp/rss-rsync.log 2>&1\n";
	`rsync -av -e $ENV{CVS_RSH} $newfiles rangerrick\@fink.sourceforge.net:/home/groups/f/fi/fink/htdocs/news/ >/tmp/rss-rsync.log 2>&1`;

	my $movecommands;
	for my $file (@FILES) {
		$file =~ s/.*\///;
		$movecommands .= "; mv news/${file}.new news/${file}; chgrp fink news/${file}";
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

	my @keys = map { $_ =~ s,^$PREFIX/dists/,,; $_ } sort keys %CVS_FILES;

	my $filename;
	my $revdone = 0;
	my $lookfordesc = 0;
	my $author;
	my $spacecount = 100;
	my @lines;
	my $pwd = `pwd`;
	my $count = 0;
	chdir($PREFIX . '/dists');
	if (open(CVSLOG, "CVS_RSH=/Users/ranger/bin/ssh.sh cvs -d :ext:rangerrick\@cvs.sourceforge.net:/cvsroot/fink log @keys 2>$PREFIX/cvslog.log |")) {
		$count = 0;
		open(FILEOUT, ">$PREFIX/cvslog-data.log");
		while (my $line = <CVSLOG>) {
			print FILEOUT $line;
			$count++;
			if ($line =~ m#\s*RCS file: /cvsroot/fink/dists/(.*),v#) {
				for my $index (0..$#lines) {
					$lines[$index] =~ s/^\s{$spacecount}//;
				}
				if (not defined $CVS_FILES{$filename} and defined $author and int(@lines)) {
					$CVS_FILES{$filename} = [ $author, join('', @lines) ];
				}
				$filename = $PREFIX . '/dists/' . $1;
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
		if (not defined $CVS_FILES{$filename} and defined $author and int(@lines)) {
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

sub make_rss {
	my $packagehash = shift;
	my $tree        = shift;
	my $rss         = XML::RSS->new(version => '1.0');

	$rss->channel(
		title       => "Updated Fink Packages ($tree)",
		link        => 'http://fink.sourceforge.net/pdb/',
		description => "Updated Packages Released to the $tree Tree in the Last $DAYS Days.",
		dc          => {
			date      => w3c_date(time),
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

	my $description;
	for my $package (sort { $packagehash->{$b}->{'date'} <=> $packagehash->{$a}->{'date'} || $a <=> $b } keys %{$packagehash}) {
		$package = $packagehash->{$package};

		next if ($CACHE->{$tree}->{$package->{'package'}} eq $package->{'version'} . '-' . $package->{'revision'});
		$CACHE->{$tree}->{$package->{'package'}} = $package->{'version'} . '-' . $package->{'revision'};

		print "  - ", $package->{'package'}, " ", $package->{'version'} . "-" . $package->{'revision'}, "\n";
		if (not exists $package->{'descdetail'} or $package->{'descdetail'} =~ /^\s*$/gs) {
			$description = $package->{'description'};
		} else {
			$description = $package->{'descdetail'};
		}

		$description =~ s/[\r\n]+$//gsi;
		$description =~ s/<(http:\/\/[^>]+)>/$1/gsi;
		$description =~ s/<(.+\@[^\@]+)>/mailto:$1"/gsi;
		$description = encode_entities($description);
		$URIFINDER->find(\$description);
		if ($DOCVS) {
			if (exists $CVS_FILES{$package->get_info_filename()}) {
				my $content = $CVS_FILES{$package->get_info_filename()}->[1];
				$content = encode_entities($content);
				$description = $description . "\n\ncommit log from " .
					$CVS_FILES{$package->get_info_filename()}->[0] . ":\n" .
					$content;
			} else {
				warn "no CVS information for " . $package->get_info_filename() . "\n";
			}
		}

		$rss->add_item(
			title       => encode_entities($package->{'package'} . ' ' . $package->{'version'} . '-' . $package->{'revision'} . ' (' . $package->{'description'} . ', ' . $package->{'tree'} . ' tree)'),
			description => '<![CDATA[<pre>' . $description . '</pre>]]>',
			#description => $description,
			link        => encode_entities('http://fink.sourceforge.net/pdb/package.php/' . $package->{'package'} . '#' . $package->{'version'} . '-' . $package->{'revision'}),
			dc          => {
				date => w3c_date($package->{'date'}),
			},
		) or die "couldn't add item: $!\n";
	}

	my $lctree = lc($tree);
	$rss->save("$TOPDIR/fink-$lctree.rdf.new") or die "can't save rss: $!\n";
	push(@FILES, "$TOPDIR/fink-$lctree.rdf");
}

sub find_infofiles {
	return unless (/\.info$/);
	my $tree = '10.2';
	if ($File::Find::name =~ /dists\/([^\/]+)\//) {
		$tree = $1;
	}

	my @stat = stat($File::Find::name) or die "can't stat $_: $!\n";
	return unless ($stat[9] >= $CUTOFF);
	return unless ($stat[9] <= int (time - 60 * 60 * 2)); # skip the newest 2 hours, to account for mirroring

	my $properties = Fink::Package::read_properties($File::Find::name);
	$properties = Fink::Package->handle_infon_block($properties, $File::Find::name);
	my @versions = Fink::Package->setup_package_object($properties, $File::Find::name);
	#print $File::Find::name, " - ", int(@versions), " version(s)\n";

	for my $version (@versions) {
		if ($version->get_info_filename() =~ /dists\/([^\/]+)\//) {
			$version->{'tree'} = $1;
		}
		$version->{'date'} = $stat[9];
	
		$CVS_FILES{$File::Find::name} = undef;
	
		if ($File::Find::name =~ m#/stable/#) {
			$STABLE_PACKAGES{$tree . '/' . $version->get_name()} = $version;
		} else {
			$UNSTABLE_PACKAGES{$tree . '/' . $version->get_name()} = $version;
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
