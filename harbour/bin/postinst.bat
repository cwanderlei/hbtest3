@rem
@rem $Id$
@rem

@echo off

rem ---------------------------------------------------------------
rem Copyright 2009 Viktor Szakats (harbour.01 syenar.hu)
rem Copyright 2003 Przemyslaw Czerpak (druzus / at / priv.onet.pl)
rem simple script run after Harbour make install to finish install
rem process
rem
rem See COPYING for licensing terms.
rem ---------------------------------------------------------------

if "%HB_BIN_INSTALL%" == "" echo HB_BIN_INSTALL needs to be set.
if "%HB_BIN_INSTALL%" == "" goto END

echo ! Generating %HB_BIN_INSTALL%\hbmk.cfg...
echo # Harbour Make configuration> %HB_BIN_INSTALL%\hbmk.cfg
echo # Generated by Harbour build process>> %HB_BIN_INSTALL%\hbmk.cfg
echo.>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../contrib/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../contrib/rddsql/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../addons/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../examples/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg

goto INST_%HB_ARCHITECTURE%

:INST_WIN
:INST_WCE

   rem Windows post install part

   if not "%OS%" == "Windows_NT" echo ! postinst.bat Harbour build script requires Windows NT or upper.
   if not "%OS%" == "Windows_NT" goto END

   rem ; Post-build installation
   if not "%HB_INSTALL_PREFIX%" == "" copy ChangeLog* "%HB_INSTALL_PREFIX%\" > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy COPYING    "%HB_INSTALL_PREFIX%\" > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy ERRATA     "%HB_INSTALL_PREFIX%\" > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy INSTALL    "%HB_INSTALL_PREFIX%\" > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy TODO       "%HB_INSTALL_PREFIX%\" > nul

   if "%HB_BUILD_DLL%" == "no" goto _SKIP_DLL_BIN

      call "%~dp0hb-mkdyn.bat"

      if exist "%HB_BIN_INSTALL%\*.dll" (
         echo ! Creating dynamic version of Harbour binaries...
         "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN -shared "-o%HB_BIN_INSTALL%\hbrun-dll"    "%~dp0..\utils\hbrun\hbrun.hbp"
         "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN -shared "-o%HB_BIN_INSTALL%\hbmk2-dll"    "%~dp0..\utils\hbmk2\hbmk2.hbp"
         "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN -shared "-o%HB_BIN_INSTALL%\hbtest-dll"   "%~dp0..\utils\hbtest\hbtest.hbp"
         "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN -shared "-o%HB_BIN_INSTALL%\hbi18n-dll"   "%~dp0..\utils\hbi18n\hbi18n.hbp"
         "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN -shared "-o%HB_BIN_INSTALL%\hbformat-dll" "%~dp0..\utils\hbformat\hbformat.hbp"
      )

   :_SKIP_DLL_BIN

   rem ; We build this here, because GNU Make wouldn't add the icon.
   echo ! Creating hbrun with embedded icon...
   "%HB_HOST_BIN_DIR%\hbmk2" -q0 -lng=en-EN "-o%HB_BIN_INSTALL%\hbrun" "%~dp0..\utils\hbrun\hbrun.hbp"

   if "%HB_BUILD_IMPLIB%" == "yes" call "%~dp0hb-mkimp.bat"
   if "%HB_BUILD_PKG%" == "yes" call "%~dp0hb-mkpkg.bat"

   goto END

:INST_DOS

   rem ; Post-build installation
   if not "%HB_INSTALL_PREFIX%" == "" copy CHANG*     %HB_INSTALL_PREFIX%\CHANGES > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy COPYING    %HB_INSTALL_PREFIX% > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy ERRATA     %HB_INSTALL_PREFIX% > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy INSTALL    %HB_INSTALL_PREFIX% > nul
   if not "%HB_INSTALL_PREFIX%" == "" copy TODO       %HB_INSTALL_PREFIX% > nul

   if "%HB_BUILD_PKG%" == "yes" call "%~dp0hb-mkpkg.bat"

   rem DOS post install part
   goto END

:INST_LINUX

   goto END

:INST_

   goto END

:END
