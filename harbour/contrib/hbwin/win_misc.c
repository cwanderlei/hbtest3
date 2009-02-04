/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Misc Windows API functions
 *
 * Copyright 2008-2009 Viktor Szakats <harbour.01 syenar hu>
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

#define HB_OS_WIN_USED

#include "hbapi.h"

#include <shellapi.h>

/* TODO: Add hb_osEncode(). */

HB_FUNC( WIN_SHELLEXECUTE )
{
   LPTSTR lpOperation  = ISCHAR( 2 ) ? HB_TCHAR_CONVTO( hb_parc( 2 ) ) : NULL;
   LPTSTR lpFile       =               HB_TCHAR_CONVTO( hb_parcx( 3 ) );
   LPTSTR lpParameters = ISCHAR( 4 ) ? HB_TCHAR_CONVTO( hb_parc( 4 ) ) : NULL;
   LPTSTR lpDirectory  = ISCHAR( 5 ) ? HB_TCHAR_CONVTO( hb_parc( 5 ) ) : NULL;

   hb_retnint( ( HB_PTRDIFF ) ShellExecute( ( HWND ) ( ISPOINTER( 1 ) ? hb_parptr( 1 ) : ( void * ) ( HB_PTRDIFF ) hb_parnint( 1 ) ),
                                            ( LPCTSTR ) lpOperation, /* edit, explore, open, print, play?, properties? */
                                            ( LPCTSTR ) lpFile,
                                            ( LPCTSTR ) lpParameters,
                                            ( LPCTSTR ) lpDirectory,
                                            ISNUM( 6 ) ? hb_parni( 6 ) : SW_SHOWNORMAL /* nShowCmd */ ) );

   if( lpOperation )
      HB_TCHAR_FREE( lpOperation );
   HB_TCHAR_FREE( lpFile );
   if( lpParameters )
      HB_TCHAR_FREE( lpParameters );
   if( lpDirectory )
      HB_TCHAR_FREE( lpDirectory );
}

HB_FUNC( WIN_RUNDETACHED )
{
   LPTSTR lpCommandName = ISCHAR( 1 ) ? HB_TCHAR_CONVTO( hb_parc( 1 ) ) : NULL;
   LPTSTR lpCommandLine = ISCHAR( 2 ) ? HB_TCHAR_CONVTO( hb_parc( 2 ) ) : NULL;

   STARTUPINFO si;
   PROCESS_INFORMATION pi;

   ZeroMemory( &si, sizeof( si ) );
   si.cb = sizeof( si );
   ZeroMemory( &pi, sizeof( pi ) );

   if( CreateProcess(
         ( LPCTSTR ) lpCommandName,                            /* Command name */
         ( LPTSTR ) lpCommandLine,                             /* Command line (Unicode version needs an non-const buffer) */
         NULL,                                                 /* Process handle not inheritable */
         NULL,                                                 /* Thread handle not inheritable */
         FALSE,                                                /* Set handle inheritance to FALSE */
         hb_parl( 4 ) ? CREATE_NO_WINDOW : CREATE_NEW_CONSOLE, /* Creation flags */
         NULL,                                                 /* Use parent's environment block */
         NULL,                                                 /* Use parent's starting directory */
         &si,                                                  /* Pointer to STARTUPINFO structure */
         &pi )                                                 /* Pointer to PROCESS_INFORMATION structure */
      )
   {
      hb_stornl( pi.dwProcessId, 2 );
      hb_retl( TRUE );

      /* Close process and thread handles. */
      CloseHandle( pi.hProcess );
      CloseHandle( pi.hThread );
   }
   else
   {
      hb_stornl( -1, 3 );
      hb_retl( FALSE );
   }

   if( lpCommandName )
      HB_TCHAR_FREE( lpCommandName );
   if( lpCommandLine )
      HB_TCHAR_FREE( lpCommandLine );
}

HB_FUNC( WIN_LOADRESOURCE )
{
   HANDLE hInstance = NULL;

   /* Set default return value */
   hb_retc_null();

   if( hb_winmainArgGet( &hInstance, NULL, NULL ) )
   {
      LPTSTR lpName = HB_TCHAR_CONVTO( hb_parcx( 1 ) );
      LPTSTR lpType = HB_TCHAR_CONVTO( hb_parcx( 2 ) );

      HRSRC hRes = FindResource( hInstance, ( LPCTSTR ) lpName, ( LPCTSTR ) lpType );

      if( hRes )
      {
         HGLOBAL hMem = LoadResource( NULL, hRes );

         if( hMem )
         {
            void * pMem = LockResource( hMem );

            if( pMem )
               hb_retclen( ( char * ) pMem, SizeofResource( NULL, hRes ) );
         }
      }

      HB_TCHAR_FREE( lpName );
      HB_TCHAR_FREE( lpType );
   }
}
