#!/usr/bin/perl

my $VERSION   = '3.0.98';
my $DIRECTORY = 'unstable/kde-3.1-rc2/src/';
my $ARTSVER   = '1.1.0-6';
my $VERBOSE   = 0;
my $DRYRUN    = 0;
my @packages;

my %MAPPINGS;

for my $arg (@ARGV) {
	$VERBOSE = 1 if ($arg eq "-v");
	$DRYRUN  = 1 if ($arg eq "-d");
}

opendir(DIR, "/sw/src") or die "can't read from /sw/src: $!\n";
my @I18N = sort(grep(/kde-i18n-.*-${VERSION}.*.tar.(gz|bz2)/, readdir(DIR)));
closedir(DIR);

open(MAPPING, "i18n-mappings.txt") or die "can't read i18n-mappings.txt: $!\n";
while (my $line = <MAPPING>) {
	my ($key, $value) = $line =~ /^\s*(\S+)\s*=\s*(.+?)\s*$/;
	$MAPPINGS{$key} = $value;
}
close(MAPPING);

for my $i18n (@I18N) {
	my ($shortname) = $i18n =~ /kde-i18n-(.+)-${VERSION}.tar.(gz|bz2)/;
	if (exists $MAPPINGS{$shortname}) {
		chomp(my $md5 = `md5 /sw/src/$i18n`);
		$md5 =~ s/^.*\s*=\s*//;
		my $normalized = lc($MAPPINGS{$shortname});
		$normalized =~ s#[^a-zA-Z]+#-#g;
		my $filename = $i18n;
		$filename =~ s#${VERSION}#\%v#g;
		push(@packages, "kde-i18n-${normalized}");
		my $contents = <<END;
Package: kde-i18n-${normalized}
Source: mirror:kde:${DIRECTORY}kde-i18n/${filename}
SourceDirectory: kde-i18n-${shortname}
Description: KDE language files for $MAPPINGS{$shortname}
DescDetail: Language files for the K Desktop Environment: $MAPPINGS{$shortname}
Source-MD5: $md5
Version: ${VERSION}
Revision: 1
Depends: kdelibs3-ssl (>= %v-1) | kdelibs3 (>= %v-1), arts (>= ${ARTSVER}), xfonts-intl
BuildDepends: kdebase3-ssl (>= %v-1) | kdebase3 (>= %v-1), kdelibs3-ssl (>= %v-1) | kdelibs3 (>= %v-1), arts-dev (>= ${ARTSVER})
Maintainer: Benjamin Reed <ranger\@befunk.com>
CompileScript: (export KDEDIR=%p; sh configure %c; make)
InstallScript: make install DESTDIR=%d
License: GPL/LGPL
END
		print $contents if ($VERBOSE);
		my $infofile = "kde-i18n-${normalized}-${VERSION}-1.info";
		unless ($DRYRUN) {
			open(FILEOUT, ">$infofile") or die "can't write to $infofile: $!\n";
			print FILEOUT $contents;
			close(FILEOUT);
		}
	} else {
		print "ERROR: no name mapping for $i18n!\n";
	}
}

unless ($DRYRUN) {
	my $packagelist = join(', ', map { $_ . " (>= ${VERSION}-1)" } @packages);
	open(FILEOUT, ">bundle-kde-i18n-${VERSION}-1.info") or die "can't write to bundle-kde-i18n-${VERSION}-1.info: $!\n";
	print FILEOUT <<END;
Package: bundle-kde-i18n
Version: ${VERSION}
Revision: 1
Type: bundle
Depends: $packagelist
Description: KDE convenience package: all language files
DescDetail: <<
This package doesn't install any files of itself, but instead makes
sure that all KDE language files get installed.
<<
Maintainer: Benjamin Reed <ranger\@befunk.com>
END
	close(FILEOUT);
}
