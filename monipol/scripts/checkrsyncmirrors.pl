#!/usr/bin/perl

use strict;
use warnings;

my $basepath = '/sw';

my $mirror_FH;
my $timestamp_FH;
my $mirror;
my $timestamp;
my $command;
my $command_result;
my $ts;
my @files = ('TIMESTAMP', 'LOCAL');
#my @files = ('TIMESTAMP');
my $file;
my $mirrorname;
my @mirrornameparts;

open($mirror_FH, '<', "$basepath/lib/fink/mirror/rsync") || die "Could not open rsync mirrors file\n";
while (<$mirror_FH>) {
	if($_ =~ /(^...-..: |Primary: )(rsync:\/\/.*)/) {
		$mirror = $2;
		chomp $mirror ;
		$mirrorname = $mirror;
		$mirrorname =~ s/^rsync:\/\///;
		($mirrorname) = split(/\//, $mirrorname);
		print "$mirrorname:\n";
		foreach $file (@files) {
			system("rm -f ./$file");
			$command = "rsync -qaz --timeout=5 $mirror" . "$file ./$file 2>/dev/null";
			$command_result = system("$command");
			$command_result = $command_result >> 8;
			if ($command_result == 0) {
				if (open($timestamp_FH, '<', "./$file")) {
					$timestamp = <$timestamp_FH>;
					if (defined $timestamp) {
						chomp $timestamp;
						close $timestamp_FH;
						$ts = `date -j -f \%s $timestamp \%+\%`;
						chomp $ts;
						print "\t$file = $timestamp = $ts\n";
					}
					else {
						print "\tLocal $file couldn't be parsed\n";
					}
					system("rm -f ./$file");
				}
				else {
					print "\tCouldn't open local $file file\n";
				}
			}
			else {
				print "\tRsync failed for $file\n";
			}
		}
	}
}
close($mirror_FH);
