#!/bin/sh
#
# $Id$
#

# ---------------------------------------------------------------
# Copyright 2003 Przemyslaw Czerpak <druzus@polbox.com>
# simple script to build shared libraries from static ones and
# object files
#
# See COPYING for licensing terms.
# ---------------------------------------------------------------

# HB_PLATFORM=""
# HB_CCPREFIX=""
# HB_CCPATH=""

if [ -n "${HB_PLATFORM}" ]
then
   hb_plat="${HB_PLATFORM}"
else
   hb_plat=`uname -s | tr -d "[-]" | tr '[A-Z]' '[a-z]' 2>/dev/null`
fi

linker_options=""

case "$hb_plat" in
   *windows*|*mingw32*|msys*|cygwin*) hb_plat="win" ;;
   *os/2*)                            hb_plat="os2" ;;
   *dos)                              hb_plat="dos" ;;
   *bsd)                              hb_plat="bsd" ;;
esac

case "$hb_plat" in
   darwin) SLIB_EXT=".dylib" ;;
   win)    SLIB_EXT=".dll" ;;
   wce)    SLIB_EXT=".dll" ;;
   os2)    SLIB_EXT=".dll" ;;
   hpux)   SLIB_EXT=".sl" ;;
   *)      SLIB_EXT=".so" ;;
esac

NAME="${1%${SLIB_EXT}}"
LIB_NAME="${NAME##*/}"
DSTDIR="${NAME%${LIB_NAME}}"
[ -n "${DSTDIR}" ] || DSTDIR="./"

if [ $# -lt 2 ] || [ -z "${LIB_NAME}" ]
then
   echo "usage: `basename $0` <target[${SLIB_EXT}]> [link options] src1.a .. srcN.a [obj1.o .. objN.o]"
   exit 1
fi

shift

BASE=`echo ${LIB_NAME} | sed "s/\([^.-]*\)[.-][0-9.]*/\1/g"`
VERSION="${LIB_NAME#${BASE}}"
VERSION="${VERSION#[.-]}"
REVIS="${VERSION}"
MAJOR="${REVIS%%.*}"
REVIS="${REVIS#${MAJOR}}"
REVIS="${REVIS#.}"
MINOR="${REVIS%%.*}"
REVIS="${REVIS#${MINOR}}"
REVIS="${REVIS#.}"
REVIS="${REVIS%%.*}"
[ -n "${MAJOR}" ] || MAJOR=2
[ -n "${MINOR}" ] || MINOR=0
[ -n "${REVIS}" ] || REVIS=0
VERSION="${MAJOR}.${MINOR}.${REVIS}"

OTMPDIR=""
dir=`pwd`

cleanup()
{
   [ -z "${OTMPDIR}" ] || rm -fR "${OTMPDIR}"
}

trap cleanup EXIT >/dev/null 2>&1

if [ "${SLIB_EXT}" != ".dylib" ]; then

   OTMPDIR="/tmp/hb-mkdyn-$$"
   rm -fR "${OTMPDIR}"
   mkdir -p "${OTMPDIR}"
   cd "${OTMPDIR}"

   for f in $*
   do
      case "${f}" in
         *.o)
            if [ "${f#/}" == "${f}" ]; then
               f="${dir}/${f}"
            fi
            if [ ! -r "${f}" ]; then
               echo "cannot read file: ${f}"
               exit 1
            fi
            cp "${f}" "${OTMPDIR}" || exit 1
            ;;
         *.a)
            if [ "${f#/}" == "${f}" ]; then
               f="${dir}/${f}"
            fi
            if [ ! -r "${f}" ]; then
               echo "cannot read file: ${f}"
               exit 1
            fi
            d="${f%.a}"
            d="${f##*/}"
            mkdir $d
            cd $d
            ${HB_CCPATH}${HB_CCPREFIX}ar -x "${f}" || exit 1
            cd ..
            ;;
         *)
            linker_options="${linker_options} ${f}"
            ;;
      esac
   done
   cd "${OTMPDIR}"
   OBJLST=`find . -name \*.o`
fi

if [ "${SLIB_EXT}" = ".dylib" ]; then
   FULLNAME="${BASE}.${VERSION}${SLIB_EXT}"
   libtool -dynamic -install_name "${BASE}${SLIB_EXT}" \
       -compatibility_version ${MAJOR}.${MINOR} -current_version ${VERSION} \
       -flat_namespace -undefined warning -multiply_defined suppress -single_module ${HB_USER_DFLAGS} \
       -o "${DSTDIR}/${FULLNAME}" "$@" && \
   ln -sf "${FULLNAME}" "${DSTDIR}${BASE}.${MAJOR}${SLIB_EXT}" && \
   ln -sf "${FULLNAME}" "${DSTDIR}${BASE}${SLIB_EXT}"
elif [ "${SLIB_EXT}" = ".dll" ]; then
   FULLNAME="${LIB_NAME}${SLIB_EXT}"
   if [ "$HB_COMPILER" = "mingwarm" ]; then
      SYSLIBS="-lws2"
   else
      SYSLIBS="-luser32 -lws2_32 -ladvapi32 -lgdi32"
   fi
   # -Wl,--output-def,testdll.def,--out-implib,libtestdll.a
   ${HB_CCPATH}${HB_CCPREFIX}gcc -shared -o "${FULLNAME}" $OBJLST ${linker_options} ${HB_USER_DFLAGS} ${SYSLIBS} ${HB_DLLIBS} && \
       cd "${dir}" && \
       rm -f "${DSTDIR}${FULLNAME}" && \
       mv -f "${OTMPDIR}/${FULLNAME}" "${DSTDIR}${FULLNAME}"
else
   #FULLNAME="${BASE}-${VERSION}${SLIB_EXT}"
   #FULLNAME="${BASE}{SLIB_EXT}.${VERSION}"
   FULLNAME="${LIB_NAME}${SLIB_EXT}"
   ${HB_CCPATH}${HB_CCPREFIX}gcc -shared -o "${FULLNAME}" $OBJLST ${linker_options} ${HB_USER_DFLAGS} && \
       cd "${dir}" && \
       mv -f "${OTMPDIR}/${FULLNAME}" "${DSTDIR}${FULLNAME}"
fi

stat="$?"
[ $stat != 0 ] && cd "${dir}" && rm -f "${DSTDIR}${FULLNAME}"
cleanup
exit "${stat}"
