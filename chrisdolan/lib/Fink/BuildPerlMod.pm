package Fink::BuildPerlMod;

use warnings;
use strict;
use Fink::CPANPLUS;
use File::Slurp;

our $VERSION = "1.10";

# Translation from Module::Build license tags to Fink words
#   From: http://search.cpan.org/dist/Module-Build/lib/Module/Build.pm#license
#   To:   http://fink.sourceforge.net/doc/packaging/policy.php#licenses
my %licenses = (
                perl         => "Artistic/GPL",
                gpl          => "GPL",
                lgpl         => "LGPL",
                bsd          => "BSD",
                artistic     => "Artistic",
                open_source  => "OSI-Approved",
                unrestricted => "Restrictive/Distributable",
                restrictive  => "Restrictive", 
                );

sub new
{
   my $pkg = shift;
   my %flags = (@_);

   my $self = bless({
      %flags,
   }, $pkg);

   $self->{prefix} ||= "/sw";
   if (!-d $self->{prefix})
   {
      die "No such directory $$self->{prefix} for Fink prefix\n";
   }

   if (!$self->{cpanhost} && -f $self->{prefix}."/etc/fink.conf")
   {
      my $conf = read_file("/sw/etc/fink.conf");
      if ($conf =~ /^Mirror-cpan: (.*)$/m)
      {
         $self->{cpanhost} = $1;
         print "CPAN mirror: $$self{cpanhost}\n" if ($self->{verbose});
      }
   }

   $self->{cp} = Fink::CPANPLUS->new(
                                     verbose => $self->{verbose},
                                     prereqs => $self->{prereqs},
                                     );
   if ($self->{cpanhost})
   {
      unless ($self->{cp}->set_host($self->{cpanhost}))
      {
         die "Failed to set CPAN URL\n";
      }
   }

   return $self;
}

sub verbose
{
   my $self = shift;
   return $self->{verbose};
}

sub pkgdir
{
   my $self = shift;
   return $self->{prefix}."/fink/dists/".$self->{tree}."/finkinfo/libs/perlmods";
}

sub buildpkg
{
   my $self = shift;
   my $modname = shift;
   my $overwrite = shift;

   print "Search for $modname\n" if ($self->verbose);
   my $mod = $self->{cp}->get_module($modname);
   if (!$mod)
   {
      print "Not found\n" if ($self->verbose);
      return undef;
   }

   my $pkg = lc($mod->package_name)."-pm";
   my $file = $self->pkgdir."/$pkg.info";
   if (-f $file && !$overwrite)
   {
      print "package already exists\n";
      print "  $file\n" if ($self->verbose);
      return undef;
   }

   if ($self->verbose)
   {
      my $details = $mod->details;
      for my $key (keys %$details)
      {
         print "$key: $$details{$key}\n";
      }
   }

   my $bin = $self->{bin} || $mod->bin();
   my $typepkg = $self->{typepkg} || $mod->has_xs();  # TODO extend based on depends, etc
   my @perlversions = sort split /\s+/, $self->{perltypes};
   my %libs = (
               depends        => $mod->depends(),
               builddepends   => $mod->builddepends(),
               recommends     => $mod->recommends(),
               conflicts      => $mod->conflicts(),
               buildconflicts => $mod->buildconflicts(),
               );
   foreach my $type (qw(recommend conflicts buildconflicts))
   {
      my %l;
      foreach my $dep (keys %{$libs{$type}})
      {
         my ($deppkg) = $self->finkify_dep_pkg($dep, @perlversions);
         $l{$deppkg} = $libs{$type}->{$dep};
      }
      $libs{$type} = \%l;
   }
   foreach my $type (qw(depends builddepends))
   {
      my %l;
      foreach my $dep (keys %{$libs{$type}})
      {
         my ($deppkg, $deptypepkg, $depvers) = $self->finkify_dep_pkg($dep, @perlversions);
         $l{$deppkg} = $libs{$type}->{$dep};
         $typepkg ||= $deptypepkg;
         if ("@perlversions" ne "@$depvers")
         {
            print "Reducing versions to (@$depvers) because of $deppkg\n" if ($self->verbose);
            @perlversions = @$depvers;
         }
      }
      $libs{$type} = \%l;
   }

   if ($typepkg)
   {
      $libs{depends}->{"perl\%type_pkg[perl]-core"} = 0;
   }

   # Do we need a patchscript for COPYRIGHT?
   my $patchscript = undef;
   my @docfiles = $mod->doc_files();
   my $licensefile = $mod->license_filename();
   if ($licensefile && grep({$_ eq $licensefile} @docfiles) == 0)
   {
      my $content = read_file($mod->extract_dir()."/".$licensefile);
      if ($content =~ /=head\d\s+(licen[cs]e|copyright)/)
      {
         $patchscript = 'perl -0 -pe\'s/^.*=head\\d ('.$1.'.*?)(=head\\d.*|=cut.*|)$/$1/s\' '.$licensefile.' > COPYRIGHT';
         push @docfiles, "COPYRIGHT";
      }
      else
      {
         $patchscript = 'echo "Please write a patchscript that extracts the copyright from $licensefile"';
      }
   }
   
   # Prepare the .info fields.  Note that we use "_" instead of "-"
   # in field names to keep perl happy.
   my @data = (
               Package    => $pkg.($typepkg ? "%type_pkg[perl]" : ""),
               Version    => $mod->package_version,
               Revision   => "1",
               Source     => ("mirror:cpan:" . $mod->path . "/" . 
                              $mod->package_name . "-%v." . 
                              $mod->package_extension),
               Source_MD5 => $mod->checksum,
               Type       => "perl" . ($typepkg ? " (@perlversions)" : ""),
               ($patchscript ? (PatchScript => $patchscript) : ()),
               UpdatePOD  => "true",
               Depends        => join(", ", sort keys %{$libs{depends}}),
               BuildDepends   => join(", ", sort keys %{$libs{builddepends}}),
               Conflicts      => join(", ", sort keys %{$libs{conflicts}}),
               BuildConflicts => join(", ", sort keys %{$libs{buildconflicts}}),
               Recommends     => join(", ", sort keys %{$libs{recommends}}),
               DocFiles    => join(" ", @docfiles),
               License     => $licenses{$mod->license()||""},
               Description => $mod->description,
               Maintainer  => $self->{maintainer},
               Homepage    => "http://search.cpan.org/dist/".$mod->package_name,
               DescPackaging => join("\n",
                                     "<<",
                                     " Found a bug?  Please check if it has already been reported:",
                                     " ".$self->{bugurl}.$mod->package_name(),
                                     "<<"),
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
   my $manconflict = join(", ", map("%{Ni}$_-man", @perlversions));
   (my $binconflict = $manconflict) =~ s/-man/-bin/g;
   if ($bin)
   {
      my $splitnum = ++$splitoffs == 1 ? "" : $splitoffs;
      if ($typepkg)
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
   if ($typepkg)
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

   return 1;
}

sub finkify_dep_pkg
{
   my $self = shift;
   my $pkg = shift;
   my @perlvers = (@_);

   $pkg = lc($pkg)."-pm";

   # Special cases:
   $pkg =~ s/libwww-perl-pm/libwww-pm/;

   my $out_typepkg = 0;
   my @out_perlvers;

   my $filename = $self->pkgdir."/$pkg.info";
   if (-f $filename)
   {
      my $content = read_file($filename);
      if ($content =~ /^Package:.*\%type_pkg[perl]/m)
      {
         $out_typepkg = 1;

         if ($content =~ /Type:\s+perl\s+\(?[\d\.\s]*\)?/)
         {
            my @vers = split /\s+/, $1;
            my %perlvers = map {$_, 1} @perlvers;
            foreach my $v (@vers)
            {
               if ($perlvers{$v})
               {
                  push @out_perlvers, $v;
               }
            }
         }
      }
      else
      {
         @out_perlvers = @perlvers;
      }
   }
   else
   {
      foreach my $v (@perlvers)
      {
         (my $verabbr = $v) =~ s/\.//g;  # 5.8.1 -> 581
         my $filename = $self->pkgdir."/$pkg$verabbr.info";
         if (-f $filename)
         {
            push @out_perlvers, $v;
            $out_typepkg = 1;
         }
      }
      if (@out_perlvers == 0)
      {
         print "$pkg is not yet packaged for Fink\n" if ($self->verbose);
         @out_perlvers = @perlvers;
      }
   }
   if ($out_typepkg)
   {
      $pkg .= "\%type_pkg[perl]";
   }
   return ($pkg, $out_typepkg, [sort @out_perlvers]);
}


1;
