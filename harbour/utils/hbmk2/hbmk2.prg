/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Harbour Make
 *
 * Copyright 1999-2009 Viktor Szakats <harbour.01 syenar.hu>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

/*
 * The following parts are Copyright of the individual authors.
 * www - http://www.harbour-project.org
 *
 * Copyright 2003 Przemyslaw Czerpak <druzus@priv.onet.pl>
 *    gcc and *nix configuration elements.
 *    bash script with similar purpose for gcc family.
 *    entry point override method and detection code for gcc.
 *
 * See doc/license.txt for licensing terms.
 *
 */

#include "common.ch"
#include "directry.ch"
#include "fileio.ch"
#include "hbgtinfo.ch"
#include "hbver.ch"

/* NOTE: Keep this code clean from any kind of contribs and Harbour
         level 3rd party library/tool information. This (the hbmk)
         component shall only contain hard-wired knowledge on Harbour
         _core_ (official interfaces preferred), C compilers and OS
         details on the smallest possible level.
         Instead, 3rd party Harbour packages are recommended to
         maintain and provide .hbp files themselves, as part of
         their standard distribution packages. You can find a few
         such .hbp examples in the 'examples' directory.
         For Harbour contribs, the recommended method is to supply
         and maintain .hbp files in their respective directories,
         usually under tests (or utils, samples). As of this
         writing, most of them has one created.
         Thank you. [vszakats] */

/* TODO: Sync default c/linker switches with Harbour build systems. */
/* TODO: Add support for wildcarded input source. Only if only one source file is specified. */
/* TODO: Add support for Windows resource files. */
/* TODO: Add support for library creation. */
/* TODO: msvc/bcc32: Use separate link phase. This allows incremental links. */
/* TODO: Support for more compilers/platforms. */
/* TODO: Cross compilation support. */
/* TODO: Cleanup on variable names and compiler configuration. */

ANNOUNCE HB_GTSYS
REQUEST HB_GT_CGI_DEFAULT

REQUEST hbm_ARCH
REQUEST hbm_COMP

THREAD STATIC t_lQuiet := .T.
THREAD STATIC t_lInfo := .F.
THREAD STATIC t_cARCH
THREAD STATIC t_cCOMP
THREAD STATIC t_aLIBCOREGT
THREAD STATIC t_cGTDEFAULT

THREAD STATIC t_cCCPATH
THREAD STATIC t_cCCPREFIX

FUNCTION Main( ... )

   LOCAL aLIB_BASE1 := {;
      "hbcpage" ,;
      "hblang" ,;
      "hbcommon" }

   /* NOTE: All base GTs should come here. */
   LOCAL aLIB_BASE2 := {;
      "hbrtl" ,;
      "hbpp" ,;
      "hbmacro" ,;
      "hbextern" }

   LOCAL aLIB_BASE_GT := {;
      "gtcgi" ,;
      "gtpca" ,;
      "gtstd" }

   LOCAL aLIB_BASE_PCRE := {;
      "hbpcre" }

   LOCAL aLIB_BASE_ZLIB := {;
      "hbzlib" }

   LOCAL aLIB_BASE_DEBUG := {;
      "hbdebug" }

   LOCAL aLIB_BASE_CPLR := {;
      "hbcplr" }

   LOCAL aLIB_BASE_ST := {;
      "hbvm" }
   LOCAL aLIB_BASE_MT := {;
      "hbvmmt" }

   LOCAL aLIB_BASE_NULRDD := {;
      "hbnulrdd" }

   LOCAL aLIB_BASE_RDD := {;
      "hbrdd" ,;
      "hbusrrdd" ,;
      "hbuddall" ,;
      "hbhsx" ,;
      "hbsix" ,;
      "rddntx" ,;
      "rddnsx" ,;
      "rddcdx" ,;
      "rddfpt" }

   LOCAL s_cGT
   LOCAL s_cCSTUB

   LOCAL s_cHB_INSTALL_PREFIX
   LOCAL s_cHB_BIN_INSTALL
   LOCAL s_cHB_LIB_INSTALL
   LOCAL s_cHB_INC_INSTALL

   LOCAL s_aPRG
   LOCAL s_aC
   LOCAL s_aRESSRC
   LOCAL s_aRESCMP
   LOCAL s_aLIBSHARED
   LOCAL s_aLIB
   LOCAL s_aLIBVM
   LOCAL s_aLIBUSER
   LOCAL s_aLIBUSERGT
   LOCAL s_aLIBHB
   LOCAL s_aLIBHBGT
   LOCAL s_aLIB3RD
   LOCAL s_aLIBSYS
   LOCAL s_aLIBPATH
   LOCAL s_aOPTPRG
   LOCAL s_aOPTC
   LOCAL s_aOPTL
   LOCAL s_cPROGDIR
   LOCAL s_cPROGNAME
   LOCAL s_cMAPNAME
   LOCAL s_cFIRST
   LOCAL s_aOBJ
   LOCAL s_aOBJA
   LOCAL s_aOBJUSER
   LOCAL s_aCLEAN
   LOCAL s_lHB_PCRE := .T.
   LOCAL s_lHB_ZLIB := .T.
   LOCAL s_cMAIN := NIL

   LOCAL s_lGUI := .F.
   LOCAL s_lMT := .F.
   LOCAL s_lSHARED := .F.
   LOCAL s_lSTATICFULL := .F.
   LOCAL s_lDEBUG := .F.
   LOCAL s_lNULRDD := .F.
   LOCAL s_lMAP := .F.
   LOCAL s_lSTRIP := .F.
   LOCAL s_lTRACE := .F.
   LOCAL s_lBLDFLGP := .F.
   LOCAL s_lBLDFLGC := .F.
   LOCAL s_lBLDFLGL := .F.
   LOCAL s_lRUN := .F.
   LOCAL s_lFMSTAT := NIL /* NIL = default, .T. = on, .F. = off */

   LOCAL aCOMPDET
   LOCAL aCOMPSUP

   LOCAL cLibPrefix
   LOCAL cLibExt
   LOCAL cObjPrefix
   LOCAL cObjExt
   LOCAL cLibPathPrefix
   LOCAL cLibPathSep

   LOCAL cCommand
   LOCAL cOpt_CompC
   LOCAL cOpt_Link
   LOCAL cBin_CompPRG
   LOCAL cBin_CompC
   LOCAL cBin_Link
   LOCAL nErrorLevel
   LOCAL tmp, array
   LOCAL cScriptFile
   LOCAL fhnd
   LOCAL lNOHBP
   LOCAL lSysLoc
   LOCAL cSelfCOMP

   LOCAL lStopAfterHarbour := .F.
   LOCAL lStopAfterCComp := .F.

   LOCAL aParams
   LOCAL cParam

   LOCAL cDir, cName, cExt

   LOCAL cSelfFlagPRG := hb_Version( HB_VERSION_FLAG_PRG )
   LOCAL cSelfFlagC   := hb_Version( HB_VERSION_FLAG_C )
   LOCAL cSelfFlagL   := hb_Version( HB_VERSION_FLAG_LINKER )

   LOCAL cDL_Version_NonGNU := hb_ntos( hb_Version( HB_VERSION_MAJOR ) ) +;
                               hb_ntos( hb_Version( HB_VERSION_MINOR ) )
   LOCAL cDL_Version        := hb_ntos( hb_Version( HB_VERSION_MAJOR ) ) + "." +;
                               hb_ntos( hb_Version( HB_VERSION_MINOR ) ) + "." +;
                               hb_ntos( hb_Version( HB_VERSION_RELEASE ) )

   IF PCount() == 0
      ShowHeader()
      ShowHelp()
      PauseForKey()
      RETURN 9
   ENDIF

   FOR EACH cParam IN hb_AParams()
      /* NOTE: Don't forget to make these ignored in the main
               option processing loop. */
      DO CASE
      CASE Lower( cParam )            == "-quiet" ; t_lQuiet := .T. ; t_lInfo := .F.
      CASE Lower( Left( cParam, 6 ) ) == "-comp=" ; t_cCOMP := SubStr( cParam, 7 )
      CASE Lower( Left( cParam, 6 ) ) == "-arch=" ; t_cARCH := SubStr( cParam, 7 )
      CASE Lower( cParam )            == "-hbcc"  ; t_lQuiet := .T. ; t_lInfo := .F. ; lStopAfterHarbour := .T.
      CASE Lower( cParam )            == "-hbcmp" ; t_lQuiet := .T. ; t_lInfo := .F. ; lStopAfterHarbour := .F. ; lStopAfterCComp := .T.
      CASE Lower( cParam )            == "-hblnk" ; t_lQuiet := .T. ; t_lInfo := .F.
      CASE Lower( cParam )            == "-info"  ; t_lInfo := .T.
      CASE Lower( cParam ) == "-help" .OR. ;
           Lower( cParam ) == "--help"

         ShowHeader()
         ShowHelp( .T. )
         PauseForKey()
         RETURN 9

      ENDCASE
   NEXT

   tmp := Lower( FN_NameGet( hb_argv( 0 ) ) )
   DO CASE
   CASE Right( tmp, 4 ) == "hbcc" .OR. ;
        Left(  tmp, 4 ) == "hbcc"
      t_lQuiet := .T. ; t_lInfo := .F. ; lStopAfterHarbour := .T.
      IF t_lInfo
         OutStd( "hbmk: Enabled -hbcc option." + hb_osNewLine() )
      ENDIF
   CASE Right( tmp, 5 ) == "hbcmp" .OR. ;
        Left(  tmp, 5 ) == "hbcmp"
      t_lQuiet := .T. ; t_lInfo := .F. ; lStopAfterHarbour := .F. ; lStopAfterCComp := .T.
      IF t_lInfo
         OutStd( "hbmk: Enabled -hbcmp option." + hb_osNewLine() )
      ENDIF
   CASE Right( tmp, 5 ) == "hblnk" .OR. ;
        Left(  tmp, 5 ) == "hblnk"
      t_lQuiet := .T. ; t_lInfo := .F.
      IF t_lInfo
         OutStd( "hbmk: Enabled -hblnk option." + hb_osNewLine() )
      ENDIF
   ENDCASE

   IF ! t_lQuiet
      ShowHeader()
   ENDIF

   /* Load architecture / compiler settings (compatibility) */

   IF Empty( t_cARCH )
      t_cARCH := Lower( GetEnv( "HB_ARCHITECTURE" ) )
   ENDIF
   IF Empty( t_cCOMP )
      t_cCOMP := Lower( GetEnv( "HB_COMPILER" ) )
   ENDIF

   /* Autodetect architecture */

   IF Empty( t_cARCH )

      /* NOTE: Keep this in sync manually. All compilers should be listed here,
               which are supported on one architecture only. In the future this
               should be automatically extracted from a comp/arch matrix. */
      SWITCH t_cCOMP
      CASE "msvc"
      CASE "bcc32"
      CASE "xcc"
      CASE "pocc"
      CASE "dmc"
         t_cARCH := "win"
         EXIT
      CASE "djgpp"
         t_cARCH := "dos"
         EXIT
      OTHERWISE
#if defined( __PLATFORM__BSD )
         t_cARCH := "bsd"
#elif defined( __PLATFORM__DARWIN )
         t_cARCH := "darwin"
#elif defined( __PLATFORM__DOS )
         t_cARCH := "dos"
#elif defined( __PLATFORM__HPUX )
         t_cARCH := "hpux"
#elif defined( __PLATFORM__LINUX )
         t_cARCH := "linux"
#elif defined( __PLATFORM__OS2 )
         t_cARCH := "os2"
#elif defined( __PLATFORM__SUNOS )
         t_cARCH := "sunos"
#elif defined( __PLATFORM__WINDOWS )
         t_cARCH := "win"
#endif
      ENDSWITCH
      IF ! Empty( t_cARCH )
         IF t_lInfo
            OutStd( "hbmk: Autodetected HB_ARCHITECTURE: " + t_cARCH + hb_osNewLine() )
         ENDIF
      ENDIF
   ENDIF

   /* Setup architecture dependent data */

   DO CASE
   CASE t_cARCH $ "bsd|hpux|sunos" .OR. t_cARCH == "darwin" /* Separated to avoid match with 'win' */
      aCOMPSUP := { "gcc" }
      cBin_CompPRG := "harbour"
      s_aLIBHBGT := { "gttrm", "gtxwc" }
      t_cGTDEFAULT := "gttrm"
   CASE t_cARCH == "linux"
      aCOMPSUP := { "gcc", "gpp", "owatcom", "mingw", "mingwce" }
      cBin_CompPRG := "harbour"
      s_aLIBHBGT := { "gttrm", "gtxwc" }
      t_cGTDEFAULT := "gtstd"
   CASE t_cARCH == "dos"
      aCOMPDET := { { {|| FindInPath( "gcc"    ) != NIL }, "djgpp"   },;
                    { {|| FindInPath( "wpp386" ) != NIL }, "owatcom" } } /* TODO: Add full support for wcc386 */
      aCOMPSUP := { "djgpp", "gcc", "owatcom", "rsx32" }
      cBin_CompPRG := "harbour.exe"
      s_aLIBHBGT := { "gtdos" }
      t_cGTDEFAULT := "gtdos"
   CASE t_cARCH == "os2"
      aCOMPDET := { { {|| FindInPath( "gcc"    ) != NIL }, "gcc"     },;
                    { {|| FindInPath( "wpp386" ) != NIL }, "owatcom" },; /* TODO: Add full support for wcc386 */
                    { {|| FindInPath( "icc"    ) != NIL }, "icc"     } }
      aCOMPSUP := { "gcc", "owatcom", "icc" }
      cBin_CompPRG := "harbour.exe"
      s_aLIBHBGT := { "gtos2" }
      t_cGTDEFAULT := "gtos2"
   CASE t_cARCH == "win"
      /* Order is significant.
         owatcom also keeps a cl.exe in it's binary dir. */
      aCOMPDET := { { {|| FindInPath( "gcc"    ) != NIL }, "mingw"   },; /* TODO: Add full support for g++ */
                    { {|| FindInPath( "wpp386" ) != NIL }, "owatcom" },; /* TODO: Add full support for wcc386 */
                    { {|| FindInPath( "cl"     ) != NIL }, "msvc"    },;
                    { {|| FindInPath( "bcc32"  ) != NIL }, "bcc32"   },;
                    { {|| FindInPath( "pocc"   ) != NIL }, "pocc"    },;
                    { {|| FindInPath( "dmc"    ) != NIL }, "dmc"     },;
                    { {|| FindInPath( "icc"    ) != NIL }, "icc"     },;
                    { {|| FindInPath( "xcc"    ) != NIL }, "xcc"     } }
      /* TODO: "mingwce", "msvcce", "poccce" */
      aCOMPSUP := { "gcc", "mingw", "msvc", "bcc32", "owatcom", "pocc", "pocc64", "rsxnt", "xcc", "dmc", "icc" }
      cBin_CompPRG := "harbour.exe"
      s_aLIBHBGT := { "gtwin", "gtwvt", "gtgui" }
      t_cGTDEFAULT := "gtwin"
   OTHERWISE
      OutErr( "hbmk: Error: HB_ARCHITECTURE value unknown: " + t_cARCH + hb_osNewLine() )
      PauseForKey()
      RETURN 1
   ENDCASE

   t_aLIBCOREGT := ArrayJoin( aLIB_BASE_GT, s_aLIBHBGT )

   /* Setup GUI state for Harbour default */
   SetupForGT( t_cGTDEFAULT, NIL, @s_lGUI )

   /* Autodetect compiler */

   IF Empty( t_cCOMP ) .OR. t_cCOMP == "bld"
      IF Len( aCOMPSUP ) == 1
         t_cCOMP := aCOMPSUP[ 1 ]
      ELSEIF t_cARCH == "linux" .OR. t_cCOMP == "bld"
         t_cCOMP := SelfCOMP()
         IF AScan( aCOMPSUP, {|tmp| tmp == t_cCOMP } ) == 0
            t_cCOMP := NIL
         ENDIF
      ELSEIF ! Empty( aCOMPDET )
         /* Which compiler was used to compile ourselves? */
         cSelfCOMP := SelfCOMP()
         /* Skip it for msvc, as it creates problems for other compilers. */
         IF !( cSelfCOMP $ "msvc" )
            /* Look for this compiler first */
            FOR tmp := 1 TO Len( aCOMPDET )
               IF aCOMPDET[ tmp ][ 2 ] == cSelfCOMP .AND. Eval( aCOMPDET[ tmp ][ 1 ] )
                  t_cCOMP := aCOMPDET[ tmp ][ 2 ]
                  EXIT
               ENDIF
            NEXT
         ELSE
            cSelfCOMP := ""
         ENDIF
         IF Empty( t_cCOMP )
            /* Check the rest of compilers */
            FOR tmp := 1 TO Len( aCOMPDET )
               IF !( aCOMPDET[ tmp ][ 2 ] == cSelfCOMP ) .AND. Eval( aCOMPDET[ tmp ][ 1 ] )
                  t_cCOMP := aCOMPDET[ tmp ][ 2 ]
                  EXIT
               ENDIF
            NEXT
         ENDIF
      ENDIF
      IF ! Empty( t_cCOMP )
         IF t_lInfo
            OutStd( "hbmk: Autodetected HB_COMPILER: " + t_cCOMP + hb_osNewLine() )
         ENDIF
      ELSE
         IF Empty( aCOMPDET )
            OutErr( "hbmk: Please choose a compiler by setting envvar HB_COMPILER." + hb_osNewLine() )
            OutErr( "      You have the following choices on your platform: " + hb_osNewLine() )
            OutErr( "      " + ArrayToList( aCOMPSUP, ", " ) + hb_osNewLine() )
         ELSE
            OutErr( "hbmk: Harbour Make couldn't detect any supported C compiler" + hb_osNewLine() )
            OutErr( "      in your PATH. Please setup one or set envvar HB_COMPILER" + hb_osNewLine() )
            OutErr( "      to one of these values:" + hb_osNewLine() )
            OutErr( "      " + ArrayToList( aCOMPSUP, ", " ) + hb_osNewLine() )
         ENDIF
         PauseForKey()
         RETURN 2
      ENDIF
   ELSE
      IF AScan( aCOMPSUP, {|tmp| tmp == t_cCOMP } ) == 0
         OutErr( "hbmk: Error: HB_COMPILER value unknown." + hb_osNewLine() )
         PauseForKey()
         RETURN 2
      ENDIF
   ENDIF

   /* Autodetect Harbour environment */

   s_aLIBPATH := {}

   t_cCCPATH   := GetEnv( "CCPATH" )
   t_cCCPREFIX := GetEnv( "CCPREFIX" )

   s_cHB_BIN_INSTALL := PathSepToTarget( GetEnv( "HB_BIN_INSTALL" ) )
   s_cHB_LIB_INSTALL := PathSepToTarget( GetEnv( "HB_LIB_INSTALL" ) )
   s_cHB_INC_INSTALL := PathSepToTarget( GetEnv( "HB_INC_INSTALL" ) )

   s_cHB_INSTALL_PREFIX := PathSepToTarget( GetEnv( "HB_INSTALL_PREFIX" ) )
   IF Empty( s_cHB_INSTALL_PREFIX )
      DO CASE
      CASE hb_FileExists( DirAddPathSep( hb_DirBase() ) + cBin_CompPRG )
         s_cHB_INSTALL_PREFIX := DirAddPathSep( hb_DirBase() ) + ".."
      CASE hb_FileExists( DirAddPathSep( hb_DirBase() ) + "bin" + hb_osPathSeparator() + cBin_CompPRG )
         s_cHB_INSTALL_PREFIX := DirAddPathSep( hb_DirBase() )
      CASE hb_FileExists( DirAddPathSep( hb_DirBase() ) + ".." + hb_osPathSeparator() + ".." + hb_osPathSeparator() + "bin" + hb_osPathSeparator() + cBin_CompPRG )
         s_cHB_INSTALL_PREFIX := DirAddPathSep( hb_DirBase() ) + ".." + hb_osPathSeparator() + ".."
      CASE hb_FileExists( DirAddPathSep( hb_DirBase() ) + ".." + hb_osPathSeparator() + ".." + hb_osPathSeparator() + ".." + hb_osPathSeparator() + "bin" + hb_osPathSeparator() + cBin_CompPRG )
         s_cHB_INSTALL_PREFIX := DirAddPathSep( hb_DirBase() ) + ".." + hb_osPathSeparator() + ".." + hb_osPathSeparator() + ".."
      OTHERWISE
         OutErr( "hbmk: Error: HB_INSTALL_PREFIX not set, failed to autodetect." + hb_osNewLine() )
         PauseForKey()
         RETURN 3
      ENDCASE
      /* Detect special *nix dir layout (/bin, /lib/harbour, /include/harbour) */
      IF hb_FileExists( DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "include" +;
                                         hb_osPathSeparator() + "harbour" +;
                                         hb_osPathSeparator() + "hbvm.h" )
         IF Empty( s_cHB_BIN_INSTALL )
            s_cHB_BIN_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "bin"
         ENDIF
         IF Empty( s_cHB_LIB_INSTALL )
            s_cHB_LIB_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "lib" + hb_osPathSeparator() + "harbour"
         ENDIF
         IF Empty( s_cHB_INC_INSTALL )
            s_cHB_INC_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "include" + hb_osPathSeparator() + "harbour"
         ENDIF
      ENDIF
   ENDIF
   IF Empty( s_cHB_INSTALL_PREFIX ) .AND. ;
      ( Empty( s_cHB_BIN_INSTALL ) .OR. Empty( s_cHB_LIB_INSTALL ) .OR. Empty( s_cHB_INC_INSTALL ) )
      OutErr( "hbmk: Error: Harbour locations couldn't be determined." + hb_osNewLine() )
      PauseForKey()
      RETURN 3
   ENDIF
   IF Empty( s_cHB_BIN_INSTALL )
      s_cHB_BIN_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "bin"
   ENDIF
   IF Empty( s_cHB_LIB_INSTALL )
      s_cHB_LIB_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "lib"
   ENDIF
   IF Empty( s_cHB_INC_INSTALL )
      s_cHB_INC_INSTALL := DirAddPathSep( s_cHB_INSTALL_PREFIX ) + "include"
   ENDIF

   /* Detect system locations to enable shared library option by default */
   lSysLoc := hb_DirBase() == "/usr/local/bin/" .OR. ;
              hb_DirBase() == "/usr/bin/" .OR. ;
              hb_DirBase() == "/opt/harbour/" .OR. ;
              hb_DirBase() == "/opt/bin/"

   IF t_lInfo
      OutStd( "hbmk: Using Harbour: " + s_cHB_BIN_INSTALL + " " + s_cHB_INC_INSTALL + " " + s_cHB_LIB_INSTALL + hb_osNewLine() )
   ENDIF

   /* Add main Harbour library dir to lib path list */
   AAddNotEmpty( s_aLIBPATH, s_cHB_LIB_INSTALL )

   /* Build with shared libs by default, if we're installed to default system locations. */

   IF lSysLoc .AND. ( t_cARCH $ "bsd|hpux|sunos|linux" .OR. t_cARCH == "darwin" )
      s_lSHARED := .T.
      s_lSTATICFULL := .F.
   ENDIF

   /* Process environment */

   IF    Lower( GetEnv( "HB_MT"     ) ) == "mt" ; s_lMT     := .T. ; ENDIF /* Compatibility */
   IF ValueIsT( GetEnv( "HB_MT"     ) )         ; s_lMT     := .T. ; ENDIF
   IF ValueIsT( GetEnv( "HB_GUI"    ) )         ; s_lGUI    := .T. ; ENDIF
   IF ValueIsT( GetEnv( "HB_SHARED" ) )         ; s_lSHARED := .T. ; s_lSTATICFULL := .F. ; ENDIF
   IF ValueIsT( GetEnv( "HB_DEBUG"  ) )         ; s_lDEBUG  := .T. ; ENDIF
   IF ValueIsT( GetEnv( "HB_NULRDD" ) )         ; s_lNULRDD := .T. ; ENDIF

   IF Lower( Left( GetEnv( "HB_GT" ), 2 ) ) == "gt"
      SetupForGT( GetEnv( "HB_GT" ), @s_cGT, @s_lGUI )
   ENDIF

   /* Process command line */

   s_aPRG := {}
   s_aC := {}
   s_aOPTPRG := {}
   s_aOPTC := {}
   s_aOPTL := {}
   s_aRESSRC := {}
   s_aRESCMP := {}
   s_aLIBUSER := {}
   s_aLIBUSERGT := {}
   s_aOBJUSER := {}
   s_aOBJA := {}
   s_cPROGDIR := NIL
   s_cPROGNAME := NIL
   s_cFIRST := NIL

   /* Collect all command line parameters */
   aParams := {}
   FOR EACH cParam IN hb_AParams()
      DO CASE
      CASE ( Len( cParam ) >= 1 .AND. Left( cParam, 1 ) == "@" )
         HBM_Load( aParams, SubStr( cParam, 2 ) ) /* Load parameters from script file */
      CASE Lower( FN_ExtGet( cParam ) ) == ".hbm"
         HBM_Load( aParams, cParam ) /* Load parameters from script file */
      OTHERWISE
         AAdd( aParams, cParam )
      ENDCASE
   NEXT

   /* Process command line (1st pass) */
   lNOHBP := .F.
   FOR EACH cParam IN aParams
      IF Lower( cParam ) == "-nohbp"
         lNOHBP := .T.
      ENDIF
   NEXT

   /* Process automatic control files. */
   HBP_ProcessAll( lNOHBP,;
                   @s_aLIBUSER,;
                   @s_aLIBUSERGT,;
                   @s_aLIBPATH,;
                   @s_aOPTPRG,;
                   @s_aOPTC,;
                   @s_aOPTL,;
                   @s_lGUI,;
                   @s_lMT,;
                   @s_lSHARED,;
                   @s_lSTATICFULL,;
                   @s_lDEBUG,;
                   @s_lNULRDD,;
                   @s_lMAP,;
                   @s_lSTRIP,;
                   @s_lRUN,;
                   @s_cGT )

   /* Process command line (2nd pass) */
   FOR EACH cParam IN aParams

      DO CASE
      CASE Lower( cParam )            == "-quiet" .OR. ;
           Lower( Left( cParam, 6 ) ) == "-comp=" .OR. ;
           Lower( Left( cParam, 6 ) ) == "-arch=" .OR. ;
           Lower( cParam )            == "-hbcc"  .OR. ;
           Lower( cParam )            == "-hbcmp" .OR. ;
           Lower( cParam )            == "-hblnk" .OR. ;
           Lower( cParam )            == "-info"

         /* Simply ignore. They were already processed in the first pass. */

      CASE Lower( cParam ) == "-gui"             ; s_lGUI      := .T.
      CASE Lower( cParam ) == "-mwindows"        ; s_lGUI      := .T. /* Compatibility */
      CASE Lower( cParam ) == "-std"             ; s_lGUI      := .F.
      CASE Lower( cParam ) == "-mconsole"        ; s_lGUI      := .F. /* Compatibility */
      CASE Lower( cParam ) == "-mt"              ; s_lMT       := .T.
      CASE Lower( cParam ) == "-st"              ; s_lMT       := .F.
      CASE Lower( cParam ) == "-shared"          ; s_lSHARED   := .T. ; s_lSTATICFULL := .F.
      CASE Lower( cParam ) == "-static"          ; s_lSHARED   := .F. ; s_lSTATICFULL := .F.
      CASE Lower( cParam ) == "-fullstatic"      ; s_lSHARED   := .F. ; s_lSTATICFULL := .T.
      CASE Lower( cParam ) == "-bldf"            ; s_lBLDFLGP  := s_lBLDFLGC := s_lBLDFLGL := .T.
      CASE Lower( cParam ) == "-bldf-"           ; s_lBLDFLGP  := s_lBLDFLGC := s_lBLDFLGL := .F.
      CASE Lower( Left( cParam, 6 ) ) == "-bldf="
         cParam := SubStr( cParam, 7 )
         s_lBLDFLGP := "p" $ cParam
         s_lBLDFLGC := "c" $ cParam
         s_lBLDFLGL := "l" $ cParam
      CASE Lower( cParam ) == "-debug"           ; s_lDEBUG    := .T.
      CASE Lower( cParam ) == "-debug-"          ; s_lDEBUG    := .F.
      CASE Lower( cParam ) == "-nodebug"         ; s_lDEBUG    := .F.
      CASE Lower( cParam ) == "-nulrdd"          ; s_lNULRDD   := .T.
      CASE Lower( cParam ) == "-nulrdd-"         ; s_lNULRDD   := .F.
      CASE Lower( cParam ) == "-map"             ; s_lMAP      := .T.
      CASE Lower( cParam ) == "-map-"            ; s_lMAP      := .F.
      CASE Lower( cParam ) == "-nomap"           ; s_lMAP      := .F.
      CASE Lower( cParam ) == "-fmstat"          ; s_lFMSTAT   := .T.
      CASE Lower( cParam ) == "-fmstat-"         ; s_lFMSTAT   := .F.
      CASE Lower( cParam ) == "-nofmstat"        ; s_lFMSTAT   := .F.
      CASE Lower( cParam ) == "-strip"           ; s_lSTRIP    := .T.
      CASE Lower( cParam ) == "-strip-"          ; s_lSTRIP    := .F.
      CASE Lower( cParam ) == "-nostrip"         ; s_lSTRIP    := .F.
      CASE Lower( cParam ) == "-run"             ; s_lRUN      := .T.
      CASE Lower( cParam ) == "-run-"            ; s_lRUN      := .F.
      CASE Lower( cParam ) == "-norun"           ; s_lRUN      := .F.
      CASE Lower( cParam ) == "-trace"           ; s_lTRACE    := .T.
      CASE Lower( cParam ) == "-trace-"          ; s_lTRACE    := .F.
      CASE Lower( cParam ) == "-notrace"         ; s_lTRACE    := .F.
      CASE Lower( Left( cParam, 6 ) ) == "-main="

         IF IsValidHarbourID( cParam := SubStr( cParam, 7 ) )
            s_cMAIN := "@" + cParam
         ELSE
            OutErr( "hbmk: Warning: Invalid -main value ignored: " + cParam + hb_osNewLine() )
         ENDIF

      CASE Lower( Left( cParam, 3 ) ) == "-gt"

         cParam := SubStr( cParam, 2 )
         IF s_cGT == NIL
            IF ! SetupForGT( cParam, @s_cGT, @s_lGUI )
               OutErr( "hbmk: Warning: Invalid -gt value ignored: " + cParam + hb_osNewLine() )
               cParam := NIL
            ENDIF
         ENDIF
         IF ! Empty( cParam )
            IF AScan( t_aLIBCOREGT, {|tmp| Lower( tmp ) == Lower( cParam ) } ) == 0 .AND. ;
               AScan( s_aLIBUSERGT, {|tmp| Lower( tmp ) == Lower( cParam ) } ) == 0
               AAddNotEmpty( s_aLIBUSERGT, PathSepToTarget( cParam ) )
            ENDIF
         ENDIF

      CASE Left( cParam, 2 ) == "-o"

         tmp := PathSepToSelf( SubStr( cParam, 3 ) )
         hb_FNameSplit( tmp, @cDir, @cName, @cExt )
         IF ! Empty( cDir ) .AND. Empty( cName ) .AND. Empty( cExt )
            /* Only a dir was passed, let's store that and pick a default name later. */
            s_cPROGDIR := cDir
         ELSE
            s_cPROGDIR := NIL
            s_cPROGNAME := tmp
         ENDIF

      CASE Left( cParam, 2 ) == "-l" .AND. ;
           Len( cParam ) > 2 .AND. ;
           !( Left( cParam, 3 ) == "-l-" )       ; AAddNotEmpty( s_aLIBUSER, PathSepToTarget( ArchCompFilter( SubStr( cParam, 3 ) ) ) )
      CASE Left( cParam, 2 ) == "-L" .AND. ;
           Len( cParam ) > 2                     ; AAddNotEmpty( s_aLIBPATH, PathSepToTarget( ArchCompFilter( SubStr( cParam, 3 ) ) ) )
      CASE Left( cParam, 1 ) == "-"              ; AAdd( s_aOPTPRG , PathSepToTarget( cParam ) )
      CASE Lower( FN_ExtGet( cParam ) ) == ".hbp"

         HBP_ProcessOne( cParam,;
            @s_aLIBUSER,;
            @s_aLIBUSERGT,;
            @s_aLIBPATH,;
            @s_aOPTPRG,;
            @s_aOPTC,;
            @s_aOPTL,;
            @s_lGUI,;
            @s_lMT,;
            @s_lSHARED,;
            @s_lSTATICFULL,;
            @s_lDEBUG,;
            @s_lNULRDD,;
            @s_lMAP,;
            @s_lSTRIP,;
            @s_lRUN,;
            @s_cGT )

      CASE Lower( FN_ExtGet( cParam ) ) == ".prg"   ; AAdd( s_aPRG    , PathSepToTarget( cParam ) ) ; DEFAULT s_cFIRST TO PathSepToSelf( cParam )
      CASE Lower( FN_ExtGet( cParam ) ) == ".rc"    ; AAdd( s_aRESSRC , PathSepToTarget( cParam ) )
      CASE Lower( FN_ExtGet( cParam ) ) == ".res"   ; AAdd( s_aRESCMP , PathSepToTarget( cParam ) )
      CASE Lower( FN_ExtGet( cParam ) ) == ".a"     ; AAdd( s_aOBJA   , PathSepToTarget( cParam ) )
      CASE Lower( FN_ExtGet( cParam ) ) $ ".o|.obj" ; AAdd( s_aOBJUSER, PathSepToTarget( cParam ) ) ; DEFAULT s_cFIRST TO PathSepToSelf( cParam )
      CASE Lower( FN_ExtGet( cParam ) ) $ ".c|.cpp" ; AAdd( s_aC      , PathSepToTarget( cParam ) ) ; DEFAULT s_cFIRST TO PathSepToSelf( cParam )
      CASE Lower( FN_ExtGet( cParam ) ) $ ".lib"    ; AAddNotEmpty( s_aLIBUSER, PathSepToTarget( ArchCompFilter( cParam ) ) )
      OTHERWISE                                     ; AAdd( s_aPRG    , PathSepToTarget( cParam ) ) ; DEFAULT s_cFIRST TO PathSepToSelf( cParam )
      ENDCASE
   NEXT

   /* Start doing the make process. */
   IF ( Len( s_aPRG ) + Len( s_aC ) + Len( s_aOBJUSER ) + Len( s_aOBJA ) ) == 0
      OutErr( "hbmk: Error: No source files were specified." + hb_osNewLine() )
      PauseForKey()
      RETURN 4
   ENDIF

   /* If -o with full name wasn't specified, let's
      make it the first source file specified. */
   DEFAULT s_cPROGNAME TO s_cFIRST

   IF t_cCOMP $ "mingwce|poccce"
      t_cGTDEFAULT := "gtwvt"
   ENDIF

   IF s_cGT == t_cGTDEFAULT
      s_cGT := NIL
   ENDIF

   /* Merge user libs from command line and envvar. Command line has priority. */
   s_aLIBUSER := ArrayAJoin( { s_aLIBUSER, s_aLIBUSERGT, ListToArray( PathSepToTarget( GetEnv( "HB_USER_LIBS" ) ) ) } )

   /* Combine output dir with output name. */
   IF ! Empty( s_cPROGDIR )
      hb_FNameSplit( s_cPROGNAME, @cDir, @cName, @cExt )
      s_cPROGNAME := hb_FNameMerge( iif( Empty( cDir ), s_cPROGDIR, cDir ), cName, cExt )
   ENDIF

   /* Determine map name from output name. */
   s_cMAPNAME := PathSepToTarget( FN_ExtSet( s_cPROGNAME, ".map" ) )
   /* Set output name extension. */
   IF t_cARCH $ "os2|win|dos"
      s_cPROGNAME := FN_ExtSet( s_cPROGNAME, ".exe" )
   ELSE
      s_cPROGNAME := FN_ExtSet( s_cPROGNAME )
   ENDIF

   DO CASE
   CASE t_cARCH $ "bsd|linux|sunos"
      s_aLIBSHARED := { iif( s_lMT, "harbourmt-" + cDL_Version + ".so",;
                                    "harbour-" + cDL_Version + ".so" ) }
   CASE t_cARCH == "hpux"
      s_aLIBSHARED := { iif( s_lMT, "harbourmt-" + cDL_Version + ".sl",;
                                    "harbour-" + cDL_Version + ".sl" ) }
   CASE t_cARCH == "darwin"
      s_aLIBSHARED := { iif( s_lMT, "harbourmt-" + cDL_Version + ".dylib",;
                                    "harbour-" + cDL_Version + ".dylib" ) }
   CASE t_cARCH $ "os2|win"
      s_aLIBSHARED := { iif( s_lMT, "harbourmt",;
                                    "harbour" ) }
   OTHERWISE
      s_aLIBSHARED := NIL
   ENDCASE

   /* Harbour compilation */

   IF Len( s_aPRG ) > 0

      cCommand := DirAddPathSep( s_cHB_BIN_INSTALL ) +;
                  cBin_CompPRG +;
                  " " + ArrayToList( s_aPRG ) +;
                  " -i" + s_cHB_INC_INSTALL +;
                  iif( s_lBLDFLGP, " " + cSelfFlagPRG, "" ) +;
                  iif( ! Empty( GetEnv( "HB_USER_PRGFLAGS" ) ), " " + GetEnv( "HB_USER_PRGFLAGS" ), "" ) +;
                  iif( ! Empty( s_aOPTPRG ), " " + ArrayToList( s_aOPTPRG ), "" )

      cCommand := AllTrim( cCommand )

      IF s_lTRACE
         OutStd( "hbmk: Harbour compiler command: '" + cCommand + "'" + hb_osNewLine() )
      ENDIF

      IF ( tmp := hb_run( cCommand ) ) != 0
         OutErr( "hbmk: Error: Running Harbour compiler. " + hb_ntos( tmp ) + ": '" + cCommand + "'" + hb_osNewLine() )
         PauseForKey()
         RETURN 6
      ENDIF
   ENDIF

   IF ! lStopAfterHarbour

      /* C compilation/linking */

      s_aLIB3RD := {}
      s_aLIBSYS := {}
      s_aCLEAN := {}

      /* Command macros:

         {LC}     list of C files
         {LO}     list of object files
         {LA}     list of object archive (.a) files
         {LL}     list of lib files
         {FC}     flags for C compiler (user + automatic)
         {FL}     flags for linker (user + automatic)
         {OD}     output dir
         {OO}     output object (when in -hbcmp mode)
         {OE}     output executable
         {DB}     dir for binaries
         {DI}     dir for includes
         {DL}     dir for libs
         {SCRIPT} save command line to script and pass it to command as @<filename>
      */

      /* Assemble library list */

      s_aLIBVM := iif( s_lMT, aLIB_BASE_MT, aLIB_BASE_ST )
      aLIB_BASE2 := ArrayAJoin( { aLIB_BASE2, t_aLIBCOREGT } )

      IF ! Empty( s_cGT )
         IF AScan( aLIB_BASE2, {|tmp| Lower( tmp ) == Lower( s_cGT ) } ) == 0
            AAdd( aLIB_BASE2, s_cGT )
         ENDIF
      ENDIF

      HB_SYMBOL_UNUSED( s_aRESSRC )
      HB_SYMBOL_UNUSED( s_aRESCMP )

      DO CASE
      /* GCC family */
      CASE ( t_cARCH == "bsd"    .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "darwin" .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "hpux"   .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "sunos"  .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "linux"  .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "linux"  .AND. t_cCOMP == "gpp" )

         cLibPrefix := "-l"
         cLibExt := ""
         cObjExt := ".o"
         cBin_CompC := t_cCCPREFIX + iif( t_cCOMP == "gpp", "g++", "gcc" )
         IF ! Empty( t_cCCPATH )
            cBin_CompC := t_cCCPATH + "/" + cBin_CompC
         ENDIF
         cOpt_CompC := "{LC} {LO} {LA} -O3 {FC} -I{DI} {DL}"
         cLibPathPrefix := "-L"
         cLibPathSep := " "
         IF t_cARCH == "linux" .OR. ;
            t_cARCH == "bsd"
            cOpt_CompC += " -Wl,--start-group {LL} -Wl,--end-group"
         ELSE
            cOpt_CompC += " {LL}"
            aLIB_BASE2 := ArrayAJoin( { aLIB_BASE2, { "hbcommon", "hbrtl" }, s_aLIBVM } )
         ENDIF
         IF s_lGUI
            cOpt_CompC += " -Wl,-mwindows"
         ENDIF
         IF s_lMAP
            cOpt_CompC += " -Wl,-Map " + s_cMAPNAME
         ENDIF
         IF t_cARCH == "darwin"
            AAdd( s_aOPTC, "-no-cpp-precomp" )
            AAdd( s_aOPTC, "-Wno-long-double" )
            IF s_lSHARED
               AAdd( s_aOPTC, "-bind_at_load" )
               AAdd( s_aOPTC, "-multiply_defined suppress" )
            ENDIF
         ENDIF
         IF s_lSTRIP .AND. !( t_cARCH == "sunos" )
            AAdd( s_aOPTC, "-s" )
         ENDIF
         IF lStopAfterCComp
            AAdd( s_aOPTC, "-c" )
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               IF t_cARCH == "darwin"
                  AAdd( s_aOPTC, "-o {OO}" )
               ELSE
                  AAdd( s_aOPTC, "-o{OO}" )
               ENDIF
            ENDIF
         ELSE
            IF t_cARCH == "darwin"
               AAdd( s_aOPTC, "-o {OE}" )
            ELSE
               AAdd( s_aOPTC, "-o{OE}" )
            ENDIF
         ENDIF

         /* Always inherit/reproduce some flags from self */

         IF     "-mlp64" $ cSelfFlagC ; AAdd( s_aOPTC, "-mlp64" )
         ELSEIF "-mlp32" $ cSelfFlagC ; AAdd( s_aOPTC, "-mlp32" )
         ELSEIF "-m64"   $ cSelfFlagC ; AAdd( s_aOPTC, "-m64" )
         ELSEIF "-m32"   $ cSelfFlagC ; AAdd( s_aOPTC, "-m32" )
         ENDIF

         IF     "-fPIC"  $ cSelfFlagC ; AAdd( s_aOPTC, "-fPIC" )
         ELSEIF "-fpic"  $ cSelfFlagC ; AAdd( s_aOPTC, "-fpic" )
         ENDIF

         DO CASE
         CASE "-DHB_PCRE_REGEX" $ cSelfFlagC
            AAdd( s_aLIBSYS, "pcre" )
            s_lHB_PCRE := .F.
         CASE "-DHB_POSIX_REGEX" $ cSelfFlagC
            s_lHB_PCRE := .F.
         ENDCASE
         IF "-DHB_EXT_ZLIB" $ cSelfFlagC
            AAdd( s_aLIBSYS, "z" )
            s_lHB_ZLIB := .F.
         ENDIF
         IF "-DHAVE_GPM_H" $ cSelfFlagC
            AAdd( s_aLIBSYS, "gpm" )
         ENDIF

         /* Add system libraries */
         AAdd( s_aLIBSYS, "m" )
         IF s_lMT
            AAdd( s_aLIBSYS, "pthread" )
         ENDIF
         DO CASE
         CASE t_cARCH == "linux"
            AAdd( s_aLIBSYS, "dl" )
            AAdd( s_aLIBSYS, "rt" )
#if 0
            IF ! s_lSHARED .AND. s_lSTATICFULL
               AAdd( s_aLIBSYS, "pthread" )
            ENDIF
#endif
         CASE t_cARCH == "sunos"
            AAdd( s_aLIBSYS, "rt" )
            AAdd( s_aLIBSYS, "socket" )
            AAdd( s_aLIBSYS, "nsl" )
            AAdd( s_aLIBSYS, "resolv" )
         CASE t_cARCH == "hpux"
            AAdd( s_aLIBSYS, "rt" )
         ENDCASE

         IF IsGTRequested( s_cGT, s_aLIBUSERGT, "gtcrs" )
            /* TOFIX: Sometimes 'ncur194' is needed. */
            AAdd( s_aLIBSYS, "ncurses" )
         ENDIF
         IF IsGTRequested( s_cGT, s_aLIBUSERGT, "gtsln" )
            AAdd( s_aLIBSYS, "slang" )
            /* Add paths, where this isn't a system component */
            DO CASE
            CASE t_cARCH == "darwin"
               AAdd( s_aLIBPATH, "/sw/lib" )
               AAdd( s_aLIBPATH, "/opt/local/lib" )
            CASE t_cARCH == "bsd"
               AAdd( s_aLIBPATH, "/usr/local/lib" )
            ENDCASE
         ENDIF
         IF IsGTRequested( s_cGT, s_aLIBUSERGT, "gtxwc" )
            IF hb_DirExists( "/usr/X11R6/lib64" )
               AAdd( s_aLIBPATH, "/usr/X11R6/lib64" )
            ENDIF
            AAdd( s_aLIBPATH, "/usr/X11R6/lib" )
            AAdd( s_aLIBSYS, "X11" )
         ENDIF

         IF s_lFMSTAT != NIL .AND. s_lFMSTAT
            AAdd( iif( s_lSHARED, s_aLIBSHARED, s_aLIBUSER ), iif( s_lMT, "hbfmmt", "hbfm" ) )
         ENDIF

      CASE ( t_cARCH == "win" .AND. t_cCOMP == "gcc" ) .OR. ;
           ( t_cARCH == "win" .AND. t_cCOMP == "mingw" ) .OR. ;
           ( t_cARCH == "win" .AND. t_cCOMP == "rsxnt" )

         cLibPrefix := "-l"
         cLibExt := NIL
         cObjExt := ".o"
         cBin_CompC := "gcc"
         cOpt_CompC := "{LC} {LO} {LA} -O3 {FC} -I{DI} {DL}"
         cLibPathPrefix := "-L"
         cLibPathSep := " "
         IF s_lGUI
            cOpt_CompC += " -mwindows"
         ELSE
            cOpt_CompC += " -mconsole"
         ENDIF
         IF s_lMAP
            cOpt_CompC += " -Wl,-Map " + s_cMAPNAME
         ENDIF
         IF s_lSHARED
            cOpt_CompC += " -L{DB}"
         ENDIF
         IF t_cCOMP == "gcc"
            cOpt_CompC += " -mno-cygwin"
         ENDIF
         IF t_cCOMP == "rsxnt"
            cOpt_CompC += " -Zwin32"
         ENDIF
         IF t_cCOMP == "mingw"
            cOpt_CompC += " -Wl,--start-group {LL} -Wl,--end-group"
         ELSE
            cOpt_CompC += " {LL}"
            aLIB_BASE2 := ArrayAJoin( { aLIB_BASE2, { "hbcommon", "hbrtl" }, s_aLIBVM } )
         ENDIF
         IF s_lSTRIP
            AAdd( s_aOPTC, "-s" )
         ENDIF
         IF lStopAfterCComp
            AAdd( s_aOPTC, "-c" )
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               AAdd( s_aOPTC, "-o{OO}" )
            ENDIF
         ELSE
            AAdd( s_aOPTC, "-o{OE}" )
         ENDIF
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "user32", "winspool", "gdi32", "comctl32", "comdlg32", "ole32", "oleaut32", "uuid", "wsock32", "ws2_32" } )
         s_aLIBSHARED := { iif( s_lMT, "harbourmt", "harbour" ) }

         IF s_lFMSTAT != NIL .AND. s_lFMSTAT
            AAdd( iif( s_lSHARED, s_aLIBSHARED, s_aLIBUSER ), iif( s_lMT, "hbfmmt", "hbfm" ) )
         ENDIF

      CASE ( t_cARCH == "dos" .AND. t_cCOMP == "djgpp" ) .OR. ;
           ( t_cARCH == "dos" .AND. t_cCOMP == "rsx32" )

         cLibPrefix := "-l"
         cLibExt := ""
         cObjExt := ".o"
         cBin_CompC := "gcc"
         cOpt_CompC := "{LC} {LO} {LA} -O3 {FC} -I{DI} {DL}{SCRIPT}"
         cLibPathPrefix := "-L"
         cLibPathSep := " "
         IF t_cCOMP == "rsx32"
            cOpt_CompC  += " -Zrsx32"
         ENDIF
         IF t_cCOMP == "djgpp"
            cOpt_CompC += " -Wl,--start-group {LL} -Wl,--end-group"
         ELSE
            cOpt_CompC += " {LL}"
            aLIB_BASE2 := ArrayAJoin( { aLIB_BASE2, { "hbcommon", "hbrtl" }, s_aLIBVM } )
         ENDIF
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "m" } )
         IF s_lSTRIP
            AAdd( s_aOPTC, "-s" )
         ENDIF
         IF lStopAfterCComp
            AAdd( s_aOPTC, "-c" )
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               AAdd( s_aOPTC, "-o{OO}" )
            ENDIF
         ELSE
            AAdd( s_aOPTC, "-o{OE}" )
         ENDIF

      /* Watcom family */
      CASE t_cARCH == "dos" .AND. t_cCOMP == "owatcom"
         cLibPrefix := "LIB "
         cLibExt := ".lib"
         cObjPrefix := "FILE "
         cObjExt := ".obj"
         cLibPathPrefix := "LIBPATH "
         cLibPathSep := " "
         cBin_CompC := "wpp386"
         cOpt_CompC := "-j -w3 -5s -5r -fp5 -oxehtz -zq -zt0 -bt=DOS {FC} {LC}"
         cBin_Link := "wlink"
         cOpt_Link := "OP osn=DOS OP stack=65536 OP CASEEXACT OP stub=cwstub.exe {FL} NAME {OE} {LO} {DL} {LL}{SCRIPT}"
         IF s_lDEBUG
            cOpt_Link := "DEBUG " + cOpt_Link
         ENDIF

      CASE t_cARCH == "win" .AND. t_cCOMP == "owatcom"
         cLibPrefix := "LIB "
         cLibExt := ".lib"
         cObjPrefix := "FILE "
         cObjExt := ".obj"
         cLibPathPrefix := "LIBPATH "
         cLibPathSep := " "
         cBin_CompC := "wpp386"
         cOpt_CompC := "-w3 -5s -5r -fp5 -onaehtzr -zq -zt0 -bt=NT -oi+ -s {FC} {LC}"
         cBin_Link := "wlink"
         cOpt_Link := "OP osn=NT OP stack=65536 OP CASEEXACT {FL} NAME {OE} {LO} {DL} {LL}{SCRIPT}"
         IF s_lDEBUG
            cOpt_Link := "DEBUG " + cOpt_Link
         ENDIF
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "kernel32", "user32", "wsock32" } )

      /* OS/2 compilers */
      CASE t_cARCH == "os2"

         DO CASE
         CASE t_cCOMP == "gcc"
            cLibPrefix := "-l"
            cLibExt := ""
            cObjExt := ".o"
            cBin_CompC := "gcc"
            /* OS/2 needs a space between -o and file name following it */
            cOpt_CompC := "{LC} {LO} -O3 {FC} -I{DI} {DL}"
            cLibPathPrefix := "-L"
            cLibPathSep := " "
            IF s_lMAP
               cOpt_CompC += " -Wl,-Map " + s_cMAPNAME
            ENDIF
            IF s_lSHARED
               cOpt_CompC += " -L{DB}"
            ENDIF
            cOpt_CompC += " {LL}"
            aLIB_BASE2 := ArrayAJoin( { aLIB_BASE2, { "hbcommon", "hbrtl" }, s_aLIBVM } )
            s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "socket" } )
            IF s_lSTRIP
               AAdd( s_aOPTC, "-s" )
            ENDIF
            IF lStopAfterCComp
               AAdd( s_aOPTC, "-c" )
               IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
                  AAdd( s_aOPTC, "-o {OO}" )
               ENDIF
            ELSE
               AAdd( s_aOPTC, "-o {OE}" )
            ENDIF

         CASE t_cCOMP == "owatcom"
            cLibPrefix := "LIB "
            cLibExt := ".lib"
            cObjPrefix := "FILE "
            cObjExt := ".obj"
            cLibPathPrefix := "LIBPATH "
            cLibPathSep := " "
            cBin_CompC := "wpp386"
            cOpt_CompC := "-j -w3 -5s -5r -fp5 -oxehtz -zq -zt0 -mf -bt=OS2 {FC} {LC}"
            cBin_Link := "wlink"
            cOpt_Link := "OP stack=65536 OP CASEEXACT {FL} NAME {OE} {LO} {DL} {LL}{SCRIPT}"
            IF s_lDEBUG
               cOpt_Link := "DEBUG " + cOpt_Link
            ENDIF

         CASE t_cCOMP == "icc"
            cLibPrefix := ""
            cLibExt := ".lib"
            cObjExt := ".obj"
            cLibPathPrefix := NIL /* TODO */
            cLibPathSep := NIL /* TODO */
            cBin_CompC := "icc"
            cOpt_CompC := "/Gs+ /W2 /Se /Sd+ /Ti+ /C- /Tp {FC} -I{DI} {LC}" /* TODO: {DL} */
            IF s_lDEBUG
               AAdd( s_aOPTC, "-MTd -Zi" )
            ENDIF
            IF s_lGUI
               AAdd( s_aOPTL, "/subsystem:windows" )
            ELSE
               AAdd( s_aOPTL, "/subsystem:console" )
            ENDIF
         ENDCASE

      CASE t_cARCH == "linux" .AND. t_cCOMP == "owatcom"
         cLibPrefix := "LIB "
         cLibExt := ".lib"
         cObjPrefix := "FILE "
         cObjExt := ".obj"
         cLibPathPrefix := "LIBPATH "
         cLibPathSep := " "
         cBin_CompC := "wpp386"
         cOpt_CompC := "-j -w3 -5s -5r -fp5 -oxehtz -zq -zt0 -mf -bt=LINUX {FC} {LC}"
         cBin_Link := "wlink"
         cOpt_Link := "ALL SYS LINUX OP CASEEXACT {FL} NAME {OE} {LO} {DL} {LL}{SCRIPT}"
         IF s_lDEBUG
            cOpt_Link := "DEBUG " + cOpt_Link
         ENDIF

      /* Misc */
      CASE t_cARCH == "win" .AND. t_cCOMP == "bcc32"
         IF s_lDEBUG
            AAdd( s_aOPTC, "-y -v" )
         ELSE
            AAdd( s_aCLEAN, PathSepToTarget( FN_ExtSet( s_cPROGNAME, ".tds" ) ) )
         ENDIF
         IF s_lGUI
            AAdd( s_aOPTC, "-tW" )
         ENDIF
         cLibPrefix := NIL
         cLibExt := ".lib"
         cObjExt := ".obj"
         cBin_CompC := "bcc32"
         cOpt_CompC := "-q -tWM -O2 -OS -Ov -Oi -Oc -d {FC} -I{DI} -L{DL} {LC} {LO} {LL}"
         cLibPathPrefix := ""
         cLibPathSep := ";"
         IF lStopAfterCComp
            AAdd( s_aOPTC, "-c" )
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               AAdd( s_aOPTC, "-o{OO}" )
            ELSE
               AAdd( s_aOPTC, "-n{OD}" )
            ENDIF
         ELSE
            AAdd( s_aOPTC, "-e{OE}" )
         ENDIF
         IF s_lSHARED
            cOpt_CompC += " -L{DB}"
         ENDIF
         IF s_lMAP
            cOpt_CompC += " -M"
         ENDIF
         /* TOFIX: The two build systems should generate the same .dll name, otherwise
                   we can only be compatible with one of them. non-GNU is the common choice here. */
         s_aLIBSHARED := { iif( s_lMT, "harbourmt-" + cDL_Version_NonGNU + "-b32",;
                                       "harbour-" + cDL_Version_NonGNU + "-b32" ),;
                           "hbmainstd",;
                           "hbmainwin",;
                           "hbcommon" }

      CASE t_cARCH == "win" .AND. t_cCOMP == "msvc"
         IF s_lDEBUG
            AAdd( s_aOPTC, "-MTd -Zi" )
         ENDIF
         IF s_lGUI
            AAdd( s_aOPTL, "/subsystem:windows" )
         ELSE
            AAdd( s_aOPTL, "/subsystem:console" )
         ENDIF
         cLibPrefix := NIL
         cLibExt := ".lib"
         cObjExt := ".obj"
         cBin_CompC := "cl"

         cOpt_CompC := "-nologo -W3 {FC} -I{DI} {LC} {LO} /link {DL} {FL} {LL}"
         cLibPathPrefix := "/libpath:"
         cLibPathSep := " "
         IF s_lMAP
            AAdd( s_aOPTC, "-Fm" )
         ENDIF
         IF lStopAfterCComp
            AAdd( s_aOPTC, "-c" )
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               AAdd( s_aOPTC, "-Fo{OO}" )
            ELSE
               AAdd( s_aOPTC, "-Fo{OD}" )
            ENDIF
         ELSE
            AAdd( s_aOPTC, "-Fe{OE}" )
         ENDIF
         IF s_lSHARED
            AAdd( s_aOPTL, "/libpath:{DB}" )
         ENDIF
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "user32", "wsock32", "advapi32", "gdi32" } )
         /* TOFIX: The two build systems should generate the same .dll names, otherwise
                   we can only be compatible with one of them. non-GNU is the common choice here. */
         s_aLIBSHARED := { iif( s_lMT, "harbourmt-" + cDL_Version_NonGNU + "-vc",;
                                       "harbour-" + cDL_Version_NonGNU + "-vc" ),;
                           "hbmainstd",;
                           "hbmainwin",;
                           "hbcommon" }

      CASE t_cARCH == "win" .AND. t_cCOMP == "pocc"
         IF s_lGUI
            AAdd( s_aOPTL, "/subsystem:windows" )
         ELSE
            AAdd( s_aOPTL, "/subsystem:console" )
         ENDIF
         cLibPrefix := NIL
         cLibExt := ".lib"
         cObjExt := ".obj"
         cBin_CompC := "pocc"
         cOpt_CompC := "/Ze /Go /Ot /Tx86-coff {FC} /I{DI} {LC}"
         IF s_lMT
            AAdd( s_aOPTC, "/MT" )
         ENDIF
         IF lStopAfterCComp
            IF ( Len( s_aPRG ) + Len( s_aC ) ) == 1
               AAdd( s_aOPTC, "/Fo{OO}" )
            ENDIF
         ELSE
            AAdd( s_aOPTC, "/Fo{OE}" )
         ENDIF
         cBin_Link := "polink"
         cOpt_Link := "{LO} {DL} {FL} {LL}"
         cLibPathPrefix := "/libpath:"
         cLibPathSep := " "
         IF s_lSHARED
            AAdd( s_aOPTL, "/libpath:{DB}" )
         ENDIF
         IF s_lMAP
            AAdd( s_aOPTL, "/map" )
         ENDIF
         IF s_lDEBUG
            AAdd( s_aOPTL, "/debug" )
         ENDIF
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "user32", "wsock32", "advapi32", "gdi32" } )

      /* TODO */
      CASE t_cARCH == "win" .AND. t_cCOMP == "pocc64"  /* NOTE: Cross-platform: win/amd64 on win/x86 */
      CASE t_cARCH == "win" .AND. t_cCOMP == "poccce"  /* NOTE: Cross-platform: wince/ARM on win/x86 */
      CASE t_cARCH == "win" .AND. t_cCOMP == "dmc"
      CASE t_cARCH == "win" .AND. t_cCOMP == "icc"
      CASE t_cARCH $ "win|linux" .AND. t_cCOMP == "mingwce" /* NOTE: Cross-platform: wince/ARM on win/x86 */
         s_aLIBSYS := ArrayJoin( s_aLIBSYS, { "wininet", "ws2", "commdlg", "commctrl", "uuid", "ole32" } )
      CASE t_cARCH == "win" .AND. t_cCOMP == "msvcce"  /* NOTE: Cross-platform: wince/ARM on win/x86 */
      CASE t_cARCH == "win" .AND. t_cCOMP == "xcc"
      ENDCASE

#if 0
      /* Do entry function detection on platform required and supported */
      IF s_cMAIN == NIL .AND. ! Empty( tmp := getFirstFunc( s_cFIRST ) )
         s_cMAIN := tmp
      ENDIF
#endif

      /* HACK: Override entry point requested by user or detected by us,
               and override the GT if requested by user. */
      IF s_cMAIN != NIL .OR. ;
         ! Empty( s_aLIBUSERGT ) .OR. ;
         s_cGT != NIL .OR. ;
         s_lFMSTAT != NIL

         fhnd := hb_FTempCreateEx( @s_cCSTUB, ".", "hbsc_", ".c" )
         IF fhnd != F_ERROR

            /* NOTE: This has to be kept synced with Harbour HB_IMPORT values. */
            DO CASE
            CASE !( t_cARCH == "win" ) .OR. t_cCOMP $ "msvc|rsxnt"
               /* NOTE: MSVC gives the warning:
                        "LNK4217: locally defined symbol ... imported in function ..."
                        if using 'dllimport'. [vszakats] */
               tmp := ""
            CASE t_cCOMP $ "gcc|mingw"      ; tmp := "__attribute__ (( dllimport ))"
            CASE t_cCOMP == "bcc32|owatcom" ; tmp := "__declspec( dllimport )"
            CASE t_cCOMP == "owatcom"       ; tmp := "__declspec( dllimport )"
            OTHERWISE                       ; tmp := "_declspec( dllimport )"
            ENDCASE

            /* Create list of requested symbols */
            array := {}
            IF s_cMAIN != NIL
               /* NOTE: Request this function to generate link error, rather
                        than starting with the wrong (default) function. */
               AAdd( array, Upper( iif( Left( s_cMAIN, 1 ) == "@", SubStr( s_cMAIN, 2 ), s_cMAIN ) ) )
            ENDIF
            IF s_lFMSTAT != NIL
               AAdd( array, iif( s_lFMSTAT, "HB_FM_STAT", "HB_FM_NOSTAT" ) )
            ENDIF
            IF s_cGT != NIL
               /* Always request default GT first */
               AAdd( array, "HB_GT_" + Upper( SubStr( s_cGT, 3 ) ) )
            ENDIF
            IF ! Empty( s_aLIBUSERGT )
               AEval( s_aLIBUSERGT, {|tmp| AAdd( array, "HB_GT_" + Upper( SubStr( tmp, 3 ) ) ) } )
            ENDIF

            /* Build C stub */
            FWrite( fhnd, '#include "hbapi.h"'                                                      + hb_osNewLine() )
            IF ! Empty( array )
               FWrite( fhnd, ''                                                                     + hb_osNewLine() )
               AEval( array, {|tmp| FWrite( fhnd, 'HB_FUNC_EXTERN( ' + tmp + ' );'                  + hb_osNewLine() ) } )
               FWrite( fhnd, ''                                                                     + hb_osNewLine() )
               FWrite( fhnd, 'void _hb_lnk_ForceLink_hbmk( void )'                                  + hb_osNewLine() )
               FWrite( fhnd, '{'                                                                    + hb_osNewLine() )
               AEval( array, {|tmp| FWrite( fhnd, '   HB_FUNC_EXEC( ' + tmp + ' );'                 + hb_osNewLine() ) } )
               FWrite( fhnd, '}'                                                                    + hb_osNewLine() )
               FWrite( fhnd, ''                                                                     + hb_osNewLine() )
            ENDIF

            IF s_cGT != NIL .OR. ;
               s_cMAIN != NIL
               FWrite( fhnd, '#include "hbinit.h"'                                                  + hb_osNewLine() +;
                             ''                                                                     + hb_osNewLine() +;
                             'HB_EXTERN_BEGIN'                                                      + hb_osNewLine() +;
                             'extern ' + tmp + ' void hb_vmSetLinkedMain( const char * szMain );'   + hb_osNewLine() +;
                             'extern ' + tmp + ' void hb_gtSetDefault( const char * szGtName );'    + hb_osNewLine() +;
                             'HB_EXTERN_END'                                                        + hb_osNewLine() +;
                             ''                                                                     + hb_osNewLine() +;
                             'HB_CALL_ON_STARTUP_BEGIN( _hb_hbmk_setdef_ )'                         + hb_osNewLine() )
               IF s_cGT != NIL
                  FWrite( fhnd, '   hb_gtSetDefault( "' + Upper( SubStr( s_cGT, 3 ) ) + '" );'      + hb_osNewLine() )
               ENDIF
               IF s_cMAIN != NIL
                  FWrite( fhnd, '   hb_vmSetLinkedMain( "' + Upper( s_cMAIN ) + '" );'              + hb_osNewLine() )
               ENDIF
               FWrite( fhnd, 'HB_CALL_ON_STARTUP_END( _hb_hbmk_setdef_ )'                           + hb_osNewLine() +;
                             ''                                                                     + hb_osNewLine() +;
                             '#if defined( HB_PRAGMA_STARTUP )'                                     + hb_osNewLine() +;
                             '   #pragma startup_hb_lnk_SetDefault_hbmk_'                           + hb_osNewLine() +;
                             '#elif defined( HB_MSC_STARTUP )'                                      + hb_osNewLine() +;
                             '   #if defined( HB_OS_WIN_64 )'                                       + hb_osNewLine() +;
                             '      #pragma section( HB_MSC_START_SEGMENT, long, read )'            + hb_osNewLine() +;
                             '   #endif'                                                            + hb_osNewLine() +;
                             '   #pragma data_seg( HB_MSC_START_SEGMENT )'                          + hb_osNewLine() +;
                             '   static HB_$INITSYM hb_vm_auto_hbmk_setdef_ = _hb_hbmk_setdef_;'    + hb_osNewLine() +;
                             '   #pragma data_seg()'                                                + hb_osNewLine() +;
                             '#endif'                                                               + hb_osNewLine() )
            ENDIF
            FClose( fhnd )
         ELSE
            OutErr( "hbmk: Warning: Stub helper .c program couldn't be created." + hb_osNewLine() )
            AEval( ListCook( s_aPRG, NIL, ".c" ), {|tmp| FErase( tmp ) } )
            PauseForKey()
            RETURN 5
         ENDIF
         AAdd( s_aC, s_cCSTUB )
      ENDIF

      /* Library list assembly */
      IF s_lSHARED .AND. ! Empty( s_aLIBSHARED )
         s_aLIBHB := ArrayAJoin( { s_aLIBSHARED,;
                                   aLIB_BASE_CPLR,;
                                   aLIB_BASE_DEBUG } )
      ELSE
         s_aLIBHB := ArrayAJoin( { aLIB_BASE1,;
                                   aLIB_BASE_CPLR,;
                                   aLIB_BASE_DEBUG,;
                                   s_aLIBVM,;
                                   iif( s_lNULRDD, aLIB_BASE_NULRDD, aLIB_BASE_RDD ),;
                                   aLIB_BASE2,;
                                   iif( s_lHB_PCRE, aLIB_BASE_PCRE, {} ),;
                                   iif( s_lHB_ZLIB, aLIB_BASE_ZLIB, {} ) } )
      ENDIF

      /* Merge lib lists. */
      s_aLIB := ArrayAJoin( { s_aLIBHB, s_aLIBUSER, s_aLIB3RD, s_aLIBSYS } )
      /* Dress lib names. */
      s_aLIB := ListCook( s_aLIB, cLibPrefix, cLibExt )
      /* Strip 'lib' prefix when the target is gcc family. */
      IF t_cCOMP $ "gcc|gpp|mingw|djgpp|rsxnt|rsx32"
         FOR EACH tmp IN s_aLIB
            IF Left( tmp, 3 ) == "lib"
               tmp := SubStr( tmp, 4 )
            ENDIF
         NEXT
      ENDIF
      /* Dress obj names. */
      s_aOBJ := ListCook( ArrayJoin( s_aPRG, s_aC ), NIL, cObjExt )
      s_aOBJUSER := ListCook( s_aOBJUSER, NIL, cObjExt )

      nErrorLevel := 0

      IF ( Len( s_aPRG ) + Len( s_aC ) + iif( Empty( cBin_Link ), Len( s_aOBJUSER ) + Len( s_aOBJA ), 0 ) ) > 0

         IF ! Empty( cBin_CompC )

            /* Compiling */

            /* Order is significant */
            cOpt_CompC := StrTran( cOpt_CompC, "{LC}"  , ArrayToList( ArrayJoin( ListCook( s_aPRG, NIL, ".c" ), s_aC ) ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{LO}"  , ArrayToList( ListCook( s_aOBJUSER, cObjPrefix ) ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{LA}"  , ArrayToList( s_aOBJA ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{LL}"  , ArrayToList( s_aLIB ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{FC}"  , iif( s_lBLDFLGC, cSelfFlagC + " ", "" ) +;
                                                         GetEnv( "HB_USER_CFLAGS" ) + " " + ArrayToList( s_aOPTC ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{FL}"  , iif( s_lBLDFLGL, cSelfFlagL + " ", "" ) +;
                                                         GetEnv( "HB_USER_LDFLAGS" ) + " " + ArrayToList( s_aOPTL ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{OD}"  , PathSepToTarget( FN_DirGet( s_cPROGNAME ) ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{OO}"  , PathSepToTarget( FN_ExtSet( s_cPROGNAME, cObjPrefix ) ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{OE}"  , PathSepToTarget( s_cPROGNAME ) )
            cOpt_CompC := StrTran( cOpt_CompC, "{DB}"  , s_cHB_BIN_INSTALL )
            cOpt_CompC := StrTran( cOpt_CompC, "{DI}"  , s_cHB_INC_INSTALL )
            cOpt_CompC := StrTran( cOpt_CompC, "{DL}"  , ArrayToList( ListCook( s_aLIBPATH, cLibPathPrefix ), cLibPathSep ) )

            cOpt_CompC := AllTrim( cOpt_CompC )

            /* Handle moving the whole command line to a script, if requested. */
            IF "{SCRIPT}" $ cOpt_CompC
               fhnd := hb_FTempCreateEx( @cScriptFile, NIL, NIL, ".cpl" )
               IF fhnd != F_ERROR
                  FWrite( fhnd, StrTran( cOpt_CompC, "{SCRIPT}", "" ) )
                  FClose( fhnd )
                  cOpt_CompC := "@" + cScriptFile
               ELSE
                  OutErr( "hbmk: Warning: C compiler script couldn't be created, continuing in command line." + hb_osNewLine() )
               ENDIF
            ENDIF

            cCommand := cBin_CompC + " " + cOpt_CompC

            IF s_lTRACE
               OutStd( "hbmk: C compiler command: '" + cCommand + "'" + hb_osNewLine() )
               IF ! Empty( cScriptFile )
                  OutStd( "hbmk: C compiler script: '" + hb_MemoRead( cScriptFile ) + "'" + hb_osNewLine() )
               ENDIF
            ENDIF

            IF ( tmp := hb_run( cCommand ) ) != 0
               OutErr( "hbmk: Error: Running C compiler. " + hb_ntos( tmp ) + ": '" + cCommand + "'" + hb_osNewLine() )
               nErrorLevel := 6
            ENDIF

            IF ! Empty( cScriptFile )
               FErase( cScriptFile )
            ENDIF
         ELSE
            OutErr( "hbmk: Error: This compiler/platform isn't implemented." + hb_osNewLine() )
            nErrorLevel := 8
         ENDIF
      ENDIF

      IF nErrorLevel == 0 .AND. ! lStopAfterCComp .AND. ( Len( s_aOBJ ) + Len( s_aOBJUSER ) + Len( s_aOBJA ) ) > 0 .AND. ! Empty( cBin_Link )

         /* Linking */

         /* Order is significant */
         cOpt_Link := StrTran( cOpt_Link, "{LO}"  , ArrayToList( ListCook( ArrayJoin( s_aOBJ, s_aOBJUSER ), cObjPrefix ) ) )
         cOpt_Link := StrTran( cOpt_Link, "{LA}"  , ArrayToList( s_aOBJA ) )
         cOpt_Link := StrTran( cOpt_Link, "{LL}"  , ArrayToList( s_aLIB ) )
         cOpt_Link := StrTran( cOpt_Link, "{FL}"  , iif( s_lBLDFLGL, cSelfFlagL + " ", "" ) +;
                                                    GetEnv( "HB_USER_LDFLAGS" ) + " " + ArrayToList( s_aOPTL ) )
         cOpt_Link := StrTran( cOpt_Link, "{OE}"  , PathSepToTarget( s_cPROGNAME ) )
         cOpt_Link := StrTran( cOpt_Link, "{DB}"  , s_cHB_BIN_INSTALL )
         cOpt_Link := StrTran( cOpt_Link, "{DL}"  , ArrayToList( ListCook( s_aLIBPATH, cLibPathPrefix ), cLibPathSep ) )

         cOpt_Link := AllTrim( cOpt_Link )

         /* Handle moving the whole command line to a script, if requested. */
         IF "{SCRIPT}" $ cOpt_Link
            fhnd := hb_FTempCreateEx( @cScriptFile, NIL, NIL, ".lnk" )
            IF fhnd != F_ERROR
               FWrite( fhnd, StrTran( cOpt_Link, "{SCRIPT}", "" ) )
               FClose( fhnd )
               cOpt_Link := "@" + cScriptFile
            ELSE
               OutErr( "hbmk: Warning: Link script couldn't be created, continuing in command line." + hb_osNewLine() )
            ENDIF
         ENDIF

         cCommand := cBin_Link + " " + cOpt_Link

         IF s_lTRACE
            OutStd( "hbmk: Linker command: '" + cCommand + "'" + hb_osNewLine() )
            IF ! Empty( cScriptFile )
               OutStd( "hbmk: Linker script: '" + hb_MemoRead( cScriptFile ) + "'" + hb_osNewLine() )
            ENDIF
         ENDIF

         IF ( tmp := hb_run( cCommand ) ) != 0
            OutErr( "hbmk: Error: Running linker. " + hb_ntos( tmp ) + ": '" + cCommand + "'" + hb_osNewLine() )
            nErrorLevel := 7
         ENDIF

         IF ! Empty( cScriptFile )
            FErase( cScriptFile )
         ENDIF
      ENDIF

      /* Cleanup */

      IF ! Empty( s_cCSTUB )
         FErase( s_cCSTUB )
      ENDIF
      AEval( ListCook( s_aPRG, NIL, ".c" ), {|tmp| FErase( tmp ) } )
      IF ! lStopAfterCComp
         AEval( s_aOBJ, {|tmp| FErase( tmp ) } )
      ENDIF
      AEval( s_aCLEAN, {|tmp| FErase( tmp ) } )

      IF ! lStopAfterCComp
         IF nErrorLevel != 0
            PauseForKey()
         ELSEIF s_lRUN
            #if !( defined( __PLATFORM__WINDOWS ) .OR. defined( __PLATFORM__DOS ) .OR. defined( __PLATFORM__OS2 ) )
            IF Empty( FN_DirGet( s_cPROGNAME ) )
               s_cPROGNAME := "." + hb_osPathSeparator() + s_cPROGNAME
            ENDIF
            #endif
            IF s_lTRACE
               OutStd( "hbmk: Running executable: '" + PathSepToTarget( s_cPROGNAME ) + "'" + hb_osNewLine() )
            ENDIF
            nErrorLevel := hb_run( PathSepToTarget( s_cPROGNAME ) )
         ENDIF
      ENDIF
   ENDIF

   RETURN nErrorLevel

STATIC FUNCTION SetupForGT( cGT, /* @ */ s_cGT, /* @ */ s_lGUI )

   IF IsValidHarbourID( cGT )

      s_cGT := cGT

      /* Setup default GUI mode for core GTs:
         (please don't add contrib/3rd parties here) */
      SWITCH Lower( cGT )
      CASE "gtcgi"
      CASE "gtcrs"
      CASE "gtpca"
      CASE "gtsln"
      CASE "gtstd"
      CASE "gtwin"
         s_lGUI := .F.
         EXIT

      CASE "gtgui"
      CASE "gtwvt"
         s_lGUI := .T.
         EXIT

      ENDSWITCH

      RETURN .T.
   ENDIF

   RETURN .F.

STATIC FUNCTION SelfCOMP()
   LOCAL cCompiler := hb_Compiler()

   /* Order is significant */
   IF     "Microsoft Visual C" $ cCompiler ; RETURN "msvc"
   ELSEIF "Borland"            $ cCompiler ; RETURN "bcc32"
   ELSEIF "CodeGear"           $ cCompiler ; RETURN "bcc32"
   ELSEIF "DJGPP"              $ cCompiler ; RETURN "djgpp"
   ELSEIF "MinGW"              $ cCompiler ; RETURN "mingw"
   ELSEIF "GNU C++"            $ cCompiler ; RETURN iif( t_cARCH == "linux", "gpp", "gcc" )
   ELSEIF "GNU C"              $ cCompiler ; RETURN "gcc"
   ELSEIF "Watcom C++"         $ cCompiler ; RETURN "owatcom"
   ELSEIF "Watcom C"           $ cCompiler ; RETURN "owatcom"
   ELSEIF "Pelles ISO C"       $ cCompiler ; RETURN "pocc"
   ELSEIF "Digital Mars"       $ cCompiler ; RETURN "dmc"
   ELSEIF "(XCC)"              $ cCompiler ; RETURN "xcc"
   ENDIF

   RETURN ""

STATIC FUNCTION FindInPath( cFileName )
   LOCAL cDir
   LOCAL cName
   LOCAL cExt

   hb_FNameSplit( cFileName,, @cName, @cExt )
   #if defined( __PLATFORM__WINDOWS ) .OR. ;
       defined( __PLATFORM__DOS ) .OR. ;
       defined( __PLATFORM__OS2 )
      IF Empty( cExt )
         cExt := ".exe"
      ENDIF
   #endif

   /* Check in current dir. */
   IF hb_FileExists( cFileName := hb_FNameMerge( cDir, cName, cExt ) )
      RETURN cFileName
   ENDIF

   /* Check in the dir of this executable. */
   IF ! Empty( hb_DirBase() )
      IF hb_FileExists( cFileName := hb_FNameMerge( hb_DirBase(), cName, cExt ) )
         RETURN cFileName
      ENDIF
   ENDIF

   /* Check in the PATH. */
   #if defined( __PLATFORM__WINDOWS ) .OR. ;
       defined( __PLATFORM__DOS ) .OR. ;
       defined( __PLATFORM__OS2 )
   FOR EACH cDir IN hb_ATokens( GetEnv( "PATH" ), hb_osPathListSeparator(), .T., .T. )
   #else
   FOR EACH cDir IN hb_ATokens( GetEnv( "PATH" ), hb_osPathListSeparator() )
   #endif
      IF ! Empty( cDir )
         IF hb_FileExists( cFileName := hb_FNameMerge( DirAddPathSep( StrStripQuote( cDir ) ), cName, cExt ) )
            RETURN cFileName
         ENDIF
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION ArrayJoin( array1, array2 )
   LOCAL array := AClone( array1 )
   LOCAL nLen1 := Len( array )

   ASize( array, nLen1 + Len( array2 ) )

   RETURN ACopy( array2, array, , , nLen1 + 1 )

STATIC FUNCTION ArrayAJoin( arrays )
   LOCAL array := AClone( arrays[ 1 ] )
   LOCAL tmp
   LOCAL nLenArray := Len( arrays )
   LOCAL nLen
   LOCAL nPos := Len( array ) + 1

   nLen := 0
   FOR tmp := 1 TO nLenArray
      nLen += Len( arrays[ tmp ] )
   NEXT

   ASize( array, nLen )

   FOR tmp := 2 TO nLenArray
      ACopy( arrays[ tmp ], array, , , nPos )
      nPos += Len( arrays[ tmp ] )
   NEXT

   RETURN array

STATIC FUNCTION AAddNotEmpty( aArray, xItem )

   IF ! Empty( xItem )
      AAdd( aArray, xItem )
   ENDIF

   RETURN aArray

/* Append optional prefix and optional extension to all members */
STATIC FUNCTION ListCook( arraySrc, cPrefix, cExt )
   LOCAL array := AClone( arraySrc )
   LOCAL tmp

   DEFAULT cPrefix TO ""

   FOR tmp := 1 TO Len( array )
      array[ tmp ] := cPrefix + array[ tmp ]
      IF ISCHARACTER( cExt )
           array[ tmp ] := FN_ExtSet( array[ tmp ], cExt )
      ENDIF
   NEXT

   RETURN array

STATIC FUNCTION ArrayToList( array, cSeparator )
   LOCAL cString := ""
   LOCAL tmp

   DEFAULT cSeparator TO " "

   FOR tmp := 1 TO Len( array )
      cString += array[ tmp ]
      IF tmp < Len( array )
         cString += cSeparator
      ENDIF
   NEXT

   RETURN cString

STATIC FUNCTION ListToArray( cList )
   LOCAL array := {}
   LOCAL cItem

   IF ! Empty( cList )
      FOR EACH cItem IN hb_ATokens( cList )
         AAddNotEmpty( array, cItem )
      NEXT
   ENDIF

   RETURN array

STATIC FUNCTION PathSepToSelf( cFileName )
#if defined( __PLATFORM__WINDOWS ) .OR. ;
    defined( __PLATFORM__DOS ) .OR. ;
    defined( __PLATFORM__OS2 )
   RETURN StrTran( cFileName, "/", "\" )
#else
   RETURN StrTran( cFileName, "\", "/" )
#endif

STATIC FUNCTION PathSepToTarget( cFileName )

   IF t_cARCH $ "win|dos|os2" .AND. !( t_cCOMP $ "mingw|mingwce" )
      RETURN StrTran( cFileName, "/", "\" )
   ENDIF

   RETURN StrTran( cFileName, "\", "/" )

STATIC FUNCTION DirAddPathSep( cDir )

   IF ! Empty( cDir ) .AND. !( Right( cDir, 1 ) == hb_osPathSeparator() )
      cDir += hb_osPathSeparator()
   ENDIF

   RETURN cDir

STATIC FUNCTION FN_DirGet( cFileName )
   LOCAL cDir

   hb_FNameSplit( cFileName, @cDir )

   RETURN cDir

STATIC FUNCTION FN_NameGet( cFileName )
   LOCAL cName

   hb_FNameSplit( cFileName,, @cName )

   RETURN cName

STATIC FUNCTION FN_ExtGet( cFileName )
   LOCAL cExt

   hb_FNameSplit( cFileName, , , @cExt )

   RETURN cExt

STATIC FUNCTION FN_ExtSet( cFileName, cExt )
   LOCAL cDir, cName

   hb_FNameSplit( cFileName, @cDir, @cName )

   RETURN hb_FNameMerge( cDir, cName, cExt )

#define HBMK_CFG_NAME  "hbmkcfg.hbp"

STATIC PROCEDURE HBP_ProcessAll( lConfigOnly,;
                                 /* @ */ aLIBUSER,;
                                 /* @ */ aLIBUSERGT,;
                                 /* @ */ aLIBPATH,;
                                 /* @ */ aOPTPRG,;
                                 /* @ */ aOPTC,;
                                 /* @ */ aOPTL,;
                                 /* @ */ lGUI,;
                                 /* @ */ lMT,;
                                 /* @ */ lSHARED,;
                                 /* @ */ lSTATICFULL,;
                                 /* @ */ lDEBUG,;
                                 /* @ */ lNULRDD,;
                                 /* @ */ lMAP,;
                                 /* @ */ lSTRIP,;
                                 /* @ */ lRUN,;
                                 /* @ */ cGT )
   LOCAL aFile
   LOCAL cDir
   LOCAL cFileName

   LOCAL aCFGDirs := { DirAddPathSep( hb_DirBase() ) }

   FOR EACH cDir IN aCFGDirs
      IF hb_FileExists( cFileName := ( cDir + HBMK_CFG_NAME ) )
         IF t_lInfo
            OutStd( "hbmk: Processing configuration: " + cFileName + hb_osNewLine() )
         ENDIF
         HBP_ProcessOne( cFileName,;
            @aLIBUSER,;
            @aLIBUSERGT,;
            @aLIBPATH,;
            @aOPTPRG,;
            @aOPTC,;
            @aOPTL,;
            @lGUI,;
            @lMT,;
            @lSHARED,;
            @lSTATICFULL,;
            @lDEBUG,;
            @lNULRDD,;
            @lMAP,;
            @lSTRIP,;
            @lRUN,;
            @cGT )
         EXIT
      ENDIF
   NEXT

   IF ! lConfigOnly
      FOR EACH aFile IN Directory( "*.hbp" )
         cFileName := aFile[ F_NAME ]
         IF !( cFileName == HBMK_CFG_NAME )
            IF t_lInfo
               OutStd( "hbmk: Processing: " + cFileName + hb_osNewLine() )
            ENDIF
            HBP_ProcessOne( cFileName,;
               @aLIBUSER,;
               @aLIBUSERGT,;
               @aLIBPATH,;
               @aOPTPRG,;
               @aOPTC,;
               @aOPTL,;
               @lGUI,;
               @lMT,;
               @lSHARED,;
               @lSTATICFULL,;
               @lDEBUG,;
               @lNULRDD,;
               @lMAP,;
               @lSTRIP,;
               @lRUN,;
               @cGT )
         ENDIF
      NEXT
   ENDIF

   RETURN

#define _EOL          Chr( 10 )

STATIC PROCEDURE HBP_ProcessOne( cFileName,;
                                 /* @ */ aLIBUSER,;
                                 /* @ */ aLIBUSERGT,;
                                 /* @ */ aLIBPATH,;
                                 /* @ */ aOPTPRG,;
                                 /* @ */ aOPTC,;
                                 /* @ */ aOPTL,;
                                 /* @ */ lGUI,;
                                 /* @ */ lMT,;
                                 /* @ */ lSHARED,;
                                 /* @ */ lSTATICFULL,;
                                 /* @ */ lDEBUG,;
                                 /* @ */ lNULRDD,;
                                 /* @ */ lMAP,;
                                 /* @ */ lSTRIP,;
                                 /* @ */ lRUN,;
                                 /* @ */ cGT )
   LOCAL cFile := hb_MemoRead( cFileName )
   LOCAL cLine
   LOCAL cItem

   IF ! hb_osNewLine() == _EOL
      cFile := StrTran( cFile, hb_osNewLine(), _EOL )
   ENDIF
   IF ! hb_osNewLine() == Chr( 13 ) + Chr( 10 )
      cFile := StrTran( cFile, Chr( 13 ) + Chr( 10 ), _EOL )
   ENDIF

   FOR EACH cLine IN hb_ATokens( cFile, _EOL )

      cLine := AllTrim( ArchCompFilter( AllTrim( cLine ) ) )

      DO CASE
      CASE Lower( Left( cLine, Len( "libs="       ) ) ) == "libs="       ; cLine := SubStr( cLine, Len( "libs="       ) + 1 )
         FOR EACH cItem IN hb_ATokens( cLine,, .T. )
            cItem := PathSepToTarget( StrStripQuote( cItem ) )
            IF AScan( aLIBUSER, {|tmp| tmp == cItem } ) == 0
               AAddNotEmpty( aLIBUSER, cItem )
            ENDIF
         NEXT

      CASE Lower( Left( cLine, Len( "libpaths="   ) ) ) == "libpaths="   ; cLine := SubStr( cLine, Len( "libpaths="   ) + 1 )
         FOR EACH cItem IN hb_ATokens( cLine,, .T. )
            cItem := PathSepToTarget( StrStripQuote( cItem ) )
            IF AScan( aLIBPATH, {|tmp| tmp == cItem } ) == 0
               AAddNotEmpty( aLIBPATH, cItem )
            ENDIF
         NEXT

      CASE Lower( Left( cLine, Len( "prgflags="   ) ) ) == "prgflags="   ; cLine := SubStr( cLine, Len( "prgflags="   ) + 1 )
         FOR EACH cItem IN hb_ATokens( cLine,, .T. )
            cItem := PathSepToTarget( StrStripQuote( cItem ) )
            IF AScan( aOPTPRG, {|tmp| tmp == cItem } ) == 0
               AAddNotEmpty( aOPTPRG, cItem )
            ENDIF
         NEXT

      CASE Lower( Left( cLine, Len( "cflags="     ) ) ) == "cflags="     ; cLine := SubStr( cLine, Len( "cflags="     ) + 1 )
         FOR EACH cItem IN hb_ATokens( cLine,, .T. )
            cItem := StrStripQuote( cItem )
            IF AScan( aOPTC, {|tmp| tmp == cItem } ) == 0
               AAddNotEmpty( aOPTC, cItem )
            ENDIF
         NEXT

      CASE Lower( Left( cLine, Len( "ldflags="    ) ) ) == "ldflags="    ; cLine := SubStr( cLine, Len( "ldflags="    ) + 1 )
         FOR EACH cItem IN hb_ATokens( cLine,, .T. )
            cItem := StrStripQuote( cItem )
            IF AScan( aOPTL, {|tmp| tmp == cItem } ) == 0
               AAddNotEmpty( aOPTL, cItem )
            ENDIF
         NEXT

      CASE Lower( Left( cLine, Len( "gui="        ) ) ) == "gui="        ; cLine := SubStr( cLine, Len( "gui="        ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lGUI := .T.
         CASE ValueIsF( cLine ) ; lGUI := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "mt="         ) ) ) == "mt="         ; cLine := SubStr( cLine, Len( "mt="         ) + 1 )
         DO CASE
         CASE Lower( cLine ) == "mt" ; lMT := .T. /* Compatibility */
         CASE ValueIsT( cLine ) ; lMT := .T.
         CASE ValueIsF( cLine ) ; lMT := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "shared="     ) ) ) == "shared="     ; cLine := SubStr( cLine, Len( "shared="     ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lSHARED := .T. ; lSTATICFULL := .F.
         CASE ValueIsF( cLine ) ; lSHARED := .F. ; lSTATICFULL := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "fullstatic=" ) ) ) == "fullstatic=" ; cLine := SubStr( cLine, Len( "fullstatic=" ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lSHARED := .F. ; lSTATICFULL := .T.
         CASE ValueIsF( cLine ) ; lSHARED := .F. ; lSTATICFULL := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "debug="      ) ) ) == "debug="      ; cLine := SubStr( cLine, Len( "debug="      ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lDEBUG := .T.
         CASE ValueIsF( cLine ) ; lDEBUG := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "nulrdd="     ) ) ) == "nulrdd="     ; cLine := SubStr( cLine, Len( "nulrdd="     ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lNULRDD := .T.
         CASE ValueIsF( cLine ) ; lNULRDD := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "map="        ) ) ) == "map="        ; cLine := SubStr( cLine, Len( "map="        ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lMAP := .T.
         CASE ValueIsF( cLine ) ; lMAP := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "strip="      ) ) ) == "strip="      ; cLine := SubStr( cLine, Len( "strip="      ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lSTRIP := .T.
         CASE ValueIsF( cLine ) ; lSTRIP := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "run="        ) ) ) == "run="        ; cLine := SubStr( cLine, Len( "run="        ) + 1 )
         DO CASE
         CASE ValueIsT( cLine ) ; lRUN := .T.
         CASE ValueIsF( cLine ) ; lRUN := .F.
         ENDCASE

      CASE Lower( Left( cLine, Len( "gtdef="      ) ) ) == "gtdef="      ; cLine := SubStr( cLine, Len( "gtdef="      ) + 1 )
         IF ! Empty( cLine )
            IF ! SetupForGT( cLine, @t_cGTDEFAULT, @lGUI )
               cLine := NIL
            ENDIF
            IF ! Empty( cLine )
               IF AScan( t_aLIBCOREGT, {|tmp| Lower( tmp ) == Lower( cLine ) } ) == 0 .AND. ;
                  AScan( aLIBUSERGT  , {|tmp| Lower( tmp ) == Lower( cLine ) } ) == 0
                  AAddNotEmpty( aLIBUSERGT, PathSepToTarget( cLine ) )
               ENDIF
            ENDIF
         ENDIF

      CASE Lower( Left( cLine, Len( "gt="         ) ) ) == "gt="         ; cLine := SubStr( cLine, Len( "gt="         ) + 1 )
         IF ! Empty( cLine )
            IF cGT == NIL
               IF ! SetupForGT( cLine, @cGT, @lGUI )
                  cLine := NIL
               ENDIF
            ENDIF
            IF ! Empty( cLine )
               IF AScan( t_aLIBCOREGT, {|tmp| Lower( tmp ) == Lower( cLine ) } ) == 0 .AND. ;
                  AScan( aLIBUSERGT  , {|tmp| Lower( tmp ) == Lower( cLine ) } ) == 0
                  AAddNotEmpty( aLIBUSERGT, PathSepToTarget( cLine ) )
               ENDIF
            ENDIF
         ENDIF

      ENDCASE
   NEXT

   RETURN

/* aGT = GTs requested
   cGT = GT requested for default.
         Can be NIL, when it's the Harbour default.
         Isn't necessarily on the aGT list in case it
         is a _non-default_ core GT. */
STATIC FUNCTION IsGTRequested( cGT, aGT, cWhichGT )

   /* Checking for the default GT, always requested by core. */
   IF cGT == NIL .AND. t_cGTDEFAULT == cWhichGT
      RETURN .T.
   ENDIF

   /* Checking for user requested default GT. */
   IF cGT != NIL .AND. Lower( cGT ) == cWhichGT
      RETURN .T.
   ENDIF

   /* Checking for user requested GT. */
   IF AScan( aGT, {|tmp| Lower( tmp ) == cWhichGT } ) > 0
      RETURN .T.
   ENDIF

   RETURN .F.

STATIC FUNCTION StrStripQuote( cString )
   RETURN iif( Left( cString, 1 ) == Chr( 34 ) .AND. Right( cString, 1 ) == Chr( 34 ),;
             SubStr( cString, 2, Len( cString ) - 2 ),;
             cString )

STATIC FUNCTION ValueIsT( cString )
   cString := Lower( cString )
   RETURN cString == "yes" .OR. ;
          cString == "1" /* Compatibility */

STATIC FUNCTION ValueIsF( cString )
   cString := Lower( cString )
   RETURN cString == "no" .OR. ;
          cString == "0" /* Compatibility */

STATIC PROCEDURE HBM_Load( aParams, cFileName )
   LOCAL cFile := hb_MemoRead( cFileName )
   LOCAL cLine
   LOCAL cOption

   IF ! hb_osNewLine() == _EOL
      cFile := StrTran( cFile, hb_osNewLine(), _EOL )
   ENDIF
   IF ! hb_osNewLine() == Chr( 13 ) + Chr( 10 )
      cFile := StrTran( cFile, Chr( 13 ) + Chr( 10 ), _EOL )
   ENDIF

   FOR EACH cLine IN hb_ATokens( cFile, _EOL )
      IF !( Left( cLine, 1 ) == "#" )
         FOR EACH cOption IN hb_ATokens( cLine,, .T. )
            AAddNotEmpty( aParams, StrStripQuote( cOption ) )
         NEXT
      ENDIF
   NEXT

   RETURN

/* Filter microformat:
   {[!][<arch|comp>]['&'|'|'][...]}
*/

STATIC FUNCTION ArchCompFilter( cItem )
   LOCAL nStart, nEnd, nPos
   LOCAL cFilterSrc
   LOCAL cFilterHarb
   LOCAL bFilter
   LOCAL xResult
   LOCAL cValue

   LOCAL cExpr := "( hbm_ARCH() == Lower( '%1' ) .OR. hbm_COMP() == Lower( '%1' ) )"

   IF ( nStart := At( "{", cItem ) ) > 0 .AND. ;
      ( nEnd := hb_At( "}", cItem, nStart ) ) > 0

      /* Separate filter from the rest of the item */
      cFilterSrc := SubStr( cItem, nStart + 1, nEnd - nStart - 1 )
      cItem := Left( cItem, nStart - 1 ) + SubStr( cItem, nEnd + 1 )

      /* Parse filter and convert it to Harbour expression */
      cFilterHarb := ""
      cValue := ""
      FOR nPos := 1 TO Len( cFilterSrc )
         IF IsDigit( SubStr( cFilterSrc, nPos, 1 ) ) .OR. ;
            IsAlpha( SubStr( cFilterSrc, nPos, 1 ) )
            cValue += SubStr( cFilterSrc, nPos, 1 )
         ELSE
            IF ! Empty( cValue )
               cFilterHarb += StrTran( cExpr, "%1", cValue ) + SubStr( cFilterSrc, nPos, 1 )
               cValue := ""
            ELSE
               cFilterHarb += SubStr( cFilterSrc, nPos, 1 )
            ENDIF
         ENDIF
      NEXT
      IF ! Empty( cValue )
         cFilterHarb += StrTran( cExpr, "%1", cValue ) + SubStr( cFilterSrc, nPos, 1 )
      ENDIF

      cFilterHarb := StrTran( cFilterHarb, "&", ".AND." )
      cFilterHarb := StrTran( cFilterHarb, "|", ".OR." )

      /* Evaluate filter */
      bFilter := hb_macroBlock( cFilterHarb )
      IF bFilter != NIL
         IF ISLOGICAL( xResult := Eval( bFilter ) ) .AND. xResult
            RETURN cItem
         ENDIF
      ENDIF
      RETURN ""
   ENDIF

   RETURN cItem

#define HB_ISALPHA( c )         ( Upper( c ) >= "A" .AND. Upper( c ) <= "Z" )
#define HB_ISFIRSTIDCHAR( c )   ( HB_ISALPHA( c ) .OR. ( c ) == '_' )
#define HB_ISNEXTIDCHAR( c )    ( HB_ISFIRSTIDCHAR(c) .OR. IsDigit( c ) )

STATIC FUNCTION IsValidHarbourID( cName )
   LOCAL tmp
   IF HB_ISFIRSTIDCHAR( Left( cName, 1 ) )
      FOR tmp := 2 TO Len( cName )
         IF ! HB_ISNEXTIDCHAR( SubStr( cName, tmp, 1 ) )
            RETURN .F.
         ENDIF
      NEXT
      RETURN .T.
   ENDIF
   RETURN .F.

/* in GCC LD (except DJGPP) the order of registering init function
 * does not depend directly on the order of linked files. If we want
 * to inform HVM about valid startup function then we should try to
 * locate it ourselves and pass it to HVM using our startup function
 * [druzus]
 */
STATIC FUNCTION getFirstFunc( cFile )
   LOCAL cFuncList, cExecNM, cFuncName, cExt, cLine, n, c

   cFuncName := ""
   IF t_cCOMP $ "gcc|gpp|mingw"
      hb_FNameSplit( cFile,,, @cExt )
      IF cExt == ".c"
         FOR EACH cLine IN hb_ATokens( StrTran( hb_MemoRead( cFile ), Chr( 13 ), Chr( 10 ) ), Chr( 10 ) )
            cLine := AllTrim( cLine )
            IF cLine = '{ "' .AND. "HB_FS_FIRST" $ cLine
               n := 4
               DO WHILE ( c := SubStr( cLine, n++, 1 ) ) != '"'
                  cFuncName += c
               ENDDO
               EXIT
            ENDIF
         NEXT
      ELSEIF ! Empty( cExecNM := FindInPath( t_cCCPREFIX + "nm" ) )
         cFuncList := commandResult( cExecNM + " " + cFile + " -g -n --defined-only -C" )
         IF ( n := At( " T HB_FUN_", cFuncList ) ) != 0
            n += 10
            DO WHILE ( c := SubStr( cFuncList, n++, 1 ) ) = "_" .OR. ;
                  IsDigit( c ) .OR. IsAlpha( c )
               cFuncName += c
            ENDDO
         ENDIF
      ENDIF
   ENDIF

   RETURN cFuncName

STATIC FUNCTION commandResult( cCommand, nResult )
   LOCAL hFile, cFileName, cResult

   hFile := hb_FTempCreateEx( @cFileName )

   IF hFile != F_ERROR
      FClose( hFile )
      cCommand += ">" + cFileName
      nResult := hb_run( cCommand )
      cResult := hb_MemoRead( cFileName )
      FErase( cFileName )
   ELSE
      OutErr( "hbmk: Error: cannot create temporary file." + hb_osNewLine() )
   ENDIF

   RETURN cResult

FUNCTION hbm_ARCH()
   RETURN t_cARCH

FUNCTION hbm_COMP()
   RETURN t_cCOMP

STATIC PROCEDURE PauseForKey()

   IF ! t_lQUIET .AND. hb_gtInfo( HB_GTI_ISGRAPHIC )
      OutStd( "Press any key to continue..." )
      Inkey( 0 )
   ENDIF

   RETURN

STATIC PROCEDURE ShowHeader()

   OutStd( "Harbour Make " + HBRawVersion() + hb_osNewLine() +;
           "Copyright (c) 1999-2009, Viktor Szakats" + hb_osNewLine() +;
           "http://www.harbour-project.org/" + hb_osNewLine() +;
           hb_osNewLine() )

   RETURN

STATIC PROCEDURE ShowHelp( lLong )

   LOCAL aText_Basic := {;
      "Syntax:  hbmk [options] [<script[s]>] <src[s][.prg|.c|[.obj|.o]]>" ,;
      "" ,;
      "Options:" ,;
      "  -o<outname>       output file name" ,;
      "  -l<libname>       link with <libname> library" ,;
      "  -L<libpath>       additional path to search for libraries" ,;
      "  -static|-shared   link with static/shared libs" ,;
      "  -mt|-st           link with multi-thread/single-thread VM" ,;
      "  -gt<name>         link with GT<name> GT driver, can be repeated to link" ,;
      "                    with more GTs. First one will be the default at runtime" }

   LOCAL aText_Help := {;
      "  -help             long help" }

   LOCAL aText_Long := {;
      "  -gui|-std         create GUI/console executable" ,;
      "  -main=<mainfunc>  override the name of starting function/procedure." ,;
      "  -fullstatic       link with all static libs" ,;
      "  -nulrdd[-]        link with nulrdd" ,;
      "  -bldf[-]          inherit all/no (default) flags from Harbour build" ,;
      "  -bldf=[p][c][l]   inherit .prg/.c/linker flags (or none) from Harbour build" ,;
      "  -[no]debug        add/exclude debug info" ,;
      "  -[no]map          create (or not) a map file" ,;
      "  -[no]strip        strip (no strip) binaries" ,;
      "  -[no]fmstat       enable/disable runtime memory statistics (gcc builds only)" ,;
      "  -[no]trace        show commands executed" ,;
      "  -[no]run          run/don't run the created executable" ,;
      "  -nohbp            do not process .hbp files in current directory" ,;
      "  -hbcc             stop after creating the .c Harbour output files" ,;
      "                    create link/copy/rename hbmk to hbcc for the same effect" ,;
      "  -hbcmp            stop after creating the object files" ,;
      "                    create link/copy/rename hbmk to hbcc for the same effect" ,;
      "  -hblnk            act as linker. Currently this is the same as -q" ,;
      "  -arch=<arch>      assume specific architecure. Same as HB_ARCHITECTURE envvar" ,;
      "  -comp=<comp>      use specific compiler. Same as HB_COMPILER envvar" ,;
      "                    Special value:" ,;
      "                     - bld: use original build settings (default on *nix)" ,;
      "  -info             turn on informational messages" ,;
      "  -quiet            suppress logo" ,;
      "" ,;
      "Notes:" ,;
      "  - <script> can be <@script> (.hbm file), <script.hbm> or <script.hbp>." ,;
      "  - Regular Harbour options are also accepted." ,;
      "  - Multiple -l, -L and <script> parameters are accepted." ,;
      "  - " + HBMK_CFG_NAME + " option file in hbmk directory is always processed if it" ,;
      "    exists." ,;
      "  - .hbp option files in current dir are automatically processed." ,;
      "  - .hbp options (they should come in separate lines):" ,;
      "    libs=[<libname[s]>], gt=[gtname], prgflags=[Harbour flags]" ,;
      "    cflags=[C compiler flags], ldflags=[Linker flags], libpaths=[lib paths]" ,;
      "    gui|mt|shared|nulrdd|debug|map|strip|run=[yes|no]" ,;
      "    Lines starting with '#' char are ignored" ,;
      "  - Platform filters are accepted in each .hbp line and with -l options." ,;
      "    Filter format: {[!][<arch|comp>]}. Filters can be combined " ,;
      "    using '&', '|' operators and grouped by parantheses." ,;
      "    Ex.: {win}, {gcc}, {linux|darwin}, {win&!dmc}, {(win|linux)&!owatcom}" ,;
      "  - Defaults and feature support vary by architecture/compiler." ,;
      "  - Supported <comp> values for each supported <arch> value:" ,;
      "    linux  : gcc, gpp, owatcom, mingw, mingwce" ,;
      "    darwin : gcc" ,;
      "    win    : gcc, mingw, msvc, bcc32, owatcom, pocc, pocc64," ,;
      "             dmc, rsxnt, xcc, icc" ,; /* poccce, mingwce, msvcce */
      "    os2    : gcc, owatcom, icc" ,;
      "    dos    : gcc, djgpp, owatcom, rsx32" ,;
      "    bsd, hpux, sunos: gcc" }

   DEFAULT lLong TO .F.

   AEval( aText_Basic, {|tmp| OutStd( tmp + hb_osNewLine() ) } )
   AEval( iif( lLong, aText_Long, aText_Help ), {|tmp| OutStd( tmp + hb_osNewLine() ) } )

   RETURN

STATIC FUNCTION HBRawVersion()
   RETURN StrTran( Version(), "Harbour ", "" )
