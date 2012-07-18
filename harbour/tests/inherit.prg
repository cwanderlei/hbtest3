/*
 * $Id$
 */

#include "set.ch"

//
// Inherit
//
// Test of inheritance
//
// Date : 30/05/1999
//

/*
 * Written by Eddie Runia <eddie@runia.comu>
 * www - http://harbour-project.org
 *
 * Placed in the public domain
 */

PROCEDURE Main()

   LOCAL oFrom
   LOCAL oTo
   LOCAL cOut

   SET( _SET_EXACT, .T. )

   oFrom := TOnTop()   :New( "hello.prg", "R" )
   oTo   := TTextFile():New( "hello.out", "W" )

   QOut( "What's in oFrom" )
   Debug( { oFrom, __objGetMethodList( oFrom ) } )

   QOut()
   QOut( "What's in oFrom:TEmpty" )
   Debug( { oFrom:TEmpty, __objGetMethodList( oFrom:TEmpty ) } )

   QOut()
   QOut( "Let's call Run() from TEmpty : " )
   oFrom:TEmpty:Run()

   QOut()
   QOut( "Let's call a method from TEmpty and one from TOnTop" )
   oFrom:Set( "Done !" )
   oFrom:Say( "Out" )

   QOut()
   QOut( "Basic copy loop using the default Run() from TTextFile" )
   DO WHILE !oFrom:lEoF
      cOut := oFrom:Run()
      QOut( cOut )
      oTo:Run( cOut )
   ENDDO
   oFrom:Dispose()
   oTo:Dispose()

   //   Debug( __dbgvmStkGList() )  // Stack is OK!

   RETURN

//
// Generic Empty Class
//

FUNCTION TEmpty()

   STATIC oEmpty

   IF oEmpty == NIL
      oEmpty := HBClass():New( "TEmpty" )             // Create a new class def

      oEmpty:AddInline( "New", { |self|self } )

      oEmpty:AddInline( "Run", { ||QOut( "Run !" ) } )  // Test command
      oEmpty:AddInline( "Set", { |self, xParam|::Out := xParam } )
      oEmpty:AddData( "Out", "Hi there" )            // Test command
      oEmpty:AddVirtual( "Dispose" )                 // Clean up code

      oEmpty:Create()
   ENDIF

   RETURN oEmpty:Instance()

//
// Let's add another one on top
//

FUNCTION TOnTop()

   STATIC oOnTop

   IF oOnTop == NIL
      oOnTop := HBClass():New( "TOnTop", "TTextFile" )
      oOnTop:AddInline( "Say", { |self, cArg| QOut( __objSendMsg(self, cArg ) ) } )
      oOnTop:Create()
   ENDIF

   RETURN oOnTop:Instance()

//
// Generic Text file handler
//

FUNCTION TTextFile()

   STATIC oFile

   IF oFile == NIL
      oFile := HBClass():New( "TTextFile", "TEmpty" )
      // Create a new class def
      // from TEmpty class

      oFile:AddData( "cFileName"  )             // Filename spec. by user
      oFile:AddData( "hFile"      )             // File handle
      oFile:AddData( "nLine"      )             // Current linenumber
      oFile:AddData( "nError"     )             // Last error
      oFile:AddData( "lEoF"       )             // End of file
      oFile:AddData( "cBlock"     )             // Storage block
      oFile:AddData( "nBlockSize" )             // Size of read-ahead buffer
      oFile:AddData( "cMode"      )             // Mode of file use
      // R = read, W = write

      oFile:AddMethod( "New"    , @New()     )  // Constructor
      oFile:AddMethod( "Run"    , @Run()     )  // Get/set data
      oFile:AddMethod( "Dispose", @Dispose() )  // Clean up code
      oFile:AddMethod( "Read"   , @Read()    )  // Read line
      oFile:AddMethod( "WriteLn", @WriteLn() )  // Write line
      oFile:AddMethod( "Write"  , @Write()   )  // Write without CR
      oFile:AddMethod( "Goto"   , @Goto()    )  // Go to line

      oFile:Create()
   ENDIF

   RETURN oFile:Instance()

//
// Method TextFile:New -> Create a new text file
//
// <cFile>      file name. No wild characters
// <cMode>      mode for opening. Default "R"
// <nBlockSize> Optional maximum blocksize
//

FUNCTION New( cFileName, cMode, nBlock )

   LOCAL self := QSelf()                        // Get self

   ::nLine     := 0
   ::lEoF      := .F.
   ::cBlock    := ""
   ::cFileName := cFileName
   ::cMode     := Default( cMode, "R" )

   if ::cMode == "R"
      ::hFile := FOpen( cFileName )
   elseif ::cMode == "W"
      ::hFile := FCreate( cFileName )
   ELSE
      QOut( "DosFile Init: Unknown file mode:", ::cMode )
   ENDIF

   ::nError := FError()
   if ::nError != 0
      ::lEoF := .T.
      QOut( "Error ", ::nError )
   ENDIF
   ::nBlockSize := Default( nBlock, 4096 )

   RETURN self

FUNCTION RUN( xTxt, lCRLF )

   LOCAL self := QSelf()
   LOCAL xRet

   if ::cMode == "R"
      xRet := ::Read()
   ELSE
      xRet := ::WriteLn( xTxt, lCRLF )
   ENDIF

   RETURN xRet

//
// Dispose -> Close the file handle
//

FUNCTION Dispose()

   LOCAL self := QSelf()

   ::cBlock := NIL
   if ::hFile != - 1
      if ::cMode == "W" .AND. ::nError != 0
         ::Write( Chr( 26 ) )                     // Do not forget EOF marker
      ENDIF
      IF !FClose( ::hFile )
         ::nError := FError()
         QOut( "Dos Error closing ", ::cFileName, " Code ", ::nError )
      ENDIF
   ENDIF

   RETURN self

//
// Read a single line
//

FUNCTION READ()

   LOCAL self := QSelf()
   LOCAL cRet  := ""
   LOCAL cBlock
   LOCAL nCrPos
   LOCAL nEoFPos
   LOCAL nRead

   if ::hFile == - 1
      QOut( "DosFile:Read : No file open" )
   elseif ::cMode != "R"
      QOut( "File ", ::cFileName, " not open for reading" )
   ELSEIF !::lEoF

      IF Len( ::cBlock ) == 0                     // Read new block
         cBlock := FReadStr( ::hFile, ::nBlockSize )
         IF Len( cBlock ) == 0
            ::nError := FError()                // Error or EOF
            ::lEoF   := .T.
         ELSE
            ::cBlock := cBlock
         ENDIF
      ENDIF

      IF !::lEoF
         ::nLine ++
         nCRPos := At( Chr( 10 ), ::cBlock )
         IF nCRPos != 0                         // More than one line read
            cRet     := SubStr( ::cBlock, 1, nCRPos - 1 )
            ::cBlock := SubStr( ::cBlock, nCRPos + 1 )
         ELSE                                   // No complete line
            cRet     := ::cBlock
            ::cBlock := ""
            cRet     += ::Read()                // Read the rest
            IF !::lEoF
               ::nLine --                        // Adjust erroneous line count
            ENDIF
         ENDIF
         nEoFPos := At( Chr( 26 ), cRet )
         IF nEoFPos != 0                        // End of file read
            cRet   := SubStr( cRet, 1, nEoFPos - 1 )
            ::lEoF := .T.
         ENDIF
         cRet := StrTran( cRet, Chr( 13 ), "" )   // Remove CR
      ENDIF
   ENDIF

   RETURN cRet

//
// WriteLn -> Write a line to a file
//
// <xTxt>  Text to write. May be any type. May also be an array containing
//         one or more strings
// <lCRLF> End with Carriage Return/Line Feed (Default == TRUE)
//

FUNCTION WriteLn( xTxt, lCRLF )

   LOCAL self := QSelf()
   LOCAL cBlock

   if ::hFile == - 1
      QOut( "DosFile:Write : No file open" )
   elseif ::cMode != 'W'
      QOut( "File ", ::cFileName, " not opened for writing" )
   ELSE
      cBlock := ToChar( xTxt )                  // Convert to string
      IF DEFAULT( lCRLF, .T. )
         cBlock += Chr( 10 ) + Chr( 13 )
      ENDIF
      FWrite( ::hFile, cBlock, Len( cBlock ) )
      IF FError() != 0
         ::nError := FError()                   // Not completely written !
      ENDIF
      ::nLine := ::nLine + 1
   ENDIF

   RETURN self

FUNCTION Write( xTxt )

   LOCAL self := QSelf()

   return ::WriteLn( xTxt, .F. )

   //
   // Go to a specified line number
   //

STATIC FUNCTION GOTO( nLine )

   LOCAL self   := QSelf()
   LOCAL nWhere := 1

   IF Empty( ::hFile )
      QOut( "DosFile:Goto : No file open" )
   elseif  ::cMode != "R"
      QOut( "File ", ::cFileName, " not open for reading" )
   ELSE
      ::lEoF   := .F.                           // Clear (old) End of file
      ::nLine  := 0                             // Start at beginning
      ::cBlock := ""
      FSeek( ::hFile, 0 )                         // Go top
      DO WHILE !::lEoF .AND. nWhere < nLine
         nWhere ++
         ::Read()
      ENDDO
   ENDIF

   RETURN !::lEoF
