#!/usr/bin/perl -w

=head1 NAME

mkpkg.pl - Create a Fink info file from a CPAN module

=head1 SYNOPSIS

mkpkg.pl [options] Some::Module ...

  Options:
    -m --maintainer=s   specify the maintainer.  This is a required parameter
                          (e.g. -m "Joe Maintainer <joe@foo.com>")
    -P --prereqs        show prereq info (not yet finished)
    -t --typepkg        force %type_pkg[perl] variants
    -b --bin            force a %N-bin splitoff
    -f --force          force overwrite of .info file
    -p --prefix=s       specify Fink prefix (defaults to /sw)
    -T --tree=s         specify where in Fink to write .info file
                          (defaults to unstable/main)
    -n --perltypes=s    what perl variants (defaults to "5.8.1 5.8.4 5.8.6")
    -c --cpanhost=s     what CPAN mirror (defaults to %p/etc/fink.conf value)
    -B --bugurl=s       where to report module bugs (defaults to
                          "http://rt.cpan.org/NoAuth/Bugs.html?Dist=")
    -v --verbose        print diagnostics
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

Lots of fields are incomplete or are just guesses.  Please confirm all data manually.

Does not indicate crypto vs. main dependencies

=head1 LICENSE

This program can be distributed under the same terms as Fink.

=head1 AUTHOR

Chris Dolan <chrisdolan@users.sourceforge.net>

=cut

use strict;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Getopt::Long;
use Pod::Usage;
use Carp;
use Fink::BuildPerlMod;

$SIG{__WARN__} = $SIG{__DIE__} = \&Carp::confess;

my %opts = (
            verbose    => 0,
            help       => 0,
            version    => 0,

            force      => 0,
            prereqs    => 0,
            typepkg    => 0,
            bin        => 0, # make a %N-bin splitoff

            prefix     => "/sw",
            maintainer => undef,
            tree       => "unstable/main",
            perltypes  => "5.8.1 5.8.4 5.8.6",
            cpanhost   => undef, # base url for CPAN mirror, or use fink.conf
            bugurl     => "http://rt.cpan.org/NoAuth/Bugs.html?Dist=",
            );

Getopt::Long::Configure("bundling");
GetOptions("v|verbose"  => \$opts{verbose},
           "h|help"     => \$opts{help},
           "V|version"  => \$opts{version},

           "f|force"    => \$opts{force},
           "P|prereqs"  => \$opts{prereqs},
           "t|typepkg"  => \$opts{typepkg},
           "b|bin"      => \$opts{bin},

           "p|prefix=s"     => \$opts{prefix},
           "m|maintainer=s" => \$opts{maintainer},
           "T|tree=s"       => \$opts{tree},
           "n|perltypes=s"  => \$opts{perltypes},
           "c|cpanhost=s"   => \$opts{cpanhost},
           "B|bugurl=s"     => \$opts{bugurl},
           ) or pod2usage(1);

pod2usage(-exitstatus => 0, -verbose => 2) if ($opts{help});
print("$0 v$Fink::BuildPerlMod::VERSION\n"),exit(0) if ($opts{version});

if (!$opts{maintainer})
{
   print "Please specify a maintainer\n";
   podusage(1);
}

if (@ARGV < 1)
{
   pod2usage(1);
}

my $fink = Fink::BuildPerlMod->new(
                                   verbose    => $opts{verbose},

                                   prereqs    => $opts{prereqs},
                                   typepkg    => $opts{typepkg},
                                   bin        => $opts{bin},

                                   prefix     => $opts{prefix},
                                   maintainer => $opts{maintainer},
                                   tree       => $opts{tree},
                                   perltypes  => $opts{perltypes},
                                   cpanhost   => $opts{cpanhost},
                                   bugurl     => $opts{bugurl},
                                   );
if (!$fink)
{
   die "Failed to initialize\n";
}

foreach my $module (@ARGV)
{
   $fink->buildpkg($module, $opts{force});
}
