#!/usr/bin/perl

# a little script to reorder .info files to match the
# packaging guidelines

# keyword expansion:
#   <CR> = put a carriage return after this entry
#   <N>  = any number
#   <S>  = any string

@KEYS = qw( Package Version Revision Description Type License Maintainer <CR> Depends BuildDepends Provides
	Conflicts Replaces Recommends Suggests Enhances Pre-Depends Essential BuildDependsOnly GCC <CR>
	CustomMirror Source Source<N> SourceDirectory NoSourceDirectory Source<N>ExtractDir SourceRename
	Source<N>Rename Source-MD5 Source<N>-MD5 TarFilesRename Tar<N>FilesRename <CR> UpdateConfigGuess
	UpdateConfigGuessInDirs UpdateLibtool UpdateLibtoolInDirs UpdatePoMakefile Patch PatchScript <CR>
	Set<S> NoSet<S> ConfigureParams CompileScript <CR> UpdatePOD InstallScript JarFiles DocFiles
	RuntimeVars SplitOff SplitOff<N> Files <CR> PreInstScript PostInstScript PreRmScript PostRmScript
	ConfFiles InfoDocs DaemonicFile DaemonicName <CR> Homepage DescDetail DescUsage DescPackaging
	DescPort );

for my $file (@ARGV) {

	system("mv '$file' '${file}.old'");

	my ($hash, $lastkey, $heredoc);

	open (FILEIN, "${file}.old") or die "can't read from ${file}.old: $!\n";
	{
		local $/ = undef;
		$text = <FILEIN>;
	}
	close (FILEIN);

	my $hash = parse_keys($text);
	my $text = make_formatted($hash);

	open (FILEOUT, ">${file}") or die "can't write to ${file}: $!\n";
	print FILEOUT $text;
	close (FILEOUT);

}

sub parse_keys {
	my $text    = shift;
	my $hash    = {};
	my $lastkey = "";
	my $heredoc = 0;

	for (split(/\r?\n/, $text)) {
		chomp;
		if ($heredoc > 0) {
			if (/^\s*<<$/) {
				$heredoc--;
				$hash->{lc($lastkey)} .= $_."\n" if ($heredoc > 0);
			} else {
				$hash->{lc($lastkey)} .= $_."\n";
				$heredoc++ if (/<<$/);
			}
		} else {
			next if /^\s*\#/;	 # skip comments
			if (/^\s*([0-9A-Za-z_.\-]+)\:\s*(\S.*?)\s*$/) {
				$lastkey = lc($1);
				if ($2 eq "<<") {
					$hash->{lc($lastkey)} = "";
					$heredoc = 1;
				} else {
					$hash->{lc($lastkey)} = $2;
				}
			} elsif (/^\s+(\S.*?)\s*$/) {
				$hash->{lc($lastkey)} .= "\n".$1;
			}
		}
	}

	if ($heredoc > 0) {
		if ($file) {
			print "WARNING: End of file reached during here-document in \"$file\".\n";
		} else {
			print "WARNING: End of file reached during here-document.\n";
		}
	}

	return $hash;
}

sub make_formatted {
	my $hashref = shift;
	my $nocr    = shift;

	my $return;

	for my $key (@KEYS) {
		# print "$key\n";
		if ($key eq "<CR>") {
			unless ($nocr) {
				$return .= "\n";
			}
		} elsif ($key =~ /<N>/) {
			my $index = 0;
			NUMERIC: while (1) {
				$tempkey = $key;
				$tempkey =~ s/<N>/${index}/g;
				if (exists $hashref->{lc($tempkey)}) {
					$return .= make_key($tempkey, $hashref->{lc($tempkey)});
				} else {
					last NUMERIC if ($index > 1);
				}
				$index++;
			}
		} elsif ($key =~ /<S>/) {
			my $prefix = $key;
			$prefix =~ s/<S>//;
			for my $skey (sort keys %{$hashref}) {
				if ($skey =~ /^${prefix}/i) {
					$return .= make_key($skey, $hashref->{lc($skey)});
				}
			}
		} elsif (exists $hashref->{lc($key)}) {
			$return .= make_key($key, $hashref->{lc($key)});
		}
	}

	$return =~ s/\n\n+/\n\n/gs;
	return $return;
}

sub make_key {
	my $key   = shift;
	my $value = shift;

	my $return;

	if ($key =~ /SplitOff/i) {

		my $value_hash = parse_keys($value);
		$value = make_formatted($value_hash, 1);

		$return = $key . ": <<\n";

		my $heredocs = 1;
		my $indent;

		for my $line (split(/\r?\n/, $value)) {
			$line =~ s/^\s*//;
			$indent = "  " x $heredocs;
			if ($line =~ /:\s*<<\s*$/) {
				$heredocs++;
			} elsif ($line =~ /^\s*<<\s*$/) {
				$heredocs--;
				$indent = "  " x $heredocs;
			}
			$return .= $indent . $line . "\n";
		}
		$return .= "<<\n";

	} elsif ($value =~ /\r?\n/) {

		$return = $key . ": <<\n";

		for my $line (split(/\r?\n/, $value)) {
			$return .= $line . "\n";
		}
		$return .= "<<\n";

	} else {

		$return = $key . ": " . $value . "\n";

	}

	return $return;
}
