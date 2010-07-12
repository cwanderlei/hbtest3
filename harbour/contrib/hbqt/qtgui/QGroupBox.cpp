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
 * www - http://harbour-project.org
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

#include "../hbqt.h"

/*----------------------------------------------------------------------*/
#if QT_VERSION >= 0x040500
/*----------------------------------------------------------------------*/

#include <QtCore/QPointer>

#include <QtGui/QGroupBox>


/*
 * QGroupBox ( QWidget * parent = 0 )
 * QGroupBox ( const QString & title, QWidget * parent = 0 )
 * ~QGroupBox ()
 */

typedef struct
{
   QPointer< QGroupBox > ph;
   bool bNew;
   QT_G_FUNC_PTR func;
   int type;
} QGC_POINTER_QGroupBox;

QT_G_FUNC( hbqt_gcRelease_QGroupBox )
{
   QGroupBox  * ph = NULL ;
   QGC_POINTER_QGroupBox * p = ( QGC_POINTER_QGroupBox * ) Cargo;

   if( p && p->bNew && p->ph )
   {
      ph = p->ph;
      if( ph )
      {
         const QMetaObject * m = ( ph )->metaObject();
         if( ( QString ) m->className() != ( QString ) "QObject" )
         {
            HB_TRACE( HB_TR_DEBUG, ( "ph=%p %p YES_rel_QGroupBox   /.\\   ", (void*) ph, (void*) p->ph ) );
            delete ( p->ph );
            HB_TRACE( HB_TR_DEBUG, ( "ph=%p %p YES_rel_QGroupBox   \\./   ", (void*) ph, (void*) p->ph ) );
            p->ph = NULL;
         }
         else
         {
            HB_TRACE( HB_TR_DEBUG, ( "ph=%p NO__rel_QGroupBox          ", ph ) );
            p->ph = NULL;
         }
      }
      else
      {
         HB_TRACE( HB_TR_DEBUG, ( "ph=%p DEL_rel_QGroupBox    :     Object already deleted!", ph ) );
         p->ph = NULL;
      }
   }
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "ph=%p PTR_rel_QGroupBox    :    Object not created with new=true", ph ) );
      p->ph = NULL;
   }
}

void * hbqt_gcAllocate_QGroupBox( void * pObj, bool bNew )
{
   QGC_POINTER_QGroupBox * p = ( QGC_POINTER_QGroupBox * ) hb_gcAllocate( sizeof( QGC_POINTER_QGroupBox ), hbqt_gcFuncs() );

   new( & p->ph ) QPointer< QGroupBox >( ( QGroupBox * ) pObj );
   p->bNew = bNew;
   p->func = hbqt_gcRelease_QGroupBox;
   p->type = HBQT_TYPE_QGroupBox;

   if( bNew )
   {
      HB_TRACE( HB_TR_DEBUG, ( "ph=%p    _new_QGroupBox  under p->pq", pObj ) );
   }
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "ph=%p NOT_new_QGroupBox", pObj ) );
   }
   return p;
}

HB_FUNC( QT_QGROUPBOX )
{
   QGroupBox * pObj = NULL;

   pObj = ( QGroupBox * ) new QGroupBox( hbqt_par_QWidget( 1 ) ) ;

   hb_retptrGC( hbqt_gcAllocate_QGroupBox( ( void * ) pObj, true ) );
}

/*
 * Qt::Alignment alignment () const
 */
HB_FUNC( QT_QGROUPBOX_ALIGNMENT )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      hb_retni( ( Qt::Alignment ) ( p )->alignment() );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_ALIGNMENT FP=hb_retni( ( Qt::Alignment ) ( p )->alignment() ); p is NULL" ) );
   }
}

/*
 * bool isCheckable () const
 */
HB_FUNC( QT_QGROUPBOX_ISCHECKABLE )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      hb_retl( ( p )->isCheckable() );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_ISCHECKABLE FP=hb_retl( ( p )->isCheckable() ); p is NULL" ) );
   }
}

/*
 * bool isChecked () const
 */
HB_FUNC( QT_QGROUPBOX_ISCHECKED )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      hb_retl( ( p )->isChecked() );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_ISCHECKED FP=hb_retl( ( p )->isChecked() ); p is NULL" ) );
   }
}

/*
 * bool isFlat () const
 */
HB_FUNC( QT_QGROUPBOX_ISFLAT )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      hb_retl( ( p )->isFlat() );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_ISFLAT FP=hb_retl( ( p )->isFlat() ); p is NULL" ) );
   }
}

/*
 * void setAlignment ( int alignment )
 */
HB_FUNC( QT_QGROUPBOX_SETALIGNMENT )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      ( p )->setAlignment( hb_parni( 2 ) );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_SETALIGNMENT FP=( p )->setAlignment( hb_parni( 2 ) ); p is NULL" ) );
   }
}

/*
 * void setCheckable ( bool checkable )
 */
HB_FUNC( QT_QGROUPBOX_SETCHECKABLE )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      ( p )->setCheckable( hb_parl( 2 ) );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_SETCHECKABLE FP=( p )->setCheckable( hb_parl( 2 ) ); p is NULL" ) );
   }
}

/*
 * void setFlat ( bool flat )
 */
HB_FUNC( QT_QGROUPBOX_SETFLAT )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      ( p )->setFlat( hb_parl( 2 ) );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_SETFLAT FP=( p )->setFlat( hb_parl( 2 ) ); p is NULL" ) );
   }
}

/*
 * void setTitle ( const QString & title )
 */
HB_FUNC( QT_QGROUPBOX_SETTITLE )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      ( p )->setTitle( QGroupBox::tr( hb_parc( 2 ) ) );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_SETTITLE FP=( p )->setTitle( QGroupBox::tr( hb_parc( 2 ) ) ); p is NULL" ) );
   }
}

/*
 * QString title () const
 */
HB_FUNC( QT_QGROUPBOX_TITLE )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      hb_retc( ( p )->title().toAscii().data() );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_TITLE FP=hb_retc( ( p )->title().toAscii().data() ); p is NULL" ) );
   }
}

/*
 * void setChecked ( bool checked )
 */
HB_FUNC( QT_QGROUPBOX_SETCHECKED )
{
   QGroupBox * p = hbqt_par_QGroupBox( 1 );
   if( p )
      ( p )->setChecked( hb_parl( 2 ) );
   else
   {
      HB_TRACE( HB_TR_DEBUG, ( "............................... F=QT_QGROUPBOX_SETCHECKED FP=( p )->setChecked( hb_parl( 2 ) ); p is NULL" ) );
   }
}


/*----------------------------------------------------------------------*/
#endif             /* #if QT_VERSION >= 0x040500 */
/*----------------------------------------------------------------------*/
