/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * __XHELP() function
 *
 * Copyright 1999 Victor Szel <info@szelvesz.hu>
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

#include "extend.h"
#include "ctoharb.h"

/*  $DOC$
 *  $FUNCNAME$
 *      __XHELP()
 *  $CATEGORY$
 *      Internal
 *  $ONELINER$
 *      Looks if a Help() user defined function exist.
 *  $SYNTAX$
 *      __XHELP() --> <xValue>
 *  $ARGUMENTS$
 *      None
 *  $RETURNS$
 *      This function returns aleatory values.
 *  $DESCRIPTION$
 *      This is an internal undocumented Clipper function, which will
 *      try to call the user defined function HELP() if it's defined
 *      in the current application. This is the default SetKey() handler
 *      for the F1 key.
 *  $EXAMPLES$
 *  $TESTS$
 *  $STATUS$
 *      R
 *  $COMPLIANCE$
 *      __XHELP() is fully CA-Clipper compliant.
 *  $SEEALSO$
 *      
 *  $END$
 */

HARBOUR HB___XHELP( void )
{
   PHB_DYNS pDynSym = hb_dynsymFind( "HELP" );

   if( pDynSym )
   {
      hb_vmPushSymbol( pDynSym->pSymbol );
      hb_vmPushNil();
      hb_vmDo( 0 );

      /* NOTE: Leave the return value as it is. */
   }
}
