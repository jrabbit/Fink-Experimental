#!/usr/bin/perl

my $KOI18NRELNUM  = 1;
my $KDEVERSION    = '3.4.0';
my $KDEDIRECTORY  = 'stable/3.4/src/';
my $KDERELNUM     = 1;
my $KDEARTSVER    = '1.4.0-1';
my $KDEI18NRELNUM = 2;
my $KOVERSION     = '1.3.5';
my $KODIRECTORY   = 'stable/koffice-%v/src/';
my $KORELNUM      = '1';
my $VERBOSE       = 0;
my $DRYRUN        = 0;

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
	my ($shortname) = $i18n =~ /kde-i18n-([^\-]+)-${KDEVERSION}.*.tar.(gz|bz2)/;
	if (exists $MAPPINGS{$shortname}) {
		chomp(my $md5 = `md5 /sw/src/$i18n`);
		$md5 =~ s/^.*\s*=\s*//;
		my $normalized = lc($MAPPINGS{$shortname});
		$normalized =~ s#[^a-zA-Z]+#-#g;
		$normalized =~ s#-*$##;
		my $filename = $i18n;
		$filename =~ s#${KDEVERSION}#\%v#g;
		push(@kdepackages, "kde-i18n-${normalized}");
		my $contents = <<END;
Package: kde-i18n-${normalized}
Source: mirror:kde:${KDEDIRECTORY}kde-i18n/${filename}
SourceDirectory: kde-i18n-${shortname}-%v
Description: KDE - language files for $MAPPINGS{$shortname}
DescDetail: Language files for the K Desktop Environment: $MAPPINGS{$shortname}
Source-MD5: $md5
Version: ${KDEVERSION}
Revision: ${KDEI18NRELNUM}
Replaces: koffice-i18n-${normalized}, khangman, kturtle
Depends: kdelibs3-ssl (>= %v-${KDERELNUM}) | kdelibs3 (>= %v-${KDERELNUM}), arts (>= ${KDEARTSVER}), xfonts-intl
BuildDepends: fink (>= 0.17.1-1), kdebase3-ssl-dev (>= %v-${KDERELNUM}) | kdebase3-dev (>= %v-${KDERELNUM}), kdelibs3-ssl-dev (>= %v-${KDERELNUM}) | kdelibs3-dev (>= %v-${KDERELNUM}), arts-dev (>= ${KDEARTSVER}), libxml2, libxslt, xfonts-intl
Maintainer: Benjamin Reed <kde-i18n-${normalized}\@fink.racoonfink.com>
PatchScript: perl -pi -e 's,doc/HTML,doc/kde,g' configure
CompileScript: (export HOME=/tmp; export KDEDIR=%p; sh configure %c; find . -name \\*.bz2 -exec touch {} \\;; make -j2)
InstallScript: <<
  make -j2 install DESTDIR=%d
  mkdir -p %i/share/doc/kde-installed-packages
  touch %i/share/doc/kde-installed-packages/kde-i18n-${normalized}
<<
License: GPL/LGPL
END
		print $contents if ($VERBOSE);
		my $infofile = "kde-i18n-${normalized}.info";
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
	my ($shortname) = $i18n =~ /koffice-i18n-([^\-]+)-${KOVERSION}.*.tar.(gz|bz2)/;
	if (exists $MAPPINGS{$shortname}) {
		chomp(my $md5 = `md5 /sw/src/$i18n`);
		$md5 =~ s/^.*\s*=\s*//;
		my $normalized = lc($MAPPINGS{$shortname});
		$normalized =~ s#[^a-zA-Z]+#-#g;
		$normalized =~ s#-*$##;
		my $filename = $i18n;
		$filename =~ s#${KOVERSION}#\%v#g;
		push(@kopackages, "koffice-i18n-${normalized}");
		my $contents = <<END;
Package: koffice-i18n-${normalized}
Source: mirror:kde:${KODIRECTORY}${filename}
SourceDirectory: koffice-i18n-${shortname}-%v
Description: KDE - KOffice language files for $MAPPINGS{$shortname}
DescDetail: Language files for the KDE office suite: $MAPPINGS{$shortname}
Source-MD5: $md5
Version: ${KOVERSION}
Revision: ${KOI18NRELNUM}
Replaces: kde-i18n-${normalized}
Depends: kdelibs3-ssl (>= ${KDEVERSION}-${KDERELNUM}) | kdelibs3 (>= ${KDEVERSION}-${KDERELNUM}), arts (>= ${KDEARTSVER}), xfonts-intl, koffice-base (>= ${KOVERSION}-${KORELNUM})
BuildDepends: fink (>= 0.17.1-1), kdebase3-ssl-dev (>= ${KDEVERSION}-${KDERELNUM}) | kdebase3-dev (>= ${KDEVERSION}-${KDERELNUM}), kdelibs3-ssl-dev (>= ${KDEVERSION}-${KDERELNUM}) | kdelibs3-dev (>= ${KDEVERSION}-${KDERELNUM}), arts-dev (>= ${KDEARTSVER}), koffice-dev (>= ${KOVERSION}-${KORELNUM}), libxml2, libxslt, xfonts-intl
Maintainer: Benjamin Reed <koffice-i18n-${normalized}\@fink.racoonfink.com>
PatchScript: perl -pi -e 's,doc/HTML,doc/kde,g' configure
CompileScript: (export HOME=/tmp; export KDEDIR=%p; sh configure %c; find . -name \\*.bz2 -exec touch {} \\;; make -j2)
InstallScript: <<
  make -j2 install DESTDIR=%d
  mkdir -p %i/share/doc/kde-installed-packages
  touch %i/share/doc/kde-installed-packages/koffice-i18n-${normalized}
<<
License: GPL/LGPL
END
		print $contents if ($VERBOSE);
		my $infofile = "koffice-i18n-${normalized}.info";
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
	my $packagelist = join(', ', map { $_ . " (>= ${KDEVERSION}-${KDEI18NRELNUM})" } @kdepackages);
	open(FILEOUT, ">bundle-kde-i18n.info") or die "can't write to bundle-kde-i18n.info: $!\n";
	print FILEOUT <<END;
Package: bundle-kde-i18n
Version: ${KDEVERSION}
Revision: ${KDEI18NRELNUM}
Type: bundle
Depends: $packagelist
Description: KDE - Convenience package: all language files
DescDetail: <<
This package doesn't install any files of itself, but instead makes
sure that all KDE language files get installed.
<<
Maintainer: Benjamin Reed <bundle-kde-i18n\@fink.racoonfink.com>
END
	close(FILEOUT);

	$packagelist = join(', ', map { $_ . " (>= ${KOVERSION}-${KOI18NRELNUM})" } @kopackages);
	open(FILEOUT, ">bundle-koffice-i18n.info") or die "can't write to bundle-koffice-i18n.info: $!\n";
	print FILEOUT <<END;
Package: bundle-koffice-i18n
Version: ${KOVERSION}
Revision: ${KOI18NRELNUM}
Type: bundle
Depends: $packagelist
Description: KDE - KOffice convenience package: all language files
DescDetail: <<
This package doesn't install any files of itself, but instead makes
sure that all KOffice language files get installed.
<<
Maintainer: Benjamin Reed <bundle-koffice-i18n\@fink.racoonfink.com>
END
	close(FILEOUT);
}
