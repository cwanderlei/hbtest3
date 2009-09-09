/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
 *
 * Copyright 2009 Marcos Antonio Gambeta <marcosgambeta at gmail dot com>
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
/*----------------------------------------------------------------------*/

#include "hbapi.h"
#include "hbqt.h"

/*----------------------------------------------------------------------*/
#if QT_VERSION >= 0x040500
/*----------------------------------------------------------------------*/

/*
 *  enum ActivationReason { Unknown, Context, DoubleClick, Trigger, MiddleClick }
 *  enum MessageIcon { NoIcon, Information, Warning, Critical }
 */


#include <QtGui/QSystemTrayIcon>


/*
 * QSystemTrayIcon ( QObject * parent = 0 )
 * QSystemTrayIcon ( const QIcon & icon, QObject * parent = 0 )
 * ~QSystemTrayIcon ()
 */
HB_FUNC( QT_QSYSTEMTRAYICON )
{
   hb_retptr( ( QSystemTrayIcon* ) new QSystemTrayIcon( hbqt_par_QObject( 1 ) ) );
}

/*
 * DESTRUCTOR
 */
HB_FUNC( QT_QSYSTEMTRAYICON_DESTROY )
{
   hbqt_par_QSystemTrayIcon( 1 )->~QSystemTrayIcon();
}

/*
 * QMenu * contextMenu () const
 */
HB_FUNC( QT_QSYSTEMTRAYICON_CONTEXTMENU )
{
   hb_retptr( ( QMenu* ) hbqt_par_QSystemTrayIcon( 1 )->contextMenu() );
}

/*
 * QRect geometry () const
 */
HB_FUNC( QT_QSYSTEMTRAYICON_GEOMETRY )
{
   hb_retptr( new QRect( hbqt_par_QSystemTrayIcon( 1 )->geometry() ) );
}

/*
 * QIcon icon () const
 */
HB_FUNC( QT_QSYSTEMTRAYICON_ICON )
{
   hb_retptr( new QIcon( hbqt_par_QSystemTrayIcon( 1 )->icon() ) );
}

/*
 * bool isVisible () const
 */
HB_FUNC( QT_QSYSTEMTRAYICON_ISVISIBLE )
{
   hb_retl( hbqt_par_QSystemTrayIcon( 1 )->isVisible() );
}

/*
 * void setContextMenu ( QMenu * menu )
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SETCONTEXTMENU )
{
   hbqt_par_QSystemTrayIcon( 1 )->setContextMenu( hbqt_par_QMenu( 2 ) );
}

/*
 * void setIcon ( const QIcon & icon )
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SETICON )
{
   hbqt_par_QSystemTrayIcon( 1 )->setIcon( QIcon( hbqt_par_QString( 2 ) ) );
}

/*
 * void setToolTip ( const QString & tip )
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SETTOOLTIP )
{
   hbqt_par_QSystemTrayIcon( 1 )->setToolTip( hbqt_par_QString( 2 ) );
}

/*
 * void showMessage ( const QString & title, const QString & message, MessageIcon icon = Information, int millisecondsTimeoutHint = 10000 )
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SHOWMESSAGE )
{
   hbqt_par_QSystemTrayIcon( 1 )->showMessage( hbqt_par_QString( 2 ), hbqt_par_QString( 3 ), ( HB_ISNUM( 4 ) ? ( QSystemTrayIcon::MessageIcon ) hb_parni( 4 ) : ( QSystemTrayIcon::MessageIcon ) QSystemTrayIcon::Information ), ( HB_ISNUM( 5 ) ? hb_parni( 5 ) : 10000 ) );
}

/*
 * QString toolTip () const
 */
HB_FUNC( QT_QSYSTEMTRAYICON_TOOLTIP )
{
   hb_retc( hbqt_par_QSystemTrayIcon( 1 )->toolTip().toAscii().data() );
}

/*
 * bool isSystemTrayAvailable ()
 */
HB_FUNC( QT_QSYSTEMTRAYICON_ISSYSTEMTRAYAVAILABLE )
{
   hb_retl( hbqt_par_QSystemTrayIcon( 1 )->isSystemTrayAvailable() );
}

/*
 * bool supportsMessages ()
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SUPPORTSMESSAGES )
{
   hb_retl( hbqt_par_QSystemTrayIcon( 1 )->supportsMessages() );
}

/*
 * void hide ()
 */
HB_FUNC( QT_QSYSTEMTRAYICON_HIDE )
{
   hbqt_par_QSystemTrayIcon( 1 )->hide();
}

/*
 * void setVisible ( bool visible )
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SETVISIBLE )
{
   hbqt_par_QSystemTrayIcon( 1 )->setVisible( hb_parl( 2 ) );
}

/*
 * void show ()
 */
HB_FUNC( QT_QSYSTEMTRAYICON_SHOW )
{
   hbqt_par_QSystemTrayIcon( 1 )->show();
}


/*----------------------------------------------------------------------*/
#endif             /* #if QT_VERSION >= 0x040500 */
/*----------------------------------------------------------------------*/
