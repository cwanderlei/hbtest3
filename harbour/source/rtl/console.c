/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * The Console API
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
 * Copyright 1999 Eddie Runia <eddie@runia.com>
 *    HB___ACCEPT()
 *
 * Copyright 1999 David G. Holm <dholm@jsd-llc.com>
 *    adjust_pos(), hb_altout(), hb_devout(), HB_DEVOUT(), hb_devpos(),
 *    HB_DEVPOS(), hb_dispout(), HB___EJECT(), hb_max_col(), HB_MAXCOL(),
 *    hb_max_row(), HB_MAXROW(), hb_out(), hb_outerr(), HB_OUTERR(),
 *    hb_outstd(), HB_OUTSTD(), HB_PCOL(), HB_PROW(), hb_setpos(),
 *    HB_SETPOS(), HB_SETPRC(), HB_SCROLL(), and hb_consoleInitialize()
 *
 * Copyright 1999 Victor Szel <info@szelvesz.hu>
 *    hb_consoleGetNewLine()
 *    HB_SETPOSBS()
 *    HB_DISPBOX() (GT version)
 *    HB_DISPBEGIN()
 *    HB_DISPEND()
 *    HB_DISPCOUNT()
 *    HB_ISCOLOR()
 *    HB_NOSNOW()
 *    HB___ACCEPTSTR()
 *    HB___COLORINDEX()
 *
 * See doc/license.txt for licensing terms.
 *
 */

#include "extend.h"
#include "itemapi.h"
#include "errorapi.h"
#include "filesys.h"
#include "dates.h"
#include "set.h"
#include "inkey.h"
#include "inkey.ch"
#include "gtapi.h"            /* HARBOUR_USE_GTAPI is checked inside gtapi.h, so that
                                 we can always get the border styles */

#if defined(__GNUC__) && ! defined(__MINGW32__)
   #include <unistd.h>
   #if defined(__DJGPP__) || defined(__CYGWIN__) || defined(HARBOUR_GCC_OS2)
      #include <io.h>
   #endif
#else
   #include <io.h>
#endif

#if defined(__CYGWIN__)
   #include <unistd.h>
   #include <termios.h>
#endif

#define ACCEPT_BUFFER_LEN 256 /* length of input buffer for ACCEPT command */

#if defined(OS_UNIX_COMPATIBLE)
   #define CRLF_BUFFER_LEN 2     /*length of buffer for CR/LF characters */
#else
   #define CRLF_BUFFER_LEN 3     /*length of buffer for CR/LF characters */
#endif

static BOOL   s_bInit = FALSE;
static USHORT s_uiDevRow;
static USHORT s_uiDevCol;
static USHORT s_uiPRow;
static USHORT s_uiPCol;
static char   s_szCrLf[ CRLF_BUFFER_LEN ];
static char   s_szAcceptResult[ ACCEPT_BUFFER_LEN ];
static int    s_iFilenoStdout;
static int    s_iFilenoStderr;

void hb_consoleInitialize( void )
{
   int iStderr;

#if defined(OS_DOS_COMPATIBLE)
   s_szCrLf[ 0 ] = HB_CHAR_CR;
   s_szCrLf[ 1 ] = HB_CHAR_LF;
   s_szCrLf[ 2 ] = '\0';
#else
   s_szCrLf[ 0 ] = HB_CHAR_LF;
   s_szCrLf[ 1 ] = '\0';
#endif

   s_szAcceptResult[ 0 ] = '\0';

   s_uiPRow = s_uiPCol = 0;

   /* Some compilers open stdout and stderr in text mode, but
      Harbour needs them to be open in binary mode. */

   s_iFilenoStdout = fileno( stdout );
   hb_fsSetDevMode( s_iFilenoStdout, FM_BINARY );

   iStderr = hb_cmdargNum( "STDERR" ); /* Undocumented CA-Clipper switch //STDERR:x */

   if( iStderr < 0 )        /* //STDERR not used or invalid */
      s_iFilenoStderr = fileno( stderr );
   else if( iStderr == 0 )  /* //STDERR with no parameter or 0 */
      s_iFilenoStderr = s_iFilenoStdout;
   else                     /* //STDERR:x */
      s_iFilenoStderr = iStderr;

   hb_fsSetDevMode( s_iFilenoStderr, FM_BINARY );

#ifdef HARBOUR_USE_GTAPI
   hb_gtInit();
   hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
   hb_gtSetCursor( SC_NORMAL );
#else
   s_uiDevRow = 0;
   s_uiDevCol = 0;
#endif

   s_bInit = TRUE;
}

void hb_consoleRelease( void )
{
   hb_fsSetDevMode( s_iFilenoStdout, FM_TEXT );
   hb_fsSetDevMode( s_iFilenoStderr, FM_TEXT );

   /* The is done by the OS from now on */
   s_szCrLf[ 0 ] = HB_CHAR_LF;
   s_szCrLf[ 1 ] = '\0';

#ifdef HARBOUR_USE_GTAPI
   hb_gtExit();
#endif

   s_bInit = FALSE;
}

char * hb_consoleGetNewLine( void )
{
   return s_szCrLf;
}

/*  $DOC$
 *  $FUNCNAME$
 *      HB_OSNewLine
 *  $CATEGORY$
 *      Operating System Specific
 *  $ONELINER$
 *      Returns the newline character(s) to use with the current OS
 *  $SYNTAX$
 *      HB_OSNewLine() --> cString
 *  $ARGUMENTS$
 *  $RETURNS$
 *      A character string containing the character or characters required
 *      to move the screen cursor or print head to the start of a new line.
 *      The string will hold either CHR( 10 ) or CHR( 13 ) + CHR( 10 ).
 *  $DESCRIPTION$
 *      Returns a character string containing the character or characters
 *      required to move the screen cursor or print head to the start of a
 *      new line for the operating system that the program is running on
 *      (or thinks it is running on, if an OS emulator is being used).
 *  $EXAMPLES$
 *      // Get the newline character(s) for the current OS using defaults.
 *      STATIC s_cNewLine
 *      ...
 *      s_cNewLine := HB_OSNewLine()
 *      ...
 *      OutStd( "Hello World!" + s_cNewLine )
 *      ...
 *  $TESTS$
 *      valtype( HB_OSNewLine() ) == "C"
 *      LEN( HB_OSNewLine() ) == 1
 *  $STATUS$
 *      C
 *  $COMPLIANCE$
 *      This is an add-on Operating System Tool function.
 *  $SEEALSO$
 *      OS(), OUTSTD(), OUTERR()
 *  $END$
 */

HARBOUR HB_HB_OSNEWLINE( void )
{
   hb_retc( s_szCrLf );
}

USHORT hb_max_row( void )
{
#ifdef HARBOUR_USE_GTAPI
   return hb_gtMaxRow();
#else
   #if defined(HB_OS_UNIX_COMPATIBLE)
      return 23;
   #else
      return 24;
   #endif
#endif
}

USHORT hb_max_col( void )
{
#ifdef HARBOUR_USE_GTAPI
   return hb_gtMaxCol();
#else
   return 79;
#endif
}

#ifndef HARBOUR_USE_GTAPI
static void adjust_pos( char * pStr, ULONG ulLen, USHORT * row, USHORT * col, USHORT max_row, USHORT max_col )
{
   ULONG ulCount;
   char * pPtr = pStr;

   for( ulCount = 0; ulCount < ulLen; ulCount++ )
   {
      switch( *pPtr++  )
      {
         case HB_CHAR_BEL:
            break;

         case HB_CHAR_BS:
            if( *col ) ( *col )--;
            else
            {
               *col = max_col;
               if( *row ) ( *row )--;
            }
            break;

         case HB_CHAR_LF:
            if( *row < max_row ) ( *row )++;
            break;

         case HB_CHAR_CR:
            *col = 0;
            break;

         default:
            if( *col < max_col ) ( *col )++;
            else
            {
               *col = 0;
               if( *row < max_row ) ( *row )++;
            }
      }
   }
}
#endif

typedef void hb_out_func_typedef( char *, ULONG );

/* Format items for output, then call specified output function */
static void hb_out( USHORT uiParam, hb_out_func_typedef * hb_out_func )
{
   PHB_ITEM pItem = hb_param( uiParam, IT_ANY );

   switch( pItem->type )
   {
      case IT_STRING:
         hb_out_func( hb_itemGetCPtr( pItem ), hb_itemGetCLen( pItem ) );
         break;

      case IT_DATE:
      {
         char szBuffer[ 11 ];
         hb_dtoc( hb_pards( uiParam ), szBuffer, hb_set.HB_SET_DATEFORMAT );
         hb_out_func( szBuffer, strlen( szBuffer ) );
         break;
      }

      case IT_DOUBLE:
      case IT_INTEGER:
      case IT_LONG:
      {
         char * szText = hb_itemStr( pItem, NULL, NULL ); /* Let hb_itemStr() do the hard work */
         if( szText )
         {
            hb_out_func( szText, strlen( szText ) );
            hb_xfree( szText );
         }
         break;
      }
      case IT_NIL:
         hb_out_func( "NIL", 3 );
         break;

      case IT_LOGICAL:
         if( hb_itemGetL( pItem ) )
            hb_out_func( ".T.", 3 );
         else
            hb_out_func( ".F.", 3 );
         break;

      default:
         break;
   }
}

/* Output an item to STDOUT */
void hb_outstd( char * pStr, ULONG ulLen )
{
   USHORT user_ferror;

   if( ulLen == 0 )
      ulLen = strlen( pStr );

#ifdef HARBOUR_USE_GTAPI
   if( s_bInit )
      hb_gtPreExt();
#endif

   user_ferror = hb_fsError(); /* Save current user file error code */
   hb_fsWriteLarge( s_iFilenoStdout, ( BYTE * ) pStr, ulLen );
   hb_fsSetError( user_ferror ); /* Restore last user file error code */

#ifdef HARBOUR_USE_GTAPI
   if( s_bInit )
   {
      #ifndef __CYGWIN__
      if( isatty( s_iFilenoStdout ) )
      #endif
      {
         s_uiDevRow = hb_gt_Row();
         s_uiDevCol = hb_gt_Col();
         hb_gtSetPos( s_uiDevRow, s_uiDevCol );
      }
      hb_gtPostExt();
   }
#else
   adjust_pos( pStr, ulLen, &s_uiDevRow, &s_uiDevCol, hb_max_row(), hb_max_col() );
#endif
}

/* Output an item to STDERR */
void hb_outerr( char * pStr, ULONG ulLen )
{
   USHORT user_ferror;

   if( ulLen == 0 )
      ulLen = strlen( pStr );

#ifdef HARBOUR_USE_GTAPI
   if( s_bInit )
      hb_gtPreExt();
#endif

   user_ferror = hb_fsError(); /* Save current user file error code */
   hb_fsWriteLarge( s_iFilenoStderr, ( BYTE * ) pStr, ulLen );
   hb_fsSetError( user_ferror ); /* Restore last user file error code */

#ifdef HARBOUR_USE_GTAPI
   if( s_bInit )
   {
      #ifndef __CYGWIN__
      if( isatty( s_iFilenoStdout ) )
      #endif
      {
         s_uiDevRow = hb_gt_Row();
         s_uiDevCol = hb_gt_Col();
         hb_gtSetPos( s_uiDevRow, s_uiDevCol );
      }
      hb_gtPostExt();
   }
#else
   adjust_pos( pStr, ulLen, &s_uiDevRow, &s_uiDevCol, hb_max_row(), hb_max_col() );
#endif
}

/* Output an item to the screen and/or printer and/or alternate */
static void hb_altout( char * pStr, ULONG ulLen )
{
   if( hb_set.HB_SET_CONSOLE )
   {
#ifdef HARBOUR_USE_GTAPI
      hb_gtWriteCon( ( BYTE * ) pStr, ulLen );
      hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
#else
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( s_iFilenoStdout, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
      adjust_pos( pStr, ulLen, &s_uiDevRow, &s_uiDevCol, hb_max_row(), hb_max_col() );
#endif
   }

   if( hb_set.HB_SET_ALTERNATE && hb_set_althan != FS_ERROR )
   {
      /* Print to alternate file if SET ALTERNATE ON and valid alternate file */
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( hb_set_althan, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
   }

   if( hb_set_extrahan != FS_ERROR )
   {
      /* Print to extra file if valid alternate file */
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( hb_set_extrahan, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
   }

   if( hb_set.HB_SET_PRINTER && hb_set_printhan != FS_ERROR )
   {
      /* Print to printer if SET PRINTER ON and valid printer file */
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( hb_set_printhan, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
      if( ulLen + s_uiPCol > USHRT_MAX ) s_uiPCol = USHRT_MAX;
      else s_uiPCol += ulLen;
   }
}

/* Output an item to the screen and/or printer */
static void hb_devout( char * pStr, ULONG ulLen )
{
   if( hb_set_printhan != FS_ERROR && hb_stricmp( hb_set.HB_SET_DEVICE, "PRINTER" ) == 0 )
   {
      /* Display to printer if SET DEVICE TO PRINTER and valid printer file */
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( hb_set_printhan, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
      if( ulLen + s_uiPCol > USHRT_MAX ) s_uiPCol = USHRT_MAX;
      else s_uiPCol += ulLen;
   }
   else
   {
#ifdef HARBOUR_USE_GTAPI
      /* Otherwise, display to console */
      hb_gtWrite( ( BYTE * ) pStr, ulLen );
      hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
#else
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWriteLarge( s_iFilenoStdout, ( BYTE * ) pStr, ulLen );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
      adjust_pos( pStr, ulLen, &s_uiDevRow, &s_uiDevCol, hb_max_row(), hb_max_col() );
#endif
   }
}

/* Output an item to the screen */
static void hb_dispout( char * pStr, ULONG ulLen )
{
#ifdef HARBOUR_USE_GTAPI
   /* Display to console */
   hb_gtWrite( ( BYTE * ) pStr, ulLen );
   hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
#else
   USHORT user_ferror = hb_fsError(); /* Save current user file error code */
   hb_fsWriteLarge( s_iFilenoStdout, ( BYTE * ) pStr, ulLen );
   hb_fsSetError( user_ferror ); /* Restore last user file error code */
   adjust_pos( pStr, ulLen, &s_uiDevRow, &s_uiDevCol, hb_max_row(), hb_max_col() );
#endif
}

void hb_setpos( USHORT row, USHORT col )
{
#ifdef HARBOUR_USE_GTAPI
   hb_gtSetPos( row, col );
#else
   USHORT uiCount;

   if( row < s_uiDevRow || col < s_uiDevCol )
   {
      fputs( s_szCrLf, stdout );
      s_uiDevCol = 0;
      s_uiDevRow++;
   }
   else if( row > s_uiDevRow ) s_uiDevCol = 0;
   for( uiCount = s_uiDevRow; uiCount < row; uiCount++ )
      fputs( s_szCrLf, stdout );
   for( uiCount = s_uiDevCol; uiCount < col; uiCount++ )
      fputc( ' ', stdout );
   fflush( stdout );
#endif

   s_uiDevRow = row;
   s_uiDevCol = col;
}

void hb_devpos( USHORT row, USHORT col )
{
   USHORT uiCount;
   /* Position printer if SET DEVICE TO PRINTER and valid printer file
      otherwise position console */
   if( hb_set_printhan != FS_ERROR && hb_stricmp( hb_set.HB_SET_DEVICE, "PRINTER" ) == 0 )
   {
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      if( row < s_uiPRow )
      {
         hb_fsWrite( hb_set_printhan, ( BYTE * ) "\x0C", 1 );
         s_uiPRow = s_uiPCol = 0;
      }

      for( uiCount = s_uiPRow; uiCount < row; uiCount++ )
         hb_fsWrite( hb_set_printhan, ( BYTE * ) s_szCrLf, CRLF_BUFFER_LEN-1 );

      if( row > s_uiPRow ) s_uiPCol = 0;
      col += hb_set.HB_SET_MARGIN;

      for( uiCount = s_uiPCol; uiCount < col; uiCount++ )
         hb_fsWrite( hb_set_printhan, ( BYTE * ) " ", 1 );

      s_uiPRow = row;
      s_uiPCol = col;
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
   }
   else
      hb_setpos( row, col );
}

HARBOUR HB_OUTSTD( void ) /* writes a list of values to the standard output device */
{
   USHORT uiParam, uiPCount = hb_pcount();

   for( uiParam = 1; uiParam <= uiPCount; uiParam++ )
   {
      hb_out( uiParam, hb_outstd );
      if( uiParam < uiPCount )
         hb_outstd( " ", 1 );
   }
}

HARBOUR HB_OUTERR( void ) /* writes a list of values to the standard error device */
{
   USHORT uiParam, uiPCount = hb_pcount();

   for( uiParam = 1; uiParam <= uiPCount; uiParam++ )
   {
      hb_out( uiParam, hb_outerr );
      if( uiParam < uiPCount )
         hb_outerr( " ", 1 );
   }
}

HARBOUR HB_QQOUT( void ) /* writes a list of values to the current device (screen or printer) and is affected by SET ALTERNATE */
{
   USHORT uiParam, uiPCount = hb_pcount();

   for( uiParam = 1; uiParam <= uiPCount; uiParam++ )
   {
      hb_out( uiParam, hb_altout );
      if( uiParam < uiPCount )
         hb_altout( " ", 1 );
   }
}

HARBOUR HB_QOUT( void )
{
   USHORT uiCount;

   hb_altout( s_szCrLf, CRLF_BUFFER_LEN - 1 );

   if( hb_set.HB_SET_PRINTER && hb_set_printhan != FS_ERROR )
   {
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      s_uiPRow++;
      s_uiPCol = hb_set.HB_SET_MARGIN;
      uiCount = s_uiPCol;
      while( uiCount-- > 0 )
         hb_fsWrite( hb_set_printhan, ( BYTE * ) " ", 1 );
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
   }

   HB_QQOUT();
}

HARBOUR HB_SETPOS( void ) /* Sets the screen position */
{
   if( hb_pcount() == 2 )
   {
      if( ISNUM( 1 ) && ISNUM( 2 ) )
      {
         int i_row = hb_parni( 1 );
         int i_col = hb_parni( 2 );
         USHORT row, col;

         /* Limit the new position to the range (0,0) to (MAXROW(),MAXCOL()) */
         if( i_row < 0 ) row = 0;
         else if( i_row > hb_max_row() ) row = hb_max_row();
         else row = i_row;

         if( i_col < 0 ) col = 0;
         else if( i_col > hb_max_col() ) col = hb_max_col();
         else col = i_col;

         /* Set the new screen position */
         hb_setpos( row, col );
      }
   }
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "SETPOS" ); /* NOTE: Clipper catches this at compile time! */
}

/* Move the screen position to the right by one column */
HARBOUR HB_SETPOSBS( void )
{
   if( hb_pcount() == 0 )
   {
#ifdef HARBOUR_USE_GTAPI
      USHORT uiRow;
      USHORT uiCol;

      /* NOTE: Clipper does no checks about reaching the border or anything */
      hb_gtGetPos( &uiRow, &uiCol );
      hb_gtSetPos( uiRow, uiCol + 1 );
#endif
   }
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "SETPOSBS" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_DEVPOS( void ) /* Sets the screen and/or printer position */
{
   if( hb_pcount() == 2 )
   {
      if( ISNUM( 1 ) && ISNUM( 2 ) )
      {
         long l_row = hb_parnl( 1 );
         long l_col = hb_parnl( 2 );
         USHORT row, col;

         /* Limit the new position to the range (0,0) to (65535,65535) */
         if( l_row < 0 ) row = 0;
         else if( l_row > USHRT_MAX ) row = USHRT_MAX;
         else row = l_row;

         if( l_col < 0 ) col = 0;
         else if( l_col > USHRT_MAX ) col = USHRT_MAX;
         else col = l_col;

         /* Set the new screen position */
         hb_devpos( row, col );
      }
   }
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "DEVPOS" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_DEVOUT( void ) /* writes a single value to the current device (screen or printer), but is not affected by SET ALTERNATE */
{
   if( hb_pcount() >= 1 )
   {
#ifdef HARBOUR_USE_GTAPI
      if( ISCHAR( 2 ) )
      {
         char szOldColor[ CLR_STRLEN ];

         hb_gtGetColorStr( szOldColor );
         hb_gtSetColorStr( hb_parc( 2 ) );

         hb_out( 1, hb_devout );

         hb_gtSetColorStr( szOldColor );
      }
      else
         hb_out( 1, hb_devout );
#else
      hb_out( 1, hb_devout );
#endif
   }
}

HARBOUR HB_DISPOUT( void ) /* writes a single value to the current device (screen or printer), but is not affected by SET ALTERNATE */
{
   if( hb_pcount() >= 1 )
   {
#ifdef HARBOUR_USE_GTAPI
      if( ISCHAR( 2 ) )
      {
         char szOldColor[ CLR_STRLEN ];

         hb_gtGetColorStr( szOldColor );
         hb_gtSetColorStr( hb_parc( 2 ) );

         hb_out( 1, hb_dispout );

         hb_gtSetColorStr( szOldColor );
      }
      else
         hb_out( 1, hb_dispout );
#else
      hb_out( 1, hb_devout );
#endif
   }
}

HARBOUR HB___EJECT( void ) /* Ejects the current page from the printer */
{
   if( hb_stricmp( hb_set.HB_SET_DEVICE, "PRINTER" ) == 0 && hb_set_printhan != FS_ERROR )
   {
      USHORT user_ferror = hb_fsError(); /* Save current user file error code */
      hb_fsWrite( hb_set_printhan, ( BYTE * ) "\x0C\x0D", 2 );
      s_uiPRow = s_uiPCol = 0;
      hb_fsSetError( user_ferror ); /* Restore last user file error code */
   }
}

HARBOUR HB_PROW( void ) /* Returns the current printer row position */
{
   if( hb_pcount() == 0 )
      hb_retni( s_uiPRow );
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "PROW" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_PCOL( void ) /* Returns the current printer row position */
{
   if( hb_pcount() == 0 )
      hb_retni( s_uiPCol );
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "PCOL" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_SETPRC( void ) /* Sets the current printer row and column positions */
{
   if( ISNUM( 1 ) && ISNUM( 2 ) )
   {
      long l_row = hb_parnl( 1 );
      long l_col = hb_parnl( 2 );

      /* Limit the new position to the range (0,0) to (65535,65535) */

      if( l_row < 0 ) s_uiPRow = 0;
      else if( l_row > USHRT_MAX ) s_uiPRow = USHRT_MAX;
      else s_uiPRow = l_row;

      if( l_col < 0 ) s_uiPCol = 0;
      else if( l_col > USHRT_MAX ) s_uiPCol = USHRT_MAX;
      else s_uiPCol = l_col;
   }
}

HARBOUR HB_SCROLL( void ) /* Scrolls a screen region (requires the GT API) */
{
   USHORT top, left, bottom, right;

   int iMR      = hb_max_row();
   int iMC      = hb_max_col();

   int i_top    = ISNUM( 1 ) ? hb_parni( 1 ) : 0;
   int i_left   = ISNUM( 2 ) ? hb_parni( 2 ) : 0;
   int i_bottom = ISNUM( 3 ) ? hb_parni( 3 ) : iMR;
   int i_right  = ISNUM( 4 ) ? hb_parni( 4 ) : iMC;
   int v_scroll = ISNUM( 5 ) ? hb_parni( 5 ) : 0;
   int h_scroll = ISNUM( 6 ) ? hb_parni( 6 ) : 0;

   /* Enforce limits of (0,0) to (MAXROW(),MAXCOL()) */
   if( i_top < 0 ) top = 0;
   else if( i_top > iMR ) top = iMR;
   else top = i_top;
   if( i_left < 0 ) left = 0;
   else if( i_left > iMC ) left = iMC;
   else left = i_left;
   if( i_bottom < 0 ) bottom = 0;
   else if( i_bottom > iMR ) bottom = iMR;
   else bottom = i_bottom;
   if( i_right < 0 ) right = 0;
   else if( i_right > iMC ) right = iMC;
   else right = i_right;

#ifdef HARBOUR_USE_GTAPI
   hb_gtScroll( top, left, bottom, right, v_scroll, h_scroll );
#else
   if( top == 0 && bottom == iMR
   && left == 0 && right == iMC
   && v_scroll == 0 && h_scroll == 0 )
   {
      USHORT uiCount;
      s_uiDevRow = iMR;
      for( uiCount = 0; uiCount < s_uiDevRow ; uiCount++ )
         fputs( s_szCrLf, stdout );
      fflush( stdout );
      s_uiDevRow = s_uiDevCol = 0;
   }
#endif
}

HARBOUR HB_MAXROW( void ) /* Return the maximum screen row number (zero origin) */
{
   hb_retni( hb_max_row() );
}

HARBOUR HB_MAXCOL( void ) /* Return the maximum screen column number (zero origin) */
{
   hb_retni( hb_max_col() );
}

HARBOUR HB_ROW( void ) /* Return the current screen row position (zero origin) */
{
   if( hb_pcount() == 0 )
   {
#ifdef HARBOUR_USE_GTAPI
      hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
#endif
      hb_retni( s_uiDevRow );
   }
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "ROW" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_COL( void ) /* Return the current screen column position (zero origin) */
{
   if( hb_pcount() == 0 )
   {
#ifdef HARBOUR_USE_GTAPI
      hb_gtGetPos( &s_uiDevRow, &s_uiDevCol );
#endif
      hb_retni( s_uiDevCol );
   }
   else
      hb_errRT_BASE( EG_ARGCOUNT, 3000, NULL, "COL" ); /* NOTE: Clipper catches this at compile time! */
}

HARBOUR HB_DISPBOX( void )
{
#ifdef HARBOUR_USE_GTAPI
   if( ISNUM( 1 ) && ISNUM( 2 ) && ISNUM( 3 ) && ISNUM( 4 ) )
   {
      char szOldColor[ CLR_STRLEN ];

      if( ISCHAR( 6 ) )
      {
         hb_gtGetColorStr( szOldColor );
         hb_gtSetColorStr( hb_parc( 6 ) );
      }

      if( ISCHAR( 5 ) )
         hb_gtBox( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), ( BYTE * ) hb_parc( 5 ));
      else if( ISNUM( 5 ) && hb_parni( 5 ) == 2 )
         hb_gtBoxD( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) );
      else
         hb_gtBoxS( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) );

      if( ISCHAR( 6 ) )
         hb_gtSetColorStr( szOldColor );
   }
#else
   if( ISNUM( 1 ) && ISNUM( 2 ) && ISNUM( 3 ) && ISNUM( 4 ) )
   {
      char * szBorderStyle = B_SINGLE;
      int i_top = hb_parni( 1 );
      int i_left = hb_parni( 2 );
      int i_bottom = hb_parni( 3 );
      int i_right = hb_parni( 4 );
      USHORT top, left, bottom, right, size = strlen( B_SINGLE );
      USHORT row, col, width, height;
      char Borders[ 9 ];

      /* Set limits on the box coordinates to (0,0) and (max_row(),max_col()) */
      if( i_top < 0 ) top = 0; else top = ( USHORT ) i_top;
      if( i_left < 0 ) left = 0; else left = ( USHORT ) i_left;
      if( i_bottom < 0 ) bottom  = 0; else bottom = ( USHORT ) i_bottom;
      if( i_right < 0 ) right = 0; else right = ( USHORT ) i_right;
      if( top > hb_max_row() ) top = hb_max_row();
      if( left > hb_max_col() ) left = hb_max_col();
      if( bottom > hb_max_row() ) bottom  = hb_max_row();
      if( right > hb_max_col() ) right = hb_max_col();

      /* Force the box to be drawn from top left to bottom right */
      if( top > bottom )
      {
         int temp;
         temp = top;
         top = bottom;
         bottom = temp;
      }
      if( left > right )
      {
         int temp;
         temp = right;
         right = left;
         left = temp;
      }
      width = right - left + 1;
      height = bottom - top + 1;

      /* Determine the box style */
      if( ISCHAR( 5 ) )
      {
         szBorderStyle = hb_parc( 5 );
         size = hb_parclen( 5 );
      }
      else if( ISNUM( 5 ) )
      {
         switch( hb_parni( 5 ) )
         {
            case 2:
               szBorderStyle = B_DOUBLE;
               break;
            case 3:
               szBorderStyle = B_SINGLE_DOUBLE;
               break;
            case 4:
               szBorderStyle = B_DOUBLE_SINGLE;
               break;
            default:
               szBorderStyle = B_SINGLE;
         }
          size = strlen( szBorderStyle );
      }
      /* We only need 9 characters from the source string */
      if( size > 9 ) size = 9;
      /* If we have at least one character... */
      if( size )
         /* ...copy the source string */
         memcpy( Borders, szBorderStyle, size );
      else
         /* If not, set the first character to a space */
         Borders[ size++ ] = ' ';
      /* If there were less than 8 characters in the source... */
      for( ; size < 8; size++ )
      {
         /* ...copy the last character into the remaining 8 border positions */
         Borders[ size ] = Borders[ size - 1 ];
      }
      /* If there were less than 9 characters in the source... */
      if( size < 9 )
         /* ...set the fill character to space */
         Borders[ 8 ] = ' ';

      /* Draw the box */
      hb_setpos( top, left );
      if( height > 1 && width > 1 )
         fputc( Borders[ 0 ], stdout );   /* Upper left corner */
      for( col = ( height > 1 ? left + 1 : left ); col < ( height > 1 ? right : right + 1 ); col++ )
         fputc( Borders[ 1 ], stdout );   /* Top line */
      if( height > 1 && width > 1 )
         fputc( Borders[ 2 ], stdout );   /* Upper right corner */
      for( row = ( height > 1 ? top + 1 : top ); row < ( width > 1 ? bottom : bottom + 1 ); row++ )
      {
         hb_setpos( row, left );
         if( height > 1 )
            fputc( Borders[ 3 ], stdout ); /* Left side */
         if( height > 1 && width > 1 ) for( col = left + 1; col < right; col++ )
            fputc( Borders[ 8 ], stdout ); /* Fill */
         if( height > 1 && width > 1 )
            fputc( Borders[ 7 ], stdout ); /* Right side */
      }
      if( height > 1 && width > 1 )
      {
         hb_setpos( bottom, left );
         col = left;
         fputc( Borders[ 6 ], stdout );    /* Bottom left corner */
         for( col = left + 1; col < right; col++ )
            fputc( Borders[ 5 ], stdout ); /* Bottom line */
         fputc( Borders[ 4 ], stdout );    /* Bottom right corner */
      }
      fflush( stdout );
      hb_setpos( bottom + 1, right + 1 );
   }
#endif
}

HARBOUR HB_DISPBEGIN( void )
{
#ifdef HARBOUR_USE_GTAPI
   hb_gtDispBegin();
#endif
}

HARBOUR HB_DISPEND( void )
{
#ifdef HARBOUR_USE_GTAPI
   hb_gtDispEnd();
#endif
}

HARBOUR HB_DISPCOUNT( void )
{
#ifdef HARBOUR_USE_GTAPI
   hb_retni( hb_gtDispCount() );
#else
   hb_retni( 0 );
#endif
}

HARBOUR HB_ISCOLOR( void )
{
#ifdef HARBOUR_USE_GTAPI
   hb_retl( hb_gtIsColor() );
#else
   hb_retl( FALSE );
#endif
}

HARBOUR HB_NOSNOW( void )
{
#ifdef HARBOUR_USE_GTAPI
   if( ISLOG( 1 ) )
      hb_gtSetSnowFlag( hb_parl( 1 ) );
#endif
}

HARBOUR HB___SHADOW( void )
{
#ifdef HARBOUR_USE_GTAPI
   if( hb_pcount() >= 4 )
   {
      hb_gt_DrawShadow( hb_parni( 1 ) + 1,
                        hb_parni( 2 ) + 1,
                        hb_parni( 3 ) + 1,
                        hb_parni( 4 ) + 1,
                        ISNUM( 5 ) ? hb_parni( 5 ) : 7 );
   }
#endif
}

HARBOUR HB_DBGSHADOW( void )
{
   HB___SHADOW();
}

HARBOUR HB_SAVESCREEN( void )
{
#ifdef HARBOUR_USE_GTAPI
   USHORT uiX;
   USHORT uiCoords[ 4 ];
   void * pBuffer;

   uiCoords[ 0 ] = 0;
   uiCoords[ 1 ] = 0;
   uiCoords[ 2 ] = hb_gtMaxRow();
   uiCoords[ 3 ] = hb_gtMaxCol();

   for( uiX = 1; uiX <= 4; uiX++ )
      if( ISNUM( uiX ) )
         uiCoords[ uiX - 1 ] = hb_parni( uiX );

   hb_gtRectSize( uiCoords[ 0 ], uiCoords[ 1 ], uiCoords[ 2 ], uiCoords[ 3 ], &uiX );
   pBuffer = hb_xgrab( uiX );
   hb_gtSave( uiCoords[ 0 ], uiCoords[ 1 ], uiCoords[ 2 ], uiCoords[ 3 ], pBuffer );
   hb_retclen( ( char * ) pBuffer, uiX );
   hb_xfree( ( char * ) pBuffer );
#else
   hb_retc( "" );
#endif
}

HARBOUR HB_RESTSCREEN( void )
{
#ifdef HARBOUR_USE_GTAPI
   if( hb_pcount() == 5 )
   {
      USHORT uiX;
      USHORT uiCoords[ 4 ];

      uiCoords[ 0 ] = 0;
      uiCoords[ 1 ] = 0;
      uiCoords[ 2 ] = hb_gtMaxRow();
      uiCoords[ 3 ] = hb_gtMaxCol();

      for( uiX = 1; uiX < 5; uiX++ )
         if( ISNUM( uiX ) )
            uiCoords[ uiX - 1 ] = hb_parni( uiX );

      hb_gtRest( uiCoords[ 0 ], uiCoords[ 1 ], uiCoords[ 2 ], uiCoords[ 3 ],
                 ( void * ) hb_parc( 5 ) );
   }
#endif
}

USHORT hb_setCursor( BOOL bSetCursor, USHORT usNewCursor )
{
   USHORT usPreviousCursor;
#ifdef HARBOUR_USE_GTAPI
   hb_gtGetCursor( &usPreviousCursor );
   if( bSetCursor )
      hb_gtSetCursor( usNewCursor );

#else
   usPreviousCursor = hb_set.HB_SET_CURSOR;
   if( bSetCursor )
      hb_set.HB_SET_CURSOR = ( hb_cursor_enum ) usNewCursor;
#endif
   return usPreviousCursor;
}

HARBOUR HB_SETCURSOR( void )
{
   if( hb_pcount() == 1 && ISNUM( 1 ) )
      hb_retni( hb_setCursor( TRUE, hb_parni( 1 ) ) );
   else
      hb_retni( hb_setCursor( FALSE, 0 ) );
}

HARBOUR HB_SETBLINK( void )
{
#ifdef HARBOUR_USE_GTAPI
   BOOL bPreviousBlink;

   hb_gtGetBlink( &bPreviousBlink );
   if( ISLOG( 1 ) )
      hb_gtSetBlink( hb_parl( 1 ) );

   hb_retl( bPreviousBlink );
#else
   hb_retl( FALSE );
#endif
}

HARBOUR HB_SETMODE( void )
{
#ifdef HARBOUR_USE_GTAPI
   hb_retl( hb_gtSetMode( ISNUM( 1 ) ? hb_parni( 1 ) : ( hb_gtMaxRow() + 1 ), 
                          ISNUM( 2 ) ? hb_parni( 2 ) : ( hb_gtMaxCol() + 1 ) ) == 0 );
#else
   hb_retl( FALSE );
#endif
}

HARBOUR HB___ACCEPT( void ) /* Internal Clipper function used in ACCEPT command  */
                            /* Basically the simplest Clipper function to        */
                            /* receive data. Parameter : cPrompt. Returns : cRet */
{
   int input;
   ULONG ulLen;

   if( hb_pcount() >= 1 )          /* cPrompt passed                         */
      HB_QOUT();

   ulLen = 0;
   input = 0;
   while( input != K_ENTER )
   {
      /* Wait forever, for keyboard events only */
      input = hb_inkey( 0.0, ( HB_inkey_enum ) INKEY_KEYBOARD, 1, 1 );
      switch( input )
      {
         case K_BS:
         case K_LEFT:
            if( ulLen > 0 )
            {
               ulLen--; /* Adjust input count to get rid of last character,
                         then erase it from the screen. */
#ifdef HARBOUR_USE_GTAPI
               hb_gtWriteCon( ( BYTE * ) "\x8 \x8", 3L );
#else
               fputs( "\x8 \x8", stdout );
               fflush( stdout );
#endif
            }
            break;

         default:
            if( ulLen < ( ACCEPT_BUFFER_LEN - 1 ) && input >= 32 )
            {
               s_szAcceptResult[ ulLen ] = input; /* Accept the input */
               hb_dispout( &s_szAcceptResult[ ulLen ], sizeof( char ) ); /* Then display it */
               ulLen++;  /* Then adjust the input count */
            }
      }
   }
   s_szAcceptResult[ ulLen ] = '\0';
   hb_retc( s_szAcceptResult );
}

HARBOUR HB___ACCEPTSTR( void )
{
   hb_retc( s_szAcceptResult );
}

/* ------------------------------------------------- */
/* Copyright (C) 1999 Victor Szel <info@szelvesz.hu> */
/* ------------------------------------------------- */

/*  $DOC$
 *  $FUNCNAME$
 *      __ColorIndex
 *  $CATEGORY$
 *      GT
 *  $ONELINER$
 *      Extract one color from a full Clipper colorspec string.
 *  $SYNTAX$
 *      __ColorIndex( <cColorSpec>, <nIndex> )
 *  $ARGUMENTS$
 *      <cColorSpec> is a Clipper color list
 *      <nIndex> is the position of the color item to be extracted, the first
 *               position is the zero.
 *  $RETURNS$
 *      The selected color string, or if anything goes wrong, and empty
 *      string
 *  $DESCRIPTION$
 *      Clipper has color spec string, which have more than one single
 *      colors in it, separated with commas. This function is able to extract
 *      a given item from this list. You may use the manifest constants
 *      defined in color.ch to extract common Clipper colors.
 *  $EXAMPLES$
 *      ? __ColorIndex( "W/N, N/W", CLR_ENHANCED ) // "N/W"
 *  $TESTS$
 *      see in rtl_test.prg for a comprehensive regression test suit.
 *  $STATUS$
 *      R
 *  $COMPLIANCE$
 *      Was not part of CA-Clipper.
 *  $SEEALSO$
 *      ColorSelect()
 *  $END$
 */

HARBOUR HB___COLORINDEX( void )
{
   if( ISCHAR( 1 ) && ISNUM( 2 ) )
   {
      char * szColor = hb_parc( 1 );
      ULONG ulColorPos;
      ULONG ulColorLen;
      USHORT uiColorIndex = ( USHORT ) hb_parni( 2 );

      /* Skip the given number of commas */

      for( ulColorPos = 0 ; szColor[ ulColorPos ] != '\0' && uiColorIndex > 0 ; ulColorPos++ )
      {
         if( szColor[ ulColorPos ] == ',' )
            uiColorIndex--;
      }

      /* if found, continue */

      if( uiColorIndex == 0 )
      {
         /* Skip the spaces after the comma */

         while( szColor[ ulColorPos ] == ' ' ) ulColorPos++;

         /* Search for next comma or end of string */

         ulColorLen = 0;

         while( szColor[ ulColorPos + ulColorLen ] != '\0' &&
                szColor[ ulColorPos + ulColorLen ] != ',' ) ulColorLen++;

         /* Skip the trailing spaces */

         while( ulColorLen > 0 &&
                szColor[ ulColorPos + ulColorLen - 1 ] == ' ' ) ulColorLen--;

         /* Return the string */

         hb_retclen( szColor + ulColorPos, ulColorLen );
      }
      else
         hb_retc( "" );
   }
   else
      hb_retc( "" );
}

