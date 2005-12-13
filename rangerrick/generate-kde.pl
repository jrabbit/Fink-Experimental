#!/usr/bin/perl

use File::Basename;
use File::Find;
use File::Path;
use Cwd 'abs_path';

my $path = abs_path(dirname($0));

my @files = @ARGV;
my %files;

if (not @files) {
	find(sub {
		push(@files, $File::Find::name);
	}, $path . '/common');
}

for my $file (@files) {
	if ($file !~ /^\//) {
		$file = $path . '/' . $file;
	}
	my ($dir, $filename) = (dirname($file), basename($file));

	next unless ($file =~ /\.(info|patch)$/);
	next unless ($file =~ /(kde|postgres|libpq|libpg|wv2|icecream|qt3|qca|kgpg|xfree86|xorg|\/mono\.|libgdiplus|monodevelop|cocoa-sharp|perlmods|libsmoke|fung-calc)/);
	next if ($file =~ /notready/);

	#for my $tree ('10.2-gcc3.3', '10.3', '10.4') {
	for my $tree ('10.3', '10.4') {
		my $todir = $dir;
		$todir =~ s,common/,${tree}/,;

		print "- $todir/$filename... ";

		if (mkdir_p($todir)) {
			system('cp', $dir . '/' . $filename, $todir . '/' . $filename) == 0
				or "couldn't copy $filename to $todir: $!\n";
			if ($filename =~ /\.info$/) {
				if (open(FILEIN, $dir .'/'. $filename)) {
					if (open(FILEOUT , '>' . $todir . '/' . $filename)) {
						print "converting... ";
						my $version = 0;
						my $revision = 0;
						while (my $line = <FILEIN>) {
							if ($line =~ /^\s*revision:\s*(.*?)\s*$/i) {
								$revision = $1;
								if (my ($pre, $post) = $revision =~ /^(.*\.)(\d+)$/) {
									$post += 10 if ($tree eq '10.3');
									$post += 20 if ($tree eq '10.4');
									$revision = $pre . $post;
								} else {
									$revision += 10 if ($tree eq '10.3');
									$revision += 20 if ($tree eq '10.4');
								}
								print FILEOUT "Revision: $revision\n";
							} else {
								if ($line =~ /^\s*(Build)?Depends/gi) {
									my $newline = $line;
									while ($line =~ /\G.*?((?:arts|kde\S+(?:i18n|3|3-unified)|qt3|postgresql80)\S*)\s+\(([^\)]*?)\)/g) {
										my $package = $1;
										my $version = $2;
										my ($comparator, $revision);
										if ($version =~ /^([^\%]+?)\s+([^-]+)-([^\%]+?)$/) {
											($comparator, $version, $revision) = ($1, $2, $3);
											#print "$package ($version-$revision) -> ";
											if (my ($pre, $post) = $revision =~ /^(.*\.)(\d+)$/) {
												$post += 10 if ($tree eq '10.3');
												$post += 20 if ($tree eq '10.4');
												$revision = $pre . $post;
											} else {
												$revision += 10 if ($tree eq '10.3');
												$revision += 20 if ($tree eq '10.4');
											}
											$newline =~ s/${package}\s+\([^\)]*?\)/$package ($comparator $version-$revision)/g;
											#print "($version-$revision)... ";
										}
									}
									$line = $newline;
								} elsif ($line =~ /^(\s*)type:\s*perl\s*\((.*)\)\s*$/i) {
									my @versions = split(/\s+/, $2);
									if ($tree =~ /^10\.2/) {
										@versions = qw(5.6.0 5.6.1 5.8.1);
									} elsif ($tree =~ /^10\.3/) {
										@versions = qw(5.6.0 5.8.0 5.8.1 5.8.4 5.8.6);
									} elsif ($tree =~ /^10\.4/) {
										@versions = qw(5.8.1 5.8.4 5.8.6);
									}
									$line = $1 . "Type: perl(@versions)\n";
								} elsif ($line =~ /^(\s*)type:\s*python\s*\((.*)\)\s*$/i) {
									my @versions = split(/\s+/, $2);
									if ($tree =~ /^10\.2/) {
										@versions = qw(2.1 2.2 2.3);
									} elsif ($tree =~ /^10\.3/) {
										@versions = qw(2.1 2.2 2.3 2.4);
									} elsif ($tree =~ /^10\.4/) {
										@versions = qw(2.2 2.3 2.4);
									}
									$line = $1 . "Type: python(@versions)\n";
								}

								if ($tree =~ /^10\.2/) {
									$line =~ s/^\#10.2\s+(.*)$/$1/;
									$line =~ s/libgsf-dev/libgsf/g;
									$line =~ s/gstreamer\S*?(\s+\([^\)]+\))?\s*[\,\s]*//g;
									$line =~ s/((imagemagick.*?)-dev)/$2/g;
									$line =~ s/(freetype2\S*) \((\S+)\s+2.1.3-\d+\)/$1 ($2 2.1.3-2)/g;
								} else {
									$line =~ s/(kerberos[^,]*, )//g unless ($tree =~ /^10\.4/);
									$line =~ s/^\#(\s*export\s+LD_TWOLEVEL_NAMESPACE.*)$/$1/;
									$line =~ s/(dlcompat|libpoll)(\S*)(\s+\([^\)]+\))?[\,\s]*//g unless ($line =~ m#-I/usr/X11R6/include#);
									$line =~ s/(dlcompat|libpoll|mdnsresponder)(\S*)(\s+\([^\)]+\))?[\,\s]*//g unless ($line =~ m#-I/usr/X11R6/include#);
									$line =~ s/, libgnugetopt(-shlibs)?$//;
									$line =~ s/libgnugetopt(-shlibs)?, //;
									$line =~ s/-I.*?\/include\/gnugetopt //;
									$line =~ s/^SetMACOSX_DEPLOYMENT_TARGET: 10.2/SetMACOSX_DEPLOYMENT_TARGET: $tree/;
									$line =~ s/--disable-(ada|haskell|pascal) *//g;
									$line =~ s/^\#${tree}\s+(.*)$/$1/;
									next if ($line =~ /^\s*Depends: libgnugetopt-shlibs$/);
								}

								if ($tree =~ /^10.3/) {
									$line =~ s/libxine1/libxine/gs;
									$line =~ s/(^\s*|,\s*)fontconfig2-shlibs//;
									$line =~ s/libicu32-dev, *//;
									$line =~ s/(^\s*|,\s*)macosx \(>= 10.4.*?\)//;
								} elsif ($tree =~ /^10.4/) {
									$line =~ s/libicu31-dev, *//;
								}

								if ($tree >= 10.4) {
									$line =~ s/(^|,\s*)libftw0(-shlibs)?\s*//;
									$line =~ s/gcc3.1[,\s]*//;
									# java's broken everywhere right now
									#$line =~ s/--disable-java //;
								} else {
									if ($line =~ /libkfontinst/) {
										$line = "###RR:skip###\n";
									}
								}
								$line .= "\n" unless ($line =~ /\n+$/);
								print FILEOUT $line unless ($line =~ /###RR:skip###/);
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

