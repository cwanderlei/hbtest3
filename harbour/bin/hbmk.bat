@echo off
rem
rem $Id$
rem

rem ---------------------------------------------------------------
rem This is a generic template file, if it doesn't fit your own needs
rem please DON'T MODIFY IT.
rem
rem Instead, make a local copy and modify that one, or make a call to
rem this batch file from your customized one. [vszakats]
rem ---------------------------------------------------------------

rem ---------------------------------------------------------------
rem Template to build a final Harbour executable, using Harbour
rem with the C code generation feature, then calling the proper C
rem linker/compiler.
rem
rem Copyright 1999-2008 Viktor Szakats (viktor.szakats@syenar.hu)
rem See doc/license.txt for licensing terms.
rem ---------------------------------------------------------------

rem if "%HB_ARCHITECTURE%" == "" set HB_ARCHITECTURE=w32
rem if "%HB_COMPILER%" == "" set HB_COMPILER=mingw

if "%HB_INSTALL_PREFIX%" == "" set HB_INSTALL_PREFIX=..
if "%HB_BIN_INSTALL%" == "" set HB_BIN_INSTALL=%HB_INSTALL_PREFIX%\bin
if "%HB_LIB_INSTALL%" == "" set HB_LIB_INSTALL=%HB_INSTALL_PREFIX%\lib
if "%HB_INC_INSTALL%" == "" set HB_INC_INSTALL=%HB_INSTALL_PREFIX%\include

set _HB_USR_C=
set _HB_USR_L=

set _HB_MT=%HB_MT%
set _HB_GUI=%HB_GUI%

:REPEAT

if not "%1" == "-mt" goto NO_MT
   set _HB_MT=yes
   shift
   goto REPEAT
:NO_MT

if not "%1" == "-gui" goto NO_GUI
   set _HB_GUI=yes
   shift
   goto REPEAT
:NO_GUI

set _HBVM_LIB=hbvm
if "%_HB_MT%" == "yes" set _HBVM_LIB=hbvmmt
if "%_HB_MT%" == "MT"  set _HBVM_LIB=hbvmmt

:START

   if "%HB_ARCHITECTURE%" == "" goto NO_ARCH
   if "%HB_COMPILER%" == "" goto NO_COMP

   if not "%1" == "" goto COMPILE

:HELP

   echo.
   echo Usage: hbmk [-mt] [-gui] filename
   echo.
   echo Notes:
   echo.
   echo   - 'filename' is the .prg filename (without extension on pre-NT systems).
   echo   - Don't forget to create a MAIN() function in your application.
   echo   - Environment variables HB_ARCHITECTURE, HB_COMPILER must be set.
   echo     The following values are currently supported:
   echo.
   echo     HB_ARCHITECTURE:
   echo       - dos
   echo       - w32
   echo.
   echo     HB_COMPILER:
   echo       - When HB_ARCHITECTURE=dos
   echo         - djgpp   (Delorie GNU C, DOS 32-bit)
   echo         - owatcom (OpenWatcom, DOS 32-bit)
   echo         - watcom  (OpenWatcom, DOS 32-bit)
   echo         - rxs32   (EMX/RSXNT/DOS GNU C, DOS 32-bit)
   echo       - When HB_ARCHITECTURE=w32
   echo         - msvc    (Microsoft Visual C++, Windows 32/64-bit)
   echo         - mingw   (MinGW GNU C, Windows 32-bit)
   echo         - gcc     (Cygnus/Cygwin GNU C, Windows 32-bit)
   echo         - bcc32   (Borland C++ 4.x, 5.x, 6.x, Windows 32-bit)
   echo         - owatcom (OpenWatcom, Windows 32-bit)
   echo         - watcom  (OpenWatcom, Windows 32-bit)
   echo         - rxsnt   (EMX/RSXNT/Win32 GNU C, Windows 32-bit)
   goto END

:NO_ARCH

   echo Error: HB_ARCHITECTURE is not set.
   goto HELP

:NO_COMP

   echo Error: HB_COMPILER is not set.
   goto HELP

:BAD_ARCH

   echo Error: HB_ARCHITECTURE value is unsupported.
   goto HELP

:BAD_COMP

   echo Error: HB_COMPILER value is unsupported.
   goto HELP

:COMPILE

   if     "%OS%" == "Windows_NT" set _HB_PRG_NAME=%~n1
   if not "%OS%" == "Windows_NT" set _HB_PRG_NAME=%1

   %HB_BIN_INSTALL%\harbour %_HB_PRG_NAME%.prg -n -q0 -i%HB_INC_INSTALL% %2 %3 %PRG_USR%

:A_DOS

   if not "%HB_ARCHITECTURE%" == "dos" goto A_W32

   if not "%HB_COMPILER%" == "djgpp" goto A_DOS_DJGPP_NOT

      echo %_HB_PRG_NAME%.c > _hb_mk.tmp
      echo -o%_HB_PRG_NAME%.exe -O3 %C_USR% -I%HB_INC_INSTALL% -L%HB_LIB_INSTALL% >> _hb_mk.tmp
      echo -lhbcpage >> _hb_mk.tmp
      echo -lhbdebug >> _hb_mk.tmp
      echo -lhbvm >> _hb_mk.tmp
      echo -lhbrtl >> _hb_mk.tmp
      echo -lgtdos >> _hb_mk.tmp
      echo -lgtcgi >> _hb_mk.tmp
      echo -lgtstd >> _hb_mk.tmp
      echo -lgtpca >> _hb_mk.tmp
      echo -lhblang >> _hb_mk.tmp
      echo -lhbrdd >> _hb_mk.tmp
      echo -lhbrtl >> _hb_mk.tmp
      echo -l%_HBVM_LIB% >> _hb_mk.tmp
      echo -lhbmacro >> _hb_mk.tmp
      echo -lhbpp >> _hb_mk.tmp
      echo -lrddfpt >> _hb_mk.tmp
      echo -lrddntx >> _hb_mk.tmp
      echo -lrddcdx >> _hb_mk.tmp
      echo -lhbhsx >> _hb_mk.tmp
      echo -lhbsix >> _hb_mk.tmp
      echo -lhbcommon >> _hb_mk.tmp
      echo -lm >> _hb_mk.tmp
      gcc @_hb_mk.tmp
      del _hb_mk.tmp
      goto CLEANUP

:A_DOS_DJGPP_NOT

   if not "%HB_COMPILER%" == "rsx32" goto A_DOS_RSX32_NOT

      gcc %_HB_PRG_NAME%.c -O3 -Zrsx32 %C_USR% -I%HB_INC_INSTALL% -L%HB_LIB_INSTALL% -lhbcpage -lhbdebug -lhbvm -lhbrtl -lgtdos -lgtcgi -lgtstd -lgtpca -lhblang -lhbrdd -lhbrtl -lhbvm -lhbmacro -lhbpp -lrddfpt -lrddntx -lrddcdx -lhbhsx -lhbsix -lhbcommon -lhbpcre -lhbzlib
      goto CLEANUP

:A_DOS_RSX32_NOT

   if "%HB_COMPILER%" == "owatcom" goto A_DOS_WATCOM
   if not "%HB_COMPILER%" == "watcom" goto END

      :A_DOS_WATCOM

      wpp386 -j -w3 -d2 -5s -5r -fp5 -oxehtz -zq -zt0 -bt=DOS %_HB_PRG_NAME%.c -fo=%_HB_PRG_NAME%.obj
      echo OP osn=DOS OP stack=65536 OP CASEEXACT OP stub=cwstub.exe %L_USR% NAME %_HB_PRG_NAME%.exe > _hb_mk.tmp
      echo FILE %_HB_PRG_NAME%.obj >> _hb_mk.tmp
      echo LIB hbcpage.lib >> _hb_mk.tmp
      echo LIB hbdebug.lib >> _hb_mk.tmp
      echo LIB hbvm.lib >> _hb_mk.tmp
      echo LIB hbrtl.lib >> _hb_mk.tmp
      echo LIB gtdos.lib >> _hb_mk.tmp
      echo LIB gtcgi.lib >> _hb_mk.tmp
      echo LIB gtstd.lib >> _hb_mk.tmp
      echo LIB gtpca.lib >> _hb_mk.tmp
      echo LIB hblang.lib >> _hb_mk.tmp
      echo LIB hbrdd.lib >> _hb_mk.tmp
      echo LIB hbmacro.lib >> _hb_mk.tmp
      echo LIB hbpp.lib >> _hb_mk.tmp
      echo LIB rddntx.lib >> _hb_mk.tmp
      echo LIB rddcdx.lib >> _hb_mk.tmp
      echo LIB rddfpt.lib >> _hb_mk.tmp
      echo LIB hbhsx.lib >> _hb_mk.tmp
      echo LIB hbsix.lib >> _hb_mk.tmp
      echo LIB hbcommon.lib >> _hb_mk.tmp
      echo LIB hbpcre.lib >> _hb_mk.tmp
      echo LIB hbzlib.lib >> _hb_mk.tmp
      wlink @_hb_mk.tmp
      del _hb_mk.tmp
      goto CLEANUP

:A_W32

   if not "%HB_ARCHITECTURE%" == "w32" goto END

   if not "%HB_COMPILER%" == "bcc32" goto A_WIN_BCC_NOT

      if "%_HB_GUI%" == "yes" set _HB_USR_C=-tW

      bcc32 -q -tWM -O2 -OS -Ov -Oi -Oc -d %C_USR% %_HB_USR_C% -I%HB_INC_INSTALL% -L%HB_LIB_INSTALL% %_HB_PRG_NAME%.c %HB_USER_LIBS% hbcpage.lib hbdebug.lib %_HBVM_LIB%.lib hbrtl.lib gtcgi.lib gtgui.lib gtpca.lib gtstd.lib gtwin.lib gtwvt.lib hblang.lib hbrdd.lib hbmacro.lib hbpp.lib rddfpt.lib rddntx.lib rddcdx.lib hbhsx.lib hbsix.lib hbcommon.lib hbpcre.lib hbzlib.lib
      goto CLEANUP

:A_WIN_BCC_NOT

   if not "%HB_COMPILER%" == "msvc" goto A_WIN_MSVC_NOT

      if "%_HB_GUI%" == "yes" set _HB_USR_L=/subsystem:windows

      cl -nologo -W3 %C_USR% -I%HB_INC_INSTALL% %_HB_PRG_NAME%.c /link /libpath:%HB_LIB_INSTALL% %L_USR% %_HB_USR_L% %HB_USER_LIBS% hbcpage.lib hbdebug.lib %_HBVM_LIB%.lib hbrtl.lib gtcgi.lib gtgui.lib gtpca.lib gtstd.lib gtwin.lib gtwvt.lib hblang.lib hbrdd.lib hbmacro.lib hbpp.lib rddntx.lib rddcdx.lib rddfpt.lib hbhsx.lib hbsix.lib hbcommon.lib hbpcre.lib hbzlib.lib user32.lib wsock32.lib advapi32.lib gdi32.lib
      goto CLEANUP

:A_WIN_MSVC_NOT

   if "%HB_COMPILER%" == "gcc" set HB_COMPILER=mingw
   if not "%HB_COMPILER%" == "mingw" goto A_WIN_MINGW_NOT

      gcc %_HB_PRG_NAME%.c -O3 -o%_HB_PRG_NAME%.exe %C_USR% -I%HB_INC_INSTALL% -L%HB_LIB_INSTALL% -lhbcpage -lhbdebug -l%_HBVM_LIB% -lhbrtl -lgtcgi -lgtgui -lgtpca -lgtstd -lgtwin -lgtwvt -lhblang -lhbrdd -lhbrtl -l%_HBVM_LIB% -lhbmacro -lhbpp -lrddfpt -lrddntx -lrddcdx -lhbhsx -lhbsix -lhbcommon -lhbpcre -lhbzlib
      goto CLEANUP

:A_WIN_MINGW_NOT

   if not "%HB_COMPILER%" == "rsxnt" goto A_WIN_RSXNT_NOT

      gcc %_HB_PRG_NAME%.c -O3 -Zwin32 %C_USR% -I%HB_INC_INSTALL% -L%HB_LIB_INSTALL% -lhbcpage -lhbdebug -l%_HBVM_LIB% -lhbrtl -lgtcgi -lgtgui -lgtpca -lgtstd -lgtwin -lgtwvt -lhblang -lhbrdd -lhbrtl -l%_HBVM_LIB% -lhbmacro -lhbpp -lrddfpt -lrddntx -lrddcdx -lhbhsx -lhbsix -lhbcommon -lhbpcre -lhbzlib
      goto CLEANUP

:A_WIN_RSXNT_NOT

   if "%HB_COMPILER%" == "owatcom" goto A_WIN_WATCOM
   if not "%HB_COMPILER%" == "watcom" goto END

      :A_WIN_WATCOM

      wpp386 -j -w3 -d2 -5s -5r -fp5 -oxehtz -zq -zt0 -mf -bt=NT %_HB_PRG_NAME%.c -fo=%_HB_PRG_NAME%.obj
      echo OP osn=NT OP stack=65536 OP CASEEXACT %L_USR% NAME %_HB_PRG_NAME%.exe > _hb_mk.tmp
      echo FILE %_HB_PRG_NAME%.obj >> _hb_mk.tmp
      echo LIB hbcpage.lib >> _hb_mk.tmp
      echo LIB hbdebug.lib >> _hb_mk.tmp
      echo LIB %_HBVM_LIB%.lib >> _hb_mk.tmp
      echo LIB hbrtl.lib >> _hb_mk.tmp
      echo LIB gtcgi.lib >> _hb_mk.tmp
      echo LIB gtgui.lib >> _hb_mk.tmp
      echo LIB gtpca.lib >> _hb_mk.tmp
      echo LIB gtstd.lib >> _hb_mk.tmp
      echo LIB gtwin.lib >> _hb_mk.tmp
      echo LIB gtwvt.lib >> _hb_mk.tmp
      echo LIB hblang.lib >> _hb_mk.tmp
      echo LIB hbmacro.lib >> _hb_mk.tmp
      echo LIB hbpp.lib >> _hb_mk.tmp
      echo LIB rddntx.lib >> _hb_mk.tmp
      echo LIB rddcdx.lib >> _hb_mk.tmp
      echo LIB rddfpt.lib >> _hb_mk.tmp
      echo LIB hbhsx.lib >> _hb_mk.tmp
      echo LIB hbsix.lib >> _hb_mk.tmp
      echo LIB hbrdd.lib >> _hb_mk.tmp
      echo LIB hbcommon.lib >> _hb_mk.tmp
      echo LIB hbpcre.lib >> _hb_mk.tmp
      echo LIB hbzlib.lib >> _hb_mk.tmp
      echo LIB kernel32.lib >> _hb_mk.tmp
      echo LIB user32.lib >> _hb_mk.tmp
      echo LIB wsock32.lib >> _hb_mk.tmp
      wlink @_hb_mk.tmp
      del _hb_mk.tmp
      goto CLEANUP

:CLEANUP

   if exist %_HB_PRG_NAME%.c del %_HB_PRG_NAME%.c
   if exist %_HB_PRG_NAME%.o del %_HB_PRG_NAME%.o
   if exist %_HB_PRG_NAME%.obj del %_HB_PRG_NAME%.obj
   rem Borland stuff
   if exist %_HB_PRG_NAME%.tds del %_HB_PRG_NAME%.tds

:END

set _HB_MT=
set _HB_GUI=
set _HBVM_LIB=
set _HB_USR_C=
set _HB_USR_L=
