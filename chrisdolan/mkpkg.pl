#!/usr/bin/perl -w

=head1 NAME

mkpkg.pl - Create a Fink info file from a CPAN module

=head1 SYNOPSIS

mkpkg.pl [options] Some::Module

  Options:
    -m --maintainer=s   specify the maintainer
                        (e.g. -m "Joe Maintainer E<lt>joe@foo.comE<gt>")
    -p --prereqs        show prereq info (not yet finished)
    -f --force          force overwrite of .info file
    -t --typepkg        use %type_pkg[perl] variants
    -b --bin            force a %N-bin splitoff
    -v --verbose        print the internal representation of the PDF
    -h --help           verbose help message
    -V --version        print version

If you specify more than one module, they will be processed sequentially.

=head1 DESCRIPTION

=head1 REQUIREMENTS

CPANPLUS 0.051 must be installed.  This is untested with other
versions of CPANPLUS.

file-slurp-pm.info must be installed.
 
=head1 CAVEATS

Does not do Depends, Recommends, BuildDepends, etc

Does not do variants or SplitOffs

Just guesses at DocFiles

License may not be right - confirm manually

Does not indicate crypto or main dependencies

=head1 LICENSE

This program can be distributed under the same terms as Fink.

=head1 AUTHOR

Chris Dolan <chrisdolan@users.sourceforge.net>

=cut

use strict;
use Getopt::Long;
use Pod::Usage;
use CPANPLUS::Backend;
use CPANPLUS::Internals::Constants;
use File::Slurp;
use Carp;
$SIG{__WARN__} = $SIG{__DIE__} = \&Carp::confess;

my $VERSION = "1.00";
my %opts = (
            verbose    => 0,
            help       => 0,
            version    => 0,
            force      => 0,
            dir        => "/sw/fink/dists/local/main/finkinfo/libs/perlmods",
            maintainer => "Chris Dolan <chrisdolan\@users.sourceforge.net>",
            prereqs    => 0, # not finished
            bin        => 0, # make a %N-bin splitoff
            typepkg    => 0,
            perltypes  => "5.8.0 5.8.1 5.8.4",
            );

Getopt::Long::Configure("bundling");
GetOptions("v|verbose"  => \$opts{verbose},
           "h|help"     => \$opts{help},
           "V|version"  => \$opts{version},
           "f|force"    => \$opts{force},
           "m|maintainer=s" => \$opts{maintainer},
           "p|prereqs"  => \$opts{prereqs},
           "t|typepkg"  => \$opts{typepkg},
           "b|bin"      => \$opts{bin},
           ) or pod2usage(1);
pod2usage(-exitstatus => 0, -verbose => 2) if ($opts{help});
print("$0 v$VERSION\n"),exit(0) if ($opts{version});

if (@ARGV < 1)
{
   pod2usage(1);
}

# This is a translation from CPAN "dslip" codes to Fink license words
my %licenses = (
                p   => "Artistic/GPL",
                g   => "GPL",
                l   => "LGPL",
                b   => "BSD",
                a   => "Artistic",
                o   => "Restrictive/Distributable",
                );

my $cb = CPANPLUS::Backend->new();
print "Started CPANPLUS\n";

foreach my $module (@ARGV)
{
   print "Search for $module\n";
   my $mod = $cb->module_tree($module);
   if ($mod)
   {
      print "Found\n";

      my $pkg = lc($mod->package_name)."-pm";
      my $file = "$opts{dir}/$pkg.info";
      if (-f $file && !$opts{force})
      {
         print "info package already exists\n";
         print "$file\n";
         next;
      }

      if ($opts{verbose})
      {
         my $details = $mod->details;
         for my $key (keys %$details)
         {
            print "$key: $$details{$key}\n";
         }
      }

      if (!$mod->status->fetch)
      {
         print "Fetch module\n";
         $mod->fetch;
      }
      if (!$mod->status->extract)
      {
         print "Extract module\n";
         $mod->extract;
      }
      print "Extracted to ".$mod->status->extract."\n";

      if ($opts{prereqs})
      {
         my $dist = $mod->dist(format => $mod->get_installer_type(),
                               target => TARGET_PREPARE);
         my $prereqs = $dist->_find_prereqs();
         for my $key (sort keys %$prereqs)
         {
            print "  Prereq: $key => $$prereqs{$key}\n";
         }
      }

      # Debugging: dump the module object to a file
      #use Data::Dumper;
      #write_file("/tmp/module", Dumper($mod));

      # license code is 5th character in "DSLIP" code
      my $dslip = $mod->dslip;
      my $license_code = substr($dslip, 4, 1);
      my $license = $licenses{$license_code} || "";

      # Get list of files in the root of the distro.  Some of them
      # will be the DocFiles
      my @files = map({$_->[1]}
                      grep({-f $_->[0]}
                           map({[$mod->status->extract."/".$_,$_]} 
                               read_dir($mod->status->extract))));
      @files = grep !/^(Makefile(\.PL|)|MANIFEST\.SKIP|.*\.bat|test\.pl)$/, @files;

      if (-f $mod->status->extract."/Makefile.PL")
      {
         my $makefile = read_file($mod->status->extract."/Makefile.PL");
         # Get ABSTRACT string from the MakeMaker command
         if ($makefile =~ /ABSTRACT *(?:=>|,) *(?:\"([^\"]+)|\'([^\']+))/)
         {
            $mod->description($1);
         }
         # Check if there are any script outputs
         if ($makefile =~ /EXE_FILES *(?:=>|,)/)
         {
            $opts{bin} = 1;
         }
      }

      # Prepare the .info fields.  Note that we use "_" instead of "-"
      # in field names to keep perl happy.
      my @data = (
                  Package => $pkg.($opts{typepkg} ? "%type_pkg[perl]" : ""),
                  Version => $mod->package_version,
                  Revision => "1",
                  Source => ("mirror:cpan:" . $mod->path . "/" . 
                             $mod->package_name . "-%v." . 
                             $mod->package_extension),
                  Source_MD5 => $mod->status->checksum_value,
                  Type => ($opts{typepkg} ? 
                           "perl ($opts{perltypes})" : "perl"),
                  UpdatePOD => "true",
                  Depends => "",
                  DocFiles => "@files",
                  License => $license,
                  Description => $mod->description,
                  Maintainer => $opts{maintainer},
                  Homepage => "http://search.cpan.org/dist/".$mod->package_name,
                  );

      # Write the .info file
      my $splitoffs = 0;
      my $output = "";
      my %data;
      for (my $i=0; $i<@data; $i+=2)
      {
         my $label = $data[$i];
         my $value = $data[$i+1];
         if (!defined $value)
         {
            print "Undef field '$label'\n";
            $value = "";
         }
         $data{$label} = $value;
         $label =~ s/_/-/g;
         $output .= "$label: $value\n";
      }
      my $manconflict = join(", ", map("%{Ni}$_-man", split(/ +/, $opts{perltypes})));
      (my $binconflict = $manconflict) =~ s/-man/-bin/g;
      if ($opts{bin})
      {
         my $splitnum = ++$splitoffs == 1 ? "" : $splitoffs;
         if ($opts{typepkg})
         {
            $output .= <<"EOF";
Splitoff$splitnum: <<
 Package: %N-bin
 Depends: %N (= %v-%r)
 Files: bin
 Conflicts: $binconflict
 Replaces: $binconflict
 DocFiles: $data{DocFiles}
<<
EOF
         }
         else
         {
            $output .= <<"EOF";
Splitoff$splitnum: <<
 Package: %N-bin
 Depends: %N (= %v-%r)
 Files: bin share/man/man1
 DocFiles: $data{DocFiles}
<<
EOF
         }
      }
      if ($opts{typepkg})
      {
         my $splitnum = ++$splitoffs == 1 ? "" : $splitoffs;
         $output .= <<"EOF";
Splitoff$splitnum: <<
 Package: %N-man
 Depends: %N (= %v-%r)
 Files: share/man
 Conflicts: $manconflict
 Replaces: $manconflict
 DocFiles: $data{DocFiles}
<<
EOF
         $output = "Info2: <<\n$output<<\n";
      }
      write_file($file, $output);
      print "Wrote file $file\n";
   }
   else
   {
      print "Not found\n";
   }
}
