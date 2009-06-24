@rem
@rem $Id$
@rem

@echo off

rem ---------------------------------------------------------------
rem Installer creator for Harbour Project
rem
rem Copyright 2009 Viktor Szakats (harbour.01 syenar.hu)
rem See COPYING for licensing terms.
rem
rem This script requires:
rem    - Windows NT or upper
rem    - NullSoft Installer installed (NSIS)
rem         https://sourceforge.net/project/showfiles.php?group_id=22049&package_id=15374
rem    - makensis.exe (part of NSIS) in PATH
rem         or HB_DIR_NSIS envvar set to its dir with an ending backslash.
rem    - Info-ZIP zip.exe in PATH
rem         https://sourceforge.net/project/showfiles.php?group_id=118012
rem    - HB_COMPILER envvar configured (see INSTALL doc)
rem    - C compiler and GNU Make configured (see INSTALL doc)
rem ---------------------------------------------------------------

if not "%OS%" == "Windows_NT" echo This Harbour build script requires Windows NT or upper.
if not "%OS%" == "Windows_NT" goto END

setlocal

rem ; Basic setup
set HB_VERSION=2.0.0beta2
if "%HB_ARCHITECTURE%" == "" set HB_ARCHITECTURE=win
set HB_PKGNAME=harbour-%HB_VERSION%-%HB_ARCHITECTURE%-%HB_COMPILER%
set HB_DIRNAME=harbour-%HB_ARCHITECTURE%-%HB_COMPILER%

rem ; Dir setup
set HB_INSTALL_BASE=%~dp0_hb_inst
set HB_INSTALL_PREFIX=%HB_INSTALL_BASE%\%HB_DIRNAME%
set HB_BIN_INSTALL=%HB_INSTALL_PREFIX%\bin
set HB_LIB_INSTALL=%HB_INSTALL_PREFIX%\lib\%HB_ARCHITECTURE%\%HB_COMPILER%
set HB_INC_INSTALL=%HB_INSTALL_PREFIX%\include
set HB_DOC_INSTALL=%HB_INSTALL_PREFIX%\doc

rem ; Pre-build cleanup
if exist %HB_INSTALL_PREFIX% rmdir /q /s %HB_INSTALL_PREFIX%

rem ; Option setup
set HB_BUILD_DLL=yes
set HB_BUILD_OPTIM=yes
set HB_BUILD_DEBUG=no
set HB_BUILD_IMPLIB=no

rem ; Build Harbour
call make_gnu.bat

rem if errorlevel 1 goto MK_ERROR

rem ; Post-build cleanup
if exist "%HB_BIN_INSTALL%\*.tds" del "%HB_BIN_INSTALL%\*.tds"
if exist "%HB_BIN_INSTALL%\*.lib" del "%HB_BIN_INSTALL%\*.lib"
if exist "%HB_BIN_INSTALL%\*.exp" del "%HB_BIN_INSTALL%\*.exp"

rem ; Post-build installation
xcopy /D /Y ChangeLog* "%HB_INSTALL_PREFIX%\"
xcopy /D /Y COPYING    "%HB_INSTALL_PREFIX%\"
xcopy /D /Y ERRATA     "%HB_INSTALL_PREFIX%\"
xcopy /D /Y INSTALL    "%HB_INSTALL_PREFIX%\"
xcopy /D /Y TODO       "%HB_INSTALL_PREFIX%\"

rem ; Build .zip package
if exist %HB_PKGNAME%.zip del %HB_PKGNAME%.zip
pushd
cd %HB_INSTALL_BASE%
zip -9 -X -r -o %~dp0%HB_PKGNAME%.zip . -i %HB_DIRNAME%\*
popd

rem ; Build installer package
"%HB_DIR_NSIS%makensis.exe" %~dp0mpkg_win.nsi

:MK_ERROR

rem ; Cleanup
if "%1" == "--deltemp" rmdir /q /s %HB_INSTALL_PREFIX%
if "%1" == "--deltemp" rmdir /q    %HB_INSTALL_BASE%

endlocal

:END
