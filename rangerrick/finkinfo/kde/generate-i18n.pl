#!/usr/bin/perl

my $I18NRELNUM   = 18;
my $KDEVERSION   = '3.1';
my $KDEDIRECTORY = 'stable/3.1/src/';
my $KDERELNUM    = 18;
my $KDEARTSVER   = '1.1.0-18';
my $KOVERSION    = '1.2.1';
my $KODIRECTORY  = 'stable/koffice-1.2.1/src/';
my $KORELNUM     = 4;
my $KOARTSVER    = '1.1.0-18';
my $VERBOSE      = 0;
my $DRYRUN       = 0;

my @kdepackages;
my @kopackages;

my %MAPPINGS;

for my $arg (@ARGV) {
	$VERBOSE = 1 if ($arg eq "-v");
	$DRYRUN  = 1 if ($arg eq "-d");
}

opendir(DIR, "/sw/src") or die "can't read from /sw/src: $!\n";
my @KDEI18N = sort(grep(/kde-i18n-.*-${KDEVERSION}.*.tar.(gz|bz2)/, readdir(DIR)));
closedir(DIR);

opendir(DIR, "/sw/src") or die "can't read from /sw/src: $!\n";
my @KOI18N = sort(grep(/koffice-i18n-.*-${KOVERSION}.*.tar.(gz|bz2)/, readdir(DIR)));
closedir(DIR);

open(MAPPING, "i18n-mappings.txt") or die "can't read i18n-mappings.txt: $!\n";
while (my $line = <MAPPING>) {
	my ($key, $value) = $line =~ /^\s*(\S+)\s*=\s*(.+?)\s*$/;
	$MAPPINGS{$key} = $value;
}
close(MAPPING);

for my $i18n (@KDEI18N) {
	my ($shortname) = $i18n =~ /kde-i18n-(.+)-${KDEVERSION}.*.tar.(gz|bz2)/;
	if (exists $MAPPINGS{$shortname}) {
		chomp(my $md5 = `md5 /sw/src/$i18n`);
		$md5 =~ s/^.*\s*=\s*//;
		my $normalized = lc($MAPPINGS{$shortname});
		$normalized =~ s#[^a-zA-Z]+#-#g;
		my $filename = $i18n;
		$filename =~ s#${KDEVERSION}#\%v#g;
		push(@kdepackages, "kde-i18n-${normalized}");
		my $contents = <<END;
Package: kde-i18n-${normalized}
Source: mirror:kde:${KDEDIRECTORY}kde-i18n/${filename}
SourceDirectory: kde-i18n-${shortname}
Description: KDE language files for $MAPPINGS{$shortname}
DescDetail: Language files for the K Desktop Environment: $MAPPINGS{$shortname}
Source-MD5: $md5
Version: ${KDEVERSION}
Revision: ${I18NRELNUM}
Depends: kdelibs3-ssl (>= %v-${KDERELNUM}) | kdelibs3 (>= %v-${KDERELNUM}), arts (>= ${KDEARTSVER}), xfonts-intl
BuildDepends: kdebase3-ssl (>= %v-${KDERELNUM}) | kdebase3 (>= %v-${KDERELNUM}), kdelibs3-ssl (>= %v-${KDERELNUM}) | kdelibs3 (>= %v-${KDERELNUM}), arts-dev (>= ${KDEARTSVER}), libxml2, xfonts-intl
Maintainer: Benjamin Reed <ranger\@befunk.com>
PatchScript: perl -pi -e 's,/share/doc/HTML,/share/doc/kde,g' configure
CompileScript: (export KDEDIR=%p; sh configure %c; make -j8)
InstallScript: <<
  make -j8 install DESTDIR=%d
  mkdir -p %i/share/doc/kde-installed-packages
  touch %i/share/doc/kde-installed-packages/kde-i18n-${normalized}
<<
License: GPL/LGPL
END
		print $contents if ($VERBOSE);
		my $infofile = "kde-i18n-${normalized}-${KDEVERSION}-${I18NRELNUM}.info";
		unless ($DRYRUN) {
			open(FILEOUT, ">$infofile") or die "can't write to $infofile: $!\n";
			print FILEOUT $contents;
			close(FILEOUT);
		}
	} else {
		print "ERROR: no name mapping for $i18n!\n";
	}
}

for my $i18n (@KOI18N) {
	my ($shortname) = $i18n =~ /koffice-i18n-(.+)-${KOVERSION}.*.tar.(gz|bz2)/;
	if (exists $MAPPINGS{$shortname}) {
		chomp(my $md5 = `md5 /sw/src/$i18n`);
		$md5 =~ s/^.*\s*=\s*//;
		my $normalized = lc($MAPPINGS{$shortname});
		$normalized =~ s#[^a-zA-Z]+#-#g;
		my $filename = $i18n;
		$filename =~ s#${KOVERSION}#\%v#g;
		push(@kopackages, "koffice-i18n-${normalized}");
		my $contents = <<END;
Package: koffice-i18n-${normalized}
Source: mirror:kde:${KODIRECTORY}${filename}
SourceDirectory: koffice-i18n-${shortname}
Description: KOffice language files for $MAPPINGS{$shortname}
DescDetail: Language files for the KDE office suite: $MAPPINGS{$shortname}
Source-MD5: $md5
Version: ${KOVERSION}
Revision: ${I18NRELNUM}
Depends: kdelibs3-ssl (>= %v-${KORELNUM}) | kdelibs3 (>= %v-${KORELNUM}), arts (>= ${KOARTSVER}), xfonts-intl, koffice-base (>= ${KOVERSION}-${KORELNUM})
BuildDepends: kdebase3-ssl (>= %v-${KORELNUM}) | kdebase3 (>= %v-${KORELNUM}), kdelibs3-ssl (>= %v-${KORELNUM}) | kdelibs3 (>= %v-${KORELNUM}), arts-dev (>= ${KOARTSVER}), koffice-dev (>= ${KOVERSION}-${KORELNUM}), libxml2, xfonts-intl
Maintainer: Benjamin Reed <ranger\@befunk.com>
PatchScript: perl -pi -e 's,/share/doc/HTML,/share/doc/kde,g' configure
CompileScript: (export KDEDIR=%p; sh configure %c; make -j8)
InstallScript: <<
  make -j8 install DESTDIR=%d
  mkdir -p %i/share/doc/kde-installed-packages
  touch %i/share/doc/kde-installed-packages/koffice-i18n-${normalized}
<<
License: GPL/LGPL
END
		print $contents if ($VERBOSE);
		my $infofile = "koffice-i18n-${normalized}-${KOVERSION}-${I18NRELNUM}.info";
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
	my $packagelist = join(', ', map { $_ . " (>= ${KDEVERSION}-${I18NRELNUM})" } @kdepackages);
	open(FILEOUT, ">bundle-kde-i18n-${KDEVERSION}-${I18NRELNUM}.info") or die "can't write to bundle-kde-i18n-${KDEVERSION}-${I18NRELNUM}.info: $!\n";
	print FILEOUT <<END;
Package: bundle-kde-i18n
Version: ${KDEVERSION}
Revision: ${I18NRELNUM}
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

	$packagelist = join(', ', map { $_ . " (>= ${KOVERSION}-${I18NRELNUM})" } @kopackages);
	open(FILEOUT, ">bundle-koffice-i18n-${KOVERSION}-${I18NRELNUM}.info") or die "can't write to bundle-koffice-i18n-${KOVERSION}-${I18NRELNUM}.info: $!\n";
	print FILEOUT <<END;
Package: bundle-koffice-i18n
Version: ${KOVERSION}
Revision: ${I18NRELNUM}
Type: bundle
Depends: $packagelist
Description: KOffice convenience package: all language files
DescDetail: <<
This package doesn't install any files of itself, but instead makes
sure that all KOffice language files get installed.
<<
Maintainer: Benjamin Reed <ranger\@befunk.com>
END
	close(FILEOUT);
}
