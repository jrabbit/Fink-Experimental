#!/usr/bin/perl

my @files = @ARGV;

if (not @files) {
	opendir(DIR, ".") or die "can't get file list in .: $!\n";
	@files = grep(/\.info$/, readdir(DIR));
	closedir(DIR);
}

for my $file (@files) {
	if (open(FILEIN, $file)) {
		my $contents;
		{ local $/ = undef; $contents = <FILEIN>; }
		close(FILEIN);

		(my $package)  = $contents =~ /^\s*Package:\s*(\S+?)\s*$/mi;
		(my $version)  = $contents =~ /^\s*Version:\s*(\S+?)\s*$/mi;
		(my $revision) = $contents =~ /^\s*Revision:\s*(\S+?)\s*$/mi;
		my $newrev = $revision + 1;
		$contents =~ s/^(\s*)Revision:\s*\S+?\s*$/$1Revision: $newrev/m;

		print "- writing $package-$version-$newrev.info... ";
		if (-f "$package-$version-$newrev.info") {
			print "exists\n";
		}
		if (open (FILEOUT, ">$package-$version-$newrev.info")) {
			print FILEOUT $contents;
			close(FILEOUT);
			print "done\n";
			if (-f "$package-$version-$revision.patch") {
				print "- copying $package-$version-$newrev.patch... ";
				if (system("cp $package-$version-$revision.patch $package-$version-$newrev.patch") == 0) {
					print "done\n";
				} else {
					print "failed\n";
				}
			}
		} else {
			print "failed\n";
		}
	} else {
		warn "unable to read from $file ($!) -- skipping\n";
	}
}
