#!/usr/bin/perl -w

=head1 NAME

mkpkg.pl - Create a Fink info file from a CPAN module

=head1 SYNOPSIS

mkpkg.pl [options] Some::Module ...

  Options:
    -m --maintainer=s   specify the maintainer
                        (e.g. -m "Joe Maintainer <joe@foo.com>")
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
versions of CPANPLUS.  CPANPLUS is not in Fink as of this writing.

yaml-pm must be installed.

file-slurp-pm must be installed.
 
=head1 CAVEATS

Does not do Depends, Recommends, BuildDepends, etc

Just guesses at DocFiles

License may not be right - confirm manually

Does not indicate crypto vs. main dependencies

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
            dir        => "/sw/fink/dists/unstable/main/finkinfo/libs/perlmods",
            maintainer => "Chris Dolan <chrisdolan\@users.sourceforge.net>",
            prereqs    => 0, # not finished
            bin        => 0, # make a %N-bin splitoff
            typepkg    => 0,
            perltypes  => "5.8.1",
            cpanhost   => undef, # base url for CPAN mirror, or use fink.conf
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
my %yml_licenses = (
                    # http://search.cpan.org/~kwilliams/Module-Build/lib/Module/Build.pm
                    perl => "Artistic/GPL",
                    gpl   => "GPL",
                    lgpl   => "LGPL",
                    bsd   => "BSD",
                    artistic   => "Artistic",
                    open_source  => "OSI-Approved",
                    unrestricted  => "Restrictive/Distributable",
                    restrictive => "Restrictive", 
                    );

my $cb = CPANPLUS::Backend->new();
$cb->configure_object->set_conf(verbose => $opts{verbose});
print "Started CPANPLUS\n";

if (!$opts{cpanhost} && -f "/sw/etc/fink.conf")
{
   my $conf = read_file("/sw/etc/fink.conf");
   if ($conf =~ /^Mirror-cpan: (.*)$/m)
   {
      $opts{cpanhost} = $1;
   }
}
if ($opts{cpanhost} && $opts{cpanhost} =~ m,^(\w+)://([\w\.\-]+)(/.*),)
{
   $cb->configure_object->set_conf("hosts", [{
      scheme => $1,
      host => $2,
      path => $3,
   }]);
}

my %origopts = (%opts);

foreach my $module (@ARGV)
{
   # reset in case they were changed on the prev loop
   %opts = (%origopts);

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

      my %libs = (
                  depends => {},
                  recommends => {},
                  conflicts => {},
                  builddepends => {},
                  buildconflicts => {},
                  );

      # Debugging: dump the module object to a file
      #use Data::Dumper;
      #write_file("/tmp/module", Dumper($mod));

      # Get list of files in the root of the distro.  Some of them
      # will be the DocFiles
      my @files = map({$_->[1]}
                      grep({-f $_->[0]}
                           map({[$mod->status->extract."/".$_,$_]} 
                               read_dir($mod->status->extract))));
      @files = grep !/^(
                        Build.PL |
                        Makefile(\.PL|) |
                        MANIFEST\.SKIP |
                        test\.pl |
                        .*\.(bat|xs|pm|pl)
                        )$/x, @files;

      ### Extract special info
      ### Select data in reverse order of preference: most trusted
      ### source comes last and overrides previous sources.

      # license code is 5th character in "DSLIP" code
      my $dslip = $mod->dslip;
      my $license_code = substr($dslip, 4, 1);
      my $license = $licenses{$license_code} || "";

      if (-f $mod->status->extract."/Makefile.PL")
      {
         my $makefile = read_file($mod->status->extract."/Makefile.PL");
         # Get ABSTRACT string from the MakeMaker command
         if ($makefile =~ /([\'\"]?)ABSTRACT\1 *(?:=>|,) *(?:\"([^\"]+)|\'([^\']+))/)
         {
            $mod->description($1);
         }
         # Check if there are any script outputs
         if ($makefile =~ /([\'\"]?)EXE_FILES\1 *(?:=>|,)/)
         {
            $opts{bin} = 1;
         }
      }
      if (-f $mod->status->extract."/META.yml")
      {
         require YAML;
         my $yaml = read_file($mod->status->extract."/META.yml");
         my $meta = YAML::Load($yaml);
         if (!$meta)
         {
            print "Failed to read META.yml\n";
         }
         else
         {
            if ($meta->{license} && $yml_licenses{$meta->{license}})
            {
               $license = $yml_licenses{$meta->{license}};
            }
            if ($meta->{abstract})
            {
               $mod->description($meta->{abstract});
            }
            my %libtrans = (
                            requires => "depends",
                            build_requires => "builddepends",
                            conflicts => "conflicts",
                            recommends => "recommends",
                            );
            foreach my $type (keys %libtrans)
            {
               if ($meta->{$type})
               {
                  foreach my $key (keys %{$meta->{$type}})
                  {
                     if ($key eq "perl")
                     {
                        print "$type Perl: ".$meta->{$type}->{$key}."\n";
                     }
                     else
                     {
                        &set_dep_pkg($cb, $key, $meta->{$type}, $libs{$libtrans{$type}});
                     }
                  }
               }
            }
         }
      }

      if ($opts{prereqs})
      {
         my $dist = $mod->dist(format => $mod->get_installer_type(),
                               target => TARGET_PREPARE);
         my $prereqs = $dist->_find_prereqs();
         for my $key (sort keys %$prereqs)
         {
            if ($key eq "perl")
            {
               print "prereq Perl: ".$prereqs->{$key}."\n";
            }
            else
            {
               &set_dep_pkg($cb, $key, $prereqs, $libs{depends});
               print "  Prereq: $key => $$prereqs{$key}\n";
            }
         }
      }

      if ($opts{typepkg})
      {
         $libs{depends}->{"perl\%type_pkg[perl]-core"} = 0;
      }

      # Trim trailing period, if any
      if ($mod->description)
      {
         my $desc = $mod->description;
         $desc =~ s/\.$//s;
         $mod->description($desc);
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
                  Depends => join(", ", sort keys %{$libs{depends}}),
                  BuildDepends => join(", ", sort keys %{$libs{builddepends}}),
                  Conflicts => join(", ", sort keys %{$libs{conflicts}}),
                  BuildConflicts => join(", ", sort keys %{$libs{buildconflicts}}),
                  Recommends => join(", ", sort keys %{$libs{recommends}}),
                  DocFiles => "@files",
                  License => $license,
                  Description => $mod->description,
                  Maintainer => $opts{maintainer},
                  Homepage => "http://search.cpan.org/dist/".$mod->package_name,
                  DescPackaging => "<<\n Found a bug?  Please check if it has already been reported:\n http://rt.cpan.org/NoAuth/Bugs.html?Dist=".$mod->package_name()."\n<<",
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

sub set_dep_pkg
{
   my $cb = shift;
   my $modname = shift;
   my $src = shift;
   my $dest = shift;

   my $mod = $cb->module_tree($modname);
   if ($mod)
   {
      $dest->{&fix_pkg($mod->package_name)} = $src->{$modname};
   }
   else
   {
      print "Can't find prereq module $modname\n";
   }
}

sub fix_pkg
{
   my $pkg = shift;

   $pkg = lc($pkg)."-pm";
   $pkg =~ s/libwww-perl-pm/libwww-pm/;
   if (-f "$opts{dir}/$pkg.info")
   {
      my $content = read_file("$opts{dir}/$pkg.info");
      if ($content =~ /^Package:.*\%type_pkg[perl]/m)
      {
         $opts{typepkg} = 1;
         $pkg .= "\%type_pkg[perl]";
      }
   }
   elsif (-f "$opts{dir}/${pkg}581.info")
   {
      $opts{typepkg} = 1;
      $pkg .= "\%type_pkg[perl]";
      $opts{perltypes} = "581";
   }
   else
   {
      print "$pkg is not yet packaged for Fink\n";
   }
   return $pkg;
}
