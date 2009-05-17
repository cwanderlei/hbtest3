/*
 * $Id$
 */

/*
 * ODBC Database Driver
 *
 * Copyright 2009 Mindaugas Kavaliauskas <dbtopas at dbtopas.lt>
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
#include "hbapiitm.h"
#include "hbdate.h"
#include "hbvm.h"
#include "../hbrddsql.h"

#include <sql.h>
#include <sqlext.h>

static HB_ERRCODE odbcConnect( SQLDDCONNECTION* pConnection, PHB_ITEM pItem );
static HB_ERRCODE odbcDisconnect( SQLDDCONNECTION* pConnection );
static HB_ERRCODE odbcExecute( SQLDDCONNECTION* pConnection, PHB_ITEM pItem );
static HB_ERRCODE odbcOpen( SQLBASEAREAP pArea );
static HB_ERRCODE odbcClose( SQLBASEAREAP pArea );
static HB_ERRCODE odbcGoTo( SQLBASEAREAP pArea, ULONG ulRecNo );
static HB_ERRCODE odbcGetValue( SQLBASEAREAP pArea, USHORT uiIndex, PHB_ITEM pItem );
static HB_ERRCODE odbcGetVarLen( SQLBASEAREAP pArea, USHORT uiIndex, ULONG * pLength );


static SDDNODE odbcdd =
{
   NULL,
   "ODBC",
   (SDDFUNC_CONNECT)    odbcConnect,
   (SDDFUNC_DISCONNECT) odbcDisconnect,
   (SDDFUNC_EXECUTE)    odbcExecute,
   (SDDFUNC_OPEN)       odbcOpen,
   (SDDFUNC_CLOSE)      odbcClose,
   (SDDFUNC_GOTO)       odbcGoTo,
   (SDDFUNC_GETVALUE)   odbcGetValue,
   (SDDFUNC_GETVARLEN)  odbcGetVarLen
};


HB_FUNC_EXTERN( SQLBASE );


static void hb_odbcdd_init( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );

   if ( ! hb_sddRegister( & odbcdd ) )
   {
      hb_errInternal( HB_EI_RDDINVALID, NULL, NULL, NULL );
      HB_FUNC_EXEC( SQLBASE );   /* force SQLBASE linking */
   }
}


#define __PRG_SOURCE__ __FILE__

#ifdef HB_PCODE_VER
   #undef HB_PRG_PCODE_VER
   #define HB_PRG_PCODE_VER HB_PCODE_VER
#endif

HB_FUNC( SDDODBC ) {;}

HB_INIT_SYMBOLS_BEGIN( odbcdd__InitSymbols )
{ "SDDODBC", {HB_FS_PUBLIC}, {HB_FUNCNAME( SDDODBC )}, NULL },
HB_INIT_SYMBOLS_END( odbcdd__InitSymbols )

HB_CALL_ON_STARTUP_BEGIN( _hb_odbcdd_init_ )
   hb_vmAtInit( hb_odbcdd_init, NULL );
HB_CALL_ON_STARTUP_END( _hb_odbcdd_init_ )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup odbcdd__InitSymbols
   #pragma startup _hb_odbcdd_init_
#elif defined( HB_MSC_STARTUP )
   #if defined( HB_OS_WIN_64 )
      #pragma section( HB_MSC_START_SEGMENT, long, read )
   #endif
   #pragma data_seg( HB_MSC_START_SEGMENT )
   static HB_$INITSYM hb_vm_auto_odbcdd__InitSymbols = odbcdd__InitSymbols;
   static HB_$INITSYM hb_vm_auto_odbcdd_init = _hb_odbcdd_init_;
   #pragma data_seg()
#endif


/*=====================================================================================*/
static USHORT hb_errRT_ODBCDD( ULONG ulGenCode, ULONG ulSubCode, const char * szDescription, const char * szOperation, USHORT uiOsCode )
{
   USHORT uiAction;
   PHB_ITEM pError;

   pError = hb_errRT_New( ES_ERROR, "SDDODBC", ulGenCode, ulSubCode, szDescription, szOperation, uiOsCode, EF_NONE );
   uiAction = hb_errLaunch( pError );
   hb_itemRelease( pError );
   return uiAction;
}

/*============= SDD METHODS =============================================================*/

static HB_ERRCODE odbcConnect( SQLDDCONNECTION* pConnection, PHB_ITEM pItem )
{
   SQLHENV       hEnv = NULL;
   SQLHDBC       hConnect = NULL;
   SQLCHAR       cBuffer[ 1024 ];
   SQLSMALLINT   iLen = 1024;

   if( SQL_SUCCEEDED( SQLAllocHandle( SQL_HANDLE_ENV, SQL_NULL_HANDLE, &hEnv ) ) )
   {
      SQLSetEnvAttr( hEnv, SQL_ATTR_ODBC_VERSION, ( SQLPOINTER ) SQL_OV_ODBC3, SQL_IS_UINTEGER );

      if( SQL_SUCCEEDED( SQLAllocHandle( SQL_HANDLE_DBC, hEnv, &hConnect ) ) )
      {
         cBuffer[ 0 ] ='\0';

         if( SQL_SUCCEEDED( SQLDriverConnect( hConnect, NULL, ( SQLCHAR* ) hb_arrayGetCPtr( pItem, 2 ), hb_arrayGetCLen( pItem, 2 ),  
                                              cBuffer, 1024, &iLen, SQL_DRIVER_NOPROMPT ) ) )
         {
            pConnection->hConnection = ( void* ) hConnect;
            pConnection->hCargo = ( void* ) hEnv;
            return HB_SUCCESS;
         }
         SQLFreeHandle( SQL_HANDLE_DBC, hConnect );
      }
      SQLFreeHandle( SQL_HANDLE_ENV, hEnv );
   }
   return HB_FAILURE;
}


static HB_ERRCODE odbcDisconnect( SQLDDCONNECTION* pConnection )
{
   SQLDisconnect( ( SQLHDBC ) pConnection->hConnection );
   SQLFreeHandle( SQL_HANDLE_DBC, ( SQLHDBC ) pConnection->hConnection );
   SQLFreeHandle( SQL_HANDLE_ENV, ( SQLHENV ) pConnection->hCargo );
   return HB_SUCCESS;
}


static HB_ERRCODE odbcExecute( SQLDDCONNECTION* pConnection, PHB_ITEM pItem )
{
   SQLHSTMT     hStmt;
   SQLLEN       iCount;

   if ( ! SQL_SUCCEEDED( SQLAllocStmt( ( SQLHDBC ) pConnection->hConnection, &hStmt ) ) )
   {
      hb_errRT_ODBCDD( EG_OPEN, ESQLDD_STMTALLOC, NULL, hb_itemGetCPtr( pItem ), 0 );
      return HB_FAILURE;
   }

   pConnection->ulAffectedRows = 0;

   if ( SQL_SUCCEEDED( SQLExecDirect( hStmt, ( SQLCHAR* ) hb_itemGetCPtr( pItem ), hb_itemGetCLen( pItem ) ) ) )
   {
      if ( SQL_SUCCEEDED( SQLRowCount( hStmt, &iCount ) ) )
      {
         if( iCount > 0 )
           pConnection->ulAffectedRows = ( ULONG ) iCount;
         SQLFreeStmt( hStmt, SQL_DROP );
         return HB_SUCCESS;
      }
   }

   /* TODO: error processing */

   SQLFreeStmt( hStmt, SQL_DROP );
   return HB_FAILURE;
}


static HB_ERRCODE odbcOpen( SQLBASEAREAP pArea )
{
   SQLHSTMT     hStmt;
   SQLSMALLINT  iNameLen, iDataType, iDec, iNull;
   SQLCHAR      cName[ 256 ];
   SQLULEN      uiSize;
   PHB_ITEM     pItemEof, pItem;
   DBFIELDINFO  pFieldInfo;
   BOOL         bError;
   USHORT       uiFields, uiIndex, uiError = 0;

   if ( ! SQL_SUCCEEDED( SQLAllocHandle( SQL_HANDLE_STMT, ( SQLHDBC ) pArea->pConnection->hConnection, &hStmt ) ) )
   {
      hb_errRT_ODBCDD( EG_OPEN, ESQLDD_STMTALLOC, NULL, pArea->szQuery, 0 );
      return HB_FAILURE;
   }

   if ( ! SQL_SUCCEEDED( SQLExecDirect( hStmt, ( SQLCHAR* ) pArea->szQuery, strlen( pArea->szQuery ) ) ) )
   {
      SQLFreeStmt( hStmt, SQL_DROP );
      hb_errRT_ODBCDD( EG_OPEN, ESQLDD_INVALIDQUERY, NULL, pArea->szQuery, 0 );
      return HB_FAILURE;
   }

   if ( ! SQL_SUCCEEDED( SQLNumResultCols( hStmt, &iNameLen ) ) )
   {
      SQLFreeStmt( hStmt, SQL_DROP );
      hb_errRT_ODBCDD( EG_OPEN, ESQLDD_STMTDESCR + 1000, NULL, pArea->szQuery, 0 );
      return HB_FAILURE;
   }

   uiFields = ( USHORT ) iNameLen; 
   SELF_SETFIELDEXTENT( (AREAP) pArea, uiFields );

   pItemEof = hb_itemArrayNew( uiFields );

   /* HB_TRACE( HB_TR_ALWAYS, ("fieldcount=%d", iNameLen) ); */

   bError = FALSE;
   for ( uiIndex = 0; uiIndex < uiFields; uiIndex++  )
   {
      if ( ! SQL_SUCCEEDED( SQLDescribeCol( hStmt, ( SQLSMALLINT ) uiIndex + 1, ( SQLCHAR* ) cName, 256, &iNameLen, &iDataType, &uiSize, &iDec, &iNull ) ) )
      {
         hb_itemRelease( pItemEof );
         SQLFreeStmt( hStmt, SQL_DROP );
         hb_errRT_ODBCDD( EG_OPEN, ESQLDD_STMTDESCR + 1001, NULL, pArea->szQuery, 0 );
         return HB_FAILURE;
      }

      pFieldInfo.atomName = ( BYTE* ) cName;
      pFieldInfo.atomName[ MAX_FIELD_NAME ] = '\0';
      hb_strUpper( (char *) pFieldInfo.atomName, MAX_FIELD_NAME + 1 );

      pFieldInfo.uiLen = uiSize;
      pFieldInfo.uiDec = iDec;

      /* HB_TRACE( HB_TR_ALWAYS, ("field: name=%s type=%d len=%d dec=%d null=%d", pFieldInfo.atomName, iDataType, uiSize, iDec, iNull ) ); */

      switch( iDataType )
      {
         case SQL_CHAR:
         case SQL_VARCHAR:
         case SQL_LONGVARCHAR:
           pFieldInfo.uiType = HB_FT_STRING;
           break;

         case SQL_TINYINT:
         case SQL_SMALLINT:
         case SQL_INTEGER:
           pFieldInfo.uiType = HB_FT_INTEGER;
           break;

         case SQL_DECIMAL:
           pFieldInfo.uiType = HB_FT_LONG;
           break;

         case SQL_REAL:
         case SQL_FLOAT:
         case SQL_DOUBLE:
           pFieldInfo.uiType = HB_FT_DOUBLE;
           break;

         case SQL_BIT:
           pFieldInfo.uiType = HB_FT_LOGICAL;
           break;

         case SQL_DATE:
         case SQL_TYPE_DATE:
           pFieldInfo.uiType = HB_FT_DATE;
           break;

         case SQL_TIME:
         case SQL_TYPE_TIME:
           pFieldInfo.uiType = HB_FT_DATE;
           break;

         /*  SQL_DATETIME = SQL_DATE = 9 */
         case SQL_TIMESTAMP:
         case SQL_TYPE_TIMESTAMP:
           pFieldInfo.uiType = HB_FT_DAYTIME;
           break;

         default:
           /* HB_TRACE( HB_TR_ALWAYS, ("new sql type=%d", iDataType) ); */
           bError = TRUE;
           uiError = ( USHORT ) iDataType;
           pFieldInfo.uiType = 0;
           pFieldInfo.uiType = HB_FT_STRING;
           break;
      }

      if ( ! bError )
      {
         switch ( pFieldInfo.uiType )
         {
            case HB_FT_STRING:
            {
               char*    pStr;

               pStr = (char*) hb_xgrab( ( ULONG ) pFieldInfo.uiLen + 1 );
               memset( pStr, ' ', pFieldInfo.uiLen );
               pStr[ pFieldInfo.uiLen ] = '\0';

               pItem = hb_itemPutCL( NULL, pStr, pFieldInfo.uiLen );
               hb_xfree( pStr );
               break;
            }

            case HB_FT_MEMO:
               pItem = hb_itemPutC( NULL, "" );
               break;

            case HB_FT_INTEGER:
               pItem = hb_itemPutNI( NULL, 0 );
               break;

            case HB_FT_LONG:
               if( pFieldInfo.uiDec == 0 )
                  pItem = hb_itemPutNLLen( NULL, 0, pFieldInfo.uiLen );
               else
                  pItem = hb_itemPutNDLen( NULL, 0.0, pFieldInfo.uiLen, pFieldInfo.uiDec );
               break;

            case HB_FT_DOUBLE:
               pItem = hb_itemPutNDLen( NULL, 0.0, pFieldInfo.uiLen, pFieldInfo.uiDec );
               break;

            case HB_FT_LOGICAL:
               pItem = hb_itemPutL( NULL, FALSE );
               break;

            case HB_FT_DATE:
               pItem = hb_itemPutDL( NULL, 0 );
               break;

            case HB_FT_TIME:
               pItem = hb_itemPutTDT( NULL, 0, 0 );
               break;

           case HB_FT_DAYTIME:
               pItem = hb_itemPutTDT( NULL, 0, 0 );
               break;

            default:
               pItem = hb_itemNew( NULL );
               bError = TRUE;
               break;
         }

         hb_arraySetForward( pItemEof, uiIndex + 1, pItem );
         hb_itemRelease( pItem );

         if ( ! bError )
            bError = ( SELF_ADDFIELD( (AREAP) pArea, &pFieldInfo ) == HB_FAILURE );
      }

      if ( bError )
         break;
   }

   if ( bError )
   {
     hb_itemRelease( pItemEof );
     SQLFreeStmt( hStmt, SQL_DROP );
     hb_errRT_ODBCDD( EG_CORRUPTION, ESQLDD_INVALIDFIELD, "Invalid field type", pArea->szQuery, uiError );
     return HB_FAILURE;
   }

   pArea->ulRecCount = 0;
   pArea->ulRecMax = SQLDD_ROWSET_INIT;

   pArea->pRow = ( void** ) hb_xgrab( SQLDD_ROWSET_INIT * sizeof( void* ) );
   memset( pArea->pRow, 0, SQLDD_ROWSET_INIT * sizeof( void* ) );
   pArea->pRowFlags = (BYTE*) hb_xgrab( SQLDD_ROWSET_INIT * sizeof( BYTE ) );
   memset( pArea->pRowFlags, 0, SQLDD_ROWSET_INIT * sizeof( BYTE ) );

   pArea->pRow[ 0 ] = pItemEof;
   pArea->pRowFlags[ 0 ] = SQLDD_FLAG_CACHED;

   pArea->pStmt = ( void* ) hStmt;
   return HB_SUCCESS;
}


static HB_ERRCODE odbcClose( SQLBASEAREAP pArea )
{
   if ( pArea->pStmt )
   {
      SQLFreeStmt( ( SQLHSTMT ) pArea->pStmt, SQL_DROP );
      pArea->pStmt = NULL;
   }
   return HB_SUCCESS;
}


static HB_ERRCODE odbcGoTo( SQLBASEAREAP pArea, ULONG ulRecNo )
{
   SQLHSTMT     hStmt = ( SQLHSTMT ) pArea->pStmt;
   SQLRETURN    res;
   SQLLEN       iLen;
   PHB_ITEM     pArray, pItem;
   LPFIELD      pField;
   USHORT       ui;

   while ( ulRecNo > pArea->ulRecCount && ! pArea->fFetched )
   {
      if( ! SQL_SUCCEEDED( SQLFetch( hStmt ) ) )
      {
         pArea->fFetched = TRUE;
         break;
      }

      pArray = hb_itemArrayNew( pArea->uiFieldCount );
      for ( ui = 1; ui <= pArea->uiFieldCount; ui++ )
      {
         pItem = NULL;
         res = 0;
         pField = pArea->lpFields + ui - 1;
         switch( pField->uiType )
         {
            case HB_FT_STRING:
            {
               /* TODO: it is not clear for me, how can I get string length */

               char *  val = ( char * ) hb_xgrab( 1024 );
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_CHAR, ( SQLCHAR * ) val, 1024, &iLen ) ) )
               {
                  if( iLen > 0 )
                     pItem = hb_itemPutCL( NULL, val, ( ULONG ) iLen );
               }
               hb_xfree( val );
               break;
            }

            case HB_FT_INTEGER:
            {
               long int  val = 0;
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_LONG, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutNLLen( NULL, val, pField->uiLen );
               }
               break;
            }

            case HB_FT_LONG:
               if( pField->uiDec == 0 )
               {
                  long int  val = 0;
                  if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_LONG, &val, sizeof( val ), &iLen ) ) )
                  {
                     pItem = hb_itemPutNLLen( NULL, val, pField->uiLen );
                  }
               }
               else
               {
                  double  val = 0.0;
                  if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_DOUBLE, &val, sizeof( val ), &iLen ) ) )
                  {
                     pItem = hb_itemPutNDLen( NULL, val, pField->uiLen, pField->uiDec );
                  }
               }
               break;

            case HB_FT_DOUBLE:
            {
               double  val = 0.0;
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_DOUBLE, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutNDLen( NULL, val, pField->uiLen, pField->uiDec );
               }
               break;
            }

            case HB_FT_LOGICAL:
            {
               unsigned char  val = 0;
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_BIT, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutL( NULL, val != 0 );
               }
               break;
            }

            case HB_FT_DATE:
            {
               DATE_STRUCT  val = {0,0,0};
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_DATE, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutD( NULL, val.year, val.month, val.day );
               }
               break;
            }

            case HB_FT_TIME:
            {
               TIME_STRUCT  val = {0,0,0};
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_TIME, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutTDT( NULL, 0, hb_timeEncode( val.hour, val.minute, val.second, 0 ) );
               }
               break;
            }

            case HB_FT_DAYTIME:
            {
               TIMESTAMP_STRUCT  val = {0,0,0,0,0,0,0};
               if( SQL_SUCCEEDED( res = SQLGetData( hStmt, ui, SQL_C_TIMESTAMP, &val, sizeof( val ), &iLen ) ) )
               {
                  pItem = hb_itemPutTDT( NULL, hb_dateEncode( val.year, val.month, val.day ), 
                                         hb_timeEncode( val.hour, val.minute, val.second, val.fraction / 1000000 ) );
               }
               break;
            }
         }

         /* TODO: check SQL_SUCCEEDED( res ) */
         /* TODO: check for SQL_NO_TOTAL. What does this mean? */
         HB_SYMBOL_UNUSED( res );

         /* NULL -> NIL */
         if( iLen == SQL_NULL_DATA )
         {
            hb_itemRelease( pItem );
            pItem = NULL;
         }

         if( pItem )
         {
            hb_arraySetForward( pArray, ui, pItem );
            hb_itemRelease( pItem );
         }
      }
      if ( pArea->ulRecCount + 1 <= pArea->ulRecMax )
      {
         pArea->pRow = (void**) hb_xrealloc( pArea->pRow, ( pArea->ulRecMax + SQLDD_ROWSET_RESIZE ) * sizeof( void* ) );
         pArea->pRowFlags = (BYTE*) hb_xrealloc( pArea->pRowFlags, ( pArea->ulRecMax + SQLDD_ROWSET_RESIZE ) * sizeof( BYTE ) );
         pArea->ulRecMax += SQLDD_ROWSET_RESIZE;
      }

      pArea->ulRecCount++;
      pArea->pRow[ pArea->ulRecCount ] = pArray;
      pArea->pRowFlags[ pArea->ulRecCount ] = SQLDD_FLAG_CACHED;
   }

   if ( ulRecNo <= 0 || ulRecNo > pArea->ulRecCount )
   {
      pArea->pRecord = pArea->pRow[ 0 ];
      pArea->bRecordFlags = pArea->pRowFlags[ 0 ];
      pArea->fPositioned = FALSE;
   }
   else
   {
      pArea->pRecord = pArea->pRow[ ulRecNo ];
      pArea->bRecordFlags = pArea->pRowFlags[ ulRecNo ];
      pArea->fPositioned = TRUE;
   }
   return HB_SUCCESS;
}


static HB_ERRCODE odbcGetValue( SQLBASEAREAP pArea, USHORT uiIndex, PHB_ITEM pItem )
{
   HB_SYMBOL_UNUSED( pArea );
   HB_SYMBOL_UNUSED( uiIndex );
   HB_SYMBOL_UNUSED( pItem );
   return HB_SUCCESS;
}


static HB_ERRCODE odbcGetVarLen( SQLBASEAREAP pArea, USHORT uiIndex, ULONG * pLength )
{
   HB_SYMBOL_UNUSED( pArea );
   HB_SYMBOL_UNUSED( uiIndex );
   HB_SYMBOL_UNUSED( pLength );
   return HB_SUCCESS;
}
