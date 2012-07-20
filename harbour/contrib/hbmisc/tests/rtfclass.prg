/*
 * $Id$
 */

/*
 * harbour rtfclass demo
 * notes : - raw enough but it works
           - using hb_f*() - some compilers are not friendly with this :(
           - rtf is assumed to have association
 * initial release : 23 June 1999 Andi Jahja
 * tested under Windows 98 only with RTF associated to Winword
 * works with printable ascii only
 * placed in the public domain
*/

#define CRLF CHR(13) + CHR(10)

PROCEDURE Main()

   LOCAL ortf  := trtf():new( "test.rtf" )
   LOCAL htest := FCreate( "rtf_test.txt" )
   LOCAL ctest := ""

   // create a plain text file
   ctest += "This is +bHarbour � RTF Class-b" + CRLF
   ctest += "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG" + CRLF
   ctest += "+bTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG-b" + CRLF
   ctest += "+iTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG-i" + CRLF
   ctest += "+buTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG-bu" + CRLF
   ctest += "+buiTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG-bui" + CRLF
   ctest += "THE +bQUICK-b +buBROWN-bu +buiFOX-bui +iJUMPS-i +uOVER-u +ilTHE-il +uLAZY-u +buDOG-bu" + CRLF

   FWrite( htest, ctest )
   FClose( htest )

   // convert text file to rtf
   ortf:write( "rtf_test.txt" )
   ortf:close()

   // execute file association ( windows only )
   #if defined( __PLATFORM__WINDOWS )
      // assuming start.exe is exist
      __Run( "start test.rtf" )
   #endif

   RETURN

FUNCTION trtf()

   STATIC oclass

   IF oclass == nil
      oclass := HBClass():new( "trtf" )
      oclass:adddata( "nhandle" )
      oclass:addmethod( "new",  @new() )
      oclass:addmethod( "write", @write() )
      oclass:addmethod( "close", @close() )
      oclass:create()
   ENDIF

   RETURN oclass:instance()

STATIC FUNCTION new( cfilename )

   LOCAL self := qself()

   ::nhandle   := FCreate( cfilename )
   FWrite( ::nhandle, ;
      "{\rtf1\ansi\deff0{\fonttbl {\f0\fnil\fcharset0 Courier New;}{\f1\fnil\fcharset0 Arial;}}" + ;
      "\uc1\pard\lang1033\ulnone\f0\fs20" + CRLF )

   RETURN self

STATIC FUNCTION write( csource )

   LOCAL self := qself()
   LOCAL cchar, cline, xatt, i
   LOCAL nchar, y

   // These are character attributes, self-defined
   // + means a turn-on
   // - means a turn-off
   LOCAL attrib := { ;
      { "+b"  , "\b "            } /* turn bold on*/ , ;
      { "+bu" , "\ul\b "         } /* turn bold_underline on */, ;
      { "+bi" , "\b\i "          } /* turn bold_italic on */, ;
      { "+bui", "\ul\b\i "       } /* turn bold_underline_italic on */, ;
      { "+i"  , "\i "            } /* turn italic on */, ;
      { "+il" , "\ul\i "         } /* turn italic_underline on */, ;
      { "+u"  , "\ul "           } /* turn underline on */, ;
      { "-b"  , "\b0 "           } /* turn bold off */, ;
      { "-bu" , "\b0\ulnone "    } /* turn bold_underline off */, ;
      { "-bi" , "\b0\i0 "        } /* turn bold_italic off */, ;
      { "-bui", "\b0\i0\ulnone " } /* turn bold_underline_italic off */, ;
      { "-i"  , "\i0 "           } /* turn italic off */, ;
      { "-il" , "\ulnone\i0 "    } /* turn italic_underline off */, ;
      { "-u"  , "\ulnone "       } /* turn underline off */;
   }

   hb_fuse( csource )  // open source file
   WHILE ! hb_FEof()   // read the file line by line
      cline := hb_freadln() + "\par"
      y     := Len( cline )
      for nchar := 1 TO y
         cchar := SubStr( cline, nchar, 1 )

         // todo : i need function dec2hex()
         // to convert ascii to 2-characters hex
         // ie   : dec2hex( "H" ) -> 48
         IF cchar == "+" .OR. cchar == "-"
            xatt := cchar                         + ;
               SubStr( cline, nchar + 1, 1 ) + ;
               SubStr( cline, nchar + 2, 1 ) + ;
               SubStr( cline, nchar + 3, 1 )
            IF ( i := AScan( attrib, {| e | e[ 1 ] == xatt } ) ) > 0
               FWrite( ::nhandle, attrib[ i ][ 2 ] )
               nchar := nchar + Len( xatt ) - 1
            ELSE
               // 3 attributes
               xatt := Left( xatt, 3 )
               IF ( i := AScan( attrib, {| e | e[ 1 ] == xatt } ) ) > 0
                  FWrite( ::nhandle, attrib[ i ][ 2 ] )
                  nchar := nchar + Len( xatt ) - 1
               ELSE
                  // 2 attributes
                  xatt := Left( xatt, 2 )
                  IF ( i := AScan( attrib, {| e | e[ 1 ] == xatt } ) ) > 0
                     FWrite( ::nhandle, attrib[ i ][ 2 ] )
                     nchar := nchar + Len( xatt ) - 1
                  ELSE
                     FWrite( ::nhandle, cchar )
                  ENDIF
               ENDIF
            ENDIF
         ELSE
            FWrite( ::nhandle, cchar )
         ENDIF
      next
      FWrite( ::nhandle, CRLF )
      hb_fskip() // read next line
   ENDDO
   hb_fuse()

   RETURN self

STATIC FUNCTION CLOSE()

   LOCAL self := qself()

   FWrite( ::nhandle, "\f1\fs16\par" + CRLF + "}" )
   FClose( ::nhandle )

   RETURN self
