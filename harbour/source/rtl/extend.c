/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * The Extend API
 *
 * Copyright 1999 Antonio Linares <alinares@fivetech.com>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version, with one exception:
 *
 * The exception is that if you link the Harbour Runtime Library (HRL)
 * and/or the Harbour Virtual Machine (HVM) with other files to produce
 * an executable, this does not by itself cause the resulting executable
 * to be covered by the GNU General Public License. Your use of that
 * executable is in no way restricted on account of linking the HRL
 * and/or HVM code into it.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA (or visit
 * their web site at http://www.gnu.org/).
 *
 */

/*
 * The following parts are Copyright of the individual authors.
 * www - http://www.harbour-project.org
 *
 * Copyright 1999 Victor Szel <info@szelvesz.hu>
 *    hb_retnlen()
 *    hb_retnilen()
 *    hb_retnllen()
 *    hb_retndlen()
 *
 * See doc/license.txt for licensing terms.
 *
 */

#include "extend.h"
#include "itemapi.h"
#include "set.h"
#include "dates.h"

/* NOTE: iParam = -1 can be used to access the return value. */
/* NOTE: iParam = 0 can be used to access the SELF object. */

PHB_ITEM hb_param( int iParam, int iMask )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_param(%d, %d)", iParam, iMask));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;
      USHORT uiType;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( pItem->type & IT_BYREF )
         pItem = hb_itemUnRef( pItem );

      uiType = pItem->type;

      if( ( uiType & ( USHORT ) iMask ) || ( uiType == IT_NIL && ( USHORT ) iMask == IT_ANY ) )
         return pItem;
   }

   return NULL;
}

/* NOTE: Caller should not modify the buffer returned by this function */

char * hb_parc( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parc(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_STRING( pItem ) )
         return pItem->item.asString.value;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetCPtr( pItem, ulArrayIndex );
      }
   }

   return "";
}

ULONG hb_parclen( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parclen(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_STRING( pItem ) )
         return pItem->item.asString.length;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetCLen( pItem, ulArrayIndex );
      }
   }

   return 0;
}

/* NOTE: Similar to _parclen() but returns the length including the
         terminating zero byte, and it only works for parameters passed by
         reference. */

ULONG hb_parcsiz( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parcsiz(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      /* NOTE: hb_parcsiz() will only work for strings passed by reference.
               CA-Cl*pper works like this. */

      if( IS_BYREF( pItem ) )
      {
         pItem = hb_itemUnRef( pItem );

         if( IS_STRING( pItem ) )
            return pItem->item.asString.length + 1;

         else if( IS_ARRAY( pItem ) )
         {
            va_list va;
            ULONG ulArrayIndex;

            va_start( va, iParam );
            ulArrayIndex = va_arg( va, ULONG );
            va_end( va );

            return hb_arrayGetCLen( pItem, ulArrayIndex ) + 1;
         }
      }
   }

   return 0;
}

/* NOTE: Using hb_stack.szDate as a temporary date buffer guaranties
         good behavior when multithreading. */

char * hb_pards( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_pards(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_DATE( pItem ) )
         return hb_dateDecStr( hb_stack.szDate, pItem->item.asDate.value );

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetDS( pItem, ulArrayIndex, hb_stack.szDate );
      }
   }

   return hb_dateDecStr( hb_stack.szDate, 0 );
}

int hb_parl( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parl(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_LOGICAL( pItem ) )
         return pItem->item.asLogical.value ? 1 : 0;

      else if( IS_INTEGER( pItem ) )
         return pItem->item.asInteger.value != 0 ? 1 : 0;

      else if( IS_LONG( pItem ) )
         return pItem->item.asLong.value != 0 ? 1 : 0;

      else if( IS_DOUBLE( pItem ) )
         return pItem->item.asDouble.value != 0.0 ? 1 : 0;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetL( pItem, ulArrayIndex ) ? 1 : 0;
      }
   }

   return 0;
}

double hb_parnd( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parnd(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_DOUBLE( pItem ) )
         return pItem->item.asDouble.value;

      else if( IS_INTEGER( pItem ) )
         return ( double ) pItem->item.asInteger.value;

      else if( IS_LONG( pItem ) )
         return ( double ) pItem->item.asLong.value;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetND( pItem, ulArrayIndex );
      }
   }

   return 0;
}

int hb_parni( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parni(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_INTEGER( pItem ) )
         return pItem->item.asInteger.value;

      else if( IS_LONG( pItem ) )
         return ( int ) pItem->item.asLong.value;

      else if( IS_DOUBLE( pItem ) )
         return ( int ) pItem->item.asDouble.value;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return ( int ) hb_arrayGetNL( pItem, ulArrayIndex );
      }
   }

   return 0;
}

long hb_parnl( int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parnl(%d, ...)", iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_BYREF( pItem ) )
         pItem = hb_itemUnRef( pItem );

      if( IS_LONG( pItem ) )
         return pItem->item.asLong.value;

      else if( IS_INTEGER( pItem ) )
         return ( long ) pItem->item.asInteger.value;

      else if( IS_DOUBLE( pItem ) )
         return ( long ) pItem->item.asDouble.value;

      else if( IS_DATE( pItem ) )
         return pItem->item.asDate.value;

      else if( IS_ARRAY( pItem ) )
      {
         va_list va;
         ULONG ulArrayIndex;

         va_start( va, iParam );
         ulArrayIndex = va_arg( va, ULONG );
         va_end( va );

         return hb_arrayGetNL( pItem, ulArrayIndex );
      }
   }

   return 0;
}

ULONG hb_parinfa( int iParamNum, ULONG uiArrayIndex )
{
   PHB_ITEM pArray;

   HB_TRACE(HB_TR_DEBUG, ("hb_parinfa(%d, %lu)", iParamNum, uiArrayIndex));

   pArray = hb_param( iParamNum, IT_ARRAY );

   if( pArray )
   {
      if( uiArrayIndex == 0 )
         return hb_arrayLen( pArray );
      else
         return ( long ) hb_arrayGetType( pArray, uiArrayIndex );
   }
   else
      return 0;
}

int hb_parinfo( int iParam )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_parinfo(%d)", iParam));

   if( iParam == 0 )
      return ( int ) hb_stack.pBase->item.asSymbol.paramcnt;
   else
   {
      if( ( iParam > 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
      {
         USHORT uiType;

         if( iParam == -1 )
            uiType = hb_stack.Return.type;
         else
            uiType = ( hb_stack.pBase + 1 + iParam )->type;

         if( uiType & IT_BYREF )
         {
            PHB_ITEM pItem;

            if( iParam == -1 )
               pItem = hb_itemUnRef( &hb_stack.Return );
            else
               pItem = hb_itemUnRef( hb_stack.pBase + 1 + iParam );

            if( pItem )
               uiType |= pItem->type;
         }

         return ( int ) uiType;
      }
      else
         return 0;
   }
}

int hb_pcount( void )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_pcount()"));

   return ( int ) hb_stack.pBase->item.asSymbol.paramcnt;
}

void hb_ret( void )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_ret()"));

   hb_itemClear( &hb_stack.Return );
}

void hb_reta( ULONG ulLen )  /* undocumented hb_reta() */
{
   HB_TRACE(HB_TR_DEBUG, ("hb_reta(%lu)", ulLen));

   hb_arrayNew( &hb_stack.Return, ulLen );
}

void hb_retc( char * szText )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retc(%s)", szText));

   hb_itemPutC( &hb_stack.Return, szText );
}

void hb_retclen( char * szText, ULONG ulLen )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retclen(%s, %lu)", szText, ulLen));

   hb_itemPutCL( &hb_stack.Return, szText, ulLen );
}

/* szDate must have yyyymmdd format */

void hb_retds( char * szDate )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retds(%s)", szDate));

   hb_itemPutDS( &hb_stack.Return, szDate );
}

void hb_retl( int iLogical )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retl(%d)", iLogical));

   hb_itemPutL( &hb_stack.Return, iLogical ? TRUE : FALSE );
}

void hb_retnd( double dNumber )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retnd(%lf)", dNumber));

   hb_itemPutND( &hb_stack.Return, dNumber );
}

void hb_retni( int iNumber )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retni(%d)", iNumber));

   hb_itemPutNI( &hb_stack.Return, iNumber );
}

void hb_retnl( long lNumber )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retnl(%ld)", lNumber));

   hb_itemPutNL( &hb_stack.Return, lNumber );
}

void hb_retnlen( double dNumber, int iWidth, int iDec )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retnlen(%lf, %d, %d)", dNumber, iWidth, iDec));

   hb_itemPutNLen( &hb_stack.Return, dNumber, iWidth, iDec );
}

void hb_retndlen( double dNumber, int iWidth, int iDec )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retndlen(%lf, %d, %d)", dNumber, iWidth, iDec));

   hb_itemPutNDLen( &hb_stack.Return, dNumber, iWidth, iDec );
}

void hb_retnilen( int iNumber, int iWidth )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retnilen(%d, %d)", iNumber, iWidth));

   hb_itemPutNILen( &hb_stack.Return, iNumber, iWidth );
}

void hb_retnllen( long lNumber, int iWidth )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_retnllen(%ld, %d)", lNumber, iWidth));

   hb_itemPutNLLen( &hb_stack.Return, lNumber, iWidth );
}

void hb_storc( char * szText, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_storc(%s, %d, ...)", szText, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutC( NULL, szText );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1  )
         hb_itemPutC( hb_itemUnRef( pItem ), szText );
   }
}

void hb_storclen( char * szText, ULONG ulLen, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_storclen(%s, %lu, %d, ...)", szText, ulLen, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutCL( NULL, szText, ulLen );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1  )
         hb_itemPutCL( hb_itemUnRef( pItem ), szText, ulLen );
   }
}

/* szDate should have yyyymmdd format */

void hb_stords( char * szDate, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_stords(%s, %d, ...)", szDate, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutDS( NULL, szDate );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1  )
         hb_itemPutDS( hb_itemUnRef( pItem ), szDate );
   }
}

void hb_storl( int iLogical, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_storl(%d, %d, ...)", iLogical, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutL( NULL, iLogical ? TRUE : FALSE );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1  )
         hb_itemPutL( hb_itemUnRef( pItem ), iLogical ? TRUE : FALSE );
   }
}

void hb_storni( int iValue, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_storni(%d, %d, ...)", iValue, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutNI( NULL, iValue );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1  )
         hb_itemPutNI( hb_itemUnRef( pItem ), iValue );
   }
}

void hb_stornl( long lValue, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_stornl(%ld, %d, ...)", lValue, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutNL( NULL, lValue );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1 )
         hb_itemPutNI( hb_itemUnRef( pItem ), lValue );
   }
}

void hb_stornd( double dNumber, int iParam, ... )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_stornd(%lf, %d, ...)", dNumber, iParam));

   if( ( iParam >= 0 && iParam <= hb_pcount() ) || ( iParam == -1 ) )
   {
      PHB_ITEM pItem;

      if( iParam == -1 )
         pItem = &hb_stack.Return;
      else
         pItem = hb_stack.pBase + 1 + iParam;

      if( IS_ARRAY( pItem ) )
      {
         va_list va;
         PHB_ITEM pItemNew = hb_itemPutND( NULL, dNumber );
         va_start( va, iParam );
         hb_arraySet( pItem, va_arg( va, ULONG ), pItemNew );
         va_end( va );
         hb_itemRelease( pItemNew );
      }

      else if( IS_BYREF( pItem ) || iParam == -1 )
         hb_itemPutND( hb_itemUnRef( pItem ), dNumber );
   }
}

