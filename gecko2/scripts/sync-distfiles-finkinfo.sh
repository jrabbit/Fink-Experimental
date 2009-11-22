#!/bin/sh
###
# Change this to match your local mirror structur
###
GENERATEDIR="/home/f/fink/finkinfo"
HTTPSNAPDIR="/home/f/fink/infodist"
LOGDIR="/home/f/fink/log"
SCRIPTDIR="/home/f/fink/scripts"
TMPDIR="/home/f/fink/mirwork"

###
# Change NOTHING below this line
###
printf 'Running generate-distfiles-and-finkinfo-mirror.pl...\n'
if [ -s ${TMPDIR}/mirror.lock ]; then
	printf "MIRROR locked... existing\n"
	exit 1
fi
${SCRIPTDIR}/generate-distfiles-and-finkinfo-mirror.pl
test -s ${HTTPSNAPDIR}/FORCED && mv ${HTTPSNAPDIR}/FORCED{,.old}
test -f ${TMPDIR}/FORCE && test -f ${LOGDIR}/change.log && date -u +%s >${HTTPSNAPDIR}/FORCED && rm -f ${HTTPSNAPDIR}/FORCED.old
if [ \! -s ${TMPDIR}/mirror.lock ]; then
	printf "\n\n\nLogFile: "${LOGDIR}"/mirror.log\n\n"
	grep -ve 'has not changed' -e 'fetching files for' -e 'exists$' ${LOGDIR}/mirror.log | sed 's/^/| /'
	if [ \! -f ${LOGDIR}/change.log ]; then
		printf ${LOGDIR}'/change.log is missing...\n'
		exit 1
	fi
	if [ -s ${HTTPSNAPDIR}/FORCED ];then
		echo "10.4/stable/main/foo.info" >${LOGDIR}/change.log
		echo "10.4/stable/crypto/foo.info" >>${LOGDIR}/change.log
		echo "10.4/unstable/main/foo.info" >>${LOGDIR}/change.log
		echo "10.4/unstable/crypto/foo.info" >>${LOGDIR}/log/change.log
		rm -f ${TMPDIR}/FORCE
	fi
	if [ "$(grep -e '.info$' -e '.patch$' "${LOGDIR}"/change.log)" != "" ]; then
		test -s ${HTTPSNAPDIR}/FORCED && printf '\nFORCING HTTPSNAP REBUILD!\n'
		printf '\nApplying changes in cvs to httpsnap files:\n'
		cd ${GENERATEDIR}/dists.public/10.4
		for release in stable unstable; do
			for tree in main crypto; do
				if [ "$(grep 10.4/"${release}"/"${tree}" "${LOGDIR}"/change.log)" != "" ]; then
					printf " Regenerating 10.4-"${release}"-"${tree}" tarball\n"
					if tar cjph --group 80 --numeric-owner -f ${HTTPSNAPDIR}/10.4-${release}-${tree}.tbz.new ${release}/${tree}; then
						mv ${HTTPSNAPDIR}/10.4-${release}-${tree}.tbz.new ${HTTPSNAPDIR}/10.4-${release}-${tree}.tbz
					else
						printf " Regenerating of 10.4-"${release}"-"${tree}" tarball FAILED\!\n"
						exit 0
					fi
					printf " Calculating new checksums for 10.4-"${release}"-"${tree}"\n"
					for check in md5 sha1 sha256; do
						${check}sum ${HTTPSNAPDIR}/10.4-${release}-${tree}.tbz | cut -f 1 -d " " >${HTTPSNAPDIR}/10.4-${release}-${tree}.tbz.${check}
					done
					printf " Creating symlinks and timestamps for 10.5-"${release}"-"${tree}" and 10.6-"${release}"-"${tree}"\n"
					date -u +%s >${HTTPSNAPDIR}/10.4-${release}-${tree}-TIMESTAMP
					for dist in 10.5 10.6; do
						ln -sf 10.4-${release}-${tree}.tbz ${HTTPSNAPDIR}/${dist}-${release}-${tree}.tbz
						for check in md5 sha1 sha256; do
							ln -sf 10.4-${release}-${tree}.tbz.${check} ${HTTPSNAPDIR}/${dist}-${release}-${tree}.tbz.${check}
						done
						ln -sf 10.4-${release}-${tree}-TIMESTAMP ${HTTPSNAPDIR}/${dist}-${release}-${tree}-TIMESTAMP
					done
				fi
			done
		done
	else
		printf '\nNo changes to httpsnap needed\n'
	fi
	printf ' Getting TIMESTAMP\n'
	cp -p ${GENERATEDIR}/dists.public/TIMESTAMP ${HTTPSNAPDIR}/TIMESTAMP
	printf ' Cleaning up\n'
	rm -f ${LOGDIR}/change.log
	printf 'done\n'
fi
