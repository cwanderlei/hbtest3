/*
 * $Id$
 */

/*
 * GT CLIPPER STANDARD HEADER
 *
 * File......: strright.c
 * Author....: Andy M Leighton
 * BBS.......: The Dark Knight Returns
 * Net/Node..: 050/069
 * User Name.: Andy Leighton
 * Date......: 23/05/93
 * Revision..: 1.00
 *
 * This is an original work by Andy Leighton and is placed in the
 * public domain.
 */

/*
 *  $DOC$
 *  $FUNCNAME$
 *      GT_STRRIGHT()
 *  $CATEGORY$
 *      String
 *  $ONELINER$
 *      Find length of a suffix of a string
 *  $SYNTAX$
 *      GT_StrRight(<cStr>, <cChars>) --> nLen
 *  $ARGUMENTS$
 *      <cStr>   - The input string
 *      <cChars> - The set of characters to find
 *  $RETURNS$
 *      nLen     - The length of the prefix found.
 *  $DESCRIPTION$
 *      Return the length of the trailing segment in the passed string
 *      <cStr> that consists solely of the characters in the character
 *      set <cChars>.
 *
 *      If no characters in the the search set are found, the function
 *      shall return 0
 *  $EXAMPLES$
 *
 *      ? GT_StrRight("this is a test", "teas ")       // prints 8
 *      ? GT_StrRight("this is a test", "tes h")       // prints 5
 *      ? GT_StrRight("this is a test", "zxy")         // prints 0
 *
 *  $END$
 */


#include "extend.h"


HARBOUR HB_GT_STRRIGHT( void )
{
  char *string;
  char *cset;
  int l1, l2;
  int p1, p2;

  if (ISCHAR(1) && ISCHAR(2)) {
    string = hb_parc(1);
    cset   = hb_parc(2);
    l1     = hb_parclen(1);
    l2     = hb_parclen(2);

    for (p1 = l1 - 1; p1 >= 0; p1--) {
      for (p2 = 0; p2 < l2 && cset[p2] != string[p1]; p2++)
         ;

      if (p2 == l2)
         break;
    }
    hb_retni(l1 - p1 - 1);

  } else {
    hb_retni(-1);               /* parameter mismatch - error NullStr */
  }
}

