package Fink::BuildPerlMod;

use warnings;
use strict;
#use Fink::CPANPLUS;  # now loads on demand
use File::Slurp;

our $VERSION = "1.20";

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

   require Fink::CPANPLUS;
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

sub pkg_dir
{
   my $self = shift;
   return $self->{prefix}."/fink/dists/".$self->{tree}."/finkinfo/libs/perlmods";
}

sub build_pkg
{
   my $self = shift;
   my $modname = shift;
   my $overwrite = shift;

   my $mod = $self->get_module($modname);
   return undef if (!$mod);

   my $pkg = lc($mod->package_name)."-pm";
   my $file = $self->pkg_dir."/$pkg.info";
   if (-f $file && !$overwrite)
   {
      print "package already exists\n" if ($self->verbose);
      print "  $file\n" if ($self->verbose);
      return undef;
   }

   my $data = $self->get_pkg_details($mod);
   return undef if (!$data);

   write_file($file, $self->to_string($data));
   print "Wrote file $file\n" if ($self->{verbose});

   return 1;
}

sub diff_pkg
{
   my $self = shift;
   my $modname = shift;

   my $mod = $self->get_module($modname);
   return undef if (!$mod);

   my $pkg = lc($mod->package_name)."-pm";
   my $file = $self->pkg_dir."/$pkg.info";
   if (!-f $file)
   {
      print "package does not exists\n" if ($self->verbose);
      print "  $file\n" if ($self->verbose);
      return undef;
   }

   my $old = $self->from_string(scalar read_file($file));
   return undef if (!$old);

   my $new = $self->get_pkg_details($mod);
   return undef if (!$new);

   #use Data::Dumper;
   #print Dumper($old);
   #print Dumper($new);

   # simplify:
   if ($old->{Info2})
   {
      $old = $old->{Info2};
   }
   if ($new->[0] eq "Info2")
   {
      $new = $new->[1];
   }

   my @diffs = $self->_diff_pkg($old, $new);
   return join("\n", @diffs)."\n";
}

sub _diff_pkg
{
   my $self = shift;
   my $old = shift;
   my $new = shift;

   my @diffs;
   for (my $i=0; $i<@$new; $i+=2)
   {
      my $key = $new->[$i];
      my $val = $new->[$i+1];
      if (!exists $old->{$key})
      {
         unless ($val eq "")
         {
            push @diffs, "old - ";
            if (ref $val)
            {
               push @diffs, "new - ".$self->to_string([$key => $val]);
            }
            else
            {
               push @diffs, "new - $key: $val";
            }
         }
      }
      else
      {
         my $oldval = delete $old->{$key};
         if (ref $val)
         {
            my @d = $self->_diff_pkg($oldval, $val);
            s/ - / - $key./ for (@d);
            push @diffs, @d;
         }
         elsif ($val ne $oldval)
         {
            push @diffs, "old - $key: $oldval";
            push @diffs, "new - $key: $val";
         }
      }
   }
   foreach my $key (sort keys %$old)
   {
      my $val = $old->{$key};
      if (ref $val)
      {
         push @diffs, "old - ".$self->to_string([$key => $val]);
      }
      else
      {
         push @diffs, "old - $key: $val";
      }
      push @diffs, "new - ";
   }

   return @diffs;
}

sub get_module
{
   my $self = shift;
   my $modname = shift;

   print "Search for $modname\n" if ($self->verbose);
   my $mod = $self->{cp}->get_module($modname);
   if (!$mod)
   {
      print "Not found\n" if ($self->verbose);
      return undef;
   }
   return $mod;
}

sub get_pkg_details
{
   my $self = shift;
   my $mod = shift;

   my $pkg = lc($mod->package_name)."-pm";

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
   
   # Clean up, build hash
   my %data;
   for (my $i=0; $i<@data; $i+=2)
   {
      my $label = $data[$i];
      my $value = $data[$i+1];
      if (!defined $value)
      {
         print "Undef field '$label'\n" if ($self->{verbose});
         $value = $data[$i+1] = "";
      }
      $data{$label} = $value;
   }

   # Workm on splitoffs
   my $splitoffs = 0;
   my $manconflict = join(", ", map("%{Ni}$_-man", @perlversions));
   (my $binconflict = $manconflict) =~ s/-man/-bin/g;
   if ($bin)
   {
      my $splitnum = ++$splitoffs == 1 ? "" : $splitoffs;
      if ($typepkg)
      {
         push @data, "Splitoff$splitnum" => [
                                             Package => "%N-bin",
                                             Depends => "%N (= %v-%r)",
                                             Files => "bin",
                                             Conflicts => $binconflict,
                                             Replaces => $binconflict,
                                             DocFiles => $data{DocFiles},
                                             ];
      }
      else
      {
         push @data, "Splitoff$splitnum" => [
                                             Package => "%N-bin",
                                             Depends => "%N (= %v-%r)",
                                             Files => "bin share/man/man1",
                                             DocFiles => $data{DocFiles},
                                             ];
      }
   }
   if ($typepkg)
   {
      my $splitnum = ++$splitoffs == 1 ? "" : $splitoffs;
      push @data, "Splitoff$splitnum" => [
                                          Package => "%N-man",
                                          Depends => "%N (= %v-%r)",
                                          Files => "share/man",
                                          Conflicts => $manconflict,
                                          Replaces => $manconflict,
                                          DocFiles => $data{DocFiles},
                                          ];
      @data = ("Info2" => [@data]);
   }
   return \@data;
}

sub to_string
{
   my $pkg_or_self = shift;
   my $data = shift;

   my @out;
   for (my $i=0; $i<@$data; $i+=2)
   {
      my $key = $data->[$i];
      my $val = $data->[$i+1];
      $val = "" if (!defined $val);
      $key =~ s/_/-/g;
      if (ref $val)
      {
         $val = $pkg_or_self->to_string($val);
      }
      if ($val =~ /\n/)
      {
         $val = join("\n ", "<<", split(/\n/, $val))."\n<<";
      }
      push @out, "$key: $val";
   }
   return join("\n", @out);
}

sub from_string
{
   my $pkg_or_self = shift;
   my $in = shift || "";

   $in =~ s/^[ \t]*#.*$//mg;
   $in =~ s/\n+/\n/gs;
   return $pkg_or_self->_from_string(\$in);
}

sub _from_string
{
   my $pkg_or_self = shift;
   my $in = shift;

   my %data;
   while ($$in =~ /\G([\w\-]+):\s*/scg)
   {
      my $label = $1;
      $label =~ s/-/_/g;
      if ($$in =~ /\G<<\s*/scg)
      {
         if ($$in =~ /\G[\w\-]+:/s)
         {
            $data{$label} = $pkg_or_self->_from_string($in);
            unless ($$in =~ /\G<<\s*/scg)
            {
               last;
            }
         }
         else
         {
            if ($$in =~ /\G(.*?)<<\s*/scg)
            {
               my $val = $1;
               $val =~ s/\s+$//;
               $data{$label} = $val;
            }
         }
      }
      else
      {
         if ($$in =~ /\G([^\n]*)\s*/scg)
         {
            my $val = $1;
            $val =~ s/\s+$//;
            $data{$label} = $val;
         }
         else
         {
            last;
         }
      }
   }
   return \%data;
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

   my $filename = $self->pkg_dir."/$pkg.info";
   if (-f $filename)
   {
      my $content = read_file($filename);
      if ($content =~ /^Package:.*\%type_pkg\[perl\]/m)
      {
         $out_typepkg = 1;

         if ($content =~ /Type:\s+perl\s*\(?([\d\.\s]*)\)?/)
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
         my $filename = $self->pkg_dir."/$pkg$verabbr.info";
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
