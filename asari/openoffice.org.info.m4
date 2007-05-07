divert(-1)
changequote([, ])
dnl $Id$
dnl Usage: m4 -DTREE=xxx [-DMODE=Normal|DumpMirrors|DumpSnapshotMirrors] openoffice.org.info.m4

dnl ### Configurations ###
ifdef([MODE],,
 [define([MODE], [Normal])])
define([BASEVERSION], [[2.2.0]])
define([SNAPSHOT], [[m15]])
define([SOURCE_MD5], [[994606c18a48ab073e2394b373e228a8]])
define([REVISION_10_3], 1)
define([REVISION_10_4], 1001)
define([REVISION_SUFFIX],[])
ifdef([USE_FINK_PYTHON],,
 [define([USE_FINK_PYTHON], 1)])
ifdef([USE_FIREFOX],,
 [define([USE_FIREFOX], 0)])
ifdef([USE_CRYPTO],,
 [define([USE_CRYPTO], 1)])
define([RELEASE_SOURCE], [[stable/%v/OOo_%v_src.tar.gz]])
define([SNAPSHOT_SOURCE], [[OOo_OOF680_m15_source.tar.bz2]])
define([SOURCE_DIRECTORY], [[OOF680_m15]])

dnl ### Macro Library ###
dnl Replace uppercases of $1 to lowercases.
define([TOLOWER], [translit([$1], [ABCDEFGHIJKLMNOPQRSTUVWXYZ], [abcdefghijklmnopqrstuvwxyz])])

dnl Returns *quoted* newline.
define([NEWLINE], [[
]])

dnl Usage: STR_EQ([Str1], [Str2])
dnl Returns 1 if Str1 is identical to Str2, 0 otherwise.
define([STR_EQ], [ifelse([$1], [$2], 1, 0)])

dnl Usage: DEFINED([Macro])
dnl Returns 1 if Macro is defined, 0 otherwise.
define([DEFINED], [ifdef([$1], 1, 0)])

dnl Print a error message $1 and exit.
ifdef([__line__],
 [define([ERREXIT], [errprint(__line__: [$1]NEWLINE)m4exit(1)])],
 [define([ERREXIT], [errprint([$1]NEWLINE)m4exit(1)])])

dnl ### Other Macros ###
ifdef([SNAPSHOT],
 [define([FINKVERSION], [BASEVERSION+SNAPSHOT])
  define([SOURCE], [SNAPSHOT_SOURCE])],
 [define([FINKVERSION], [BASEVERSION])
  define([SOURCE], [RELEASE_SOURCE])])

ifelse(MODE, [Normal],
 [ifdef([TREE],
   [ifelse(TREE, [10.4],
     [define([REVISION], [REVISION_10_4])],
     [ERREXIT([Wrong TREE])])],
   [ERREXIT([You must define the TREE])])])

dnl Usage: IF_10_4([Action if 10.4 or higher])
dnl        IF_10_4([Action if 10.4 or higher], [Action if 10.3])
ifelse(MODE, [Normal],
 [ifelse(eval(STR_EQ(TREE, [10.3])), 1,
   [define([IF_10_4], [$2])],
   [define([IF_10_4], [$1])])])

ifelse(MODE, [Normal],
 [define([MIRROR], [ifelse($1, 0, [[#]])[$2: $3]])],
 [define([MIRROR], [[$1 $2 $3]])])

ifelse(MODE, [Normal],
 [ifelse(TREE, [10.3],
   [define([PERLVERSION], 581)],
   [define([PERLVERSION], 586)])])

ifelse(USE_FIREFOX, 1,
 [define([IF_FIREFOX], [$1])],
 [define([IF_FIREFOX], [$2])])

ifelse(USE_CRYPTO, 1,
 [define([IF_CRYPTO], [$1])],
 [define([IF_CRYPTO], [$2])])

define([SPLITOFF_ID], 1)
define([LANGUAGE],
[[SplitOff]ifelse(SPLITOFF_ID, 1, , SPLITOFF_ID)[: <<
  Package: %N-]TOLOWER([[$1]])[
  Description: Language Pack($1) for OpenOffice.org
  Depends: %N (= %v-%r)
  InstallScript: ./languagepack-splitoff ]TOLOWER([[$1]])[ $1 %p %d %i %N
<<
]define([SPLITOFF_ID], incr(SPLITOFF_ID))])

dnl ### Run Commands ###
ifelse(MODE, [Normal],
 [divert(0)],
 MODE, [DumpMirrors],
 [divert(0)BASEVERSION RELEASE_SOURCE[]NEWLINE[]divert(-1)],
 MODE, [DumpSnapshotMirrors],
 [divert(0)FINKVERSION SNAPSHOT_SOURCE[]NEWLINE[]divert(-1)],
 [ERREXIT([Bad mode specified])])dnl
dnl
dnl ### Body ###
[Package: openoffice.org]IF_CRYPTO([IF_FIREFOX([-firefox])], [-nocrypto])[
Description: Integrated office productivity suite
Version: ]FINKVERSION[
Revision: ]REVISION[]REVISION_SUFFIX[
Type: java(1.4)
License: LGPL
Maintainer: Todai Fink Team <fink@sodan.ecc.u-tokyo.ac.jp>

Conflicts: openoffice.org, openoffice.org-firefox, openoffice.org-nocrypto
Replaces: openoffice.org, openoffice.org-firefox, openoffice.org-nocrypto
Provides: openoffice.org-generation2
BuildConflicts: libicu32-dev
BuildDepends: <<
  x11-dev, ant, bison, coreutils, system-java14-dev,
  archive-zip-pm]PERLVERSION[,
  libjpeg, expat1, freetype219, libxml2,
  sane-backends-dev, libcurl4, libsndfile1-dev,
  portaudio (>= 18.1-1), neon25,
  libart2, startup-notification-dev, libgettext3-dev,
  atk1, gtk+2-dev, orbit2-dev, pango1-xft2-ft219-dev,
  fontconfig2-dev, libiconv-dev, openldap23-dev,]
IF_10_4(
[[  libwpd-0.8-dev (>= 0.8.2-1001), glib2-dev (>= 2.6.6-1111),
  db42-ssl (>= 4.2.52-1017) | db42 (>= 4.2.52-1017),
  libsablot-dev (>= 0.98-1024), libsablot (>= 0.98-1024),
  unixodbc2-nox (>= 2.2.11-1010) | unixodbc2 (>= 2.2.11-1010),]],
[[  libwpd-0.8-dev, glib2-dev, db42-ssl | db42,
  libsablot-dev, libsablot, unixodbc2-nox | unixodbc2,]])
IF_CRYPTO(
 [IF_FIREFOX(
   [[  firefox-dev]IF_10_4([[ (>= 1.0.7-1007)]]),],
   [[  seamonkey-dev],])
])dnl
ifelse(USE_FINK_PYTHON, 1,
  [IF_10_4(
    [[  python25],],
    [[  python24],])])
[  pkgconfig, popt, fink (>= 0.24.12)
<<

Depends: <<
  x11, system-java14, system-perl,
  libjpeg-shlibs, expat1-shlibs, freetype219-shlibs, libxml2-shlibs,
  sane-backends-shlibs, libcurl4-shlibs, libsndfile1-shlibs,
  portaudio-shlibs (>= 18.1-1), neon25-shlibs,
  libart2-shlibs, startup-notification-shlibs,
  atk1-shlibs, gtk+2-shlibs, libgettext3-shlibs, pango1-xft2-ft219-shlibs,
  fontconfig2-shlibs, libiconv, openldap23-shlibs,]
IF_10_4(
[[  libwpd-0.8-shlibs (>= 0.8.2-1001), glib2-shlibs (>= 2.6.6-1111),
  db42-ssl-shlibs (>= 4.2.52-1017) | db42-shlibs (>= 4.2.52-1017),
  db42-ssl-java (>= 4.2.52-1012) | db42-java (>= 4.2.52-1012),
  libsablot-shlibs (>= 0.98-1024),
  unixodbc2-nox-shlibs (>= 2.2.11-1010) | unixodbc2-shlibs (>= 2.2.11-1010),]],
[[  libwpd-0.8-shlibs, glib2-shlibs,
  db42-ssl-shlibs | db42-shlibs, db42-ssl-java | db42-java,
  libsablot-shlibs, unixodbc2-nox-shlibs | unixodbc2-shlibs,]])
IF_CRYPTO(
 [IF_FIREFOX(
   [[  firefox-shlibs]IF_10_4([[ (>= 1.0.7-1007)]]),],
   [IF_10_4(
     [[  seamonkey-shlibs,]],
     [[  mozilla-shlibs, mozilla-mailnews,]])])
])dnl
ifelse(USE_FINK_PYTHON, 1,
 [IF_10_4(
    [[  python25-shlibs,]],
    [[  python24-shlibs,]])
])dnl
[  fondu
<<

CustomMirror: <<]
ifelse(eval((STR_EQ(MODE, [Normal]) && !DEFINED([SNAPSHOT])) ||
             STR_EQ(MODE, [DumpMirrors])),
  1, [divert(0)], [divert(-1)])dnl
MIRROR(1, [aus-AU], [http://openoffice.mirrors.ilisys.com.au/])
MIRROR(0, [aus-AU], [ftp://mirror.pacific.net.au/OpenOffice/])
MIRROR(0, [aus-AU], [http://mirror.pacific.net.au/openoffice/])
MIRROR(1, [aus-AU], [ftp://ftp.planetmirror.com/pub/openoffice/])
MIRROR(1, [aus-AU], [http://public.planetmirror.com/pub/openoffice/])
MIRROR(1, [eur-AT], [http://gd.tuwien.ac.at/office/openoffice/])
MIRROR(1, [eur-AT], [ftp://gd.tuwien.ac.at/office/openoffice/])
MIRROR(1, [eur-BE], [http://ftp.belnet.be/pub/mirror/ftp.openoffice.org/])
MIRROR(0, [eur-BE], [ftp://ftp.scarlet.be/pub/openoffice/])
MIRROR(0, [eur-BE], [http://ftp.scarlet.be/pub/openoffice/])
MIRROR(1, [eur-BE], [ftp://ftp.openoffice.skynet.be/pub/ftp.openoffice.org/])
MIRROR(1, [eur-BE], [ftp://ftp.kulnet.kuleuven.ac.be/pub/mirror/openoffice.org/])
MIRROR(1, [sam-BR], [http://linorg.usp.br/OpenOffice.org/])
MIRROR(1, [sam-BR], [ftp://ftp.pucpr.br/openoffice/])
MIRROR(1, [eur-BG], [http://ftp.spnet.net/openoffice/])
MIRROR(1, [eur-BG], [ftp://ftp.spnet.net/openoffice/])
MIRROR(1, [nam-CA], [ftp://openoffice.mirror.rafal.ca/openoffice/])
MIRROR(1, [nam-CA], [http://openoffice.mirror.rafal.ca/])
MIRROR(1, [nam-CA], [http://gulus.USherbrooke.ca/pub/appl/openoffice/])
MIRROR(1, [eur-CZ], [http://ftp.sh.cvut.cz/MIRRORS/OpenOffice/])
MIRROR(1, [eur-CZ], [ftp://ftp.sh.cvut.cz/MIRRORS/OpenOffice/])
MIRROR(1, [eur-DK], [http://mirrors.dotsrc.org/openoffice/])
MIRROR(1, [eur-DK], [ftp://mirrors.dotsrc.org/openoffice/])
MIRROR(1, [eur-EE], [http://openoffice.offline.ee/])
MIRROR(1, [eur-FI], [ftp://ftp.funet.fi/pub/mirrors/openoffice.org/])
MIRROR(0, [eur-FR], [ftp://openoffice.cict.fr/openoffice/])
MIRROR(1, [eur-FR], [ftp://ftp.free.fr/mirrors/ftp.openoffice.org/])
MIRROR(1, [eur-DE], [ftp://ftp.tu-chemnitz.de/pub/openoffice/])
MIRROR(1, [eur-DE], [ftp://ftp.gwdg.de/pub/misc/openoffice/])
MIRROR(1, [eur-DE], [ftp://sunsite.informatik.rwth-aachen.de/pub/mirror/OpenOffice/])
MIRROR(1, [eur-DE], [ftp://ftp.leo.org/pub/openoffice/])
MIRROR(1, [eur-DE], [http://ftp.leo.org/pub/openoffice/])
MIRROR(1, [eur-DE], [ftp://ftp.uni-muenster.de/pub/software/OpenOffice/])
MIRROR(1, [eur-DE], [ftp://openoffice.tu-bs.de/OpenOffice.org/])
MIRROR(1, [eur-DE], [ftp://ftp.stardiv.de/pub/OpenOffice.org/])
MIRROR(1, [eur-DE], [http://ftp.stardiv.de/pub/OpenOffice.org/])
MIRROR(1, [eur-DE], [ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.openoffice.org/])
MIRROR(1, [eur-DE], [http://mirror.xaranet.de/openoffice/])
MIRROR(1, [eur-GR], [http://www.ellak.gr/pub/openoffice/])
MIRROR(1, [eur-GR], [http://ftp.ntua.gr/pub/OpenOffice/])
MIRROR(1, [eur-GR], [ftp://ftp.ntua.gr/pub/OpenOffice/])
MIRROR(1, [eur-HU], [http://ftp.fsf.hu/OpenOffice.org/])
MIRROR(1, [eur-HU], [ftp://ftp.fsf.hu/OpenOffice.org/])
MIRROR(1, [eur-IS], [ftp://ftp.rhnet.is/pub/OpenOffice/])
MIRROR(1, [eur-IS], [http://ftp.rhnet.is/pub/OpenOffice/])
MIRROR(1, [asi-ID], [http://openoffice.ugm.ac.id/])
MIRROR(1, [asi-ID], [ftp://kambing.vlsm.org/openoffice/])
MIRROR(1, [asi-ID], [http://kambing.vlsm.org/openoffice/])
MIRROR(1, [eur-IE], [ftp://ftp.heanet.ie/mirrors/openoffice.org/])
MIRROR(1, [eur-IE], [http://ftp.heanet.ie/mirrors/openoffice.org/])
MIRROR(1, [eur-IT], [ftp://na.mirror.garr.it/mirrors/openoffice/])
MIRROR(1, [eur-IT], [http://na.mirror.garr.it/mirrors/openoffice/])
MIRROR(1, [asi-JP], [ftp://ftp.kddlabs.co.jp/office/openoffice/])
MIRROR(1, [asi-JP], [ftp://ftp.ring.gr.jp/pub/misc/openoffice/])
MIRROR(1, [asi-JP], [http://www.ring.gr.jp/archives/misc/openoffice/])
MIRROR(1, [asi-JP], [ftp://ftp.yz.yamagata-u.ac.jp/pub/openoffice/])
MIRROR(1, [asi-JP], [http://ftp.yz.yamagata-u.ac.jp/pub/openoffice/])
MIRROR(1, [eur-LT], [ftp://files.akl.lt/OpenOffice.org/])
MIRROR(1, [eur-LT], [http://files.akl.lt/OpenOffice.org/])
MIRROR(0, [asi-MY], [http://mymirror.asiaosc.org/openoffice/])
MIRROR(1, [eur-NL], [ftp://ftp.nluug.nl/pub/office/openoffice/])
MIRROR(1, [eur-NL], [http://ftp.nluug.nl/pub/office/openoffice/])
MIRROR(1, [eur-NL], [ftp://ftp.snt.utwente.nl/pub/software/openoffice/])
MIRROR(1, [eur-NL], [ftp://borft.student.utwente.nl/])
MIRROR(1, [eur-NL], [http://borft.student.utwente.nl/openoffice/])
MIRROR(1, [eur-NL], [ftp://niihau.student.utwente.nl/])
MIRROR(1, [eur-NL], [http://vlaai.snt.utwente.nl/pub/software/openoffice/])
MIRROR(1, [eur-PL], [ftp://ftp.man.poznan.pl/pub/openoffice/])
MIRROR(1, [eur-PL], [ftp://ftp.openoffice.pl/OpenOffice.ORG/])
MIRROR(1, [eur-PL], [ftp://ftp.tpnet.pl/d9/OpenOffice/])
MIRROR(1, [eur-PL], [http://ftp.tpnet.pl/vol/d9/OpenOffice/])
MIRROR(1, [eur-RO], [ftp://ftp.iasi.roedu.net/pub/mirrors/openoffice.org/])
MIRROR(1, [eur-RO], [http://ftp.iasi.roedu.net/mirrors/openoffice.org/])
MIRROR(1, [eur-RO], [ftp://mirrors.evolva.ro/openoffice.org/])
MIRROR(1, [eur-RO], [ftp://ftp.idilis.ro/mirrors/openoffice.org/])
MIRROR(1, [eur-RO], [http://ftp.idilis.ro/mirrors/openoffice.org/])
MIRROR(1, [eur-RU], [ftp://ftp.chg.ru/pub/OpenOffice/])
MIRROR(1, [eur-RU], [http://ftp.chg.ru/pub/OpenOffice/])
MIRROR(1, [eur-YU], [ftp://mirror.etf.bg.ac.yu/openoffice.org/])
MIRROR(1, [eur-YU], [http://mirror.etf.bg.ac.yu/openoffice/])
MIRROR(1, [asi-SG], [ftp://mirror.averse.net/pub/openoffice/])
MIRROR(0, [asi-SG], [http://mirror.averse.net/openoffice/])
MIRROR(1, [eur-SI], [ftp://ftp.bevc.net/mirrors/openoffice/])
MIRROR(1, [eur-SI], [http://mirrors.bevc.net/openoffice/])
MIRROR(0, [eur-SI], [http://www.wsection.com/openoffice/])
MIRROR(0, [afr-ZA], [ftp://ftp.is.co.za/mirrors/OpenOffice/])
MIRROR(1, [asi-KR], [ftp://ftp.kr.freebsd.org/pub/openoffice/])
MIRROR(1, [eur-ES], [http://ftp.rediris.es/ftp/mirror/openoffice.org/])
MIRROR(1, [eur-ES], [ftp://ftp.rediris.es/mirror/openoffice.org/])
MIRROR(1, [eur-SE], [http://ftp.sunet.se/pub/Office/OpenOffice.org/])
MIRROR(0, [eur-CH], [ftp://ftp.solnet.ch/mirror/OpenOffice/])
MIRROR(1, [eur-CH], [ftp://sunsite.cnlab-switch.ch/mirror/OpenOffice/])
MIRROR(1, [eur-CH], [http://mirror.switch.ch/ftp/mirror/OpenOffice/])
MIRROR(1, [eur-CH], [ftp://mirror.switch.ch/mirror/OpenOffice/])
MIRROR(0, [asi-TW], [ftp://ftp.isu.edu.tw/pub/OpenOffice/])
MIRROR(0, [asi-TW], [http://ftp.isu.edu.tw/pub/OpenOffice/])
MIRROR(0, [asi-TW], [ftp://ftp.nctu.edu.tw/UNIX/OpenOffice/])
MIRROR(1, [eur-UK], [ftp://ftp.mirrorservice.org/sites/ny1.mirror.openoffice.org/])
MIRROR(1, [eur-UK], [http://www.mirrorservice.org/sites/ny1.mirror.openoffice.org/])
MIRROR(0, [eur-UK], [ftp://mirrors.blueyonder.co.uk/sites/openoffice.org])
MIRROR(1, [eur-UK], [http://openoffice.blueyonder.co.uk/])
MIRROR(1, [eur-UK], [ftp://ftp.mirror.ac.uk/mirror/sunsite.dk/openoffice/])
MIRROR(0, [eur-UK], [http://www.mirror.ac.uk/mirror/sunsite.dk/openoffice/])
MIRROR(1, [nam-US], [ftp://ftp.osuosl.org/pub/openoffice/])
MIRROR(1, [nam-US], [http://ftp.osuosl.org/pub/openoffice/])
MIRROR(1, [nam-US], [http://mirrors.ibiblio.org/pub/mirrors/openoffice/])
MIRROR(1, [nam-US], [ftp://ftp.ibiblio.org/pub/mirrors/openoffice/])
MIRROR(1, [nam-US], [ftp://ftp.ussg.iu.edu/pub/openoffice/])
MIRROR(1, [nam-US], [http://mirrors.isc.org/pub/openoffice/])
MIRROR(1, [nam-US], [ftp://openoffice.mirrors.pair.com/])
MIRROR(1, [nam-US], [http://openoffice.mirrors.pair.com/ftp/])
MIRROR(1, [nam-US], [ftp://openofficeorg.secsup.org/pub/software/openoffice/])
MIRROR(1, [nam-US], [http://openofficeorg.secsup.org/])
MIRROR(1, [nam-US], [http://openoffice.mirror.wrpn.net/])
MIRROR(1, [nam-US], [ftp://openoffice.mirrors.tds.net/pub/openoffice/])
MIRROR(1, [nam-US], [http://openoffice.mirrors.tds.net/pub/openoffice/])
ifelse(eval((STR_EQ(MODE, [Normal]) && DEFINED([SNAPSHOT])) ||
             STR_EQ(MODE, [DumpSnapshotMirrors])),
  1, [divert(0)], [divert(-1)])dnl
MIRROR(1, [Primary], [ftp://ooopackages.good-day.net/pub/OpenOffice.org/sources/])
ifelse(MODE, [Normal], [divert(0)], [divert(-1)])dnl
[<<
Source: mirror:custom:]SOURCE[
Source-MD5: ]SOURCE_MD5[
SourceDirectory: ]SOURCE_DIRECTORY[
Source2: http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll
Source2-MD5: e3a0b76dcd876f3d721ee7183729153d

PatchFile: %n.patch
PatchFile-MD5: 91f3a422c41b0bc0d3ef62d276174e71
PatchScript: <<
  #!/bin/bash -ev
  /usr/bin/sed 's|@PREFIX@|%p|g;s|@PKGNAME@|%n|g' %{PatchFile} | /usr/bin/patch -p0
  chmod a+x languagepack-splitoff
  /bin/ln ../unowinreg.dll ./external/unowinreg/

  if osacompile -o test ./desktop/macosx/source/main.applescript >/dev/null 2>&1; then
    :
  elif /usr/libexec/StartupItemContext /usr/bin/osacompile -o test ./desktop/macosx/source/main.applescript >/dev/null 2>&1; then
    /usr/bin/sed -i.bak "s|osacompile|/usr/libexec/StartupItemContext /usr/bin/osacompile|g" ./desktop/macosx/source/makefile.mk
  else
    echo "osacompile failed. This is typically for you don't have root access."
    false
  fi
<<

GCC: ]IF_10_4(4.0, 3.3)[
SetCPPFLAGS: -I%p/include/db4
ConfigureParams: <<
  --with-gnu-cp=%p/lib/coreutils/bin/cp \
  --disable-epm \
  --with-lang=ALL \
  --with-x --x-includes=/usr/X11R6/include --x-libraries=/usr/X11R6/lib \
  --with-jdk-home="$JAVA_HOME" --with-ant-home=%p/lib/ant \
  --disable-crashdump \
  --with-build-version="%v-%r; Built with Fink <http://finkproject.org>" \
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
  --enable-gtk \
  --disable-systray \
  --disable-kde \
  --with-system-freetype \
  --without-nas \
  --with-system-libxml \
  --with-system-python \]
IF_CRYPTO(
[  [--with-system-mozilla \]]
IF_10_4([[  --with-seamonkey]])IF_FIREFOX([[  --with-firefox]])[[ \]],
[[  --disable-mozilla --enable-openldap \]])
[  --enable-libsn
<<

CompileScript: <<
  #!/bin/bash -ev

  if ${CXX:-"g++"} --version | /usr/bin/grep -q 'build 5250'; then
    echo "Xcode 2.2.1 is buggy." >&2
    exit 2
  fi

: "[ Message from OpenOffice.org package maintainer ] ================="
:
: "Welcome to OpenOffice.org build script!"
:
: "Notice for builders:"
:
: "1. This building process may take a couple of day or more,"
: "   and often fails with errors."
: "2. This building process may consume much of your disk space,"
: "   possibly up to 10GB."
: "3. This building process needs your own WindowServer process."
: "   i.e, it is not possible to build through simple SSH connection."
: "   This is because the building process uses /usr/bin/osacompile ."
: "   /usr/libexec/StartupItemContext will be used if you are root."
:
: "If you faced a building problem, feel free to mail the maintainer,"
: "preferably with your environment (gcc's version, etc.) and"
: "the build log."
: "You can find the logs here:"
: "   %b/%n-%v-%r.buildlog"
:
: "The mail address is: Todai Fink Team <fink@sodan.ecc.u-tokyo.ac.jp>"
:
: "Please understand this Fink package is still unstable."
:
: "===================================================================="
:
: "If you are ready, press RETURN/ENTER to proceed..."

  read -t 60 || true

  # Record the time
  STARTTIME=`/bin/date +"%%F %%T %%Z(%%z)"`

  # Check the architecture
  case %m in
    powerpc) machine=PPC;;
    i386) machine=Intel;;
    *) echo 'Unknown architecture'; exit 1;;
  esac

  # Create a log file
  exec 3> >(/usr/bin/tee -i %n-%v-%r.buildlog)

  # $X_LDFLAGS is needed to configure with X correctly.  
  export X_LDFLAGS=$LDFLAGS

  # $PKG_CONFIG_PATH is needed to configure with freetype219, pango1-xft2-xft219
  export PKG_CONFIG_PATH=%p/lib/freetype219/lib/pkgconfig:%p/lib/pango-ft219/lib/pkgconfig
]
ifelse(USE_FINK_PYTHON, 1,
[IF_10_4(
[[  # $PYTHON is needed to configure with python25
  export PYTHON=%p/bin/python2.5]],
[[  # $PYTHON is needed to configure with python24
  export PYTHON=%p/bin/python2.4]])],
[[  # $PYTHON is needed to configure with the Darwin's python
  export PYTHON=/usr/bin/python]])
[
  /usr/bin/printf "[ Phase 1: Configure ]\n\n" >&3
  (cd config_office && ./configure %c ] ifelse(USE_FINK_PYTHON, 1,
  IF_10_4(
[[--with-python-libs="$(%p/bin/python2.5-config --ldflags)"]],
[[--with-python-libs="-L%p/lib/python2.4/config -lpython2.4"]])
)[ ) >&3 2>&3 || exit

  /usr/bin/printf "\n\n[ Phase 2: Bootstrap ]\n\n" >&3
  ./bootstrap >&3 2>&3

  # Because we are using %p, $SOLARINC and $SOLARLIB need modified  
  # Include libdb_java-4.2.jnilib to DYLD_LIBRARY_PATH so that Java can find it
  /usr/bin/sed -i.bak \
    -e"/^\(setenv \)*SOLARLIB/s|-L/usr/lib|-L%b/FINKLIBS -L%p/lib/freetype219/lib -L%p/lib -L/usr/lib|" \
    -e"/^\(setenv \)*SOLARINC/s|-I/usr/X11R6/include -I/usr/X11R6/include/freetype2|-I%p/include/db4 -I%p/lib/freetype219/include/freetype2 -I%p/lib/freetype219/include -I%p/include -I/usr/X11R6/include|" \
    -e"/^\(setenv \)*DYLD_LIBRARY_PATH/s|/lib|/lib:%b/FINKLIBS|" \
    -e"/^\(setenv \)*PROFULLSWITCH/s|product=full|--dlv_switch -link product=full|" \
    MacOSX${machine}Env.Set MacOSX${machine}Env.Set.sh

  /bin/mkdir FINKLIBS
  /bin/ln -s %p/lib/libdb_java-4.2.jnilib FINKLIBS

  # Retry forever to build OOo until success!
  while :; do
    /usr/bin/printf "\n\n[ Phase 3: Make ]\n\n" >&3
    . ./MacOSX${machine}Env.Set.sh
    dmake >&3 2>&3 && break

    echo 'begin-base64 644 /dev/stdout
H4sIAEZ6OUYAA51QvW6EMAze/RTfA/Rye6VKqBJjuQrRqeoQwIGIkCAT7srb11y361ZLlpzvx479
iTdeVzswnKQZl4XjxTnfsUkyYLHddHCz9TFrsuALL49B9Lr50Ps4PPqdVRw3n0fYCBZJYqhKN+xp
Q6fQwBnieySHPLJC28pod4w29k9IokgIcFqMHBZDjYraYxh6L9zlJDv8+kxA0ZJ67l3cpp6QdLwP
rDTsVf9hW32MLPyrPhfxVFxPhZh7P5UT/dnsH0H0LnpR1GXzUVfnsmrKGjmBv30+FvJx2bJeY8fE
+0GoOlvJ6Gc7sTGG6AdmMhLhlAEAAA==
====' | uudecode | gzip -dc | sed 's|@b|%b|g;s|@n|%n|g;s|@v|%v|g;s|@r|%r|g'

    read input
    [ -n "$input" ] || false
  done

  /usr/bin/printf "\n\n[ Phase 4: Statistics ]\n\n" >&3
: "[ Message from OpenOffice.org package maintainer ] ================="
:
: "Congratulations!"
: "The building process of OpenOffice.org has completed!"
:
: "===================================================================="

  echo "   Started:   $STARTTIME" >&3

  ENDTIME=`/bin/date +"%%F %%T %%Z(%%z)"`

  echo "   Completed: $ENDTIME" >&3

  DISKUSAGE=`/usr/bin/du -sh %b | /usr/bin/cut -f1`

  echo "   $DISKUSAGE is used for this building process (not including tarball)." >&3
<<

InstallScript: <<
  #!/bin/bash -ev

  # Mainly, this InstallScript is derived from
  # "ooinstall" in ooo-build and instsetoo_native/util/makefile.mk

  /usr/bin/printf "\n\n[ Install Phase ]\n\n"

  # Setting up environment
  case %m in
    powerpc) . ./MacOSXPPCEnv.Set.sh;;
    i386) . ./MacOSXIntelEnv.Set.sh;;
    *) echo 'Unknown architecture'; exit 1;;
  esac

  # Variables needed to execute make_installer.pl
  export GNUCOPY="/bin/ln"
  export OUT="../$INPATH"
  export LOCAL_OUT="$OUT"
  export LOCAL_COMMON_OUT="$OUT"
  solarlibdir=$SOLARVER/$INPATH/lib
  export PYTHONPATH=$SRC_ROOT/instsetoo_native/$INPATH/bin:$solarlibdir:$solarlibdir/python:$solarlibdir/python/lib-dynload
  build=`sed -n 's/^BUILD=\(.*\)$/\1/p' $SOLARENVINC/minor.mk`

  # Some dirty hacks to reduce disk consumption

  # Force make_installer.pl to use ln instead of cp
  /usr/bin/sed -i .bak "s|'-af'|'-f'|" \
    $SOLARENV/bin/modules/installer/worker.pm
  /usr/bin/sed -i .bak \
    's/installer::systemactions::copy_one_file/installer::systemactions::hardlink_one_file/' \
    $SOLARENV/bin/modules/installer/archivefiles.pm
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
    -simple %p/Applications
  popd

  # Some dirty hacks to reduce disk consumption -- again

  # Surpress further unzipping from now on
  /usr/bin/sed -i .bak2 \
    's|\(.installer::globals::unzippath -o -q[^"]*\)|if [ -d %b/instsetoo_native/util/OpenOffice/zip/en-US/00/$onefilename ]; then /bin/rmdir $unzipdir; /bin/ln -s %b/instsetoo_native/util/OpenOffice/zip/en-US/00/$onefilename `/usr/bin/dirname ${unzipdir}foo`; elif [ -d %b/instsetoo_native/util/OpenOffice/zip/en-US/en-US/$onefilename ]; then /bin/rmdir $unzipdir; /bin/ln -s %b/instsetoo_native/util/OpenOffice/zip/en-US/en-US/$onefilename `/usr/bin/dirname ${unzipdir}foo`; else \1; fi|' \
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
    /bin/ln -s "../Applications/OpenOffice.org 2.2.app/Contents/MacOS/program/s${bin}" %i/bin
    /bin/ln -s "../Applications/OpenOffice.org 2.2.app/Contents/MacOS/program/s${bin}" %i/bin/oo${bin}
  done
  /bin/ln -s "../Applications/OpenOffice.org 2.2.app/Contents/MacOS/program/soffice" %i/bin
  /bin/ln -s "../Applications/OpenOffice.org 2.2.app/Contents/MacOS/program/soffice" %i/bin/ooffice]

ifelse(eval(USE_FIREFOX || !USE_CRYPTO), 1,
[[  /bin/ln -s %n %i/lib/openoffice.org
]])dnl
[  # Symlink libdb_java-4.2.jnilib so that Java can find it
  /bin/ln -s %p/lib/libdb_java-4.2.jnilib "%i/Applications/OpenOffice.org 2.2.app/Contents/MacOS/program"

  # Install update-ooo-fonts
  /usr/bin/install -m 755 -d %i/sbin
  /usr/bin/install -m 755 update-ooo-fonts %i/sbin/update-ooo-fonts

  # Install DocFiles
  /usr/bin/install -m 755 -d %i/share/doc/%n
  /bin/mv %i/Applications/{LICENSEs,READMEs} %i/share/doc/%n

  # Currently, Fink cannot handle "OpenOffice.org 2.2.app"
  # (which contains space character) with AppBundles field.
  [ -x /Developer/Tools/SplitForks ] && /Developer/Tools/SplitForks '%i/Applications/'

  # End of Install Phase. Proceeding to install language packs...

<<

PostInstScript: <<
  %p/sbin/update-ooo-fonts
  [ ! -e /Applications/Fink ] && /usr/bin/install -d -m 755 /Applications/Fink
  /bin/ln -s '%p/Applications/OpenOffice.org 2.2.app' /Applications/Fink/
<<
PreRmScript: %p/sbin/update-ooo-fonts --clean
PostRmScript: /bin/rm -f '/Applications/Fink/OpenOffice.org 2.2.app'

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
http://porting.openoffice.org/servlets/SummarizeList?listName=mac

It is reported that:
  * Mac OS X SDK (which comes with Xcode) is needed.

Because DYLD_LIBRARY_PATH does not contain %p/lib by default,
Java cannot find %p/lib/libdb_java-4.2.jnilib at compile time and runtime.
This script tries to make a symlink of it in %p/lib/%n/programs.
<<
DescPackaging: <<
This finkinfo is maintained by m4. See experimental/asari/openoffice.org.info.m4.

These --with-system flags are not used because they are not in Fink:
   --with-system-mspack
   --with-system-myspell
   --with-system-mythes
   --with-system-altlinuxhyph
   --enable-evolution2

Using fontconfig is not supported on Mac OS X.
<<
DescUsage: <<
To start OpenOffice.org, type "soffice" on your terminal,
or double-click "OpenOffice.org 2.2.app" icon located at /Applications/Fink .

To use GTK+ look and feel,
set SAL_USE_VCLPLUGIN environmental variable to "gtk".
normally this is done by rewriting %p/bin/soffice startup script.

To update fonts, execute %p/sbin/update-ooo-fonts.
<<]
LANGUAGE([af])
LANGUAGE([ar])
LANGUAGE([as-IN])
LANGUAGE([be-BY])
LANGUAGE([bg])
LANGUAGE([bn])
LANGUAGE([bn-BD])
LANGUAGE([bn-IN])
LANGUAGE([br])
LANGUAGE([bs])
LANGUAGE([ca])
LANGUAGE([cs])
LANGUAGE([cy])
LANGUAGE([da])
LANGUAGE([de])
LANGUAGE([dz])
LANGUAGE([el])
LANGUAGE([en-GB])
LANGUAGE([en-ZA])
LANGUAGE([eo])
LANGUAGE([es])
LANGUAGE([et])
LANGUAGE([eu])
LANGUAGE([fa])
LANGUAGE([fi])
LANGUAGE([fr])
LANGUAGE([ga])
LANGUAGE([gl])
LANGUAGE([gu-IN])
LANGUAGE([he])
LANGUAGE([hi-IN])
LANGUAGE([hr])
LANGUAGE([hu])
LANGUAGE([it])
LANGUAGE([ja])
LANGUAGE([km])
LANGUAGE([kn-IN])
LANGUAGE([ko])
LANGUAGE([ku])
LANGUAGE([lo])
LANGUAGE([lt])
LANGUAGE([lv])
LANGUAGE([mk])
LANGUAGE([ml-IN])
LANGUAGE([mr-IN])
LANGUAGE([ms])
LANGUAGE([nb])
LANGUAGE([ne])
LANGUAGE([nl])
LANGUAGE([nn])
LANGUAGE([nr])
LANGUAGE([ns])
LANGUAGE([or-IN])
LANGUAGE([pa-IN])
LANGUAGE([pl])
LANGUAGE([pt])
LANGUAGE([pt-BR])
LANGUAGE([ru])
LANGUAGE([rw])
LANGUAGE([sh-YU])
LANGUAGE([sk])
LANGUAGE([sl])
LANGUAGE([sr-CS])
LANGUAGE([ss])
LANGUAGE([st])
LANGUAGE([sv])
LANGUAGE([sw])
LANGUAGE([sw-TZ])
LANGUAGE([sx])
LANGUAGE([ta-IN])
LANGUAGE([te-IN])
LANGUAGE([tg])
LANGUAGE([th])
LANGUAGE([ti-ER])
LANGUAGE([tn])
LANGUAGE([tr])
LANGUAGE([ts])
LANGUAGE([uk])
LANGUAGE([ur-IN])
LANGUAGE([ve])
LANGUAGE([vi])
LANGUAGE([xh])
LANGUAGE([zh-CN])
LANGUAGE([zh-TW])
LANGUAGE([zu])
