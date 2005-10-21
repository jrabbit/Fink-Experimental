#!/bin/sh -e

INFOFILE=${INFOFILE:-openoffice.org.info}
TMPFILE=`/usr/bin/mktemp /tmp/\`basename $0\`.XX`

hosts=$(/usr/bin/sed -n 's/.*\(...\)-\(..\): \(.*\)$/[\1-\2],\3/p' ${INFOFILE})
version=`/usr/bin/sed -n -e 's/^Version: \(.*\)$/\1/p' "$INFOFILE"`
source=`/usr/bin/sed -n -e "s/%v/$version/g" -e 's/^Source: mirror:custom:\(.*\)$/\1/p' "$INFOFILE"`

for host in ${hosts[*]}; do
  area=`echo $host | /usr/bin/cut -d, -f1`
  url=`echo $host | /usr/bin/cut -d, -f2`
  outputfile=`/usr/bin/mktemp "${TMPFILE}"XXX`
  echo $outputfile >> "${TMPFILE}"
  echo "${area} ${url}" >"$outputfile"
  /usr/bin/curl -fILsS "${url}${source}" >>"$outputfile" 2>&1 &
done

wait

for file in `/bin/cat "${TMPFILE}"`; do
  /bin/cat "$file"
  echo
  /bin/rm "$file"
done

/bin/rm "${TMPFILE}"