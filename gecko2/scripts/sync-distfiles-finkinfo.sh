#!/bin/sh
printf 'Running generate-distfiles-and-finkinfo-mirror.pl...\n'
test -f ~fink/infodist/FORCED && mv ~fink/infodist/FORCED{,.old}
test -f ~fink/log/change.log && date -u +%s >~fink/infodist/FORCED && rm -f ~fink/infodist/FORCED.old
~fink/scripts/generate-distfiles-and-finkinfo-mirror.pl
if [ \! -f ~fink/mirwork/mirror.lock ]; then
	printf "\n\n\nLogFile: ~fink/log/mirror.log\n\n"
	grep -ve 'has not changed' -e 'fetching files for' -e 'exists$'  ~fink/log/mirror.log | sed 's/^/| /'
	if [ \! -f ~fink/log/change.log ]; then
		printf '~fink/log/change.log is missing...'
		exit 0
	fi
	if [ "$(grep -e '.info$' -e '.patch$' ~fink/log/change.log)" != "" ]; then
		printf '\nApplying changes in cvs to infodist files:\n'
		cd ~fink/finkinfo/dists.public/10.4
		for tree in stable unstable; do
			if [ "$(grep 10.4/"${tree}"/ ~fink/log/change.log)" != "" ]; then
				printf " Regenerating 10.4-${tree} tarball\n"
				if tar cjph --group 80 --numeric-owner -f ~fink/infodist/10.4-${tree}.tbz.new stable; then
					mv ~fink/infodist/10.4-${tree}.tbz.new ~fink/infodist/10.4-${tree}.tbz
				else
					printf " Regenerating of 10.4-${tree} tarball FAILED!\n"
					exit 0
				fi
				printf " Calculating new checksums for 10.4-"${tree}"\n"
				for check in md5 sha1 sha256; do
					${check}sum ~fink/infodist/10.4-${tree}.tbz | cut -f 1 -d " " >~fink/infodist/10.4-${tree}.tbz.${check}
				done
				printf " Creating symlinks and timestamps for 10.5-"${tree}" and 10.6-"${tree}"\n"
				date -u +%s >~fink/infodist/10.4-${tree}-LOCAL
				for dist in 10.5 10.6; do
					ln -sf 10.4-${tree}.tbz ~fink/infodist/${dist}-${tree}.tbz
					for check in md5 sha1 sha256; do
						ln -sf 10.4-${tree}.tbz.${check} ~fink/infodist/${dist}-${tree}.tbz.${check}
					done
					ln -sf 10.4-${tree}-LOCAL ~fink/infodist/${dist}-${tree}-LOCAL
				done
			fi
		done
	else
		printf '\nNo changes to infodist needed\n'
	fi
	printf ' Getting TIMESTAMP\n'
	cp -p ~fink/finkinfo/dists.public/TIMESTAMP ~fink/infodist/TIMESTAMP
	printf ' Cleaning up\n'
	rm -f ~fink/log/change.log
	printf 'done\n'
fi
