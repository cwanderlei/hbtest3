/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Dummy functions until they are not implemented
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

/* TODO: Dummy functions, should be removed when implemented. */

FUNCTION ordBagExt()       ; RETURN ".ntx"
FUNCTION ordBagName()      ; RETURN ""
FUNCTION ordCondSet()      ; RETURN NIL
FUNCTION ordCreate()       ; RETURN NIL
FUNCTION ordDestroy()      ; RETURN NIL
FUNCTION ordFor()          ; RETURN NIL
FUNCTION ordKey()          ; RETURN ""
FUNCTION ordListAdd()      ; RETURN NIL
FUNCTION ordListClear()    ; RETURN NIL
FUNCTION ordListRebuild()  ; RETURN NIL
FUNCTION ordName()         ; RETURN ""
FUNCTION ordNumber()       ; RETURN 0
FUNCTION ordSetFocus()     ; RETURN 0
FUNCTION IndexOrd()        ; RETURN 0

FUNCTION dbSeek()          ; RETURN .F.
FUNCTION dbSetRelation()   ; RETURN NIL
FUNCTION dbClearRelation() ; RETURN NIL
FUNCTION dbEval()          ; RETURN NIL
FUNCTION dbFileGet()       ; RETURN .F. /* 5.3 */
FUNCTION dbFilePut()       ; RETURN .F. /* 5.3 */
FUNCTION dbInfo()          ; RETURN NIL /* 5.3 */
FUNCTION dbOrderInfo()     ; RETURN NIL /* 5.3 */
FUNCTION dbRecordInfo()    ; RETURN NIL /* 5.3 */
FUNCTION dbFieldInfo()     ; RETURN NIL /* 5.3 */

FUNCTION MemoEdit( str )   ; RETURN str
FUNCTION MLCToPos()        ; RETURN 0
FUNCTION MLPos()           ; RETURN 0
FUNCTION MPosToLC()        ; RETURN 0

FUNCTION __dbApp()         ; RETURN NIL
FUNCTION __dbCopy()        ; RETURN NIL
FUNCTION __dbDelim()       ; RETURN NIL
FUNCTION __dbJoin()        ; RETURN NIL
FUNCTION __dbList()        ; RETURN NIL
FUNCTION __dbSDF()         ; RETURN NIL
FUNCTION __dbSort()        ; RETURN NIL
FUNCTION __dbTotal()       ; RETURN NIL
FUNCTION __dbUpdate()      ; RETURN NIL

/* NOTE: Internal functions */
FUNCTION __dbArrange()     ; RETURN NIL
FUNCTION __dbFList()       ; RETURN {}
FUNCTION __dbOpenSDF()     ; RETURN NIL
FUNCTION __dbTrans()       ; RETURN NIL
FUNCTION __dbTransRec()    ; RETURN NIL

FUNCTION __TypeFile()      ; RETURN NIL
FUNCTION __LabelForm()     ; RETURN NIL
FUNCTION __ReportForm()    ; RETURN NIL

FUNCTION GetActive()       ; RETURN NIL
FUNCTION GetApplyKey()     ; RETURN NIL
FUNCTION GetDoSetKey()     ; RETURN NIL
FUNCTION GetPostValidate() ; RETURN .T.
FUNCTION GetPreValidate()  ; RETURN .T.
FUNCTION GetReader()       ; RETURN NIL
FUNCTION ReadFormat()      ; RETURN .F.
FUNCTION ReadKill()        ; RETURN .F.
FUNCTION ReadUpdated()     ; RETURN .T.
FUNCTION Updated()         ; RETURN .T.
FUNCTION __SetFormat()     ; RETURN NIL

