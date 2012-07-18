/*
 * $Id$
 */

//+--------------------------------------------------------------------
//+ Browse function
//+
//+ Written by Alexander Kresin <alex@belacy.belgorod.su>
//+
//+ Date : 30/09/1999
//+ Time : 19:20
//+ Placed in the public domain
//+
//+    Source Module => db_brows.prg
//+
//+    Functions: PROCEDURE Main()
//+               Function DBFLIST()
//+               Function DBFLIST()
//+               Function FLDCOUNT()
//+               Function VIVNAMES()
//+               Function WNDVIVOD()
//+               Static Procedure VIVSTR()
//+               Function FLDSTR()
//+               Function GetBuf()
//+               Function InitList()
//+               Function Defpict()
//+               Function NUM_STR()
//+
//+       Tables: USE &filename
//+
//+    Reformatted by Click! 2.00 on Apr-20-2001 at 11:46 am
//+
//+--------------------------------------------------------------------

#include "fileio.ch"

#define LI_LEN    42
#define LI_NSTR      mslist[1]
#define LI_CLR       mslist[2]   // Color of a window
#define LI_CLRV      mslist[3]   // Color of a current line
#define LI_BSKIP     mslist[4]   // Codeblock for a 'skip' operation
#define LI_BGTOP     mslist[5]   // Codeblock for a 'go top'
#define LI_BGBOT     mslist[6]   // Codeblock for a 'go bottom'
#define LI_BEOF      mslist[7]   // Codeblock for a 'eof' checking
#define LI_BBOF      mslist[8]   // Codeblock for a 'bof' checking
#define LI_B1        mslist[9]
#define LI_MSF       mslist[10]  // Array of codeblocks for columns
#define LI_NAMES     mslist[11]  // Array of the fields names
#define LI_NMCLR     mslist[12]  // Color of field names line
#define LI_FREEZE    mslist[13]  // Number of fields to 'freeze' from left
#define LI_RCOU      mslist[14]
#define LI_MSREC     mslist[15]
#define LI_PRFLT     mslist[16]
#define LI_TEKZP     mslist[17]
#define LI_KOLZ      mslist[18]
#define LI_VALID     mslist[19]  // Array of codeblocks for postvalidation while changing a field
#define LI_WHEN      mslist[20]  // Array of codeblocks for prevalidation while changing a field
#define LI_MSNAME    mslist[21]
#define LI_MSTYP     mslist[22]
#define LI_MSLEN     mslist[23]
#define LI_MSDEC     mslist[24]
#define LI_EXPFI     mslist[25]
#define LI_BDESHIN   mslist[26]
#define LI_BDESHOUT  mslist[27]
#define LI_RECNO     mslist[28]
#define LI_BGOTO     mslist[29]
#define LI_Y1        mslist[30]
#define LI_X1        mslist[31]
#define LI_Y2        mslist[32]
#define LI_X2        mslist[33]
#define LI_LSOHR     mslist[34]
#define LI_LVIEW     mslist[35]
#define LI_NCOLUMNS  mslist[36]
#define LI_LEFTVISIBLE  mslist[37]
#define LI_NLEFT     mslist[38]
#define LI_COLPOS    mslist[39]
#define LI_XPOS      mslist[40]
#define LI_MSED      mslist[41]
#define LI_COLCOUNT  mslist[42]

MEMVAR str_bar

//+--------------------------------------------------------------------
//+
//+    PROCEDURE Main()
//+
//+--------------------------------------------------------------------
//+

PROCEDURE Main( filename )

   LOCAL vybkey := 1

   IF filename == Nil
      ? 'Dbf browse demo'
      ? 'Syntax:'
      ? '', 'db_brows filename'
      QUIT
   ENDIF
   USE ( filename )
   DO WHILE vybkey != 0
      vybkey := DBFLIST( , 3, 1, 76, 20, filename )
      DO CASE
      CASE vybkey == 13                  // Enter
         // ...
      CASE vybkey == - 2                 // F3
         // ...
      CASE vybkey == - 4                 // F5
         // ...
      ENDCASE
   ENDDO

   RETURN

//+--------------------------------------------------------------------
//+
//+    Function DBFLIST()
//+
//+    Called from ( db_brows.prg )   1 - PROCEDURE Main()
//+
//+--------------------------------------------------------------------
//+
#ifdef VER_MOUSE

FUNCTION DBFLIST( mslist, x1, y1, x2, y2, title, maskey, ctrl_ar )

#else

FUNCTION DBFLIST( mslist, x1, y1, x2, y2, title, maskey )

#endif

   LOCAL rezproc, xkey, rez, fipos, wndbuf, predit, predxx, oldcolors
#ifdef VER_MOUSE
   LOCAL ym, xm
#endif
   LOCAL i
   LOCAL fbar1, fbar2, vartmp, varbuf, razmer
   LOCAL GetList := {}

   MEMVAR str_bar

   IF mslist == Nil
      mslist := InitList()
   ENDIF
   IF !( Type( "str_bar" ) == "C" )
      PRIVATE str_bar := "-�"
   ENDIF
   LI_Y1 := y1
   LI_X1 := x1
   LI_Y2 := y2
   LI_X2 := x2
   IF LI_MSF == Nil
      LI_COLCOUNT := FCount()
      LI_MSTYP := Array( LI_COLCOUNT )
      LI_MSLEN := Array( LI_COLCOUNT )
      LI_MSDEC := Array( LI_COLCOUNT )
      AFields( , LI_MSTYP, LI_MSLEN, LI_MSDEC )
   ELSE
      LI_COLCOUNT := Len( LI_MSF )
      IF LI_MSTYP == Nil
         LI_MSTYP := Array( LI_COLCOUNT )
         LI_MSLEN := Array( LI_COLCOUNT )
         LI_MSDEC := Array( LI_COLCOUNT )
         FOR i := 1 TO LI_COLCOUNT
            IF ValType( LI_MSF[ i ] ) == "B"
               vartmp        := Eval( LI_MSF[ i ], mslist, i )
               LI_MSTYP[ i ] := ValType( vartmp )
               IF LI_MSTYP[ i ] == "C"
                  LI_MSLEN[ i ] := Len( vartmp )
               ELSEIF LI_MSTYP[ i ] == "N"
                  vartmp        := Str( vartmp )
                  LI_MSLEN[ i ] := Len( vartmp )
                  LI_MSDEC[ i ] := iif( '.' $ vartmp, LI_MSLEN[ i ] - At( '.', vartmp ), 0 )
               ELSEIF LI_MSTYP[ i ] == "D"
                  LI_MSLEN[ i ] := 8
               ELSEIF LI_MSTYP[ i ] == "L"
                  LI_MSLEN[ i ] := 1
               ENDIF
            ELSE
               LI_MSTYP[ i ] := ValType( FieldGet( FieldPos( LI_MSF[ i ] ) ) )
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF ValType( LI_MSED ) == "N"
      predxx := predit := LI_MSED
   ELSE
      predxx := predit := iif( AScan( LI_MSED, 3 ) != 0, 3, iif( AScan( LI_MSED, 2 ) != 0, 2, 1 ) )
   ENDIF
   SET CURSOR ( predit > 1 )
   SET EXACT OFF
   IF LI_LSOHR
      wndbuf := SaveScreen( LI_Y1, LI_X1, LI_Y2, LI_X2 )
   ENDIF
   oldcolors := SetColor()
   SetColor( LI_CLR )
   @ LI_Y1, LI_X1, LI_Y2, LI_X2 BOX "�Ŀ����� "
   IF title != Nil
      @ LI_Y1, ( LI_X2 - LI_X1 - 1 - Len( title ) ) / 2 + LI_X1 SAY " " + title + " "
   ENDIF
   IF title != Nil .AND. LI_NAMES != Nil
      LI_Y1 ++
   ENDIF
   razmer := LI_Y2 - LI_Y1 - 1
   IF ! LI_PRFLT
      LI_KOLZ := Eval( LI_RCOU, mslist )
   ENDIF
   LI_COLPOS := 1
   LI_NLEFT  := LI_FREEZE + 1
   // DO MSFNEXT WITH mslist,LI_NLEFT
   LI_LEFTVISIBLE := LI_NLEFT
   STORE .T. TO rez
   LI_NCOLUMNS := FLDCOUNT( mslist, LI_X1 + 2, LI_X2 - 2, LI_NLEFT )
   VIVNAMES( mslist, LI_NLEFT )
   IF Eval( LI_BEOF, mslist )
      Eval( LI_BGTOP, mslist )
      LI_NSTR := 1
   ELSE
      Eval( LI_BSKIP, mslist, - ( LI_NSTR - 1 ) )
      IF Eval( LI_BBOF, mslist )
         Eval( LI_BGTOP, mslist )
         LI_NSTR := 1
      ENDIF
   ENDIF
   WNDVIVOD( mslist )
   Eval( LI_BSKIP, mslist, ( LI_NSTR - 1 ) )
   IF LI_KOLZ == 0 .AND. predit == 3
      LI_NSTR := 0
      KEYBOARD Chr( 24 )
   ENDIF
   DO WHILE rez
      SetColor( LI_CLR )
      Eval( LI_B1, mslist )
      //     IF predit>1
      //      SETCOLOR(LI_CLRV+"*")                 // �뤥���� ��ப�
      //     ELSE
      SetColor( LI_CLRV )
      //     ENDIF
      VIVSTR( mslist, LI_NSTR + LI_Y1, iif( predit > 1, LI_COLPOS, 0 ) )
      SetColor( LI_CLR )                // ����� �뤥�����
      //
#ifdef RDD_AX
      @ LI_Y1 + 2, LI_X2, LI_Y2 - 2, LI_X2 BOX Left( str_bar, 1 )
      @ LI_Y1 + 1, LI_X2                                                                                                                  SAY SubStr( str_bar, 2, 1 )
      @ LI_Y2 - 1, LI_X2                                                                                                                  SAY SubStr( str_bar, 2, 1 )
      @ LI_Y1 + 2 + Int( iif( LI_PRFLT, LI_TEKZP, Ax_Keyno() ) * ( LI_Y2 - LI_Y1 - 4 ) / iif( LI_PRFLT, LI_KOLZ, Ax_KeyCount() ) ), LI_X2 SAY Right( str_bar, 1 )
#else
      IF ! ( Type( "Sx_Keyno()" ) == "U" )
         @ LI_Y1 + 2, LI_X2, LI_Y2 - 2, LI_X2 BOX Left( str_bar, 1 )
         @ LI_Y1 + 1, LI_X2 SAY SubStr( str_bar, 2, 1 )
         @ LI_Y2 - 1, LI_X2 SAY SubStr( str_bar, 2, 1 )
         fbar1 := "Sx_Keyno()"
         fbar2 := "Sx_KeyCount()"
         @ LI_Y1 + 2 + Int( iif( LI_PRFLT, LI_TEKZP, &fbar1 ) * ( LI_Y2 - LI_Y1 - 4 ) / iif( LI_PRFLT, LI_KOLZ, &fbar2 ) ), LI_X2 SAY Right( str_bar, 1 )
      ENDIF
#endif
      //
      IF LI_LVIEW
         xkey := 27
      ELSE
#ifdef VER_MOUSE
         xkey := IN_KM( .F. )
         IF xkey == 502
            DO WHILE M_STAT() != 0
            ENDDO
            xkey := 27
         ELSEIF xkey == 501
            ym := M_YTEXT()
            xm := M_XTEXT()
            IF ( ym <= LI_Y1 .OR. ym >= LI_Y2 .OR. xm <= LI_X1 .OR. xm >= LI_X2 )
               IF xm <= LI_X2 .AND. xm >= LI_X1 .AND. ( ym == LI_Y1 .OR. ym == LI_Y2 )
                  M_SHOW()
                  i := Seconds()
                  DO WHILE Seconds() - i < 0.05
                  ENDDO
                  KEYBOARD Chr( iif( ym == LI_Y1, 5, 24 ) )
                  M_HIDE()
                  LOOP
               ELSEIF ctrl_ar != Nil
                  FOR i := 1 TO Len( ctrl_ar )
                     IF ValType( ctrl_ar[ i ] ) == "C"
                        SetColor( ctrl_ar[ i ] )
                     ELSE
                        rezproc := F_CTRL( ctrl_ar[ i ], , , , , , 1, ym, xm )
                        IF rezproc > 0
                           EXIT
                        ENDIF
                     ENDIF
                  NEXT
                  SetColor( LI_CLR )
                  IF rezproc > 0
                     rezproc += 500
                     EXIT
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
#else
         xkey := Inkey( 0 )
#endif
      ENDIF
      VIVSTR( mslist, LI_NSTR + LI_Y1, 0 )                  // ��ப�
      IF xkey < 500
         DO CASE
         CASE xkey == 24                 // ����� ����
            IF ( LI_KOLZ > 0 .OR. predit == 3 ) .AND. ( LI_KOLZ == 0 .OR. ! Eval( LI_BEOF, mslist ) )
               Eval( LI_BSKIP, mslist, 1 )
               IF Eval( LI_BEOF, mslist ) .AND. ( predit < 3 .OR. LI_PRFLT )
                  Eval( LI_BSKIP, mslist, - 1 )
               ELSE
                  IF Eval( LI_BEOF, mslist )
                     vartmp      := LI_NLEFT
                     LI_NLEFT    := LI_LEFTVISIBLE
                     LI_COLPOS   := LI_LEFTVISIBLE
                     LI_NCOLUMNS := FLDCOUNT( mslist, LI_X1 + 2, LI_X2 - 2, LI_NLEFT )
                     IF vartmp > LI_LEFTVISIBLE
                        Eval( LI_BSKIP, mslist, - 1 )
                        Eval( LI_BSKIP, mslist, - ( LI_NSTR - 1 ) )
                        WNDVIVOD( mslist )
                        Eval( LI_BSKIP, mslist, LI_NSTR - 1 )
                        Eval( LI_BSKIP, mslist )
                     ENDIF
                  ENDIF
                  LI_NSTR ++
                  IF LI_NSTR > razmer
                     LI_NSTR := razmer
                     Scroll( LI_Y1 + 1, LI_X1 + 1, LI_Y2 - 1, LI_X2 - 1, 1 )
                     VIVSTR( mslist, LI_Y2 - 1, 0 )
                  ENDIF
                  IF Eval( LI_BEOF, mslist )
                     KEYBOARD Chr( 13 )
                  ENDIF
               ENDIF
            ENDIF
         CASE xkey == 5 .AND. LI_KOLZ > 0                    // ����� �����
            Eval( LI_BSKIP, mslist, - 1 )
            IF Eval( LI_BBOF, mslist )
               Eval( LI_BGTOP, mslist )
            ELSE
               LI_NSTR --
               IF LI_NSTR == 0
                  LI_NSTR := 1
                  Scroll( LI_Y1 + 1, LI_X1 + 1, LI_Y2 - 1, LI_X2 - 1, - 1 )
                  VIVSTR( mslist, LI_Y1 + 1, 0 )
               ENDIF
            ENDIF
         CASE xkey == 4 .AND. LI_KOLZ != 0                   // ����� ��ࠢ�
            IF predit > 1
               IF LI_COLPOS < LI_NCOLUMNS
                  LI_COLPOS ++
                  LOOP
               ENDIF
            ENDIF
            IF LI_NCOLUMNS + LI_NLEFT - LI_FREEZE - 1 < LI_COLCOUNT
               i := LI_NLEFT + LI_NCOLUMNS
               DO WHILE LI_NCOLUMNS + LI_NLEFT - LI_FREEZE - 1 < LI_COLCOUNT .AND. LI_NLEFT + LI_NCOLUMNS == i
                  LI_NLEFT ++
                  // DO MSFNEXT WITH mslist,LI_NLEFT
                  LI_NCOLUMNS := FLDCOUNT( mslist, LI_X1 + 2, LI_X2 - 2, LI_NLEFT )
               ENDDO
               LI_COLPOS := i - LI_NLEFT + 1
               Eval( LI_BSKIP, mslist, - ( LI_NSTR - 1 ) )
               WNDVIVOD( mslist )
               Eval( LI_BSKIP, mslist, LI_NSTR - 1 )
            ENDIF
            VIVNAMES( mslist, LI_NLEFT )
         CASE xkey == 19                 // ����� �����
            IF predit > 1
               IF LI_COLPOS != 1
                  LI_COLPOS --
                  LOOP
               ENDIF
            ENDIF
            IF LI_NLEFT > LI_LEFTVISIBLE
               LI_NLEFT --
               // DO MSFBACK WITH mslist,LI_NLEFT
               LI_NCOLUMNS := FLDCOUNT( mslist, LI_X1 + 2, LI_X2 - 2, LI_NLEFT )
               LI_COLPOS   := 1
               Eval( LI_BSKIP, mslist, - ( LI_NSTR - 1 ) )
               WNDVIVOD( mslist )
               Eval( LI_BSKIP, mslist, LI_NSTR - 1 )
            ENDIF
            VIVNAMES( mslist, LI_NLEFT )
         CASE xkey == 3                  // PgDn
            Eval( LI_BSKIP, mslist, razmer - LI_NSTR + 1 )
            LI_NSTR := 1
            IF Eval( LI_BEOF, mslist )
               Eval( LI_BSKIP, mslist, - 1 )
            ENDIF
            WNDVIVOD( mslist )
         CASE xkey == 18                 // PgUp
            IF LI_NSTR > 1
               Eval( LI_BSKIP, mslist, - ( LI_NSTR - 1 ) )
               LI_NSTR := 1
            ELSE
               Eval( LI_BSKIP, mslist, - razmer )
               IF Eval( LI_BBOF, mslist )
                  Eval( LI_BGTOP, mslist )
               ENDIF
               WNDVIVOD( mslist )
            ENDIF
         CASE xkey == 6 .AND. LI_KOLZ > 0                    // End
            Eval( LI_BGBOT, mslist )
            Eval( LI_BSKIP, mslist, - ( razmer - 1 ) )
            IF Eval( LI_BBOF, mslist )
               Eval( LI_BGTOP, mslist )
            ENDIF
            LI_NSTR := WNDVIVOD( mslist )
            Eval( LI_BSKIP, mslist, LI_NSTR - 1 )
         CASE xkey == 1 .AND. LI_KOLZ > 0                    // Home
            LI_NSTR := 1
            Eval( LI_BGTOP, mslist )
            WNDVIVOD( mslist )
         CASE xkey == 13 .AND. predit < 2                    // Enter
            rez     := .F.
            rezproc := xkey
         CASE ( xkey == 13 .OR. ( xkey > 47 .AND. xkey < 58 ) .OR. ( xkey > 64 .AND. xkey < 91 ) ;
               .OR. ( xkey > 96 .AND. xkey < 123 ) .OR. ( xkey > 127 .AND. xkey < 176 ) .OR. ( xkey > 223 .AND. xkey < 240 ) ) .AND. predit > 1             // Enter
            //   ������஢����
            fipos := LI_COLPOS + LI_NLEFT - 1 - LI_FREEZE
            IF LI_WHEN == Nil .OR. Len( LI_WHEN ) < fipos .OR. LI_WHEN[ fipos ] == Nil .OR. Eval( LI_WHEN[ fipos ] )
               IF ValType( LI_MSED ) != "N"
                  vartmp := iif( Len( LI_MSED ) < fipos, 1, LI_MSED[ fipos ] )
                  IF ValType( vartmp ) == "N"
                     IF vartmp != 2
                        LOOP
                     ENDIF
                  ELSE
                     LOOP
                  ENDIF
               ENDIF
               SET CURSOR ON
               SetColor( LI_CLRV + "," + LI_CLRV )
               IF xkey != 13
                  KEYBOARD Chr( xkey ) + GetBuf()
               ENDIF
               vartmp := ReadExit( .T. )
               varbuf := FieldGet( fipos )
               @ LI_NSTR + LI_Y1, LI_XPOS GET varbuf PICTURE Defpict( mslist, fipos, LI_X2 - LI_X1 - 3 )
               IF LI_VALID != Nil .AND. Len( LI_VALID ) >= fipos .AND. LI_VALID[ fipos ] != Nil
                  Getlist[ 1 ] :postBlock := LI_VALID[ fipos ]
               ENDIF
               READ
               IF LastKey() != 27 .AND. Updated()
                  IF Eval( LI_BEOF, mslist )
                     APPEND BLANK
                     LI_KOLZ := Eval( LI_RCOU, mslist )
                  ELSE
                     IF ! Set( _SET_EXCLUSIVE )
                        RLock()
                        IF NetErr()
                           LOOP
                        ENDIF
                     ENDIF
                  ENDIF
                  IF LI_BDESHOUT != Nil .AND. ValType( varbuf ) == "C"
                     varbuf := Eval( LI_BDESHOUT, mslist, varbuf )
                  ENDIF
                  FieldPut( fipos, varbuf )
                  IF ! Set( _SET_EXCLUSIVE )
                     UNLOCK
                  ENDIF
               ENDIF
               IF ( LastKey() == 27 .OR. ! Updated() ) .AND. Eval( LI_BEOF, mslist )
                  SetColor( LI_CLR )
                  @ LI_NSTR + LI_Y1, LI_X1 + 1 CLEAR TO LI_NSTR + LI_Y1, LI_X2 - 1
                  LI_NSTR --
                  Eval( LI_BSKIP, mslist, - 1 )
               ELSE
                  IF ( vartmp := LastKey() ) != 13 .AND. vartmp != 27 .AND. vartmp < 32
                     KEYBOARD Chr( vartmp )
                  ENDIF
               ENDIF
               ReadExit( vartmp )
               SET CURSOR OFF
            ENDIF
         CASE xkey == 27                 // Esc
            rez     := .F.
            rezproc := 0
         CASE xkey == - 1 .AND. ( maskey == Nil .OR. AScan( maskey, xkey ) == 0 )  // F2
            IF predit == 1
               predit := predxx
            ELSEIF predit > 1
               predit := 1
            ENDIF
            OTHERWISE
            IF maskey != Nil
               IF AScan( maskey, xkey ) != 0
                  rez     := .F.
                  rezproc := xkey
               ENDIF
            ENDIF
         ENDCASE
#ifdef VER_MOUSE
      ELSE
         IF ym > LI_Y1 .AND. ym < LI_Y2 .AND. xm > LI_X1 .AND. xm < LI_X2
            IF predit < 2
               IF LI_NSTR == ym - LI_Y1
                  rez     := .F.
                  rezproc := 13
               ELSE
                  Eval( LI_BSKIP, mslist, ym - LI_Y1 - LI_NSTR )
                  LI_NSTR := ym - LI_Y1
               ENDIF
            ELSE
               i := FLDCOUNT( mslist, LI_X1 + 2, xm, LI_NLEFT ) + 1
               IF i <= FLDCOUNT( mslist, LI_X1 + 2, LI_X2 - 2, LI_NLEFT )
                  IF i == 2 .AND. xm < LI_X1 + 2 + Len( FLDSTR( mslist, LI_NLEFT + LI_COLPOS - 1 ) )
                     i := 1
                  ENDIF
                  IF LI_COLPOS != i .OR. LI_NSTR != ym - LI_Y1
                     LI_COLPOS := i
                     Eval( LI_BSKIP, mslist, ym - LI_Y1 - LI_NSTR )
                     LI_NSTR := ym - LI_Y1
                  ELSE
                     KEYBOARD Chr( 13 )
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         M_SHOW()
         DO WHILE M_STAT() != 0
         ENDDO
         M_HIDE()
#endif
      ENDIF
   ENDDO

   IF LI_LSOHR
      RestScreen( iif( title != Nil .AND. LI_NAMES != Nil, LI_Y1 - 1, LI_Y1 ), LI_X1, LI_Y2, LI_X2, wndbuf )
   ELSE
      SetColor( LI_CLRV )
      VIVSTR( mslist, LI_NSTR + LI_Y1, iif( predit > 1, LI_COLPOS, 0 ) )
   ENDIF
   SetColor( oldcolors )
   SET CURSOR ON

   RETURN rezproc

//+--------------------------------------------------------------------
//+
//+    Function FLDCOUNT()
//+
//+    Called from ( db_brows.prg )   6 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION FLDCOUNT( mslist, xstrt, xend, fld1 )

   LOCAL klf := 0, i := iif( LI_FREEZE > 0, 1, fld1 )

   DO WHILE .T.
      xstrt += Max( Len( FLDSTR( mslist, i ) ), iif( LI_NAMES != Nil .AND. Len( LI_NAMES ) >= i, Len( LI_NAMES[ i ] ), 0 ) ) - 1
      IF xstrt > xend
         EXIT
      ENDIF
      klf ++
      i     := iif( i == LI_FREEZE, fld1, i + 1 )
      xstrt += 2
      IF i > LI_COLCOUNT
         EXIT
      ENDIF
   ENDDO

   RETURN iif( klf == 0, 1, klf )

//+--------------------------------------------------------------------
//+
//+    Function VIVNAMES()
//+
//+    Called from ( db_brows.prg )   3 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION VIVNAMES( mslist )

   LOCAL i := 1, x, oldc, fif

   IF LI_NAMES != Nil
      x := LI_X1 + 2
      IF LI_NMCLR != Nil
         oldc := SetColor( LI_NMCLR )
      ENDIF
      @ LI_Y1, x - 1 CLEAR TO LI_Y1, LI_X2 - 1
      fif := iif( LI_FREEZE > 0, 1, LI_NLEFT )
      // DO MSFNEXT WITH mslist,fif
      DO WHILE i <= LI_NCOLUMNS .AND. fif <= Len( LI_NAMES )
         IF LI_NAMES[ fif ] != Nil
            @ LI_Y1, x SAY LI_NAMES[ fif ]
         ENDIF
         x   := x + Max( Len( FLDSTR( mslist, fif ) ), Len( LI_NAMES[ fif ] ) ) + 1
         fif := iif( fif == LI_FREEZE, LI_NLEFT, fif + 1 )
         // DO MSFNEXT WITH mslist,fif
         i ++
      ENDDO
      IF LI_NMCLR != Nil
         SetColor( oldc )
      ENDIF
   ENDIF

   RETURN Nil

//+--------------------------------------------------------------------
//+
//+    Function WNDVIVOD()
//+
//+    Called from ( db_brows.prg )   8 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION WNDVIVOD( mslist )

   LOCAL firstrec, nstr := 1, tekzp1

   IF LI_PRFLT
      tekzp1 := LI_TEKZP
   ENDIF
   firstrec := Eval( LI_RECNO, mslist )
   SetColor( LI_CLR )
   @ LI_Y1 + 1, LI_X1 + 1 CLEAR TO LI_Y2 - 1, LI_X2 - 1
   DO WHILE .T.
      VIVSTR( mslist, nstr + LI_Y1, 0 )
      nstr ++
      Eval( LI_BSKIP, mslist, 1 )
      IF nstr > LI_Y2 - LI_Y1 - 1 .OR. Eval( LI_BEOF, mslist )
         EXIT
      ENDIF
   ENDDO
   IF LI_PRFLT
      LI_TEKZP := tekzp1
   ENDIF
   Eval( LI_BGOTO, mslist, firstrec )

   RETURN nstr - 1

//+--------------------------------------------------------------------
//+
//+    Static Procedure VIVSTR()
//+
//+    Called from ( db_brows.prg )   5 - function dbflist()
//+                                   1 - function wndvivod()
//+
//+--------------------------------------------------------------------
//+

STATIC PROCEDURE VIVSTR( mslist, nstroka, vybfld )

   LOCAL x, i, sviv, fif

   LI_XPOS := x := LI_X1 + 2
   IF LI_KOLZ > 0
      fif     := iif( LI_FREEZE > 0, 1, LI_NLEFT )
      IF LI_NLEFT != LI_LEFTVISIBLE .AND. vybfld == 0
         @ nstroka, LI_X1 + 1 SAY "<"
      ENDIF
      IF Deleted()
         @ nstroka, LI_X1 + 1 SAY "*"
      ENDIF
      FOR i := 1 TO LI_NCOLUMNS
         IF i == LI_COLPOS
            LI_XPOS := x
         ENDIF
         IF vybfld == 0 .OR. vybfld == i
            // DO MSFNEXT WITH mslist,fif
            sviv := FLDSTR( mslist, fif )
            sviv := iif( Len( sviv ) < LI_X2 - 1 - x, sviv, SubStr( sviv, 1, LI_X2 - 1 - x ) )
            @ nstroka, x SAY sviv
         ELSE
            sviv := FLDSTR( mslist, fif )
            sviv := iif( Len( sviv ) < LI_X2 - 1 - x, sviv, SubStr( sviv, 1, LI_X2 - 1 - x ) )
         ENDIF
         x   := x + Max( Len( sviv ), iif( LI_NAMES != Nil .AND. Len( LI_NAMES ) >= fif, Len( LI_NAMES[ fif ] ), 0 ) ) + 1
         fif := iif( fif == LI_FREEZE, LI_NLEFT, fif + 1 )
      NEXT
      // DO MSFNEXT WITH mslist,fif
      IF fif <= LI_COLCOUNT .AND. vybfld == 0
         IF LI_X2 - 1 - x > 0
            sviv := FLDSTR( mslist, fif )
            @ nstroka, x SAY SubStr( sviv, 1, LI_X2 - 1 - x )
         ENDIF
         @ nstroka, LI_X2 - 1 SAY ">"
      ENDIF
   ENDIF

   RETURN

//+--------------------------------------------------------------------
//+
//+    Function FLDSTR()
//+
//+    Called from ( db_brows.prg )   1 - function dbflist()
//+                                   1 - function fldcount()
//+                                   1 - function vivnames()
//+                                   3 - static procedure vivstr()
//+
//+--------------------------------------------------------------------
//+

FUNCTION FLDSTR( mslist, numf )

   LOCAL fldtype, rez, vartmp

   IF LI_MSF != Nil
      IF numf <= Len( LI_MSF )
         vartmp := LI_MSF[ numf ]
         IF ( fldtype := ValType( vartmp ) ) == "B"
            vartmp := Eval( vartmp, mslist, numf )
            IF LI_MSTYP[ numf ] == "C"
               RETURN PadR( vartmp, LI_MSLEN[ numf ] )
            ELSEIF LI_MSTYP[ numf ] == "N"
               RETURN PadL( Str( vartmp, LI_MSLEN[ numf ], LI_MSDEC[ numf ] ), LI_MSLEN[ numf ] )
            ELSEIF LI_MSTYP[ numf ] == "D"
               RETURN PadR( DToC( vartmp ), LI_MSLEN[ numf ] )
            ELSEIF LI_MSTYP[ numf ] == "L"
               RETURN PadR( iif( vartmp, "T", "F" ), LI_MSLEN[ numf ] )
            ENDIF
         ELSEIF fldtype == "C"
            numf := FieldPos( vartmp )
         ENDIF
      ENDIF
   ENDIF
   // fldtype := FIELDTYPE( numf )
   fldtype := LI_MSTYP[ numf ]
   DO CASE
   CASE fldtype == "C"
      rez := FieldGet( numf )
   CASE fldtype == "N"
      // rez := STR( FIELDGET( numf ), FIELDSIZE( numf ), FIELDDECI( numf ) )
      rez := Str( FieldGet( numf ), LI_MSLEN[ numf ], LI_MSDEC[ numf ] )
   CASE fldtype == "D"
      rez := DToC( FieldGet( numf ) )
   CASE fldtype == "L"
      rez := iif( FieldGet( numf ), "T", "F" )
   CASE fldtype == "M"
      rez := "  <Memo>  "
   ENDCASE
   IF LI_BDESHIN != Nil
      rez := Eval( LI_BDESHIN, mslist, rez )
   ENDIF

   RETURN rez

//+--------------------------------------------------------------------
//+
//+    Function GetBuf()
//+
//+    Called from ( db_brows.prg )   1 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION GetBuf

   LOCAL srez := ""

   DO WHILE NextKey() != 0
      srez += Chr( Inkey( 0 ) )
   ENDDO

   RETURN srez

//+--------------------------------------------------------------------
//+
//+    Function InitList()
//+
//+    Called from ( db_brows.prg )   1 - PROCEDURE Main()
//+                                   1 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION InitList

   LOCAL mslist := Array( LI_LEN )

   LI_NSTR    := LI_MSED := 1
   LI_CLR     := "W+/B"
   LI_CLRV    := "R/W"
   LI_BSKIP   := { | a, x | HB_SYMBOL_UNUSED( a ), dbSkip( x ) }
   LI_BGTOP   := { || DBGOTOP() }
   LI_BGBOT   := { || dbGoBottom() }
   LI_BEOF    := { || Eof() }
   LI_BBOF    := { || Bof() }
   LI_B1      := { | a | HB_SYMBOL_UNUSED( a ), DevPos( LI_Y2, LI_X1 + 2 ), DevOut( Str( RecNo(), 6 ) + "/" + Str( LI_KOLZ, 6 ) ) }
   LI_FREEZE  := 0
   LI_RCOU    := { || RecCount() }
   LI_RECNO   := { || RecNo() }
   LI_BGOTO   := { | a, n | HB_SYMBOL_UNUSED( a ), dbGoto( n ) }
   LI_PRFLT   := LI_LVIEW := .F.
   LI_LSOHR   := .T.
   LI_BDESHIN := LI_BDESHOUT := LI_MSF := LI_MSTYP := LI_NAMES := Nil
   LI_TEKZP   := 1

   RETURN mslist

//+--------------------------------------------------------------------
//+
//+    Function Defpict()
//+
//+    Called from ( db_brows.prg )   1 - function dbflist()
//+
//+--------------------------------------------------------------------
//+

FUNCTION Defpict( mslist, i, maxlen )

   // LOCAL spict, fldd, fldtype := FIELDTYPE( i ), fldlen := FIELDSIZE( i )
   LOCAL spict, fldd, fldtype := LI_MSTYP[ i ], fldlen := LI_MSLEN[ i ]
   DO CASE
   CASE fldtype == "C"
      spict := iif( maxlen == Nil, Replicate( "X", fldlen ), "@S" + NUM_STR( maxlen, 2 ) )
   CASE fldtype == "N"
      fldd  := LI_MSDEC[ i ]
      spict := iif( fldd == 0, Replicate( "9", fldlen ), Replicate( "9", fldlen - 1 - fldd ) + "." + Replicate( "9", fldd ) )
   CASE fldtype == "D"
      spict := "@D"
   ENDCASE

   RETURN spict

//+--------------------------------------------------------------------
//+
//+    Function NUM_STR()
//+
//+    Called from ( db_brows.prg )   1 - function defpict()
//+
//+--------------------------------------------------------------------
//+

FUNCTION NUM_STR( NOM, KOLZN )

   NOM := Int( NOM )

   RETURN Replicate( "0", KOLZN - Len( LTrim( Str( NOM ) ) ) ) + LTrim( Str( NOM ) )
