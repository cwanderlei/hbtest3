/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Marcos Antonio Gambeta <marcosgambeta at gmail dot com>
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
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

#if QT_VERSION >= 0x040500

#include <QtGui/QMainWindow>

/*----------------------------------------------------------------------*/
/*
QMainWindow( QWidget * parent = 0, Qt::WindowFlags flags = 0 )
*/
HB_FUNC( QT_QMAINWINDOW )
{
  hb_retptr( ( QMainWindow* ) new QMainWindow( hbqt_par_QWidget( 1 ), ( Qt::WindowFlags ) hb_parni( 2 ) ) );
}

/*
void addDockWidget( Qt::DockWidgetArea area, QDockWidget * dockwidget )
*/
HB_FUNC( QT_QMAINWINDOW_ADDDOCKWIDGET_1 )
{
  hbqt_par_QMainWindow( 1 )->addDockWidget( ( Qt::DockWidgetArea ) hb_parni( 2 ), hbqt_par_QDockWidget( 3 ) );
}

/*
void addDockWidget( Qt::DockWidgetArea area, QDockWidget * dockwidget, Qt::Orientation orientation )
*/
HB_FUNC( QT_QMAINWINDOW_ADDDOCKWIDGET_2 )
{
  hbqt_par_QMainWindow( 1 )->addDockWidget( ( Qt::DockWidgetArea ) hb_parni( 2 ), hbqt_par_QDockWidget( 3 ), ( Qt::Orientation ) hb_parni(4) );
}

/*
void addToolBar( Qt::ToolBarArea area, QToolBar * toolbar )
*/
HB_FUNC( QT_QMAINWINDOW_ADDTOOLBAR_1 )
{
  hbqt_par_QMainWindow( 1 )->addToolBar( ( Qt::ToolBarArea ) hb_parni( 2 ), hbqt_par_QToolBar( 3 ) );
}

/*
void addToolBar( QToolBar * toolbar )
*/
HB_FUNC( QT_QMAINWINDOW_ADDTOOLBAR_2 )
{
  hbqt_par_QMainWindow( 1 )->addToolBar( hbqt_par_QToolBar( 2 ) );
}

/*
QToolBar * addToolBar( const QString & title )
*/
HB_FUNC( QT_QMAINWINDOW_ADDTOOLBAR_3 )
{
  hb_retptr( (QToolBar *) hbqt_par_QMainWindow( 1 )->addToolBar( hbqt_par_QString( 2 ) ) );
}

/*
void addToolBarBreak( Qt::ToolBarArea area = Qt::TopToolBarArea )
*/
HB_FUNC( QT_QMAINWINDOW_ADDTOOLBARBREAK )
{
  hbqt_par_QMainWindow( 1 )->addToolBarBreak( ( Qt::ToolBarArea ) hb_parni( 2 ) );
}

/*
QWidget * centralWidget () const
*/
HB_FUNC( QT_QMAINWINDOW_CENTRALWIDGET )
{
  hb_retptr( (QWidget *) hbqt_par_QMainWindow( 1 )->centralWidget() );
}

/*
Qt::DockWidgetArea corner( Qt::Corner corner ) const
*/
HB_FUNC( QT_QMAINWINDOW_CORNER )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->corner( ( Qt::Corner ) hb_parni( 2 ) ) );
}

/*
virtual QMenu * createPopupMenu ()
*/
HB_FUNC( QT_QMAINWINDOW_CREATEPOPUPMENU )
{
  hb_retptr( (QMenu *) hbqt_par_QMainWindow( 1 )->createPopupMenu() );
}

/*
DockOptions dockOptions () const
*/
HB_FUNC( QT_QMAINWINDOW_DOCKOPTIONS )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->dockOptions() );
}

/*
Qt::DockWidgetArea dockWidgetArea( QDockWidget * dockwidget ) const
*/
HB_FUNC( QT_QMAINWINDOW_DOCKWIDGETAREA )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->dockWidgetArea( hbqt_par_QDockWidget( 2 ) ) );
}

/*
bool documentMode () const
*/
HB_FUNC( QT_QMAINWINDOW_DOCUMENTMODE )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->documentMode() );
}

/*
void insertToolBar( QToolBar * before, QToolBar * toolbar )
*/
HB_FUNC( QT_QMAINWINDOW_INSERTTOOLBAR )
{
  hbqt_par_QMainWindow( 1 )->insertToolBar( hbqt_par_QToolBar( 2 ), hbqt_par_QToolBar( 3 ) );
}

/*
void insertToolBarBreak( QToolBar * before )
*/
HB_FUNC( QT_QMAINWINDOW_INSERTTOOLBARBREAK )
{
  hbqt_par_QMainWindow( 1 )->insertToolBarBreak( hbqt_par_QToolBar( 2 ) );
}

/*
bool isAnimated () const
*/
HB_FUNC( QT_QMAINWINDOW_ISANIMATED )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->isAnimated() );
}

/*
bool isDockNestingEnabled () const
*/
HB_FUNC( QT_QMAINWINDOW_ISDOCKNESTINGENABLED )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->isDockNestingEnabled() );
}

/*
QMenuBar * menuBar () const
*/
HB_FUNC( QT_QMAINWINDOW_MENUBAR )
{
  hb_retptr( (QMenuBar *) hbqt_par_QMainWindow( 1 )->menuBar() );
}

/*
QWidget * menuWidget () const
*/
HB_FUNC( QT_QMAINWINDOW_MENUWIDGET )
{
  hb_retptr( (QWidget *) hbqt_par_QMainWindow( 1 )->menuWidget() );
}

/*
void removeDockWidget( QDockWidget * dockwidget )
*/
HB_FUNC( QT_QMAINWINDOW_REMOVEDOCKWIDGET )
{
  hbqt_par_QMainWindow( 1 )->removeDockWidget( hbqt_par_QDockWidget( 2 ) );
}

/*
void removeToolBar( QToolBar * toolbar )
*/
HB_FUNC( QT_QMAINWINDOW_REMOVETOOLBAR )
{
  hbqt_par_QMainWindow( 1 )->removeToolBar( hbqt_par_QToolBar( 2 ) );
}

/*
void removeToolBarBreak( QToolBar * before )
*/
HB_FUNC( QT_QMAINWINDOW_REMOVETOOLBARBREAK )
{
  hbqt_par_QMainWindow( 1 )->removeToolBarBreak( hbqt_par_QToolBar( 2 ) );
}

/*
bool restoreDockWidget( QDockWidget * dockwidget )
*/
HB_FUNC( QT_QMAINWINDOW_RESTOREDOCKWIDGET )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->restoreDockWidget( hbqt_par_QDockWidget( 2 ) ) );
}

/*
void setCentralWidget( QWidget * widget )
*/
HB_FUNC( QT_QMAINWINDOW_SETCENTRALWIDGET )
{
  hbqt_par_QMainWindow( 1 )->setCentralWidget( hbqt_par_QWidget( 2 ) );
}

/*
void setCorner( Qt::Corner corner, Qt::DockWidgetArea area )
*/
HB_FUNC( QT_QMAINWINDOW_SETCORNER )
{
  hbqt_par_QMainWindow( 1 )->setCorner( ( Qt::Corner) hb_parni( 2 ), ( Qt::DockWidgetArea ) hb_parni(3) );
}

/*
void setDockOptions( DockOptions options )
*/
HB_FUNC( QT_QMAINWINDOW_SETDOCKOPTIONS )
{
  hbqt_par_QMainWindow( 1 )->setDockOptions( ( QMainWindow::DockOptions ) hb_parni( 2 ) );
}

/*
void setDocumentMode( bool enabled )
*/
HB_FUNC( QT_QMAINWINDOW_SETDOCUMENTMODE )
{
  hbqt_par_QMainWindow( 1 )->setDocumentMode( hb_parl( 2 ) );
}

/*
void setMenuBar( QMenuBar * menuBar )
*/
HB_FUNC( QT_QMAINWINDOW_SETMENUBAR )
{
  hbqt_par_QMainWindow( 1 )->setMenuBar( hbqt_par_QMenuBar( 2 ) );
}

/*
void setMenuWidget( QWidget * menuBar )
*/
HB_FUNC( QT_QMAINWINDOW_SETMENUWIDGET )
{
  hbqt_par_QMainWindow( 1 )->setMenuWidget( hbqt_par_QWidget( 2 ) );
}

/*
void setStatusBar( QStatusBar * statusbar )
*/
HB_FUNC( QT_QMAINWINDOW_SETSTATUSBAR )
{
  hbqt_par_QMainWindow( 1 )->setStatusBar( hbqt_par_QStatusBar( 2 ) );
}

/*
void setTabPosition( Qt::DockWidgetAreas areas, QTabWidget::TabPosition tabPosition )
*/
HB_FUNC( QT_QMAINWINDOW_SETTABPOSITION )
{
  hbqt_par_QMainWindow( 1 )->setTabPosition( ( Qt::DockWidgetAreas) hb_parni( 2 ), ( QTabWidget::TabPosition ) hb_parni(3) );
}

/*
void setTabShape( QTabWidget::TabShape tabShape )
*/
HB_FUNC( QT_QMAINWINDOW_SETTABSHAPE )
{
  hbqt_par_QMainWindow( 1 )->setTabShape( ( QTabWidget::TabShape ) hb_parni( 2 ) );
}

/*
void setToolButtonStyle( Qt::ToolButtonStyle toolButtonStyle )
*/
HB_FUNC( QT_QMAINWINDOW_SETTOOLBUTTONSTYLE )
{
  hbqt_par_QMainWindow( 1 )->setToolButtonStyle( ( Qt::ToolButtonStyle ) hb_parni( 2 ) );
}

/*
void setUnifiedTitleAndToolBarOnMac( bool set )
*/
HB_FUNC( QT_QMAINWINDOW_SETUNIFIEDTITLEANDTOOLBARONMAC )
{
  hbqt_par_QMainWindow( 1 )->setUnifiedTitleAndToolBarOnMac( hb_parl( 2 ) );
}

/*
void splitDockWidget( QDockWidget * first, QDockWidget * second, Qt::Orientation orientation )
*/
HB_FUNC( QT_QMAINWINDOW_SPLITDOCKWIDGET )
{
  hbqt_par_QMainWindow( 1 )->splitDockWidget( hbqt_par_QDockWidget( 2 ), hbqt_par_QDockWidget( 3 ),  (Qt::Orientation) hb_parni(4) );
}

/*
QStatusBar * statusBar () const
*/
HB_FUNC( QT_QMAINWINDOW_STATUSBAR )
{
  hb_retptr( (QStatusBar *) hbqt_par_QMainWindow( 1 )->statusBar() );
}

/*
QTabWidget::TabPosition tabPosition( Qt::DockWidgetArea area ) const
*/
HB_FUNC( QT_QMAINWINDOW_TABPOSITION )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->tabPosition( ( Qt::DockWidgetArea ) hb_parni( 2 ) ) );
}

/*
QTabWidget::TabShape tabShape () const
*/
HB_FUNC( QT_QMAINWINDOW_TABSHAPE )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->tabShape() );
}

/*
void tabifyDockWidget( QDockWidget * first, QDockWidget * second )
*/
HB_FUNC( QT_QMAINWINDOW_TABIFYDOCKWIDGET )
{
  hbqt_par_QMainWindow( 1 )->tabifyDockWidget( hbqt_par_QDockWidget( 2 ), hbqt_par_QDockWidget( 3 ) );
}

/*
Qt::ToolBarArea toolBarArea( QToolBar * toolbar ) const
*/
HB_FUNC( QT_QMAINWINDOW_TOOLBARAREA )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->toolBarArea( hbqt_par_QToolBar( 2 ) ) );
}

/*
bool toolBarBreak( QToolBar * toolbar ) const
*/
HB_FUNC( QT_QMAINWINDOW_TOOLBARBREAK )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->toolBarBreak( hbqt_par_QToolBar( 2 ) ) );
}

/*
Qt::ToolButtonStyle toolButtonStyle () const
*/
HB_FUNC( QT_QMAINWINDOW_TOOLBUTTONSTYLE )
{
  hb_retni( hbqt_par_QMainWindow( 1 )->toolButtonStyle() );
}

/*
bool unifiedTitleAndToolBarOnMac () const
*/
HB_FUNC( QT_QMAINWINDOW_UNIFIEDTITLEANDTOOLBARONMAC )
{
  hb_retl( hbqt_par_QMainWindow( 1 )->unifiedTitleAndToolBarOnMac() );
}

/*
void setAnimated( bool enabled )
*/
HB_FUNC( QT_QMAINWINDOW_SETANIMATED )
{
  hbqt_par_QMainWindow( 1 )->setAnimated( hb_parl( 2 ) );
}

/*
void setDockNestingEnabled( bool enabled ) const
*/
HB_FUNC( QT_QMAINWINDOW_SETDOCKNESTINGENABLED )
{
  hbqt_par_QMainWindow( 1 )->setDockNestingEnabled( hb_parl( 2 ) );
}

/*----------------------------------------------------------------------*/
#endif
