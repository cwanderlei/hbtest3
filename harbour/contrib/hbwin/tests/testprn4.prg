/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2009 Viktor Szakats (harbour.01 syenar.hu)
 * www - http://www.harbour-project.org
 *
 */

#include "simpleio.ch"

PROCEDURE Main()
   LOCAL a := WIN_PRINTERGETDEFAULT()

   ? ">" + a + "<"

   ? WIN_PRINTERSETDEFAULT( a )

   RETURN
