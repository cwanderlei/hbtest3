/*
 * $Id$
 */

/*
 * File......: pchr.prg
 * Author....: Jim Gale
 * CIS ID....: 73670,2561
 *
 * This is an original work by Jim Gale and is placed in the
 * public domain.
 *
 * Modification history:
 * ---------------------
 *
 *    Rev 1.2   17 Aug 1991 15:40:16   GLENN
 * Don Caton fixed some spelling errors in the doc
 *
 *    Rev 1.1   15 Aug 1991 23:06:00   GLENN
 * Forest Belt proofread/edited/cleaned up doc
 *
 *    Rev 1.0   12 Jun 1991 01:45:04   GLENN
 * Initial revision.
 *
 */

/* NOTE: In original NF, control codes were also accepted when
         having extra characters (f.e. "/GRAPHICMODE" instead of "/GRAPHIC"),
         but only if _SET_EXACT was set to .F., Harbour accepts them
         that way regardless of _SET_EXACT setting. [vszakats] */

FUNCTION FT_PCHR( c_nums )

   LOCAL c_ret := "", c_st := 0, c_part, c_st2, c_hex := "0123456789ABCDEF"
   LOCAL c_upper, c_t1, c_t2

   IF SubStr( c_nums, 1, 1 ) == "," .OR. Trim( c_nums ) == ""
      RETURN ""
   ENDIF

   c_nums := Trim( c_nums ) + ",~,"
   c_part := SubStr( c_nums, c_st + 1, At( ",", SubStr( c_nums, c_st + 2 ) ) )

   DO WHILE ! ( c_part == "~" .OR. c_part == "" )

      IF SubStr( c_part, 1, 1 ) == Chr( 34 )

         c_st2 := At( Chr( 34 ), SubStr( c_part,2 ) ) + 1
         c_ret := c_ret + SubStr( c_part, 2, c_st2 - 2 )

      ELSEIF SubStr( c_part, 1, 1 ) == "&"

         c_upper := Upper( c_part )
         c_t1 := At( SubStr( c_upper, 2, 1 ), c_hex ) - 1
         IF c_t1 >- 1
            c_t2 := At( SubStr( c_upper, 3, 1 ), c_hex ) - 1
            IF c_t2 >- 1
               c_t1 := c_t1 * 16 + c_t2
            ENDIF
            c_ret := c_ret + Chr( c_t1 )
         ENDIF

      ELSEIF ( Val( c_part ) > 0 .AND. Val( c_part ) < 256 ) .OR. c_part == "0"

         c_ret := c_ret + Chr( Val( c_part ) )

      ELSE

         IF SubStr( c_part, 1, 1 ) == "/"

            c_upper := Upper( c_part )

#define LEFTEQUAL( l, r )       ( Left( l, Len( r ) ) == r )

            DO CASE
            CASE LEFTEQUAL( c_upper, "/GRAPHIC" )
               c_ret += Chr( 27 ) + Chr( 116 ) + Chr( 1 )
            CASE LEFTEQUAL( c_upper, "/ITALIC" )
               c_ret += Chr( 27 ) + Chr( 116 ) + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/PICTURE" )
               c_ret += Chr( 27 ) + Chr( 116 ) + Chr( 1 ) + ;
                  Chr( 27 ) + Chr( 120 ) + Chr( 1 ) + Chr( 27 ) + Chr( 107 ) + Chr( 1 ) + ;
                  Chr( 27 ) + Chr( 77 ) + Chr( 27 ) + "U"
            CASE LEFTEQUAL( c_upper, "/COND" ) .OR. LEFTEQUAL( c_upper, "/SI" )
               c_ret += Chr( 15 )
            CASE LEFTEQUAL( c_upper, "/ROMAN" )
               c_ret += Chr( 27 ) + Chr( 107 ) + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/SANS" )
               c_ret += Chr( 27 ) + Chr( 107 ) + Chr( 1 )
            CASE LEFTEQUAL( c_upper, "/NLQ" )
               c_ret += Chr( 27 ) + Chr( 120 ) + Chr( 1 )
            CASE LEFTEQUAL( c_upper, "/DRAFT" )
               c_ret += Chr( 27 ) + Chr( 120 ) + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/ELITE" )
               c_ret += Chr( 27 ) + Chr( 77 )
            CASE LEFTEQUAL( c_upper, "/PICA" )
               c_ret += Chr( 27 ) + Chr( 80 )
            CASE LEFTEQUAL( c_upper, "/EMPHOFF" )
               c_ret += Chr( 27 ) + Chr( 70 )
            CASE LEFTEQUAL( c_upper, "/EMPH" )
               c_ret += Chr( 27 ) + Chr( 69 )
            CASE LEFTEQUAL( c_upper, "/1/6" )
               c_ret += Chr( 27 ) + Chr( 50 )
            CASE LEFTEQUAL( c_upper, "/1/8" )
               c_ret += Chr( 27 ) + Chr( 48 )
            CASE LEFTEQUAL( c_upper, "/SKIPOFF" )
               c_ret += Chr( 27 ) + Chr( 79 )
            CASE LEFTEQUAL( c_upper, "/SKIP" )
               c_ret += Chr( 27 ) + Chr( 78 )
            CASE LEFTEQUAL( c_upper, "/FF" ) .OR. LEFTEQUAL( c_upper, "/EJECT" )
               c_ret += Chr( 12 )
            CASE LEFTEQUAL( c_upper, "/INIT" ) .OR. LEFTEQUAL( c_upper, "/RESET" )
               c_ret += Chr( 27 ) + Chr( 64 )
            CASE LEFTEQUAL( c_upper, "/SPANISH" )
               c_ret += Chr( 27 ) + Chr( 82 ) + Chr( 12 )
            CASE LEFTEQUAL( c_upper, "/USA" )
               c_ret += Chr( 27 ) + Chr( 82 ) + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/ONE" )
               c_ret += Chr( 27 ) + "U" + Chr( 1 )
            CASE LEFTEQUAL( c_upper, "/TWO" )
               c_ret += Chr( 27 ) + "U" + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/FAST" )
               c_ret += Chr( 27 ) + "s" + Chr( 0 )
            CASE LEFTEQUAL( c_upper, "/SLOW" )
               c_ret += Chr( 27 ) + "s" + Chr( 1 )
            CASE LEFTEQUAL( c_upper, "/OFF" )
               c_ret += Chr( 19 )
            CASE LEFTEQUAL( c_upper, "/ON" )
               c_ret += Chr( 17 )
            CASE LEFTEQUAL( c_upper, "/BEEP" ) .OR. LEFTEQUAL( c_upper, "/BELL" )
               c_ret += Chr( 7 )
            CASE LEFTEQUAL( c_upper, "/CAN" )
               c_ret += Chr( 24 )
            ENDCASE

         ENDIF

      ENDIF

      c_st := At( ",", SubStr( c_nums, c_st + 1 ) ) + c_st
      c_part := SubStr( c_nums, c_st + 1, At( ",", SubStr( c_nums, c_st + 2 ) ) )

   ENDDO

   RETURN c_ret
