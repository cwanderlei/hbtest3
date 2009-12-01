/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Windows API functions (shellapi.h - shell32.dll)
 *
 * Copyright 2008-2009 Viktor Szakats (harbour.01 syenar.hu)
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

HB_FUNC( WAPI_SHELLEXECUTE )
{
#if defined( HB_OS_WIN_CE )
   hb_retnint( -1 );
#else
   char * pszFreeOperation  = NULL;
   char * pszFreeFile       = NULL;
   char * pszFreeParameters = NULL;
   char * pszFreeDirectory  = NULL;

   const char * pszOperation  = HB_ISCHAR( 2 ) ? hb_osEncodeCP( hb_parc( 2 ), &pszFreeOperation, NULL ) : NULL;
   const char * pszFile       = hb_osEncodeCP( hb_parcx( 3 ), &pszFreeFile, NULL );
   const char * pszParameters = HB_ISCHAR( 4 ) ? hb_osEncodeCP( hb_parc( 4 ), &pszFreeParameters, NULL ) : NULL;
   const char * pszDirectory  = HB_ISCHAR( 5 ) ? hb_osEncodeCP( hb_parc( 5 ), &pszFreeDirectory, NULL ) : NULL;

   LPTSTR lpOperation  = pszOperation  ? HB_TCHAR_CONVTO( pszOperation  ) : NULL;
   LPTSTR lpFile       = pszFile       ? HB_TCHAR_CONVTO( pszFile       ) : NULL;
   LPTSTR lpParameters = pszParameters ? HB_TCHAR_CONVTO( pszParameters ) : NULL;
   LPTSTR lpDirectory  = pszDirectory  ? HB_TCHAR_CONVTO( pszDirectory  ) : NULL;

   hb_retnint( ( HB_PTRDIFF ) ShellExecute( ( HWND ) hb_parptr( 1 ),
                                            ( LPCTSTR ) lpOperation, /* edit, explore, open, print, play?, properties? */
                                            ( LPCTSTR ) lpFile,
                                            ( LPCTSTR ) lpParameters,
                                            ( LPCTSTR ) lpDirectory,
                                            HB_ISNUM( 6 ) ? hb_parni( 6 ) : SW_SHOWNORMAL /* nShowCmd */ ) );

   if( lpOperation  ) HB_TCHAR_FREE( lpOperation  );
   if( lpFile       ) HB_TCHAR_FREE( lpFile       );
   if( lpParameters ) HB_TCHAR_FREE( lpParameters );
   if( lpDirectory  ) HB_TCHAR_FREE( lpDirectory  );

   if( pszFreeOperation  ) hb_xfree( pszFreeOperation  );
   if( pszFreeFile       ) hb_xfree( pszFreeFile       );
   if( pszFreeParameters ) hb_xfree( pszFreeParameters );
   if( pszFreeDirectory  ) hb_xfree( pszFreeDirectory  );

#endif
}

HB_FUNC( WAPI_ISUSERANADMIN )
{
   BOOL bResult = FALSE;

   HMODULE hLib = LoadLibrary( TEXT( "shell32.dll" ) );

   if( hLib )
   {
      typedef int ( WINAPI * ISUSERANADMIN )( void );
      ISUSERANADMIN pIsUserAnAdmin = ( ISUSERANADMIN ) GetProcAddress( hLib, HBTEXT( "IsUserAnAdmin" ) );
      if( pIsUserAnAdmin )
         bResult = ( pIsUserAnAdmin )();

      FreeLibrary( hLib );
   }

   hb_retl( bResult );
}
