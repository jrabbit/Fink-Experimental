#!/usr/bin/perl -w

# For a given perlmod .info file, go to CPAN and get the MD5 for the
# source file.  Compare the result to the .info file to see if it
# needs updating.

use strict;
use LWP::Simple qw(get);
use File::Slurp;
use Data::Dumper;

my $SERVER = "http://www.cpan.org/";

my $file = shift || die "Syntax: $0 <infofile>\n";

print "Reading $file\n";
$_ = read_file($file);
# extract .info fields as a hash.  Doesn't support multiline fields
my %info = /^([\w\-]+): *(.*)$/gm;

my $src = $info{Source};
$src =~ s/mirror:cpan:/$SERVER/;
$src =~ s/([^\/]*)$/CHECKSUMS/;
my $dist = $1;
$dist =~ s/%v/$info{Version}/g;

print "Retrieving $src\n";
my $cksum = get($src) || die "Failed\n";

print "Evaling $src\n";
eval $cksum;
($@ || !$cksum) && die "Failed\n";

print "Fetching record for $dist\n";
my $record = $cksum->{$dist} || die "Failed\n".Dumper($cksum);
print "Old MD5: ".$info{"Source-MD5"}."\n";
print "New MD5: ".$record->{md5}."\n";
