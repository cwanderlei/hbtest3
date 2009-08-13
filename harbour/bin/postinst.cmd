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

if "%HB_BIN_INSTALL%" == "" goto END

echo ! Generating %HB_BIN_INSTALL%\hbmk.cfg...
echo # Harbour Make configuration> %HB_BIN_INSTALL%\hbmk.cfg
echo # Generated by Harbour build process>> %HB_BIN_INSTALL%\hbmk.cfg
echo.>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../contrib/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../contrib/rddsql/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../addons/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg
echo libpaths=../examples/%%{hb_name}>> %HB_BIN_INSTALL%\hbmk.cfg

rem ; Post-build installation
if not "%HB_INSTALL_PREFIX%" == "" xcopy /y ChangeLog* "%HB_INSTALL_PREFIX%\" > nul
if not "%HB_INSTALL_PREFIX%" == "" xcopy /y COPYING    "%HB_INSTALL_PREFIX%\" > nul
if not "%HB_INSTALL_PREFIX%" == "" xcopy /y ERRATA     "%HB_INSTALL_PREFIX%\" > nul
if not "%HB_INSTALL_PREFIX%" == "" xcopy /y INSTALL    "%HB_INSTALL_PREFIX%\" > nul
if not "%HB_INSTALL_PREFIX%" == "" xcopy /y TODO       "%HB_INSTALL_PREFIX%\" > nul

goto INST_%HB_ARCHITECTURE%

:INST_OS2

   rem OS/2 post install part
   goto END

:INST_
:END
