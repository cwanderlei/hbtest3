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

/*----------------------------------------------------------------------*/
#if QT_VERSION >= 0x040500
/*----------------------------------------------------------------------*/


/*
 *  Constructed[ 6/9 [ 66.67% ] ]
 *  
 *  *** Unconvered Prototypes ***
 *  -----------------------------
 *  
 *  virtual void commitData ( QSessionManager & manager )
 *  virtual bool macEventFilter ( EventHandlerCallRef, EventRef )
 *  virtual void saveState ( QSessionManager & manager )
 *  
 *  *** Commented out protos which construct fine but do not compile ***
 *  
 *  // virtual bool qwsEventFilter ( QWSEvent * )
 *  // int qwsProcessEvent ( QWSEvent * )
 *  // void qwsSetCustomColors ( QRgb * colortable, int start, int numColors )
 */ 



#include "hbapi.h"
#include "hbinit.h"
#include "hbdefs.h"
#include "hbapifs.h"
#include "hbapiitm.h"
#include "hbstack.h"
#include "hbvm.h"
#include "hbdate.h"
#include "hbapierr.h"

#include <QtGui/QApplication>

void release_codeblocks();

static QApplication * app = NULL;
static bool hbqtinit = false;

/*
 * QApplication ( int & argc, char ** argv )
 * QApplication ( int & argc, char ** argv, bool GUIenabled )
 * QApplication ( int & argc, char ** argv, Type type )
 * QApplication ( Display * display, Qt::HANDLE visual = 0, Qt::HANDLE colormap = 0 )
 * QApplication ( Display * display, int & argc, char ** argv, Qt::HANDLE visual = 0, Qt::HANDLE colormap = 0 )
 * virtual ~QApplication ()
*/

#if 0
HB_FUNC( QT_QAPPLICATION )
{
   int i_argc = 0;
   char** c_argv = NULL;
   app = new QApplication( i_argc, c_argv );
   hb_retptr( ( QApplication* ) app);
}
#endif

HB_FUNC( QT_QAPPLICATION )
{
#if 0
   int i_argc;
   char ** c_argv;
   i_argc = hb_cmdargARGC();
   c_argv = hb_cmdargARGV();
   app = new QApplication( i_argc, c_argv );
#endif
   hb_retptr( ( QApplication * ) app );
}

static void hbqt_Exit( void * cargo )
{
   HB_SYMBOL_UNUSED( cargo );

   release_codeblocks();
}

static void hbqt_Init( void * cargo )
{
   int argc;
   char ** argv;

   HB_SYMBOL_UNUSED( cargo );

   argc = hb_cmdargARGC();
   argv = hb_cmdargARGV();

   app = new QApplication( argc, argv );

   if( app )
      hbqtinit = true;

   if( ! hbqtinit )
      hb_errInternal( 11001, "hbqt_Init(): QT Initilization Error.", NULL, NULL );

   hb_cmdargInit( argc, argv );

   hb_vmAtExit( hbqt_Exit, NULL );
}

HB_CALL_ON_STARTUP_BEGIN( _hb_hbqt_init_ )
   hb_vmAtInit( hbqt_Init, NULL );
HB_CALL_ON_STARTUP_END( _hb_hbqt_init_ )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup _hb_hbqt_init_
#elif defined( HB_MSC_STARTUP )
   #if defined( HB_OS_WIN_64 )
      #pragma section( HB_MSC_START_SEGMENT, long, read )
   #endif
   #pragma data_seg( HB_MSC_START_SEGMENT )
   static HB_$INITSYM hb_auto_hbqt_init_ = _hb_hbqt_init_;
   #pragma data_seg()
#endif

HB_FUNC( QT_QAPPLICATION_EXEC )
{
   hb_retni( app->exec() );
}

HB_FUNC( QT_QAPPLICATION_SETSTYLE )
{
   app->setStyle( hb_parc( 2 ) );
}

HB_FUNC( QT_QAPPLICATION_QUIT )
{
   app->quit();
}

HB_FUNC( QT_QAPPLICATION_ABOUTQT )
{
   app->aboutQt();
}


/*
 * QInputContext * inputContext () const
 */
HB_FUNC( QT_QAPPLICATION_INPUTCONTEXT )
{
   hb_retptr( ( QInputContext* ) hbqt_par_QApplication( 1 )->inputContext(  ) );
}

/*
 * bool isSessionRestored () const
 */
HB_FUNC( QT_QAPPLICATION_ISSESSIONRESTORED )
{
   hb_retl( hbqt_par_QApplication( 1 )->isSessionRestored(  ) );
}

/*
 * QString sessionId () const
 */
HB_FUNC( QT_QAPPLICATION_SESSIONID )
{
   hb_retc( hbqt_par_QApplication( 1 )->sessionId( ).toLatin1().data() );
}

/*
 * QString sessionKey () const
 */
HB_FUNC( QT_QAPPLICATION_SESSIONKEY )
{
   hb_retc( hbqt_par_QApplication( 1 )->sessionKey( ).toLatin1().data() );
}

/*
 * void setInputContext ( QInputContext * inputContext )
 */
HB_FUNC( QT_QAPPLICATION_SETINPUTCONTEXT )
{
   hbqt_par_QApplication( 1 )->setInputContext( hbqt_par_QInputContext( 2 ) );
}

/*
 * QString styleSheet () const
 */
HB_FUNC( QT_QAPPLICATION_STYLESHEET )
{
   hb_retc( hbqt_par_QApplication( 1 )->styleSheet( ).toLatin1().data() );
}


/*----------------------------------------------------------------------*/
#endif             /* #if QT_VERSION >= 0x040500 */
/*----------------------------------------------------------------------*/

