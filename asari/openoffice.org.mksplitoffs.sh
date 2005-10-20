#!/bin/sh

LANGS="af ar bg ca cs cy da de el en-GB eo es et eu fi fr gl he hi-IN hu it ja km kn-IN ko lt ms nb nl nn ns pl pt pt-BR ru sk sl sv th tn tr xh zh-CN zh-TW zu"

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