#!/usr/bin/perl

use File::Find;
use XML::RSS;
use strict;

use vars qw(
	$CUTOFF
	$DAYS
	$NOW
	$PREFIX
	$SCP

	@FILES

	$STABLE_RSS
	$UNSTABLE_RSS
	%STABLE_PACKAGES
	%UNSTABLE_PACKAGES
);

$DAYS   = 7; # number of days to look back
$NOW    = time;
$CUTOFF = ($NOW - (60 * 60 * 24 * $DAYS));
$PREFIX = '/tmp/fink-rss';
$SCP    = 1;

print "- updating cvs repository... ";
system("mkdir -p $PREFIX");
system("cd $PREFIX; cvs -d :pserver:anonymous\@cvs.fink.sourceforge.net:/cvsroot/fink co dists packages >$PREFIX/cvs.log 2>&1");
print "done\n";

print "- searching for new info files... ";
find(\&find_infofiles, $PREFIX);
print "done\n";

print "- generating RSS... ";
make_rss(\%STABLE_PACKAGES, 'Stable');
make_rss(\%UNSTABLE_PACKAGES, 'Unstable');
print "done\n";

if ($SCP) {
	print "- copying feeds to the Fink website... ";
	system("scp @FILES rangerrick\@fink.sourceforge.net:/home/groups/f/fi/fink/htdocs/news/ >/dev/null 2>&1");
	system("ssh rangerrick\@fink.sourceforge.net 'cd /home/groups/f/fi/fink/htdocs; ./fix_perm.sh' >/dev/null 2>&1");
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
	#$time[4] += 1;

	my @days   = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
	my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

	return sprintf('%s, %02d %s %04d %02d:%02d:%02d EST', $days[$time[6]], $time[3], $months[$time[4]], $time[5], $time[2], $time[1], $time[0]);
}

sub make_rss {
	my $packagehash = shift;
	my $tree        = shift;
	my $rss         = XML::RSS->new(version => '1.0');

	$rss->channel(
		title       => "New Fink Packages ($tree)",
		link        => 'http://fink.sourceforge.net/',
		description => "New Packages Released to the $tree Tree in the Last $DAYS Days.",
		dc          => {
			date      => w3c_date(time),
			subject   => 'Fink Software',
			creator   => 'fink-devel@lists.sf.net',
			publisher => 'fink-devel@lists.sf.net',
			language  => 'en-us',
		},
		syn         => {
			updatePeriod    => 'hourly',
			updateFrequency => '1',
			updateBase      => '2000-01-01T00:00:00-05:00',
		},
	);

	my $description;
	for my $package (sort { $packagehash->{$b}->{'date'} <=> $packagehash->{$a}->{'date'} } keys %{$packagehash}) {
		$package = $packagehash->{$package};
		if (not exists $package->{'descdetail'} or $package->{'descdetail'} =~ /^\s*$/gs) {
			$description = $package->{'description'};
		} else {
			$description = $package->{'descdetail'};
		}
		$description =~ s/[\s\n\r]+/ /gs; $description =~ s/^\s+//; $description =~ s/\s+$//;
		$description =~ s/</&lt;/gs;
		$description =~ s/>/&gt;/gs;
		$description =~ s/&/&amp;/gs;
		# $description = '(updated ' . w3c_date($package->{'date'}) . ') ' . $description;
		$rss->add_item(
			title       => $package->{'package'} . ' ' . $package->{'version'} . ' (' . $package->{'description'} . ')',
			description => $description,
			link        => 'http://fink.sourceforge.net/pdb/package.php/' . $package->{'package'},
			dc          => {
				date => w3c_date($package->{'date'}),
			},
		);
	}

	my $lctree = lc($tree);
	$rss->save("fink-$lctree.rdf") or die "can't save rss: $!\n";
	push(@FILES, "fink-$lctree.rdf");
}

sub find_infofiles {
	return unless (/\.info$/);

	my @stat = stat($File::Find::name) or die "can't stat $_: $!\n";
	return unless ($stat[9] >= $CUTOFF);

	my $text;
	open(FILEIN, $File::Find::name) or die "can't open $File::Find::name: $!\n";
	{ local $/ = undef; $text = <FILEIN>; }
	my $hash = parse_keys($text);
	close(FILEIN);

	next unless (exists $hash->{'package'});
	$hash->{'date'} = $stat[9];

	if ($File::Find::name =~ m#/stable/#) {
		$STABLE_PACKAGES{$hash->{'package'}} = $hash;
	} else {
		$UNSTABLE_PACKAGES{$hash->{'package'}} = $hash;
	}
}

sub parse_keys {
	my $text    = shift;
	my $hash    = {};
	my $lastkey = "";
	my $heredoc = 0;

	for (split(/\r?\n/, $text)) {
		chomp;
		if ($heredoc > 0) {
			if (/^\s*<<$/) {
				$heredoc--;
				$hash->{lc($lastkey)} .= $_."\n" if ($heredoc > 0);
			} else {
				$hash->{lc($lastkey)} .= $_."\n";
				$heredoc++ if (/<<$/);
			}
		} else {
			next if /^\s*\#/;	# skip comments
			if (/^\s*([0-9A-Za-z_.\-]+)\:\s*(\S.*?)\s*$/) {
				$lastkey = lc($1);
				if ($2 eq "<<") {
					$hash->{lc($lastkey)} = "";
					$heredoc = 1;
				} else {
					$hash->{lc($lastkey)} = $2;
				}
			} elsif (/^\s+(\S.*?)\s*$/) {
				$hash->{lc($lastkey)} .= "\n".$1;
			}
		}
	}

	if ($heredoc > 0) {
		print "WARNING: End of file reached during here-document.\n";
	}

	return $hash;
}

