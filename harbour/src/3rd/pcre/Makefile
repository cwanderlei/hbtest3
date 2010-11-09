#
# $Id$
#

ROOT := ../../../

include $(TOP)$(ROOT)config/global.mk

HB_BUILD_WARN := no
HB_BUILD_MODE := c

C_SOURCES := \
   chartabs.c \
   pcrecomp.c \
   pcreconf.c \
   pcredfa.c \
   pcreexec.c \
   pcrefinf.c \
   pcreget.c \
   pcreglob.c \
   pcreinfo.c \
   pcremktb.c \
   pcrenewl.c \
   pcreoutf.c \
   pcrerefc.c \
   pcrestud.c \
   pcretabs.c \
   pcretryf.c \
   pcreucd.c \
   pcrever.c \
   pcrevutf.c \
   pcrexcls.c \

LIBNAME := hbpcre

ifneq ($(HB_HAS_PCRE_LOCAL),)

   HB_CFLAGS += -DHAVE_STDINT_H=0
   # only needed for win/wce, for other platforms this is noop
   HB_CFLAGS_STA := -DPCRE_STATIC

   ifneq ($(filter $(HB_COMPILER),bcc msvc msvc64 msvcia64 icc iccia64 djgpp),)
      HB_CFLAGS += -DHAVE_INTTYPES_H=0
   else
   ifneq ($(filter $(HB_PLATFORM),vxworks),)
      HB_CFLAGS += -DHAVE_INTTYPES_H=0
   endif
   endif

   HB_CFLAGS += -DHAVE_CONFIG_H

   # workaround for problems in sunpro x86 PIC builds exploited by hbpcre library code
   ifeq ($(HB_COMPILER),sunpro)
      ifeq ($(HB_PLATFORM),sunos)
         ifeq ($(findstring sparc,$(shell isalist)),)
            HB_CFLAGS += -xbuiltin=%none
         endif
      else
         HB_CFLAGS += -xbuiltin=%none
      endif
   endif

   # suppress bcc warnings
   ifeq ($(HB_COMPILER),bcc)
      HB_CFLAGS += -w-use -w-csu -w-aus -w-sig
   endif

   include $(TOP)$(ROOT)config/lib.mk
else
   HB_SKIP_REASON := unused
   include $(TOP)$(ROOT)config/none.mk
endif

# ORIGIN http://www.pcre.org/
# VER    8.10
# URL    http://sourceforge.net/projects/pcre/files/pcre/8.10/pcre-8.10.zip/download
# DIFF   pcre.dif
#
# MAP    LICENCE
# MAP    config.h.generic       config.h
# MAP    pcre.h.generic         pcre.h
# MAP    pcre_internal.h        pcreinal.h
# MAP    ucp.h
# MAP    pcre_chartables.c.dist chartabs.c
# MAP    pcre_compile.c         pcrecomp.c
# MAP    pcre_config.c          pcreconf.c
# MAP    pcre_dfa_exec.c        pcredfa.c
# MAP    pcre_exec.c            pcreexec.c
# MAP    pcre_fullinfo.c        pcrefinf.c
# MAP    pcre_get.c             pcreget.c
# MAP    pcre_globals.c         pcreglob.c
# MAP    pcre_info.c            pcreinfo.c
# MAP    pcre_maketables.c      pcremktb.c
# MAP    pcre_newline.c         pcrenewl.c
# MAP    pcre_ord2utf8.c        pcreoutf.c
# MAP    pcre_printint.src      pcreprni.h
# MAP    pcre_refcount.c        pcrerefc.c
# MAP    pcre_study.c           pcrestud.c
# MAP    pcre_tables.c          pcretabs.c
# MAP    pcre_try_flipped.c     pcretryf.c
# MAP    pcre_ucd.c             pcreucd.c
# MAP    pcre_valid_utf8.c      pcrevutf.c
# MAP    pcre_version.c         pcrever.c
# MAP    pcre_xclass.c          pcrexcls.c