/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
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

/*
 * The following parts are Copyright of the individual authors.
 * www - http://www.harbour-project.org
 *
 * Copyright 2010 Viktor Szakats (harbour.01 syenar.hu)
 *    hbide_PathProc()
 *
 * See COPYING for licensing terms.
 *
 */

/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*
 *                                EkOnkar
 *                          ( The LORD is ONE )
 *
 *                            Harbour-Qt IDE
 *
 *                  Pritpal Bedi <pritpal@vouchcac.com>
 *                               23Nov2009
 */
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/

#include "common.ch"
#include "fileio.ch"

#include "xbp.ch"

#include "hbide.ch"

STATIC aRegList

/*----------------------------------------------------------------------*/

PROCEDURE AppSys()
   RETURN

/*----------------------------------------------------------------------*/

PROCEDURE hbide_justACall()
   RETURN

/*----------------------------------------------------------------------*/

FUNCTION hbide_execPopup( aPops, aPos, qParent )
   LOCAL i, qPop, qPoint, qAct, cAct, xRet, pAct, a_

   qPop := QMenu():new( iif( hb_isObject( qParent ), qParent, NIL ) )

   FOR i := 1 TO len( aPops )
      IF empty( aPops[ i,1 ] )
         qPop:addSeparator()
      ELSE
         IF hb_isObject( aPops[ i, 1 ] )
            qPop:addAction_4( aPops[ i, 1 ] )
         ELSE
            qPop:addAction( aPops[ i, 1 ] )
         ENDIF
      ENDIF
   NEXT

   qPoint := QPoint():new( aPos[ 1 ], aPos[ 2 ] )
   pAct   := qPop:exec_1( qPoint )
   IF !hbqt_isEmptyQtPointer( pAct )
      qAct := QAction():configure( pAct )
      cAct := qAct:text()
      FOR EACH a_ IN aPops
         IF hb_isObject( a_[ 1 ] )
            IF a_[ 1 ]:text() == cAct
               xRet := eval( aPops[ a_:__enumIndex(), 2 ] )
               EXIT
            ENDIF
         ELSE
            IF a_[ 1 ] == cAct
               xRet := eval( aPops[ a_:__enumIndex(), 2 ] )
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF

   qPop:pPtr := 0

   RETURN xRet

/*----------------------------------------------------------------------*/

FUNCTION hbide_menuAddSep( oMenu )

   oMenu:addItem( { NIL, NIL, XBPMENUBAR_MIS_SEPARATOR, NIL } )

   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION hbide_createTarget( cFile, txt_ )
   LOCAL hHandle := fcreate( cFile )
   LOCAL cNewLine := hb_OsNewLine()

   IF hHandle != F_ERROR
      aeval( txt_, { |e| fWrite( hHandle, e + cNewLine ) } )
      fClose( hHandle )
   ENDIF

   RETURN hb_FileExists( cFile )

/*----------------------------------------------------------------------*/

FUNCTION hbide_posAndSize( qWidget )

   RETURN hb_ntos( qWidget:x() )     + "," + hb_ntos( qWidget:y() )      + "," + ;
          hb_ntos( qWidget:width() ) + "," + hb_ntos( qWidget:height() ) + ","

/*----------------------------------------------------------------------*/

FUNCTION hbide_showWarning( cMsg, cInfo, cTitle )
   LOCAL oMB

   DEFAULT cTitle TO "Information"

   oMB := QMessageBox():new()
   oMB:setText( cMsg )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Critical )
   oMB:setParent( SetAppWindow():pWidget )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setWindowTitle( cTitle )

   RETURN oMB:exec()

/*----------------------------------------------------------------------*/

FUNCTION hbide_getYesNo( cMsg, cInfo, cTitle )
   LOCAL oMB

   DEFAULT cTitle TO "Option Please!"

   oMB := QMessageBox():new()
   oMB:setText( "<b>"+ cMsg +"</b>" )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Information )
   oMB:setParent( SetAppWindow():pWidget )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setWindowTitle( cTitle )
   oMB:setStandardButtons( QMessageBox_Yes + QMessageBox_No )

   RETURN ( oMB:exec() == QMessageBox_Yes )

/*----------------------------------------------------------------------*/

FUNCTION hbide_getYesNoCancel( cMsg, cInfo, cTitle )
   LOCAL oMB

   DEFAULT cTitle TO "Option Please!"

   oMB := QMessageBox():new()
   oMB:setText( "<b>"+ cMsg +"</b>" )
   IF !empty( cInfo )
      oMB:setInformativeText( cInfo )
   ENDIF
   oMB:setIcon( QMessageBox_Information )
   oMB:setParent( SetAppWindow():pWidget )
   oMB:setWindowFlags( Qt_Dialog )
   oMB:setWindowTitle( cTitle )
   oMB:setStandardButtons( QMessageBox_Yes + QMessageBox_No + QMessageBox_Cancel )

   RETURN oMB:exec()

/*----------------------------------------------------------------------*/

FUNCTION hbide_fetchAFile( oWnd, cTitle, aFlt, cDftDir, cDftSuffix )
   LOCAL oDlg, cFile

   DEFAULT cTitle  TO "Please Select a File"
   DEFAULT aFlt    TO { { "All Files", "*.*" } }
   DEFAULT cDftDir TO hb_dirBase()

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title       := cTitle
   oDlg:center      := .t.
   oDlg:fileFilters := aFlt
   IF hb_isChar( cDftSuffix )
      oDlg:oWidget:setDefaultSuffix( cDftSuffix )
   ENDIF

   cFile := oDlg:open( cDftDir, , .f. )

   RETURN cFile

/*----------------------------------------------------------------------*/

FUNCTION hbide_saveAFile( oWnd, cTitle, aFlt, cDftFile, cDftSuffix )
   LOCAL oDlg, cFile

   DEFAULT cTitle  TO "Please Select a File"

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title       := cTitle
   oDlg:center      := .t.
   oDlg:fileFilters := aFlt
   IF hb_isChar( cDftSuffix )
      oDlg:oWidget:setDefaultSuffix( cDftSuffix )
   ENDIF

   cFile := oDlg:saveAs( cDftFile, .f., .t. )

   RETURN cFile

/*----------------------------------------------------------------------*/
/* Function to user select a existing folder
 * 25/12/2009 - 19:10:41 - vailtom
 */
FUNCTION hbide_fetchADir( oWnd, cTitle, cDftDir )
   LOCAL oDlg, cFile

   DEFAULT cTitle  TO "Please Select a Folder"
   DEFAULT cDftDir TO hb_dirBase()

   oDlg := XbpFileDialog():new():create( oWnd, , { 10,10 } )

   oDlg:title  := cTitle
   oDlg:center := .t.
   oDlg:oWidget:setFileMode( 4 )

   cFile := oDlg:open( cDftDir, , .f. )

   IF hb_isChar( cFile )
      //cFile := strtran( cFile, "/", HB_OSPATHSEPARATOR() )
      RETURN cFile
   ENDIF

   RETURN ""

/*----------------------------------------------------------------------*/

FUNCTION hbide_readSource( cTxtFile )
   LOCAL cFileBody := hb_MemoRead( cTxtFile )

   HB_TRACE( HB_TR_DEBUG, cFileBody )

   cFileBody := StrTran( cFileBody, Chr( 13 ) )

   RETURN hb_ATokens( cFileBody, Chr( 10 ) )

/*----------------------------------------------------------------------*/

FUNCTION hbide_evalAsString( cExp )
   LOCAL cValue

   BEGIN SEQUENCE WITH { || break() }
      cValue := eval( &( "{|| " + cExp + "}" ) )
   RECOVER
      cValue := cExp
   END SEQUENCE

   IF !hb_isChar( cValue )
      cValue := ""
   ENDIF

   RETURN cValue

/*----------------------------------------------------------------------*/

FUNCTION hbide_fetchHbiStructFromBuffer( cBuffer )
   RETURN hbide_pullHbiStruct( hb_atokens( cBuffer, _EOL ) )

/*----------------------------------------------------------------------*/

FUNCTION hbide_fetchHbiStructFromFile( cProject )
   RETURN hbide_pullHbiStruct( hbide_readSource( cProject ) )

/*----------------------------------------------------------------------*/

STATIC FUNCTION hbide_pullHbiStruct( a_ )
   LOCAL n, s, nPart, cKey, cVal, ss
   LOCAL aPrp := { "Type", "Title", "Location", "WorkingFolder", "DestinationFolder", ;
                                            "Output", "LaunchParams", "LaunchProgram" }

   LOCAL a1_0 := afill( array( PRJ_PRP_PRP_VRBLS ), "" )
   LOCAL a1_1 := {}
   local a2_0 := {}
   local a2_1 := {}
   local a3_0 := {}
   local a3_1 := {}
   local a4_0 := {}
   local a4_1 := {}

   IF .t.
      FOR EACH ss IN a_
         s := alltrim( ss )

         IF !empty( s )
            DO CASE
            CASE s == "[ PROPERTIES ]"
               nPart := PRJ_PRP_PROPERTIES
            CASE s == "[ FLAGS ]"
               nPart := PRJ_PRP_FLAGS
            CASE s == "[ SOURCES ]"
               nPart := PRJ_PRP_SOURCES
            CASE s == "[ METADATA ]"
               nPart := PRJ_PRP_METADATA
            OTHERWISE
               DO CASE
               CASE nPart == PRJ_PRP_PROPERTIES
                  IF ( n := at( "=", s ) ) > 0
                     cKey := alltrim( substr( s, 1, n-1 ) )
                     cVal := alltrim( substr( s, n+1 ) )
                     IF ( n := ascan( aPrp, cKey ) ) > 0
                        a1_0[ n ] := cVal
                     ENDIF
                  ENDIF
               CASE nPart == PRJ_PRP_FLAGS
                  aadd( a2_0, s )

               CASE nPart == PRJ_PRP_SOURCES
                  aadd( a3_0, s )

               CASE nPart == PRJ_PRP_METADATA
                  aadd( a4_0, s )
                  IF !( "#" == left( s,1 ) )
                     IF ( n := at( "=", s ) ) > 0
                        cKey := alltrim( substr( s, 1, n-1 ) )
                        cVal := hbide_evalAsString( alltrim( substr( s, n+1 ) ) )
                        aadd( a4_1, { "<"+ cKey +">", cVal } )
                     ENDIF
                  ENDIF
               ENDCASE
            ENDCASE
         ENDIF
      NEXT

      /* General Properties */
      FOR EACH s IN a1_0
         aadd( a1_1, hbide_parseWithMetaData( s, a4_1 ) )
      NEXT

      /* Parse Flags */
      IF !empty( a2_0 )
         FOR EACH s IN a2_0
            aadd( a2_1, hbide_parseWithMetaData( s, a4_1 ) )
         NEXT
      ENDIF

      /* Parse Files */
      IF !empty( a3_0 )
         FOR EACH s IN a3_0
            IF !( "#" == left( s,1 ) ) .and. !empty( s )
               aadd( a3_1, hbide_parseWithMetaData( s, a4_1 ) )
            ENDIF
         NEXT
      ENDIF

   ENDIF

   RETURN { { a1_0, a1_1 }, { a2_0, a2_1 }, { a3_0, a3_1 }, { a4_0, a4_1 } }

/*----------------------------------------------------------------------*/

FUNCTION hbide_setupMetaKeys( a_ )
   LOCAL s, n, cKey, cVal
   LOCAL a4_1 := {}

   FOR EACH s IN a_
      IF !( "#" == left( s,1 ) )
         IF ( n := at( "=", s ) ) > 0
            cKey := alltrim( substr( s, 1, n-1 ) )
            cVal := hbide_evalAsString( alltrim( substr( s, n+1 ) ) )
            aadd( a4_1, { "<"+ cKey +">", cVal } )
         ENDIF
      ENDIF
   NEXT

   RETURN a4_1

/*----------------------------------------------------------------------*/

FUNCTION hbide_applyMetaData( s, a_ )
   LOCAL k

   IF ! Empty( a_ )
      FOR EACH k IN a_
         s := StrTran( s, hbide_pathNormalized( k[ 2 ], .f. ), k[ 1 ] )
      NEXT
   ENDIF

   RETURN s

/*----------------------------------------------------------------------*/

FUNCTION hbide_parseWithMetaData( s, a_ )
   LOCAL k

   IF ! Empty( a_ )
      FOR EACH k IN a_ DESCEND
         s := StrTran( s, k[ 1 ], k[ 2 ] )
      NEXT
   ENDIF

   RETURN s

/*----------------------------------------------------------------------*/

FUNCTION hbide_arrayToMemo( a_ )
   LOCAL s := ""

   aeval( a_, {|e| s += e + CRLF } )

   s += CRLF

   RETURN s

/*----------------------------------------------------------------------*/

FUNCTION hbide_memoToArray( s )
   LOCAL aLine := hb_ATokens( StrTran( RTrim( s ), CRLF, _EOL ), _EOL )
   LOCAL nNewSize := 0
   LOCAL line

   FOR EACH line IN aLine DESCEND
      IF ! Empty( line )
         nNewSize := line:__enumIndex()
         EXIT
      ENDIF
   NEXT

   ASize( aLine, nNewSize )

   RETURN aLine

/*----------------------------------------------------------------------*/

FUNCTION hbide_isValidPath( cPath, cPathDescr )

   DEFAULT cPathDescr TO ''

   IF hb_dirExists( cPath )
      RETURN .T.
   ENDIF

   IF empty( cPathDescr )
      MsgBox( 'The specified path is invalid "' + cPath + '"' )
   ELSE
      //MsgBox( 'The specified path is invalid for ' + cPathDescr + ': "' + cPath + '"' )
      MsgBox( 'The specified path is invalid for : "' + cPath + '"', cPathDescr )
   ENDIF
   RETURN .F.

/*----------------------------------------------------------------------*/

FUNCTION hbide_isValidText( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )

   RETURN ( lower( cExt ) $ ".c,.cpp,.prg,.h,.ch,.txt,.log,.ini,.env,.ppo," + ;
                                     ".cc,.hbc,.hbp,.hbm,.xml,.bat,.sh,.rc,.ui,.bak" )

/*----------------------------------------------------------------------*/

FUNCTION hbide_isValidSource( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )

   RETURN ( lower( cExt ) $ ".c,.cpp,.prg,.res,.rc" )

/*----------------------------------------------------------------------*/

FUNCTION hbide_isSourcePPO( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )

   RETURN ( lower( cExt ) == ".ppo" )

/*----------------------------------------------------------------------*/

FUNCTION hbide_isSourcePRG( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )

   RETURN ( lower( cExt ) == ".prg" )

/*----------------------------------------------------------------------*/

FUNCTION hbide_sourceType( cSourceFile )
   LOCAL cExt

   hb_fNameSplit( cSourceFile, , , @cExt )

   RETURN lower( cExt )

/*----------------------------------------------------------------------*/

FUNCTION hbide_pathNormalized( cPath, lLower )
   LOCAL S

   DEFAULT lLower TO .T.

   s := strtran( cPath, "\", "/" )

   RETURN IIF( lLower, lower( s ), s )

/*----------------------------------------------------------------------*/

FUNCTION hbide_pathToOSPath( cPath )

   cPath := strtran( cPath, "/" , hb_osPathSeparator() )
   cPath := strtran( cPath, "\" , hb_osPathSeparator() )

   RETURN cPath

/*----------------------------------------------------------------------*/
/*
 * This function fills an array with the list of regular expressions that will
 * identify the errors messages retrieved from during the build process.
 * 29/12/2009 - 12:43:26 - vailtom
 */
#define MSG_TYPE_ERR    1
#define MSG_TYPE_INFO   2
#define MSG_TYPE_WARN   3

#define CLR_MSG_ERR     'red'
#define CLR_MSG_INFO    'brown'
#define CLR_MSG_WARN    'blue'

STATIC FUNCTION hbide_buildRegExpressList( aRegList )

   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".*: warning.*"                 ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( ".*\) Warning W.*"              ) } )
   AAdd( aRegList, { MSG_TYPE_WARN, hb_RegexComp( "^Warning W([0-9]+).*"          ) } )

   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*: error.*"                   ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*\) Error E.*"                ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( "^Error E([0-9]+).*"            ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( "^Error: ."                     ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*:([0-9]+):([\w|\s]*)error.*" ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*:\(\.\w+\+.*\):.*"           ) } )
   AAdd( aRegList, { MSG_TYPE_ERR , hb_RegexComp( ".*: fatal\s.*"                 ) } )

   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( ".*: note.*"                    ) } )
   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( ".*: In function '.*"           ) } )
   AAdd( aRegList, { MSG_TYPE_INFO, hb_RegexComp( "^(\s*).*\s: see.*"             ) } )

   RETURN aRegList

/*----------------------------------------------------------------------*//*
* Catch source file name & line error from an msg status from compiler result.
 * 29/12/2009 - 13:22:29 - vailtom
 */
FUNCTION hbide_parseFNfromStatusMsg( cText, cFileName, nLine, lValidText )
   LOCAL regLineN := hb_RegexComp( ".*(\(([0-9]+)\)|:([0-9]+):|\s([0-9]+):).*" )
   LOCAL aList
   LOCAL nPos

   DEFAULT lValidText TO .T.

   cFileName := ''
   nLine     := 0

 * Validate if current text is a error/warning/info message.
 * 29/12/2009 - 22:51:39 - vailtom
   IF lValidText
      nPos := aScan( aRegList, {| reg | !Empty( hb_RegEx( reg[ 2 ], cText ) ) } )

      IF ( nPos <= 0 )
         RETURN .F.
      ENDIF
   ENDIF

   aList     := hb_RegEx( regLineN, cText )

   IF !Empty(aList)
      nLine := alltrim( aList[2] )
      cText := Substr( cText, 1, At( nLine, cText ) -1 )
      cText := alltrim( cText ) + '('

      nLine := strtran( nLine, ":", "" )
      nLine := strtran( nLine, "(", "" )
      nLine := strtran( nLine, ")", "" )
      nLine := VAL( alltrim( nLine ) )
   ENDIF

   IF (nPos := hb_At( '(', cText )) > 0
      cFileName := alltrim( Subst( cText, 1, nPos -1 ) )
   ELSE
      IF (nPos := At( 'referenced from', Lower( cText ) )) <> 00
         cFileName := Subst( cText, nPos + Len( 'referenced from' ) )
      ELSE
       * GCC & MSVC filename detect...
         IF Subst( cText, 2, 1 ) == ':'
            nPos := hb_At( ':', cText, 3 )
         ELSE
            nPos := hb_At( ':', cText )
         ENDIF
         IF nPos <> 00
            cFileName := Subst( cText, 1, nPos-1 )
         ENDIF
      ENDIF
   ENDIF

   cFileName := strtran( cFileName, "(", "" )
   cFileName := strtran( cFileName, ")", "" )
   cFileName := alltrim( cFileName )

   cFileName := strtran( cFileName, "\\", "/" )        && Fix for the BCC
   cFileName := strtran( cFileName, "\" , "/" )

   IF (nPos := Rat( ' ', cFileName )) <> 00
      cFileName := Subst( cFileName, nPos+1 )
   ENDIF

   IF Subst( cFileName, 2, 1 ) == ':'
      nPos := hb_At( ':', cFileName, 3 )
   ELSE
      nPos := hb_At( ':', cFileName )
   ENDIF

   IF nPos <> 00
      cFileName := Subst( cFileName, 1, nPos-1 )
   ENDIF

   cFileName := alltrim( cFileName )
   RETURN !Empty( cFileName )

/*----------------------------------------------------------------------*/
/*
 * This function parses compiler result and hightlight errors & warnings using
 * regular expressions. (vailtom)
 *
 * More about Qt Color names:
 *  http://www.w3.org/TR/SVG/types.html#ColorKeywords
 *
 * 28/12/2009 - 16:17:37
 */
FUNCTION hbide_convertBuildStatusMsgToHtml( cText, oWidget )
   LOCAL aColors  := { CLR_MSG_ERR, CLR_MSG_INFO, CLR_MSG_WARN }
   LOCAL aLines
   LOCAL cLine
   LOCAL nPos

   IF aRegList == NIL
      aRegList := {}
      hbide_BuildRegExpressList( aRegList )
   ENDIF

   cText := StrTran( cText, Chr( 13 ) + Chr( 10 ), Chr( 10 ) )
   cText := StrTran( cText, Chr( 13 )            , Chr( 10 ) )
   cText := StrTran( cText, Chr( 10 ) + Chr( 10 ), Chr( 10 ) )

   /* Convert some chars to valid HTML chars */
   DO WHILE "<" $ cText
      cText := StrTran( cText, "<", "&lt;" )
   ENDDO
   DO WHILE ">" $ cText
      cText := StrTran( cText, ">", "&gt;" )
   ENDDO
   aLines := hb_aTokens( cText, Chr( 10 ) )

   FOR EACH cLine IN aLines

      IF !Empty( cLine )
         IF ( nPos := aScan( aRegList, {| reg | !Empty( hb_RegEx( reg[ 2 ], cLine ) ) } ) ) > 0
            cLine := '<font color=' + aColors[ aRegList[nPos,1] ] + '>' + cLine + '</font>'
         ELSE
            cLine := "<font color = black>" + cLine + "</font>"
         ENDIF
      ENDIF

      oWidget:append( cLine )
   NEXT

   RETURN cText

/*----------------------------------------------------------------------*/

FUNCTION hbide_filesToSources( aFiles )
   LOCAL aSrc := {}
   LOCAL s

   FOR EACH s IN aFiles
      IF hbide_isValidSource( s )
         aadd( aSrc, s )
      ENDIF
   NEXT

   RETURN aSrc

/*----------------------------------------------------------------------*/

FUNCTION hbide_parseKeyValPair( s, cKey, cVal )
   LOCAL n, lYes := .f.

   IF ( n := at( "=", s ) ) > 0
      cKey := alltrim( substr( s, 1, n - 1 ) )
      cVal := alltrim( substr( s, n + 1 ) )
      lYes := ( !empty( cKey ) .and. !empty( cVal ) )
   ENDIF

   RETURN ( lYes )

/*----------------------------------------------------------------------*/

FUNCTION hbide_dbg( ... )
   HB_TRACE( HB_TR_ALWAYS, procname(1),... )
   RETURN nil

/*----------------------------------------------------------------------*/
/*
 * Return the next untitled filename available.
 * 01/01/2010 - 19:40:17 - vailtom
 */
FUNCTION hbide_getNextUntitled()
   STATIC s_nCount := 0
   RETURN ++s_nCount

/*----------------------------------------------------------------------*/
/*
 * Return the next TAB_ID or IDE_ID available.
 * 02/01/2010 - 10:47:16 - vailtom
 */
FUNCTION hbide_getNextUniqueID()
   STATIC s_nCount := 0

   IF s_nCount > 4294967295
      s_nCount := 0
   ENDIF
   RETURN ++s_nCount

/*----------------------------------------------------------------------*/
/*
 * Check if cFilename has a extension... and add cDefaultExt if not exist.
 * 01/01/2010 - 20:48:10 - vailtom
 */
FUNCTION hbide_checkDefaultExtension( cFileName, cDefaultExt )
   LOCAL cPath, cFile, cExt
   hb_fNameSplit( cFileName, @cPath, @cFile, @cExt )
   IF Empty( cExt )
      cExt := cDefaultExt
   ENDIF
   RETURN cPath + HB_OSPATHSEPARATOR() + cFile + HB_OSPATHSEPARATOR() + cExt

/*----------------------------------------------------------------------*/

FUNCTION hbide_pathProc( cPathR, cPathA )
   LOCAL cDirA
   LOCAL cDirR, cDriveR, cNameR, cExtR

   IF Empty( cPathA )
      RETURN cPathR
   ENDIF

   hb_FNameSplit( cPathR, @cDirR, @cNameR, @cExtR, @cDriveR )

   IF ! Empty( cDriveR ) .OR. ( ! Empty( cDirR ) .AND. Left( cDirR, 1 ) $ hb_osPathDelimiters() )
      RETURN cPathR
   ENDIF

   hb_FNameSplit( cPathA, @cDirA )

   IF Empty( cDirA )
      RETURN cPathR
   ENDIF

   RETURN hb_FNameMerge( cDirA + cDirR, cNameR, cExtR )

/*----------------------------------------------------------------------*/

function hbide_toString( x, lLineFeed, lInherited, lType, cFile, lForceLineFeed )
   LOCAL s := ''
   LOCAL t := valtype( x )
   LOCAL i, j

   DEFAULT lLineFeed      TO .T.
   DEFAULT lInherited     TO .F.
   DEFAULT lType          TO .F.
   DEFAULT cFile          TO ""
   DEFAULT lForceLineFeed TO .F.

   DO CASE
   CASE ( t == "C" )
      s := iif( lType, "[C]=", "" ) + '"' + x + '"'
   CASE ( t == "N" )
      s := iif( lType, "[N]=", "" ) + alltrim(str( x ))
   CASE ( t == "D" )
      s := iif( lType, "[D]=", "" ) + "ctod('"+ dtoc(x) +"')"
   CASE ( t == "L" )
      s := iif( lType, "[L]=", "" ) + iif( x, '.T.', '.F.' )
   CASE ( t == "M" )
      s := iif( lType, "[M]=", "" ) + '"' + x + '"'
   CASE ( t == "B" )
      s := iif( lType, "[B]=", "" ) + '{|| ... }'
   CASE ( t == "U" )
      s := iif( lType, "[U]=", "" ) + 'NIL'
   CASE ( t == "A" )
      s := iif( lType, "[A]=", "" ) + "{"
      IF len( x ) = 0
         s += " "
      ELSE
         s += iif( valtype( x[1] ) = "A" .or. lForceLineFeed, CRLF, "" )
         j := len( x )

         FOR i := 1 TO j
             s += iif( valtype( x[i] ) == "A", "  ", " " ) + iif( lForceLineFeed, " ", "" ) + hbide_toString( x[i], .F. )
             s += iif( i <> j, ",", "" )
             IF lLineFeed
                IF !lInherited .and. ( valtype( x[i] ) == "A" .or. lForceLineFeed )
                   s += CRLF
                ENDIF
             ENDIF
         NEXT
      ENDIF
      s += iif( !lForceLineFeed, " ", "" ) + "}"

   CASE ( t == "O" )
      IF lInherited
         && � necess�rio linkar \harbour\lib\xhb.lib
         **s := iif( lType, "[O]=", "" ) + hb_dumpvar( x ) + iif( lLineFeed, CRLF, "" )
         s := '' + iif( lLineFeed, CRLF, "" )
      ELSE
         s := iif( lType, "[O]=", "" ) + x:ClassName()+'():New()' + iif( lLineFeed, CRLF, "" )
      ENDIF
   ENDCASE

   IF !empty( cFile )
      memowrit( cFile, s )
   ENDIF

   RETURN s

/*----------------------------------------------------------------------*/

FUNCTION hbide_help( nOption )
   LOCAL txt_  := {}
   LOCAL tit_  := ''

   SWITCH nOption
   CASE 1
      tit_ := 'About hbIde'
      AAdd( txt_, "<b>Harbour IDE ( hbIDE )</b>" )
      AAdd( txt_, "Developed by" )
      AAdd( txt_, "Pritpal Bedi ( pritpal@vouchcac.com )" )
      AAdd( txt_, "" )
      AAdd( txt_, "built with:" )
      AAdd( txt_, HB_VERSION() )
      AAdd( txt_, HB_COMPILER() )
      AAdd( txt_, "Qt " + QT_VERSION_STR() )
      AAdd( txt_, "" )
      AAdd( txt_, "Visit the project website at:" )
      AAdd( txt_, "<a href='http://www.harbour-project.org/'>http://www.harbour-project.org/</a>" )
      EXIT

   CASE 2
      tit_ := 'Mailing List'
      AAdd( txt_, "<b>Harbour Developers Mailing List</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, "Please visit the home page:" )
      AAdd( txt_, "<a href='http://lists.harbour-project.org/pipermail/harbour/'>http://lists.harbour-project.org/pipermail/harbour/</a>" )
      EXIT

   CASE 3
      tit_ := 'Mailing List'
      AAdd( txt_, "<b>Harbour Users Mailing List</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, "Please visit the home page:" )
      AAdd( txt_, "<a href='http://lists.harbour-project.org/pipermail/harbour/'>http://lists.harbour-project.org/pipermail/harbour/</a>" )
      EXIT

   CASE 4
      tit_ := 'About Harbour'
      AAdd( txt_, "<b>About Harbour</b>" )
      AAdd( txt_, "" )
      AAdd( txt_, '"The Harbour Project is a Free Open Source Software effort to build' )
      AAdd( txt_, 'a multiplatform Clipper language compiler. Harbour consists of the' )
      AAdd( txt_, 'xBase language compiler and the runtime libraries with different' )
      AAdd( txt_, 'terminal plugins and different databases (not just DBF)"' )
      AAdd( txt_, "" )
      AAdd( txt_, "Get downloads, samples, contribs and much more at:" )
      AAdd( txt_, "<a href='http://www.harbour-project.org/'>http://www.harbour-project.org/</a>" )
      EXIT

   END

   IF !Empty( txt_ )
      MsgBox( hbide_arrayToMemo( txt_ ), tit_ )
   ENDIF

   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION hbide_getUniqueFuncName()
   LOCAL t, b, c, n

   t := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
   n := len( t )
   b := ''
   WHILE Len( b ) <> 10
      c := Substr( t, HB_RANDOMINT( 1, n ), 1 )

      IF !( c $ b )
         IF Empty( b ) .AND. IsDigit( c )
            LOOP
         ENDIF
         b += c
      ENDIF
   End
   b += '( '

   RETURN b

/*----------------------------------------------------------------------*/

FUNCTION hbide_findProjTreeItem( oIde, cNodeText, cType )
   LOCAL oItem, a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == cType .AND. a_[ TRE_OITEM ]:caption == cNodeText
         oItem := a_[ TRE_OITEM ]
         EXIT
      ENDIF
   NEXT
   RETURN oItem

/*----------------------------------------------------------------------*/

FUNCTION hbide_expandChildren( oIde, oItem )
   LOCAL a_

   oItem:expand( .t. )
   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_OPARENT ] == oItem
         a_[ TRE_OITEM ]:expand( .t. )
      ENDIF
   NEXT

   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION hbide_collapseProjects( oIde )
   LOCAL a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == "Project Name"
         a_[ TRE_OITEM ]:expand( .f. )
      ENDIF
   NEXT

   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION hbide_expandProjects( oIde )
   LOCAL a_

   FOR EACH a_ IN oIde:aProjData
      IF a_[ TRE_TYPE ] == "Project Name"
         hbide_expandChildren( oIde, a_[ TRE_OITEM ] )
      ENDIF
   NEXT

   RETURN nil

/*----------------------------------------------------------------------*/

FUNCTION hbide_buildLinesLabel( nFrom, nTo, nW, nMax )
   LOCAL n, i, s := ""

   n := min( nMax, nTo - nFrom  )

   FOR i := 0 TO n
      IF ( ( nFrom + i ) % 10 ) == 0
         s += "<font color = red>" + padl( hb_ntos( nFrom + i ), nW ) + "</font><br>"
      ELSE
         //s += padl( hb_ntos( nFrom + i ), nW ) + CRLF
         s += padl( hb_ntos( nFrom + i ), nW ) + "<br>"
      ENDIF
   NEXT

   RETURN s

/*----------------------------------------------------------------------*/
