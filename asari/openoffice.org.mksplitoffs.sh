#!/bin/sh

LANGS="af ar be-BY bg bn ca cs cy da de el en-GB eo es et eu fi fr ga gl gu-IN he hi-IN hr hu it ja km kn-IN ko lo lt ms nb ne nl nn nr ns pa-IN pl pt pt-BR ru rw sh-YU sk sl sr-CS ss st sv sw-TZ ta-IN th tn tr ts ve vi xh zh-CN zh-TW zu"

nLangs=`echo $LANGS | wc -w`

for i in `jot $nLangs 1 $nLangs`; do
   LANG=`echo $LANGS | cut -d" " -f "$i"`
   LANG_LOWERCASE=`echo $LANG | tr "[:upper:]" "[:lower:]"`
   if [ $i == 1 ]; then
      sed -e "s/@LANG@/$LANG/g" -e "s/@LANG_LOWERCASE@/$LANG_LOWERCASE/g" openoffice.org.splitoff.in
   else
      sed -e "s/@LANG@/$LANG/g" -e "s/@LANG_LOWERCASE@/$LANG_LOWERCASE/g" \
        -e "s/SplitOff:/SplitOff${i}:/"  openoffice.org.splitoff.in
   fi
done
