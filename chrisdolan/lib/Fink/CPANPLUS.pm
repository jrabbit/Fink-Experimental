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
   print "Started CPANPLUS\n" if ($self->{verbose});
   $self->{cb}->configure_object->set_conf(verbose => $self->{verbose});
   
   return $self;
}

sub set_host
{
   my $self = shift;
   my $host = shift;

   if ($host && $host =~ m,^(\w+)://([\w\.\-]+)(/.*),)
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

sub module_tree
{
   my $self = shift;
   return $self->{cb}->module_tree(@_);
}

sub get_module
{
   my $self = shift;
   my $modname = shift;

   my $cache = $self->{modcache};
   if (!$cache->{$modname})
   {
      my $mod = Fink::CPANPLUS::Module->new($self, $modname);
      $cache->{$modname} = $mod;
      if ($mod)
      {
         $cache->{$mod->package_name} = $mod;
      }
   }
   return $cache->{$modname};
}

1;
