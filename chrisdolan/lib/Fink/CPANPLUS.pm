package Fink::CPANPLUS;

use warnings;
use strict;
use CPANPLUS::Backend;
use Fink::CPANPLUS::Module;

sub new
{
   my $pkg = shift;
   my %flags = (@_);

   my $self = bless({
      %flags,
      modcache => {},
   }, $pkg);
   $self->{cb} = CPANPLUS::Backend->new();
   #print "Started CPANPLUS\n" if ($self->{verbose});
   $self->{cb}->configure_object->set_conf(verbose => $self->{verbose});
   
   return $self;
}

sub set_host
{
   my $self = shift;
   my $host = shift;

   if ($host && $host eq "default")
   {
      # noop
      return 1;
   }
   elsif ($host && $host =~ m,^(\w+)://([\w\.\-]+)(/.*),)
   {
      $self->{cb}->configure_object->set_conf("hosts", [{
         scheme => $1,
         host => $2,
         path => $3,
      }]);
      return 1;
   }
   else
   {
      return undef;
   }
}

sub module_by_name
{
   # Returns CPANPLUS module (internal only)
   my $self = shift;
   my $modname = shift;

   if ($modname =~ /::/)
   {
      return $self->{cb}->module_tree($modname);
   }
   else
   {
      my $re = qr/^\Q$modname\E-\d[\d\.]*\.(?:tar\.gz|zip|tgz)$/i;
      my ($mod) = $self->{cb}->search(type => "package", allow => [$re]);
      #print "Search yielded ".$mod->name." for package $modname\n" if ($mod && $self->{verbose});
      return $mod;
   }
}

sub get_module
{
   # Returns Fink::CPANPLUS::Module (public interface)
   my $self = shift;
   my $modname = shift;

   my $cache = $self->{modcache};
   if (!$cache->{lc$modname})
   {
      my $mod = Fink::CPANPLUS::Module->new($self, $modname);
      $cache->{lc$modname} = $mod;
      if ($mod)
      {
         $cache->{lc($mod->package_name)} = $mod;
      }
   }
   return $cache->{lc$modname};
}

1;
