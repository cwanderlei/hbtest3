/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Windows communications library
 *
 * Copyright 2005-2009 Alex Strickland <sscc@mweb.co.za>
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
 * anyone as to the status o such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"
#include "common.ch"

#include "hbwin.ch"

/* The class is a VERY thin layer over the xHarbour functions and the xHarbour functions
   are a VERY thin layer over the Win functions, almost no parameter checking! You get what you
   pay for :)

   I haven't bothered to remember things that you can remember for yourself - the state of DTR (low
   to begin with) or the baud rate for example, you can always sub-class it.

   I've only done the things that I've found useful over the years, for example I never used the
   "BREAK" state of a line so I haven't done it here.

   The class needs the port to be already open to change timeouts and buffer sizes, it doesn't have to
   be that way, but it is.

   Really Windows comms should be done with threads and/or OVERLAPPED I/O - and I haven't. */

CREATE CLASS win_Com

   ACCESS Open()     INLINE ::lOpen
   ACCESS PortName() INLINE ::cPortName

   PROTECT nPort     INIT -1
   PROTECT lOpen     INIT .F.
   PROTECT cPortName INIT ""

   METHOD Init( cPortName, nBaudRate, nParity, nByteSize, nStopBits )
   METHOD QueueSize( nInQueue, nOutQueue )  INLINE win_ComSetQueueSize( ::nPort, nInQueue, nOutQueue )
   METHOD TimeOuts( nReadInterval, nReadMultiplier, nReadConstant, nWriteMultiplier, nWriteConstant ) ;
                                            INLINE win_ComSetTimeOuts( ::nPort, nReadInterval, nReadMultiplier, nReadConstant, nWriteMultiplier, nWriteConstant )
   METHOD Read( /* @ */ cString, nLength )
   METHOD Recv( nLength, nResult )          INLINE win_ComRecv( ::nPort, nLength, @nResult )
   METHOD RecvTo( cDelim, nMaxlen )
   METHOD Write( cString )                  INLINE win_ComWrite( ::nPort, cString )
   METHOD Status( lCTS, lDSR, lRing, lDCD ) INLINE win_ComStatus( ::nPort, @lCTS, @lDSR, @lRing, @lDCD )
   METHOD QueueStatus( lCTSHold, lDSRHold, lDCDHold, lXoffHold, lXoffSent, nInQueue, nOutQueue ) ;
                                            INLINE win_ComQueueStatus( ::nPort, @lCTSHold, @lDSRHold, @lDCDHold, @lXoffHold, @lXoffSent, @nInQueue, @nOutQueue )
   METHOD SetRTS( lCTS )                    INLINE win_ComSetRTS( ::nPort, lCTS ) /* boolean return is the status of the call not the line! */
   METHOD SetDTR( lDTR )                    INLINE win_ComSetDTR( ::nPort, lDTR ) /* boolean return is the status of the call not the line! */
   METHOD RTSFlow( nRTS )                   INLINE win_ComRTSFlow( ::nPort, nRTS )
   METHOD DTRFlow( nDTR )                   INLINE win_ComDTRFlow( ::nPort, nDTR )
   METHOD XonXoffFlow( lXonXoff )           INLINE win_ComXonXoffFlow( ::nPort, lXonXoff )
   METHOD Purge( lRXBuffer, lTXBuffer )     INLINE win_ComPurge( ::nPort, lRXBuffer, lTXBuffer )
   METHOD PurgeRX()                         INLINE win_ComPurge( ::nPort, .T., .F. )
   METHOD PurgeTX()                         INLINE win_ComPurge( ::nPort, .F., .T. )
   METHOD Close( nDrain )                   INLINE win_ComClose( ::nPort, iif( Empty( nDrain ), 0, nDrain ) )
   METHOD DebugDCB( nDebug )                INLINE win_ComDebugDCB( ::nPort, nDebug )
   METHOD ErrorText()

ENDCLASS


METHOD Init( cPortName, nBaudRate, nParity, nByteSize, nStopBits ) CLASS win_Com

   ::cPortName := Upper( cPortName )
   IF Left( ::cPortName, 3 ) == "COM"
      ::nPort := Val( SubStr( ::cPortName, 4 ) ) - 1
      IF win_ComOpen( ::nPort, nBaudRate, nParity, nByteSize, nStopBits ) != -1
         ::lOpen := .T.
      ENDIF
   ENDIF

   RETURN self

METHOD Read( /* @ */ cString, nLength ) CLASS win_Com

   cString := Space( nlength )

   RETURN win_ComRead( ::nPort, @cString )

METHOD RecvTo( cDelim, nMaxlen ) CLASS win_Com
   LOCAL nResult
   LOCAL cRecv := ""

   LOCAL cString

   DO WHILE .T.
      cString := Space( 1 )
      IF ( nResult := win_ComRead( ::nPort, @cString ) ) != -1
         IF nResult == 0
            EXIT
         ELSE
            cRecv += cString
            IF cDelim != NIL .AND. cString == cDelim
               EXIT
            ENDIF
            IF Len( cRecv ) == nMaxlen
               EXIT
            ENDIF
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO

   RETURN cRecv

/* Since the win_Com functions are an amalgamation of Win functions this allows
   you to see what call did the deed when things go wrong. */

METHOD ErrorText() CLASS win_Com
   LOCAL nFcn := win_ComFuncLast( ::nPort )
   LOCAL cString
   LOCAL nError
   LOCAL cMsg
   LOCAL aWinPortFcns := { ;
      "CreateFile", ;
      "GetCommState", ;
      "SetCommState", ;
      "SetupComm", ;
      "GetCommTimeouts", ;
      "SetCommTimeouts", ;
      "CloseHandle", ;
      "WriteFile", ;
      "ReadFile", ;
      "GetCommModemStatus", ;
      "PurgeComm", ;
      "ClearCommError", ;
      "EscapeCommFunction", ;
      "GetCommProperties" }

   IF nFcn >= 1 .AND. nFcn <= Len( aWinPortFcns )
      cString := aWinPortFcns[ nFcn ] + "(), "
   ELSE
      cString := "Function number (" + hb_ntos( nFcn ) + ") invalid, "
   ENDIF

   /* WinPortError clears the error - don't call it twice */
   cMsg := Space( 256 )
   wapi_FormatMessage( NIL, NIL, nError := win_ComError( ::nPort ), NIL, @cMsg )

   RETURN cString + "error (" + hb_ntos( nError ) + ") : " + cMsg
