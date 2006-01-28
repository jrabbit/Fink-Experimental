divert(-1)
changequote([, ])
dnl $Id$
dnl Usage: m4 -B32768 -S200 -DTREE=xxx [-DMODE=DumpMirrors|DumpSnapshotMirrors] openoffice.org.info.m4

dnl ### Configurations ###
define([BASEVERSION], [[2.0.1]])
define([SNAPSHOT], [[m152]])
define([SOURCE_MD5], [[de893aa3bbd15022089abafbd8a2e623]])
define([TREE_TO_REVISION],
  [[[10.3], [1]], [[10.4-transitional], [101]], [[10.4], [201]]])
define([REVISION_SUFFIX],[])
ifdef([USE_FINK_PYTHON],,
 [define([USE_FINK_PYTHON], 1)])
define([RELEASE_SOURCE], [[stable/%v/OOo_%v_src.tar.gz]])
define([SNAPSHOT_SOURCE], [[OOo_SRC680_]SNAPSHOT[_source.tar.bz2]])

define([LANGUAGES], [[af], [ar], [be-BY], [bg], [bn], [bn-BD],
 [bn-IN], [br], [bs], [ca], [cs], [cy], [da], [de], [el], [en-GB],
 [en-ZA], [eo], [es], [et], [eu], [fi], [fr], [ga], [gl], [gu-IN],
 [he], [hi-IN], [hr], [hu], [it], [ja], [km], [kn-IN], [ko], [lo],
 [lt], [lv], [mk], [ms], [nb], [ne], [nl], [nn], [nr], [ns],
 [pa-IN], [pl], [pt], [pt-BR], [ru], [rw], [sh-YU], [sk], [sl],
 [sr-CS], [ss], [st], [sv], [sw], [sw-TZ], [sx], [ta-IN], [th],
 [tn], [tr], [ts], [ve], [vi], [xh], [zh-CN], [zh-TW], [zu]])

define([RELEASE_MIRRORS], [
 [0, [aus-AU], [http://openoffice.mirrors.ilisys.com.au/]],
 [1, [aus-AU], [ftp://mirror.pacific.net.au/OpenOffice/]],
 [0, [aus-AU], [http://mirror.pacific.net.au/openoffice/]],
 [1, [aus-AU], [ftp://ftp.planetmirror.com/pub/openoffice/]],
 [1, [aus-AU], [http://public.planetmirror.com/pub/openoffice/]],
 [1, [eur-AT], [http://gd.tuwien.ac.at/office/openoffice/]],
 [1, [eur-AT], [ftp://gd.tuwien.ac.at/office/openoffice/]],
 [1, [eur-BE], [http://ftp.belnet.be/pub/mirror/ftp.openoffice.org/]],
 [1, [eur-BE], [ftp://ftp.scarlet.be/pub/openoffice/]],
 [1, [eur-BE], [http://ftp.scarlet.be/pub/openoffice/]],
 [1, [eur-BE], [ftp://ftp.openoffice.skynet.be/pub/ftp.openoffice.org/]],
 [1, [eur-BE], [ftp://ftp.kulnet.kuleuven.ac.be/pub/mirror/openoffice.org/]],
 [1, [sam-BR], [http://linorg.usp.br/OpenOffice.org/]],
 [1, [sam-BR], [ftp://ftp.pucpr.br/openoffice/]],
 [1, [eur-BG], [http://ftp.spnet.net/openoffice/]],
 [1, [eur-BG], [ftp://ftp.spnet.net/openoffice/]],
 [1, [nam-CA], [ftp://openoffice.mirror.rafal.ca/openoffice/]],
 [1, [nam-CA], [http://openoffice.mirror.rafal.ca/]],
 [1, [nam-CA], [http://gulus.USherbrooke.ca/pub/appl/openoffice/]],
 [1, [eur-CZ], [http://ftp.sh.cvut.cz/MIRRORS/OpenOffice/]],
 [1, [eur-CZ], [ftp://ftp.sh.cvut.cz/MIRRORS/OpenOffice/]],
 [1, [eur-DK], [http://mirrors.dotsrc.org/openoffice/]],
 [1, [eur-DK], [ftp://mirrors.dotsrc.org/openoffice/]],
 [1, [eur-EE], [http://openoffice.offline.ee/]],
 [1, [eur-FI], [ftp://ftp.funet.fi/pub/mirrors/openoffice.org/]],
 [0, [eur-FR], [ftp://openoffice.cict.fr/openoffice/]],
 [1, [eur-FR], [ftp://ftp.free.fr/mirrors/ftp.openoffice.org/]],
 [1, [eur-DE], [ftp://ftp.tu-chemnitz.de/pub/openoffice/]],
 [1, [eur-DE], [ftp://ftp.gwdg.de/pub/misc/openoffice/]],
 [1, [eur-DE], [ftp://sunsite.informatik.rwth-aachen.de/pub/mirror/OpenOffice/]],
 [1, [eur-DE], [ftp://ftp.leo.org/pub/openoffice/]],
 [1, [eur-DE], [http://ftp.leo.org/pub/openoffice/]],
 [1, [eur-DE], [ftp://ftp.uni-muenster.de/pub/software/OpenOffice/]],
 [1, [eur-DE], [ftp://openoffice.tu-bs.de/OpenOffice.org/]],
 [1, [eur-DE], [ftp://ftp.stardiv.de/pub/OpenOffice.org/]],
 [1, [eur-DE], [http://ftp.stardiv.de/pub/OpenOffice.org/]],
 [1, [eur-DE], [ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.openoffice.org/]],
 [1, [eur-DE], [http://mirror.xaranet.de/openoffice/]],
 [1, [eur-GR], [http://www.ellak.gr/pub/openoffice/]],
 [1, [eur-GR], [http://ftp.ntua.gr/pub/OpenOffice/]],
 [1, [eur-GR], [ftp://ftp.ntua.gr/pub/OpenOffice/]],
 [1, [eur-HU], [http://ftp.fsf.hu/OpenOffice.org/]],
 [1, [eur-HU], [ftp://ftp.fsf.hu/OpenOffice.org/]],
 [1, [eur-IS], [ftp://ftp.rhnet.is/pub/OpenOffice/]],
 [1, [eur-IS], [http://ftp.rhnet.is/pub/OpenOffice/]],
 [1, [asi-ID], [http://openoffice.ugm.ac.id/]],
 [1, [asi-ID], [ftp://kambing.vlsm.org/openoffice/]],
 [1, [asi-ID], [http://kambing.vlsm.org/openoffice/]],
 [1, [eur-IE], [ftp://ftp.heanet.ie/mirrors/openoffice.org/]],
 [1, [eur-IE], [http://ftp.heanet.ie/mirrors/openoffice.org/]],
 [1, [eur-IT], [ftp://na.mirror.garr.it/mirrors/openoffice/]],
 [1, [eur-IT], [http://na.mirror.garr.it/mirrors/openoffice/]],
 [1, [asi-JP], [ftp://ftp.kddlabs.co.jp/office/openoffice/]],
 [0, [asi-JP], [ftp://ftp.ring.gr.jp/pub/misc/openoffice/]],
 [1, [asi-JP], [http://www.ring.gr.jp/archives/misc/openoffice/]],
 [1, [asi-JP], [ftp://ftp.yz.yamagata-u.ac.jp/pub/openoffice/]],
 [1, [asi-JP], [http://ftp.yz.yamagata-u.ac.jp/pub/openoffice/]],
 [1, [eur-LT], [ftp://files.akl.lt/OpenOffice.org/]],
 [1, [eur-LT], [http://files.akl.lt/OpenOffice.org/]],
 [0, [asi-MY], [http://mymirror.asiaosc.org/openoffice/]],
 [1, [eur-NL], [ftp://ftp.nluug.nl/pub/office/openoffice/]],
 [1, [eur-NL], [http://ftp.nluug.nl/pub/office/openoffice/]],
 [1, [eur-NL], [ftp://ftp.snt.utwente.nl/pub/software/openoffice/]],
 [1, [eur-NL], [ftp://borft.student.utwente.nl/]],
 [1, [eur-NL], [http://borft.student.utwente.nl/openoffice/]],
 [1, [eur-NL], [ftp://niihau.student.utwente.nl/]],
 [1, [eur-NL], [http://vlaai.snt.utwente.nl/pub/software/openoffice/]],
 [1, [eur-PL], [ftp://ftp.man.poznan.pl/pub/openoffice/]],
 [1, [eur-PL], [ftp://ftp.openoffice.pl/OpenOffice.ORG/]],
 [1, [eur-PL], [ftp://ftp.tpnet.pl/d9/OpenOffice/]],
 [1, [eur-PL], [http://ftp.tpnet.pl/vol/d9/OpenOffice/]],
 [0, [eur-PT], [http://ftpdem.ubi.pt/OpenOffice]],
 [0, [eur-PT], [http://mirrors.oninet.pt/openoffice/]],
 [0, [eur-PT], [http://tux.cprm.net/pub/openoffice.org/]],
 [0, [eur-PT], [ftp://tux.cprm.net/pub/openoffice.org/]],
 [1, [eur-RO], [ftp://ftp.iasi.roedu.net/pub/mirrors/openoffice.org/]],
 [1, [eur-RO], [http://ftp.iasi.roedu.net/mirrors/openoffice.org/]],
 [1, [eur-RO], [ftp://mirrors.evolva.ro/openoffice.org/]],
 [1, [eur-RO], [ftp://ftp.idilis.ro/mirrors/openoffice.org/]],
 [1, [eur-RO], [http://ftp.idilis.ro/mirrors/openoffice.org/]],
 [1, [eur-RU], [ftp://ftp.chg.ru/pub/OpenOffice/]],
 [1, [eur-RU], [http://ftp.chg.ru/pub/OpenOffice/]],
 [1, [eur-YU], [ftp://mirror.etf.bg.ac.yu/openoffice.org/]],
 [1, [eur-YU], [http://mirror.etf.bg.ac.yu/openoffice/]],
 [1, [asi-SG], [ftp://mirror.averse.net/pub/openoffice/]],
 [1, [asi-SG], [http://mirror.averse.net/openoffice/]],
 [1, [eur-SI], [ftp://ftp.bevc.net/mirrors/openoffice/]],
 [1, [eur-SI], [http://mirrors.bevc.net/openoffice/]],
 [0, [eur-SI], [http://www.wsection.com/openoffice/]],
 [1, [afr-ZA], [ftp://ftp.is.co.za/mirrors/OpenOffice/]],
 [1, [asi-KR], [ftp://ftp.kr.freebsd.org/pub/openoffice/]],
 [1, [eur-ES], [http://ftp.rediris.es/ftp/mirror/openoffice.org/]],
 [1, [eur-ES], [ftp://ftp.rediris.es/mirror/openoffice.org/]],
 [1, [eur-SE], [http://ftp.sunet.se/pub/Office/OpenOffice.org/]],
 [0, [eur-CH], [ftp://ftp.solnet.ch/mirror/OpenOffice/]],
 [1, [eur-CH], [ftp://sunsite.cnlab-switch.ch/mirror/OpenOffice/]],
 [1, [eur-CH], [http://mirror.switch.ch/ftp/mirror/OpenOffice/]],
 [1, [eur-CH], [ftp://mirror.switch.ch/mirror/OpenOffice/]],
 [1, [asi-TW], [ftp://ftp.isu.edu.tw/pub/OpenOffice/]],
 [1, [asi-TW], [http://ftp.isu.edu.tw/pub/OpenOffice/]],
 [1, [asi-TW], [ftp://ftp.nctu.edu.tw/UNIX/OpenOffice/]],
 [1, [eur-UK], [ftp://ftp.mirrorservice.org/sites/ny1.mirror.openoffice.org/]],
 [1, [eur-UK], [http://www.mirrorservice.org/sites/ny1.mirror.openoffice.org/]],
 [0, [eur-UK], [ftp://mirrors.blueyonder.co.uk/sites/openoffice.org]],
 [1, [eur-UK], [http://openoffice.blueyonder.co.uk/]],
 [1, [eur-UK], [ftp://ftp.mirror.ac.uk/mirror/sunsite.dk/openoffice/]],
 [1, [eur-UK], [http://www.mirror.ac.uk/mirror/sunsite.dk/openoffice/]],
 [0, [nam-US], [http://openoffice.collab.net/]],
 [1, [nam-US], [ftp://ftp.osuosl.org/pub/openoffice/]],
 [1, [nam-US], [http://ftp.osuosl.org/pub/openoffice/]],
 [0, [nam-US], [http://www.binarycode.org/openoffice/]],
 [1, [nam-US], [http://mirrors.ibiblio.org/pub/mirrors/openoffice/]],
 [1, [nam-US], [ftp://ftp.ibiblio.org/pub/mirrors/openoffice/]],
 [1, [nam-US], [ftp://ftp.ussg.iu.edu/pub/openoffice/]],
 [1, [nam-US], [http://mirrors.isc.org/pub/openoffice/]],
 [0, [nam-US], [http://www.online-mirror.org/openoffice/]],
 [1, [nam-US], [ftp://openoffice.mirrors.pair.com/]],
 [1, [nam-US], [http://openoffice.mirrors.pair.com/ftp/]],
 [1, [nam-US], [ftp://openofficeorg.secsup.org/pub/software/openoffice/]],
 [1, [nam-US], [http://openofficeorg.secsup.org/]],
 [1, [nam-US], [http://openoffice.mirror.wrpn.net/]],
 [1, [nam-US], [ftp://openoffice.mirrors.tds.net/pub/openoffice/]],
 [1, [nam-US], [http://openoffice.mirrors.tds.net/pub/openoffice/]],
 [0, [nam-US], [http://mirrors.wehost4u.net/openoffice/]]])

define([SNAPSHOT_MIRRORS], [
 [1, [asi-JP], [http://www.sodan.ecc.u-tokyo.ac.jp/~shinra/distfiles/]],
 [1, [asi-JP], [http://www.j10n.org/files/]],
 [1, [Primary], [ftp://ooopackages.good-day.net/pub/OpenOffice.org/sources/]]])

dnl ### Macro Library ###
dnl Replace uppercases of $1 to lowercases.
define([TOLOWER], [translit([$1], [ABCDEFGHIJKLMNOPQRSTUVWXYZ], [abcdefghijklmnopqrstuvwxyz])])

dnl Returns *quoted* newline.
define([NEWLINE], [[
]])

dnl Usage: EQ_ANY([Query], [Str], [Str], ...)
dnl Returns 1 if one of $2... equals to $1, 0 otherwise.
define([EQ_ANY], [ifelse($#, 0, 0, $#, 1, 0,
 [$1], [$2], 1, $#, 2, 0,
 [EQ_ANY([$1], shift(shift($@)))])])

dnl Print a error message $1 and exit.
define([ERREXIT], [errprint([$1]NEWLINE)m4exit(1)])

dnl Usage: ALIST_GET([Query], [[Key], [Value]], [[Key], [Value]], ...)
dnl Returns [1, [Value]] if found, 0 otherwise.
define([ALIST_GET], [ifelse($#, 0, [0], $#, 1, [0],
 [$1], FIRST($2), [1, SECOND($2)], $#, 2, [0],
 [ALIST_GET([$1], shift(shift($@)))])])
define([FIRST], [[$1]])
define([SECOND], [[$2]])

dnl Evaluate $2 only once and define $1 to it.
define([DEFINE_LAZILY], [define([$1], [define([$1], QUOTE($2))$1])])
define([QUOTE], [ifelse($#, 1, [[[$1]]], [ERREXIT([Bad quoting])])])

dnl ### Other Macros ###
ifdef([SNAPSHOT],
 [define([FINKVERSION], [BASEVERSION+SNAPSHOT])
  define([SOURCE], [SNAPSHOT_SOURCE])
  define([MIRRORS], [SNAPSHOT_MIRRORS])],
 [define([FINKVERSION], [BASEVERSION])
  define([SOURCE], [RELEASE_SOURCE])
  define([MIRRORS], [RELEASE_MIRRORS])])

define([MAKE_REVISION], [ifelse([$1], 0, [ERREXIT([Wrong TREE])], [[$2]])])
DEFINE_LAZILY([REVISION],
 [ifdef([TREE], [MAKE_REVISION(ALIST_GET(TREE, TREE_TO_REVISION))],
   [ERREXIT([You must define the TREE])])])

define([LANGUAGEPACK_SPLITOFF],[ifelse([$2],,,
[ifelse($1,1,SplitOff,SplitOff$1)[: <<
  Package: %N-]TOLOWER([[$2]])[
  Description: Language Pack($2) for OpenOffice.org
  Depends: %N (= %v-%r)
  InstallScript: ./languagepack-splitoff ]TOLOWER([[$2]])[ $2 %p %d %i
<<]

LANGUAGEPACK_SPLITOFF(incr($1),shift(shift($@)))dnl
])])

define([CUSTOM_MIRRORS], [ifelse([$1],,,
[CUSTOM_MIRRORS_SUBR($1)
CUSTOM_MIRRORS(shift($@))dnl
])])
define([CUSTOM_MIRRORS_SUBR], [ifelse($1,0,[[#]])[$2: $3]])

define([DUMP_MIRRORS], [ifelse([$1],,,
[DUMP_MIRRORS_SUBR($1)
DUMP_MIRRORS(shift($@))dnl
])])
define([DUMP_MIRRORS_SUBR], [[$1 $2 $3]])

dnl ### Run Commands ###
ifdef([MODE],
 [ifelse(
   MODE, [DumpMirrors],
[divert(0)BASEVERSION RELEASE_SOURCE
DUMP_MIRRORS(RELEASE_MIRRORS)m4exit(0)],

   MODE, [DumpSnapshotMirrors],
[divert(0)FINKVERSION SNAPSHOT_SOURCE
DUMP_MIRRORS(SNAPSHOT_MIRRORS)m4exit(0)],

   [ERREXIT([Bad mode specified])])],
 [divert(0)])dnl
dnl
dnl ### Body ###
[Package: openoffice.org
Description: Integrated office productivity suite
Version: ]FINKVERSION[
Revision: ]REVISION[]REVISION_SUFFIX[
License: LGPL
Maintainer: Todai Fink Team <fink@sodan.ecc.u-tokyo.ac.jp>

BuildConflicts: libicu32-dev
BuildDepends: <<
  x11-dev, ant, bison, fileutils, system-java14-dev,
  archive-zip-pm586,
  libjpeg, expat, freetype219, libwpd-0.8-dev, libxml2,
  db42-ssl | db42,
  libsablot-dev, libsablot, unixodbc2 | unixodbc2-nox,
  sane-backends, libcurl3-unified,
  libsndfile1-dev,
  portaudio (>= 18.1-1), neon24-ssl | neon24,
  mozilla-dev, libart2, startup-notification-dev,
  atk1, audiofile, esound, gconf2-dev, libgettext3-dev, glib2-dev,
  gnome-keyring-dev (>= 0.4.3-1), gnome-vfs2-ssl-dev | gnome-vfs2-dev,
  gtk+2-dev, libbonobo2-dev, libbonoboui2-dev, libglade2,
  libgnome2-dev, libgnomecanvas2-dev, libgnomeprint2.2-dev,
  libgnomeprintui2.2-dev, libgnomeui2-dev, libiconv-dev, 
  orbit2-dev, pango1-xft2-dev, pcre, pkgconfig, popt, vte-dev, 
  ]ifelse(USE_FINK_PYTHON, 1, [boost1.32-py24, python24],
    [boost1.32-py23 | boost1.32-py24])[,
  autoconf2.5
<<

Depends: <<
  x11, system-java14, system-perl,
  libjpeg-shlibs, expat-shlibs, libwpd-0.8-shlibs, libxml2-shlibs,
  db42-ssl-shlibs | db42-shlibs, db42-ssl-java,
  libsablot-shlibs, unixodbc2-shlibs | unixodbc2-nox-shlibs,
  sane-backends-shlibs, libcurl3-unified-shlibs,
  libsndfile1-shlibs,
  portaudio-shlibs (>= 18.1-1), neon24-ssl-shlibs | neon24-shlibs,
  mozilla-shlibs, mozilla-mailnews, libart2-shlibs,
  ]ifelse(USE_FINK_PYTHON, 1, [[python24-shlibs,
  ]])[fondu, startup-notification-shlibs
<<

CustomMirror: <<]
CUSTOM_MIRRORS(MIRRORS)dnl
[<<
Source: mirror:custom:]SOURCE[
Source-MD5: ]SOURCE_MD5[
NoSourceDirectory: true

PatchScript: <<
  /usr/bin/patch -p0 < %a/%n.patch
  chmod a+x languagepack-splitoff
<<

SetCPPFLAGS: -I%p/include/db4 -I%p/include/boost
ConfigureParams: <<
  --with-gnu-cp=%p/bin/cp \
  --disable-epm \
  --with-lang=ALL \
  --with-x --x-includes=/usr/X11R6/include --x-libraries=/usr/X11R6/lib \
  --with-jdk-home=/Library/Java/Home --with-ant-home=%p/lib/ant \
  --disable-crashdump \
  --with-build-version="%v-%r; Built with Fink <http://fink.sourceforge.net>" \
  --enable-libart \
  --enable-pasf \
  --with-system-db \
  --with-db-jar=%p/share/java/db42-ssl-java/db.jar \
  --with-system-libwpd \
  --with-system-sablot \
  --with-system-odbc-headers \
  --with-system-sane-header \
  --with-system-xrender-headers \
  --with-system-curl \
  --with-system-sndfile \
  --with-system-portaudio \
  --with-system-neon \
  --with-system-stdlibs \
  --with-system-zlib \
  --with-system-jpeg \
  --with-system-expat \
  --with-system-mozilla \
  --enable-gtk \
  --with-system-freetype \
  --with-system-boost \
  --without-nas \
  --with-system-libxml \
  --with-system-python \]
ifelse(USE_FINK_PYTHON, 1,
[[  --with-python-libs="-L%p/lib/python2.4/config -lpython2.4" \]]NEWLINE)dnl
[  --enable-libsn
<<
]
ifelse(EQ_ANY(TREE, [10.3], [10.4-transitional]), 1,
[[GCC: 3.3
SetCC: gcc-3.3
SetCXX: g++-3.3]],
[[GCC: 4.0
SetCC: gcc-4.0
SetCXX: g++-4.0]])
[CompileScript: <<
  #!/bin/bash

  set -e

  echo "[ Message from OpenOffice.org package maintainer ] ================="
  echo
  echo "Welcome to OpenOffice.org build script!"
  echo
  echo "Notice for builders:"
  echo
  echo "1. This building process may take a couple of day or more,"
  echo "   and often fails with errors."
  echo "2. This building process may consume much of your disk space,"
  echo "   possibly up to 10GB."
  echo "3. This building process needs your own WindowServer process."
  echo "   i.e, it is not possible to build through simple SSH connection."
  echo "   This is because the building process uses /usr/bin/osacompile ."
  echo "   (This limitation would be removed in the future release.)"
  echo
  echo "If you faced a building problem, feel free to mail the maintainer,"
  echo "preferably with your environment (gcc's version, etc.) and"
  echo "the build log."
  echo "You can find the logs here:"
  echo "   %b/%n-%v-%r.buildlog"
  echo
  echo "The mail address is: Todai Fink Team <fink@sodan.ecc.u-tokyo.ac.jp>"
  echo
  echo "Please understand this Fink package is still unstable."
  echo
  echo "===================================================================="
  echo
  echo "If you are ready, press RETURN/ENTER to proceed..."

  read -t 60 || true

  echo

  # Record the time
  STARTTIME=`/bin/date +"%%F %%T %%Z(%%z)"`

  set -v

  # $X_LDFLAGS is needed to configure with X correctly.  
  export X_LDFLAGS=$LDFLAGS

  # $PKG_CONFIG_PATH is needed to configure with freetype219
  export PKG_CONFIG_PATH=%p/lib/freetype219/lib/pkgconfig
]
ifelse(USE_FINK_PYTHON, 1,
[[  # $PYTHON is needed to configure with python24
  export PYTHON=%p/bin/python2.4]],
[[  # $PYTHON is needed to configure with the Darwin's python
  export PYTHON=/usr/bin/python]])
[
  /usr/bin/printf "[ Phase 1: Configure ]\n\n" >> %n-%v-%r.buildlog
  (cd config_office && autoconf && ./configure %c) 2>&1 |
    /usr/bin/tee -ai %n-%v-%r.buildlog

  /usr/bin/printf "\n\n[ Phase 2: Bootstrap ]\n\n" >> %n-%v-%r.buildlog
  ./bootstrap 2>&1 |
    /usr/bin/tee -ai %n-%v-%r.buildlog

  # Because we are using %p, $SOLARINC and $SOLARLIB need modified  
  # Include libdb_java-4.2.jnilib to DYLD_LIBRARY_PATH so that Java can find it
  /usr/bin/sed -i.bak \
    -e"/^SOLARLIB/s|-L/usr/lib|-L%p/lib/freetype219/lib -L%p/lib -L/usr/lib|" \
    -e"/^SOLARINC/s|-I/usr/X11R6/include -I/usr/X11R6/include/freetype2|-I%p/include/db4 -I%p/lib/freetype219/include/freetype2 -I%p/lib/freetype219/include -I%p/include -I/usr/X1186/include|" \
    -e"/^DYLD_LIBRARY_PATH/s|/lib|/lib:%b/FINKLIBS|" \
    MacosxEnv.Set MacosxEnv.Set.sh

  /bin/mkdir FINKLIBS
  /bin/ln -s %p/lib/libdb_java-4.2.jnilib FINKLIBS

  # Retry forever to build OOo until success!
  until [ -n "$succeeded" ]; do
    /usr/bin/printf "\n\n[ Phase 3: Make ]\n\n" >> %n-%v-%r.buildlog
    . ./MacosxEnv.Set.sh
    dmake 2>&1 | /usr/bin/tee -ai %n-%v-%r.buildlog
    if [ ${PIPESTATUS[0]} == 0 ]; then
      succeeded=TRUE
      continue
    fi
    echo
    echo "[ Message from OpenOffice.org package maintainer ] ================="
    echo
    echo "Building OpenOffice.org faild with an error."
    echo "Now you can get rid of the cause by hand, or call for help."
    echo "The build directory is:"
    echo "  %b"
    echo "and the full log file is available here:"
    echo "  %b/%n-%v-%r.buildlog"
    echo
    echo "===================================================================="
    echo
    echo "Press RETURN/ENTER to exit or input any key to restart dmake..."
    read input
    [ -n "$input" ] || false
  done

  set +v

  /usr/bin/printf "\n\n[ Phase 4: Statistics ]\n\n" >> %n-%v-%r.buildlog
  echo
  echo "[ Message from OpenOffice.org package maintainer ] ================="
  echo
  echo "Congratulations!"
  echo "The building process of OpenOffice.org has completed!"
  echo "   Started:   $STARTTIME" | /usr/bin/tee -ai %n-%v-%r.buildlog

  ENDTIME=`/bin/date +"%%F %%T %%Z(%%z)"`

  echo "   Completed: $ENDTIME"   | /usr/bin/tee -ai %n-%v-%r.buildlog

  DISKUSAGE=`/usr/bin/du -sh %b | /usr/bin/cut -f1`

  echo "   $DISKUSAGE is used for this building process (not including tarball)." | /usr/bin/tee -ai %n-%v-%r.buildlog
  echo
  echo "===================================================================="
<<

InstallScript: <<
  #!/bin/bash

  set  -e

  # Mainly, this InstallScript is derived from
  # "ooinstall" in ooo-build and instsetoo_native/util/makefile.mk

  /usr/bin/printf "\n\n[ Install Phase ]\n\n"

  # Setting up environment
  . ./MacosxEnv.Set.sh

  set -v

  # Variables needed to execute make_installer.pl
  export OUT="../$INPATH"
  export LOCAL_OUT="$OUT"
  export LOCAL_COMMON_OUT="$OUT"
  solarlibdir=$SOLARVER/$UPD/$INPATH/lib
  export PYTHONPATH=$SRC_ROOT/instsetoo_native/$INPATH/bin:$solarlibdir:$solarlibdir/python:$solarlibdir/python/lib-dynload
  build=`sed -n 's/^BUILD=\(.*\)$/\1/p' $SOLARENVINC/minor.mk`

  # Some dirty hacks to reduce disk consumption

  # Force make_installer.pl to use ln instead of cp
  /usr/bin/sed -i .bak 's|cp -af|/bin/ln -f|' \
    $SOLARENV/bin/modules/installer/worker.pm
  # Disable making download installation set  
  /usr/bin/sed -i .bak 's/$makedownload = .;/$makedownload = 0;/' \
    $SOLARENV/bin/modules/installer/globals.pm
  # Disable cleaning output tree, to reuse unzipped files
  /usr/bin/sed 's/installer::worker::clean_output_tree();/# Disabled by Fink; /' \
    $SOLARENV/bin/make_installer.pl > $SOLARENV/bin/make_installer-noclean.pl

  # Install
  pushd instsetoo_native/util
  /usr/bin/perl -w $SOLARENV/bin/make_installer-noclean.pl \
    -f openoffice.lst -l en-US -p OpenOffice \
    -packagelist ../inc_openoffice/unix/packagelist.txt \
    -buildid $build -destdir %d \
    -simple %p/lib/openoffice.org
  popd

  # Some dirty hacks to reduce disk consumption -- again

  # Don't recurse in symlinks on cleaning
  /usr/bin/sed -i .bak 's/-f $item/( -l $item ) || ( -f $item )/' \
    $SOLARENV/bin/modules/installer/systemactions.pm
  # Surpress further unzipping from now on
  /usr/bin/sed -i .bak \
    -e 's|\(.installer::globals::unzippath -o -q[^"]*\)|if [ -d %b/instsetoo_native/util/OpenOffice/zipfiles/en-US/00/$onefilename ]; then /bin/rmdir $unzipdir; /bin/ln -s %b/instsetoo_native/util/OpenOffice/zipfiles/en-US/00/$onefilename `/usr/bin/dirname ${unzipdir}foo`; elif [ -d %b/instsetoo_native/util/OpenOffice/zipfiles/en-US/en-US/$onefilename ]; then /bin/rmdir $unzipdir; /bin/ln -s %b/instsetoo_native/util/OpenOffice/zipfiles/en-US/en-US/$onefilename `/usr/bin/dirname ${unzipdir}foo`; else \1; fi|' \
    -e 's/installer::systemactions::copy_one_file/installer::systemactions::hardlink_one_file/' \
    $SOLARENV/bin/modules/installer/archivefiles.pm

  # Remove the list files
  /bin/rm -v %d/gid_Module*
]
ifelse(USE_FINK_PYTHON, 0,
[[  # Install pyuno
  # -- derived from the post-install script of openoffice.org-pyuno.install
  /bin/rm -f %i/lib/%n/program/python-core %i/lib/%n/program/python
  /bin/ln -s python-core-2.3.4 %i/lib/%n/program/python-core
  /bin/ln -s python.sh %i/lib/%n/program/python
  /bin/chmod +x %i/lib/%n/program/python-core-2.3.4/bin/python
]])dnl
[  # Convenience symlinks
  /usr/bin/install -m 755 -d %i/bin
  for bin in base calc draw impress math writer; do
    /bin/ln -s ../lib/%n/program/s${bin} %i/bin
    /bin/ln -s s${bin} %i/bin/oo${bin}
  done
  /bin/ln -s ../lib/%n/program/soffice %i/bin
  /usr/bin/sed -e "s/ -calc//" %i/lib/%n/program/scalc > %i/bin/ooffice
  /bin/chmod 755 %i/bin/ooffice

  # Symlink libdb_java-4.2.jnilib so that Java can find it
  /bin/ln -s %p/lib/libdb_java-4.2.jnilib %i/lib/%n/program

  # Install DocFiles
  /usr/bin/install -m 755 -d %i/share/doc/%n
  /bin/ln -s %i/lib/%n/LICENSE %i/share/doc/%n/LICENSE

  # Currently, Fink cannot handle "OpenOffice.org 2.0.app"
  # (which contains space character) with AppBundles field.
  /usr/bin/install -d -m 755 %i/Applications
  /usr/bin/tar -xf $STAR_RESOURCEPATH/OpenOffice.org.app.tar -C %i/Applications
  /bin/mv %i/Applications/OpenOffice.org.app "%i/Applications/OpenOffice.org 2.0.app"
  /bin/ln -s %p/lib/%n "%i/Applications/OpenOffice.org 2.0.app/Contents"
  /bin/chmod -R o-w '%i/Applications/'
  [ -x /Developer/Tools/SplitForks ] && /Developer/Tools/SplitForks '%i/Applications/'

  # End of Install Phase. Proceeding to install language packs...

<<
#AppBundles: instsetoo_native/unxmacxp.pro/OpenOffice/install/en-US_temp/OpenOffice.org*.app
PostInstScript: <<
  cd %p/lib/openoffice.org/share/fonts/truetype
  echo "Converting Mac OS X fonts..."
  /usr/bin/touch .fondudone
  for font in /System/Library/Fonts/* /Library/Fonts/*; do
    %p/bin/fondu --force "$font" || true
  done
  
  [ ! -e /Applications/Fink ] && /usr/bin/install -d -m 755 /Applications/Fink
  /bin/ln -s '%p/Applications/OpenOffice.org 2.0.app' /Applications/Fink/
<<
PostRmScript: /bin/rm -f '/Applications/Fink/OpenOffice.org 2.0.app'

Homepage: http://www.openoffice.org/

DescDetail: <<
OpenOffice.org is an Open Source, community-developed, multi-platform office
productivity suite. It includes the key desktop applications, such as a
word processor, spreadsheet, presentation manager, and drawing program,
with a user interface and feature set similar to other office suites.

Components include:
  * A universal word processing application for creating business
    letters, extensive text documents, professional layouts, and HTML
    documents.
  * A sophisticated application for performing advanced spreadsheet
    functions, such as analyzing figures, creating lists, and viewing data.
  * A tool for creating effective eye-catching presentations.
  * A vector-oriented draw module that enables the creation of 3D
    illustrations.
<<
DescPort: <<
This package is advised by NAKATA Maho <maho@FreeBSD.org>.
And furthermore, much advice from _rene_, ericb2, paveljanik, pmladek, shres
and ssa @ irc://irc.freenode.net/OpenOffice.org . Thanks to all OOo persons!

You can join discussions on porting here:
http://porting.openoffice.org/servlets/SummarizeList?listName=dev

It is reported that:
  * Mac OS X SDK (which comes with Xcode) is needed.

Because DYLD_LIBRARY_PATH does not contain %p/lib by default,
Java cannot find %p/lib/libdb_java-4.2.jnilib at compile time and runtime.
This script tries to make a symlink of it in %p/lib/openoffice.org/programs.
<<
DescPackaging: <<
To Do 1: Report build failures on building nas (Network Audio System)
  ( --without-nas or --with-system-nas )
with internal nas, build fails on Panther. 

"boost" is required on compile time, but not needed on runtime.

These --with-system flags are not used because they are not in Fink:
   --with-system-mspack
   --with-system-myspell
   --with-system-mythes
   --with-system-altlinuxhyph
   --enable-evolution2

I have no idea about openldap. Maybe mozilla is enough?
   --enable-openldap

Some comments about configure logs:
# checking whether to enable fontconfig support... no
Using fontconfig is not supported on Mac OS X.

# checking whether to build Mozilla addressbook connectivity...
#  no, not possible with system-mozilla
# checking whether to use Mozilla or Firefox... Mozilla
Shall I use Firefox instead of Mozilla?
<<
DescUsage: <<
To start OpenOffice.org, type "soffice" on your terminal,
or double-click "OpenOffice.org 2.0.app" icon located at /Applications/Fink .

To use GTK+ look and feel,
set SAL_USE_VCLPLUGIN environmental variable to "gtk".
normally this is done by rewriting %p/bin/soffice startup script.

To update fonts, execute these lines:
  cd %p/lib/openoffice.org/share/fonts/truetype
  for font in /System/Library/Fonts/* /Library/Fonts/*; do
    %p/bin/fondu --force "$font"
  done
or just one line:
  fink reinstall openoffice.org
<<]
LANGUAGEPACK_SPLITOFF(1, LANGUAGES)dnl
