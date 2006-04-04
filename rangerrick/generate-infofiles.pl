#!/usr/bin/perl

use strict;

use lib '/sw/lib/perl5';
use lib '/Users/ranger/cvs.build/fink/perlmod';
use lib '/Users/ranger/cvs/fink/perlmod';

use Clone qw(clone);
use File::Basename;
use File::Find;
use File::Path;
use Cwd 'abs_path';
use Fink;
use Fink::PkgVersion;
use Fink::Services qw(&read_properties_var &pkglist2lol &lol2pkglist);
use Data::Dumper;

Fink->import;

my $path = abs_path(dirname($0));

my @files = @ARGV;
my %files;

my $translate = '(openexr|gst.*0.10.*|gstreamer|gst-plugins|kde|postgres|libpq|libpg|wv2|icecream|qt3|qca|kgpg|xfree86|xorg|\\/mono\\.|libgdiplus|monodevelop|cocoa-sharp|perlmods|libsmoke|fung-calc|.*-pm.info$|libagg|doxygen1.3|piklab|poppler-qt3|distcc|gtk-sharp|gecko-sharp|gtksourceview-sharp|ikvm|ekg|gconfmm2|gnomoradio|libmusicbrainz4|libtunepimp|^taglib|dbus|libmath|glibmm|gconfmm|gtkmm|libxml\\\+\\\+|qca|libxine|imlib|libcapsi|libwpd|libpostproc|ffmpeg|enblend|gemrb|apt|dpkg|ecj|monodoc|mono-tools|nant|boo\\.)';

my $package_lookup = {
	'10.3' => {
		'^libxine1$'           => 'libxine',
		'^libxine1-shlibs$'    => 'libxine-shlibs',
		'^fontconfig2-shlibs$' => undef,
		'^libicu32-dev$'       => undef,
	},
	'10.4-transitional' => {
		'^libicu31-dev$'       => undef,
		'^gcc3.1$'             => undef,
	},
	'10.4' => {
		'^libicu31-dev$'       => undef,
		'^gcc3.1$'             => undef,
		'^gcc3.3$'             => undef,
#		'^mjpegtools2-dev$'    => 'mjpegtools1.8-dev',
#		'^mjpetools2-shlibs$'  => 'mjpegtools1.8-shlibs',
	},
};

my $version_lookup = {
	'10.4' => {
		'^abiword$'                                 => [ '2.2.7',        '1003' ],
		'^advancemame$'                             => [ '0.84.0',       '1020' ],
		'^apache2.*$'                               => [ '2.0.55',       '1010' ],
		'^libapache2-mod-(actions|auth-anon|auth-dbm|auth-digest|bucketeer|cgid|expires|headers|info|isapi|mime-magic|proxy|proxy-connect|proxy-ftp|proxy-http|rewrite|speling|ssl|suexec|unique-id|usertrack|vhost-alias)$'                              => [ '2.0.55',       '1010' ],
		'^apr(-ssl)?(-common|-shlibs)?$'            => [ '0.9.7',        '1011' ],
		'^apt(-dev|-shlibs)?$'                      => [ '0.5.4',        '1052' ],
		'^aqbanking$'                               => [ '1.0.4',        '1beta.1000' ],
		'^aqhbci(-.*)?$'                            => [ '1.0.2',        '1beta.1000' ],
		'^aquaterm(-dev|-shlibs)?$'                 => [ '1.0.0',        '1002' ],
		'^aspell(-dev|-shlibs)?$'                   => [ '0.50.5',       '1002' ],
		'^autotrace(-bin|-shlibs)?$'                => [ '0.31.1',       '1014' ],
		'^boo$'                                     => [ '0.7.5.2013',   '1023' ],
		'^boost1.32-py..(-shlibs)?$'                => [ '1.32.0',       '1002' ],
		'^boost1.32.python(-shlibs)?$'              => [ '1.32.0',       '1011' ],
		'^ccp4(-.*)?$'                              => [ '5.99.5',       '1001' ],
		'^cdrdao$'                                  => [ '1.2.0',        '1010' ],
		'^cocoa-sharp$'                             => [ '0.9.1',        '1022' ],
		'^dasher(-.*)?$'                            => [ '3.2.18',       '1001' ],
		'^dbus(-shlibs|-dev)?$'                     => [ '0.60',         '1003' ],
		'^dbus(-qt3|-qt4)(-shlibs|-dev)?$'          => [ '0.60',         '1001' ],
		'^dialog$'                                  => [ '0.9b-20020814', '1024' ],
		'^db3(-bin|-doc|-shlibs)?$'                 => [ '3.3.11',       '1027' ],
		'^db4(-bin|-doc|-shlibs)?$'                 => [ '4.0.14',       '1026' ],
		'^db41(-ssl)?(-bin|-doc|-shlibs)?$'         => [ '4.1.25',       '1023' ],
		'^db42(-ssl)?(-bin|-doc|-java|-shlibs)?$'   => [ '4.2.52',       '1017' ],
		'^db43(-ssl)?(-bin|-doc|-java|-shlibs)?$'   => [ '4.3.29',       '1001' ],
		'^db44(-aes)?(-bin|-doc|-java|-shlibs)?$'   => [ '4.4.16',       '1001' ],
		'^dods$'                                    => [ '3.4.5',        '1005' ],
		'^dpkg$'                                    => [ '1.10.21',      '1217' ],
		'^ecj$'                                     => [ '3.1.2',        '1021' ],
		'^firefox(-dev|-shlibs)?$'                  => [ '1.0.7',        '1007' ],
		'^flac(-nox)?(-.*)?$'                       => [ '1.1.1',        '1011' ],
		'^fltk-x11(-shlibs)?$'                      => [ '1.1.6',        '11.1' ],
		'^gal21(-shlibs)?$'                         => [ '0.22',         '1014' ],
		'^gc(-shlibs)?$'                            => [ '6.4',          '1001' ],
		'^gconfmm2(-shlibs)?$'                      => [ '2.0.2',        '1022' ],
		'^gconfmm2.6(-dev|-shlibs)?$'               => [ '2.10.0',       '1002' ],
		'^gdal(-ssl)?(-dev|-doc|-grass|-shlibs)?$'  => [ '1.2.6',        '1005' ],
		'^gecko-sharp$'                             => [ '2.0',          '1029' ],
		'^gimp(-default|-dev|-shlibs)?$'            => [ '1.2.5',        '1003' ],
		'^glib2(-dev|-shlibs)?$'                    => [ '2.8.6',        '123'  ],
		'^glibmm2.4(-dev|-shlibs)?$'                => [ '2.6.1',        '1001' ],
		'^glut(-shlibs)?$'                          => [ '3.7',          '1025' ],
		'^gnuplot$'                                 => [ '4.0.0',        '1003' ],
		'^grads$'                                   => [ '1.9',          '1004' ],
		'^gtkmm2(-dev|-shlibs)?$'                   => [ '2.2.12',       '1002' ],
		'^gtkmm2.4(-dev|-shlibs)?$'                 => [ '2.6.4',        '1001' ],
		'^gtk-sharp$'                               => [ '1.0.10',       '1024' ],
		'^gtk-sharp(2|-monodoc)$'                   => [ '2.4.2',        '1022' ],
		'^gtksourceview-sharp$'                     => [ '2.0',          '1025' ],
		'^guile16(-dev|-libs|-shlibs)?$'            => [ '1.6.7',        '1010' ],
		'^gwenhywfar(-shlibs)?$'                    => [ '1.7.2',        '1002' ],
		'^hdf5(-bin|-shlibs)?$'                     => [ '1.6.5',        '1002' ],
		'^id3lib4(-dev|-doc|-shlibs)?$'             => [ '3.8.3',        '1014' ],
		'^ikvm$'                                    => [ '0.26.0.1',     '1021' ],
		'^imagemagick(-nox)?(-dev|-shlibs)?$'       => [ '6.1.8',        '1002' ],
		'^kaptain$'                                 => [ '0.72',         '1012' ],
		'^ktoblzcheck$'                             => [ '1.2',          '1003' ],
		'^ladspa(-dev)?$'                           => [ '1.12',         '1012' ],
		'^lammpi(-dev|-examples|-shlibs)?$'         => [ '7.0.6',        '1011' ],
		'^libcapsinetwork(-dev)?$'                  => [ '0.3.0',        '1001' ],
		'^libdap3(-shlibs)?$'                       => [ '3.5.2',        '1001' ],
		'^libemf(-shlibs|-bin)?$'                   => [ '1.0.2',        '1011' ],
		'^libgdiplus$'                              => [ '1.1.14',       '1021' ],
		'^libgeos2(-.*)?$'                          => [ '2.1.4',        '1001' ],
		'^libhttpd-persistent$'                     => [ '1.3',          '1010' ],
		'^libidl2(-shlibs)?$'                       => [ '0.8.5',        '1001' ],
		'^libmath..(-dev)?$'                        => [ '0.0.4',        '1001' ],
		'^libmp4v21(-dev|-shlibs)?$'                => [ '2.0.0',        '1013' ],
		'^libmusicbrainz4(-shlibs)?$'               => [ '2.1.1',        '1001' ],
		'^libnc-dap3(-shlibs)?$'                    => [ '3.5.2',        '1001' ],
		'^(libncurses5(-shlibs)?|ncurses)$'         => [ '5.4-20041023', '1006' ],
		'^libncursesw5(-shlibs)?$'                  => [ '5.4-20041023', '1001' ],
		'^libofx1(-shlibs)?$'                       => [ '0.7.0',        '1002' ],
		'^libogdi3(-bin|-shlibs)?$'                 => [ '3.1.5',        '1002' ],
		'^librep(-dev|-shlibs)?$'                   => [ '0.16.2',       '1011' ],
		'^librsync(-bin|-shlibs)?$'                 => [ '0.9.7',        '1001' ],
		'^libsablot(-dev|-shlibs)?$'                => [ '0.98',         '1024' ],
		'^libsidplay(-shlibs)?$'                    => [ '1.36.59',      '1001' ],
		'^libsigc..12(-shlibs)?$'                   => [ '1.2.5',        '1002' ],
		'^libsigc..2(-shlibs)?$'                    => [ '2.0.11',       '1003' ],
		'^libtunepimp2(-shlibs)?$'                  => [ '0.3.0',        '1001' ],
		'^libusb(-shlibs)?$'                        => [ '0.1.8',        '1015' ],
		'^libwpd-0.8(-shlibs)?$'                    => [ '0.8.2',        '1001' ],
		'^libwpd1(-shlibs)?$'                       => [ '0.7.2',        '1011' ],
		'^libxml..2(-shlibs)?$'                     => [ '2.10.0',       '1001' ],
		'^matplotlib-py..$'                         => [ '0.86.1',       '1002' ],
		'^mjpegtools2?(-dev|-shlibs)?$'             => [ '1.6.2',        '1003' ],
		'^mono(-dev|-shlibs)$',                     => [ '1.1.14',       '1021' ],
		'^mono-tools$',                             => [ '1.1.11',       '1022' ],
		'^monodevelop$'                             => [ '0.9',          '1023' ],
		'^monodoc$'                                 => [ '1.1.13',       '1022' ],
		'^mozilla(-.*)?$'                           => [ '1.7.5',        '1102' ],
		'^mysql(-dev|-shlibs)?$'                    => [ '3.23.58',      '1023' ],
		'^mysql12(-dev|-shlibs)?$'                  => [ '4.0.22',       '1012' ],
		'^mysql14(-dev|-shlibs)?$'                  => [ '4.1.10',       '1002' ],
		'^mysql15(-dev|-shlibs)?$'                  => [ '5.0.16',       '1001' ],
		'^nant$'                                    => [ '0.85',         '1032' ],
		'^ncurses-(dev|shlibs)$'                    => [ '5.3-20031018', '1501' ],
		'^netcdf(-bin|-shlibs)?$'                   => [ '3.6.0',        '1002' ],
		'^openexr(-dev)?$'                          => [ '1.2.2',        '31'   ],
		'^openhbci(-shlibs)?$'                      => [ '0.9.13',       '1012' ],
		'^openjade$'                                => [ '1.3.2',        '1028' ],
		'^pdcurses(-shlibs)?$'                      => [ '2.6',          '1013' ],
		'^pdflib(-shlibs)?$'                        => [ '5.0.3',        '1002' ],
		'^pdflib-py..$'                             => [ '5.0.3',        '1001' ],
		'^pilot-link9(-bin|-py.+|-shlibs)?$'        => [ '0.11.8',       '1035' ],
		'^postgresql-perl.*$'                       => [ '8.1.2',        '1022' ],
		'^postgresql-tcl.*$'                        => [ '8.1.2',        '1021' ],
		'^postgresql80(-.*)?$'                      => [ '8.0.6',        '1026' ],
		'^pstoedit(-bin|-shlibs)?$'                 => [ '3.40',         '1002' ],
		'^pygtk-py23$'                              => [ '0.6.9',        '1016' ],
		'^python23(-shlibs|-socket)?$'              => [ '1:2.3.5',      '1124' ],
		'^python23-nox(-shlibs|-socket)?$'          => [ '1:2.3.4',      '1104' ],
		'^python23-socket-ssl$'                     => [ '1:2.3.5',      '1101' ],
		'^python24(-shlibs|-socket)?$'              => [ '1:2.4.2',      '1004' ],
		'^python24-socket-ssl$'                     => [ '2.4.2',        '1101' ],
		'^qca(-shlibs)?$'                           => [ '1.0',          '1023' ],
		'^qcad$'                                    => [ '2.0.1.3-1',    '1002' ],
		'^qt3(-.+)?$'                               => [ '3.3.6',        '1022' ],
		'^qt3mac(-mysql|-postgresql)?$'             => [ '3.3.5',        '1001' ],
		'^r-base$'                                  => [ '2.1.1',        '1001' ],
		'^readline(-shlibs)?$'                      => [ '4.3',          '1028' ],
		'^readline5(-shlibs)?$'                     => [ '5.0',          '1004' ],
		'^rep-gtk$'                                 => [ '0.18',         '1013' ],
		'^reportlab-.*$'                            => [ '1.20',         '1011' ],
		'^sane-backends(-dev|-shlibs)?$'            => [ '1.0.15',       '1004' ],
		'^sdl(-shlibs)?$'                           => [ '1.2.9',        '1001' ],
		'^sdl-mixer(-shlibs)?$'                     => [ '1.2.6',        '1012' ],
		'^smpeg(-shlibs)?$'                         => [ '0.4.4',        '1025' ],
		'^svn(-.*)?$'                               => [ '1.2.3',        '1012' ],
		'^swig(-shlibs)?$'                          => [ '1.3.20',       '1012' ],
		'^taglib(-shlibs)?$'                        => [ '1.4',          '1001' ],
		'^unixodbc2(-.*)?$'                         => [ '2.2.11',       '1010' ],
		'^w3m(-ssl)?$'                              => [ '0.5.1',        '1003' ],
		'^wxmac(-shlibs)?$'                         => [ '2.6.1',        '1001' ],
		'^xmlto$'                                   => [ '0.0.18',       '1005' ],
		'^xpdf$'                                    => [ '3.01',         '1002' ],
		'^yelp-viewer(-firefox|-mozilla)$'          => [ '2.12.2',       '1001' ],
		'^zope$'                                    => [ '2.6.3',        '1102' ],
		'^macosx$'                                  => [ '10.4.3',       '1'    ],
	},
	'10.4-transitional' => {
		'^boo$'                                     => [ '0.7.5.2013',   '23'   ],
		'^cocoa-sharp$'                             => [ '0.9.1',        '22'   ],
		'^ecj$'                                     => [ '3.1.2',        '21'   ],
		'^gecko-sharp$'                             => [ '2.0',          '29'   ],
		'^gtk-sharp$'                               => [ '1.0.10',       '24'   ],
		'^gtk-sharp(2|-monodoc)$'                   => [ '2.4.2',        '22'   ],
		'^gtksourceview-sharp$'                     => [ '2.0',          '25'   ],
		'^ikvm$'                                    => [ '0.26.0.1',     '21'   ],
		'^libgdiplus$'                              => [ '1.1.14',       '21'   ],
		'^libusb(-shlibs)?$'                        => [ '0.1.8',        '15'   ],
		'^mjpegtools2?(-dev|-shlibs)?$'             => [ '1.6.2',        '3'    ],
		'^mono(-dev|-shlibs)$',                     => [ '1.1.14',       '21'   ],
		'^mono-tools$',                             => [ '1.1.11',       '22'   ],
		'^monodevelop$'                             => [ '0.9',          '23'   ],
		'^monodoc$'                                 => [ '1.1.13',       '22'   ],
		'^nant$'                                    => [ '0.85',         '32'   ],
		'^qt3(-.+)?$'                               => [ '3.3.6',        '22'   ],
		'^sane-backends(-dev|-shlibs)?$'            => [ '1.0.15',       '4'    ],
		'^macosx$'                                  => [ '10.4.3',       '1'    ],
	},
	'10.3' => {
		'^boo$'                                     => [ '0.7.5.2013',   '13'   ],
		'^cocoa-sharp$'                             => [ '0.9.1',        '12'   ],
		'^ecj$'                                     => [ '3.1.2',        '11'   ],
		'^gecko-sharp$'                             => [ '2.0',          '19'   ],
		'^gtk-sharp$'                               => [ '1.0.10',       '14'   ],
		'^gtk-sharp(2|-monodoc)$'                   => [ '2.4.2',        '12'   ],
		'^gtksourceview-sharp$'                     => [ '2.0',          '15'   ],
		'^ikvm$'                                    => [ '0.26.0.1',     '11'   ],
		'^libgdiplus$'                              => [ '1.1.14',       '11'   ],
		'^libusb(-shlibs)?$'                        => [ '0.1.8',        '15'   ],
		'^mjpegtools2?(-dev|-shlibs)?$'             => [ '1.6.2',        '3'    ],
		'^mono(-dev|-shlibs)$',                     => [ '1.1.14',       '11'   ],
		'^mono-tools$',                             => [ '1.1.11',       '12'   ],
		'^monodevelop$'                             => [ '0.9',          '13'   ],
		'^monodoc$'                                 => [ '1.1.13',       '12'   ],
		'^nant$'                                    => [ '0.85',         '22'   ],
		'^qt3(-.+)?$'                               => [ '3.3.6',        '12'   ],
		'^sane-backends(-dev|-shlibs)?$'            => [ '1.0.15',       '4'    ],
		'^macosx$'                                  => [ '10.3.0',       '1'    ],
	},
	'all' => {
		'^arts(-dev|-shlibs)?$'                     => [ undef,          '+'    ],
		'^glib2(-dev|-shlibs)?$'                    => [ '2.8.6',        '122'  ],
		'^gnokii2(-dev|-shlibs)?$'                  => [ '0.6.12',       '1'    ],
		'^gtk-doc$'                                 => [ '1.5',          '1'    ],
		'^kde\S+(i18n|3|3-unified)(-dev|-shlibs)?$' => [ undef,          '+'    ],
		'^libcdparanoia0-dev$'                      => [ '3a9.8',        '11'   ],
#		'^qt3(-.+)?$'                               => [ undef,          '+'    ],
		'^postgresql\S+$'                           => [ undef,          '+'    ],
	},
};

my @KEYS = (
	'Package', 'Version', 'Revision', 'Epoch', 'Architecture', 'Description', 'Type',
		'License', 'Maintainer', '<CR>',
	'Depends', 'BuildDepends', 'BuildConflicts', 'Provides', 'Conflicts', 'Replaces',
		'Recommends', 'Suggests', 'Enhances', 'Pre-Depends', 'Essential',
		'BuildDependsOnly', 'GCC', '<CR>',
	'CustomMirror', 'Source', 'Source<N>', 'SourceDirectory', 'Source<N>Directory',
		'NoSourceDirectory', 'SourceExtractDir', 'Source<N>ExtractDir', 'SourceRename',
		'Source<N>Rename', 'Source-MD5', 'Source<N>-MD5', 'TarFilesRename',
		'Tar<N>FilesRename', 'UpdateConfigGuess', 'UpdateConfigGuessInDirs',
		'UpdateLibtool', 'UpdateLibtoolInDirs', 'UpdatePoMakefile', 'Patch',
		'PatchScript', '<CR>',
	'Set<S>', 'NoSet<S>', 'ConfigureParams', 'CompileScript', '<CR>',
	'UpdatePOD', 'InstallScript', 'NoPerlTests', 'JarFiles', 'DocFiles',
		'RuntimeVars', 'SplitOff', 'SplitOff<N>', 'Files', 'Shlibs', '<CR>',
	'PreInstScript', 'PostInstScript', 'PreRmScript', 'PostRmScript', 'ConfFiles',
		'InfoDocs', 'DaemonicFile', 'DaemonicName', '<CR>',
	'Homepage', 'DescDetail', 'DescUsage', 'DescPackaging', 'DescPort',
);

my @TREES = qw( 10.3 10.4-transitional 10.4 );

my $APPEND_USAGE = '^arts|kde\S+3|kdevelop|koffice|bundle-kde|kgpg';

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
	next unless ($file =~ /$translate/);
	next if ($file =~ /notready/);

	my $contents;
	if (open (FILEIN, $file)) {
		local $/ = undef;
		$contents = <FILEIN>;
		close (FILEIN);
	} else {
		warn "unable to read from $file: $!\n";
		next;
	}

	print $file, "\n";
	if ($file =~ /\.info$/) {
		my $properties = info_hash_from_var(
			$file,
			$contents,
			{ case_sensitive => 1 },
		);

#		print Dumper($properties), "\n";

		for my $tree (@TREES) {
			next if ($file =~ /postgresql73/ and $tree ne "10.3");

			my $treeproperties = clone($properties);
			$treeproperties->{'Tree'} = $tree;

			$treeproperties = transform_fields($treeproperties, clone($treeproperties));

			my $todir = $dir;
			$todir =~ s#/common/#/${tree}/#;
			mkdir_p($todir) unless (-d $todir);

			my $info = serialize_to_info($treeproperties) . "\n";
			if (open (FILEOUT, '>' . $todir . '/' . $filename)) {
				print FILEOUT $info;
				close (FILEOUT);
			}
		}

	} elsif ($file =~ /\.patch$/) {
		for my $tree (@TREES) {
			next if ($file =~ /postgresql73/ and $tree ne "10.3");

			my $todir = $dir;
			$todir =~ s#/common/#/${tree}/#;
			mkdir_p($todir) unless (-d $todir);

			if (open (FILEOUT, '>' . $todir . '/' . $filename)) {
				print FILEOUT transform_patch($tree, $contents);
				close (FILEOUT);
			}
		}

	} else {
		warn "unhandled file: $file\n";
	}

}

sub transform_fields {
	my $packagehash = shift;
	my $properties  = shift;

	for my $field (keys %$properties) {
		my $lcfield = lc($field);
		no strict qw(refs);
		if ($field =~ /^splitoff/i) {
			$properties->{$field} = transform_fields($packagehash, $properties->{$field});
		} elsif (defined &{"transform_$lcfield"}) {
			$properties->{$field} = &{"transform_$lcfield"}($packagehash, $properties->{$field});
		} else {
			#warn "unhandled field: $field\n";
		}
	}

	if (exists $properties->{'Type'} and $properties->{'Type'} =~ /^perl/ and $properties->{'Tree'} ge "10.4") {
		if (exists $properties->{'Architecture'}) {
			warn "type = perl, but architecture is already set!\n";
		} else {
			$properties->{'Architecture'} = '(%type_pkg[perl] = 581) powerpc, (%type_pkg[perl] = 584) powerpc';
		}
	}

	if ($packagehash->{'Package'} =~ /$APPEND_USAGE/i) {
		$properties->{'DescUsage'} = transform_descusage($packagehash, $properties->{'DescUsage'});
	}

	return $properties;
}

sub print_indent {
	my $field_name = shift;
	my $text       = shift;
	my $indent     = shift || 0;

	$text =~ s/^\n+//gsi;
	$text =~ s/\n+$//gsi;

	my $return = "";

	if ($text =~ /\n/) {
		$return .= "\t" x $indent . $field_name . ": <<\n";
		if ($field_name =~ /^(files|conffiles|custommirror|patchscript|shlibs)$/i) {
			for my $line (split(/\n/, $text)) {
				$line =~ s/^\s+//;
				$return .= "\t" x ($indent + 1) . $line . "\n";
			}
		} else {
			$return .= $text . "\n";
		}
		$return .= "\t" x $indent . "<<\n";
	} else {
		$return .= "\t" x $indent . $field_name . ": " . $text . "\n";
	}

	return $return;
}

sub serialize_to_info {
	my $package = clone(shift);
	my $indent  = shift || 0;

	#print Dumper($package), "\n";
	my $output = "";

	delete $package->{'Tree'};
	my $infolevel = int($package->{'InfoLevel'});
	delete $package->{'InfoLevel'};

	$output .= "Info${infolevel}: <<\n" if ($infolevel >= 2 and not $indent);

	for my $key (@KEYS) {
		if ($key eq "<CR>") {
			$output .= "\n" unless ($output =~ /\n\n$/gs or $indent);
		} elsif ($key =~ /<N>/) {
			my $regex = $key;
			$regex =~ s/<N>/\\d\+/gs;
			for my $field (sort keys %$package) {
				if ($field =~ /^\s*${regex}\s*$/gsi) {
					if (ref $package->{$field}) {
						$output .= print_indent($field, serialize_to_info($package->{$field}, $indent + 1), $indent);
					} else {
						$output .= print_indent($field, $package->{$field}, $indent);
					}
					delete $package->{$field};
					#warn "$key matched $field (/^$regex\$/i\n";
				} else {
					#warn "$key did not match $field (/^$regex\$/i\n";
				}
			}
		} elsif ($key =~ /<S>/) {
			my $regex = $key;
			$regex =~ s/<S>/\.\+/gs;
			for my $field (sort keys %$package) {
				if ($field =~ /^\s*${regex}\s*$/gsi) {
					if (ref $package->{$field}) {
						$output .= print_indent($field, serialize_to_info($package->{$field}, $indent + 1), $indent);
					} else {
						$output .= print_indent($field, $package->{$field}, $indent);
					}
					delete $package->{$field};
					#warn "$key matched $field (/^$regex\$/i\n";
				} else {
					#warn "$key did not match $field (/^$regex\$/i\n";
				}
			}
		} else {
			for my $field (keys %$package) {
				if ($field =~ /^\s*${key}\s*$/gsi) {
					if (ref $package->{$field}) {
						$output .= print_indent($key, serialize_to_info($package->{$field}, $indent + 1), $indent);
					} else {
						$output .= print_indent($key, $package->{$field}, $indent);
					}
					delete $package->{$field};
				}
			}
		}
	}

	for my $key (sort keys %$package) {
		die "ERROR: '$key' is missing from \@KEYS!\n";
	}

	$output =~ s/\n\n+/\n\n/gsi;
	$output .= "<<\n" if ($infolevel >= 2 and not $indent);

	return $output;
}

sub prettify_field_name {
	my $field = shift;

	for my $key (@KEYS) {
		if ($key =~ /<N>/) {
			my $regex = $key;
			$regex =~ s/<N>/\(\\d\+\)/gs;
			if (my ($number) = $field =~ /^${regex}$/gsi) {
				my $field_name = $key;
				$field_name =~ s/<N>/$number/gsi;
				return $field_name;
			}
		} elsif (my ($set, $var) = $field =~ /^(NoSet|Set)(.*)$/i) {
			if ($set =~ /^no/i) {
				return "NoSet" . uc($var);
			} else {
				return "Set" . uc($var);
			}
		} elsif ($key =~ /<S>/i) {
			my $regex = $key;
			$regex =~ s/<S>/\(\.\+\)/gsi;
			if (my ($string) = $field =~ /^${regex}$/i) {
				my $field_name = $key;
				$field_name =~ s/<S>/$string/gsi;
				return $field_name;
			}
		} elsif ($field =~ /^\s*${key}\s*$/gsi) {
			# warn "prettify: $key =~ /^${field}\$/gsi matched\n";
			return $key;
		} else {
			# warn "prettify: $key =~ /^${field}\$/gsi did not match\n";
		}
	}
	warn "prettify: no match for '$field'\n";
	return $field;
}

sub transform_patch {
	my $tree = shift;
	my $text = shift;

	if ($tree eq "10.4") {
		$text =~ s/g(cc|\+\+)-3\.3/g$1-4.0/gi;
	}

	$text =~ s/(^|[\r\n]+)diff -uN[^\r\n]*//gs;

	return $text;
}

sub transform_descusage {
	my $packagehash = shift;
	my $descusage   = shift;

	if ($packagehash->{'Package'} =~ /$APPEND_USAGE/i) {
		if (open (FILEIN, $path . '/kdedesc.txt')) {
			local $/ = undef;
			if ($descusage !~ /^[\s\n]*$/gsi) {
				warn "descusage is not empty, overwriting:\n$descusage\n";
			}
			$descusage = <FILEIN>;
			close (FILEIN);
		} else {
			warn "unable to open kdedesc.txt: $!\n";
		}
	}

	return $descusage;
}

sub transform_files {
	my $tree  = shift->{'Tree'};
	my $files = shift;

	my @newlines;

	for my $line (split(/\r?\n/, $files)) {
		if ($tree eq "10.3") {
			next if ($line =~ /libkfontinst/i);
		}
		push(@newlines, $line);
	}

	return join("\n", @newlines);
}

sub transform_shlibs {
	my $tree   = shift->{'Tree'};
	my $shlibs = shift;
	my @newlines;

	for my $line (split(/\r?\n/, $shlibs)) {
		if ($tree eq "10.3") {
			next if ($line =~ /libkfontinst/i);
		}

		# whoo!  crazy lexing!
		my $newline;
		while ($line =~ /\G(.+?\(\S+\s+\S+\-)([^\-]+)\)/gsi) {
			my ($rest, $revision) = ($1, $2);
			$newline .= $rest . transform_revision( $tree, $revision ) . ')';
		}
		$line =~ /\G\(.*$/;
		$newline .= $1;

		push(@newlines, $line);
	}

	return join("\n", @newlines);
}

sub transform_configureparams {
	my $tree   = shift->{'Tree'};
	my $params = shift;

	if ($tree eq '10.4') {
		$params =~ s/--disable-java//gs;
	}

	return $params;
}

sub transform_setcxx {
	transform_setcc(@_);
}

sub transform_setcc {
	my $tree  = shift->{'Tree'};
	my $setcc = shift;

	if ($tree eq '10.4') {
		$setcc =~ s/3\.3/4.0/gs;
	}

	return $setcc;
}

sub transform_compilescript {
	my $tree          = shift->{'Tree'};
	my $compilescript = shift;

	if ($tree eq '10.4') {
		# I really don't like having these hardcoded here, need to figure out a way to
		# make it more configurable
		$compilescript =~ s/(gcc|g\+\+)-3.3/$1/gs;
		$compilescript =~ s/USE_EXCEPTIONS=\"[^\"]+\"//gs;
	}

	return $compilescript;
}

sub transform_gcc {
	my $tree = shift->{'Tree'};
	my $gcc  = shift;

	if ($tree eq "10.4") {
		$gcc = "4.0";
	}

	return $gcc;
}

sub transform_type {
	my $tree = shift->{'Tree'};
	my $type = shift;
	if ($type =~ /^perl\s*\(0\)/i) {
		my @versions = qw(5.6.0 5.6.1 5.8.0 5.8.1 5.8.4 5.8.5 5.8.6);
		if ($tree =~ /^10.3/) {
			@versions = qw(5.6.0 5.8.0 5.8.1 5.8.4 5.8.6);
		} elsif ($tree =~ /^10.4/) {
			@versions = qw(5.8.1 5.8.4 5.8.6);
		}
		$type = "perl(@versions)";
	} elsif ($type =~ /^python\s*\(0\)/i) {
		my @versions = qw(2.1 2.2 2.3 2.4);
		if ($tree =~ /^10.3/) {
			@versions = qw(2.2 2.3 2.4);
		} elsif ($tree =~ /^10.4/) {
			@versions = qw(2.3 2.4);
		}
		$type = "python(@versions)";
	}

	return $type;
}

sub transform_enhances {
	return transform_depends(@_);
}

sub transform_recommends {
	return transform_depends(@_);
}

sub transform_suggests {
	return transform_depends(@_);
}

sub transform_runtimedepends {
	return transform_depends(@_);
}

sub transform_builddepends {
	return transform_depends(@_);
}

sub transform_depends {
	my $packagehash = shift;
	my $depends     = pkglist2lol(shift);
	my @newdepends;

	for my $dep (@$depends) {
		my @newdep;
		for my $pkg (@$dep) {
			my $newdep = transform_dependency($packagehash->{'Tree'}, $pkg);
			push(@newdep, $newdep) if (defined $newdep);
		}
		push(@newdepends, \@newdep);
	}

	return lol2pkglist(\@newdepends);
}

sub transform_dependency {
	my $tree     = shift;
	my $dep_spec = shift;
	my $delete   = 0;

	my ($prefix, $package, $comparator, $version, $revision);
	if ($dep_spec =~ s/^\s*\(([^\)]+)\)\s+//) {
		$prefix = $1;
	}
	if (($package, $comparator, $version, $revision) = $dep_spec =~ /^(\S+)\s+\((\S+)\s+(\S+)\-(\S+)\)$/) {
		#print "transform_dependency[$dep_spec]: $package matched long-form dep\n";
	} elsif (($package) = $dep_spec =~ /^(\S+)$/) {
		#print "transform_dependency[$dep_spec]: $package matched short-form dep\n";
	} elsif (($package, $comparator, $version) = $dep_spec =~ /^(\S+)\s+\((\S+)\s+([^\-\s]+)\)$/) {
		#print "transform_dependency[$dep_spec]: $package matched incorrect dep\n";
		$revision = 0;
	} else {
		warn "transform_dependency[$dep_spec]: unhandled dependency specification\n";
	}

	my $matched = 0;
	for my $tree_iterator ($tree, 'all') {
		last if ($matched);
		if (exists $package_lookup->{$tree_iterator}) {
			for my $key (keys %{$package_lookup->{$tree_iterator}}) {
				my $replace = $package_lookup->{$tree_iterator}->{$key};
				if ($package =~ /$key/i) {
					if (not defined $replace) {
						$delete++;
					} else {
						$package =~ s/$key/$replace/gsi;
					}
				}
			}
		}
		if (exists $version_lookup->{$tree_iterator}) {
			#print "checking in $tree_iterator\n";
	
			for my $key (keys %{$version_lookup->{$tree_iterator}}) {
				if ($package =~ /$key/i) {
					#print "transform_dependency[$dep_spec]: $package matches $key\n";
					my ($newversion, $newrevision) = @{$version_lookup->{$tree_iterator}->{$key}};
					if (defined $version and defined $revision and $revision ne '%r' and $newrevision eq '+') {
						$revision = transform_revision( $tree, $revision );
					} elsif (defined $newversion and defined $newrevision and $revision ne '%r') {
						$version  = $newversion;
						$revision = $newrevision;
					} else {
						if ((not defined $version and not defined $revision) or ($version eq '%v' and $revision eq '%r')) {
							# it's OK to do nothing here
						} else {
							warn "transform_dependency[$dep_spec]: not sure how to handle ($newversion, $newrevision) when version = $version and revision = $revision\n";
						}
					}
					$matched++;
					last;
				} else {
					#print "transform_dependency[$dep_spec]: $package does not match $key\n";
				}
			}
		}
	}

	if (defined $package and defined $version and defined $revision) {
		$comparator = '>=' unless (defined $comparator);
		$dep_spec = $package . ' (' . $comparator . ' ' . $version . '-' . $revision . ')';
		$dep_spec = '(' . $prefix . ') ' . $dep_spec if (defined $prefix);
	} elsif (defined $package) {
		$dep_spec = $package;
		$dep_spec = '(' . $prefix . ') ' . $dep_spec if (defined $prefix);
	}

	#print "transform_dependency: returning $dep_spec\n";

	return undef if ($delete);
	return $dep_spec;
}

sub transform_version {
	my $packagehash = shift;
	my $version     = shift;
	return $version;
}

sub transform_revision {
	my $tree     = shift;
	my $revision = shift;
	$tree = $tree->{'Tree'} if (ref $tree eq "HASH");

	if ($tree eq '10.3') {
		$revision = revision_add($revision, 10);
	} elsif ($tree eq '10.4-transitional') {
		$revision = revision_add($revision, 20);
	} elsif ($tree eq '10.4') {
		$revision = revision_add($revision, 1020);
	} else {
		warn "unhandled tree '$tree'\n";
	}
	return $revision;
}

sub revision_add {
	my $revision = shift;
	my $amount   = shift;

	if (my ($pre, $post) = $revision =~ /^(.*\.)(\d+)$/) {
		$post += $amount;
		$revision = $pre . $post;
	} else {
		$revision += $amount;
	}
	return $revision;
}

sub info_hash_from_var {
	my $filename = shift;
	my $var      = shift;
	my $options  = shift;
	my $infolevel = 0;

	my $properties = read_properties_var(
		$filename,
		$var,
		$options,
	);
	($properties, $infolevel) = Fink::PkgVersion->handle_infon_block($properties, $filename);

	my $return;

	for my $key (keys %$properties) {
		my $newkey = prettify_field_name($key);
		#print "$key = $newkey\n";
		if ($key =~ /^splitoff/i) {
			$return->{$newkey} = info_hash_from_var(
				$filename . ' (' . $key . ')',
				$properties->{$key},
				{ remove_space => 1, %$options },
			);
		} else {
			$return->{$newkey} = $properties->{$key};
		}
	}

	$return->{'InfoLevel'} = $infolevel;

	return $return;
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
