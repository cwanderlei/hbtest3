/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Editor Class (base for Memoedit(), debugger, etc.)
 *
 * Copyright 2000 Maurilio Longo <maurilio.longo@libero.it>
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


#include "common.ch"
#include "hbclass.ch"
#include "error.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "color.ch"

CLASS HBEditor

   DATA  cFile          INIT ""     // name of file being edited

   DATA  aText          INIT {}     // array with lines of text being edited
   DATA  naTextLen      INIT 0      // number of lines of text inside aText.

   DATA  nTop                       // boundaries of editor window, without box around
   DATA  nLeft
   DATA  nBottom
   DATA  nRight

   DATA  nFirstCol      INIT 1      // FirstCol/Row of current text visible inside editor window
   DATA  nFirstRow      INIT 1
   DATA  nRow           INIT 1      // Cursor position inside aText (nRow) and inside current line of text (nCol)
   DATA  nCol           INIT 1

   DATA  nPhysRow       INIT 0      // Hardware cursor position, I cannot rely on Row()/Col() because I could be inside another
   DATA  nPhysCol       INIT 0      // application/object and this one could be moving real cursor. If I'm running full
                                    // screen nPhysRow will always have the same value as Row() and nPhysCol as Col()

   DATA  nNumCols       INIT 1      // How many columns / rows can be displayed inside editor window
   DATA  nNumRows       INIT 1

   DATA  lInsert        INIT .F.    // Is editor in Insert mode or in Overstrike one?
   DATA  nTabWidth      INIT 8      // Size of Tab chars
   DATA  lEditAllow     INIT .T.    // Are changes to text allowed?
   DATA  lSaved         INIT .F.    // True if user exited editor with K_CTRL_W
   DATA  lWordWrap      INIT .F.    // True if word wrapping is active
   DATA  nWordWrapCol   INIT 0      // At which column word wrapping occurs
   DATA  lDirty                     // .T. if there are changes not saved
   DATA  lExitEdit      INIT .F.    // .T. if user requested to end Edit() method

   DATA  cColorSpec     INIT SetColor()     // Color string used for screen writes


   METHOD New(cString, nTop, nLeft, nBottom,;            // Converts a string to an array of strings splitting input string at EOL boundaries
              nRight, lEditMode, nLineLength, nTabSize)

   METHOD LoadFile(cFileName)                            // Load cFileName into active editor
   METHOD LoadText(cString)                              // Load cString into active editor
   METHOD SaveFile()                                     // Save active file (not for MemoEdit() emulation)

   METHOD AddLine(cLine, lSoftCR)                        // Add a new Line of text at end of current text
   METHOD InsertLine(cLine, lSoftCR, nRow)               // Insert a line of text at a defined row
   METHOD RemoveLine(nRow)                               // Remove a line of text
   METHOD GetLine(nRow)                                  // Return line n of text
   METHOD LineLen(nRow) INLINE Len(::aText[nRow]:cText)  // Return text length of line n
   METHOD SplitLine(nRow)                                // If a line of text is longer than nWordWrapCol divides it into multiple lines
   METHOD GotoLine(nRow)                                 // Put line nRow at cursor position

   METHOD GetText()                                      // Returns aText as a string (for MemoEdit())

   METHOD RefreshWindow()                                // Redraw a window
   METHOD RefreshLine()                                  // Redraw a line
   METHOD RefreshColumn()                                // Redraw a column of text
   METHOD LineColor(nRow) INLINE ::cColorSpec            // Returns color string to use to draw nRow (current line if nRow is empty)

   METHOD MoveCursor(nKey)                               // Move cursor inside text / window (needs a movement key)
   METHOD InsertState(lInsState)                         // Changes lInsert value and insertion / overstrike mode of editor
   METHOD Edit(nPassedKey)                               // Handles input (can receive a key in which case handles only this key and then exits)

   METHOD KeyboardHook(nKey)                             // Gets called every time there is a key not handled directly by HBEditor
   METHOD IdleHook()                                     // Gets called every time there are no more keys to hanlde just before HBEditor blocks itself waiting for a char

   METHOD Resize(nTop, nLeft, nBottom, nRight)           // Redefines editor window size and refreshes it
   METHOD SetColor(cColorString)                         // Sets/retrieves color used for screen writes
   METHOD Hilite()                                       // Start Hilighting swapping first two color definitions inside cColorSpec
   METHOD DeHilite()                                     // Stop Hilighting

   METHOD SetPos(nRow, nCol)                             // Updates ::nPhysRow, ::nPhysCol and then calls SetPos() to move hardware cursor
   METHOD Row() INLINE ::nPhysRow                        // Same as clipper ones, returns ::nPhysRow value
   METHOD Col() INLINE ::nPhysCol                        // Same as clipper ones, returns ::nPhysCol value

ENDCLASS


// Returns EOL char (be it either CR or LF or both)
STATIC function WhichEOL(cString)

   LOCAL nCRPos := At(Chr(13), cString)
   LOCAL nLFPos := At(Chr(10), cString)

   if nCRPos > 0 .AND. nLFPos == 0
      return Chr(13)

   elseif nCRPos == 0 .AND. nLFPos >  0
      return Chr(10)

   elseif nCRPos > 0 .AND. nLFPos == nCRPos + 1
      return Chr(13) + Chr(10)

   endif

return HB_OSNewLine()


// Converts a string to an array of strings splitting input string at EOL boundaries
STATIC function Text2Array(cString, nWordWrapCol)

   LOCAL cLine
   LOCAL nTokNum
   LOCAL aArray
   LOCAL cEOL
   LOCAL nEOLLen
   LOCAL nRetLen
   LOCAL ncSLen
   LOCAL nFirstSpace
   LOCAL cSplittedLine
   LOCAL nTokPos := 0

   nTokNum := 1
   aArray := {}

   cEOL := WhichEOL(cString)
   nEOLLen := Len(cEOL)

   // __StrTkPtr() needs that string to be tokenized be terminated with a token delimiter
   if Rat(cEOL, cString) <> Len(cString) - nEOLLen + 1
      cString += cEOL
   endif

   nRetLen := 0
   ncSLen := Len(cString)

   // If cString starts with an EOL delimiter I have to add an empty line since __StrTkPtr
   // gives back _next_ token and would skip this first EOL delimiter
   if Left(cString, nEOLLen) == cEOL
      AAdd(aArray, HBTextLine():New(cLine, .F.))
      nTokPos += nEOLLen
      nRetLen += nEOLLen
   endif

   while nRetLen < ncSLen
      /* TOFIX: Note that __StrToken is not able to cope with delimiters longer than one char */
      // Dos - OS/2 - Windows have CRLF as EOL
      if nEOLLen > 1
         cLine := StrTran(__StrTkPtr(@cString, @nTokPos, cEOL), SubStr(cEOL, 2), "")
      else
         cLine := __StrTkPtr(@cString, @nTokPos, cEOL)
      endif
      nRetLen += Len(cLine) + nEOLLen

      if nWordWrapCol != NIL .AND. Len(cLine) > nWordWrapCol

         while !Empty(cLine)

            // Split line at nWordWrapCol boundary
            if Len(cLine) > nWordWrapCol

               nFirstSpace := nWordWrapCol
               while SubStr(cLine, --nFirstSpace, 1) <> " " .AND. nFirstSpace > 1
               enddo

               if nFirstSpace > 1
                  cSplittedLine := Left(cLine, nFirstSpace)
               else
                  cSplittedLine := Left(cLine, nWordWrapCol)
               endif

               AAdd(aArray, HBTextLine():New(cSplittedLine, .T.))

            else

               // remainder of line is shorter than split point
               cSplittedLine := cLine
               AAdd(aArray, HBTextLine():New(cSplittedLine, .F.))

            endif

            cLine := Right(cLine, Len(cLine) - Len(cSplittedLine))
         enddo

      else
         AAdd(aArray, HBTextLine():New(cLine, .F.))

      endif

   enddo

return aArray


// Converts an array of text lines to a String
METHOD GetText() CLASS HBEditor

   LOCAL cString := ""
   LOCAL cEOL := HB_OSNewLine()

   if ::lWordWrap
      AEval(::aText, {|cItem| cString += cItem:cText + iif(cItem:lSoftCR, "", cEOL)},, ::naTextLen - 1)
   else
      AEval(::aText, {|cItem| cString += cItem:cText + cEOL},, ::naTextLen - 1)
   endif

   // Last line does not need a cEOL delimiter
   cString += ::aText[::naTextLen]:cText

return cString


METHOD New(cString, nTop, nLeft, nBottom, nRight, lEditMode, nLineLength, nTabSize) CLASS HBEditor

   default  cString     to ""
   default  nTop        to 0
   default  nLeft       to 0
   default  nBottom     to MaxRow()
   default  nRight      to MaxCol()
   default  lEditMode   to .T.
   default  nLineLength to nil
   default  nTabSize    to nil

   ::aText := Text2Array(cString, nLineLength)
   ::naTextLen := Len(::aText)

   if ::naTextLen == 0
      AAdd(::aText, HBTextLine():New())
      ::naTextLen++
   endif

   // editor window boundaries
   ::nTop := nTop
   ::nLeft := nLeft
   ::nBottom := nBottom
   ::nRight := nRight

   // How many cols and rows are available
   ::nNumCols := nRight - nLeft + 1
   ::nNumRows := nBottom - nTop + 1

   if lEditMode != NIL
      ::lEditAllow := lEditMode
   endif

   // set correct insert state
   if ::lEditAllow
      ::InsertState(::lInsert)
   endif

   // No need to save
   ::lDirty := .F.

   // is word wrap required?
   if nLineLength != NIL
      ::lWordWrap := .T.
      ::nWordWrapCol := nLineLength
   endif

   // how many spaces for each tab?
   if nTabSize != NIL
      ::nTabWidth := nTabSize
   endif

   // Empty area of screen which will hold editor window
   Scroll(nTop, nLeft, nBottom, nRight)

   // Set cursor upper left corner
   ::SetPos(::nTop, ::nLeft)

return Self


// Redefines editor window size and refreshes it
METHOD Resize(nTop, nLeft, nBottom, nRight) CLASS HBEditor

   // don't change coordinates not given
   default nTop to ::nTop
   default nLeft to ::nLeft
   default nBottom to ::nBottom
   default nRight to ::nRight

   ::nTop := nTop
   ::nLeft := nLeft
   ::nBottom := nBottom
   ::nRight := nRight

   // How many cols and rows are available
   ::nNumCols := ::nRight - ::nLeft + 1
   ::nNumRows := ::nBottom - ::nTop + 1

   // FirstCol/Row of current text visible inside editor window
   ::nFirstCol := 1
   ::nFirstRow := 1
   // Cursor position inside aText (nRow) and inside current line of text (nCol)
   ::nRow := 1
   ::nCol := 1

   // Set cursor upper left corner
   ::SetPos(::nTop, ::nLeft)

   ::RefreshWindow()

return Self


METHOD LoadFile(cFileName) CLASS HBEditor

   local cString := ""

   if File(cFileName)
      ::cFile := cFileName
      cString := MemoRead(cFileName)
   endif

   ::aText := Text2Array(cString, iif(::lWordWrap, ::nNumCols, nil))
   ::naTextLen := Len(::aText)

   if ::naTextLen == 0
      AAdd(::aText, HBTextLine():New())
      ::naTextLen++
   endif

   ::lDirty := .F.
   ::MoveCursor(K_CTRL_PGUP)

return Self


METHOD LoadText(cString) CLASS HBEditor

   ::aText := Text2Array(cString, iif(::lWordWrap, ::nNumCols, nil))
   ::naTextLen := Len(::aText)

   if ::naTextLen == 0
      AAdd(::aText, HBTextLine():New())
      ::naTextLen++
   endif

   ::lDirty := .F.
   ::MoveCursor(K_CTRL_PGUP)

return Self


// Saves file being edited, if there is no file name does nothing, returns .T. if OK
METHOD SaveFile() CLASS HBEditor

   local cString

   if !Empty(::cFile)
      cString := ::GetText()
      ::lDirty := !MemoWrit(::cFile, cString)
      return !::lDirty

   endif

return .F.


// Add a new Line of text at end of current text
METHOD AddLine(cLine, lSoftCR) CLASS HBEditor

   AAdd(::aText, HBTextLine():New(cLine, lSoftCR))
   ::naTextLen++

return Self


// Insert a line of text at a defined row
METHOD InsertLine(cLine, lSoftCR, nRow) CLASS HBEditor

   ::AddLine()
   AIns(::aText, nRow)
   ::aText[nRow] := HBTextLine():New(cLine, lSoftCR)

return Self


// Remove a line of text
METHOD RemoveLine(nRow) CLASS HBEditor

   ADel(::aText, nRow)
   ASize(::aText, --::naTextLen)

return Self


// Return line n of text
METHOD GetLine(nRow) CLASS HBEditor

   if nRow <= ::naTextLen .AND. nRow > 0
      return ::aText[nRow]:cText
   else
      return ""
   endif

return Self


METHOD GotoLine(nRow) CLASS HBEditor

   if nRow <= ::naTextLen .AND. nRow > 0

      // Back one line
      if ::nRow - nRow == 1
         ::MoveCursor(K_UP)

      elseif ::nRow - nRow == -1
         ::MoveCursor(K_DOWN)

      else
         // I need to move cursor if is past requested line number and if requested line is
         // inside first screen of text otherwise ::nFirstRow would be wrong
         if nRow < ::nNumRows .AND. (::nTop + nRow) < ::Row()
            ::SetPos(::nTop + nRow, ::Col())
         endif

         ::nRow := nRow
         ::nFirstRow := Max(1, nRow - (::Row() - ::nTop))

         ::RefreshWindow()
      endif
   endif

return Self

// Rebuild a long line from multiple short ones (wrapped at soft CR)
STATIC function GetParagraph(oSelf, nRow)

   LOCAL cLine := ""

   while oSelf:aText[nRow]:lSoftCR
      cLine += oSelf:aText[nRow]:cText
      // I don't need to increment nRow since I'm removing lines, ie line n is
      // a different line each time I add it to cLine
      oSelf:RemoveLine(nRow)
   enddo

   // Last line, or only one line
   cLine += oSelf:aText[nRow]:cText
   oSelf:RemoveLine(nRow)

return cLine


// If a line of text is longer than nWordWrapCol divides it into multiple lines,
// Used during text editing to reflow a paragraph
METHOD SplitLine(nRow) CLASS HBEditor

   LOCAL nFirstSpace
   LOCAL cLine
   LOCAL cSplittedLine
   LOCAL nStartRow
   LOCAL nOCol
   LOCAL nORow
   LOCAL lMoveToNextLine
   LOCAL nPosInWord
   LOCAL nI

   // Do something only if Word Wrapping is on
   if ::lWordWrap .AND. (::LineLen(nRow) > ::nWordWrapCol)

      nOCol := ::Col()
      nORow := ::Row()

      // Move cursor to next line if you will move the word which I'm over to next line
      // ie, since word wrapping happens at spaces if first space is behind cursor
      lMoveToNextLine := RAt(" ", RTrim(::GetLine(nRow))) < ::nCol
      nPosInWord := Len(::GetLine(nRow)) - ::nCol

      nStartRow := nRow
      cLine := GetParagraph(Self, nRow)

      while !Empty(cLine)

         if Len(cLine) > ::nWordWrapCol
            nFirstSpace := ::nWordWrapCol

            // Split line at fist space before current position
            while SubStr(cLine, --nFirstSpace, 1) <> " " .AND. nFirstSpace > 1
            enddo

            // If there is a space before beginning of line split there
            if nFirstSpace > 1
               cSplittedLine := Left(cLine, nFirstSpace)
            else
               // else split at current cursor position
               cSplittedLine := Left(cLine, ::nCol - 1)
            endif

            ::InsertLine(cSplittedLine, .T., nStartRow++)

         else
            // remainder of line
            cSplittedLine := cLine
            ::InsertLine(cSplittedLine, .F., nStartRow++)
         endif

         cLine := Right(cLine, Len(cLine) - Len(cSplittedLine))
      enddo

      if lMoveToNextLine
         ::MoveCursor(K_DOWN)
         ::MoveCursor(K_HOME)
         ::MoveCursor(K_CTRL_RIGHT)
         if nPosInWord > 0
            // from 0 since I have to take into account previous K_CTRL_RIGHT which moves me past end of word
            for nI := 0 to nPosInWord
               ::MoveCursor(K_LEFT)
            next
         endif
      else
         ::SetPos(nORow, nOCol)
      endif
      ::RefreshWindow()
   endif

return Self


// Redraws a screenfull of text
METHOD RefreshWindow() CLASS HBEditor

   LOCAL i
   LOCAL nOCol
   LOCAL nORow
   LOCAL nOCur

   nOCol := ::Col()
   nORow := ::Row()
   nOCur := SetCursor(SC_NONE)

   for i := 0 to Min(::nNumRows - 1, ::naTextLen - 1)
      DispOutAt(::nTop + i, ::nLeft, PadR(SubStr(::GetLine(::nFirstRow + i), ::nFirstCol, ::nNumCols), ::nNumCols, " "), ::LineColor(::nFirstRow + i))
   next

   // Clear rest of editor window (needed when deleting lines of text)
   if ::naTextLen < ::nNumRows
      Scroll(::nTop + ::naTextLen, ::nLeft, ::nBottom, ::nRight)
   endif

   SetCursor(nOCur)
   ::SetPos(nORow, nOCol)

return Self


// Redraws current screen line
METHOD RefreshLine() CLASS HBEditor

   LOCAL nOCol
   LOCAL nORow

   nOCol := ::Col()
   nORow := ::Row()

   DispOutAt(::Row(), ::nLeft, PadR(SubStr(::GetLine(::nRow), ::nFirstCol, ::nNumCols), ::nNumCols, " "), ::LineColor(::nRow))

   ::SetPos(nORow, nOCol)

return Self


// Refreshes only one screen column of text (for Left() and Right() movements)
METHOD RefreshColumn() CLASS HBEditor

   LOCAL i
   LOCAL nOCol
   LOCAL nORow
   LOCAL nOCur

   nOCol := ::Col()
   nORow := ::Row()
   nOCur := SetCursor(SC_NONE)

   for i := 0 to Min(::nNumRows - 1, ::naTextLen - 1)
      DispOutAt(::nTop + i, nOCol, SubStr(::GetLine(::nFirstRow + i), ::nCol, 1), ::LineColor(::nFirstRow + i))
   next

   SetCursor(nOCur)
   ::SetPos(nORow, nOCol)

return Self


// Handles cursor movements inside text array
METHOD MoveCursor(nKey) CLASS HBEditor

   LOCAL lMoveKey := .T.

   do case
      case nKey == K_DOWN
         if !::lEditAllow
            while ::Row() < ::nBottom .AND. ::nRow < ::naTextLen
               ::nRow++
               ::SetPos(::Row() + 1, ::Col())
            enddo
         endif
         if ::Row() == ::nBottom
            if ::nRow < ::naTextLen
               Scroll(::nTop, ::nLeft, ::nBottom, ::nRight, 1)
               ::nFirstRow++
               ::nRow++
               ::RefreshLine()
            endif
         else
            if ::nRow < ::naTextLen
               ::nRow++
               ::SetPos(::Row() + 1, ::Col())
            endif
         endif

      case nKey == K_PGDN
         if ::nRow + ::nNumRows < ::naTextLen
            ::nRow += ::nNumRows
            ::nFirstRow += ::nNumRows
            if ::nFirstRow + ::nNumRows > ::naTextLen
               ::nFirstRow -= ((::nFirstRow + ::nNumRows) - ::naTextLen) + 1
            endif
         else
            ::nFirstRow := Max(::naTextLen - ::nNumRows + 1, 1)
            ::nRow := ::naTextLen
            ::SetPos(Min(::nTop + ::naTextLen - 1, ::nBottom), ::Col())
         endif
         ::RefreshWindow()

      case nKey == K_CTRL_PGDN
         ::nRow := ::naTextLen
         ::nCol := Max(::LineLen(::nRow), 1)
         ::nFirstRow := Max(::naTextLen - ::nNumRows + 1, 1)
         ::nFirstCol := Max(::nCol - ::nNumCols + 1, 1)
         ::SetPos(Min(::nTop + ::naTextLen - 1, ::nBottom), Min(::nLeft + ::nCol - 1, ::nRight))
         ::RefreshWindow()

      case nKey == K_UP
         if ! ::lEditAllow
            while ::Row() > ::nTop .AND. ::nRow > 1
               ::nRow--
               ::SetPos(::Row() - 1, ::Col())
            enddo
         endif
         if ::Row() == ::nTop
            if ::nRow > 1
               Scroll(::nTop, ::nLeft, ::nBottom, ::nRight, -1)
               ::nFirstRow--
               ::nRow--
               ::RefreshLine()
            endif
         else
            ::nRow--
            ::SetPos(::Row() - 1, ::Col())
         endif

      case nKey == K_PGUP
         if (::nRow - ::nNumRows) > 1
            ::nRow -= ::nNumRows
            ::nFirstRow -= ::nNumRows
            if ::nFirstRow < 1
               ::nFirstRow := 1
            endif
         else
            ::nFirstRow := 1
            ::nRow := 1
            ::SetPos(::nTop, ::Col())
         endif
         ::RefreshWindow()

      case nKey == K_CTRL_PGUP
         ::nRow := 1
         ::nCol := 1
         ::nFirstCol := 1
         ::nFirstRow := 1
         ::SetPos(::nTop, ::nLeft)
         ::RefreshWindow()

      case nKey == K_RIGHT
         if ::Col() == ::nRight
            if ::nCol <= iif(::lWordWrap, ::nWordWrapCol, ::LineLen(::nRow))
               Scroll(::nTop, ::nLeft, ::nBottom, ::nRight,, 1)
               ::nFirstCol++
               ::nCol++
               ::RefreshColumn()
            endif
         else
            ::nCol++
            ::SetPos(::Row(), ::Col() + 1)
         endif

      case nKey == K_CTRL_RIGHT
         // NOTE: should be faster without call to ::GetLine()
         while ::nCol <= iif(::lWordWrap, Min(::nWordWrapCol, ::LineLen(::nRow)), ::LineLen(::nRow)) .AND. SubStr(::aText[::nRow]:cText, ::nCol, 1) <> " "
            ::MoveCursor(K_RIGHT)
         enddo
         while ::nCol <= iif(::lWordWrap, Min(::nWordWrapCol, ::LineLen(::nRow)), ::LineLen(::nRow)) .AND. SubStr(::aText[::nRow]:cText, ::nCol, 1) == " "
            ::MoveCursor(K_RIGHT)
         enddo

      case nKey == K_LEFT
         if ::Col() == ::nLeft
            if ::nCol > 1
               Scroll(::nTop, ::nLeft, ::nBottom, ::nRight,, -1)
               ::nFirstCol--
               ::nCol--
               ::RefreshColumn()
            endif
         else
            ::nCol--
            ::SetPos(::Row(), ::Col() - 1)
         endif

      case nKey == K_CTRL_LEFT
         while ::nCol > 1 .AND. SubStr(::aText[::nRow]:cText, ::nCol, 1) <> " "
            ::MoveCursor(K_LEFT)
         enddo
         while ::nCol > 1 .AND. SubStr(::aText[::nRow]:cText, ::nCol, 1) == " "
            ::MoveCursor(K_LEFT)
         enddo

      case nKey == K_HOME
         ::nCol := 1
         ::nFirstCol := 1
         ::SetPos(::Row(), ::nLeft)
         ::RefreshWindow()

      case nKey == K_CTRL_HOME
         ::nCol := 1
         ::nFirstCol := 1
         ::nRow -= (::Row() - ::nTop)
         ::SetPos(::nTop, ::nLeft)
         ::RefreshWindow()

      case nKey == K_END
         // Empty lines have 0 len
         ::nCol := Max(::LineLen(::nRow)+1, 1)
         ::nFirstCol := Max(::nCol - ::nNumCols + 1, 1)
         ::SetPos(::Row(), Min(::nLeft + ::nCol - 1, ::nRight))
         ::RefreshWindow()

      case nKey == K_CTRL_END
         ::nRow += ::nBottom - ::Row()
         if ::nRow > ::naTextLen
            ::nRow := ::naTextLen
         endif
         ::nCol := Max(::LineLen(::nRow), 1)
         ::nFirstCol := Max(::nCol - ::nNumCols + 1, 1)
         ::SetPos(Min(::nTop + ::naTextLen - 1, ::nBottom), Min(::nLeft + ::nCol - 1, ::nRight))
         ::RefreshWindow()

      otherwise
         lMoveKey := .F.

   endcase

return lMoveKey


// Changes lInsert value and insertion / overstrike mode of editor
METHOD InsertState(lInsState) CLASS HBEditor

   ::lInsert := lInsState
   SET(_SET_INSERT, lInsState)

return Self


// if editing isn't allowed we enter this loop which
// handles only movement keys and discards all the others
STATIC procedure BrowseText(oSelf, nPassedKey)

   LOCAL nKey,bKeyBlock

   while ! oSelf:lExitEdit

      // If I haven't been called with a key already preset, evaluate this key and then exit
      if nPassedKey == NIL
         if NextKey() == 0
            oSelf:IdleHook()
         endif
         nKey := InKey(0)
      else
         nKey = nPassedKey
      endif

      IF !( ( bKeyBlock := setkey( nKey ) ) == NIL )
         eval( bKeyBlock )
         return 
      endif

      if nKey == K_ESC
         oSelf:lExitEdit := .T.

      else
         if !oSelf:MoveCursor(nKey)
            oSelf:KeyboardHook(nKey)
         endif

      endif

   enddo

return


// Edits text
METHOD Edit(nPassedKey) CLASS HBEditor

   LOCAL i
   LOCAL nKey
   LOCAL lOldInsert
   LOCAL lDelAppend
   LOCAL bKeyBlock
   LOCAL lSingleKeyProcess := .F.         // .T. if I have to process passed key and then exit

   if ! ::lEditAllow
      BrowseText(Self,nPassedKey)

   else

      // If user pressed an exiting key (K_ESC or K_ALT_W) or I've received a key to handle and then exit
      while ! ::lExitEdit .AND. ! lSingleKeyProcess

         // If I haven't been called with a key already preset, evaluate this key and then exit
         if nPassedKey == NIL
            if NextKey() == 0
               ::IdleHook()
            endif
            nKey := InKey(0)
         else
            lSingleKeyProcess := .T.
            nKey := nPassedKey
         endif
         IF !( ( bKeyBlock := setkey( nKey ) ) == NIL )
            eval( bKeyBlock )
            return Self
         endif

         do case
            case nKey >= K_SPACE .AND. nKey < 256
               ::lDirty := .T.
               // If I'm past EOL I need to add as much spaces as I need to reach ::nCol
               if ::nCol > ::LineLen(::nRow)
                  ::aText[::nRow]:cText += Space(::nCol - ::LineLen(::nRow))
               endif
               // insert char if in insert mode or at end of current line
               if ::lInsert .OR. (::nCol > ::LineLen(::nRow))
                  ::aText[::nRow]:cText := Stuff(::aText[::nRow]:cText, ::nCol, 0, Chr(nKey))
               else
                  ::aText[::nRow]:cText := Stuff(::aText[::nRow]:cText, ::nCol, 1, Chr(nKey))
               endif
               ::MoveCursor(K_RIGHT)
               ::RefreshLine()
               ::SplitLine(::nRow)

            case nKey == K_RETURN
               ::lDirty := .T.
               if ::lInsert .OR. ::nRow == ::naTextLen
                  if ::LineLen(::nRow) > 0
                     // Split current line at cursor position
                     ::InsertLine(Right(::aText[::nRow]:cText, ::LineLen(::nRow) - ::nCol + 1), ::aText[::nRow]:lSoftCR, ::nRow + 1)
                     ::aText[::nRow]:cText := Left(::aText[::nRow]:cText, ::nCol - 1)
                     if ::lWordWrap
                        ::aText[::nRow]:lSoftCR := .F.
                     endif
                  else
                     ::InsertLine("", .F., ::nRow + 1)
                  endif
               endif
               ::MoveCursor(K_DOWN)
               ::MoveCursor(K_HOME)

            case nKey == K_INS
               ::InsertState(!::lInsert)

            case nKey == K_DEL
               ::lDirty := .T.
               // If I'm on last char of a line and there are more lines, append next line to current one
               lDelAppend := ::nCol > ::LineLen(::nRow)
               ::aText[::nRow]:cText := Stuff(::aText[::nRow]:cText, ::nCol, 1, "")
               if lDelAppend
                  if ::nRow < ::naTextLen
                     ::aText[::nRow]:cText += ::GetLine(::nRow + 1)
                     ::RemoveLine(::nRow + 1)
                     ::RefreshWindow()
                  else
                     ::RefreshLine()
                  endif
               else
                  ::RefreshLine()
               endif

            case nKey == K_TAB
               // insert char if in insert mode or at end of current line
               if ::lInsert .OR. (::nCol == ::LineLen(::nRow))
                  ::aText[::nRow]:cText := Stuff(::aText[::nRow]:cText, ::nCol, 0, Space(::nTabWidth))
                  ::lDirty := .T.
               endif
               for i := 1 to ::nTabWidth
                  ::MoveCursor(K_RIGHT)
               next
               ::RefreshLine()

            case nKey == K_BS
               ::lDirty := .T.
               // delete previous character
               ::aText[::nRow]:cText := Stuff(::aText[::nRow]:cText, --::nCol, 1, "")
               // correct column position for next call to MoveCursor()
               ::nCol++
               ::MoveCursor(K_LEFT)
               ::RefreshLine()

            case nKey == K_CTRL_Y
               ::lDirty := .T.
               if ::naTextLen > 1
                  ::RemoveLine(::nRow)
                  // if we have less lines of text than our current position, up one line
                  if ::nRow > ::naTextLen
                     ::nRow := Max(::nRow - 1, 1)
                     // if our position on screen exceeds text length, up one row
                     if (::nFirstRow + ::nNumRows - 1) > ::naTextLen
                        ::SetPos(Max(::Row() - 1, ::nTop), ::Col())
                     endif
                     // if first line of displayed text is less than length of text
                     if ::nFirstRow > ::naTextLen
                        ::nFirstRow := Max(::nFirstRow - 1, 1)
                     endif
                  endif
                  ::RefreshWindow()
               else
                  ::aText[::nRow]:cText := ""
                  ::RefreshLine()
               endif

            case ::MoveCursor(nKey)
               // if it's a movement key ::MoveCursor() handles it

            case nKey == K_ALT_W
               /* TOFIX: Not clipper compatible */
               ::lSaved := .T.
               ::lExitEdit := .T.

            case nKey == K_ESC
               ::lSaved := .F.
               ::lExitEdit := .T.

            otherwise
               /* NOTE: if you call ::Edit() with a key that is passed to ::KeyboardHook() and then
                        ::KeyboardHook() calls ::Edit() with the same key you end up with an endless loop */
               ::KeyboardHook(nKey)
         endcase
      enddo
   endif

return Self


// This in an empty method which can be used by classes subclassing HBEditor to be able
// to handle particular keys.
METHOD KeyboardHook(nKey)  CLASS HBEditor

return Self


// There are no more keys to handle. Can I do something for you?
METHOD IdleHook()  CLASS HBEditor

return Self


METHOD SetColor(cColorString) CLASS HBEditor

   local cOldColor := ::cColorSpec

   if cColorString <> nil
      ::cColorSpec := cColorString
   endif

return cOldColor


METHOD Hilite() CLASS HBEditor

   local cEnhanced := ""

   // Swap CLR_STANDARD and CLR_ENHANCED
   cEnhanced += __StrToken(::cColorSpec, 2, ",") +  ","
   cEnhanced += __StrToken(::cColorSpec, 1, ",")

   ::SetColor(cEnhanced + Right(::cColorSpec, Len(::cColorSpec) - Len(cEnhanced)))

return Self


METHOD DeHilite() CLASS HBEditor

   local cStandard := ""

   // Swap CLR_STANDARD and CLR_ENHANCED back to their original position inside cColorSpec
   cStandard += __StrToken(::cColorSpec, 2, ",") +  ","
   cStandard += __StrToken(::cColorSpec, 1, ",")

   ::SetColor(cStandard + Right(::cColorSpec, Len(::cColorSpec) - Len(cStandard)))

return Self


METHOD SetPos(nRow, nCol) CLASS HBEditor

   default nRow to ::nPhysRow
   default nCol to ::nPhysCol

   ::nPhysRow := nRow
   ::nPhysCol := nCol

   SetPos(::nPhysRow, ::nPhysCol)

return ::nPhysRow


/*METHOD LineColor(nRow) CLASS HBEditor

return ::cColorSpec*/
