/*
 * $Id$
 */

/* -------------------------------------------------------------------- */
/* WARNING: Automatically generated source file. DO NOT EDIT!           */
/*          Instead, edit corresponding .qth file,                      */
/*          or the generator tool itself, and run regenarate.           */
/* -------------------------------------------------------------------- */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009-2010 Pritpal Bedi <pritpal@vouchcac.com>
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
#include "../hbqt.h"

/*----------------------------------------------------------------------*/
#if QT_VERSION >= 0x040500
/*----------------------------------------------------------------------*/

#include <QtCore/QPointer>

#include <QtCore/QTimer>


/*
 * QTimer ( QObject * parent = 0 )
 * ~QTimer ()
 */

typedef struct
{
   void * ph;
   bool bNew;
   QT_G_FUNC_PTR func;
   QPointer< QTimer > pq;
} QGC_POINTER_QTimer;

QT_G_FUNC( hbqt_gcRelease_QTimer )
{
   QGC_POINTER_QTimer * p = ( QGC_POINTER_QTimer * ) Cargo;

   if( p && p->bNew )
   {
      if( p->ph && p->pq )
      {
         const QMetaObject * m = ( ( QObject * ) p->ph )->metaObject();
         if( ( QString ) m->className() != ( QString ) "QObject" )
         {
            HB_TRACE( HB_TR_DEBUG, ( "YES_rel_QTimer   /.\\   ph=%p pq=%p", p->ph, (void *)(p->pq) ) );
            delete ( ( QTimer * ) p->ph );
            HB_TRACE( HB_TR_DEBUG, ( "YES_rel_QTimer   \\./   ph=%p pq=%p", p->ph, (void *)(p->pq) ) );
            p->ph = NULL;
         }
         else
         {
            HB_TRACE( HB_TR_DEBUG, ( "NO__rel_QTimerph=%p pq=%p", p->ph, (void *)(p->pq) ) );
         }
      }
      else
      {
         HB_TRACE( HB_TR_DEBUG, ( "DEL_rel_QTimer    :     Object already deleted!" ) );
      }
   }
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "PTR_rel_QTimer    :    Object not created with new()" ) );
      p->ph = NULL;
   }
}

void * hbqt_gcAllocate_QTimer( void * pObj, bool bNew )
{
   QGC_POINTER_QTimer * p = ( QGC_POINTER_QTimer * ) hb_gcAllocate( sizeof( QGC_POINTER_QTimer ), hbqt_gcFuncs() );

   p->ph = pObj;
   p->bNew = bNew;
   p->func = hbqt_gcRelease_QTimer;

   if( bNew )
   {
      new( & p->pq ) QPointer< QTimer >( ( QTimer * ) pObj );
      HB_TRACE( HB_TR_DEBUG, ( "   _new_QTimer                     ph=%p %i B %i KB", pObj, ( int ) hb_xquery( 1001 ), hbqt_getmemused() ) );
   }
   return p;
}

HB_FUNC( QT_QTIMER )
{
   void * pObj = NULL;

   pObj = new QTimer( hbqt_par_QObject( 1 ) ) ;

   hb_retptrGC( hbqt_gcAllocate_QTimer( pObj, true ) );
}

/*
 * int interval () const
 */
HB_FUNC( QT_QTIMER_INTERVAL )
{
   hb_retni( hbqt_par_QTimer( 1 )->interval() );
}

/*
 * bool isActive () const
 */
HB_FUNC( QT_QTIMER_ISACTIVE )
{
   hb_retl( hbqt_par_QTimer( 1 )->isActive() );
}

/*
 * bool isSingleShot () const
 */
HB_FUNC( QT_QTIMER_ISSINGLESHOT )
{
   hb_retl( hbqt_par_QTimer( 1 )->isSingleShot() );
}

/*
 * void setInterval ( int msec )
 */
HB_FUNC( QT_QTIMER_SETINTERVAL )
{
   hbqt_par_QTimer( 1 )->setInterval( hb_parni( 2 ) );
}

/*
 * void setSingleShot ( bool singleShot )
 */
HB_FUNC( QT_QTIMER_SETSINGLESHOT )
{
   hbqt_par_QTimer( 1 )->setSingleShot( hb_parl( 2 ) );
}

/*
 * int timerId () const
 */
HB_FUNC( QT_QTIMER_TIMERID )
{
   hb_retni( hbqt_par_QTimer( 1 )->timerId() );
}

/*
 * void singleShot ( int msec, QObject * receiver, const char * member )
 */
HB_FUNC( QT_QTIMER_SINGLESHOT )
{
   hbqt_par_QTimer( 1 )->singleShot( hb_parni( 2 ), hbqt_par_QObject( 3 ), hbqt_par_char( 4 ) );
}

/*
 * void start ()
 */
HB_FUNC( QT_QTIMER_START )
{
   hbqt_par_QTimer( 1 )->start();
}

/*
 * void stop ()
 */
HB_FUNC( QT_QTIMER_STOP )
{
   hbqt_par_QTimer( 1 )->stop();
}

/*
 * void start ( int msec )
 */
HB_FUNC( QT_QTIMER_START_1 )
{
   hbqt_par_QTimer( 1 )->start( hb_parni( 2 ) );
}


/*----------------------------------------------------------------------*/
#endif             /* #if QT_VERSION >= 0x040500 */
/*----------------------------------------------------------------------*/
