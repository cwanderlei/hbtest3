/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Source file for the Xbp*Classes
 *
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
 * http://www.harbour-project.org
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
 *                                EkOnkar
 *                          ( The LORD is ONE )
 *
 *                 Xbase++ xbpPushButton Compatible Class
 *
 *                  Pritpal Bedi <pritpal@vouchcac.com>
 *                               13Jun2009
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
#include "apig.ch"
#include "hbqt.ch"

/*----------------------------------------------------------------------*/

CLASS XbpPushButton  INHERIT  XbpWindow

   DATA     autosize                              INIT .F.
   DATA     border                                INIT .T.
   DATA     caption                               INIT ""
   DATA     pointerFocus                          INIT .T.
   DATA     preSelect                             INIT .F.
   DATA     drawMode                              INIT XBP_DRAW_NORMAL
   DATA     default                               INIT .F.
   DATA     cancel                                INIT .F.

   METHOD   new()
   METHOD   create()
   METHOD   configure()
   METHOD   destroy()

   METHOD   setCaption()

   METHOD   activate()                            SETGET
   METHOD   draw()                                SETGET

   METHOD   handleEvent( nEvent, aInfo )
   METHOD   exeBlock()

   //METHOD   setColorFG()                          INLINE NIL
   //METHOD   setColorBG()                          INLINE NIL

   ENDCLASS
/*----------------------------------------------------------------------*/

METHOD XbpPushButton:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::Initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::className   := "XBPPUSHBUTTON"
   ::objType     := objTypePushButton

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::xbpWindow:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::oWidget := QPushButton():new( QT_PTROF( ::oParent:oWidget ) )
   ::oWidget:move( aPos[ 1 ],aPos[ 2 ] )
   ::oWidget:resize( aSize[ 1 ],aSize[ 2 ] )

   ::Connect( QT_PTROF( ::oWidget ), "clicked()", {|| ::exeBlock() } )

   IF ::visible
      ::oWidget:show()
   ENDIF

   ::setCaption( ::caption )

   IF ::default
      ::oWidget:setDefault( .t. )
   ENDIF

   ::oParent:AddChild( SELF )
   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:exeBlock()

   IF hb_isBlock( ::sl_lbClick )
      eval( ::sl_lbClick, NIL, NIL, self )
   ENDIF

   RETURN nil

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:handleEvent( nEvent, mp1, mp2 )

   HB_SYMBOL_UNUSED( nEvent )
   HB_SYMBOL_UNUSED( mp1    )
   HB_SYMBOL_UNUSED( mp2    )

   RETURN EVENT_UNHANDELLED

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:destroy()

   ::xbpWindow:destroy()

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::Initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:setCaption( xCaption, cDll )

   HB_SYMBOL_UNUSED( cDll )

   IF hb_isChar( xCaption )
      ::caption := xCaption

      IF file( xCaption )
         ::oWidget:setIcon( xCaption )
      ELSE
         ::oWidget:setText( xCaption )
      ENDIF
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:activate( xParam )

   IF hb_isBlock( xParam ) .or. ( xParam == NIL )
      ::sl_lbClick := xParam
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD XbpPushButton:draw( xParam )

   IF hb_isBlock( xParam ) .or. ( xParam == NIL )
      ::sl_paint := xParam
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/
