#
# Fink::Mirror module
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2002 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

package Fink::Mirror;

use Fink::Services qw(&prompt_selection
                      &read_properties &read_properties_multival);
use Fink::Config qw($config $basepath $libpath);

use strict;
use warnings;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION = 1.00;
  @ISA         = qw(Exporter);
  @EXPORT      = qw();
  %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

  # your exported package globals go here,
  # as well as any optionally exported functions
  @EXPORT_OK   = qw(&fetch_url &fetch_url_to_file);
}
our @EXPORT_OK;

my %named_mirrors = ();

END { }       # module clean-up code here (global destructor)


### get mirror by name (class method, caches objects)

sub get_by_name {
  shift;  # class method
  my $name = shift;
  my ($mirror);

  if (exists $named_mirrors{$name}) {
    return $named_mirrors{$name};
  }
  $mirror = Fink::Mirror->new_from_name($name);
  $named_mirrors{$name} = $mirror;
  return $mirror;
}

### constructor from name (for configurable mirrors)

sub new_from_name {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $name = shift;

  my $self = {};
  bless($self, $class);

  $self->{name} = $name;

  my $mirrorfile = "$libpath/mirror/$name";
  if (not -f $mirrorfile) {
    die "No mirror site list file found for mirror '$name'.\n";
  }
  $self->{data} = &read_properties_multival($mirrorfile);

  # Extract the timestamp, and delete it from the hash.
  $self->{timestamp} = $self->{data}->{timestamp};
  delete $self->{data}->{timestamp};

  $self->initialize();

  return $self;
}

### construct from field contents (for inline custom mirrors)

sub new_from_field {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $field = shift;
  my $package = shift || "unknown package";

  my $self = {};
  bless($self, $class);

  $self->{name} = "-";
  $self->{package} = $package;

  my ($key, $url);
  $self->{data} = {};
  foreach (split /^/m, $field) {
    next if /^\s*\#/;   # skip comments
    if (/^\s*([0-9A-Za-z_.\-]+)\:\s*(\S.*?)\s*$/) {
      $key = lc $1;
      $url = $2;
#    } elsif (/^\s+(\S.*?)\s*$/) {
#      $key = "primary";
#      $url = $1;
    } else {
      next;
    }

    if (exists $self->{data}->{$key}) {
      push @{$self->{data}->{$key}}, $url;
    } else {
      $self->{data}->{$key} = [ $url ];
    }
  }

  $self->initialize();

  return $self;
}

### self-initialization

sub initialize {
  my $self = shift;

  $self->{lastused} = "";
  $self->{failed} = {};
  $self->{tries} = 0;
}

### get a url (no previous tries)

sub get_site {
  my $self = shift;
  my ($name, $url, $level, @list);

  if ($self->{lastused}) {
    $url = $self->{lastused};
    $url .= "/" unless $url =~ /\/$/;
    return $url;
  }

  $name = $self->{name};
  if ($name ne "-") {
    # check the configuration for named mirrors
    if ($Fink::Config::config->has_param("mirror-$name")) {
      $self->{lastused} = $url = $Fink::Config::config->param("mirror-$name");
      $url .= "/" unless $url =~ /\/$/;
      return $url;
    }
  }

  # pick one at random
  for ($level = 1; $level <= 3; $level++) {
    @list = $self->list_by_level($level);
    next if $#list < 0;

    $self->{lastused} = $url = $list[int(rand(scalar(@list)))];
    $url .= "/" unless $url =~ /\/$/;
    return $url;
  }

  # nothing found, not even primaries
  if ($name eq "-") {
    $name = "custom mirror of ".$self->{package};
  } else {
    $name = "mirror '$name'";
  }
  die "Can't find a site for $name, not even a primary one\n";
}

### get a url for retries after the previous failed
# returns "" when the user chooses to give up

sub get_site_retry {
  my $self = shift;
  my ($result, $level, @choice_list, $default, $url);
  my (@list_country, @list_continent, @list_world);

  # hmm, someone called us without calling get_site() on the initial try
  if (not $self->{lastused}) {
    return $self->get_site();
  }

  # record the failure
  $self->{tries}++;
  $self->{failed}->{$self->{lastused}} = 1;

  # get lists of remaining mirrors
  @list_country = grep { not exists $self->{failed}->{$_} }
    $self->list_by_level(1);
  @list_continent = grep { not exists $self->{failed}->{$_} }
    $self->list_by_level(2);
  @list_world = grep { not exists $self->{failed}->{$_} }
    $self->list_by_level(3);

  # assemble choices
  @choice_list = ( "error", "retry" );
  if ($#list_country >= 0) {
    push @choice_list, "retry-country";
  }
  if ($#list_continent > $#list_country) {
    push @choice_list, "retry-continent";
  }
  $default = $#choice_list + 1;
  if ($#list_world > $#list_continent) {
    push @choice_list, "retry-world";
    if ($self->{tries} >= 3) {
      $default = $#choice_list + 1;
    }
  }
  if ($self->{tries} >= 5) {
    $default = 1;
  }

  # ask the user
  $result =
    &prompt_selection("How do you want to proceed?", $default,
		      { "error" => "Give up",
			"retry" => "Retry the same mirror",
			"retry-country" => "Retry another mirror from your country",
			"retry-continent" => "Retry another mirror from your continent",
			"retry-world" => "Retry another mirror" },
		      @choice_list);

  $url = $self->{lastused};
  if ($result eq "error") {
    return "";
  } elsif ($result eq "retry") {
    # nothing to do
  } elsif ($result eq "retry-country") {
    if ($#list_country >= 0) {
      $url = $list_country[int(rand(scalar(@list_country)))];
    }
  } elsif ($result eq "retry-continent") {
    if ($#list_continent >= 0) {
      $url = $list_continent[int(rand(scalar(@list_continent)))];
    }
  } elsif ($result eq "retry-world") {
    if ($#list_world >= 0) {
      $url = $list_world[int(rand(scalar(@list_world)))];
    }
  }

  $self->{lastused} = $url;
  $url .= "/" unless $url =~ /\/$/;
  return $url;
}

### get a list of primary sites

sub list_primary {
  my $self = shift;
  my ($site, @list);

  @list = ();
  foreach $site (@{$self->{data}->{primary}}) {
    push @list, $site;
  }

  return @list;
}

### get a list of geographical sites by level
# level: 0 - configured (-> empty list)
#        1 - country
#        2 - continent
#        3 - world (includes primaries)

sub list_by_level {
  my $self = shift;
  my $level = shift;
  my ($site, @list, $key, $match);

  @list = ();
  if ($level <= 0) {
    return @list;
  } elsif ($level == 1) {
    $match = lc $config->param_default("MirrorCountry", "nam-us");
  } elsif ($level == 2) {
    $match = lc $config->param_default("MirrorContinent", "nam");
  } else {
    $match = "";
  }

  foreach $key (keys %{$self->{data}}) {
    if ($key =~ /^$match/) {
      foreach $site (@{$self->{data}->{$key}}) {
	push @list, $site;
      }
    }
  }

  return @list;
}


### EOF
1;
