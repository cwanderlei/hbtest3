/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Source file for the Xbp*Classes
 *
 * Copyright 2009-2010 Pritpal Bedi <bedipritpal@hotmail.com>
 * http://harbour-project.org
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
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*
 *                               EkOnkar
 *                         ( The LORD is ONE )
 *
 *                  Xbase++ Compatible xbpDialog Class
 *
 *                            Pritpal Bedi
 *                              29May2009
 */
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/

#include "hbclass.ch"
#include "common.ch"
#include "inkey.ch"
#include "hbgtinfo.ch"

#include "xbp.ch"
#include "appevent.ch"

/*----------------------------------------------------------------------*/

CLASS XbpDialog FROM XbpWindow

   DATA     oMenu
   DATA     aRect

   DATA     maxbutton                             INIT  .T.
   DATA     minbutton                             INIT  .T.
   DATA     drawingArea
   DATA     tasklist                              INIT  .T.
   DATA     oEventLoop

   DATA     alwaysOnTop                           INIT  .F.
   DATA     border                                INIT  XBPDLG_RAISEDBORDERTHICK
   DATA     titleBar                              INIT  .F.
   DATA     moveWithOwner                         INIT  .T.
   DATA     origin                                INIT  XBPDLG_ORIGIN_OWNER
   DATA     sysMenu                               INIT  .T.

   METHOD   init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   execEvent( nEvent, pEvent )

   METHOD   destroy()

   METHOD   showModal()
   METHOD   setTitle( cTitle )                    INLINE ::title := cTitle, ::oWidget:setWindowTitle( cTitle )
   METHOD   getTitle()                            INLINE ::oWidget:windowTitle()

   METHOD   menuBar()
   METHOD   setFrameState( nState )
   METHOD   getFrameState()
   METHOD   calcClientRect()                      INLINE { 0, 0, ::oWidget:width(), ::oWidget:height() }
   METHOD   calcFrameRect()                       INLINE { ::oWidget:x(), ::oWidget:y(), ;
                                                           ::oWidget:x()+::oWidget:width(), ::oWidget:y()+::oWidget:height() }
   DATA     aMaxSize
   METHOD   maxSize( aSize )                      SETGET
   DATA     aMinSize
   METHOD   minSize( aSize )                      SETGET

   DATA     oMdi
   DATA     nFlags

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD XbpDialog:init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   DEFAULT oParent TO AppDeskTop()

   ::xbpWindow:init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::resizeMode  := 0
   ::mouseMode   := 0

   ::drawingArea := XbpDrawingArea():new( self, , {0,0}, ::aSize, , .t. )

   RETURN Self

/*----------------------------------------------------------------------*/
#if 0
Qt::FramelessWindowHint

Qt_CustomizeWindowHint
Qt_WindowTitleHint
Qt_WindowSystemMenuHint
Qt_WindowMinimizeButtonHint
Qt_WindowMaximizeButtonHint
Qt_WindowMinMaxButtonsHint
Qt_WindowCloseButtonHint
Qt_WindowContextHelpButtonHint
Qt_WindowShadeButtonHint
Qt_WindowStaysOnTopHint
Qt_WindowStaysOnBottomHint
Qt_WindowOkButtonHint
Qt_WindowCancelButtonHint
#endif

METHOD XbpDialog:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   LOCAL nFlags, nnFlags

   ::xbpWindow:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   /* Thread specific event buffer */
   hbxbp_InitializeEventBuffer()

   IF !empty( ::qtObject )
      IF hb_isObject( ::qtObject )
         ::isViaQtObject := .t.
         ::oWidget       := ::qtObject:oWidget
         ::qtObject      := NIL
      ENDIF
      ::oWidget:setMouseTracking( .t. )
   ELSE
      IF ::taskList
         ::oWidget := QMainWindow()
      ELSE
         ::oWidget := QMainWindow( SetAppWindow() )
      ENDIF
      ::oWidget:setMouseTracking( .t. )
      ::oWidget:setObjectName( "mainWindow" )
   ENDIF

   IF !empty( ::qtObject )
      ::drawingArea:qtObject := ::oWidget:centralWidget()
      ::drawingArea:create()
   ELSE
      ::drawingArea:create()
      ::oWidget:setCentralWidget( ::drawingArea:oWidget )
   ENDIF

   nnFlags := ::oWidget:windowFlags()
   nFlags  := Qt_Window

   IF ::border == XBPDLG_NO_BORDER
      nFlags := hb_bitOr( nFlags, Qt_FramelessWindowHint )

   ELSE
      nFlags := hb_bitOr( nFlags, Qt_CustomizeWindowHint )
      nFlags := hb_bitOr( nFlags, Qt_WindowCloseButtonHint )

      IF ::titleBar
         nFlags := hb_bitOr( nFlags, Qt_WindowTitleHint )
      ENDIF
      IF ::sysMenu
         nFlags := hb_bitOr( nFlags, Qt_WindowSystemMenuHint )
      ENDIF
      IF ::maxButton
         nFlags := hb_bitOr( nFlags, Qt_WindowMaximizeButtonHint )
      ENDIF
      IF ::minButton
         nFlags := hb_bitOr( nFlags, Qt_WindowMinimizeButtonHint )
      ENDIF
   ENDIF

   IF ::alwaysOnTop
      nFlags += hb_bitOr( nFlags, Qt_WindowStaysOnTopHint )
   ENDIF
   IF nnFlags != nFlags
      ::oWidget:setWindowFlags( nFlags )
   ENDIF

   IF ! empty( ::title )
      ::oWidget:setWindowTitle( ::title )
   ENDIF
   IF hb_isChar( ::icon )
      ::oWidget:setWindowIcon( ::icon )
   ENDIF

   ::setPosAndSize()

   IF ::border == XBPDLG_RAISEDBORDERTHICK_FIXED   .OR. ;
      ::border == XBPDLG_RAISEDBORDERTHIN_FIXED    .OR. ;
      ::border == XBPDLG_RECESSEDBORDERTHICK_FIXED .OR. ;
      ::border == XBPDLG_RECESSEDBORDERTHIN_FIXED

      ::oWidget:setMinimumWidth( ::oWidget:width() )
      ::oWidget:setMaximumWidth( ::oWidget:width() )
      ::oWidget:setMinimumHeight( ::oWidget:height() )
      ::oWidget:setMaximumHeight( ::oWidget:height() )
   ENDIF


   ::nFlags := nFlags
   IF __objGetClsName( ::oParent ) == "XBPDRAWINGAREA"
      ::setParent( ::oParent )
   ENDIF

   //::setQtProperty()
   IF ::visible
      ::show()
   ENDIF

   /* Install Event Loop per thread/dialog Basis */
   IF empty( hbxbp_SetEventLoop() )
      ::oEventLoop := QEventLoop( ::oWidget )
      hbxbp_SetEventLoop( ::oEventLoop )
   ENDIF

   /* Instal Event Filter */
   ::connectWindowEvents()
   //
   ::oWidget:connect( QEvent_Close            , {|e| ::execEvent( QEvent_Close            , e ) } )
   ::oWidget:connect( QEvent_WindowActivate   , {|e| ::execEvent( QEvent_WindowActivate   , e ) } )
   ::oWidget:connect( QEvent_WindowDeactivate , {|e| ::execEvent( QEvent_WindowDeactivate , e ) } )

   ::postCreate()

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpDialog:destroy()

   IF ! empty( ::oMdi )
      ::oMdi := NIL
   ENDIF

   ::disconnectWindowEvents()
   ::oWidget:disconnect( QEvent_Close            )
   ::oWidget:disconnect( QEvent_WindowActivate   )
   ::oWidget:disconnect( QEvent_WindowDeactivate )

   IF !empty( ::oEventLoop )
      hbxbp_SetEventLoop( NIL )
      ::oEventLoop:exit( 0 )
      ::oEventLoop := NIL
   ENDIF
   ::oMenu := NIL

   ::XbpWindow:destroy()

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpDialog:execEvent( nEvent, pEvent )

   HB_SYMBOL_UNUSED( pEvent )
   DO CASE

   CASE nEvent == QEvent_WindowActivate
      SetAppEvent( xbeP_SetDisplayFocus, NIL, NIL, Self )

   CASE nEvent == QEvent_WindowDeactivate
      SetAppEvent( xbeP_KillDisplayFocus, NIL, NIL, Self )

   CASE nEvent == QEvent_Close
      pEvent:ignore()
      ::close()
      SetAppEvent( xbeP_Close, NIL, NIL, Self )
   ENDCASE

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD XbpDialog:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::xbpWindow:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpDialog:maxSize( aSize )

   IF hb_isArray( aSize ) .AND. len( aSize ) == 2 .AND. hb_isNumeric( aSize[ 1 ] ) .AND. hb_isNumeric( aSize[ 2 ] )
      ::aMaxSize := aSize
      ::oWidget:setMaximumWidth( aSize[ 1 ] )
      ::oWidget:setMaximumHeight( aSize[ 2 ] )
   ENDIF

   RETURN ::aMaxSize

/*----------------------------------------------------------------------*/

METHOD XbpDialog:minSize( aSize )

   IF hb_isArray( aSize ) .AND. len( aSize ) == 2 .AND. hb_isNumeric( aSize[ 1 ] ) .AND. hb_isNumeric( aSize[ 2 ] )
      ::aMinSize := aSize
      ::oWidget:setMinimumWidth( aSize[ 1 ] )
      ::oWidget:setMinimumHeight( aSize[ 2 ] )
   ENDIF

   RETURN ::aMinSize

/*----------------------------------------------------------------------*/

METHOD XbpDialog:showModal()

   ::hide()
   ::oWidget:setWindowModality( 2 )
   ::show()
   ::is_hidden      := .f.
   ::lHasInputFocus := .t.

   RETURN .t.

/*----------------------------------------------------------------------*/

METHOD XbpDialog:setFrameState( nState )
   LOCAL lSuccess := .T.
   LOCAL nCurState := ::getFrameState()

   DO CASE
   CASE nState == XBPDLG_FRAMESTAT_MINIMIZED
      IF nCurState != XBPDLG_FRAMESTAT_MINIMIZED
         ::oWidget:setWindowState( Qt_WindowMinimized )
      ENDIF
   CASE nState == XBPDLG_FRAMESTAT_MAXIMIZED
      IF nCurState == XBPDLG_FRAMESTAT_MINIMIZED
         ::oWidget:show()
         ::oWidget:setWindowState( Qt_WindowMaximized )
      ELSEIF nCurState == XBPDLG_FRAMESTAT_NORMALIZED
         ::oWidget:setWindowState( Qt_WindowMaximized )
      ENDIF
   CASE nState == XBPDLG_FRAMESTAT_NORMALIZED
      IF nCurState != XBPDLG_FRAMESTAT_MINIMIZED
         ::oWidget:show()
      ENDIF
      ::oWidget:setWindowState( Qt_WindowNoState )
   ENDCASE

   RETURN lSuccess

/*----------------------------------------------------------------------*/

METHOD XbpDialog:getFrameState()
   LOCAL nState := ::oWidget:windowState()

   IF ( hb_bitAnd( nState, Qt_WindowMinimized ) == Qt_WindowMinimized )
      RETURN XBPDLG_FRAMESTAT_MINIMIZED
   ELSEIF ( hb_bitAnd( nState, Qt_WindowMaximized ) == Qt_WindowMaximized )
      RETURN XBPDLG_FRAMESTAT_MAXIMIZED
   ENDIF

   RETURN XBPDLG_FRAMESTAT_NORMALIZED

/*----------------------------------------------------------------------*/

METHOD XbpDialog:menuBar()

   IF !( hb_isObject( ::oMenu ) )
      XbpMenuBar():New( self ):create()
   ENDIF

   RETURN ::oMenu

/*----------------------------------------------------------------------*/
/*
 *                            XbpDrawingArea
 */
/*----------------------------------------------------------------------*/

CLASS XbpDrawingArea  INHERIT  XbpWindow

   DATA     caption                               INIT ""
   DATA     clipParent                            INIT .T.
   DATA     clipSiblings                          INIT .T.
   DATA     clipChildren                          INIT .F.

   METHOD   init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD   create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   DATA     oBrush

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD XbpDrawingArea:init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::xbpWindow:init( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   ::visible := .t.

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpDrawingArea:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   HB_SYMBOL_UNUSED( lVisible )

   ::xbpWindow:create( oParent, oOwner, aPos, aSize, aPresParams, .T. )

   IF ! empty( ::qtObject )
      ::oWidget := ::qtObject:oWidget
   ELSE
      #if 0
      ::oWidget := QWidget()
      #else
      ::oWidget := QMdiArea()
      ::oBrush  := QApplication():palette():button()
      ::oWidget:setBackground( ::oBrush )
      #endif
   ENDIF

   ::oWidget:setMouseTracking( .T. )
   ::oWidget:setFocusPolicy( Qt_NoFocus )
   ::oWidget:setObjectName( hbxbp_getNextID( "XBaseDrawingArea" ) )

   ::setQtProperty()  /* Using it for one-to-one style sheet management */

   ::oParent:addChild( SELF )

   RETURN Self

/*----------------------------------------------------------------------*/
