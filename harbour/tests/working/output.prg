// Testing Harbour device management.
/* Harbour Project source code
   http://www.Harbour-Project.org/
   Copyright 1999 David G. Holm <dholm@jsd-llc.com>
   See doc/hdr_tpl.txt, Version 1.2 or later, for licensing terms.
*/

#include "set.ch"
#define cNewLine CHR( 13 ) + CHR( 10 )

function Main()

   OUTSTD (cNewLine,  "Testing Harbour device management on", DATE())
   SET ALTERNATE TO OUTPUT ADDITIVE
   SET (_SET_EXTRAFILE, "OUTPUT.EXT", .F.)
   SET PRINTER TO OUTPUT
   SET MARGIN TO 5
   QOUT ("SCREEN, EXTRA, NOT ALTERNATE, NOT PRINTER")
   @ 5,5 SAY "SCREEN, NOT EXTRA, NOT ALTERNATE NOT PRINTER"
   SET ALTERNATE ON
   SET PRINTER ON
   QOUT ("SCREEN, EXTRA, ALTERNATE AND PRINTER")
   @ 10,10 SAY "SCREEN, NOT EXTRA, NOT ALTERNATE, NOT PRINTER"
   SET DEVICE TO PRINTER
   SET (_SET_EXTRAFILE, "")
   QOUT ("SCREEN, ALTERNATE AND PRINTER AGAIN, BUT NOT EXTRA")
   SET PRINTER OFF
   SET (_SET_EXTRAFILE, "OUTPUT.EXT", .T.)
   QOUT ("SCREEN, EXTRA, AND ALTERNATE, BUT NOT PRINTER")
   @ 15,15 SAY "PRINTER, NOT SCREEN, NOT ALTERNATE"
   EJECT

return nil
