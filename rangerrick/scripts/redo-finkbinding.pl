#!/usr/bin/perl

my %deps;
my %done;
my %badpackage;

if (@ARGV) {
	for my $file (@ARGV) {
		update_deps($file);
	}
} else {
	open (FILEIN, "/sw/fink/dists/seg_addr_table") or die "couldn't read seg_addr_table: $!\n";
	while (<FILEIN>) {
		next unless (/^0x\d+\s+\//);
		my ($address, $file) = split(/\s+/);
		update_deps($file);
	}
	close(FILEIN);
}

for my $dep (sort keys %deps) {
	redo_prebinding($dep);
}

delete $badpackage{'xfree86-shlibs'};

if (keys %badpackage) {
	print "These packages need to be made twolevel:\n";
	for my $key (sort keys %badpackage) {
		print "- $key\n";
	}
}

sub redo_prebinding {
	my $install_name = shift;
	if (exists $done{$install_name}) {
		#print "$install_name: already prebound\n";
		return;
	}

	for my $subdep (@{$deps{$install_name}->{'deps'}}) {
		redo_prebinding($subdep->{'name'});
	}

	print "- $install_name... ";
	my $system_name = $install_name;
	   $system_name =~ s/\'/\\\'/g;
	# force into single-segment table
	$ENV{'MACOSX_DEPLOYMENT_TARGET'} = '10.1';
	my $output = `redo_prebinding -seg_addr_table /sw/fink/dists/seg_addr_table '$system_name' 2>&1`;
	chomp($output);
	if ($?) {
		if ($output =~ /is not prebound/) {
			print "failed (file is not prebound)\n";
			my $package = `dpkg -S '$system_name'`;
			chomp($package);
			$package =~ s/^([^:]*):.*$/$1/;
			$badpackage{$package} = 1;
		} else {
			print "failed\n  ";
			warn($output);
		}
	} else {
		print "done\n";
	}
	$done{$install_name} = 1;

	return 1;
}

sub update_deps {
	my $filename = shift;

	return if (exists $deps{$filename});

	my @deplist;
	my $is_install_name = 0;

	my $system_name = $filename;
	   $system_name =~ s/\'/\\\'/g;
	open(OTOOL, "otool -L '$system_name' |") or die "couldn't run otool -L: $!\n";
	while (<OTOOL>) {
		chomp;
		if (/:$/) {
			$is_install_name++;
			next;
		}
		if (($dep) = $_ =~ /^\s+(\/.+?)\s+/) {
			if ($is_install_name) {
				$filename = $dep;
				$is_install_name = 0;
			} elsif (
				$dep !~ /libSystem/ and
				$dep ne $filename and
				$dep !~ /\/Library\/Frameworks/ and
				$dep !~ /\/usr\/lib/
			) {
				push(@deplist, $dep);
			}
		}
	}
	close(OTOOL);

	$deps{$filename} = { name => $filename, deps => [] };

	for my $dep (@deplist) {
		if (not exists $deps{$dep}) {
			update_deps($dep);
		}
		push(@{$deps{$filename}->{'deps'}}, $deps{$dep});
	}
}
