package Fink::CPANPLUS::Module;

use warnings;
use strict;
use CPANPLUS::Internals::Constants;
use File::Slurp;

my $min_perl_version = 5.008;

# TODO: add buildfile() method like makefile()

# This is a translation from CPAN "dslip" codes to Module::Build YAML codes
#   From: http://cpan.uwinnipeg.ca/htdocs/faqs/dslip.html
#   To:   http://search.cpan.org/dist/Module-Build/lib/Module/Build.pm#license
my %licenses = (
                p   => "perl",
                g   => "gpl",
                l   => "lgpl",
                b   => "bsd",
                a   => "artistic",
                o   => "unrestricted",
                );
sub new
{
   my $pkg = shift;
   my $cp = shift;
   my $name = shift;

   my $self = bless({
      cp => $cp,
      name => $name,
      mod => $cp->module_by_name($name),
   }, $pkg);
   
   return $self->{mod} ? $self : undef;
}

sub verbose
{
   my $self = shift;
   return $self->{cp}->{verbose};
}

foreach my $fn (qw(
                   package_name
                   package_version
                   package_extension
                   path
                   details
                   ))
{
   eval "sub $fn {return shift()->{mod}->$fn();}";
}

sub license_filename
{
   my $self = shift;

   # Check files that are for-sure
   my @licenses = grep /^(copyright|copying|license|gpl|lgpl|artistic)/i, $self->root_files();
   return $licenses[0] if (@licenses > 0);

   # Check doc files that might have copyright inline
   foreach my $file (grep(/^readme/i, $self->root_files()),
                     grep({defined $_} $self->makefile->{version_from}))
   {
      my $filename = $self->extract_dir()."/".$file;
      if (-f $filename)
      {
         my $content = read_file($filename);
         if ($content =~ /licen[sc]e|licensing|copyright/i) # [sc] is to catch a common typo
         {
            return $file;
         }
      }
   }

   return undef;
}

sub checksum
{
   my $self = shift;

   $self->extract(); # TODO: do we really need to extract first??
   return $self->{mod}->status->checksum_value();
}

sub root_files
{
   my $self = shift;

   # Get list of files in the root of the distro
   my @files = map({$_->[1]}
                   grep({-f $_->[0]}
                        map({[$self->extract_dir()."/".$_,$_]} 
                            read_dir($self->extract_dir()))));
   return @files;
}
sub doc_files
{
   my $self = shift;
   my @docfiles = grep !/^(
                           .*\.(bat|xs|pm|pl|PM|PL) |
                           Makefile |
                           MANIFEST\.SKIP |
                           INSTALL.* |
                           pm_to_blib
                           )$/xi, $self->root_files();
   return @docfiles;
}

sub has_xs
{
   my $self = shift;

   my @xs = grep /\.xs$/, $self->root_files();
   return @xs > 0;
}
sub bin
{
   my $self = shift;

   return $self->makefile->{bin};
}

sub license
{
   my $self = shift;

   return $self->yml->{license} || $self->dslip->{license};
}

sub description
{
   my $self = shift;

   my $desc = $self->yml->{abstract} || $self->makefile->{abstract} || $self->{mod}->description();
   if (!$desc && 
       $self->mainfile() =~ /=head1\s+NAME\s+[\w\-\'\:]+\s+\-\s+([^\r\n]+)/s)
   {
      $desc = $1;
   }
   $desc =~ s/\.$// if (defined $desc);
   return $desc;
}

foreach my $fn (qw(depends
                   recommends
                   conflicts
                   builddepends
                   buildconflicts))
{
   eval "sub $fn {return shift()->libs->{$fn};}";
}

# internal functions

sub libs
{
   my $self = shift;

   if (!$self->{libs})
   {
      $self->{libs} = {};
      my @check = (
                   $self->prereqs(),
                   $self->makefile(),
                   $self->yml(),
                   );
      foreach my $type (qw(depends recommends conflicts builddepends buildconflicts))
      {
         $self->{libs}->{$type} = {};

         foreach my $o (@check)
         {
            my $p = $o->{$type};
            if ($p)
            {
               $self->{libs}->{$type} = {%{$self->{libs}->{$type}}, %$p};
            }
         }
      }
   }
   return $self->{libs};
}

sub dslip
{
   my $self = shift;

   if (!$self->{dslip})
   {
      my @d = split "", ($self->{mod}->dslip || "");
      $self->{dslip} = {
         license => $licenses{$d[4] || ""},
      };
   }
   return $self->{dslip};
}

sub makefile
{
   my $self = shift;

   if (!$self->{makefile})
   {
      $self->{makefile} = {};
      my $filename = $self->extract_dir()."/Makefile.PL";
      if (-f $filename)
      {
         my $makefile = read_file($filename);
         # Get main file from the MakeMaker command
         if ($makefile =~ /([\'\"]?)VERSION_FROM\1\s*(?:=>|,)\s*(\"[^\"]+|\'[^\']+)/s)
         {
            $self->{makefile}->{version_from} = substr($2,1);
         }
         # Get ABSTRACT string from the MakeMaker command
         if ($makefile =~ /([\'\"]?)ABSTRACT\1\s*(?:=>|,)\s*(\"[^\"]+|\'[^\']+)/s)
         {
            $self->{makefile}->{abstract} = substr($2,1);
         }
         # Check if there are any script outputs
         if ($makefile =~ /([\'\"]?)EXE_FILES\1\s*(?:=>|,)/s)
         {
            $self->{makefile}->{bin} = 1;
         }
         # Check for prereqs
         if ($makefile =~ /([\'\"]?)PREREQ_PM\1\s*(?:=>|,)\s*(\{.*?\})/s)
         {
            my $hash = $2;
            my $libs;
            {
               no strict;
               no warnings;
               eval "\$libs = $hash";
            }
            #$hash =~ s/\s+/ /g;
            if ($@)
            {
               print "Eval error for PREREQ_PM: $@\n$hash\n" if ($self->verbose);
            }
            else
            {
               foreach my $type ("depends")
               {
                  $self->{makefile}->{$type} = {};
                  foreach my $key (keys %$libs)
                  {
                     my $pkg = $self->get_dep_pkg($key, $libs->{$key}, $type);
                     if ($pkg)
                     {
                        $self->{makefile}->{$type}->{$pkg} = $libs->{$key};
                     }
                  }
               }
            }
         }
      }
   }
   return $self->{makefile};
}

sub mainfile
{
   my $self = shift;
   if (!defined $self->{mainfile})
   {
      $self->{mainfile} = "";
      if ($self->makefile->{version_from})
      {
         my $filename = $self->extract_dir."/".$self->makefile->{version_from};
         if (-f $filename)
         {
            $self->{mainfile} = read_file($filename);
         }
      }
   }
   return $self->{mainfile};
}

sub yml
{
   my $self = shift;

   if (!$self->{yml})
   {
      $self->{yml} = {
         depends => {},
         builddepends => {},
         conflicts => {},
         recommends => {},
      };
      my $filename = $self->extract_dir()."/META.yml";
      if (-f $filename)
      {
         require YAML;
         my $yaml = read_file($filename);
         my $meta = YAML::Load($yaml);
         if (!$meta)
         {
            print "Failed to read META.yml\n" if ($self->verbose);
         }
         else
         {
            if ($meta->{license})
            {
               $self->{yml}->{license} = $meta->{license};
            }
            if ($meta->{abstract})
            {
               $self->{yml}->{abstract} = $meta->{abstract};
            }
            my %libtrans = (
                            requires => "depends",
                            build_requires => "builddepends",
                            conflicts => "conflicts",
                            recommends => "recommends",
                            );
            foreach my $ytype (keys %libtrans)
            {
               my $type = $libtrans{$ytype};
               if ($meta->{$ytype})
               {
                  foreach my $key (keys %{$meta->{$ytype}})
                  {
                     my $pkg = $self->get_dep_pkg($key, $meta->{$ytype}->{$key}, $type);
                     if ($pkg)
                     {
                        $self->{yml}->{$type}->{$pkg} = $meta->{$ytype}->{$key};
                     }
                  }
               }
            }
         }
      }
   }
   return $self->{yml};
}

sub prereqs
{
   my $self = shift;

   if (!$self->{prereqs})
   {
      $self->{prereqs} = {};
      if ($self->{cp}->{prereqs})
      {
         $self->extract();
         my $dist = $self->{mod}->dist(format => $self->{mod}->get_installer_type(),
                                       target => TARGET_PREPARE);
         # The file arg is happily ignored for Build.PL packages
         my $prereqs = $dist->_find_prereqs(file => $self->extract_dir()."/Makefile.PL",
                                            verbose => $self->verbose);
         foreach my $type (qw(depends))
         {
            foreach my $key (sort keys %$prereqs)
            {
               print "  Prereq: $key => $$prereqs{$key}\n" if ($self->verbose);
               my $pkg = $self->get_dep_pkg($key, $prereqs->{$key}, $type);
               if ($pkg)
               {
                  $self->{prereqs}->{$type}->{$pkg} = $prereqs->{$key};
               }
            }
         }
      }
   }
   return $self->{prereqs};
}

sub get_dep_pkg
{
   my $self = shift;
   my $name = shift;
   my $val = shift;
   my $type = shift;

   $val = "" if (!defined $val);
   $type = "depends" if (!defined $type);

   if (lc($name) eq "perl")
   {
      print "$type Perl: $val\n" if ($self->verbose);
      return undef;
   }
   else
   {
      require Module::CoreList;
      my $corever = Module::CoreList->first_release($name);
      if ($corever && $corever <= $min_perl_version)
      {
         return undef;
      }

      my $mod = $self->{cp}->get_module($name);
      if ($mod)
      {
         return $mod->package_name;
      }
      else
      {
         print "Can't find prereq module $name\n" if ($self->verbose);
         return undef;
      }
   }
}

sub extract_dir
{
   my $self = shift;
   return $self->extract();
}
sub extract
{
   my $self = shift;

   $self->fetch();
   if (!$self->{mod}->status->extract)
   {
      #print "Extract module\n" if ($self->verbose);
      $self->{mod}->extract;
      print "Extracted to ".$self->{mod}->status->extract."\n" if ($self->verbose);
   }
   return $self->{mod}->status->extract;
}
sub fetch
{
   my $self = shift;

   if (!$self->{mod}->status->fetch)
   {
      #print "Fetch module\n" if ($self->verbose);
      $self->{mod}->fetch;
   }
   return $self->{mod}->status->fetch;
}

1;
