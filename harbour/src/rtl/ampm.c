/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * AMPM() compatibility function from the SAMPLES directory of Clipper.
 *
 * Copyright 1999-2001 Viktor Szakats (harbour.01 syenar.hu)
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

#include "hbapi.h"

HB_FUNC( AMPM )
{
   HB_SIZE ulTimeLen = hb_parclen( 1 );
   char *  pszResult = ( char * ) hb_xgrab( HB_MAX( ulTimeLen, 2 ) + 3 + 1 );
   int     iHour = 0;
   HB_BOOL bAM;

   if( ulTimeLen )
   {
      const char * pszTime = hb_parc( 1 );
      memcpy( pszResult, pszTime, ulTimeLen );
      iHour = ( int ) hb_strVal( pszTime, ulTimeLen );
   }

   if( iHour == 0 || iHour == 24 )
   {
      if( ulTimeLen < 2 )
         ulTimeLen = 2;

      pszResult[ 0 ] = '1';
      pszResult[ 1 ] = '2';
      bAM = HB_TRUE;
   }
   else if( iHour > 12 )
   {
      if( ulTimeLen < 2 )
         ulTimeLen = 2;

      iHour -= 12;
      pszResult[ 0 ] = ( char ) ( iHour / 10 ) + '0';
      pszResult[ 1 ] = ( char ) ( iHour % 10 ) + '0';

      if( pszResult[ 0 ] == '0' )
         pszResult[ 0 ] = ' ';

      bAM = HB_FALSE;
   }
   else
      bAM = ( iHour != 12 );

   memcpy( pszResult + ulTimeLen, bAM ? " am" : " pm", 4 );

   hb_retclen_buffer( pszResult, ulTimeLen + 3 );
}
