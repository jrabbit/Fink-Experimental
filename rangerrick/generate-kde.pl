#!/usr/bin/perl

use File::Basename;
use File::Find;
use File::Path;
use Cwd 'abs_path';

my $path = abs_path(dirname($0));

my %files;

find(sub {
	return unless ($File::Find::name =~ /(kde|postgres|libpq|libpg|wv2|icecream|qt3|qca|kgpg)/);
	return if ($File::Find::name =~ /notready/);
	$files{$File::Find::name}++ if ($File::Find::name =~ /\.(info|patch)$/);
}, $path . '/common');

for my $file (sort keys %files) {
	my ($dir, $filename) = (dirname($file), basename($file));

	for my $tree ('10.2-gcc3.3', '10.3') {
		my $todir = $dir;
		$todir =~ s,/common/,/${tree}/,;

		print "- $todir/$filename... ";

		if (mkdir_p($todir)) {
			system('cp', $dir . '/' . $filename, $todir . '/' . $filename) == 0
				or "couldn't copy $filename to $todir: $!\n";
			if ($filename =~ /\.info$/) {
				if (open(FILEIN, $dir .'/'. $filename)) {
					if (open(FILEOUT , '>' . $todir . '/' . $filename)) {
						print "converting... ";
						while (my $line = <FILEIN>) {
							if ($line =~ /^\s*revision:\s*(.*?)\s*$/i) {
								my $revision = $1;
								if (my ($pre, $post) = $revision =~ /^(.*\.)(\d+)$/) {
									$post += 10 if ($tree eq '10.2-gcc3.3');
									$post += 20 if ($tree eq '10.3');
									$revision = $pre . $post;
								} else {
									$revision += 10 if ($tree eq '10.2-gcc3.3');
									$revision += 20 if ($tree eq '10.3');
								}
								print FILEOUT "Revision: $revision\n";
							} else {
								if ($line =~ /^\s*(Build)?Depends/g) {
									my $newline = $line;
									while ($line =~ /\G.*?((?:arts|kde\S+3|qt3)\S*)\s+\(([^\)]*?)\)/g) {
										my $package = $1;
										my $version = $2;
										my ($comparator, $revision);
										if ($version =~ /^(.+?)\s+(.+)-(.+?)$/) {
											($comparator, $version, $revision) = ($1, $2, $3);
											#print "$package ($version-$revision) -> ";
											if (my ($pre, $post) = $revision =~ /^(.*\.)(\d+)$/) {
												$post += 10 if ($tree eq '10.2-gcc3.3');
												$post += 20 if ($tree eq '10.3');
												$revision = $pre . $post;
											} else {
												$revision += 10 if ($tree eq '10.2-gcc3.3');
												$revision += 20 if ($tree eq '10.3');
											}
											$newline =~ s/${package}\s+\([^\)]*?\)/$package ($comparator $version-$revision)/g;
											#print "($version-$revision)... ";
										}
									}
									$line = $newline;
								}
								if ($tree =~ /^10\.2/) {
									$line =~ s/^\#10.2\s+(.*)$/$1/;
									$line =~ s/libgsf-dev/libgsf/g;
									$line =~ s/gstreamer\S*?(\s+\([^\)]+\))?\s*[\,\s]*//g;
									$line =~ s/((imagemagick.*?)-dev)/$2/g;
									$line =~ s/(freetype2\S*) \((\S+)\s+2.1.3-23\)/$1 ($2 2.1.3-2)/g;
								} else {
									$line =~ s/^\#(\s*export\s+LD_TWOLEVEL_NAMESPACE.*)$/$1/;
									$line =~ s/(dlcompat|libpoll)(\S*)(\s+\([^\)]+\))?[\,\s]*//g unless ($line =~ m#-I/usr/X11R6/include#);
									$line =~ s/, libgnugetopt(-shlibs)?$//;
									$line =~ s/libgnugetopt(-shlibs)?, //;
									$line =~ s/-I.*?\/include\/gnugetopt //;
									$line =~ s/^SetMACOSX_DEPLOYMENT_TARGET: 10.2/SetMACOSX_DEPLOYMENT_TARGET: 10.3/;
									$line =~ s/--disable-(ada|haskell|pascal) *//g;
									$line =~ s/^\#10.3\s+(.*)$/$1/;
									next if ($line =~ /^\s*Depends: libgnugetopt-shlibs$/);
								}
								print FILEOUT $line;
							}
						}
						if ($filename =~ /(arts|kde\S+3|koffice|quanta|bundle-kde)/ and open(DESCUSAGE, $path . '/kdedesc.txt')) {
							while (<DESCUSAGE>) {
								print FILEOUT;
							}
							close(DESCUSAGE);
						}
						print "done\n";
						close(FILEOUT);
					} else {
						warn "couldn't write to $todir/$filename: $!\n";
					}
					close(FILEIN);
				} else {
					warn "couldn't read from $dir/$filename: $!\n";
				}
			} else {
				print "copied\n";
			}
		} else {
			warn "couldn't create $todir: $!\n";
		}
	}
}

sub mkdir_p {
	my $dir = shift;

	eval { mkpath($dir, 0, 0775) };
	if ($@) {
		warn "unable to create $dir: $!\n";
	} else {
		return 1;
	}
	return;
}

