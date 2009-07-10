/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Compatibility functions from the SAMPLES directory of Clipper.
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

/* NOTE: szTime must be 9 chars large. */

static char * hb_SecToTimeStr( char * pszTime, ULONG ulTime )
{
   int iValue;

   HB_TRACE(HB_TR_DEBUG, ("hb_SecToTimeStr(%s, %lu)", pszTime, ulTime));

   iValue = ( int ) ( ( ulTime / 3600 ) % 24 );
   pszTime[ 0 ] = ( char ) ( iValue / 10 ) + '0';
   pszTime[ 1 ] = ( char ) ( iValue % 10 ) + '0';
   pszTime[ 2 ] = ':';
   iValue = ( int ) ( ( ulTime / 60 ) % 60 );
   pszTime[ 3 ] = ( char ) ( iValue / 10 ) + '0';
   pszTime[ 4 ] = ( char ) ( iValue % 10 ) + '0';
   pszTime[ 5 ] = ':';
   iValue = ( int ) ( ulTime % 60 );
   pszTime[ 6 ] = ( char ) ( iValue / 10 ) + '0';
   pszTime[ 7 ] = ( char ) ( iValue % 10 ) + '0';
   pszTime[ 8 ] = '\0';

   return pszTime;
}

static ULONG hb_TimeStrToSec( const char * pszTime )
{
   ULONG ulLen;
   ULONG ulTime = 0;

   HB_TRACE(HB_TR_DEBUG, ("hb_TimeStrToSec(%s)", pszTime));

   ulLen = strlen( pszTime );

   if( ulLen >= 1 )
      ulTime += ( ULONG ) hb_strVal( pszTime, ulLen ) * 3600;

   if( ulLen >= 4 )
      ulTime += ( ULONG ) hb_strVal( pszTime + 3, ulLen - 3 ) * 60;

   if( ulLen >= 7 )
      ulTime += ( ULONG ) hb_strVal( pszTime + 6, ulLen - 6 );

   return ulTime;
}

HB_FUNC( DAYS )
{
   hb_retnl( hb_parnl( 1 ) / 86400 );
}

HB_FUNC( ELAPTIME )
{
   ULONG ulStart = hb_TimeStrToSec( hb_parcx( 1 ) );
   ULONG ulEnd = hb_TimeStrToSec( hb_parcx( 2 ) );
   char szTime[ 9 ];

   hb_retc( hb_SecToTimeStr( szTime, ( ulEnd < ulStart ? 86400 : 0 ) + ulEnd - ulStart ) );
}

HB_FUNC( SECS )
{
   hb_retnl( hb_TimeStrToSec( hb_parcx( 1 ) ) );
}

HB_FUNC( TSTRING )
{
   char szTime[ 9 ];

   hb_retc( hb_SecToTimeStr( szTime, hb_parnl( 1 ) ) );
}
